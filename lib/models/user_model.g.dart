// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  email: json['email'] as String?,
  jenisKelamin: json['jenis_kelamin'] as String?,
  profilePhoto: json['profile_photo'] as String?,
  profilePhotoUrl: json['profile_photo_url'] as String?,
  batchId: json['batch_id'],
  trainingId: json['training_id'],
  trainingTitle: json['training_title'] as String?,
  batchKe: json['batch_ke'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'jenis_kelamin': instance.jenisKelamin,
  'profile_photo': instance.profilePhoto,
  'profile_photo_url': instance.profilePhotoUrl,
  'batch_id': instance.batchId,
  'training_id': instance.trainingId,
  'training_title': instance.trainingTitle,
  'batch_ke': instance.batchKe,
};
