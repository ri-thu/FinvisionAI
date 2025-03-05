import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../core/network/dio_service.dart';
import '../bloc/authentication_bloc.dart';
import 'auth_service.dart';
import 'token_service.dart';

class AuthDependencies extends StatelessWidget {
  final Widget child;

  const AuthDependencies({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dioService = DioService();
    final tokenService = dioService.tokenService;
    final authService = AuthService(dioService.dioInstance, tokenService);

    // Create the AuthBloc
    final authBloc = AuthenticationBloc(authService)
      ..add(AuthenticationStatusChecked());

    // Set the authBloc in DioService
    dioService.setAuthBloc(authBloc);

    return MultiProvider(
      providers: [
        Provider<TokenService>.value(value: tokenService),
        Provider<AuthService>.value(value: authService),
        BlocProvider<AuthenticationBloc>.value(value: authBloc),
      ],
      child: child,
    );
  }
}
