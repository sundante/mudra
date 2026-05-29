import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

const _mapAsset = 'assets/maps/mudra_app_map.json';
const _nodeWidth = 132.0;
const _nodeHeight = 64.0;
const _decisionSize = 92.0;
const _columnGap = 32.0;
const _rowGap = 14.0;
const _canvasPadding = 18.0;
const _initialScale = 0.72;

class _MapNode {
  const _MapNode({
    required this.id,
    required this.label,
    required this.kind,
    required this.color,
    this.sub,
    this.children = const [],
  });

  final String id;
  final String label;
  final String kind;
  final String color;
  final String? sub;
  final List<_MapNode> children;

  bool get hasChildren => children.isNotEmpty;
  bool get isDecision => kind == 'decision';

  factory _MapNode.fromJson(Map<String, dynamic> json) {
    return _MapNode(
      id: json['id'] as String,
      label: json['label'] as String,
      kind: json['kind'] as String,
      color: json['color'] as String,
      sub: json['sub'] as String?,
      children: (json['children'] as List<dynamic>? ?? const [])
          .map((child) => _MapNode.fromJson(child as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class _PlacedNode {
  const _PlacedNode({
    required this.node,
    required this.rect,
    required this.depth,
  });

  final _MapNode node;
  final Rect rect;
  final int depth;
}

class _VisibleEdge {
  const _VisibleEdge({
    required this.parentId,
    required this.childId,
  });

  final String parentId;
  final String childId;
}

class _FlowLayout {
  const _FlowLayout({
    required this.nodes,
    required this.edges,
    required this.size,
  });

  final List<_PlacedNode> nodes;
  final List<_VisibleEdge> edges;
  final Size size;
}

class _NodeTheme {
  const _NodeTheme({
    required this.background,
    required this.border,
    required this.foreground,
    required this.subtle,
    this.italic = false,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color subtle;
  final bool italic;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final Future<_MapNode> _mapFuture = _loadMap();
  final TransformationController _viewerController = TransformationController(
    Matrix4.diagonal3Values(_initialScale, _initialScale, 1),
  );
  final Set<String> _expandedNodeIds = <String>{};

  @override
  void dispose() {
    _viewerController.dispose();
    super.dispose();
  }

  Future<_MapNode> _loadMap() async {
    final raw = await rootBundle.loadString(_mapAsset);
    return _MapNode.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Set<String> _expandableIds(_MapNode root) {
    final ids = <String>{};
    void visit(_MapNode node) {
      if (node.hasChildren) ids.add(node.id);
      for (final child in node.children) {
        visit(child);
      }
    }

    visit(root);
    return ids;
  }

  void _toggleNode(_MapNode node) {
    if (!node.hasChildren) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (!_expandedNodeIds.add(node.id)) {
        _expandedNodeIds.remove(node.id);
      }
    });
  }

  void _toggleAll(_MapNode root) {
    final expandableIds = _expandableIds(root);
    final allExpanded = _expandedNodeIds.length == expandableIds.length &&
        _expandedNodeIds.containsAll(expandableIds);
    HapticFeedback.lightImpact();
    setState(() {
      _expandedNodeIds
        ..clear()
        ..addAll(allExpanded ? const <String>{} : expandableIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MapNode>(
      future: _mapFuture,
      builder: (context, snapshot) {
        final root = snapshot.data;
        final allExpanded = root != null &&
            _expandedNodeIds.length == _expandableIds(root).length &&
            _expandedNodeIds.containsAll(_expandableIds(root));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'App Map',
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.red,
              ),
            ),
            actions: [
              if (root != null)
                TextButton.icon(
                  key: const ValueKey('map-expand-toggle'),
                  onPressed: () => _toggleAll(root),
                  icon: Icon(
                    allExpanded ? Icons.unfold_less : Icons.unfold_more,
                    size: 18,
                    color: allExpanded ? AppColors.inkDim : AppColors.red,
                  ),
                  label: Text(
                    allExpanded ? 'Collapse all' : 'Expand all',
                    style: AppTypography.labelSmall.copyWith(
                      color: allExpanded ? AppColors.inkDim : AppColors.red,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_MapNode> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (snapshot.hasError || snapshot.data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Unable to load app map.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.red),
          ),
        ),
      );
    }

    final layout = _FlowLayoutBuilder(_expandedNodeIds).build(snapshot.data!);
    return InteractiveViewer(
      transformationController: _viewerController,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(220),
      minScale: 0.55,
      maxScale: 2.0,
      child: SizedBox(
        width: math.max(layout.size.width, MediaQuery.sizeOf(context).width),
        height: math.max(
          layout.size.height,
          MediaQuery.sizeOf(context).height - kToolbarHeight,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ConnectorPainter(layout: layout),
              ),
            ),
            for (final placed in layout.nodes)
              Positioned.fromRect(
                rect: placed.rect,
                child: _FlowNodeCard(
                  placed: placed,
                  expanded: _expandedNodeIds.contains(placed.node.id),
                  onTap: () => _toggleNode(placed.node),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FlowLayoutBuilder {
  const _FlowLayoutBuilder(this.expandedIds);

  final Set<String> expandedIds;

  _FlowLayout build(_MapNode root) {
    final placed = <_PlacedNode>[];
    final edges = <_VisibleEdge>[];

    final bottom = _place(root, 0, _canvasPadding, placed, edges);
    var maxRight = 0.0;
    for (final node in placed) {
      maxRight = math.max(maxRight, node.rect.right);
    }

    return _FlowLayout(
      nodes: placed,
      edges: edges,
      size: Size(
        maxRight + _canvasPadding,
        math.max(bottom + _canvasPadding, _nodeHeight + _canvasPadding * 2),
      ),
    );
  }

  double _place(
    _MapNode node,
    int depth,
    double top,
    List<_PlacedNode> placed,
    List<_VisibleEdge> edges,
  ) {
    final visibleChildren = expandedIds.contains(node.id) ? node.children : [];
    final nodeSize = _sizeFor(node);
    final left = _canvasPadding + depth * (_nodeWidth + _columnGap);

    if (visibleChildren.isEmpty) {
      placed.add(_PlacedNode(
        node: node,
        rect: Rect.fromLTWH(left, top, nodeSize.width, nodeSize.height),
        depth: depth,
      ));
      return top + nodeSize.height + _rowGap;
    }

    final childStart = top;
    var cursor = childStart;
    final childRects = <Rect>[];
    for (final child in visibleChildren) {
      final beforeCount = placed.length;
      cursor = _place(child, depth + 1, cursor, placed, edges);
      edges.add(_VisibleEdge(parentId: node.id, childId: child.id));
      childRects.add(placed[beforeCount].rect);
    }

    final childrenTop = childRects.map((rect) => rect.top).reduce(math.min);
    final childrenBottom =
        childRects.map((rect) => rect.bottom).reduce(math.max);
    final centeredTop =
        childrenTop + (childrenBottom - childrenTop - nodeSize.height) / 2;

    placed.add(_PlacedNode(
      node: node,
      rect: Rect.fromLTWH(
        left,
        math.max(_canvasPadding, centeredTop),
        nodeSize.width,
        nodeSize.height,
      ),
      depth: depth,
    ));
    return math.max(cursor, top + nodeSize.height + _rowGap);
  }

  Size _sizeFor(_MapNode node) {
    if (node.isDecision) return const Size(_decisionSize, _decisionSize);
    return const Size(_nodeWidth, _nodeHeight);
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({required this.layout});

  final _FlowLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    final nodesById = {
      for (final placed in layout.nodes) placed.node.id: placed,
    };
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final arrowPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (final edge in layout.edges) {
      final parent = nodesById[edge.parentId];
      final child = nodesById[edge.childId];
      if (parent == null || child == null) continue;

      final start = Offset(parent.rect.right, parent.rect.center.dy);
      final end = Offset(child.rect.left, child.rect.center.dy);
      final midX = start.dx + math.max(18, (end.dx - start.dx) * 0.52);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);

      const arrow = 5.0;
      canvas
        ..drawLine(end, Offset(end.dx - arrow, end.dy - arrow), arrowPaint)
        ..drawLine(end, Offset(end.dx - arrow, end.dy + arrow), arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}

class _FlowNodeCard extends StatelessWidget {
  const _FlowNodeCard({
    required this.placed,
    required this.expanded,
    required this.onTap,
  });

  final _PlacedNode placed;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final node = placed.node;
    final theme = _themeFor(node.color);
    final content = _NodeContent(
      node: node,
      theme: theme,
      expanded: expanded,
    );

    return Semantics(
      button: node.hasChildren,
      label: node.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: node.hasChildren ? onTap : null,
          borderRadius: BorderRadius.circular(node.isDecision ? 13 : 7),
          child: node.isDecision
              ? Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.background,
                      border: Border.all(color: theme.border, width: 1.8),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Center(child: content),
                    ),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: theme.background,
                    border: Border.all(color: theme.border, width: 1.1),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withAlpha(12),
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: content,
                ),
        ),
      ),
    );
  }

  _NodeTheme _themeFor(String color) {
    switch (color) {
      case 'shell':
        return const _NodeTheme(
          background: AppColors.red,
          border: AppColors.red,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'home':
        return const _NodeTheme(
          background: AppColors.ink,
          border: AppColors.ink,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'funds':
        return const _NodeTheme(
          background: AppColors.green,
          border: AppColors.green,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'debts':
        return const _NodeTheme(
          background: AppColors.red,
          border: AppColors.red,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'invest':
        return const _NodeTheme(
          background: AppColors.amber,
          border: AppColors.amber,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'net':
        return const _NodeTheme(
          background: AppColors.blue,
          border: AppColors.blue,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'profile':
        return const _NodeTheme(
          background: AppColors.inkDim,
          border: AppColors.inkDim,
          foreground: Colors.white,
          subtle: Color(0xD9FFFFFF),
        );
      case 'action':
        return const _NodeTheme(
          background: AppColors.surface,
          border: AppColors.border,
          foreground: AppColors.inkMid,
          subtle: AppColors.inkDim,
          italic: true,
        );
      case 'leaf':
      default:
        return const _NodeTheme(
          background: AppColors.surfaceAlt,
          border: AppColors.border,
          foreground: AppColors.ink,
          subtle: AppColors.inkDim,
        );
    }
  }
}

class _NodeContent extends StatelessWidget {
  const _NodeContent({
    required this.node,
    required this.theme,
    required this.expanded,
  });

  final _MapNode node;
  final _NodeTheme theme;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: node.isDecision ? const EdgeInsets.all(8) : EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  node.label,
                  textAlign: TextAlign.center,
                  maxLines: node.isDecision ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.foreground,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    fontStyle: theme.italic ? FontStyle.italic : null,
                  ),
                ),
              ),
              if (node.hasChildren && !node.isDecision) ...[
                const SizedBox(width: 3),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 12,
                  color: theme.subtle,
                ),
              ],
            ],
          ),
          if (node.sub != null) ...[
            const SizedBox(height: 3),
            Text(
              node.sub!,
              textAlign: TextAlign.center,
              maxLines: node.isDecision ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.monoXSmall.copyWith(
                color: theme.subtle,
                fontSize: 8,
                height: 1.05,
              ),
            ),
          ],
          if (node.hasChildren && node.isDecision) ...[
            const SizedBox(height: 2),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 11,
              color: theme.subtle,
            ),
          ],
        ],
      ),
    );
  }
}
