import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  @JsonKey(name: 'jenis_kelamin')
  final String? jenisKelamin;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;
  @JsonKey(name: 'batch_id')
  final dynamic batchId;
  @JsonKey(name: 'training_id')
  final dynamic trainingId;
  @JsonKey(name: 'training_title')
  final String? trainingTitle;
  @JsonKey(name: 'batch_ke')
  final String? batchKe;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.jenisKelamin,
    this.profilePhoto,
    this.profilePhotoUrl,
    this.batchId,
    this.trainingId,
    this.trainingTitle,
    this.batchKe,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
