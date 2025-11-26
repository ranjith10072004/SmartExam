const router = require("express").Router();
const Exam = require("../models/exam");
const Result = require("../models/result");
const auth = require("../middleware/auth");

// Student submits exam answers → stored as pending
router.post("/submit/:examId", auth(["student"]), async (req, res) => {
  try {
    const { examId } = req.params;
    const { answers } = req.body;

    const exam = await Exam.findById(examId);
    if (!exam) return res.status(404).json({ msg: "Exam not found" });

    const result = await Result.create({
      examId,
      studentId: req.user.id,
      answers,
      totalMarks: exam.questions.length,
      status: "pending",
    });

    res.json({
      msg: "Exam submitted successfully. Awaiting evaluation.",
      resultId: result._id,
    });
  } catch (error) {
    res.status(500).json({ msg: "Error", error: error.message });
  }
}); 

module.exports = router;
