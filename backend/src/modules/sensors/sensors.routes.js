const express = require("express");
const supabase = require("../../config/supabase");

const router = express.Router();

async function createAlertIfNeeded(reading) {
  const { data: threshold, error } = await supabase
    .from("thresholds")
    .select("*")
    .eq("device_id", reading.device_id)
    .order("updated_at", { ascending: false })
    .limit(1)
    .single();

  if (error || !threshold) return [];

  const alerts = [];

  if (Number(reading.temperature) > Number(threshold.max_temperature)) {
    alerts.push({
      device_id: reading.device_id,
      type: "HIGH_TEMPERATURE",
      message: `Temperature is too high: ${reading.temperature}°C`,
      severity: "critical",
    });
  }

  if (Number(reading.humidity) > Number(threshold.max_humidity)) {
    alerts.push({
      device_id: reading.device_id,
      type: "HIGH_HUMIDITY",
      message: `Humidity is too high: ${reading.humidity}%`,
      severity: "warning",
    });
  }

  if (Number(reading.particle_level) > Number(threshold.max_particle_level)) {
    alerts.push({
      device_id: reading.device_id,
      type: "HIGH_PARTICLE_LEVEL",
      message: `Particle level is too high: ${reading.particle_level}`,
      severity: "critical",
    });
  }

  if (alerts.length === 0) return [];

  const { data, error: alertError } = await supabase
    .from("alerts")
    .insert(alerts)
    .select();

  if (alertError) throw alertError;

  return data;
}

router.post("/readings", async (req, res) => {
  try {
    const { deviceId, temperature, humidity, particleLevel } = req.body;

    const { data: reading, error } = await supabase
      .from("sensor_readings")
      .insert([
        {
          device_id: deviceId,
          temperature,
          humidity,
          particle_level: particleLevel,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    const alerts = await createAlertIfNeeded(reading);

    res.status(201).json({
      message: "Sensor reading saved",
      reading,
      alertsCreated: alerts,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/latest/:deviceId", async (req, res) => {
  try {
    const { deviceId } = req.params;

    const { data, error } = await supabase
      .from("sensor_readings")
      .select("*")
      .eq("device_id", deviceId)
      .order("created_at", { ascending: false })
      .limit(1)
      .single();

    if (error) throw error;

    res.json(data);
  } catch (error) {
    res.status(404).json({ error: "No latest reading found" });
  }
});

router.get("/history/:deviceId", async (req, res) => {
  try {
    const { deviceId } = req.params;

    const { data, error } = await supabase
      .from("sensor_readings")
      .select("*")
      .eq("device_id", deviceId)
      .order("created_at", { ascending: false })
      .limit(50);

    if (error) throw error;

    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;