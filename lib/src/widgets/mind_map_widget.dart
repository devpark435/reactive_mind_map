import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../models/mind_map_data.dart';
import '../models/mind_map_style.dart';
import '../models/mind_map_node.dart';
import '../enums/mind_map_layout.dart';
import '../enums/node_shape.dart';
import '../painters/mind_map_painter.dart';
import '../painters/node_painter.dart';

/// 커스터마이징 가능한 마인드맵 위젯 / Customizable mind map widget
class MindMapWidget extends StatefulWidget {
  /// 마인드맵 데이터 / Mind map data
  final MindMapData data;

  /// 마인드맵 스타일 / Mind map style
  final MindMapStyle style;

  /// 노드 탭 콜백 / Node tap callback
  final Function(MindMapData node)? onNodeTap;

  /// 노드 길게 누르기 콜백 / Node long press callback
  final Function(MindMapData node)? onNodeLongPress;

  /// 노드 더블 탭 콜백 / Node double tap callback
  final Function(MindMapData node)? onNodeDoubleTap;

  /// 확장/축소 상태 변경 콜백 / Expand/collapse state change callback
  final Function(MindMapData node, bool isExpanded)? onNodeExpandChanged;

  /// 캔버스 크기 (null이면 자동 계산) / Canvas size (auto-calculated if null)
  final Size? canvasSize;

  /// 뷰어 설정 / Interactive viewer options
  final InteractiveViewerOptions? viewerOptions;

  /// 최소 캔버스 크기 / Minimum canvas size
  final Size minCanvasSize;

  /// 캔버스 여백 / Canvas padding
  final EdgeInsets canvasPadding;

  /// Optional key to capture the full mind map canvas (wraps canvas in RepaintBoundary) to give the user the ability to save the mind map as an image
  final GlobalKey? captureKey;

  /// Whether nodes should be collapsed by default (false = open all nodes)
  final bool isNodesCollapsed;

  /// Initial zoom scale for the mind map (1.0 = no zoom)
  final double initialScale;

  const MindMapWidget({
    super.key,
    required this.data,
    this.style = const MindMapStyle(),
    this.onNodeTap,
    this.onNodeLongPress,
    this.onNodeDoubleTap,
    this.onNodeExpandChanged,
    this.canvasSize,
    this.viewerOptions,
    this.minCanvasSize = const Size(1200, 800),
    this.canvasPadding = const EdgeInsets.all(300),
    this.isNodesCollapsed = false,
    this.initialScale = 1.0,
    this.captureKey,
  });

  @override
  State<MindMapWidget> createState() => _MindMapWidgetState();
}

/// 뷰어 옵션 설정 / Interactive viewer options
class InteractiveViewerOptions {
  final bool constrained;
  final EdgeInsets boundaryMargin;
  final double minScale;
  final double maxScale;
  final bool enablePanAndZoom;

  const InteractiveViewerOptions({
    this.constrained = false,
    this.boundaryMargin = const EdgeInsets.all(100),
    this.minScale = 0.1,
    this.maxScale = 3.0,
    this.enablePanAndZoom = true,
  });
}

