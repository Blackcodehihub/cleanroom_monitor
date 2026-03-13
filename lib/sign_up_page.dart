import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color darkGreen = Color(0xFF237A35);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 390;

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 18 : 22,
            4,
            isSmallScreen ? 18 : 22,
            22,
          ),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: isSmallScreen ? 130 : 150,
                  height: isSmallScreen ? 130 : 150,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start Monitoring with Confidence',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 26 : 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account to access the cleanroom monitoring prototype and live data views.',
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
                  color: Colors.white,
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
                    const _FieldLabel('Full Name'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        prefixIcon: const Icon(
                          Icons.person_outline,
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
                    const SizedBox(height: 16),
                    const _FieldLabel('Email'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
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
                    const SizedBox(height: 16),
                    const _FieldLabel('Password'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Create your password',
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
                    const SizedBox(height: 16),
                    const _FieldLabel('Confirm Password'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: primaryGreen,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
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
                    const SizedBox(height: 22),
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
                          onPressed: _createAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
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
              const SizedBox(height: 18),
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
                  'User registration UI only • backend will be added later',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ],
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