import 'package:flutter/material.dart';
import 'home_page.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color darkGreen = Color(0xFF237A35);
  static const Color softBg = Color(0xFFF4F5F7);
  static const Color cardBg = Colors.white;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;

    return Scaffold(
      backgroundColor: softBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 16 : 22,
            18,
            isSmallScreen ? 16 : 22,
            20,
          ),
          child: Column(
            children: [
              const SizedBox(height: 6),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: isSmallScreen ? 130 : 155,
                  height: isSmallScreen ? 130 : 155,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 28 : 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to monitor your cleanroom environment and track live sensor conditions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Email'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@email.com',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: primaryGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Password'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: primaryGreen,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black54,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Responsive fix for overflow
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 6,
                      spacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: 0.95,
                              child: Checkbox(
                                value: rememberMe,
                                activeColor: primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryGreen, darkGreen],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGreen.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialCircle(icon: Icons.apple, iconColor: Colors.black87),
                  SizedBox(width: 14),
                  _SocialTextCircle(label: 'f', textColor: primaryGreen),
                  SizedBox(width: 14),
                  _SocialTextCircle(label: 'G', textColor: primaryGreen),
                ],
              ),
              const SizedBox(height: 22),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Prototype Mode • Firebase integration later',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _SocialCircle({
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

class _SocialTextCircle extends StatelessWidget {
  final String label;
  final Color textColor;

  const _SocialTextCircle({
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}