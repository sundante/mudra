import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/common/mudra_hero_card.dart';
import '../../data/models/investment_holding.dart';
import '../../data/models/investment_platform.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/investment_provider.dart';
import '../../widgets/charts/asset_allocation_donut.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/common/timeline_filter_bar.dart';
import '../../widgets/holding_row.dart';
import '../../widgets/platform_card.dart';

const _uuid = Uuid();

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  int? _selectedPlatformId;
  TimelineRange _timelineRange = TimelineRange.all;

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardNotifierProvider);
    final platforms = (ref.watch(platformsStreamProvider).valueOrNull ?? [])
      ..sort((a, b) => a.safePlatformName
          .toLowerCase()
          .compareTo(b.safePlatformName.toLowerCase()));
    final allHoldings = ref.watch(holdingsStreamProvider).valueOrNull ?? [];

    final timelineCutoff = _timelineRange.cutoff;
    final filteredHoldings = allHoldings.where((h) {
      if (_selectedPlatformId != null &&
          h.safePlatformId != _selectedPlatformId) {
        return false;
      }
      if (timelineCutoff != null && h.safeCreatedAt.isBefore(timelineCutoff)) {
        return false;
      }
      return true;
    }).toList();

    // Group filtered holdings by asset type (only types that have holdings)
    final grouped = <AssetType, List<InvestmentHolding>>{};
    for (final h in filteredHoldings) {
      grouped.putIfAbsent(h.safeAssetType, () => []).add(h);
    }
    // Sort groups by asset type index for consistent ordering
    final sortedTypes = grouped.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    // Platform lookup map for holding rows
    final platformMap = {for (final p in platforms) p.id: p};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Investments',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.inkDim),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context, platforms),
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Net Worth Hero ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, AppSpacing.screenV,
                AppSpacing.screenH, AppSpacing.md,
              ),
              child: GestureDetector(
                onTap: () => context.go('/net'),
                child: MudraHeroCard(
                  label: 'NET WORTH',
                  amount: CurrencyFormatter.compact(dashboard.netWorth, dashboard.currency),
                  sublabel: 'Tap for full breakdown',
                  bottom: Row(
                    children: [
                      _HeroInvestStat(label: 'ASSETS', value: CurrencyFormatter.compact(dashboard.totalAssets, dashboard.currency)),
                      Container(width: 1, height: 28, color: Colors.white24),
                      _HeroInvestStat(label: 'INVESTED', value: CurrencyFormatter.compact(dashboard.investmentsTotal, dashboard.currency)),
                      Container(width: 1, height: 28, color: Colors.white24),
                      _HeroInvestStat(label: 'DEBTS', value: CurrencyFormatter.compact(dashboard.totalLiabilities, dashboard.currency)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Platform Filter Bar ──────────────────────────────────────
          if (platforms.isNotEmpty)
            SliverToBoxAdapter(
              child: _PlatformFilterBar(
                platforms: platforms,
                selectedId: _selectedPlatformId,
                onSelected: (id) => setState(() => _selectedPlatformId = id),
              ),
            ),

          // ── Timeline Filter ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: TimelineFilterBar(
              selected: _timelineRange,
              onChanged: (r) => setState(() => _timelineRange = r),
            ),
          ),

          // ── Asset Allocation Donut ───────────────────────────────────
          if (allHoldings.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                    AppSpacing.sm, AppSpacing.screenH, AppSpacing.sm),
                child: AssetAllocationDonut(
                  currency: dashboard.currency,
                  segments: AssetType.values
                      .map((t) {
                        final total = filteredHoldings
                            .where((h) => h.safeAssetType == t)
                            .fold<double>(0, (s, h) => s + h.safeCurrentValue);
                        return DonutSegment(
                          label: assetTypeLabel(t),
                          value: total,
                          color: _assetTypeColor(t),
                        );
                      })
                      .where((s) => s.value > 0)
                      .toList(),
                ),
              ),
            ),

          // ── Holdings grouped by asset type ───────────────────────────
          if (filteredHoldings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                    AppSpacing.xl, AppSpacing.screenH, AppSpacing.md),
                child: Column(
                  children: [
                    Icon(Icons.show_chart,
                        size: 48,
                        color: AppColors.inkDim.withValues(alpha: 0.4)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _selectedPlatformId == null
                          ? 'No holdings yet'
                          : 'No holdings for this platform',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.inkDim),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tap + to add a scheme or fund',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.inkDim),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final type = sortedTypes[index];
                  final holdings = grouped[type]!;
                  final groupTotal = holdings.fold<double>(
                      0, (s, h) => s + h.safeCurrentValue);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0,
                        AppSpacing.screenH, AppSpacing.sm),
                    child: _AssetTypeGroup(
                      assetType: type,
                      groupTotal: groupTotal,
                      currency: dashboard.currency,
                      holdings: holdings,
                      platformMap: platformMap,
                      onTapHolding: (h) =>
                          _openHoldingSheet(context, platforms, initial: h),
                      onDeleteHolding: (id) => _deleteHolding(id),
                    ),
                  );
                },
                childCount: sortedTypes.length,
              ),
            ),

          // ── Platform Summary ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.lg, AppSpacing.screenH, 0),
              child: _SectionActionHeader(
                label: 'PLATFORMS',
                actionLabel: 'Add Platform',
                onPressed: () => _openPlatformSheet(context),
              ),
            ),
          ),

          if (platforms.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                    AppSpacing.sm, AppSpacing.screenH, AppSpacing.md),
                child: Text(
                  'Add a platform first, then record individual holdings.',
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.inkDim),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final platform = platforms[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                        AppSpacing.sm, AppSpacing.screenH, 0),
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
                        final confirmed = await _confirmDelete(context,
                            title: 'Delete ${platform.safePlatformName}?',
                            message:
                                'This removes the platform. Holdings are not deleted.');
                        if (confirmed) await _deletePlatform(platform.id);
                        return false;
                      },
                      child: PlatformCard(
                        platform: platform,
                        currency: dashboard.currency,
                        onTap: () =>
                            _openPlatformSheet(context, initial: platform),
                      ),
                    ),
                  );
                },
                childCount: platforms.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Sheets ──────────────────────────────────────────────────────────

  Future<void> _openAddSheet(
      BuildContext context, List<InvestmentPlatform> platforms) async {
    if (platforms.isEmpty) {
      // No platforms yet — go straight to add platform
      await _openPlatformSheet(context);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddChoiceSheet(
        onAddHolding: () {
          Navigator.of(context).pop();
          _openHoldingSheet(context, platforms);
        },
        onAddPlatform: () {
          Navigator.of(context).pop();
          _openPlatformSheet(context);
        },
      ),
    );
  }

  Future<void> _openHoldingSheet(
    BuildContext context,
    List<InvestmentPlatform> platforms, {
    InvestmentHolding? initial,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HoldingEditorSheet(
        initial: initial,
        platforms: platforms,
        currency: ref.read(dashboardNotifierProvider).currency,
        defaultPlatformId: _selectedPlatformId,
        onSave: _saveHolding,
        onDelete: initial == null ? null : () => _deleteHolding(initial.id),
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
      builder: (_) => _PlatformEditorSheet(
        initial: initial,
        currency: ref.read(dashboardNotifierProvider).currency,
        onSave: _savePlatform,
        onDelete: initial == null ? null : () => _deletePlatform(initial.id),
      ),
    );
  }

  // ── Data operations ─────────────────────────────────────────────────

  Future<void> _saveHolding(_HoldingDraft draft) async {
    final holding = InvestmentHolding()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..platformId = draft.platformId
      ..schemeName = draft.schemeName
      ..assetType = draft.assetType
      ..investedAmount = draft.investedAmount
      ..currentValue = draft.currentValue
      ..units = draft.units
      ..createdAt = draft.createdAt;
    await ref.read(investmentRepoProvider).saveHolding(holding);
    await HapticFeedback.lightImpact();
  }

  Future<void> _deleteHolding(int id) async {
    await ref.read(investmentRepoProvider).deleteHolding(id);
    await HapticFeedback.mediumImpact();
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

  Color _assetTypeColor(AssetType t) => switch (t) {
        AssetType.mutualFund => AppColors.amber,
        AssetType.indianStocks => AppColors.green,
        AssetType.usStocks => AppColors.blue,
        AssetType.ppf => AppColors.gold,
        AssetType.epf => AppColors.inkMid,
        AssetType.nps => AppColors.inkDim,
        AssetType.gold => const Color(0xFFC8A44A),
        AssetType.other => AppColors.border,
      };

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(title,
                style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.ink, fontWeight: FontWeight.w600)),
            content: Text(message,
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.inkDim)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete',
                      style: TextStyle(color: AppColors.red))),
            ],
          ),
        ) ??
        false;
  }
}

