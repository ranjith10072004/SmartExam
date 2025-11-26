const mongoose = require("mongoose");

const QuestionSchema = new mongoose.Schema({
  question: { type: String, required: true },

  // "mcq" | "multiple" | "truefalse" | "short" | "long" | "fill"
  type: { type: String, required: true },

  // Only for MCQ / Multiple Choice / TrueFalse
  options: [{ type: String }],

  // Correct answer(s)
  correctAnswer: mongoose.Schema.Types.Mixed,
  // For MCQ → Number (index)
  // For Multiple → [Number]
  // For TrueFalse → Boolean
  // For short/long/fill → String
});

const ExamSchema = new mongoose.Schema({
  title: { type: String, required: true },
  questions: [QuestionSchema],
});

module.exports = mongoose.model("Exam", ExamSchema);
