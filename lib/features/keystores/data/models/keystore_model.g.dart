// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keystore_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeystoreModelAdapter extends TypeAdapter<KeystoreModel> {
  @override
  final int typeId = 0;

  @override
  KeystoreModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeystoreModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      alias: fields[3] as String,
      sha1Fingerprint: fields[4] as String,
      sha256Fingerprint: fields[5] as String,
      createdAt: fields[6] as DateTime,
      fileSize: fields[7] as int,
      keySize: fields[8] as String,
      signatureAlgorithm: fields[9] as String,
      validityYears: fields[10] as int,
      commonName: fields[11] as String?,
      organization: fields[12] as String?,
      organizationalUnit: fields[13] as String?,
      city: fields[14] as String?,
      state: fields[15] as String?,
      countryCode: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KeystoreModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.alias)
      ..writeByte(4)
      ..write(obj.sha1Fingerprint)
      ..writeByte(5)
      ..write(obj.sha256Fingerprint)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.fileSize)
      ..writeByte(8)
      ..write(obj.keySize)
      ..writeByte(9)
      ..write(obj.signatureAlgorithm)
      ..writeByte(10)
      ..write(obj.validityYears)
      ..writeByte(11)
      ..write(obj.commonName)
      ..writeByte(12)
      ..write(obj.organization)
      ..writeByte(13)
      ..write(obj.organizationalUnit)
      ..writeByte(14)
      ..write(obj.city)
      ..writeByte(15)
      ..write(obj.state)
      ..writeByte(16)
      ..write(obj.countryCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeystoreModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
