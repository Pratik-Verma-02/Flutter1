import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../home/data/services/fingerprint_service.dart';
import '../../../keystores/data/models/keystore_model.dart';

class ScanResult {
  final KeystoreModel keystore;
  final FingerprintResult fingerprint;

  ScanResult({
    required this.keystore,
    required this.fingerprint,
  });
}

class KeystoreScannerService {
  final FingerprintService _fingerprintService = FingerprintService();

  Future<String?> pickKeystoreFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jks', 'keystore'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path;
    }

    return null;
  }

  Future<ScanResult> scanKeystore({
    required String filePath,
    required String password,
    required String id,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found');
    }

    final fileName = filePath.split('/').last;
    final fileSize = await file.length();

    final fingerprint = await _fingerprintService.extractFromFile(
      filePath: filePath,
      password: password,
    );

    final keystore = KeystoreModel(
      id: id,
      fileName: fileName,
      filePath: filePath,
      alias: fingerprint.alias,
      sha1Fingerprint: fingerprint.sha1,
      sha256Fingerprint: fingerprint.sha256,
      createdAt: DateTime.now(),
      fileSize: fileSize,
      keySize: 'Unknown',
      signatureAlgorithm: 'Unknown',
      validityYears: 0,
    );

    return ScanResult(
      keystore: keystore,
      fingerprint: fingerprint,
    );
  }
}
