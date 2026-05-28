import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/account.dart';
import '../../data/models/app_settings.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/account_tile.dart';
import '../../widgets/common/amount_display.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/mudra_button.dart';
import '../../widgets/common/mudra_card.dart';
import '../../widgets/common/mudra_input.dart';
import '../../widgets/common/section_label.dart';

const _uuid = Uuid();
const _bankSuggestions = <String>[
  'HDFC Bank',
  'ICICI Bank',
  'Axis Bank',
  'SBI',
  'Federal Bank',
  'Kotak',
  'Jupiter',
];
const _categorySuggestions = <String>[
  'Savings',
  'Current',
  'Emergency',
  'Business with friends',
  'Travel',
  'Bills',
];

class FundsScreen extends ConsumerStatefulWidget {
  const FundsScreen({super.key});

  @override
  ConsumerState<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends ConsumerState<FundsScreen> {
  AccountType _selectedType = AccountType.personal;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull ?? AppSettings();
    final currency = settings.safeBaseCurrency;

    final viewData = accounts
        .map(_FundsAccountView.fromAccount)
        .where((a) => !a.isCreditCard)
        .toList()
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase());
      });

    final filtered =
        viewData.where((a) => a.accountType == _selectedType).toList();
    final liquidTotal = viewData
        .where(
            (a) => a.accountType == AccountType.personal && a.includeInLiquid)
        .fold(0.0, (sum, a) => sum + a.balance);
    final fdTotal = viewData.fold(0.0, (sum, a) => sum + a.fdAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Funds',
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
        onPressed: () => _openAccountSheet(context),
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
                children: [
                  MudraCard(
                    color: AppColors.goldLight,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: 'LIQUID',
                            amount: liquidTotal,
                            currency: currency,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _SummaryStat(
                            label: 'FIXED DEPOSITS',
                            amount: fdTotal,
                            currency: currency,
                            color: AppColors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<AccountType>(
                      segments: const [
                        ButtonSegment(
                          value: AccountType.personal,
                          label: Text('Personal'),
                        ),
                        ButtonSegment(
                          value: AccountType.joint,
                          label: Text('Joint'),
                        ),
                        ButtonSegment(
                          value: AccountType.business,
                          label: Text('Business'),
                        ),
                      ],
                      selected: <AccountType>{_selectedType},
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
                          icon: _selectedType == AccountType.personal
                              ? '🏦'
                              : '🗂',
                          title:
                              'No ${_segmentLabel(_selectedType).toLowerCase()} accounts yet',
                          message:
                              'Add an account to track balances, fixed deposits, and monthly liquid cash.',
                          action: MudraButton(
                            label: 'Add account',
                            onPressed: () => _openAccountSheet(context),
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
                        final account = filtered[index];
                        return Dismissible(
                          key: ValueKey(account.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.redLight,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: AppColors.red),
                          ),
                          confirmDismiss: (_) =>
                              _confirmDelete(context, account),
                          onDismissed: (_) => _deleteAccount(account.id),
                          child: AccountTile(
                            nickname: account.nickname,
                            bankName: account.bankName,
                            categoryLabel: account.categoryLabel,
                            balance: account.balance,
                            fdAmount: account.fdAmount,
                            currency: currency,
                            includeInLiquid: account.includeInLiquid,
                            onTap: () => _openAccountSheet(
                              context,
                              initial: account,
                            ),
                            onBalanceTap: () => _openQuickBalanceSheet(
                              context,
                              account,
                              currency,
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

  Future<void> _openAccountSheet(
    BuildContext context, {
    _FundsAccountView? initial,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AccountEditorSheet(
          initial: initial,
          onSave: _saveAccount,
          onDelete: initial == null ? null : () => _deleteAccount(initial.id),
        );
      },
    );
  }

  Future<void> _openQuickBalanceSheet(
    BuildContext context,
    _FundsAccountView account,
    String currency,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _QuickBalanceSheet(
          account: account,
          currency: currency,
          onSave: _updateBalance,
        );
      },
    );
  }

  Future<void> _saveAccount(_AccountDraft draft) async {
    final repo = ref.read(accountRepoProvider);
    final account = Account()
      ..id = draft.id ?? Isar.autoIncrement
      ..uid = draft.uid
      ..nickname = draft.nickname
      ..bankName = draft.bankName.isEmpty ? null : draft.bankName
      ..categoryLabel = draft.categoryLabel.isEmpty ? null : draft.categoryLabel
      ..accountType = draft.accountType
      ..isCreditCard = false
      ..balance = draft.balance
      ..fdAmount = draft.fdAmount
      ..includeInLiquid =
          draft.accountType == AccountType.personal && draft.includeInLiquid
      ..balanceUpdatedAt = DateTime.now()
      ..sortOrder = draft.sortOrder
      ..isDeleted = false
      ..createdAt = draft.createdAt;

    await repo.save(account);
    await HapticFeedback.lightImpact();
  }

  Future<void> _updateBalance(int id, double balance) async {
    final accounts = ref.read(accountsStreamProvider).valueOrNull ?? [];
    final existing = accounts.cast<Account?>().firstWhere(
          (account) => account?.id == id,
          orElse: () => null,
        );
    if (existing == null) return;

    final repo = ref.read(accountRepoProvider);
    final updated = Account()
      ..id = existing.id
      ..uid = existing.safeUid.isEmpty ? _uuid.v4() : existing.safeUid
      ..nickname = existing.safeNickname
      ..bankName = existing.safeBankName.isEmpty ? null : existing.safeBankName
      ..categoryLabel =
          existing.safeCategoryLabel.isEmpty ? null : existing.safeCategoryLabel
      ..accountType = existing.safeAccountType
      ..isCreditCard = existing.safeIsCreditCard
      ..balance = balance
      ..fdAmount = existing.safeFdAmount
      ..includeInLiquid = existing.safeIncludeInLiquid
      ..balanceUpdatedAt = DateTime.now()
      ..sortOrder = existing.safeSortOrder
      ..isDeleted = existing.safeIsDeleted
      ..createdAt = existing.safeCreatedAt;

    await repo.save(updated);
    await HapticFeedback.mediumImpact();
  }

  Future<void> _deleteAccount(int id) async {
    await ref.read(accountRepoProvider).delete(id);
    await HapticFeedback.mediumImpact();
  }

  Future<bool> _confirmDelete(
      BuildContext context, _FundsAccountView account) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text(
                'Delete ${account.nickname}?',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'This hides the account from Funds and dashboard totals.',
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

  String _segmentLabel(AccountType type) => switch (type) {
        AccountType.personal => 'Personal',
        AccountType.joint => 'Joint',
        AccountType.business => 'Business',
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

class _FundsAccountView {
  const _FundsAccountView({
    required this.id,
    required this.uid,
    required this.nickname,
    required this.bankName,
    required this.categoryLabel,
    required this.accountType,
    required this.isCreditCard,
    required this.balance,
    required this.fdAmount,
    required this.includeInLiquid,
    required this.sortOrder,
    required this.createdAt,
  });

  final int id;
  final String uid;
  final String nickname;
  final String bankName;
  final String categoryLabel;
  final AccountType accountType;
  final bool isCreditCard;
  final double balance;
  final double fdAmount;
  final bool includeInLiquid;
  final int sortOrder;
  final DateTime createdAt;

  factory _FundsAccountView.fromAccount(Account account) {
    return _FundsAccountView(
      id: account.id,
      uid: account.safeUid,
      nickname: account.safeNickname,
      bankName: account.safeBankName,
      categoryLabel: account.safeCategoryLabel,
      accountType: account.safeAccountType,
      isCreditCard: account.safeIsCreditCard,
      balance: account.safeBalance,
      fdAmount: account.safeFdAmount,
      includeInLiquid: account.safeIncludeInLiquid,
      sortOrder: account.safeSortOrder,
      createdAt: account.safeCreatedAt,
    );
  }
}

class _AccountDraft {
  const _AccountDraft({
    this.id,
    required this.uid,
    required this.nickname,
    required this.bankName,
    required this.categoryLabel,
    required this.accountType,
    required this.balance,
    required this.fdAmount,
    required this.includeInLiquid,
    required this.sortOrder,
    required this.createdAt,
  });

  final int? id;
  final String uid;
  final String nickname;
  final String bankName;
  final String categoryLabel;
  final AccountType accountType;
  final double balance;
  final double fdAmount;
  final bool includeInLiquid;
  final int sortOrder;
  final DateTime createdAt;
}

class _AccountEditorSheet extends ConsumerStatefulWidget {
  const _AccountEditorSheet({
    required this.initial,
    required this.onSave,
    required this.onDelete,
  });

  final _FundsAccountView? initial;
  final Future<void> Function(_AccountDraft draft) onSave;
  final Future<void> Function()? onDelete;

  @override
  ConsumerState<_AccountEditorSheet> createState() =>
      _AccountEditorSheetState();
}

class _AccountEditorSheetState extends ConsumerState<_AccountEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _bankController;
  late final TextEditingController _categoryController;
  late final TextEditingController _balanceController;
  late final TextEditingController _fdController;
  late AccountType _accountType;
  late bool _includeInLiquid;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nicknameController = TextEditingController(text: initial?.nickname ?? '');
    _bankController = TextEditingController(text: initial?.bankName ?? '');
    _categoryController =
        TextEditingController(text: initial?.categoryLabel ?? '');
    _balanceController = TextEditingController(
      text: initial == null ? '' : initial.balance.toStringAsFixed(2),
    );
    _fdController = TextEditingController(
      text: initial == null || initial.fdAmount == 0
          ? ''
          : initial.fdAmount.toStringAsFixed(2),
    );
    _accountType = initial?.accountType ?? AccountType.personal;
    _includeInLiquid = initial?.includeInLiquid ?? true;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bankController.dispose();
    _categoryController.dispose();
    _balanceController.dispose();
    _fdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initial != null;

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
                        isEditing ? 'Edit Account' : 'Add Account',
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
                MudraInput(
                  label: 'Nickname',
                  controller: _nicknameController,
                  hintText: 'HDFC Savings',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nickname is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Bank',
                  controller: _bankController,
                  hintText: 'Choose or type a bank',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _bankSuggestions.map((bank) {
                    final selected = _bankController.text == bank;
                    return ChoiceChip(
                      label: Text(bank),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _bankController.text = bank;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Category',
                  controller: _categoryController,
                  hintText: 'Current, business with friends, travel...',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _categorySuggestions.map((category) {
                    final selected = _categoryController.text == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _categoryController.text = category;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                MudraInput(
                  label: 'Balance',
                  controller: _balanceController,
                  hintText: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  amountMode: true,
                  validator: _amountValidator,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AccountType>(
                        initialValue: _accountType,
                        decoration: const InputDecoration(
                          labelText: 'Account Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: AccountType.personal,
                            child: Text('Personal'),
                          ),
                          DropdownMenuItem(
                            value: AccountType.joint,
                            child: Text('Joint'),
                          ),
                          DropdownMenuItem(
                            value: AccountType.business,
                            child: Text('Business'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _accountType = value;
                            if (_accountType != AccountType.personal) {
                              _includeInLiquid = false;
                            } else {
                              _includeInLiquid = true;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MudraInput(
                        label: 'FD Amount',
                        controller: _fdController,
                        hintText: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        amountMode: true,
                        validator: _optionalAmountValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  value: _includeInLiquid,
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.green,
                  title: Text(
                    'Include in liquid total',
                    style:
                        AppTypography.bodyMedium.copyWith(color: AppColors.ink),
                  ),
                  subtitle: Text(
                    _accountType == AccountType.personal
                        ? 'Personal accounts can count toward monthly liquid cash.'
                        : 'Only personal accounts can be liquid.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.inkDim),
                  ),
                  onChanged: _accountType == AccountType.personal
                      ? (value) {
                          setState(() {
                            _includeInLiquid = value;
                          });
                        }
                      : null,
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
                            : (isEditing ? 'Save changes' : 'Create account'),
                        onPressed: _saving ? null : _submit,
                      ),
                    ),
                  ],
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  MudraButton(
                    label: 'Delete account',
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

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _optionalAmountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }

    setState(() {
      _saving = true;
    });

    final initial = widget.initial;
    final existingSortOrder = initial?.sortOrder;
    final accounts = ref.read(accountsStreamProvider).valueOrNull ?? [];
    final maxSortOrder = accounts.fold<int>(0, (max, account) {
      return account.safeSortOrder > max ? account.safeSortOrder : max;
    });

    final draft = _AccountDraft(
      id: initial?.id,
      uid: initial != null && initial.uid.isNotEmpty ? initial.uid : _uuid.v4(),
      nickname: _nicknameController.text.trim(),
      bankName: _bankController.text.trim(),
      categoryLabel: _categoryController.text.trim(),
      accountType: _accountType,
      balance: double.parse(_balanceController.text.trim()),
      fdAmount: _fdController.text.trim().isEmpty
          ? 0
          : double.parse(_fdController.text.trim()),
      includeInLiquid: _includeInLiquid,
      sortOrder: existingSortOrder ?? (maxSortOrder + 1),
      createdAt: initial?.createdAt ?? DateTime.now(),
    );

    await widget.onSave(draft);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _QuickBalanceSheet extends StatefulWidget {
  const _QuickBalanceSheet({
    required this.account,
    required this.currency,
    required this.onSave,
  });

  final _FundsAccountView account;
  final String currency;
  final Future<void> Function(int id, double balance) onSave;

  @override
  State<_QuickBalanceSheet> createState() => _QuickBalanceSheetState();
}

class _QuickBalanceSheetState extends State<_QuickBalanceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _balanceController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _balanceController =
        TextEditingController(text: widget.account.balance.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

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
                        'Quick Balance Update',
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.account.nickname,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.inkDim),
                ),
                const SizedBox(height: AppSpacing.lg),
                MudraInput(
                  label: 'New balance',
                  controller: _balanceController,
                  hintText: '0.00',
                  amountMode: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Balance is required';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
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
                        label: _saving ? 'Updating...' : 'Update balance',
                        onPressed: _saving ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      await HapticFeedback.vibrate();
      return;
    }

    setState(() {
      _saving = true;
    });

    await widget.onSave(
      widget.account.id,
      double.parse(_balanceController.text.trim()),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
