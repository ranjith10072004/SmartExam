const router = require("express").Router();
const Exam = require("../models/exam");
const auth = require("../middleware/auth");

// Admin creates exam
router.post("/createexam", auth(["admin"]), async (req, res) => {
  try {
    const exam = await Exam.create({
      ...req.body,
      createdBy: req.user.id,
    });

    res.json({ msg: "Exam created successfully", exam });
  } catch (err) {
    res.status(500).json({ msg: "Error", error: err.message });
  }
});

module.exports = router;
