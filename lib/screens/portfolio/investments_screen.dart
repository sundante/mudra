import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/debt.dart';
import '../../data/models/investment_platform.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/investment_provider.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/platform_card.dart';

const _uuid = Uuid();

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardNotifierProvider);
    final platforms = (ref.watch(platformsStreamProvider).valueOrNull ?? [])
        .toList()
      ..sort((a, b) => a.safePlatformName
          .toLowerCase()
          .compareTo(b.safePlatformName.toLowerCase()));
    final debts = ref.watch(debtsStreamProvider).valueOrNull ?? [];
    final iOwe = debts
        .where((debt) => debt.safeDirection == DebtDirection.iOwe)
        .toList();
    final theyOwe = debts
        .where((debt) => debt.safeDirection == DebtDirection.theyOwe)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Investments',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _NetWorthHero(
              dashboard: dashboard,
              onTap: () => _openNetWorthSheet(context, dashboard),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.sm,
                  AppSpacing.screenH,
                  AppSpacing.xxl,
                ),
                children: [
                  _SectionActionHeader(
                    label: 'INVESTMENTS',
                    actionLabel: 'Add Platform',
                    onPressed: () => _openPlatformSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (platforms.isEmpty)
                    EmptyState(
                      icon: '\u{1F4C8}',
                      title: 'No investment platforms yet',
                      message:
                          'Add a platform to track invested value and gains.',
                      action: MudraButton(
                        label: 'Add platform',
                        icon: Icons.add,
                        expand: false,
                        onPressed: () => _openPlatformSheet(context),
                      ),
                    )
                  else
                    ...platforms.map((platform) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Dismissible(
                            key: ValueKey('platform-${platform.id}'),
                            direction: DismissDirection.endToStart,
                            background: const _SwipeBackground(
                              direction: DismissDirection.endToStart,
                              color: AppColors.redLight,
                              foreground: AppColors.red,
                              icon: Icons.delete_outline,
                              label: 'Delete',
                            ),
                            confirmDismiss: (_) async {
                              final confirmed = await _confirmPlatformDelete(
                                  context, platform);
                              if (confirmed) {
                                await _deletePlatform(platform.id);
                              }
                              return false;
                            },
                            child: PlatformCard(
                              platform: platform,
                              currency: dashboard.currency,
                              onTap: () => _openPlatformSheet(
                                context,
                                initial: platform,
                              ),
                            ),
                          ),
                        )),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionActionHeader(
                    label: 'DEBTS',
                    actionLabel: 'Add Debt',
                    onPressed: () => _openDebtSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DebtSection(
                    label: 'I OWE',
                    debts: iOwe,
                    currency: dashboard.currency,
                    emptyMessage: 'Nothing you owe is outstanding.',
                    onEdit: (debt) => _openDebtSheet(context, initial: debt),
                    onSettle: _settleDebt,
                    onDelete: (debt) => _confirmAndDeleteDebt(context, debt),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DebtSection(
                    label: 'OWED TO ME',
                    debts: theyOwe,
                    currency: dashboard.currency,
                    emptyMessage: 'Nobody currently owes you money.',
                    onEdit: (debt) => _openDebtSheet(context, initial: debt),
                    onSettle: _settleDebt,
                    onDelete: (debt) => _confirmAndDeleteDebt(context, debt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPlatformSheet(
    BuildContext context, {
    InvestmentPlatform? initial,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlatformEditorSheet(
        initial: initial,
        currency: ref.read(dashboardNotifierProvider).currency,
        onSave: _savePlatform,
        onDelete: initial == null ? null : () => _deletePlatform(initial.id),
      ),
    );
  }

  Future<void> _openDebtSheet(
    BuildContext context, {
    Debt? initial,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DebtEditorSheet(
        initial: initial,
        onSave: _saveDebt,
        onDelete: initial == null ? null : () => _deleteDebt(initial.id),
      ),
    );
  }

  Future<void> _openNetWorthSheet(
    BuildContext context,
    DashboardData dashboard,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NetWorthSheet(dashboard: dashboard),
    );
  }

  Future<void> _savePlatform(_PlatformDraft draft) async {
    final platform = InvestmentPlatform()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..platformName = draft.platformName
      ..assetType = draft.assetType
      ..investedAmount = draft.investedAmount
      ..currentValue = draft.currentValue
      ..valueUpdatedAt = DateTime.now()
      ..isDeleted = false
      ..createdAt = draft.createdAt;
    await ref.read(investmentRepoProvider).savePlatform(platform);
    await HapticFeedback.lightImpact();
  }

  Future<void> _deletePlatform(int id) async {
    await ref.read(investmentRepoProvider).deletePlatform(id);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _saveDebt(_DebtDraft draft) async {
    final debt = Debt()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..counterpartyName = draft.counterpartyName
      ..direction = draft.direction
      ..amount = draft.amount
      ..dueDate = draft.dueDate
      ..notes = draft.notes.isEmpty ? null : draft.notes
      ..isSettled = draft.isSettled
      ..createdAt = draft.createdAt;
    await ref.read(investmentRepoProvider).saveDebt(debt);
    await HapticFeedback.lightImpact();
  }

  Future<void> _settleDebt(Debt debt) async {
    await ref.read(investmentRepoProvider).settleDebt(debt.id);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _deleteDebt(int id) async {
    await ref.read(investmentRepoProvider).deleteDebt(id);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _confirmAndDeleteDebt(
    BuildContext context,
    Debt debt,
  ) async {
    if (await _confirmDebtDelete(context, debt)) {
      await _deleteDebt(debt.id);
    }
  }

  Future<bool> _confirmPlatformDelete(
    BuildContext context,
    InvestmentPlatform platform,
  ) async {
    return await _confirmDelete(
      context,
      title: 'Delete ${platform.safePlatformName}?',
      message: 'This removes the platform from investments and net worth.',
    );
  }

  Future<bool> _confirmDebtDelete(BuildContext context, Debt debt) async {
    return await _confirmDelete(
      context,
      title: 'Delete debt with ${debt.safeCounterpartyName}?',
      message: 'This permanently removes this debt record.',
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _NetWorthHero extends StatelessWidget {
  const _NetWorthHero({required this.dashboard, required this.onTap});

  final DashboardData dashboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.screenV,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          MudraCard(
            color: AppColors.surface,
            onTap: onTap,
            child: Column(
              children: [
                const SectionLabel('net worth'),
                const SizedBox(height: AppSpacing.xs),
                AmountDisplay(
                  amount: dashboard.netWorth,
                  currency: dashboard.currency,
                  style: AppTypography.monoHero,
                  coloured: true,
                  compact: true,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tap for breakdown',
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'TOTAL ASSETS',
                  amount: dashboard.totalAssets,
                  currency: dashboard.currency,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HeroStat(
                  label: 'TOTAL LIABILITIES',
                  amount: dashboard.totalLiabilities,
                  currency: dashboard.currency,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });

  final String label;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          AmountDisplay(
            amount: amount,
            currency: currency,
            style: AppTypography.monoSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            compact: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          SectionLabel(label),
        ],
      ),
    );
  }
}

class _SectionActionHeader extends StatelessWidget {
  const _SectionActionHeader({
    required this.label,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionLabel(label)),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 18),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _DebtSection extends StatelessWidget {
  const _DebtSection({
    required this.label,
    required this.debts,
    required this.currency,
    required this.emptyMessage,
    required this.onEdit,
    required this.onSettle,
    required this.onDelete,
  });

  final String label;
  final List<Debt> debts;
  final String currency;
  final String emptyMessage;
  final ValueChanged<Debt> onEdit;
  final Future<void> Function(Debt) onSettle;
  final Future<void> Function(Debt) onDelete;

  @override
  Widget build(BuildContext context) {
    final active = debts.where((debt) => !debt.safeIsSettled).toList()
      ..sort(_sortDebt);
    final settled = debts.where((debt) => debt.safeIsSettled).toList()
      ..sort(_sortDebt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.sm),
        if (active.isEmpty)
          MudraCard(
            color: AppColors.surfaceAlt,
            child: Text(
              emptyMessage,
              style: AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
            ),
          )
        else
          ...active.map((debt) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Dismissible(
                  key: ValueKey('debt-active-${debt.id}'),
                  direction: DismissDirection.horizontal,
                  background: const _SwipeBackground(
                    direction: DismissDirection.startToEnd,
                    color: AppColors.amberLight,
                    foreground: AppColors.amber,
                    icon: Icons.check_circle_outline,
                    label: 'Settled',
                  ),
                  secondaryBackground: const _SwipeBackground(
                    direction: DismissDirection.endToStart,
                    color: AppColors.redLight,
                    foreground: AppColors.red,
                    icon: Icons.delete_outline,
                    label: 'Delete',
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      await onSettle(debt);
                    } else {
                      await onDelete(debt);
                    }
                    return false;
                  },
                  child: _DebtRow(
                    debt: debt,
                    currency: currency,
                    onTap: () => onEdit(debt),
                  ),
                ),
              )),
        if (settled.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey<String>('settled-$label'),
              initiallyExpanded: false,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'Settled (${settled.length})',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.inkDim,
                ),
              ),
              children: settled
                  .map((debt) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Dismissible(
                          key: ValueKey('debt-settled-${debt.id}'),
                          direction: DismissDirection.endToStart,
                          background: const _SwipeBackground(
                            direction: DismissDirection.endToStart,
                            color: AppColors.redLight,
                            foreground: AppColors.red,
                            icon: Icons.delete_outline,
                            label: 'Delete',
                          ),
                          confirmDismiss: (_) async {
                            await onDelete(debt);
                            return false;
                          },
                          child: Opacity(
                            opacity: 0.55,
                            child: _DebtRow(
                              debt: debt,
                              currency: currency,
                              onTap: () => onEdit(debt),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  static int _sortDebt(Debt a, Debt b) {
    final firstDate = a.dueDate;
    final secondDate = b.dueDate;
    if (firstDate != null && secondDate != null) {
      final byDate = firstDate.compareTo(secondDate);
      if (byDate != 0) return byDate;
    } else if (firstDate != null) {
      return -1;
    } else if (secondDate != null) {
      return 1;
    }
    return a.safeCounterpartyName
        .toLowerCase()
        .compareTo(b.safeCounterpartyName.toLowerCase());
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.debt,
    required this.currency,
    required this.onTap,
  });

  final Debt debt;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MudraCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.safeCounterpartyName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (debt.dueDate != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Due ${DateFormat('d MMM yyyy').format(debt.dueDate!)}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.inkDim),
                  ),
                ],
              ],
            ),
          ),
          AmountDisplay(
            amount: debt.safeAmount,
            currency: currency,
            style: AppTypography.monoMedium.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.direction,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
  });

  final DismissDirection direction;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLeft = direction == DismissDirection.endToStart;
    return Container(
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) ...[
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: foreground)),
          if (isLeft) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(icon, color: foreground),
          ],
        ],
      ),
    );
  }
}

