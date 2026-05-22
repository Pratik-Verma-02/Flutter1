import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../keystores/data/models/keystore_model.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final String keystoreId;

  const DetailsScreen({super.key, required this.keystoreId});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  KeystoreModel? _keystore;

  @override
  void initState() {
    super.initState();
    _loadKeystore();
  }

  void _loadKeystore() {
    setState(() {
      _keystore = ServiceLocator.keystoreRepository.getById(widget.keystoreId);
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  void _shareKeystore() {
    if (_keystore != null) {
      Share.shareXFiles(
        [XFile(_keystore!.filePath)],
        subject: 'Keystore: ${_keystore!.fileName}',
      );
    }
  }

  Future<void> _deleteKeystore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Keystore'),
        content: const Text('Are you sure you want to delete this keystore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && _keystore != null) {
      await ServiceLocator.fileService.deleteFile(_keystore!.filePath);
      await ServiceLocator.keystoreRepository.delete(_keystore!.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keystore deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_keystore == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Keystore not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keystore Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareKeystore,
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppTheme.error),
            onPressed: _deleteKeystore,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Fingerprints card
            _buildFingerprintsCard(),
            const SizedBox(height: 16),

            // Certificate details card
            _buildCertificateDetailsCard(),
            const SizedBox(height: 16),

            // File info card
            _buildFileInfoCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      hasGlow: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _keystore!.fileName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Alias: ${_keystore!.alias}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM dd, yyyy • HH:mm').format(_keystore!.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFingerprintsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Fingerprints', Icons.fingerprint_rounded),
          const SizedBox(height: 16),
          _buildFingerprintItem(
            'SHA-1',
            _keystore!.sha1Fingerprint,
            () => _copyToClipboard(_keystore!.sha1Fingerprint, 'SHA-1'),
          ),
          const Divider(height: 24),
          _buildFingerprintItem(
            'SHA-256',
            _keystore!.sha256Fingerprint,
            () => _copyToClipboard(_keystore!.sha256Fingerprint, 'SHA-256'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFingerprintItem(String label, String value, VoidCallback onCopy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.copy_rounded, size: 18, color: AppTheme.primaryBlue),
              onPressed: onCopy,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgCardLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: AppTheme.accentCyan,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateDetailsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Certificate Details', Icons.description_rounded),
          const SizedBox(height: 16),
          _buildDetailRow('Key Size', _keystore!.keySize),
          _buildDetailRow('Algorithm', _keystore!.signatureAlgorithm),
          _buildDetailRow('Validity', '${_keystore!.validityYears} years'),
          if (_keystore!.commonName != null)
            _buildDetailRow('Common Name', _keystore!.commonName!),
          if (_keystore!.organization != null)
            _buildDetailRow('Organization', _keystore!.organization!),
          if (_keystore!.organizationalUnit != null)
            _buildDetailRow('Org Unit', _keystore!.organizationalUnit!),
          if (_keystore!.city != null)
            _buildDetailRow('City', _keystore!.city!),
          if (_keystore!.state != null)
            _buildDetailRow('State', _keystore!.state!),
          if (_keystore!.countryCode != null)
            _buildDetailRow('Country', _keystore!.countryCode!),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFileInfoCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('File Information', Icons.info_outline_rounded),
          const SizedBox(height: 16),
          _buildDetailRow('File Name', _keystore!.fileName),
          _buildDetailRow('File Size', _formatFileSize(_keystore!.fileSize)),
          _buildDetailRow('File Path', _keystore!.filePath, isPath: true),
          _buildDetailRow(
            'Created',
            DateFormat('MMM dd, yyyy HH:mm:ss').format(_keystore!.createdAt),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPath = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontFamily: isPath ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
