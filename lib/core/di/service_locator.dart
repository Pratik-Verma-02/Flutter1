import 'package:hive_flutter/hive_flutter.dart';
import '../../features/keystores/data/models/keystore_model.dart';
import '../../features/keystores/data/repositories/keystore_repository.dart';
import '../../features/home/data/services/jks_generator_service.dart';
import '../../features/home/data/services/fingerprint_service.dart';
import '../../features/scanner/data/services/keystore_scanner_service.dart';
import '../services/file_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static late Box<KeystoreModel> _keystoreBox;
  static late KeystoreRepository _keystoreRepository;
  static late JksGeneratorService _jksGeneratorService;
  static late FingerprintService _fingerprintService;
  static late KeystoreScannerService _keystoreScannerService;
  static late FileService _fileService;

  static Box<KeystoreModel> get keystoreBox => _keystoreBox;
  static KeystoreRepository get keystoreRepository => _keystoreRepository;
  static JksGeneratorService get jksGeneratorService => _jksGeneratorService;
  static FingerprintService get fingerprintService => _fingerprintService;
  static KeystoreScannerService get keystoreScannerService => _keystoreScannerService;
  static FileService get fileService => _fileService;

  static Future<void> init() async {
    Hive.registerAdapter(KeystoreModelAdapter());

    _keystoreBox = await Hive.openBox<KeystoreModel>('keystores');

    _fileService = FileService();
    _fingerprintService = FingerprintService();
    _jksGeneratorService = JksGeneratorService();
    _keystoreScannerService = KeystoreScannerService();
    _keystoreRepository = KeystoreRepository(_keystoreBox);

    await _fileService.init();
  }
}
