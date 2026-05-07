import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool obscure = true;

  static const primary = Color(0xFF2F9E44);
  static const bg = Color(0xFFF4F6F8);

  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      // Logic para sa pag-create og account (e.g., Firebase/API)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account creation successful!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      _input(
                        controller: name, 
                        hint: "Full Name", 
                        icon: Icons.person,
                        validator: (v) => v == null || v.isEmpty ? "Please enter your name" : null,
                      ),
                      const SizedBox(height: 12),
                      _input(
                        controller: email, 
                        hint: "Email", 
                        icon: Icons.email,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Please enter your email";
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return "Enter a valid email address";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _input(
                        controller: phone, 
                        hint: "Phone", 
                        icon: Icons.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Please enter your phone number";
                          if (v.length < 10) return "Enter a valid phone number";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _password(
                        controller: password, 
                        hint: "Password",
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Please enter a password";
                          if (v.length < 6) return "Password must be at least 6 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _password(
                        controller: confirm, 
                        hint: "Confirm Password",
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Please confirm your password";
                          if (v != password.text) return "Passwords do not match";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({required controller, required hint, required icon, required String? Function(String?) validator}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primary),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _password({required controller, required hint, required String? Function(String?) validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock, color: primary),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() => obscure = !obscure);
          },
        ),
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}