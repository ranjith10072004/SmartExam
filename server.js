const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");

const app = express();
app.use(cors());
app.use(express.json());

connectDB();

// Routes
app.use("/auth", require("./routes/authRoutes"));
app.use("/admin", require("./routes/adminRoutes"));
app.use("/student", require("./routes/studentRoutes"));

app.listen(5000, () => console.log("Server running on port 5000"));