const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    await mongoose.connect(
      "mongodb+srv://202317b2418_db_user:J2fltXMkNqR9bxpe@cluster0.wizcchi.mongodb.net/smart-exam"
    );
    console.log("MongoDB Connected");
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
