import 'package:flutter/material.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

// ── Data model ────────────────────────────────────────────────────────────

class _MapNode {
  const _MapNode({
    required this.label,
    this.sub,
    required this.color,
    this.children = const [],
    this.initiallyExpanded = false,
  });

  final String label;
  final String? sub;
  final Color color;
  final List<_MapNode> children;
  final bool initiallyExpanded;

  bool get isLeaf => children.isEmpty;
}

// ── Static tree data ──────────────────────────────────────────────────────

const _tree = _MapNode(
  label: 'Mudra App',
  sub: 'v1.0 · Flutter',
  color: AppColors.gold,
  initiallyExpanded: true,
  children: [
    _MapNode(
      label: 'Splash Screen',
      color: AppColors.gold,
      children: [
        _MapNode(
          label: 'Session gate',
          sub: 'Supabase auth before finance access',
          color: AppColors.surfaceAlt,
          children: [
            _MapNode(label: 'Signed out → Welcome', color: AppColors.border),
            _MapNode(
                label: 'Verified → private local store',
                color: AppColors.border),
          ],
        ),
      ],
    ),

    _MapNode(
      label: 'Authentication Entry',
      sub: 'Welcome · Login · Register',
      color: AppColors.inkDim,
      initiallyExpanded: true,
      children: [
        _MapNode(
            label: 'Welcome', sub: '/welcome', color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Email Verify',
            sub: 'mudra://auth/callback',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Password Reset',
            sub: 'mudra://auth/reset-password',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Legacy Data',
            sub: 'Attach or start fresh',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Setup Welcome',
            sub: 'Authenticated handoff',
            color: AppColors.surfaceAlt),
      ],
    ),

    _MapNode(
      label: 'Protected Bottom Nav Shell',
      sub: 'Authenticated + setup complete · 5 tabs',
      color: AppColors.gold,
      initiallyExpanded: true,
      children: [
        // ── HOME ───────────────────────────────────────────────────────
        _MapNode(
          label: 'Home',
          sub: '/  ·  Dashboard',
          color: AppColors.ink,
          initiallyExpanded: true,
          children: [
            _MapNode(
              label: 'This Month Tab',
              sub: 'Default on launch',
              color: AppColors.ink,
              children: [
                _MapNode(
                  label: 'Sticky Date Header',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'Tap 📅 → Date Picker (current month only)',
                        color: AppColors.border),
                  ],
                ),
                _MapNode(
                    label: 'Fuel Gauge Ring',
                    sub: 'Spend vs budget arc',
                    color: AppColors.surfaceAlt),
                _MapNode(
                  label: 'Day Slider  (1–31)',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'Drag → simulate balance on any day',
                        color: AppColors.border),
                  ],
                ),
                _MapNode(
                    label: 'Liquid / Balance Row',
                    sub: 'Opening cash · current',
                    color: AppColors.surfaceAlt),
                _MapNode(
                  label: 'Runway Table',
                  sub: '4 collapsible sections',
                  color: AppColors.ink,
                  children: [
                    _MapNode(
                      label: 'Opening Cash',
                      color: AppColors.surfaceAlt,
                      children: [
                        _MapNode(
                            label: 'Expand → account rows',
                            color: AppColors.border)
                      ],
                    ),
                    _MapNode(
                      label: 'Credits',
                      color: AppColors.surfaceAlt,
                      children: [
                        _MapNode(
                            label: 'Expand → received + upcoming',
                            color: AppColors.border)
                      ],
                    ),
                    _MapNode(
                      label: 'Debits',
                      color: AppColors.surfaceAlt,
                      children: [
                        _MapNode(
                            label: 'Expand → category groups + items',
                            color: AppColors.border)
                      ],
                    ),
                    _MapNode(
                      label: 'Commitments',
                      color: AppColors.surfaceAlt,
                      children: [
                        _MapNode(
                            label: 'Expand → CC + future debits',
                            color: AppColors.border)
                      ],
                    ),
                  ],
                ),
                _MapNode(
                  label: 'Until End of Month',
                  sub: 'Radar — debits within 7 days',
                  color: AppColors.ink,
                  children: [
                    _MapNode(
                        label:
                            'Radar Item: name · type · amount · urgency chip',
                        color: AppColors.surfaceAlt),
                  ],
                ),
                _MapNode(
                  label: 'FAB  [+]  → Quick Spend',
                  color: AppColors.ink,
                  children: [
                    _MapNode(
                        label: 'Amount field', color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Category chips',
                        sub:
                            'Food / Travel / Shopping / Bills / Health / Other',
                        color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Optional note', color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Date picker (current month)',
                        color: AppColors.surfaceAlt),
                    _MapNode(
                        label: '[Save] → VariableExpense created',
                        color: AppColors.border),
                  ],
                ),
              ],
            ),
            _MapNode(
              label: 'Overall Tab',
              color: AppColors.ink,
              children: [
                _MapNode(
                  label: 'Net Worth Hero',
                  sub: 'Tap → /net screen',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'Tap → Net Worth screen',
                        color: AppColors.border)
                  ],
                ),
                _MapNode(
                  label: 'Asset Allocation Donut',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'Liquid Cash segment', color: AppColors.border),
                    _MapNode(
                        label: 'Fixed Deposits segment',
                        color: AppColors.border),
                    _MapNode(
                        label: 'Investments segment', color: AppColors.border),
                    _MapNode(
                        label: 'Tap segment → shows value',
                        color: AppColors.border),
                  ],
                ),
                _MapNode(
                  label: 'Stat Tiles Row',
                  color: AppColors.ink,
                  children: [
                    _MapNode(
                        label: 'ASSETS tap → /accounts',
                        color: AppColors.border),
                    _MapNode(
                        label: 'INVESTED tap → /portfolio',
                        color: AppColors.border),
                    _MapNode(
                        label: 'LIABILITIES tap → /portfolio',
                        color: AppColors.border),
                  ],
                ),
                _MapNode(
                    label: 'Breakdown Rows',
                    sub: 'Assets + Liabilities detail',
                    color: AppColors.surfaceAlt),
              ],
            ),
          ],
        ),

        // ── FUNDS ──────────────────────────────────────────────────────
        _MapNode(
          label: 'Funds',
          sub: '/accounts',
          color: AppColors.green,
          initiallyExpanded: true,
          children: [
            _MapNode(
              label: 'Account List',
              color: AppColors.green,
              children: [
                _MapNode(
                  label: 'AccountTile',
                  sub: 'nickname · bank · category · balance',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'LIQUID badge (if included in liquid)',
                        color: AppColors.border),
                    _MapNode(
                      label: 'Tap balance → Quick Balance Update Sheet',
                      color: AppColors.border,
                      children: [
                        _MapNode(
                            label: 'Amount field (pre-filled)',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: '[Update] → saves new balance',
                            color: AppColors.border),
                      ],
                    ),
                    _MapNode(
                        label: 'FD Amount row (if > 0)',
                        color: AppColors.border),
                    _MapNode(
                      label: 'Tap tile → Edit Account Sheet',
                      color: AppColors.border,
                      children: [
                        _MapNode(
                            label: 'Nickname · Bank Name',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Account Type',
                            sub: 'Personal / Credit Card / Savings',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Balance · FD Amount',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Include in Liquid toggle',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: '[Save]  /  [Delete]',
                            color: AppColors.border),
                      ],
                    ),
                    _MapNode(
                        label: 'Swipe left → Delete (confirm)',
                        color: AppColors.border),
                  ],
                ),
              ],
            ),
            _MapNode(
              label: 'FAB  [+]  → Add Account',
              color: AppColors.green,
              children: [
                _MapNode(
                    label: 'Same form as Edit Account (blank)',
                    color: AppColors.surfaceAlt),
              ],
            ),
          ],
        ),

        // ── DEBTS ──────────────────────────────────────────────────────
        _MapNode(
          label: 'Debts',
          sub: '/debts',
          color: AppColors.red,
          initiallyExpanded: true,
          children: [
            _MapNode(
              label: 'Upcoming + Total Committed',
              color: AppColors.red,
              children: [
                _MapNode(
                  label: 'Fixed Commitment Groups',
                  sub: 'Loans · Bills · SIPs · Subscriptions',
                  color: AppColors.surfaceAlt,
                ),
              ],
            ),
            _MapNode(
              label: 'VARIABLE SPENT',
              color: AppColors.red,
              children: [
                _MapNode(
                    label: 'Current-month quick spend rows · swipe delete',
                    color: AppColors.surfaceAlt),
              ],
            ),
            _MapNode(
              label: 'PERSONAL DEBTS  + Add Debt',
              color: AppColors.red,
              children: [
                _MapNode(
                  label: 'I OWE',
                  sub: 'Active + collapsed SETTLED',
                  color: AppColors.surfaceAlt,
                ),
                _MapNode(
                  label: 'OWED TO ME',
                  sub: 'Active + collapsed SETTLED',
                  color: AppColors.surfaceAlt,
                ),
                _MapNode(
                  label: 'Swipe right → settle · left → delete',
                  color: AppColors.border,
                ),
              ],
            ),
            _MapNode(label: 'FAB  [+]  → Add Commitment', color: AppColors.red),
          ],
        ),

        // ── INVESTMENTS ────────────────────────────────────────────────
        _MapNode(
          label: 'Invests',
          sub: '/portfolio',
          color: AppColors.amber,
          initiallyExpanded: true,
          children: [
            _MapNode(
                label: 'Net Worth Hero',
                sub: 'Tap → /net',
                color: AppColors.surfaceAlt),
            _MapNode(
              label: 'Platform Filter Bar',
              sub: 'All · Platform name chips',
              color: AppColors.amber,
              children: [
                _MapNode(
                    label: 'Tap chip → filter holdings below',
                    color: AppColors.border)
              ],
            ),
            _MapNode(
              label: 'Timeline Filter Bar',
              sub: '1M · 3M · 6M · 1Y · All',
              color: AppColors.amber,
              children: [
                _MapNode(
                    label: 'Filters holdings by createdAt date',
                    color: AppColors.border)
              ],
            ),
            _MapNode(
              label: 'Asset Allocation Donut',
              sub: 'By AssetType (when holdings exist)',
              color: AppColors.amber,
              children: [
                _MapNode(
                    label: 'Segments per AssetType',
                    sub: 'MF · Stocks · PPF · EPF · NPS · Gold · Other',
                    color: AppColors.surfaceAlt),
                _MapNode(
                    label: 'Tap segment → shows value vs %',
                    color: AppColors.border),
              ],
            ),
            _MapNode(
              label: 'Holdings — by Asset Type',
              sub: 'ExpansionTile per type',
              color: AppColors.amber,
              children: [
                _MapNode(
                  label: 'HoldingRow',
                  sub: 'scheme · platform badge · P&L chip',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                      label: 'Tap → Edit Holding Sheet',
                      color: AppColors.border,
                      children: [
                        _MapNode(
                            label: 'Scheme name', color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Platform picker chips',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Asset type chips',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Invested Amount · Current Value',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: 'Units (optional)',
                            color: AppColors.surfaceAlt),
                        _MapNode(
                            label: '[Save]  /  [Delete]',
                            color: AppColors.border),
                      ],
                    ),
                    _MapNode(
                        label: 'Swipe left → Delete holding',
                        color: AppColors.border),
                  ],
                ),
              ],
            ),
            _MapNode(
              label: 'Platform Summary',
              color: AppColors.amber,
              children: [
                _MapNode(
                  label: 'PlatformCard',
                  sub: 'name · asset type · invested · P&L',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'Tap → Edit Platform Sheet',
                        color: AppColors.border),
                    _MapNode(
                        label: 'Swipe left → Delete platform',
                        color: AppColors.border),
                  ],
                ),
              ],
            ),
            _MapNode(
              label: 'FAB  [+]  → Add Choice',
              color: AppColors.amber,
              children: [
                _MapNode(
                  label: 'Add Holding / Scheme',
                  color: AppColors.amber,
                  children: [
                    _MapNode(label: 'Scheme name', color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Platform picker chips',
                        color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Asset type chips', color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Invested Amount · Current Value',
                        color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Units (optional)', color: AppColors.surfaceAlt),
                    _MapNode(label: '[Save]', color: AppColors.border),
                  ],
                ),
                _MapNode(
                  label: 'Add Platform',
                  color: AppColors.amber,
                  children: [
                    _MapNode(
                        label: 'Platform name', color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Asset type chips', color: AppColors.surfaceAlt),
                    _MapNode(
                        label: 'Invested Amount · Current Value',
                        color: AppColors.surfaceAlt),
                    _MapNode(label: '[Save]', color: AppColors.border),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ── NET WORTH ──────────────────────────────────────────────────
        _MapNode(
          label: 'Net Worth',
          sub: '/net',
          color: AppColors.blue,
          initiallyExpanded: true,
          children: [
            _MapNode(
                label: 'Net Worth Hero',
                sub: '"Your Net Worth" + pos/neg label',
                color: AppColors.surfaceAlt),
            _MapNode(
              label: 'Asset Allocation Donut',
              sub: 'Liquid · FD · Investments',
              color: AppColors.surfaceAlt,
              children: [
                _MapNode(
                    label: 'Tap segment → value vs %', color: AppColors.border)
              ],
            ),
            _MapNode(
                label: 'Formula Card',
                sub: 'Assets − Liabilities = Net Worth',
                color: AppColors.surfaceAlt),
            _MapNode(
              label: 'Expandable Sections',
              color: AppColors.blue,
              children: [
                _MapNode(
                  label: 'MONEY IN BANKS',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'Liquid Accounts → rows',
                        color: AppColors.border),
                    _MapNode(
                        label: 'Fixed Deposits → rows',
                        color: AppColors.border),
                  ],
                ),
                _MapNode(
                  label: 'INVESTMENTS',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(
                        label: 'PlatformCard per platform (read-only)',
                        color: AppColors.border)
                  ],
                ),
                _MapNode(
                  label: 'CC OUTSTANDING',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(label: 'Credit card rows', color: AppColors.border)
                  ],
                ),
                _MapNode(
                  label: 'LOANS & I OWE',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(label: 'Personal debts', color: AppColors.border),
                    _MapNode(
                        label: 'Active outgoings due ≤ today',
                        color: AppColors.border),
                  ],
                ),
                _MapNode(
                  label: 'OWED TO ME',
                  sub: 'Only shown when entries exist',
                  color: AppColors.surfaceAlt,
                  children: [
                    _MapNode(label: 'Debt rows', color: AppColors.border)
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ── PROFILE ──────────────────────────────────────────────────────
    _MapNode(
      label: 'Profile Screen',
      sub: 'Protected screens only',
      color: AppColors.inkDim,
      initiallyExpanded: true,
      children: [
        _MapNode(
            label: 'User Name',
            sub: 'Display name → initials avatar',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Base Currency',
            sub: 'INR · USD · EUR · GBP · JPY · AED · SGD',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Pay Date',
            sub: 'Grid 1–31 picker',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'App Map',
            sub: 'Navigate to /map screen',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Sign Out',
            sub: 'Close user store → Welcome',
            color: AppColors.surfaceAlt),
        _MapNode(
            label: 'Clear All Data',
            sub: 'Double-confirm → wipes current user store',
            color: AppColors.surfaceAlt),
      ],
    ),
  ],
);

// ── Screen ────────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _allExpanded = false;
  int _refreshKey = 0;

  void _expandAll() => setState(() {
        _allExpanded = true;
        _refreshKey++;
      });
  void _collapseAll() => setState(() {
        _allExpanded = false;
        _refreshKey++;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'App Map',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
        actions: [
          TextButton(
            onPressed: _expandAll,
            child: Text('Expand all',
                style:
                    AppTypography.labelSmall.copyWith(color: AppColors.gold)),
          ),
          TextButton(
            onPressed: _collapseAll,
            child: Text('Collapse',
                style:
                    AppTypography.labelSmall.copyWith(color: AppColors.inkDim)),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.md,
            AppSpacing.screenH, AppSpacing.xxl),
        child: _TreeNodeWidget(
          key: ValueKey(_refreshKey),
          node: _tree,
          depth: 0,
          forceExpand: _allExpanded,
          forceCollapse: !_allExpanded && _refreshKey > 0,
        ),
      ),
    );
  }
}

// ── Recursive Tree Node ───────────────────────────────────────────────────

class _TreeNodeWidget extends StatefulWidget {
  const _TreeNodeWidget({
    super.key,
    required this.node,
    required this.depth,
    this.forceExpand = false,
    this.forceCollapse = false,
  });

  final _MapNode node;
  final int depth;
  final bool forceExpand;
  final bool forceCollapse;

  @override
  State<_TreeNodeWidget> createState() => _TreeNodeWidgetState();
}

class _TreeNodeWidgetState extends State<_TreeNodeWidget>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _chevronController;
  late Animation<double> _chevronTurn;

  @override
  void initState() {
    super.initState();
    _expanded = widget.node.initiallyExpanded;
    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: _expanded ? 1.0 : 0.0,
    );
    _chevronTurn = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_TreeNodeWidget old) {
    super.didUpdateWidget(old);
    if (widget.forceExpand && !_expanded) _setExpanded(true);
    if (widget.forceCollapse && _expanded) _setExpanded(false);
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  void _setExpanded(bool v) {
    setState(() => _expanded = v);
    if (v) {
      _chevronController.forward();
    } else {
      _chevronController.reverse();
    }
  }

  void _toggle() {
    if (widget.node.isLeaf) return;
    _setExpanded(!_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final indent = widget.depth * 20.0;
    final isLeaf = node.isLeaf;

    // Determine node colours
    final bool isColoured =
        node.color != AppColors.surfaceAlt && node.color != AppColors.border;
    final bgColor = isColoured ? node.color : node.color;
    final textColor =
        (node.color == AppColors.surfaceAlt || node.color == AppColors.border)
            ? AppColors.ink
            : Colors.white;
    final subColor =
        (node.color == AppColors.surfaceAlt || node.color == AppColors.border)
            ? AppColors.inkDim
            : Colors.white.withAlpha(180);

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Node Pill ──────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isColoured ? bgColor : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.label,
                          style: AppTypography.bodySmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (node.sub != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            node.sub!,
                            style: AppTypography.monoXSmall
                                .copyWith(color: subColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isLeaf) ...[
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _chevronTurn,
                      child: Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: textColor.withAlpha(180),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Children ───────────────────────────────────────────────
          if (!isLeaf)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vertical connector line + children
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: 1.5,
                                  margin: const EdgeInsets.only(right: 10),
                                  color: AppColors.border,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: node.children.map((child) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: _TreeNodeWidget(
                                          node: child,
                                          depth: 0,
                                          forceExpand: widget.forceExpand,
                                          forceCollapse: widget.forceCollapse,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
