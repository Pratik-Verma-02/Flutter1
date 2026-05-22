class FileUtils {
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  static String getFileNameWithoutExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  static String truncateFileName(String fileName, int maxLength) {
    if (fileName.length <= maxLength) return fileName;

    final extension = getFileExtension(fileName);
    final nameWithoutExt = getFileNameWithoutExtension(fileName);
    final availableLength = maxLength - extension.length - 3; // 3 for "..."

    if (availableLength <= 0) return fileName;

    return '${nameWithoutExt.substring(0, availableLength)}...$extension';
  }
}
