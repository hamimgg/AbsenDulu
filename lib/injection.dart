import 'package:dio/dio.dart';
import 'package:udah_absen/repositories/auth_repository_concrete.dart';
import 'package:udah_absen/repositories/auth_repository_impl.dart';
import 'package:udah_absen/services/api_service.dart';

class Injection {
  static final AuthRepository authRepository = AuthRepositoryImplConcrete(
    ApiService(
      Dio(
        BaseOptions(
          baseUrl: 'https://appabsensi.mobileprojp.com',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ),
    ),
  );
}
