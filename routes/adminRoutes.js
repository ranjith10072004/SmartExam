const router = require("express").Router();
const Exam = require("../models/exam");
const auth = require("../middleware/auth");

// Create Exam
router.post("/exam", auth(["admin"]), async (req, res) => {
  const exam = await Exam.create(req.body);
  res.json(exam);
});

// Get All Exams
router.get("/exam", auth(["admin"]), async (req, res) => {
  res.json(await Exam.find());
});

module.exports = router;
