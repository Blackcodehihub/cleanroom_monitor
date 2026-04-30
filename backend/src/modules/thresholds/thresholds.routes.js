const express = require("express");
const supabase = require("../../config/supabase");

const router = express.Router();

router.post("/:deviceId", async (req, res) => {
  try {
    const { deviceId } = req.params;
    const { maxTemperature, maxHumidity, maxParticleLevel } = req.body;

    const { data, error } = await supabase
      .from("thresholds")
      .insert([
        {
          device_id: deviceId,
          max_temperature: maxTemperature,
          max_humidity: maxHumidity,
          max_particle_level: maxParticleLevel,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    res.status(201).json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/:deviceId", async (req, res) => {
  try {
    const { deviceId } = req.params;

    const { data, error } = await supabase
      .from("thresholds")
      .select("*")
      .eq("device_id", deviceId)
      .order("updated_at", { ascending: false })
      .limit(1)
      .single();

    if (error) throw error;

    res.json(data);
  } catch (error) {
    res.status(404).json({ error: "Threshold not found" });
  }
});

module.exports = router;