// ── Platform Filter Bar ────────────────────────────────────────────────────

class _PlatformFilterBar extends StatelessWidget {
  const _PlatformFilterBar({
    required this.platforms,
    required this.selectedId,
    required this.onSelected,
  });

  final List<InvestmentPlatform> platforms;
  final int? selectedId;
  final void Function(int?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        children: [
          _FilterChip(
            label: 'All',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          ...platforms.map((p) => _FilterChip(
                label: p.safePlatformName,
                selected: selectedId == p.id,
                onTap: () => onSelected(selectedId == p.id ? null : p.id),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border:
              Border.all(color: selected ? AppColors.gold : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.inkDim,
          ),
        ),
      ),
    );
  }
}

// ── Asset Type Group ────────────────────────────────────────────────────────

class _AssetTypeGroup extends StatelessWidget {
  const _AssetTypeGroup({
    required this.assetType,
    required this.groupTotal,
    required this.currency,
    required this.holdings,
    required this.platformMap,
    required this.onTapHolding,
    required this.onDeleteHolding,
  });

  final AssetType assetType;
  final double groupTotal;
  final String currency;
  final List<InvestmentHolding> holdings;
  final Map<int, InvestmentPlatform> platformMap;
  final void Function(InvestmentHolding) onTapHolding;
  final void Function(int) onDeleteHolding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
        title: SectionLabel(assetTypeLabel(assetType).toUpperCase()),
        trailing: AmountDisplay(
          amount: groupTotal,
          currency: currency,
          style: AppTypography.monoSmall.copyWith(color: AppColors.amber),
          compact: true,
        ),
        children: holdings
            .map((h) => Dismissible(
                  key: ValueKey('holding-${h.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child:
                        const Icon(Icons.delete_outline, color: AppColors.red),
                  ),
                  confirmDismiss: (_) async {
                    onDeleteHolding(h.id);
                    return false;
                  },
                  child: HoldingRow(
                    schemeName: h.safeSchemeName,
                    platformName:
                        platformMap[h.safePlatformId]?.safePlatformName ?? '—',
                    investedAmount: h.safeInvestedAmount,
                    currentValue: h.safeCurrentValue,
                    currency: currency,
                    onTap: () => onTapHolding(h),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Add Choice Sheet ────────────────────────────────────────────────────────

class _AddChoiceSheet extends StatelessWidget {
  const _AddChoiceSheet({
    required this.onAddHolding,
    required this.onAddPlatform,
  });

  final VoidCallback onAddHolding;
  final VoidCallback onAddPlatform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.screenV + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('What would you like to add?',
              style:
                  AppTypography.headingMedium.copyWith(color: AppColors.gold)),
          const SizedBox(height: AppSpacing.lg),
          MudraButton(
            label: 'Add Holding / Scheme',
            icon: Icons.add_chart,
            onPressed: onAddHolding,
          ),
          const SizedBox(height: AppSpacing.sm),
          MudraButton(
            label: 'Add Platform',
            icon: Icons.account_balance_outlined,
            variant: MudraButtonVariant.secondary,
            onPressed: onAddPlatform,
          ),
        ],
      ),
    );
  }
}

// ── Hero Invest Stat ──────────────────────────────────────────────────────

class _HeroInvestStat extends StatelessWidget {
  const _HeroInvestStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontSize: 8,
              letterSpacing: 1.0,
              color: Colors.white38,
            ),
          ),
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

