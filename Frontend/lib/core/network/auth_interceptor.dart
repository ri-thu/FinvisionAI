import 'package:dio/dio.dart';
import '../../authentication/bloc/authentication_bloc.dart';
import '../../authentication/services/token_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  final AuthenticationBloc _authBloc;

  AuthInterceptor(this._tokenService, this._dio, this._authBloc);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get the access token from AuthBloc instead of secure storage
    final token = _authBloc.accessToken;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Check if the request is already trying to refresh the token
      if (err.requestOptions.path == '/auth/token/refresh/') {
        // If refresh token request fails, clear tokens and pass the error
        await _tokenService.clearTokens();
        return super.onError(err, handler);
      }

      try {
        // Get the refresh token from secure storage
        final refreshToken = await _tokenService.getRefreshToken();

        if (refreshToken == null) {
          return super.onError(err, handler);
        }

        // Call refresh endpoint to get new access token
        final response = await _dio.post(
          '/auth/token/refresh/',
          data: {'refresh': refreshToken},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        // Get the new access token
        final newAccessToken = response.data['access'];

        // Update the access token in the AuthBloc
        _authBloc.updateAccessToken(newAccessToken);

        // Retry the original request with the new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        // Create a new request with the updated token
        final retryResponse = await _dio.request(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: Options(method: options.method, headers: options.headers),
        );

        // Return the successful response to the handler
        return handler.resolve(retryResponse);
      } catch (refreshError) {
        // If token refresh fails, clear tokens and logout
        await _tokenService.clearTokens();
        return super.onError(err, handler);
      }
    }

    // For other errors, just pass them through
    return super.onError(err, handler);
  }
}
