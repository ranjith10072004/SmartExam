const jwt = require("jsonwebtoken");

module.exports = (roles = []) => {
  return (req, res, next) => {
    const token = req.headers["authorization"];

    if (!token) return res.status(401).json({ msg: "No token" });

    try {
      const decoded = jwt.verify(token, "secret123");
      req.user = decoded;

      if (roles.length && !roles.includes(decoded.role)) {
        return res.status(403).json({ msg: "Access denied" });
      }

      next();
    } catch {
      res.status(400).json({ msg: "Invalid token" });
    }
  };
};
