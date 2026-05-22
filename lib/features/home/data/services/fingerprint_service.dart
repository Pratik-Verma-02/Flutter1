import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FingerprintResult {
  final String sha1;
  final String sha256;
  final String alias;
  final List<String> certificateChain;

  FingerprintResult({
    required this.sha1,
    required this.sha256,
    required this.alias,
    required this.certificateChain,
  });
}

class FingerprintService {
  Future<FingerprintResult> extractFromFile({
    required String filePath,
    required String password,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Keystore file not found');
    }

    final bytes = await file.readAsBytes();

    return _extractFromBytes(bytes, password);
  }

  FingerprintResult _extractFromBytes(Uint8List bytes, String password) {
    if (bytes.length < 4) {
      throw Exception('Invalid keystore file');
    }

    // Check JKS magic number
    if (bytes[0] == 0xFE && bytes[1] == 0xED && bytes[2] == 0xFE && bytes[3] == 0xED) {
      return _parseJks(bytes, password);
    }

    // Check JCEKS magic number
    if (bytes[0] == 0xCE && bytes[1] == 0xCE && bytes[2] == 0xCE && bytes[3] == 0xCE) {
      return _parseJceks(bytes, password);
    }

    throw Exception('Unsupported keystore format');
  }

  FingerprintResult _parseJks(Uint8List bytes, String password) {
    var offset = 4; // Skip magic number

    // Read version
    final version = _readInt(bytes, offset);
    offset += 4;

    if (version != 1 && version != 2) {
      throw Exception('Unsupported JKS version: $version');
    }

    // Read number of entries
    final entryCount = _readInt(bytes, offset);
    offset += 4;

    if (entryCount <= 0) {
      throw Exception('No entries found in keystore');
    }

    // Read first entry
    final entryTag = _readInt(bytes, offset);
    offset += 4;

    // Read alias
    final aliasLength = _readInt(bytes, offset);
    offset += 4;
    final alias = utf8.decode(bytes.sublist(offset, offset + aliasLength));
    offset += aliasLength;

    // Skip timestamp
    offset += 4;

    if (entryTag == 1) {
      // Private key entry
      final keyLength = _readInt(bytes, offset);
      offset += 4;
      offset += keyLength; // Skip private key data

      // Certificate chain
      final certCount = _readInt(bytes, offset);
      offset += 4;

      String sha1 = '';
      String sha256 = '';
      final certs = <String>[];

      for (var i = 0; i < certCount && i < 1; i++) {
        // Read cert type
        final certTypeLength = _readInt(bytes, offset);
        offset += 4;
        final certType = utf8.decode(bytes.sublist(offset, offset + certTypeLength));
        offset += certTypeLength;

        // Read certificate data
        final certLength = _readInt(bytes, offset);
        offset += 4;
        final certData = bytes.sublist(offset, offset + certLength);
        offset += certLength;

        // Calculate fingerprints
        sha1 = _calculateSHA1(certData);
        sha256 = _calculateSHA256(certData);
        certs.add(certType);
      }

      return FingerprintResult(
        sha1: sha1,
        sha256: sha256,
        alias: alias,
        certificateChain: certs,
      );
    }

    throw Exception('Unsupported entry type');
  }

  FingerprintResult _parseJceks(Uint8List bytes, String password) {
    // JCEKS has same basic structure but with different magic
    return _parseJks(bytes, password);
  }

  int _readInt(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
           (bytes[offset + 1] << 16) |
           (bytes[offset + 2] << 8) |
           bytes[offset + 3];
  }

  String _calculateSHA1(Uint8List data) {
    final digest = sha1.convert(data);
    return _formatFingerprint(digest.bytes);
  }

  String _calculateSHA256(Uint8List data) {
    final digest = sha256.convert(data);
    return _formatFingerprint(digest.bytes);
  }

  String _formatFingerprint(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
  }
}
