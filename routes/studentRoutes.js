const router = require("express").Router();
const Exam = require("../models/exam");
const auth = require("../middleware/auth");

// Students can only view + take exam
router.get("/exam", auth(["student"]), async (req, res) => {
  res.json(await Exam.find());
});

module.exports = router;