class _MindMapWidgetState extends State<MindMapWidget>
    with TickerProviderStateMixin {
  // Controller to manage initial centering in InteractiveViewer
  late TransformationController _transformationController;
  late MindMapNode _rootNode;
  final List<AnimationController> _activeAnimations = [];
  String? _selectedNodeId;

  Size _actualCanvasSize = const Size(1200, 800);
  late Offset _rootPosition;

  @override
  void initState() {
    super.initState();
    // Initialize transformation controller for centering
    _transformationController = TransformationController();
    _initializeMindMap();
    _calculateCanvasAndLayout();
    // Center the root after first frame if pan/zoom is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.viewerOptions?.enablePanAndZoom ?? true)) {
        _centerView();
      }
    });
  }

  @override
  void didUpdateWidget(MindMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.style != widget.style ||
        oldWidget.isNodesCollapsed != widget.isNodesCollapsed ||
        oldWidget.initialScale != widget.initialScale) {
      _initializeMindMap();
      // Re-center after layout updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _calculateCanvasAndLayout();
          if ((widget.viewerOptions?.enablePanAndZoom ?? true)) {
            _centerView();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    for (var controller in _activeAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  /// 마인드맵 초기화 / Initialize mind map
  void _initializeMindMap() {
    _rootNode = MindMapNode.fromData(
      widget.data,
      0,
      defaultColors: widget.style.defaultNodeColors,
    );
    // apply default expansion/collapse to all nodes
    _applyInitialExpansion(_rootNode);
  }

  /// Recursively set each node's expanded state based on the isNodesCollapsed flag
  void _applyInitialExpansion(MindMapNode node) {
    node.isExpanded = !widget.isNodesCollapsed;
    for (var child in node.children) {
      _applyInitialExpansion(child);
    }
  }

  /// 캔버스 크기 계산 및 레이아웃 설정 / Calculate canvas size and layout
  void _calculateCanvasAndLayout() {
    if (!mounted) return;

    try {
      _actualCanvasSize = widget.canvasSize ?? widget.minCanvasSize;

      _calculateRootPosition();
      _calculateSubtreeHeights(_rootNode);
      _calculateSubtreeWidths(_rootNode);
      _assignPositions(_rootNode, 0);

      if (widget.canvasSize == null) {
        final requiredSize = _calculateRequiredCanvasSize();

        if (_actualCanvasSize != requiredSize) {
          _actualCanvasSize = requiredSize;
          _resetNodePositions(_rootNode);
          _calculateRootPosition();
          _calculateSubtreeHeights(_rootNode);
          _calculateSubtreeWidths(_rootNode);
          _assignPositions(_rootNode, 0);
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Layout calculation error: $e');
      _resetToBasicLayout();
    }
  }

  /// 노드 위치 초기화 / Reset node positions
  void _resetNodePositions(MindMapNode node, {Set<String>? visited}) {
    visited ??= <String>{};
    if (visited.contains(node.id)) return;
    visited.add(node.id);

    if (node != _rootNode) {
      node.hasFixedPosition = false;
    }

    for (var child in node.children) {
      _resetNodePositions(child, visited: Set.from(visited));
    }
  }

  /// 실제 필요한 캔버스 크기 계산 / Calculate required canvas size
  Size _calculateRequiredCanvasSize() {
    final allNodes = _collectAllVisibleNodes(_rootNode);

    if (allNodes.isEmpty) {
      return widget.minCanvasSize;
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    double maxNodeWidth = 0;
    double maxNodeHeight = 0;

    for (var node in allNodes) {
      final nodeSize = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );

      maxNodeWidth = math.max(maxNodeWidth, nodeSize.width);
      maxNodeHeight = math.max(maxNodeHeight, nodeSize.height);

      final nodeLeft = node.position.dx - nodeSize.width / 2;
      final nodeRight = node.position.dx + nodeSize.width / 2;
      final nodeTop = node.position.dy - nodeSize.height / 2;
      final nodeBottom = node.position.dy + nodeSize.height / 2;

      minX = math.min(minX, nodeLeft);
      maxX = math.max(maxX, nodeRight);
      minY = math.min(minY, nodeTop);
      maxY = math.max(maxY, nodeBottom);
    }

    final extraPaddingX = math.max(maxNodeWidth, 100.0);
    final extraPaddingY = math.max(maxNodeHeight, 100.0);

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;

    final totalPaddingX = widget.canvasPadding.horizontal + (extraPaddingX * 2);
    final totalPaddingY = widget.canvasPadding.vertical + (extraPaddingY * 2);

    final requiredWidth = contentWidth + totalPaddingX;
    final requiredHeight = contentHeight + totalPaddingY;

    final finalWidth = math.max(requiredWidth, widget.minCanvasSize.width);
    final finalHeight = math.max(requiredHeight, widget.minCanvasSize.height);

    return Size(finalWidth, finalHeight);
  }

  /// 모든 보이는 노드 수집 / Collect all visible nodes
  List<MindMapNode> _collectAllVisibleNodes(
    MindMapNode node, {
    Set<String>? visited,
  }) {
    visited ??= <String>{};
    if (visited.contains(node.id)) return [];
    visited.add(node.id);

    List<MindMapNode> nodes = [node];

    if (node.isExpanded) {
      for (var child in node.children) {
        nodes.addAll(
          _collectAllVisibleNodes(child, visited: Set.from(visited)),
        );
      }
    }

    return nodes;
  }

  /// 루트 노드 위치 계산 / Calculate root node position
  void _calculateRootPosition() {
    switch (widget.style.layout) {
      case MindMapLayout.right:
        _rootPosition = Offset(
          widget.canvasPadding.left + 100,
          _actualCanvasSize.height / 2,
        );
        break;
      case MindMapLayout.left:
        _rootPosition = Offset(
          _actualCanvasSize.width - widget.canvasPadding.right - 100,
          _actualCanvasSize.height / 2,
        );
        break;
      case MindMapLayout.top:
        _rootPosition = Offset(
          _actualCanvasSize.width / 2,
          _actualCanvasSize.height - widget.canvasPadding.bottom - 100,
        );
        break;
      case MindMapLayout.bottom:
        _rootPosition = Offset(
          _actualCanvasSize.width / 2,
          widget.canvasPadding.top + 100,
        );
        break;
      case MindMapLayout.radial:
      case MindMapLayout.horizontal:
      case MindMapLayout.vertical:
        _rootPosition = Offset(
          _actualCanvasSize.width / 2,
          _actualCanvasSize.height / 2,
        );
        break;
    }

    _rootNode.position = _rootPosition;
    _rootNode.targetPosition = _rootPosition;
    _rootNode.hasFixedPosition = true;
  }

  /// 기본 레이아웃으로 복원 / Reset to basic layout
  void _resetToBasicLayout() {
    _rootNode.position = _rootPosition;
    _rootNode.targetPosition = _rootPosition;
    if (mounted) {
      setState(() {});
    }
  }

  /// 서브트리 높이 계산 / Calculate subtree heights
  double _calculateSubtreeHeights(MindMapNode node, {Set<String>? visited}) {
    visited ??= <String>{};

    if (visited.contains(node.id)) {
      final nodeSize = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );
      return nodeSize.height + widget.style.nodeMargin;
    }
    visited.add(node.id);

    if (node.children.isEmpty) {
      final nodeSize = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );
      node.subtreeHeight = nodeSize.height + widget.style.nodeMargin;
      return node.subtreeHeight;
    }

    double totalChildHeight = 0;
    for (var child in node.children) {
      totalChildHeight += _calculateSubtreeHeights(
        child,
        visited: Set.from(visited),
      );
    }

    final nodeSize = widget.style.getActualNodeSize(
      node.title,
      node.level,
      customSize: node.size,
      customTextStyle: node.textStyle,
    );

    final additionalMargin = nodeSize.height * 0.3;

    node.subtreeHeight = math.max(
      totalChildHeight,
      nodeSize.height + widget.style.nodeMargin + additionalMargin,
    );

    return node.subtreeHeight;
  }

  /// 서브트리 너비 계산 / Calculate subtree widths
  double _calculateSubtreeWidths(MindMapNode node, {Set<String>? visited}) {
    visited ??= <String>{};

    if (visited.contains(node.id)) {
      final nodeSize = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );
      return nodeSize.width + widget.style.nodeMargin;
    }
    visited.add(node.id);

    if (node.children.isEmpty) {
      final nodeSize = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );
      node.subtreeWidth = nodeSize.width + widget.style.nodeMargin;
      return node.subtreeWidth;
    }

    double totalChildWidth = 0;
    for (var child in node.children) {
      totalChildWidth += _calculateSubtreeWidths(
        child,
        visited: Set.from(visited),
      );
    }

    final nodeSize = widget.style.getActualNodeSize(
      node.title,
      node.level,
      customSize: node.size,
      customTextStyle: node.textStyle,
    );

    final additionalMargin = nodeSize.width * 0.3;

    node.subtreeWidth = math.max(
      totalChildWidth,
      nodeSize.width + widget.style.nodeMargin + additionalMargin,
    );

    return node.subtreeWidth;
  }

  /// 노드 위치 할당 / Assign node positions
  void _assignPositions(MindMapNode parent, int level, {Set<String>? visited}) {
    visited ??= <String>{};

    if (visited.contains(parent.id) || parent.children.isEmpty) return;
    visited.add(parent.id);

    if (parent.parentDirection != null && level > 1) {
      switch (parent.parentDirection) {
        case 'top':
          _assignTopLayout(parent, level);
          break;
        case 'bottom':
          _assignBottomLayout(parent, level);
          break;
        case 'left':
          _assignLeftLayout(parent, level);
          break;
        case 'right':
          _assignRightLayout(parent, level);
          break;
        default:
          _assignLayoutByType(parent, level);
      }
    } else {
      _assignLayoutByType(parent, level);
    }

    for (var child in parent.children) {
      _assignPositions(child, level + 1, visited: Set.from(visited));
    }
  }

  /// 레이아웃 타입에 따른 위치 할당 / Assign layout by type
  void _assignLayoutByType(MindMapNode parent, int level) {
    switch (widget.style.layout) {
      case MindMapLayout.right:
        _assignRightLayout(parent, level);
        break;
      case MindMapLayout.left:
        _assignLeftLayout(parent, level);
        break;
      case MindMapLayout.top:
        _assignTopLayout(parent, level);
        break;
      case MindMapLayout.bottom:
        _assignBottomLayout(parent, level);
        break;
      case MindMapLayout.radial:
        _assignRadialLayout(parent, level);
        break;
      case MindMapLayout.horizontal:
        _assignHorizontalLayout(parent, level);
        break;
      case MindMapLayout.vertical:
        _assignVerticalLayout(parent, level);
        break;
    }
  }

  /// 동적 레벨 간격 계산 / Calculate dynamic level spacing
  double _calculateDynamicSpacing(MindMapNode parent, int level) {
    final parentSize = widget.style.getActualNodeSize(
      parent.title,
      parent.level,
      customSize: parent.size,
      customTextStyle: parent.textStyle,
    );

    double maxChildSize = 0;
    for (var child in parent.children) {
      final childSize = widget.style.getActualNodeSize(
        child.title,
        child.level,
        customSize: child.size,
        customTextStyle: child.textStyle,
      );
      maxChildSize = math.max(
        maxChildSize,
        math.max(childSize.width, childSize.height),
      );
    }

    final baseSpacing = widget.style.levelSpacing;
    final parentMaxSize = math.max(parentSize.width, parentSize.height);
    final additionalSpacing = (parentMaxSize + maxChildSize) / 2 + 40;

    return math.max(baseSpacing, additionalSpacing + 80);
  }

  /// 오른쪽 방향 레이아웃 / Right direction layout
  void _assignRightLayout(MindMapNode parent, int level) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final x = parent.targetPosition.dx + dynamicSpacing;
    double totalHeight = parent.children.fold(
      0.0,
      (sum, child) => sum + child.subtreeHeight,
    );
    double currentY = parent.targetPosition.dy - totalHeight / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterY = currentY + child.subtreeHeight / 2;
        child.targetPosition = Offset(x, childCenterY);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'right';
      }
      currentY += child.subtreeHeight;
    }
  }

  /// 왼쪽 방향 레이아웃 / Left direction layout
  void _assignLeftLayout(MindMapNode parent, int level) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final x = parent.targetPosition.dx - dynamicSpacing;
    double totalHeight = parent.children.fold(
      0.0,
      (sum, child) => sum + child.subtreeHeight,
    );
    double currentY = parent.targetPosition.dy - totalHeight / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterY = currentY + child.subtreeHeight / 2;
        child.targetPosition = Offset(x, childCenterY);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'left';
      }
      currentY += child.subtreeHeight;
    }
  }

  /// 위쪽 방향 레이아웃 / Top direction layout
  void _assignTopLayout(MindMapNode parent, int level) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final y = parent.targetPosition.dy - dynamicSpacing;
    double totalWidth = parent.children.fold(
      0.0,
      (sum, child) => sum + child.subtreeWidth,
    );
    double currentX = parent.targetPosition.dx - totalWidth / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterX = currentX + child.subtreeWidth / 2;
        child.targetPosition = Offset(childCenterX, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'top';
      }
      currentX += child.subtreeWidth;
    }
  }

  /// 아래쪽 방향 레이아웃 / Bottom direction layout
  void _assignBottomLayout(MindMapNode parent, int level) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final y = parent.targetPosition.dy + dynamicSpacing;
    double totalWidth = parent.children.fold(
      0.0,
      (sum, child) => sum + child.subtreeWidth,
    );
    double currentX = parent.targetPosition.dx - totalWidth / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterX = currentX + child.subtreeWidth / 2;
        child.targetPosition = Offset(childCenterX, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'bottom';
      }
      currentX += child.subtreeWidth;
    }
  }

  /// 원형 방향 레이아웃 / Radial layout
  void _assignRadialLayout(MindMapNode parent, int level) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final radius = dynamicSpacing * 0.8;
    final angleStep = (2 * math.pi) / parent.children.length;

    for (int i = 0; i < parent.children.length; i++) {
      final child = parent.children[i];
      if (!child.hasFixedPosition) {
        final angle = i * angleStep;
        final x = parent.targetPosition.dx + radius * math.cos(angle);
        final y = parent.targetPosition.dy + radius * math.sin(angle);
        child.targetPosition = Offset(x, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
      }
    }
  }

  /// 수평 방향 레이아웃 (좌우로 분할) / Horizontal layout (split left-right)
  void _assignHorizontalLayout(MindMapNode parent, int level) {
    if (level == 0) {
      final leftChildren =
          parent.children.take((parent.children.length / 2).ceil()).toList();
      final rightChildren = parent.children.skip(leftChildren.length).toList();

      _assignChildrenToSide(leftChildren, parent, level, -1);
      for (var child in leftChildren) {
        child.parentDirection = 'left';
      }

      _assignChildrenToSide(rightChildren, parent, level, 1);
      for (var child in rightChildren) {
        child.parentDirection = 'right';
      }
    } else {
      if (parent.parentDirection == 'left') {
        _assignLeftLayout(parent, level);
      } else {
        _assignRightLayout(parent, level);
      }
    }
  }

  /// 수직 방향 레이아웃 (위아래로 분할) / Vertical layout (split top-bottom)
  void _assignVerticalLayout(MindMapNode parent, int level) {
    if (level == 0) {
      final topChildren =
          parent.children.take((parent.children.length / 2).ceil()).toList();
      final bottomChildren = parent.children.skip(topChildren.length).toList();

      _assignChildrenVertically(topChildren, parent, level, -1);
      for (var child in topChildren) {
        child.parentDirection = 'top';
      }

      _assignChildrenVertically(bottomChildren, parent, level, 1);
      for (var child in bottomChildren) {
        child.parentDirection = 'bottom';
      }
    } else {
      if (parent.parentDirection == 'top') {
        _assignTopLayout(parent, level);
      } else {
        _assignBottomLayout(parent, level);
      }
    }
  }

  /// 한쪽으로 자식 노드들 배치 / Assign children to one side
  void _assignChildrenToSide(
    List<MindMapNode> children,
    MindMapNode parent,
    int level,
    int direction,
  ) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final x = parent.targetPosition.dx + direction * dynamicSpacing;
    double totalHeight = children.fold(
      0.0,
      (sum, child) => sum + child.subtreeHeight,
    );
    double currentY = parent.targetPosition.dy - totalHeight / 2;

    for (var child in children) {
      if (!child.hasFixedPosition) {
        final childCenterY = currentY + child.subtreeHeight / 2;
        child.targetPosition = Offset(x, childCenterY);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
      }
      currentY += child.subtreeHeight;
    }
  }

  /// 위아래로 자식 노드들 배치 / Assign children vertically
  void _assignChildrenVertically(
    List<MindMapNode> children,
    MindMapNode parent,
    int level,
    int direction,
  ) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final y = parent.targetPosition.dy + direction * dynamicSpacing;
    double totalWidth = children.fold(
      0.0,
      (sum, child) => sum + child.subtreeWidth,
    );
    double currentX = parent.targetPosition.dx - totalWidth / 2;

    for (var child in children) {
      if (!child.hasFixedPosition) {
        final childCenterX = currentX + child.subtreeWidth / 2;
        child.targetPosition = Offset(childCenterX, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
      }
      currentX += child.subtreeWidth;
    }
  }

  /// 노드 토글 / Toggle node
  void _toggleNode(MindMapNode node) {
    if (node.children.isEmpty || !mounted) return;

    HapticFeedback.lightImpact();

    setState(() {
      node.isExpanded = !node.isExpanded;

      if (node.isExpanded) {
        try {
          _calculateCanvasAndLayout();

          for (var child in node.children) {
            child.position = node.position;
            child.isAnimating = true;
          }

          _animateChildren(node);
        } catch (e) {
          debugPrint('Toggle error: $e');
          node.isExpanded = false;
        }
      } else {
        _calculateCanvasAndLayout();
      }
    });

    final originalData = _findOriginalData(node.id);
    if (originalData != null) {
      widget.onNodeExpandChanged?.call(originalData, node.isExpanded);
    }
  }

  /// 자식 노드 애니메이션 / Animate children nodes
  void _animateChildren(MindMapNode node) {
    if (!mounted || node.children.isEmpty) return;

    final controller = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );

    _activeAnimations.add(controller);

    final animation = CurvedAnimation(
      parent: controller,
      curve: widget.style.animationCurve,
    );

    final startPositions = <String, Offset>{};
    for (var child in node.children) {
      startPositions[child.id] = child.position;
    }

    controller.addListener(() {
      if (!mounted) return;

      final progress = animation.value;

      try {
        for (var child in node.children) {
          if (child.isAnimating) {
            final startPos = startPositions[child.id];
            if (startPos != null) {
              child.position =
                  Offset.lerp(startPos, child.targetPosition, progress)!;
            }
          }
        }

        if (progress >= 1.0) {
          for (var child in node.children) {
            child.isAnimating = false;
            child.position = child.targetPosition;
          }
          _activeAnimations.remove(controller);
          controller.dispose();
        }

        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        debugPrint('Animation error: $e');
        for (var child in node.children) {
          child.isAnimating = false;
          child.position = child.targetPosition;
        }
        _activeAnimations.remove(controller);
        controller.dispose();
      }
    });

    controller.forward().catchError((error) {
      debugPrint('Animation start error: $error');
      _activeAnimations.remove(controller);
      controller.dispose();
    });
  }

  /// 노드 선택 / Select node
  void _selectNode(MindMapNode node) {
    setState(() {
      _selectedNodeId = node.id;
    });

    final originalData = _findOriginalData(node.id);
    if (originalData != null) {
      widget.onNodeTap?.call(originalData);
    }
  }

  /// 원본 데이터 찾기 / Find original data
  MindMapData? _findOriginalData(String nodeId) {
    return _searchData(widget.data, nodeId);
  }

  MindMapData? _searchData(MindMapData data, String targetId) {
    if (data.id == targetId) return data;

    for (var child in data.children) {
      final result = _searchData(child, targetId);
      if (result != null) return result;
    }

    return null;
  }

  /// Centers the InteractiveViewer so the root node appears in the viewport center at the given scale.
  void _centerView() {
    final Size screenSize = MediaQuery.of(context).size;
    final double scale = widget.initialScale;
    // compute translation so that rootPosition maps to screen center at the given scale
    final double tx = screenSize.width / 2 - (_rootPosition.dx * scale);
    final double ty = screenSize.height / 2 - (_rootPosition.dy * scale);
    _transformationController.value =
        Matrix4.identity()
          ..translate(tx, ty)
          ..scale(scale);
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize =
        widget.canvasSize ??
        Size(_actualCanvasSize.width, _actualCanvasSize.height);
    final viewerOptions =
        widget.viewerOptions ?? const InteractiveViewerOptions();

    // Wrap the full canvas in a RepaintBoundary if a captureKey is provided
    final mindMapContent =
        (widget.captureKey != null)
            ? RepaintBoundary(
              key: widget.captureKey,
              child: Container(
                width: canvasSize.width,
                height: canvasSize.height,
                color: widget.style.backgroundColor,
                child: CustomPaint(
                  painter: MindMapPainter(_rootNode, widget.style),
                  child: Stack(children: _buildAllNodes(_rootNode)),
                ),
              ),
            )
            : Container(
              width: _actualCanvasSize.width,
              height: _actualCanvasSize.height,
              color: widget.style.backgroundColor,
              child: CustomPaint(
                painter: MindMapPainter(_rootNode, widget.style),
                child: Stack(children: _buildAllNodes(_rootNode)),
              ),
            );

    if (viewerOptions.enablePanAndZoom) {
      return InteractiveViewer(
        // Disable clipping so we can capture the full mind map
        clipBehavior: Clip.none,
        transformationController: _transformationController,
        constrained: viewerOptions.constrained,
        boundaryMargin: viewerOptions.boundaryMargin,
        minScale: viewerOptions.minScale,
        maxScale: viewerOptions.maxScale,
        child: mindMapContent,
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: mindMapContent,
        ),
      );
    }
  }

  /// 모든 노드 위젯 빌드 / Build all node widgets
  List<Widget> _buildAllNodes(MindMapNode node, {Set<String>? visited}) {
    visited ??= <String>{};

    if (visited.contains(node.id)) return [];
    visited.add(node.id);

    List<Widget> widgets = [];
    widgets.add(_buildNodeWidget(node));

    if (node.isExpanded && node.children.isNotEmpty) {
      for (var child in node.children) {
        widgets.addAll(_buildAllNodes(child, visited: Set.from(visited)));
      }
    }

    return widgets;
  }

  /// 개별 노드 위젯 빌드 / Build individual node widget
  Widget _buildNodeWidget(MindMapNode node) {
    final isSelected = _selectedNodeId == node.id;

    final actualSize = widget.style.getActualNodeSize(
      node.title,
      node.level,
      customSize: node.size,
      customTextStyle: node.textStyle,
    );
    final textSize = widget.style.getTextSize(node.level);

    final nodeColor = node.color;
    final textColor = node.textColor ?? widget.style.defaultTextStyle.color;
    final borderColor =
        node.borderColor ??
        (isSelected ? widget.style.selectionBorderColor : Colors.white);

    return Positioned(
      key: ValueKey('positioned_${node.id}'),
      left: node.position.dx - actualSize.width / 2,
      top: node.position.dy - actualSize.height / 2,
      child: GestureDetector(
        onTap: () {
          if (node.hasChildren) {
            _toggleNode(node);
          } else {
            _selectNode(node);
          }
        },
        onLongPress: () {
          final originalData = _findOriginalData(node.id);
          if (originalData != null) {
            widget.onNodeLongPress?.call(originalData);
          }
        },
        onDoubleTap: () {
          final originalData = _findOriginalData(node.id);
          if (originalData != null) {
            widget.onNodeDoubleTap?.call(originalData);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: actualSize.width,
          height: actualSize.height,
          child: CustomPaint(
            painter: _NodeWidgetPainter(
              shape: widget.style.nodeShape,
              fillColor: nodeColor,
              borderColor: borderColor,
              borderWidth: isSelected ? widget.style.selectionBorderWidth : 2.0,
              shadowEnabled: widget.style.enableNodeShadow,
              shadowColor: widget.style.nodeShadowColor,
              shadowBlurRadius: widget.style.nodeShadowBlurRadius,
              shadowSpreadRadius: widget.style.nodeShadowSpreadRadius,
              shadowOffset: widget.style.nodeShadowOffset,
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: widget.style.textPadding,
                    child: Text(
                      node.title,
                      textAlign: TextAlign.center,
                      style: (node.textStyle ?? widget.style.defaultTextStyle)
                          .copyWith(color: textColor, fontSize: textSize),
                      maxLines: null,
                      softWrap: true,
                    ),
                  ),
                ),
                if (node.hasChildren)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        node.isExpanded ? Icons.remove : Icons.add,
                        size: 12,
                        color: nodeColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 노드 위젯을 그리는 커스텀 페인터 / Custom painter for node widgets
class _NodeWidgetPainter extends CustomPainter {
  final NodeShape shape;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final Offset shadowOffset;

  _NodeWidgetPainter({
    required this.shape,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowEnabled,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.shadowSpreadRadius,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final fillPaint =
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke;

    if (shadowEnabled) {
      final shadowPaint =
          Paint()
            ..color = shadowColor
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius)
            ..style = PaintingStyle.fill;

      final shadowRect = rect.shift(shadowOffset);
      NodePainter.paintNode(
        canvas: canvas,
        rect: shadowRect,
        shape: shape,
        fillPaint: shadowPaint,
      );
    }

    NodePainter.paintNode(
      canvas: canvas,
      rect: rect,
      shape: shape,
      fillPaint: fillPaint,
      borderPaint: borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
