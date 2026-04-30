const express = require("express");
const supabase = require("../../config/supabase");

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    const { data, error } = await supabase
      .from("alerts")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(50);

    if (error) throw error;

    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.patch("/:alertId/read", async (req, res) => {
  try {
    const { alertId } = req.params;

    const { data, error } = await supabase
      .from("alerts")
      .update({ is_read: true })
      .eq("id", alertId)
      .select()
      .single();

    if (error) throw error;

    res.json({
      message: "Alert marked as read",
      alert: data,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;