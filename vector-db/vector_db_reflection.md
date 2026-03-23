## Vector DB Use Case

A traditional keyword-based database search would not be sufficient for a law firm dealing with large contracts. Keyword search relies on exact word matches, which makes it ineffective when users phrase queries differently from how the content is written. For example, a lawyer searching for “termination clauses” might miss relevant sections if the document uses terms like “contract cancellation” or “agreement end conditions.” This limitation reduces the accuracy and usefulness of the system.

In contrast, a vector database enables semantic search by using embeddings. Embeddings convert both the contract text and user queries into numerical vectors that capture their meaning rather than just keywords. This allows the system to find relevant sections even if the wording is different but the meaning is similar.

In this system, the 500-page contracts would first be broken into smaller chunks and converted into embeddings using models like sentence-transformers. These embeddings would be stored in a vector database. When a lawyer asks a question in plain English, the query is also converted into an embedding and compared with stored vectors using similarity measures like cosine similarity.

The vector database quickly retrieves the most relevant sections based on semantic similarity. This approach improves search accuracy, reduces time spent reviewing documents, and enables a more intuitive, AI-powered search experience for legal professionals.