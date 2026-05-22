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
import '../data/services/jks_generator_service.dart';
import '../../keystores/data/models/keystore_model.dart';
import 'widgets/fingerprint_result_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keyAliasController = TextEditingController(text: 'my-key');
  final _storePasswordController = TextEditingController();
  final _aliasPasswordController = TextEditingController();
  final _commonNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _organizationalUnitController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryCodeController = TextEditingController();

  bool _showStorePassword = false;
  bool _showAliasPassword = false;
  bool _isLoading = false;
  int _rsaKeySize = 2048;
  String _signatureAlgorithm = 'SHA256withRSA';
  int _validityYears = 25;

  @override
  void dispose() {
    _keyAliasController.dispose();
    _storePasswordController.dispose();
    _aliasPasswordController.dispose();
    _commonNameController.dispose();
    _organizationController.dispose();
    _organizationalUnitController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  Future<void> _generateJks() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final id = const Uuid().v4();
      final fileName = '${_keyAliasController.text}_$id.jks';
      final filePath = await ServiceLocator.fileService.getKeystorePath(fileName);

      final result = await ServiceLocator.jksGeneratorService.generateJks(
        outputPath: filePath,
        alias: _keyAliasController.text,
        storePassword: _storePasswordController.text,
        aliasPassword: _aliasPasswordController.text,
        commonName: _commonNameController.text.isEmpty ? 'Unknown' : _commonNameController.text,
        organization: _organizationController.text.isEmpty ? 'Unknown' : _organizationController.text,
        organizationalUnit: _organizationalUnitController.text.isEmpty ? 'Unknown' : _organizationalUnitController.text,
        city: _cityController.text.isEmpty ? 'Unknown' : _cityController.text,
        state: _stateController.text.isEmpty ? 'Unknown' : _stateController.text,
        countryCode: _countryCodeController.text.isEmpty ? 'US' : _countryCodeController.text,
        keySize: _rsaKeySize,
        signatureAlgorithm: _signatureAlgorithm,
        validityYears: _validityYears,
      );

      // Save to Hive
      final keystoreModel = KeystoreModel(
        id: id,
        fileName: fileName,
        filePath: filePath,
        alias: result.alias,
        sha1Fingerprint: result.sha1Fingerprint,
        sha256Fingerprint: result.sha256Fingerprint,
        createdAt: result.timestamp,
        fileSize: await ServiceLocator.fileService.getFileSize(filePath),
        keySize: result.keySize,
        signatureAlgorithm: result.signatureAlgorithm,
        validityYears: result.validityYears,
        commonName: _commonNameController.text.isEmpty ? null : _commonNameController.text,
        organization: _organizationController.text.isEmpty ? null : _organizationController.text,
        organizationalUnit: _organizationalUnitController.text.isEmpty ? null : _organizationalUnitController.text,
        city: _cityController.text.isEmpty ? null : _cityController.text,
        state: _stateController.text.isEmpty ? null : _stateController.text,
        countryCode: _countryCodeController.text.isEmpty ? null : _countryCodeController.text,
      );

      await ServiceLocator.keystoreRepository.save(keystoreModel);

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResultDialog(JksGenerationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FingerprintResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Key Configuration Card
                  _buildKeyConfigCard(),
                  const SizedBox(height: 16),

                  // Password Card
                  _buildPasswordCard(),
                  const SizedBox(height: 16),

                  // Certificate Details Card
                  _buildCertificateCard(),
                  const SizedBox(height: 16),

                  // Security Options Card
                  _buildSecurityOptionsCard(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
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
                Icons.vpn_key_rounded,
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
                    'Generate Keystore',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create JKS keystore with SHA fingerprints',
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

  Widget _buildKeyConfigCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Key Configuration', Icons.key_rounded),
          const SizedBox(height: 16),
          TextFormField(
            controller: _keyAliasController,
            decoration: const InputDecoration(
              labelText: 'Key Alias',
              hintText: 'e.g., my-key',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a key alias';
              }
              return null;
            },
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
          _buildSectionTitle('Security', Icons.lock_rounded),
          const SizedBox(height: 16),
          TextFormField(
            controller: _storePasswordController,
            obscureText: !_showStorePassword,
            decoration: InputDecoration(
              labelText: 'Store Password',
              hintText: 'Enter store password',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _showStorePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _showStorePassword = !_showStorePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter store password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _aliasPasswordController,
            obscureText: !_showAliasPassword,
            decoration: InputDecoration(
              labelText: 'Alias Password',
              hintText: 'Enter alias password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _showAliasPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _showAliasPassword = !_showAliasPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter alias password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCertificateCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Certificate Details', Icons.description_rounded),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commonNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name (CN)',
              hintText: 'e.g., John Doe',
              prefixIcon: Icon(Icons.person_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _organizationController,
            decoration: const InputDecoration(
              labelText: 'Organization (O)',
              hintText: 'e.g., My Company',
              prefixIcon: Icon(Icons.business_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _organizationalUnitController,
            decoration: const InputDecoration(
              labelText: 'Organizational Unit (OU)',
              hintText: 'e.g., Development',
              prefixIcon: Icon(Icons.group_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City (L)',
                    hintText: 'e.g., New York',
                    prefixIcon: Icon(Icons.location_city_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State (ST)',
                    hintText: 'e.g., NY',
                    prefixIcon: Icon(Icons.map_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _countryCodeController,
            decoration: const InputDecoration(
              labelText: 'Country Code (C)',
              hintText: 'e.g., US',
              prefixIcon: Icon(Icons.flag_rounded),
            ),
            maxLength: 2,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSecurityOptionsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Security Options', Icons.security_rounded),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _rsaKeySize,
            decoration: const InputDecoration(
              labelText: 'RSA Key Size',
              prefixIcon: Icon(Icons.speed_rounded),
            ),
            items: const [
              DropdownMenuItem(value: 2048, child: Text('2048 bit (Standard)')),
              DropdownMenuItem(value: 4096, child: Text('4096 bit (High Security)')),
            ],
            onChanged: (value) {
              setState(() => _rsaKeySize = value!);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _signatureAlgorithm,
            decoration: const InputDecoration(
              labelText: 'Signature Algorithm',
              prefixIcon: Icon(Icons.fingerprint_rounded),
            ),
            items: const [
              DropdownMenuItem(value: 'SHA256withRSA', child: Text('SHA256withRSA')),
              DropdownMenuItem(value: 'SHA512withRSA', child: Text('SHA512withRSA')),
            ],
            onChanged: (value) {
              setState(() => _signatureAlgorithm = value!);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Validity: $_validityYears years',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Slider(
            value: _validityYears.toDouble(),
            min: 1,
            max: 50,
            divisions: 49,
            label: '$_validityYears years',
            onChanged: (value) {
              setState(() => _validityYears = value.toInt());
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PremiumButton(
          onPressed: _generateJks,
          label: 'Create JKS File',
          icon: Icons.add_rounded,
          gradient: AppTheme.primaryGradient,
        ),
        const SizedBox(height: 12),
        PremiumButton(
          onPressed: () => context.push('/scanner'),
          label: 'Scan Existing JKS',
          icon: Icons.qr_code_scanner_rounded,
          isOutlined: true,
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
