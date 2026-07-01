import 'dart:convert';
import 'dart:io';

import 'package:udah_absen/models/login_request.dart';
import 'package:udah_absen/models/register_request.dart';
import 'package:udah_absen/models/training_model.dart';
import 'package:udah_absen/models/user_model.dart';
import 'package:udah_absen/repositories/auth_repository_impl.dart';
import 'package:udah_absen/services/api_service.dart';
import 'package:udah_absen/services/token_service.dart';

class AuthRepositoryImplConcrete implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImplConcrete(this._apiService);

  @override
  Future<void> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiService.login(request);
    final token = response.data?.token;
    if (token != null) {
      await TokenStorage.saveToken(token);
    } else {
      throw Exception('Login gagal: token tidak ditemukan');
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
    String? profilePhoto,
  }) async {
    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
      jenisKelamin: jenisKelamin,
      batchId: batchId,
      trainingId: trainingId,
      profilePhoto: profilePhoto,
    );
    final response = await _apiService.register(request);
    final token = response.data?.token;
    if (token != null) {
      await TokenStorage.saveToken(token);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final token = await _getBearerToken();
    final response = await _apiService.getProfile(token);
    if (response.data != null) {
      return response.data!;
    }
    throw Exception('Gagal mengambil profil');
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    required String jenisKelamin,
    required int batchId,
    required int trainingId,
  }) async {
    final token = await _getBearerToken();
    await _apiService.updateProfile(
      token,
      name,
      email,
      jenisKelamin,
      batchId,
      trainingId,
    );
  }

  @override
  Future<void> updateProfilePhoto(File photo) async {
    final token = await _getBearerToken();
    final bytes = await photo.readAsBytes();
    final base64String = base64Encode(bytes);
    await _apiService.updateProfilePhoto(token, base64String);
  }

  @override
  Future<void> logout() async {
    await TokenStorage.clearToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return TokenStorage.getToken();
  }

  @override
  Future<List<TrainingModel>> getTrainings() async {
    final response = await _apiService.getTrainings();
    return response.data ?? [];
  }

  Future<String> _getBearerToken() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Silakan login.');
    return 'Bearer $token';
  }
}
