const mongoose = require("mongoose");

const QuestionSchema = new mongoose.Schema({
  questionText: { type: String, required: true },

  // Question types:
  // mcq = single choice
  // multiple = multiple correct choices
  // truefalse = true/false
  // short = one word / short answer
  // long = long answer (requires evaluator grading)
  type: {
    type: String,
    enum: ["mcq", "multiple", "truefalse", "short", "long"],
    required: true
  },

  // For MCQ/Multiple/TrueFalse:
  options: [{ type: String }],

  // Correct answers are stored but NEVER sent to student
  correctAnswer: mongoose.Schema.Types.Mixed,
});

const ExamSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: String,
  duration: Number, // in minutes
  createdAt: { type: Date, default: Date.now },

  // List of questions
  questions: [QuestionSchema],

  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User", // Admin
  },
});

module.exports = mongoose.model("Exam", ExamSchema);
