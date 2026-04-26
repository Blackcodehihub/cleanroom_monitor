import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'device_info_page.dart';
import 'profile_details_page.dart';
import 'profile_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Color primaryGreen = Color(0xFF2F9E44);
  static const Color softBg = Color(0xFFF4F5F7);

  @override
  Widget build(BuildContext context) {
    final profile = ProfileService.instance;

    return AnimatedBuilder(
      animation: profile,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: softBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your account and app preferences',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),

                // PROFILE CARD
                Container(
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
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFFEAF6EC),
                        backgroundImage: profile.profileImage != null
                            ? FileImage(profile.profileImage!)
                            : null,
                        child: profile.profileImage == null
                            ? const Icon(
                                Icons.person_rounded,
                                color: primaryGreen,
                                size: 46,
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.contactNumber,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // EDIT PROFILE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileDetailsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // DEVICE INFORMATION (ONLY SETTINGS LEFT)
                _settingTile(
                  context: context,
                  icon: Icons.memory_rounded,
                  title: 'Device Information',
                  subtitle: 'View connected device and sensor details',
                  badge: '2',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeviceInformationPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // LOGOUT BUTTON
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignInPage(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
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
      },
    );
  }

  Widget _settingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: primaryGreen.withValues(alpha: 0.10),
              child: Icon(icon, color: primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}