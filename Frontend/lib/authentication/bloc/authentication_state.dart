part of 'authentication_bloc.dart';

abstract class AuthenticationState {
  // Add access token to the base state so it's available in all states
  final String? accessToken;

  AuthenticationState({this.accessToken});
}

class Unauthenticated extends AuthenticationState {
  Unauthenticated() : super(accessToken: null);
}

class Authenticated extends AuthenticationState {
  final AuthModel auth;

  Authenticated(this.auth) : super(accessToken: auth.accessToken);
}

class AuthenticationLoadInProgress extends AuthenticationState {
  AuthenticationLoadInProgress({super.accessToken});
}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure(this.message, {super.accessToken});
}
