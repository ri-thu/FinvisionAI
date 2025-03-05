import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthService _authService;
  String? _accessToken;

  // Method to get current access token
  String? get accessToken => _accessToken;

  // Method to update access token without emitting a new state
  void updateAccessToken(String token) {
    _accessToken = token;
  }

  AuthenticationBloc(this._authService) : super(Unauthenticated()) {
    on<LogIn>((event, emit) async {
      emit(AuthenticationLoadInProgress(accessToken: _accessToken));
      try {
        final auth = await _authService.login(
          username: event.username,
          password: event.password,
        );

        if (auth.isAuthenticated) {
          _accessToken = auth.accessToken;
          emit(Authenticated(auth));
        } else {
          _accessToken = null;
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthenticationFailure(e.toString(), accessToken: _accessToken));
      }
    });

    on<Register>((event, emit) async {
      emit(AuthenticationLoadInProgress(accessToken: _accessToken));
      try {
        final auth = await _authService.register(
          username: event.username,
          email: event.email,
          password1: event.password,
          password2: event.password,
          name: event.name,
        );

        if (auth.isAuthenticated) {
          _accessToken = auth.accessToken;
          emit(Authenticated(auth));
        } else {
          _accessToken = null;
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthenticationFailure(e.toString(), accessToken: _accessToken));
      }
    });

    on<LoggedOut>((event, emit) async {
      emit(AuthenticationLoadInProgress(accessToken: _accessToken));
      try {
        await _authService.logout(_accessToken);
        _accessToken = null;
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthenticationFailure(e.toString(), accessToken: _accessToken));
      }
    });

    on<AuthenticationStatusChecked>((event, emit) async {
      emit(AuthenticationLoadInProgress(accessToken: _accessToken));
      try {
        final auth = await _authService.checkAuthStatus(_accessToken);

        if (auth.isAuthenticated) {
          _accessToken = auth.accessToken;
          emit(Authenticated(auth));
        } else {
          _accessToken = null;
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthenticationFailure(e.toString(), accessToken: _accessToken));
      }
    });

    // Add event to update access token
    on<AccessTokenUpdated>((event, emit) {
      _accessToken = event.accessToken;
      // Don't emit a new state, just update the internal token
    });
  }
}
