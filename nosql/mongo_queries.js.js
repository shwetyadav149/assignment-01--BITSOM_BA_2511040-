// Switch to database
use assignment_db
switched to db assignment_db
db["products"].find()
//--------------------------------------------------
db.products.insertMany([
  {
    product_id: "E101",
    name: "iPhone 15",
    category: "Electronics",
    price: 80000,
    specs: { warranty: "1 year", voltage: "220V" }
  },
  {
    product_id: "C101",
    name: "T-Shirt",
    category: "Clothing",
    price: 999,
    sizes: ["S", "M", "L"],
    material: "Cotton"
  },
  {
    product_id: "G101",
    name: "Milk",
    category: "Groceries",
    price: 60,
    expiry_date: "2024-12-01",
    nutrition: { calories: 150, protein: "8g" }
  }
]);
// OP2
db.products.find({
  category: "Electronics",
  price: { $gt: 20000 }
});
// OP3
db.products.find({
  category: "Groceries",
  expiry_date: { $lt: "2025-01-01" }
});
// OP4
db.products.updateOne(
  { name: "iPhone 15" },
  { $set: { discount_percent: 10 } }
);
// OP5
db.products.createIndex({ category: 1 });