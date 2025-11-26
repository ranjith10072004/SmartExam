const router = require("express").Router();

const User = require("../models/user");

const bcrypt = require("bcryptjs");

const jwt = require("jsonwebtoken");
 
// -------------------- REGISTER --------------------

router.post("/register", async (req, res) => {

  try {

    const { name, email, password, role } = req.body;
 
    // Check if email already exists

    const existing = await User.findOne({ email });

    if (existing)

      return res.status(400).json({ error: "Email already registered" });
 
    const hashed = await bcrypt.hash(password, 10);
 
    const user = await User.create({

      name,

      email,

      password: hashed,

      role,

    });
 
    res.json({

      msg: "Registration successful",

      user,

    });

  } catch (err) {

    res.status(500).json({ error: "Server error" });

  }

});
 
// -------------------- LOGIN --------------------

router.post("/login", async (req, res) => {

  try {

    const { email, password } = req.body;
 
    // Check if user exists

    const user = await User.findOne({ email });

    if (!user)

      return res.status(400).json({ error: "User not found" });
 
    // Compare password

    const match = await bcrypt.compare(password, user.password);

    if (!match)

      return res.status(400).json({ error: "Wrong password" });
 
    // Create JWT token

    const token = jwt.sign(

      { id: user._id, role: user.role },

      "secret123",

      { expiresIn: "7d" }

    );
 
    // SUCCESS RESPONSE

    res.json({

      msg: "Login successful",

      token: token,

      type: user.role,   // student or evaluator

    });
 
  } catch (err) {

    res.status(500).json({ error: "Server error" });

  }

});
 
// -------------------- VERY IMPORTANT --------------------

module.exports = router;

 
