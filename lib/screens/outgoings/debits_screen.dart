import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/outgoing.dart';
import '../../providers/outgoing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';
import '../../widgets/common/section_label.dart';
import '../../widgets/outgoing_row.dart';

const _uuid = Uuid();
const _expenseSuggestions = <String>[
  'Home Loan EMI',
  'Rent',
  'Electricity Bill',
  'Wi-Fi',
  'Netflix',
  'Spotify',
];
const _investmentSuggestions = <String>[
  'Mutual Fund SIP',
  'PPF Contribution',
  'NPS Auto Debit',
  'EPF Top Up',
  'Gold Savings',
];
const _expenseCategories = <OutgoingCategory>[
  OutgoingCategory.loan,
  OutgoingCategory.insurance,
  OutgoingCategory.utility,
  OutgoingCategory.subscription,
  OutgoingCategory.other,
];
const _investmentCategories = <OutgoingCategory>[
  OutgoingCategory.sip,
  OutgoingCategory.ppf,
  OutgoingCategory.epf,
  OutgoingCategory.nps,
  OutgoingCategory.other,
];

class DebitsScreen extends ConsumerStatefulWidget {
  const DebitsScreen({super.key});

  @override
  ConsumerState<DebitsScreen> createState() => _DebitsScreenState();
}

class _DebitsScreenState extends ConsumerState<DebitsScreen> {
  OutgoingType _selectedType = OutgoingType.expense;

