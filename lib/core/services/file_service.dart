import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileService {
  late Directory _appDir;
  late Directory _keystoresDir;

  Directory get appDir => _appDir;
  Directory get keystoresDir => _keystoresDir;

  Future<void> init() async {
    _appDir = await getApplicationDocumentsDirectory();
    _keystoresDir = Directory(p.join(_appDir.path, 'keystores'));

    if (!await _keystoresDir.exists()) {
      await _keystoresDir.create(recursive: true);
    }
  }

  Future<String> getKeystorePath(String fileName) async {
    return p.join(_keystoresDir.path, fileName);
  }

  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> renameFile(String oldPath, String newName) async {
    final file = File(oldPath);
    if (await file.exists()) {
      final directory = file.parent;
      final newPath = p.join(directory.path, newName);
      await file.rename(newPath);
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
