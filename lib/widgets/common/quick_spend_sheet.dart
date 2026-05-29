import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/variable_expense.dart';
import 'mudra_button.dart';

class QuickSpendDraft {
  const QuickSpendDraft({
    required this.amount,
    required this.category,
    required this.note,
    required this.spentAt,
  });

  final double amount;
  final VariableCategory category;
  final String note;
  final DateTime spentAt;
}

class QuickSpendSheet extends StatefulWidget {
  const QuickSpendSheet({
    super.key,
    required this.currency,
    required this.onSave,
  });

  final String currency;
  final Future<void> Function(QuickSpendDraft draft) onSave;

  @override
  State<QuickSpendSheet> createState() => _QuickSpendSheetState();
}

class _QuickSpendSheetState extends State<QuickSpendSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  VariableCategory _category = VariableCategory.misc;
  DateTime _spentAt = DateTime.now();
  bool _saving = false;

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _amount > 0 && !_saving;
    final symbol = CurrencyFormatter.symbol(widget.currency);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor: 0.55,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              AppSpacing.screenV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Log a spend',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.inkDim),
                    ),
                  ],
                ),
                TextField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.right,
                  style: AppTypography.monoLarge.copyWith(
                    color: AppColors.ink,
                    fontSize: 40,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '$symbol ',
                    prefixStyle: AppTypography.monoLarge.copyWith(
                      color: AppColors.ink,
                      fontSize: 40,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: VariableCategory.values.map((category) {
                    final selected = _category == category;
                    return ChoiceChip(
                      label: Text('${category.emoji} ${category.label}'),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      selectedColor: AppColors.red,
                      backgroundColor: AppColors.surfaceAlt,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: selected ? Colors.white : AppColors.inkMid,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.red : AppColors.border,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _noteController,
                  maxLength: 40,
                  style:
                      AppTypography.bodyMedium.copyWith(color: AppColors.ink),
                  decoration: const InputDecoration(
                    hintText: 'What was it? (optional)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionChip(
                    backgroundColor: AppColors.surfaceAlt,
                    side: const BorderSide(color: AppColors.border),
                    label: Text(
                      _isToday(_spentAt)
                          ? 'Today'
                          : '${_spentAt.day} ${_monthName(_spentAt.month)}',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.inkDim),
                    ),
                    avatar: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.inkDim,
                    ),
                    onPressed: _saving ? null : _pickDate,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraButton(
                  label: _saving
                      ? 'Logging...'
                      : 'Log ${CurrencyFormatter.format(_amount, widget.currency)} spend',
                  onPressed: canSave ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _spentAt.isAfter(now) ? now : _spentAt,
      firstDate: DateTime(now.year, now.month),
      lastDate: now,
      helpText: 'Select spend date',
    );
    if (selected != null && mounted) {
      setState(() => _spentAt = selected.isAfter(now) ? now : selected);
    }
  }

  Future<void> _submit() async {
    if (_amount <= 0) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final formatted = CurrencyFormatter.format(_amount, widget.currency);
    await widget.onSave(QuickSpendDraft(
      amount: _amount,
      category: _category,
      note: _noteController.text.trim(),
      spentAt: _spentAt.isAfter(DateTime.now()) ? DateTime.now() : _spentAt,
    ));
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text('$formatted logged')));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _monthName(int month) {
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }
}