class _PlatformDraft {
  const _PlatformDraft({
    this.id,
    required this.uid,
    required this.platformName,
    required this.assetType,
    required this.investedAmount,
    required this.currentValue,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final String platformName;
  final AssetType assetType;
  final double investedAmount;
  final double currentValue;
  final DateTime createdAt;
}

class _PlatformEditorSheet extends StatefulWidget {
  const _PlatformEditorSheet({
    required this.initial,
    required this.currency,
    required this.onSave,
    required this.onDelete,
  });

  final InvestmentPlatform? initial;
  final String currency;
  final Future<void> Function(_PlatformDraft draft) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<_PlatformEditorSheet> createState() => _PlatformEditorSheetState();
}

class _PlatformEditorSheetState extends State<_PlatformEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _investedController;
  late final TextEditingController _currentController;
  late AssetType _assetType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController =
        TextEditingController(text: initial?.safePlatformName ?? '');
    _investedController = TextEditingController(
      text:
          initial == null ? '' : initial.safeInvestedAmount.toStringAsFixed(2),
    );
    _currentController = TextEditingController(
      text: initial == null ? '' : initial.safeCurrentValue.toStringAsFixed(2),
    );
    _assetType = initial?.safeAssetType ?? AssetType.mutualFund;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initial;
    final isEditing = initial != null;
    final invested = double.tryParse(_investedController.text.trim()) ?? 0;
    final current = double.tryParse(_currentController.text.trim()) ?? 0;
    final pnl = current - invested;
    final percent = invested == 0 ? 0.0 : pnl / invested * 100;
    final pnlColor = pnl > 0
        ? AppColors.green
        : pnl < 0
            ? AppColors.red
            : AppColors.inkDim;

    return _EditorSurface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHeader(
              title: isEditing ? 'Edit Platform' : 'Add Platform',
              disabled: _saving,
            ),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label: 'Platform name',
              controller: _nameController,
              hintText: 'Groww',
              textInputAction: TextInputAction.next,
              validator: _requiredName,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Asset type',
                style:
                    AppTypography.labelMedium.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AssetType.values
                  .map((type) => ChoiceChip(
                        label: Text(assetTypeLabel(type)),
                        selected: type == _assetType,
                        onSelected: (_) => setState(() => _assetType = type),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MudraInput(
                    label: 'Invested amount',
                    controller: _investedController,
                    hintText: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    amountMode: true,
                    onChanged: (_) => setState(() {}),
                    validator: _amountValidator,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MudraInput(
                    label: 'Current value',
                    controller: _currentController,
                    hintText: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    amountMode: true,
                    onChanged: (_) => setState(() {}),
                    validator: _amountValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            MudraCard(
              color: pnl > 0
                  ? AppColors.greenLight
                  : pnl < 0
                      ? AppColors.redLight
                      : AppColors.surfaceAlt,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('profit and loss'),
                  Text(
                    '${_signedCurrency(pnl, widget.currency)} (${_signedPercent(percent)})',
                    style: AppTypography.monoSmall.copyWith(
                      color: pnlColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SheetButtons(
              saving: _saving,
              saveLabel: isEditing ? 'Save changes' : 'Create platform',
              onSubmit: _submit,
            ),
            if (widget.onDelete != null) ...[
              const SizedBox(height: AppSpacing.sm),
              MudraButton(
                label: 'Delete platform',
                variant: MudraButtonVariant.destructive,
                onPressed: _saving
                    ? null
                    : () async {
                        Navigator.of(context).pop();
                        await widget.onDelete!.call();
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _requiredName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Platform name is required';
    }
    return null;
  }

  String? _amountValidator(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter an amount';
    if (parsed < 0) return 'Amount cannot be negative';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }
    setState(() => _saving = true);
    final initial = widget.initial;
    await widget.onSave(_PlatformDraft(
      id: initial?.id,
      uid: initial != null && initial.safeUid.isNotEmpty
          ? initial.safeUid
          : _uuid.v4(),
      platformName: _nameController.text.trim(),
      assetType: _assetType,
      investedAmount: double.parse(_investedController.text.trim()),
      currentValue: double.parse(_currentController.text.trim()),
      createdAt: initial?.createdAt ?? DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop();
  }
}

class _DebtDraft {
  const _DebtDraft({
    this.id,
    required this.uid,
    required this.counterpartyName,
    required this.direction,
    required this.amount,
    required this.dueDate,
    required this.notes,
    required this.isSettled,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final String counterpartyName;
  final DebtDirection direction;
  final double amount;
  final DateTime? dueDate;
  final String notes;
  final bool isSettled;
  final DateTime createdAt;
}

class _DebtEditorSheet extends StatefulWidget {
  const _DebtEditorSheet({
    required this.initial,
    required this.onSave,
    required this.onDelete,
  });

  final Debt? initial;
  final Future<void> Function(_DebtDraft draft) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<_DebtEditorSheet> createState() => _DebtEditorSheetState();
}

class _DebtEditorSheetState extends State<_DebtEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late DebtDirection _direction;
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController =
        TextEditingController(text: initial?.safeCounterpartyName ?? '');
    _amountController = TextEditingController(
      text: initial == null ? '' : initial.safeAmount.toStringAsFixed(2),
    );
    _notesController = TextEditingController(text: initial?.safeNotes ?? '');
    _direction = initial?.safeDirection ?? DebtDirection.iOwe;
    _dueDate = initial?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initial;
    final isEditing = initial != null;

    return _EditorSurface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHeader(
              title: isEditing ? 'Edit Debt' : 'Add Debt',
              disabled: _saving,
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<DebtDirection>(
              segments: const [
                ButtonSegment(
                  value: DebtDirection.iOwe,
                  label: Text('I Owe'),
                ),
                ButtonSegment(
                  value: DebtDirection.theyOwe,
                  label: Text('They Owe'),
                ),
              ],
              selected: {_direction},
              onSelectionChanged: (selection) =>
                  setState(() => _direction = selection.first),
              style: _segmentedButtonStyle,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Counterparty name',
              controller: _nameController,
              hintText: 'Priya',
              textInputAction: TextInputAction.next,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Counterparty name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Amount',
              controller: _amountController,
              hintText: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              amountMode: true,
              validator: _amountValidator,
            ),
            const SizedBox(height: AppSpacing.md),
            MudraCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('due date'),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _dueDate == null
                              ? 'No due date'
                              : DateFormat('d MMM yyyy').format(_dueDate!),
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.ink),
                        ),
                      ],
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.close, color: AppColors.inkDim),
                      tooltip: 'Clear due date',
                    ),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickDueDate,
                    icon: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: const Text('Pick'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            MudraInput(
              label: 'Notes (optional)',
              controller: _notesController,
              hintText: 'Shared trip expenses',
            ),
            const SizedBox(height: AppSpacing.lg),
            _SheetButtons(
              saving: _saving,
              saveLabel: isEditing ? 'Save changes' : 'Create debt',
              onSubmit: _submit,
            ),
            if (widget.onDelete != null) ...[
              const SizedBox(height: AppSpacing.sm),
              MudraButton(
                label: 'Delete debt',
                variant: MudraButtonVariant.destructive,
                onPressed: _saving
                    ? null
                    : () async {
                        Navigator.of(context).pop();
                        await widget.onDelete!.call();
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _amountValidator(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter an amount';
    if (parsed < 0) return 'Amount cannot be negative';
    return null;
  }

  Future<void> _pickDueDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 10, 12, 31),
      helpText: 'Select due date',
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }
    setState(() => _saving = true);
    final initial = widget.initial;
    await widget.onSave(_DebtDraft(
      id: initial?.id,
      uid: initial != null && initial.safeUid.isNotEmpty
          ? initial.safeUid
          : _uuid.v4(),
      counterpartyName: _nameController.text.trim(),
      direction: _direction,
      amount: double.parse(_amountController.text.trim()),
      dueDate: _dueDate,
      notes: _notesController.text.trim(),
      isSettled: initial?.safeIsSettled ?? false,
      createdAt: initial?.createdAt ?? DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop();
  }
}

class _EditorSurface extends StatelessWidget {
  const _EditorSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.lg,
            AppSpacing.screenH,
            AppSpacing.screenV,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.disabled});

  final String title;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
          ),
        ),
        IconButton(
          onPressed: disabled ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.inkDim),
          tooltip: 'Close',
        ),
      ],
    );
  }
}

class _SheetButtons extends StatelessWidget {
  const _SheetButtons({
    required this.saving,
    required this.saveLabel,
    required this.onSubmit,
  });

  final bool saving;
  final String saveLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MudraButton(
            label: 'Cancel',
            variant: MudraButtonVariant.secondary,
            onPressed: saving ? null : () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: MudraButton(
            label: saving ? 'Saving...' : saveLabel,
            onPressed: saving ? null : onSubmit,
          ),
        ),
      ],
    );
  }
}

