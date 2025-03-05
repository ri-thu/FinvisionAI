// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  email: json['email'] as String,
  username: json['username'] as String,
  name: json['name'] as String,
  isAdmin: json['isAdmin'] as bool? ?? false,
  isAnonymous: json['isAnonymous'] as bool? ?? false,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'name': instance.name,
      'isAdmin': instance.isAdmin,
      'isAnonymous': instance.isAnonymous,
    };
