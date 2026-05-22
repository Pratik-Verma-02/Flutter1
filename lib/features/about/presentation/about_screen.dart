import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../shared/widgets/glass_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // App logo and name
              _buildAppHeader(context),
              const SizedBox(height: 32),

              // Features section
              _buildFeaturesSection(context),
              const SizedBox(height: 24),

              // Description section
              _buildDescriptionSection(context),
              const SizedBox(height: 24),

              // Developer section
              _buildDeveloperSection(context),
              const SizedBox(height: 24),

              // Version info
              _buildVersionInfo(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Column(
      children: [
        // Logo with glow
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 20),

        Text(
          'PrimeXKey',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppTheme.accentCyan, AppTheme.primaryBlue, AppTheme.primaryPurple],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 8),

        Text(
          'Keystore Generator & Manager',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Features', Icons.star_rounded),
          const SizedBox(height: 16),
          _buildFeatureItem('Generate JKS Keystores', 'Create production-ready keystores with RSA key pairs'),
          _buildFeatureItem('SHA Fingerprint Extraction', 'Extract SHA-1 and SHA-256 fingerprints instantly'),
          _buildFeatureItem('Import Existing Keystores', 'Scan and analyze your existing JKS files'),
          _buildFeatureItem('Fully Offline', 'All cryptographic operations happen on-device'),
          _buildFeatureItem('Secure Storage', 'Your keystores are stored securely locally'),
          _buildFeatureItem('Easy Sharing', 'Export and share keystores with ease'),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About', Icons.info_outline_rounded),
          const SizedBox(height: 12),
          Text(
            'PrimeXKey is a professional utility application designed for Android developers who need to generate and manage JKS keystores for their applications.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Whether you need to generate a new keystore for signing your Android app, extract SHA fingerprints for Firebase or Google Maps integration, or manage existing keystores, PrimeXKey has you covered.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return GlassCard(
      hasGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Developer', Icons.code_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
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
                      'PrimeXKey Team',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Building tools for developers',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.language_rounded, 'Website', () {}),
              _buildSocialButton(Icons.code_rounded, 'GitHub', () {}),
              _buildSocialButton(Icons.email_rounded, 'Contact', () {}),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Version 1.0.0',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Made with Flutter',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 14, color: AppTheme.error),
            const SizedBox(width: 4),
            Text(
              'for developers',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 700.ms, duration: 400.ms);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
