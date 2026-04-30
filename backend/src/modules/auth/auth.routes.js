const express = require("express");
const supabase = require("../../config/supabase");

const router = express.Router();

router.post("/signup", async (req, res) => {
  try {
    const { email, password, fullName, role } = req.body;

    const { data, error } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: fullName,
        role: role || "staff",
      },
    });

    if (error) throw error;

    res.status(201).json({
      message: "Account created successfully",
      user: data.user,
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;

    res.json({
      message: "Login successful",
      user: data.user,
      session: data.session,
    });
  } catch (error) {
    res.status(401).json({ error: error.message });
  }
});

module.exports = router;