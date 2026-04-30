import 'package:flutter/material.dart';
import 'forgot_password_page.dart';
import 'home_page.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool obscure = true;

  static const primary = Color(0xFF2F9E44);
  static const bg = Color(0xFFF4F6F8);

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              /// 🔥 BIG LOGO (NO CIRCLE)
              Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Sign in to continue",
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 18),

              /// FORM CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _input(email, "Email", Icons.email),
                    const SizedBox(height: 12),
                    _password(),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Sign In",
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

              const SizedBox(height: 14),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
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

  Widget _password() {
    return TextField(
      controller: password,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: "Password",
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