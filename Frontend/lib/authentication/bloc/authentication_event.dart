part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LogIn extends AuthenticationEvent {
  final String username;
  final String password;

  LogIn({required this.username, required this.password});
}

class Register extends AuthenticationEvent {
  final String username;
  final String email;
  final String password;
  final String name;

  Register({
    required this.username,
    required this.email,
    required this.password,
    required this.name,
  });
}

class LoggedOut extends AuthenticationEvent {}

class AuthenticationStatusChecked extends AuthenticationEvent {}

class AccessTokenUpdated extends AuthenticationEvent {
  final String accessToken;

  AccessTokenUpdated(this.accessToken);
}
