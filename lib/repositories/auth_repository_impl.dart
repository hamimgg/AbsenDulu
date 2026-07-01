import 'dart:io';

import 'package:udah_absen/models/training_model.dart';
import 'package:udah_absen/models/user_model.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
    String? profilePhoto,
  });
  Future<UserModel> getProfile();
  Future<void> updateProfile({
    required String name,
    required String email,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  });
  Future<void> updateProfilePhoto(File photo);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Future<List<TrainingModel>> getTrainings();
}
