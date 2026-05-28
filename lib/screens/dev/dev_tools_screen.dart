import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/database.dart';
import '../../data/models/account.dart';
import '../../data/models/debt.dart';
import '../../data/models/investment_platform.dart';
import '../../data/models/outgoing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/mudra_button.dart';

class DevToolsScreen extends ConsumerStatefulWidget {
  const DevToolsScreen({super.key});

  @override
  ConsumerState<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends ConsumerState<DevToolsScreen> {
  _DbInfo? _info;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final dbName = userDatabaseName('developer');
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/$dbName.isar');
    final exists = await file.exists();

    int accounts = 0;
    int outgoings = 0;
    int investments = 0;
    int debts = 0;

    final isar = ref.read(activeDatabaseProvider);
    if (isar != null && exists) {
      accounts = await isar.accounts.count();
      outgoings = await isar.outgoings.count();
      investments = await isar.investmentPlatforms.count();
      debts = await isar.debts.count();
    }

    if (mounted) {
      setState(() {
        _info = _DbInfo(
          dbName: dbName,
          exists: exists,
          accounts: accounts,
          outgoings: outgoings,
          investments: investments,
          debts: debts,
        );
      });
    }
  }

  Future<void> _openDevDb() async {
    setState(() => _busy = true);
    await ref.read(appSessionControllerProvider).signInAsDebug(
          userId: 'developer',
          email: 'developer@local',
          fullName: 'Developer',
        );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _clearData() async {
    final confirmed = await _confirm(
      context,
      title: 'Clear all data?',
      message: 'This wipes every record in the dev database. The file stays on disk.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    final isar = ref.read(activeDatabaseProvider);
    if (isar != null) {
      await clearAllData(isar);
    }
    await _loadInfo();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _deleteDb() async {
    final confirmed = await _confirm(
      context,
      title: 'Delete database?',
      message: 'This permanently removes the dev database file from this device and signs you out.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    final dbName = userDatabaseName('developer');
    await resetDatabaseFiles(name: dbName);
    if (mounted) {
      setState(() => _busy = false);
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final info = _info;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'DEV TOOLS',
          style: AppTypography.sectionLabel.copyWith(
            color: AppColors.gold,
            fontSize: 13,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoCard(info: info, busy: _busy),
              const SizedBox(height: AppSpacing.xl),
              Text('ACTIONS', style: AppTypography.sectionLabel),
              const SizedBox(height: AppSpacing.md),
              MudraButton(
                label: _busy ? 'Opening...' : 'Open dev database',
                onPressed: _busy ? null : _openDevDb,
              ),
              const SizedBox(height: AppSpacing.sm),
              MudraButton(
                label: 'Clear all data',
                variant: MudraButtonVariant.secondary,
                onPressed: (_busy || info == null || !info.exists)
                    ? null
                    : _clearData,
              ),
              const SizedBox(height: AppSpacing.sm),
              MudraButton(
                label: 'Delete database + reset',
                variant: MudraButtonVariant.secondary,
                onPressed: (_busy || info == null || !info.exists)
                    ? null
                    : _deleteDb,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'This screen is only visible in debug builds.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DbInfo {
  const _DbInfo({
    required this.dbName,
    required this.exists,
    required this.accounts,
    required this.outgoings,
    required this.investments,
    required this.debts,
  });

  final String dbName;
  final bool exists;
  final int accounts;
  final int outgoings;
  final int investments;
  final int debts;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.info, required this.busy});

  final _DbInfo? info;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: info == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DATABASE', style: AppTypography.sectionLabel),
                const SizedBox(height: AppSpacing.sm),
                _Row(label: 'Name', value: info!.dbName),
                _Row(
                  label: 'Status',
                  value: info!.exists ? 'EXISTS ON DISK' : 'NOT CREATED YET',
                  valueColor: info!.exists ? AppColors.green : AppColors.inkDim,
                ),
                if (info!.exists) ...[
                  const Divider(height: AppSpacing.lg),
                  Text('RECORDS', style: AppTypography.sectionLabel),
                  const SizedBox(height: AppSpacing.sm),
                  _Row(label: 'Accounts', value: '${info!.accounts}'),
                  _Row(label: 'Outgoings', value: '${info!.outgoings}'),
                  _Row(label: 'Investments', value: '${info!.investments}'),
                  _Row(label: 'Debts', value: '${info!.debts}'),
                ],
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              color: valueColor ?? AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: AppTypography.headingSmall),
      content: Text(message, style: AppTypography.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(
            'Confirm',
            style: TextStyle(color: AppColors.red),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