// ── Data Drafts ────────────────────────────────────────────────────────────

class _HoldingDraft {
  const _HoldingDraft({
    this.id,
    required this.uid,
    required this.platformId,
    required this.schemeName,
    required this.assetType,
    required this.investedAmount,
    required this.currentValue,
    required this.units,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final int platformId;
  final String schemeName;
  final AssetType assetType;
  final double investedAmount;
  final double currentValue;
  final double units;
  final DateTime createdAt;
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

// ── Holding Editor Sheet ────────────────────────────────────────────────────

class _HoldingEditorSheet extends StatefulWidget {
  const _HoldingEditorSheet({
    required this.initial,
    required this.platforms,
    required this.currency,
    required this.defaultPlatformId,
    required this.onSave,
    required this.onDelete,
  });

  final InvestmentHolding? initial;
  final List<InvestmentPlatform> platforms;
  final String currency;
  final int? defaultPlatformId;
  final Future<void> Function(_HoldingDraft) onSave;
  final Future<void> Function()? onDelete;

  @override
  State<_HoldingEditorSheet> createState() => _HoldingEditorSheetState();
}

class _HoldingEditorSheetState extends State<_HoldingEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _investedController;
  late final TextEditingController _currentController;
  late final TextEditingController _unitsController;
  late AssetType _assetType;
  late int _platformId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final h = widget.initial;
    _nameController = TextEditingController(text: h?.safeSchemeName ?? '');
    _investedController = TextEditingController(
        text: h == null ? '' : h.safeInvestedAmount.toStringAsFixed(2));
    _currentController = TextEditingController(
        text: h == null ? '' : h.safeCurrentValue.toStringAsFixed(2));
    _unitsController = TextEditingController(
        text: h == null || h.safeUnits == 0
            ? ''
            : h.safeUnits.toStringAsFixed(3));
    _assetType = h?.safeAssetType ?? AssetType.mutualFund;
    _platformId = h?.safePlatformId ??
        widget.defaultPlatformId ??
        (widget.platforms.isNotEmpty ? widget.platforms.first.id : 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
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
              title: isEditing ? 'Edit Holding' : 'Add Holding',
              disabled: _saving,
            ),
            const SizedBox(height: AppSpacing.lg),
            MudraInput(
              label: 'Scheme / fund name',
              controller: _nameController,
              hintText: 'SBI Bluechip Fund - Direct Growth',
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            // Platform picker
            Text('Platform',
                style:
                    AppTypography.labelMedium.copyWith(color: AppColors.ink)),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.platforms
                    .map((p) => GestureDetector(
                          onTap: () => setState(() => _platformId = p.id),
                          child: Container(
                            margin: const EdgeInsets.only(right: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: _platformId == p.id
                                  ? AppColors.gold
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                  color: _platformId == p.id
                                      ? AppColors.gold
                                      : AppColors.border),
                            ),
                            child: Text(
                              p.safePlatformName,
                              style: AppTypography.labelMedium.copyWith(
                                color: _platformId == p.id
                                    ? Colors.white
                                    : AppColors.inkDim,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Asset type
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
                    label: 'Invested',
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
            const SizedBox(height: AppSpacing.sm),
            MudraInput(
              label: 'Units (optional)',
              controller: _unitsController,
              hintText: '0.000',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
                  const SectionLabel('P & L'),
                  Text(
                    '${_signedCurrency(pnl, widget.currency)} (${_signedPercent(percent)})',
                    style: AppTypography.monoSmall
                        .copyWith(color: pnlColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SheetButtons(
              saving: _saving,
              saveLabel: isEditing ? 'Save changes' : 'Add holding',
              onSubmit: _submit,
            ),
            if (widget.onDelete != null) ...[
              const SizedBox(height: AppSpacing.sm),
              MudraButton(
                label: 'Delete holding',
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
    if (parsed < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }
    if (_platformId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a platform')),
      );
      return;
    }
    setState(() => _saving = true);
    final h = widget.initial;
    await widget.onSave(_HoldingDraft(
      id: h?.id,
      uid: h != null && h.safeUid.isNotEmpty ? h.safeUid : _uuid.v4(),
      platformId: _platformId,
      schemeName: _nameController.text.trim(),
      assetType: _assetType,
      investedAmount: double.parse(_investedController.text.trim()),
      currentValue: double.parse(_currentController.text.trim()),
      units: double.tryParse(_unitsController.text.trim()) ?? 0.0,
      createdAt: h?.safeCreatedAt ?? DateTime.now(),
    ));
    if (mounted) Navigator.of(context).pop();
  }
}

// ── Platform Editor Sheet ──────────────────────────────────────────────────

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
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Default asset type',
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
                    label: 'Total invested',
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
                    style: AppTypography.monoSmall
                        .copyWith(color: pnlColor, fontWeight: FontWeight.w500),
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

// ── Shared Sheet Widgets ────────────────────────────────────────────────────

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
          child: Text(title,
              style:
                  AppTypography.headingMedium.copyWith(color: AppColors.gold)),
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

// ── Helpers ────────────────────────────────────────────────────────────────

String _signedCurrency(double value, String currency) {
  final formatted = CurrencyFormatter.format(value, currency);
  return value > 0 ? '+$formatted' : formatted;
}

String _signedPercent(double value) {
  final formatted = '${value.toStringAsFixed(1)}%';
  return value > 0 ? '+$formatted' : formatted;
}