  @override
  Widget build(BuildContext context) {
    final outgoings = ref.watch(outgoingsStreamProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull ?? AppSettings();
    final currency = settings.safeBaseCurrency;

    final viewData = outgoings
        .map(_OutgoingView.fromOutgoing)
        .where((item) => item.isActive)
        .toList();

    final filtered =
        viewData.where((item) => item.type == _selectedType).toList()
          ..sort((a, b) {
            final byDay = a.debitDate.compareTo(b.debitDate);
            if (byDay != 0) return byDay;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

    final monthlyTotal =
        filtered.fold<double>(0, (sum, item) => sum + item.amount);

    final upcoming = filtered.where((item) => item.daysUntil <= 7).toList()
      ..sort((a, b) {
        final byDays = a.daysUntil.compareTo(b.daysUntil);
        if (byDays != 0) return byDays;
        return a.debitDate.compareTo(b.debitDate);
      });

    final totalLabel = _selectedType == OutgoingType.expense
        ? 'MONTHLY EXPENSES'
        : 'MONTHLY INVESTMENTS';
    final summaryColor =
        _selectedType == OutgoingType.expense ? AppColors.red : AppColors.amber;
    final summaryBg = _selectedType == OutgoingType.expense
        ? AppColors.redLight
        : AppColors.amberLight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Debits',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _openOutgoingSheet(context, defaultType: _selectedType),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.screenV,
                AppSpacing.screenH,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(
                    'upcoming in 7 days',
                    color: upcoming.isEmpty ? AppColors.inkDim : AppColors.gold,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (upcoming.isEmpty)
                    MudraCard(
                      color: AppColors.surfaceAlt,
                      child: Text(
                        'No ${_typeLabel(_selectedType).toLowerCase()} debits due this week.',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.inkDim),
                      ),
                    )
                  else
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: upcoming.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = upcoming[index];
                          return _UpcomingChipCard(
                            item: item,
                            currency: currency,
                            onTap: () => _openOutgoingSheet(
                              context,
                              initial: item,
                              defaultType: item.type,
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  MudraCard(
                    color: summaryBg,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: totalLabel,
                            amount: monthlyTotal,
                            currency: currency,
                            color: summaryColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SummaryMeta(
                            label: 'ACTIVE ITEMS',
                            value: filtered.length.toString(),
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<OutgoingType>(
                      segments: const [
                        ButtonSegment(
                          value: OutgoingType.expense,
                          label: Text('Expenses'),
                        ),
                        ButtonSegment(
                          value: OutgoingType.investment,
                          label: Text('Investments'),
                        ),
                      ],
                      selected: <OutgoingType>{_selectedType},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _selectedType = selection.first;
                        });
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return states.contains(WidgetState.selected)
                              ? Colors.white
                              : AppColors.ink;
                        }),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return states.contains(WidgetState.selected)
                              ? AppColors.gold
                              : AppColors.surface;
                        }),
                        side: const WidgetStatePropertyAll(
                          BorderSide(color: AppColors.border),
                        ),
                        textStyle:
                            WidgetStatePropertyAll(AppTypography.labelMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenH),
                      children: [
                        EmptyState(
                          icon: _selectedType == OutgoingType.expense
                              ? '🧾'
                              : '📈',
                          title:
                              'No ${_typeLabel(_selectedType).toLowerCase()} debits yet',
                          message: _selectedType == OutgoingType.expense
                              ? 'Add scheduled expenses like EMIs, insurance, utilities, and subscriptions.'
                              : 'Add auto-investments like SIP, PPF, EPF, or NPS contributions.',
                          action: MudraButton(
                            label: _selectedType == OutgoingType.expense
                                ? 'Add expense'
                                : 'Add investment',
                            onPressed: () => _openOutgoingSheet(
                              context,
                              defaultType: _selectedType,
                            ),
                            expand: false,
                            icon: Icons.add,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        0,
                        AppSpacing.screenH,
                        AppSpacing.xxl,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final accentColor = item.type == OutgoingType.expense
                            ? AppColors.red
                            : AppColors.amber;
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.redLight,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppColors.red,
                            ),
                          ),
                          confirmDismiss: (_) => _confirmDelete(context, item),
                          onDismissed: (_) => _deleteOutgoing(item.id),
                          child: OutgoingRow(
                            name: item.name,
                            categoryLabel: _categoryLabel(item.category),
                            debitDate: item.debitDate,
                            daysUntil: item.daysUntil,
                            amount: item.amount,
                            currency: currency,
                            accentColor: accentColor,
                            onTap: () => _openOutgoingSheet(
                              context,
                              initial: item,
                              defaultType: item.type,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOutgoingSheet(
    BuildContext context, {
    _OutgoingView? initial,
    required OutgoingType defaultType,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _OutgoingEditorSheet(
          initial: initial,
          defaultType: defaultType,
          onSave: _saveOutgoing,
          onDelete: initial == null ? null : () => _deleteOutgoing(initial.id),
        );
      },
    );
  }

  Future<void> _saveOutgoing(_OutgoingDraft draft) async {
    final repo = ref.read(outgoingRepoProvider);
    final outgoing = Outgoing()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..name = draft.name
      ..outgoingType = draft.type
      ..category = draft.category
      ..amount = draft.amount
      ..debitDate = draft.debitDate
      ..isActive = draft.isActive
      ..createdAt = draft.createdAt;

    await repo.save(outgoing);
    await HapticFeedback.lightImpact();
  }

  Future<void> _deleteOutgoing(int id) async {
    await ref.read(outgoingRepoProvider).delete(id);
    await HapticFeedback.mediumImpact();
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    _OutgoingView outgoing,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'Delete ${outgoing.name}?',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'This removes the debit from the Debits screen and monthly projections.',
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
    return confirmed;
  }

  String _typeLabel(OutgoingType type) => switch (type) {
        OutgoingType.expense => 'Expenses',
        OutgoingType.investment => 'Investments',
      };

  String _categoryLabel(OutgoingCategory category) => switch (category) {
        OutgoingCategory.loan => 'Loan',
        OutgoingCategory.insurance => 'Insurance',
        OutgoingCategory.utility => 'Utility',
        OutgoingCategory.subscription => 'Subscription',
        OutgoingCategory.sip => 'SIP',
        OutgoingCategory.ppf => 'PPF',
        OutgoingCategory.epf => 'EPF',
        OutgoingCategory.nps => 'NPS',
        OutgoingCategory.other => 'Other',
      };
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, color: AppColors.inkDim),
        const SizedBox(height: AppSpacing.xs),
        AmountDisplay(
          amount: amount,
          currency: currency,
          style: AppTypography.monoMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryMeta extends StatelessWidget {
  const _SummaryMeta({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, color: AppColors.inkDim),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.monoMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _UpcomingChipCard extends StatelessWidget {
  const _UpcomingChipCard({
    required this.item,
    required this.currency,
    required this.onTap,
  });

  final _OutgoingView item;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        item.type == OutgoingType.expense ? AppColors.red : AppColors.amber;

    return SizedBox(
      width: 170,
      child: MudraCard(
        color: item.type == OutgoingType.expense
            ? AppColors.redLight
            : AppColors.amberLight,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionLabel(
              item.daysUntil == 0
                  ? 'today'
                  : item.daysUntil == 1
                      ? 'tomorrow'
                      : 'in ${item.daysUntil} days',
              color: accentColor,
            ),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_categoryChipLabel(item.category)}  ·  Day ${item.debitDate}',
              style: AppTypography.monoXSmall.copyWith(color: AppColors.inkDim),
            ),
            AmountDisplay(
              amount: item.amount,
              currency: currency,
              style: AppTypography.monoSmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryChipLabel(OutgoingCategory category) => switch (category) {
        OutgoingCategory.loan => 'Loan',
        OutgoingCategory.insurance => 'Insurance',
        OutgoingCategory.utility => 'Utility',
        OutgoingCategory.subscription => 'Subscription',
        OutgoingCategory.sip => 'SIP',
        OutgoingCategory.ppf => 'PPF',
        OutgoingCategory.epf => 'EPF',
        OutgoingCategory.nps => 'NPS',
        OutgoingCategory.other => 'Other',
      };
}

class _OutgoingView {
  const _OutgoingView({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.debitDate,
    required this.isActive,
    required this.createdAt,
    required this.daysUntil,
  });

  final int id;
  final String uid;
  final String name;
  final OutgoingType type;
  final OutgoingCategory category;
  final double amount;
  final int debitDate;
  final bool isActive;
  final DateTime createdAt;
  final int daysUntil;

  factory _OutgoingView.fromOutgoing(Outgoing outgoing) {
    final debitDate = outgoing.safeDebitDate == 0 ? 1 : outgoing.safeDebitDate;
    return _OutgoingView(
      id: outgoing.id,
      uid: outgoing.safeUid,
      name: outgoing.safeName,
      type: outgoing.safeType,
      category: outgoing.safeCategory,
      amount: outgoing.safeAmount,
      debitDate: debitDate,
      isActive: outgoing.safeIsActive,
      createdAt: outgoing.safeCreatedAt,
      daysUntil: DateHelpers.daysUntilDebit(debitDate),
    );
  }
}

class _OutgoingDraft {
  const _OutgoingDraft({
    this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.debitDate,
    required this.isActive,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final String name;
  final OutgoingType type;
  final OutgoingCategory category;
  final double amount;
  final int debitDate;
  final bool isActive;
  final DateTime createdAt;
}

class _OutgoingEditorSheet extends ConsumerStatefulWidget {
  const _OutgoingEditorSheet({
    required this.initial,
    required this.defaultType,
    required this.onSave,
    required this.onDelete,
  });

  final _OutgoingView? initial;
  final OutgoingType defaultType;
  final Future<void> Function(_OutgoingDraft draft) onSave;
  final Future<void> Function()? onDelete;

  @override
  ConsumerState<_OutgoingEditorSheet> createState() =>
      _OutgoingEditorSheetState();
}

class _OutgoingEditorSheetState extends ConsumerState<_OutgoingEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late OutgoingType _type;
  late OutgoingCategory _category;
  late int _debitDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(2),
    );
    _type = initial?.type ?? widget.defaultType;
    _category = _resolveInitialCategory(
      initial?.category,
      initial?.type ?? widget.defaultType,
    );
    _debitDate = initial?.debitDate ?? DateTime.now().day;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initial != null;
    final categories = _type == OutgoingType.expense
        ? _expenseCategories
        : _investmentCategories;
    final suggestions = _type == OutgoingType.expense
        ? _expenseSuggestions
        : _investmentSuggestions;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing
                            ? (_type == OutgoingType.expense
                                ? 'Edit Expense'
                                : 'Edit Investment')
                            : (_type == OutgoingType.expense
                                ? 'Add Expense'
                                : 'Add Investment'),
                        style: AppTypography.headingMedium
                            .copyWith(color: AppColors.gold),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.inkDim,
                      ),
                      tooltip: 'Back',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SegmentedButton<OutgoingType>(
                  segments: const [
                    ButtonSegment(
                      value: OutgoingType.expense,
                      label: Text('Expense'),
                    ),
                    ButtonSegment(
                      value: OutgoingType.investment,
                      label: Text('Investment'),
                    ),
                  ],
                  selected: <OutgoingType>{_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                      _category = _resolveInitialCategory(null, _type);
                    });
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? Colors.white
                          : AppColors.ink;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? AppColors.gold
                          : AppColors.surface;
                    }),
                    side: const WidgetStatePropertyAll(
                      BorderSide(color: AppColors.border),
                    ),
                    textStyle:
                        WidgetStatePropertyAll(AppTypography.labelMedium),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Name',
                  controller: _nameController,
                  hintText: _type == OutgoingType.expense
                      ? 'Home Loan EMI'
                      : 'Mutual Fund SIP',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: suggestions.map((label) {
                    final selected = _nameController.text == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _nameController.text = label;
                        });
                      },
                    );
                  }).toList(),
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
                Text(
                  'Category',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: categories.map((category) {
                    final selected = _category == category;
                    return ChoiceChip(
                      label: Text(_categoryLabel(category)),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _category = category;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraCard(
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel('debit day'),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Day $_debitDate of this month',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.ink),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            _saving ? null : () => _pickDebitDate(context),
                        icon:
                            const Icon(Icons.calendar_month_outlined, size: 18),
                        label: const Text('Pick date'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: MudraButton(
                        label: 'Cancel',
                        variant: MudraButtonVariant.secondary,
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MudraButton(
                        label: _saving
                            ? (isEditing ? 'Saving...' : 'Creating...')
                            : (isEditing ? 'Save changes' : 'Create debit'),
                        onPressed: _saving ? null : _submit,
                      ),
                    ),
                  ],
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  MudraButton(
                    label: 'Delete debit',
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
        ),
      ),
    );
  }

  Future<void> _pickDebitDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, _debitDate),
      firstDate: firstDay,
      lastDate: lastDay,
      helpText: 'Select debit day',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _debitDate = picked.day;
    });
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  OutgoingCategory _resolveInitialCategory(
    OutgoingCategory? initialCategory,
    OutgoingType type,
  ) {
    final allowed = type == OutgoingType.expense
        ? _expenseCategories
        : _investmentCategories;
    if (initialCategory != null && allowed.contains(initialCategory)) {
      return initialCategory;
    }
    return allowed.first;
  }

  String _categoryLabel(OutgoingCategory category) => switch (category) {
        OutgoingCategory.loan => 'Loan',
        OutgoingCategory.insurance => 'Insurance',
        OutgoingCategory.utility => 'Utility',
        OutgoingCategory.subscription => 'Subscription',
        OutgoingCategory.sip => 'SIP',
        OutgoingCategory.ppf => 'PPF',
        OutgoingCategory.epf => 'EPF',
        OutgoingCategory.nps => 'NPS',
        OutgoingCategory.other => 'Other',
      };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }

    setState(() {
      _saving = true;
    });

    final initial = widget.initial;
    final draft = _OutgoingDraft(
      id: initial?.id,
      uid: initial != null && initial.uid.isNotEmpty ? initial.uid : _uuid.v4(),
      name: _nameController.text.trim(),
      type: _type,
      category: _category,
      amount: double.parse(_amountController.text.trim()),
      debitDate: _debitDate,
      isActive: initial?.isActive ?? true,
      createdAt: initial?.createdAt ?? DateTime.now(),
    );

    await widget.onSave(draft);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
