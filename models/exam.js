const mongoose = require("mongoose");

const ExamSchema = new mongoose.Schema({
  title: String,
  questions: [
    {
      question: String,
      options: [String],
      answer: Number,
    },
  ],
});

module.exports = mongoose.model("Exam", ExamSchema);
