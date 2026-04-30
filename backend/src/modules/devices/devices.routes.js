const express = require("express");
const supabase = require("../../config/supabase");

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const { name, roomName, status } = req.body;

    const { data, error } = await supabase
      .from("devices")
      .insert([
        {
          name,
          room_name: roomName,
          status: status || "active",
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

router.get("/", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("devices")
      .select("*")
      .order("created_at", { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;