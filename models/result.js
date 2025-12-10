const mongoose = require("mongoose");

const AnswerSchema = new mongoose.Schema({
  questionId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
  },

  // Written / typed answer
  writtenAnswer: {
    type: String,
    default: "",
  },

  // Uploaded scanned answer sheets (images or PDFs)
  fileUploads: [
    {
      type: String, // stores file URL: /uploads/filename.jpg
    },
  ],

  // Evaluator marks per question
  evaluatorScore: {
    type: Number,
    default: 0,
  },
});

const ResultSchema = new mongoose.Schema({
  examId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Exam",
    required: true,
  },

  studentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  // Array of per-question answers
  answers: {
    type: [AnswerSchema],
    required: true,
  },

  // Overall score assigned by evaluator
  score: {
    type: Number,
    default: 0,
  },

  // Total questions or max marks
  totalMarks: {
    type: Number,
    required: true,
  },

  // Evaluation status
  status: {
    type: String,
    enum: ["pending", "evaluated"],
    default: "pending",
  },

  // Who evaluated
  evaluatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    default: null,
  },

  submittedAt: {
    type: Date,
    default: Date.now,
  },

  evaluatedAt: {
    type: Date,
  },
});

module.exports = mongoose.model("Result", ResultSchema);
