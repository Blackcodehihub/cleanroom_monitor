import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool obscure = true;

  static const primary = Color(0xFF2F9E44);
  static const bg = Color(0xFFF4F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
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

              /// 🔥 BIG LOGO (NO CIRCLE)
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
                    _input(name, "Full Name", Icons.person),
                    const SizedBox(height: 12),
                    _input(email, "Email", Icons.email),
                    const SizedBox(height: 12),
                    _input(phone, "Phone", Icons.phone),
                    const SizedBox(height: 12),
                    _password(password, "Password"),
                    const SizedBox(height: 12),
                    _password(confirm, "Confirm Password"),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
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
    );
  }

  Widget _input(controller, hint, icon) {
    return TextField(
      controller: controller,
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

  Widget _password(controller, hint) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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