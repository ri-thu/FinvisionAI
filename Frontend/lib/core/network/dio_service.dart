import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_constants.dart';
import 'auth_interceptor.dart';
import '../../authentication/services/token_service.dart';
import '../../authentication/bloc/authentication_bloc.dart';

class DioService {
  static final DioService _singleton = DioService._internal();

  factory DioService() => _singleton;

  late final Dio dio;
  final _secureStorage = const FlutterSecureStorage();
  late final TokenService _tokenService;
  AuthenticationBloc? _authBloc;

  DioService._internal() {
    dio = _createDio();
    _tokenService = TokenService(_secureStorage);
    // AuthInterceptor will be added after authBloc is set
  }

  // Set the auth bloc after it's created
  void setAuthBloc(AuthenticationBloc authBloc) {
    _authBloc = authBloc;
    _addInterceptors();
  }

  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: ApiConstants.headers,
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
  }

  void _addInterceptors() {
    dio.interceptors.clear(); // Clear any existing interceptors
    dio.interceptors.addAll([
      // Add auth interceptor with auth bloc
      if (_authBloc != null) AuthInterceptor(_tokenService, dio, _authBloc!),

      // Pretty logger for development debugging
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    ]);
  }

  // Get the dio instance
  Dio get dioInstance => dio;

  // Get the token service
  TokenService get tokenService => _tokenService;
}
