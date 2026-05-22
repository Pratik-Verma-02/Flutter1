import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  String? _selectedFilePath;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final filePath = await ServiceLocator.keystoreScannerService.pickKeystoreFile();
      if (filePath != null) {
        setState(() {
          _selectedFilePath = filePath;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick file: ${e.toString()}');
    }
  }

  Future<void> _scanKeystore() async {
    if (_selectedFilePath == null) {
      setState(() => _error = 'Please select a keystore file first');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Please enter the keystore password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final id = const Uuid().v4();
      final result = await ServiceLocator.keystoreScannerService.scanKeystore(
        filePath: _selectedFilePath!,
        password: _passwordController.text,
        id: id,
      );

      await ServiceLocator.keystoreRepository.save(result.keystore);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keystore imported successfully')),
        );
        context.go('/keystores');
      }
    } catch (e) {
      setState(() => _error = _getErrorMessage(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('password')) {
      return 'Incorrect password. Please try again.';
    }
    if (error.contains('not found')) {
      return 'File not found. Please select a valid file.';
    }
    if (error.contains('Invalid') || error.contains('Unsupported')) {
      return 'Invalid or unsupported keystore file.';
    }
    return 'Failed to read keystore. Please check the file and password.';
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Import Keystore'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // File selection card
              _buildFileSelectionCard(),
              const SizedBox(height: 16),

              // Password card
              _buildPasswordCard(),
              const SizedBox(height: 16),

              // Error message
              if (_error != null) _buildErrorCard(),
              if (_error != null) const SizedBox(height: 16),

              // Scan button
              PremiumButton(
                onPressed: _scanKeystore,
                label: 'Scan & Import',
                icon: Icons.qr_code_scanner_rounded,
                gradient: AppTheme.primaryGradient,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Existing Keystore',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan JKS or keystore files to extract fingerprints',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildFileSelectionCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_rounded, size: 20, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Select File',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedFilePath != null
                      ? AppTheme.primaryBlue.withOpacity(0.5)
                      : AppTheme.textMuted.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFilePath != null
                        ? Icons.check_circle_rounded
                        : Icons.upload_file_rounded,
                    size: 48,
                    color: _selectedFilePath != null
                        ? AppTheme.success
                        : AppTheme.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedFilePath != null
                        ? _selectedFilePath!.split('/').last
                        : 'Tap to select .jks or .keystore file',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedFilePath != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: _selectedFilePath != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedFilePath != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickFile,
                      child: const Text('Change File'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPasswordCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, size: 20, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Keystore Password',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter keystore password',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _showPassword = !_showPassword);
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).shake();
  }
}
