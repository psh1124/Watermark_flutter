class EnvConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://solunet.shop';
  static const String loginEndpoint = '/4768b05aa6df12a2ddad4c3a58ad2da2/Login';
  static const String watermarkEndpoint = '/4768b05aa6df12a2ddad4c3a58ad2da2/User/EmbedWaterMark';
  static const String watermarkDetectionEndpoint = '/4768b05aa6df12a2ddad4c3a58ad2da2/User/DecodeWaterMark';
  
  // API Key for watermark service
  static const String apiKey = 'ak_1a12c4c7765c40aab4429b914150f75e'; // 실제 API 키로 교체 필요
  
  // Test Credentials (for development only)
  static const String testUsername = 'seonghun8368';
  static const String testPassword = 'qwer1234@!';
  
  // Full login URL
  static String get loginUrl => '$apiBaseUrl$loginEndpoint';
  
  // Full watermark URL
  static String get watermarkUrl => '$apiBaseUrl$watermarkEndpoint';
  
  // Full watermark detection URL
  static String get watermarkDetectionUrl => '$apiBaseUrl$watermarkDetectionEndpoint';
}
