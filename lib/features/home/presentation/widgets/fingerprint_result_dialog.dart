import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../data/services/jks_generator_service.dart';

class FingerprintResultDialog extends StatelessWidget {
  final JksGenerationResult result;

  const FingerprintResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 16),

              Text(
                'Keystore Generated',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Fingerprint cards
              _buildFingerprintCard(
                context,
                'SHA-1 Fingerprint',
                result.sha1Fingerprint,
                Icons.fingerprint_rounded,
              ),
              const SizedBox(height: 12),
              _buildFingerprintCard(
                context,
                'SHA-256 Fingerprint',
                result.sha256Fingerprint,
                Icons.fingerprint_rounded,
              ),

              const SizedBox(height: 16),

              // Details
              _buildDetailRow('Alias', result.alias),
              _buildDetailRow('Key Size', result.keySize),
              _buildDetailRow('Algorithm', result.signatureAlgorithm),
              _buildDetailRow('Validity', '${result.validityYears} years'),
              _buildDetailRow('File Path', result.filePath, isPath: true),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    'Copy SHA-1',
                    Icons.copy_rounded,
                    () {
                      Clipboard.setData(ClipboardData(text: result.sha1Fingerprint));
                      _showCopiedSnackbar(context, 'SHA-1 copied');
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Copy SHA-256',
                    Icons.copy_all_rounded,
                    () {
                      Clipboard.setData(ClipboardData(text: result.sha256Fingerprint));
                      _showCopiedSnackbar(context, 'SHA-256 copied');
                    },
                  ),
                  _buildActionButton(
                    context,
                    'Share',
                    Icons.share_rounded,
                    () {
                      Share.shareXFiles(
                        [XFile(result.filePath)],
                        subject: 'Keystore: ${result.alias}',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildFingerprintCard(
    BuildContext context,
    String title,
    String fingerprint,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textMuted.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            fingerprint,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: AppTheme.accentCyan,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildDetailRow(String label, String value, {bool isPath = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontFamily: isPath ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: AppTheme.primaryBlue),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showCopiedSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
