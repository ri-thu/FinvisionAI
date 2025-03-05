import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  // Add private constructor for potential future custom getters/methods
  const UserModel._();

  const factory UserModel({
    required String email,
    required String username,
    required String name,
    @Default(false) bool isAdmin,
    @Default(false) bool isAnonymous,
  }) = _UserModel;

  factory UserModel.anonymous() =>
      const UserModel(email: '', username: '', name: '', isAnonymous: true);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
