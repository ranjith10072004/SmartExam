const jwt = require("jsonwebtoken");

module.exports = (roles = []) => {
  return (req, res, next) => {
    const authHeader = req.headers["authorization"];

    if (!authHeader) return res.status(401).json({ msg: "No token" });

    // Extract token from "Bearer <token>"
    const token = authHeader.split(" ")[1];

    if (!token) return res.status(401).json({ msg: "Token missing" });

    try {
      // ✔ Use the SAME secret that login route uses
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = decoded;

      // ✔ Role check
      if (roles.length && !roles.includes(decoded.role)) {
        return res.status(403).json({ msg: "Access denied" });
      }

      next();
    } catch (error) {
      return res.status(400).json({ msg: "Invalid token" });
    }
  };
};
