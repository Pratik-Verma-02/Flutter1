class AppConstants {
  AppConstants._();

  static const String appName = 'PrimeXKey';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Keystore Generator & Manager';

  // Hive box names
  static const String keystoreBoxName = 'keystores';

  // Default values
  static const String defaultAlias = 'my-key';
  static const int defaultRsaKeySize = 2048;
  static const String defaultSignatureAlgorithm = 'SHA256withRSA';
  static const int defaultValidityYears = 25;

  // File extensions
  static const List<String> keystoreExtensions = ['jks', 'keystore'];

  // RSA key sizes
  static const List<int> rsaKeySizes = [2048, 4096];

  // Signature algorithms
  static const List<String> signatureAlgorithms = [
    'SHA256withRSA',
    'SHA512withRSA',
  ];
}
