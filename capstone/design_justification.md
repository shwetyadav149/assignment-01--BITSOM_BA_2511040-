# Part 6.2 — Hospital Data Architecture: Design Justification

## Storage Systems

The hospital data system uses a **polyglot persistence** approach, selecting distinct storage technologies for each of the four goals to optimize for different access patterns and use cases.

**PostgreSQL (Patient Records OLTP)**: For the EHR system handling current patient records, I chose PostgreSQL as the primary transactional database. This is essential for the doctor-facing application that requires immediate, consistent reads and writes of patient data. PostgreSQL's ACID guarantees ensure data integrity during concurrent access—critical when multiple departments update a patient's record simultaneously. The relational schema naturally models the complex relationships between patients, visits, medications, and allergies. Strong foreign key constraints prevent orphaned records.

**TimescaleDB (Real-time ICU Vitals)**: For streaming ICU monitoring data, TimescaleDB is the ideal choice. It extends PostgreSQL with time-series optimization, enabling efficient storage and querying of millions of vital sign measurements (heart rate, oxygen saturation, blood pressure) arriving every few seconds from dozens of beds. Its automatic time-based partitioning keeps recent data hot in memory while archiving older data, delivering sub-second latency for real-time dashboards and anomaly detection. Standard PostgreSQL would struggle with this ingest rate and query pattern.

**Snowflake/BigQuery (Data Warehouse OLAP)**: For monthly reporting and analytical queries across the entire hospital network, I chose a cloud data warehouse. These systems excel at aggregating historical data across years—computing department-wise costs, bed occupancy trends, readmission correlations—through massively parallel processing. Unlike OLTP databases designed for single-row updates, warehouses compress historical data and optimize columnar scans, making it 10–100× faster to answer "What was average occupancy in ICU last quarter?" than querying the live OLTP system. The warehouse is fed nightly by ETL, decoupling analytics from operational workloads.

**Feature Store (Feast or Postgres-backed)**: For the readmission risk prediction model, a feature store materializes pre-computed features—average length of stay, previous hospitalizations, comorbidity codes—indexed by patient ID. This avoids expensive re-computation during inference; the model simply looks up the latest features rather than scanning treatment history tables. A feature store also tracks feature versioning, ensuring the model always uses consistent feature definitions during training and serving.

## OLTP vs OLAP Boundary

The architecture **sharply separates transactional and analytical workloads** at the ETL layer, solving a critical problem: unoptimized analytical queries can lock production tables and degrade doctor responsiveness.

**Transactional system (OLTP)**: PostgreSQL and TimescaleDB serve immediate operational needs. Doctors querying a patient's allergy list, nurses recording vital signs, and the alerting system consuming ICU streams happen in real-time on these systems. These databases are sized and configured for low-latency, high-concurrency, single-row or small-batch operations. Schema is normalized to minimize update anomalies.

**Boundary**: An ETL pipeline (running nightly or hourly) **reads** from OLTP systems in a non-blocking way and **writes** to the data warehouse. This one-directional flow means analytics never interfere with patient care operations. The pipeline uses snapshot isolation or CDC (change data capture) to extract deltas without locking production tables.

**Analytical system (OLAP)**: Snowflake/BigQuery stores denormalized fact tables and dimensions optimized for historical analysis. Data is heavily indexed and partitioned by date, enabling fast scans of millions of records. Doctors can run exploratory queries ("Show me readmissions by department over the last 12 months") without worry—these queries cannot slow down the EHR or vital-monitoring systems.

**Plain-English queries**: The semantic search service queries the warehouse (via the vector database and LLM), not the live EHR. If the doctor asks "Has this patient had cardiac issues?", the system searches a denormalized history table in the warehouse, returning results in seconds. This is acceptable latency for diagnostic context; the doctor doesn't need microseconds.

## Trade-offs

**The key trade-off: Data freshness vs. system stability.**

The nightly ETL batch means the data warehouse is 4–24 hours stale. Monthly reports may include data that's already a day old. For a doctor running an analytical query mid-month, the answer reflects last night's snapshot, not this instant's reality. In an ideal world, the warehouse would be real-time—but this comes at a cost: real-time ETL pipelines (streaming from Kafka directly to Snowflake, or using CDC) are significantly more complex to operate. They have higher failure rates, require careful idempotency handling, and introduce latency jitter, making real-time analytics unpredictable.

**Mitigation strategies**:
1. **Tiered freshness**: Keep hot data in PostgreSQL and TimescaleDB (real-time), cold data in the warehouse (stale). The query router directs "give me today's ICU metrics" to TimescaleDB and "compare this month vs. last month" to the warehouse.
2. **Scheduled refreshes for reports**: Monthly reports don't require real-time data. Running ETL at midnight ensures doctors have fresh-as-possible data for the next morning's decision-making. For quarterly or annual reviews, daily staleness is irrelevant.
3. **Real-time alerting on OLTP**: Critical alerts—abnormal vitals, infection risks—are detected on live TimescaleDB streams and Kafka topics, bypassing the warehouse entirely. The slower analytical system is reserved for trend discovery, not acute warnings.
4. **Incremental ETL with CDC**: Migrate toward change data capture (PostgreSQL WAL, MySQL binlog, or Kafka Connect) to capture only the deltas since the last run, reducing ETL runtime from hours to minutes and narrowing the staleness window to a few minutes for most use cases.

This design prioritizes **operational stability and doctor safety over maximum freshness**. A stale monthly report that compiles reliably every month is preferable to a real-time warehouse that fails mid-run and delays decision-making.
