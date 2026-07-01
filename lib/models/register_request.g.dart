// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      profilePhoto: json['profile_photo'] as String?,
      batchId: (json['batch_id'] as num).toInt(),
      trainingId: (json['training_id'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'jenis_kelamin': instance.jenisKelamin,
      'profile_photo': instance.profilePhoto,
      'batch_id': instance.batchId,
      'training_id': instance.trainingId,
    };
