class ApiConstants {
  ApiConstants._();

  // Base URL for API calls
  static const String baseUrl = 'http://localhost:8000/api/';

  // Common headers
  static const Map<String, dynamic> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout settings in milliseconds
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
