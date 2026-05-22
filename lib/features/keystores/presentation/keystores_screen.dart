import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/config/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/glass_card.dart';
import '../data/models/keystore_model.dart';

class KeystoresScreen extends ConsumerStatefulWidget {
  const KeystoresScreen({super.key});

  @override
  ConsumerState<KeystoresScreen> createState() => _KeystoresScreenState();
}

class _KeystoresScreenState extends ConsumerState<KeystoresScreen> {
  List<KeystoreModel> _keystores = [];
  String _searchQuery = '';
  String _sortBy = 'date'; // date, name

  @override
  void initState() {
    super.initState();
    _loadKeystores();
  }

  void _loadKeystores() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _keystores = ServiceLocator.keystoreRepository.search(_searchQuery);
      } else if (_sortBy == 'name') {
        _keystores = ServiceLocator.keystoreRepository.sortByName();
      } else {
        _keystores = ServiceLocator.keystoreRepository.sortByDate();
      }
    });
  }

  Future<void> _deleteKeystore(KeystoreModel keystore) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Keystore'),
        content: Text('Are you sure you want to delete ${keystore.fileName}?'),
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

    if (confirmed == true) {
      await ServiceLocator.fileService.deleteFile(keystore.filePath);
      await ServiceLocator.keystoreRepository.delete(keystore.id);
      _loadKeystores();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keystore deleted')),
        );
      }
    }
  }

  Future<void> _renameKeystore(KeystoreModel keystore) async {
    final controller = TextEditingController(text: keystore.fileName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Keystore'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File Name',
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await ServiceLocator.fileService.renameFile(keystore.filePath, newName);
      final updated = keystore.copyWith(
        fileName: newName,
        filePath: '${keystore.filePath.substring(0, keystore.filePath.lastIndexOf('/') + 1)}$newName',
      );
      await ServiceLocator.keystoreRepository.update(updated);
      _loadKeystores();
    }
  }

  void _shareKeystore(KeystoreModel keystore) {
    Share.shareXFiles(
      [XFile(keystore.filePath)],
      subject: 'Keystore: ${keystore.fileName}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Search bar
            _buildSearchBar(),

            // Keystores list
            Expanded(
              child: _keystores.isEmpty
                  ? _buildEmptyState()
                  : _buildKeystoresList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keystores',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${_keystores.length} files',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded, color: AppTheme.textSecondary),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadKeystores();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: TextField(
        onChanged: (value) {
          _searchQuery = value;
          _loadKeystores();
        },
        decoration: InputDecoration(
          hintText: 'Search keystores...',
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
          filled: true,
          fillColor: AppTheme.bgCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.textMuted.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.textMuted.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryBlue),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Keystores Yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate or import a keystore to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Keystore'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildKeystoresList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _keystores.length,
      itemBuilder: (context, index) {
        final keystore = _keystores[index];
        return _buildKeystoreCard(keystore, index);
      },
    );
  }

  Widget _buildKeystoreCard(KeystoreModel keystore, int index) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/details/${keystore.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.vpn_key_rounded,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        keystore.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(keystore.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: AppTheme.textMuted),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        context.push('/details/${keystore.id}');
                        break;
                      case 'rename':
                        _renameKeystore(keystore);
                        break;
                      case 'share':
                        _shareKeystore(keystore);
                        break;
                      case 'delete':
                        _deleteKeystore(keystore);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('View Details')),
                    const PopupMenuItem(value: 'rename', child: Text('Rename')),
                    const PopupMenuItem(value: 'share', child: Text('Share')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: AppTheme.error)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Fingerprint preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgCardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.fingerprint_rounded, size: 16, color: AppTheme.accentCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SHA-1: ${_formatFingerprintShort(keystore.sha1Fingerprint)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.storage_rounded, _formatFileSize(keystore.fileSize)),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.key_rounded, keystore.keySize),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: Duration(milliseconds: 100 * index));
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFingerprintShort(String fingerprint) {
    if (fingerprint.length > 20) {
      return '${fingerprint.substring(0, 20)}...';
    }
    return fingerprint;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
