import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_service.dart';
import 'mock_sensor_service.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color darkGreen = Color(0xFF237A35);
  static const Color softBg = Color(0xFFF4F5F7);

  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController contactController;

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    final profile = ProfileService.instance;

    fullNameController = TextEditingController(text: profile.fullName);
    emailController = TextEditingController(text: profile.email);
    contactController = TextEditingController(text: profile.contactNumber);
    selectedImage = profile.profileImage;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  void _saveChanges() {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final contact = contactController.text.trim();

    if (fullName.isEmpty || email.isEmpty || contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full name, email, and contact number are required'),
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (contact.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid contact number')),
      );
      return;
    }

    ProfileService.instance.updateProfile(
      newFullName: fullName,
      newEmail: email,
      newContactNumber: contact,
      newProfileImage: selectedImage,
    );

    MockSensorService.instance.updateNotificationNumber(contact);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile changes saved')),
    );

    Navigator.pop(context);
  }

  void _discardChanges() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Column(
          children: [
            _profilePhotoCard(),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Personal Information',
              subtitle:
                  'Update your profile details and alert receiver contact number',
              child: Column(
                children: [
                  _fieldLabel('Full Name'),
                  const SizedBox(height: 8),
                  _textField(
                    controller: fullNameController,
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Email'),
                  const SizedBox(height: 8),
                  _textField(
                    controller: emailController,
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _fieldLabel('Contact Number'),
                  const SizedBox(height: 8),
                  _textField(
                    controller: contactController,
                    hintText: 'Enter your contact number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: Colors.black38,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'This number will be used as the alert receiver number.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                      color: primaryGreen.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _discardChanges,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text(
                  'Back / Discard Changes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePhotoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFEAF6EC),
                backgroundImage:
                    selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? const Icon(
                        Icons.person_rounded,
                        color: primaryGreen,
                        size: 46,
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            fullNameController.text.trim().isEmpty
                ? 'Prototype User'
                : fullNameController.text.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emailController.text.trim().isEmpty
                ? 'prototype.user@email.com'
                : emailController.text.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text(
              'Upload Photo',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(color: primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        prefixIcon: Icon(prefixIcon, color: primaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: primaryGreen, width: 1.3),
        ),
      ),
    );
  }
}