import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class JksGenerationResult {
  final String filePath;
  final String alias;
  final String sha1Fingerprint;
  final String sha256Fingerprint;
  final String keySize;
  final String signatureAlgorithm;
  final int validityYears;
  final DateTime timestamp;

  JksGenerationResult({
    required this.filePath,
    required this.alias,
    required this.sha1Fingerprint,
    required this.sha256Fingerprint,
    required this.keySize,
    required this.signatureAlgorithm,
    required this.validityYears,
    required this.timestamp,
  });
}

class JksGeneratorService {
  Future<JksGenerationResult> generateJks({
    required String outputPath,
    required String alias,
    required String storePassword,
    required String aliasPassword,
    required String commonName,
    required String organization,
    required String organizationalUnit,
    required String city,
    required String state,
    required String countryCode,
    required int keySize,
    required String signatureAlgorithm,
    required int validityYears,
  }) async {
    // Generate RSA key pair
    final keyPair = _generateRSAKeyPair(keySize);

    // Generate self-signed certificate
    final certificate = _generateSelfSignedCertificate(
      keyPair: keyPair,
      commonName: commonName,
      organization: organization,
      organizationalUnit: organizationalUnit,
      city: city,
      state: state,
      countryCode: countryCode,
      validityYears: validityYears,
      signatureAlgorithm: signatureAlgorithm,
    );

    // Calculate fingerprints
    final sha1Fingerprint = _calculateSHA1Fingerprint(certificate);
    final sha256Fingerprint = _calculateSHA256Fingerprint(certificate);

    // Create and write JKS file
    await _writeJksFile(
      outputPath: outputPath,
      alias: alias,
      keyPair: keyPair,
      certificate: certificate,
      storePassword: storePassword,
      aliasPassword: aliasPassword,
    );

    return JksGenerationResult(
      filePath: outputPath,
      alias: alias,
      sha1Fingerprint: sha1Fingerprint,
      sha256Fingerprint: sha256Fingerprint,
      keySize: '$keySize bit',
      signatureAlgorithm: signatureAlgorithm,
      validityYears: validityYears,
      timestamp: DateTime.now(),
    );
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPair(int bitLength) {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.from(65537), bitLength, 64),
        secureRandom,
      ));

    // Type casting added here to fix Error 2
    return keyGen.generateKeyPair() as AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>;
  }

  Uint8List _generateSelfSignedCertificate({
    required AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair,
    required String commonName,
    required String organization,
    required String organizationalUnit,
    required String city,
    required String state,
    required String countryCode,
    required int validityYears,
    required String signatureAlgorithm,
  }) {
    final publicKey = keyPair.publicKey;
    final privateKey = keyPair.privateKey;

    // Create certificate using ASN1
    final serial = BigInt.from(DateTime.now().millisecondsSinceEpoch);
    final notBefore = DateTime.now();
    final notAfter = notBefore.add(Duration(days: validityYears * 365));

    // Build Distinguished Name string
    final dn = 'CN=$commonName, O=$organization, OU=$organizationalUnit, L=$city, ST=$state, C=$countryCode';

    // Create certificate data
    final certData = _buildCertificateAsn1(
      serial: serial,
      notBefore: notBefore,
      notAfter: notAfter,
      dn: dn,
      publicKey: publicKey,
      privateKey: privateKey,
      signatureAlgorithm: signatureAlgorithm,
    );

    return certData;
  }

  Uint8List _buildCertificateAsn1({
    required BigInt serial,
    required DateTime notBefore,
    required DateTime notAfter,
    required String dn,
    required RSAPublicKey publicKey,
    required RSAPrivateKey privateKey,
    required String signatureAlgorithm,
  }) {
    // Use basic_utils to build proper X509 certificate data
    // For the certificate content that will be hashed for fingerprints
    final buffer = BytesBuilder();

    // Version
    buffer.add([0x02, 0x01, 0x02]); // v3

    // Serial number
    final serialBytes = _bigIntToBytes(serial);
    buffer.add(_encodeAsn1Integer(serialBytes));

    // Signature algorithm identifier
    buffer.add(_encodeAlgorithmIdentifier(signatureAlgorithm));

    // Issuer (same as subject for self-signed)
    buffer.add(_encodeDistinguishedName(dn));

    // Validity
    buffer.add(_encodeValidity(notBefore, notAfter));

    // Subject
    buffer.add(_encodeDistinguishedName(dn));

    // Subject public key info
    buffer.add(_encodePublicKeyInfo(publicKey));

    return buffer.toBytes();
  }

  Uint8List _bigIntToBytes(BigInt value) {
    final hex = value.toRadixString(16);
    final paddedHex = hex.length.isOdd ? '0$hex' : hex;
    final bytes = <int>[];
    for (var i = 0; i < paddedHex.length; i += 2) {
      bytes.add(int.parse(paddedHex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  Uint8List _encodeAsn1Integer(Uint8List value) {
    final builder = BytesBuilder();
    builder.add([0x02]); // INTEGER tag
    builder.add(_encodeLength(value.length));
    builder.add(value);
    return builder.toBytes();
  }

  Uint8List _encodeLength(int length) {
    // Uint8List.fromList() added here to fix Error 3
    if (length < 0x80) {
      return Uint8List.fromList([length]);
    } else if (length < 0x100) {
      return Uint8List.fromList([0x81, length]);
    } else {
      return Uint8List.fromList([0x82, (length >> 8) & 0xFF, length & 0xFF]);
    }
  }

  Uint8List _encodeAlgorithmIdentifier(String algorithm) {
    final builder = BytesBuilder();
    builder.add([0x30]); // SEQUENCE tag

    final algOid = _getAlgorithmOid(algorithm);
    final algOidBytes = _encodeOid(algOid);
    final nullBytes = [0x05, 0x00]; // NULL

    final contentLength = algOidBytes.length + nullBytes.length;
    builder.add(_encodeLength(contentLength));
    builder.add(algOidBytes);
    builder.add(nullBytes);

    return builder.toBytes();
  }

  List<int> _getAlgorithmOid(String algorithm) {
    switch (algorithm) {
      case 'SHA256withRSA':
        return [1, 2, 840, 113549, 1, 1, 11];
      case 'SHA512withRSA':
        return [1, 2, 840, 113549, 1, 1, 13];
      default:
        return [1, 2, 840, 113549, 1, 1, 11]; // Default SHA256withRSA
    }
  }

  Uint8List _encodeOid(List<int> oid) {
    final builder = BytesBuilder();
    builder.add([0x06]); // OID tag

    final contentBuilder = BytesBuilder();
    contentBuilder.add([oid[0] * 40 + oid[1]]);

    for (var i = 2; i < oid.length; i++) {
      final bytes = _encodeOidComponent(oid[i]);
      contentBuilder.add(bytes);
    }

    final content = contentBuilder.toBytes();
    builder.add(_encodeLength(content.length));
    builder.add(content);

    return builder.toBytes();
  }

  List<int> _encodeOidComponent(int value) {
    if (value < 0x80) {
      return [value];
    }

    final bytes = <int>[];
    var v = value;
    bytes.add(v & 0x7F);
    v >>= 7;

    while (v > 0) {
      bytes.add((v & 0x7F) | 0x80);
      v >>= 7;
    }

    return bytes.reversed.toList();
  }

  Uint8List _encodeDistinguishedName(String dn) {
    final builder = BytesBuilder();
    builder.add([0x30]); // SEQUENCE tag

    final parts = _parseDN(dn);
    final contentBuilder = BytesBuilder();

    for (final part in parts) {
      contentBuilder.add(_encodeRDN(part.key, part.value));
    }

    final content = contentBuilder.toBytes();
    builder.add(_encodeLength(content.length));
    builder.add(content);

    return builder.toBytes();
  }

  List<MapEntry<String, String>> _parseDN(String dn) {
    final parts = <MapEntry<String, String>>[];
    final components = dn.split(', ');

    for (final component in components) {
      final index = component.indexOf('=');
      if (index > 0) {
        final key = component.substring(0, index).trim();
        final value = component.substring(index + 1).trim();
        parts.add(MapEntry(key, value));
      }
    }

    return parts;
  }

  Uint8List _encodeRDN(String type, String value) {
    final builder = BytesBuilder();
    builder.add([0x31]); // SET tag

    final typeOid = _getDNTypeOid(type);
    final typeOidBytes = _encodeOid(typeOid);
    final valueBytes = _encodePrintableString(value);

    final contentBuilder = BytesBuilder();
    contentBuilder.add([0x30]); // SEQUENCE tag
    final seqContent = BytesBuilder();
    seqContent.add(typeOidBytes);
    seqContent.add(valueBytes);
    final seqContentBytes = seqContent.toBytes();
    contentBuilder.add(_encodeLength(seqContentBytes.length));
    contentBuilder.add(seqContentBytes);

    final content = contentBuilder.toBytes();
    builder.add(_encodeLength(content.length));
    builder.add(content);

    return builder.toBytes();
  }

  List<int> _getDNTypeOid(String type) {
    switch (type.toUpperCase()) {
      case 'CN':
        return [2, 5, 4, 3];
      case 'O':
        return [2, 5, 4, 10];
      case 'OU':
        return [2, 5, 4, 11];
      case 'L':
        return [2, 5, 4, 7];
      case 'ST':
        return [2, 5, 4, 8];
      case 'C':
        return [2, 5, 4, 6];
      default:
        return [2, 5, 4, 3];
    }
  }

  Uint8List _encodePrintableString(String value) {
    final builder = BytesBuilder();
    builder.add([0x13]); // PrintableString tag
    final valueBytes = ascii.encode(value);
    builder.add(_encodeLength(valueBytes.length));
    builder.add(valueBytes);
    return builder.toBytes();
  }

  Uint8List _encodeValidity(DateTime notBefore, DateTime notAfter) {
    final builder = BytesBuilder();
    builder.add([0x30]); // SEQUENCE tag

    final beforeBytes = _encodeUTCTime(notBefore);
    final afterBytes = _encodeUTCTime(notAfter);

    final contentLength = beforeBytes.length + afterBytes.length;
    builder.add(_encodeLength(contentLength));
    builder.add(beforeBytes);
    builder.add(afterBytes);

    return builder.toBytes();
  }

  Uint8List _encodeUTCTime(DateTime time) {
    final builder = BytesBuilder();
    builder.add([0x17]); // UTCTime tag

    final year = time.year % 100;
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');

    final timeStr = '$year$month$day$hour$minute${second}Z';
    final timeBytes = ascii.encode(timeStr);

    builder.add(_encodeLength(timeBytes.length));
    builder.add(timeBytes);

    return builder.toBytes();
  }

  Uint8List _encodePublicKeyInfo(RSAPublicKey publicKey) {
    final builder = BytesBuilder();
    builder.add([0x30]); // SEQUENCE tag

    final algBytes = _encodeAlgorithmIdentifier('SHA256withRSA');
    final keyBytes = _encodeRSAPublicKey(publicKey);

    final contentLength = algBytes.length + keyBytes.length;
    builder.add(_encodeLength(contentLength));
    builder.add(algBytes);
    builder.add(keyBytes);

    return builder.toBytes();
  }

  Uint8List _encodeRSAPublicKey(RSAPublicKey publicKey) {
    final builder = BytesBuilder();
    builder.add([0x03]); // BIT STRING tag

    final modulusBytes = _bigIntToBytes(publicKey.modulus!);
    final exponentBytes = _bigIntToBytes(publicKey.exponent!);

    final contentBuilder = BytesBuilder();
    contentBuilder.add([0x00]); // unused bits
    contentBuilder.add([0x30]); // SEQUENCE tag
    final seqContent = BytesBuilder();
    seqContent.add(_encodeAsn1Integer(modulusBytes));
    seqContent.add(_encodeAsn1Integer(exponentBytes));
    final seqContentBytes = seqContent.toBytes();
    contentBuilder.add(_encodeLength(seqContentBytes.length));
    contentBuilder.add(seqContentBytes);

    final content = contentBuilder.toBytes();
    builder.add(_encodeLength(content.length));
    builder.add(content);

    return builder.toBytes();
  }

  String _calculateSHA1Fingerprint(Uint8List certificateData) {
    final digest = sha1.convert(certificateData);
    return _formatFingerprint(digest.bytes);
  }

  String _calculateSHA256Fingerprint(Uint8List certificateData) {
    final digest = sha256.convert(certificateData);
    return _formatFingerprint(digest.bytes);
  }

  String _formatFingerprint(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
  }

  Future<void> _writeJksFile({
    required String outputPath,
    required String alias,
    required AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair,
    required Uint8List certificate,
    required String storePassword,
    required String aliasPassword,
  }) async {
    final file = File(outputPath);
    final sink = file.openSync(mode: FileMode.write);

    try {
      // JKS Magic number
      sink.writeByteSync(0xFE);
      sink.writeByteSync(0xED);
      sink.writeByteSync(0xFE);
      sink.writeByteSync(0xED);

      // Version
      _writeInt(sink, 2);

      // Number of entries
      _writeInt(sink, 1);

      // Entry type (PrivateKeyEntry = 1)
      _writeInt(sink, 1);

      // Alias
      _writeUtf(sink, alias);

      // Timestamp
      _writeInt(sink, DateTime.now().millisecondsSinceEpoch ~/ 1000);

      // Private key encoded
      final privateKeyEncoded = _encodePrivateKey(keyPair.privateKey);
      _writeInt(sink, privateKeyEncoded.length);
      sink.writeFromSync(privateKeyEncoded);

      // Certificate chain length
      _writeInt(sink, 1);

      // Certificate type
      _writeUtf(sink, 'X.509');

      // Certificate data
      _writeInt(sink, certificate.length);
      sink.writeFromSync(certificate);

      // Store password digest
      final saltBytes = _generateSalt();
      final passwordDigest = _calculateJKSPasswordDigest(alias, storePassword, saltBytes);
      _writeInt(sink, passwordDigest.length);
      sink.writeFromSync(passwordDigest);

    } finally {
      await sink.close();
    }
  }

  Uint8List _encodePrivateKey(RSAPrivateKey privateKey) {
    final builder = BytesBuilder();
    builder.add([0x30]); // SEQUENCE tag

    final contentBuilder = BytesBuilder();
    contentBuilder.add(_encodeAsn1Integer(Uint8List.fromList([0x00]))); // version
    contentBuilder.add(_encodeAsn1Integer(_bigIntToBytes(privateKey.modulus!)));
    contentBuilder.add(_encodeAsn1Integer(_bigIntToBytes(privateKey.exponent!)));
    contentBuilder.add(_encodeAsn1Integer(_bigIntToBytes(privateKey.privateExponent!)));
    contentBuilder.add(_encodeAsn1Integer(_bigIntToBytes(privateKey.p!)));
    contentBuilder.add(_encodeAsn1Integer(_bigIntToBytes(privateKey.q!)));

    final content = contentBuilder.toBytes();
    builder.add(_encodeLength(content.length));
    builder.add(content);

    return builder.toBytes();
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(20, (_) => random.nextInt(256));
  }

  Uint8List _calculateJKSPasswordDigest(String alias, String password, List<int> salt) {
    final passwordBytes = ascii.encode(password);
    final combined = [...passwordBytes, ...salt];

    final digest = sha1.convert(combined);
    return Uint8List.fromList(digest.bytes);
  }

  void _writeInt(RandomAccessFile sink, int value) {
    sink.writeByteSync((value >> 24) & 0xFF);
    sink.writeByteSync((value >> 16) & 0xFF);
    sink.writeByteSync((value >> 8) & 0xFF);
    sink.writeByteSync(value & 0xFF);
  }

  void _writeUtf(RandomAccessFile sink, String value) {
    final bytes = utf8.encode(value);
    _writeInt(sink, bytes.length);
    for (final byte in bytes) {
      sink.writeByteSync(byte);
    }
  }
}
