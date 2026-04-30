const express = require("express");
const cors = require("cors");

const deviceRoutes = require("./modules/devices/devices.routes");
const thresholdRoutes = require("./modules/thresholds/thresholds.routes");
const sensorRoutes = require("./modules/sensors/sensors.routes");
const alertRoutes = require("./modules/alerts/alerts.routes");
const authRoutes = require("./modules/auth/auth.routes");

console.log("deviceRoutes:", typeof deviceRoutes);
console.log("thresholdRoutes:", typeof thresholdRoutes);
console.log("sensorRoutes:", typeof sensorRoutes);
console.log("alertRoutes:", typeof alertRoutes);

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ message: "Alima Backend is running with Supabase" });
});

app.use("/api/devices", deviceRoutes);
app.use("/api/thresholds", thresholdRoutes);
app.use("/api/sensors", sensorRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/auth", authRoutes);

module.exports = app;