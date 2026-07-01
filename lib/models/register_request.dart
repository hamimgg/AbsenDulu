import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'jenis_kelamin')
  final String jenisKelamin;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  @JsonKey(name: 'batch_id')
  final int batchId;
  @JsonKey(name: 'training_id')
  final int trainingId;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    this.profilePhoto,
    required this.batchId,
    required this.trainingId,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
