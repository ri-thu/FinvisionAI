import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'user_model.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  // Add the private constructor to support custom getters
  const AuthModel._();

  // Changed to use @With instead of @Implements
  const factory AuthModel({String? accessToken, required UserModel user}) =
      _AuthModel;

  factory AuthModel.initial() =>
      AuthModel(accessToken: null, user: UserModel.anonymous());

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  bool get isAuthenticated => accessToken != null && user.isAnonymous == false;
}
