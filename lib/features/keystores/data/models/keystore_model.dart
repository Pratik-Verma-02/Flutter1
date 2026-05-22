import 'package:hive/hive.dart';

part 'keystore_model.g.dart';

@HiveType(typeId: 0)
class KeystoreModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fileName;

  @HiveField(2)
  final String filePath;

  @HiveField(3)
  final String alias;

  @HiveField(4)
  final String sha1Fingerprint;

  @HiveField(5)
  final String sha256Fingerprint;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final int fileSize;

  @HiveField(8)
  final String keySize;

  @HiveField(9)
  final String signatureAlgorithm;

  @HiveField(10)
  final int validityYears;

  @HiveField(11)
  final String? commonName;

  @HiveField(12)
  final String? organization;

  @HiveField(13)
  final String? organizationalUnit;

  @HiveField(14)
  final String? city;

  @HiveField(15)
  final String? state;

  @HiveField(16)
  final String? countryCode;

  KeystoreModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.alias,
    required this.sha1Fingerprint,
    required this.sha256Fingerprint,
    required this.createdAt,
    required this.fileSize,
    required this.keySize,
    required this.signatureAlgorithm,
    required this.validityYears,
    this.commonName,
    this.organization,
    this.organizationalUnit,
    this.city,
    this.state,
    this.countryCode,
  });

  KeystoreModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    String? alias,
    String? sha1Fingerprint,
    String? sha256Fingerprint,
    DateTime? createdAt,
    int? fileSize,
    String? keySize,
    String? signatureAlgorithm,
    int? validityYears,
    String? commonName,
    String? organization,
    String? organizationalUnit,
    String? city,
    String? state,
    String? countryCode,
  }) {
    return KeystoreModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      alias: alias ?? this.alias,
      sha1Fingerprint: sha1Fingerprint ?? this.sha1Fingerprint,
      sha256Fingerprint: sha256Fingerprint ?? this.sha256Fingerprint,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      keySize: keySize ?? this.keySize,
      signatureAlgorithm: signatureAlgorithm ?? this.signatureAlgorithm,
      validityYears: validityYears ?? this.validityYears,
      commonName: commonName ?? this.commonName,
      organization: organization ?? this.organization,
      organizationalUnit: organizationalUnit ?? this.organizationalUnit,
      city: city ?? this.city,
      state: state ?? this.state,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