class _NetWorthSheet extends StatelessWidget {
  const _NetWorthSheet({required this.dashboard});

  final DashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.lg,
          AppSpacing.screenH,
          AppSpacing.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Net Worth',
                    style: AppTypography.headingMedium
                        .copyWith(color: AppColors.gold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.inkDim),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('assets'),
            const SizedBox(height: AppSpacing.sm),
            _FormulaRow(
              label: 'Liquid Cash',
              amount: dashboard.bankBalance,
              currency: dashboard.currency,
              color: AppColors.green,
            ),
            _FormulaRow(
              label: '+ Fixed Deposits',
              amount: dashboard.fdTotal,
              currency: dashboard.currency,
            ),
            _FormulaRow(
              label: '+ Investments',
              amount: dashboard.investmentsTotal,
              currency: dashboard.currency,
              color: AppColors.amber,
            ),
            const Divider(height: AppSpacing.lg),
            _FormulaRow(
              label: '= Total Assets',
              amount: dashboard.totalAssets,
              currency: dashboard.currency,
              color: AppColors.green,
              emphasized: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel('liabilities'),
            const SizedBox(height: AppSpacing.sm),
            _FormulaRow(
              label: 'CC Outstanding',
              amount: dashboard.ccOutstanding,
              currency: dashboard.currency,
              color: AppColors.red,
            ),
            _FormulaRow(
              label: '+ Debts I Owe',
              amount: dashboard.debtsIOwe,
              currency: dashboard.currency,
              color: AppColors.red,
            ),
            const Divider(height: AppSpacing.lg),
            _FormulaRow(
              label: '= Total Liabilities',
              amount: dashboard.totalLiabilities,
              currency: dashboard.currency,
              color: AppColors.red,
              emphasized: true,
            ),
            const Spacer(),
            MudraCard(
              color: AppColors.surface,
              child: Column(
                children: [
                  const SectionLabel('net worth = assets - liabilities'),
                  const SizedBox(height: AppSpacing.sm),
                  AmountDisplay(
                    amount: dashboard.netWorth,
                    currency: dashboard.currency,
                    style: AppTypography.monoLarge,
                    coloured: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  const _FormulaRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.color,
    this.emphasized = false,
  });

  final String label;
  final double amount;
  final String currency;
  final Color? color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: emphasized ? AppColors.ink : AppColors.inkDim,
              fontWeight: emphasized ? FontWeight.w600 : null,
            ),
          ),
          AmountDisplay(
            amount: amount,
            currency: currency,
            style: AppTypography.monoSmall.copyWith(
              color: color,
              fontWeight: emphasized ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }
}

String _signedCurrency(double value, String currency) {
  final formatted = CurrencyFormatter.format(value, currency);
  return value > 0 ? '+$formatted' : formatted;
}

String _signedPercent(double value) {
  final formatted = '${value.toStringAsFixed(1)}%';
  return value > 0 ? '+$formatted' : formatted;
}

final _segmentedButtonStyle = ButtonStyle(
  visualDensity: VisualDensity.compact,
  foregroundColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected) ? Colors.white : AppColors.ink;
  }),
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? AppColors.gold
        : AppColors.surface;
  }),
  side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
  textStyle: WidgetStatePropertyAll(AppTypography.labelMedium),
);
