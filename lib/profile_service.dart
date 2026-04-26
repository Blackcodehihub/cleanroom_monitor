import 'dart:io';
import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  ProfileService._internal();

  static final ProfileService instance = ProfileService._internal();

  String fullName = 'Prototype User';
  String email = 'prototype.user@email.com';
  String contactNumber = '09123456789';
  File? profileImage;

  void updateProfile({
    required String newFullName,
    required String newEmail,
    required String newContactNumber,
    File? newProfileImage,
  }) {
    fullName = newFullName;
    email = newEmail;
    contactNumber = newContactNumber;

    if (newProfileImage != null) {
      profileImage = newProfileImage;
    }

    notifyListeners();
  }
}