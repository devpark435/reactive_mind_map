import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../models/mind_map_data.dart';
import '../models/mind_map_style.dart';
import '../models/mind_map_node.dart';
import '../enums/mind_map_layout.dart';
import '../enums/node_shape.dart';
import '../enums/camera_focus.dart';
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

  /// 카메라 포커스 옵션 / Camera focus option
  final CameraFocus cameraFocus;

  /// 포커스할 특정 노드 ID / Specific node ID to focus on
  final String? focusNodeId;

  /// 포커스 이동 애니메이션 지속시간 / Focus animation duration
  final Duration focusAnimation;

  /// 포커스할 때의 여백 / Margin when focusing
  final EdgeInsets focusMargin;

  /// 노드 확장 시 카메라 동작 / Camera behavior when expanding nodes
  final NodeExpandCameraBehavior nodeExpandCameraBehavior;

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
    this.cameraFocus = CameraFocus.rootNode,
    this.focusNodeId,
    this.focusAnimation = const Duration(milliseconds: 300),
    this.focusMargin = const EdgeInsets.all(20),
    this.nodeExpandCameraBehavior = NodeExpandCameraBehavior.none,
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

  bool _isTogglingNode = false;

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

    // 데이터나 스타일이 변경된 경우 전체 재계산 / If the data or style is changed, recalculate the entire layout
    if (oldWidget.data != widget.data ||
        oldWidget.style != widget.style ||
        oldWidget.isNodesCollapsed != widget.isNodesCollapsed ||
        oldWidget.initialScale != widget.initialScale) {
      _initializeMindMap();
      // 레이아웃 업데이트 후 다시 중앙 정렬 / Re-center after layout updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _calculateCanvasAndLayout();
          // 🎯 노드 토글로 인한 변경이 아닌 경우에만 자동 카메라 이동
          if ((widget.viewerOptions?.enablePanAndZoom ?? true) &&
              !_isTogglingNode) {
            _centerView();
          }
        }
      });
    }
    // 카메라 포커스만 변경된 경우 바로 포커스 이동 / If only the camera focus is changed, move the focus immediately
    else if (oldWidget.cameraFocus != widget.cameraFocus ||
        oldWidget.focusNodeId != widget.focusNodeId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (widget.viewerOptions?.enablePanAndZoom ?? true)) {
          _centerView();
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

      if (!_isTogglingNode) {
        _calculateRootPosition();
      }
      _calculateSubtreeHeights(_rootNode);
      _calculateSubtreeWidths(_rootNode);
      _assignPositions(_rootNode, 0);

      if (widget.canvasSize == null) {
        final requiredSize = _calculateRequiredCanvasSize();

        if (_actualCanvasSize != requiredSize) {
          _actualCanvasSize = requiredSize;
          _resetNodePositions(_rootNode);

          if (!_isTogglingNode) {
            _calculateRootPosition();
          }
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

    final collapsedNodes = _collectAllCollapsedNodes(_rootNode);
    if (collapsedNodes.isNotEmpty) {
      final estimatedBounds = _estimateCollapsedNodesBounds(collapsedNodes);
      if (estimatedBounds != null) {
        minX = math.min(minX, estimatedBounds.left);
        maxX = math.max(maxX, estimatedBounds.right);
        minY = math.min(minY, estimatedBounds.top);
        maxY = math.max(maxY, estimatedBounds.bottom);
      }
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

  /// 축소된 노드들 수집 / Collect all collapsed nodes
  List<MindMapNode> _collectAllCollapsedNodes(
    MindMapNode node, {
    Set<String>? visited,
  }) {
    visited ??= <String>{};
    if (visited.contains(node.id)) return [];
    visited.add(node.id);

    List<MindMapNode> collapsedNodes = [];

    if (!node.isExpanded && node.children.isNotEmpty) {
      collapsedNodes.add(node);
      // 축소된 노드의 모든 하위 노드들도 포함
      for (var child in node.children) {
        collapsedNodes.addAll(
          _collectAllNodes(child, visited: Set.from(visited)),
        );
      }
    } else if (node.isExpanded) {
      // 확장된 노드의 경우 자식들을 재귀적으로 확인
      for (var child in node.children) {
        collapsedNodes.addAll(
          _collectAllCollapsedNodes(child, visited: Set.from(visited)),
        );
      }
    }

    return collapsedNodes;
  }

  /// 모든 노드 수집 (확장 상태 무관) / Collect all nodes regardless of expansion state
  List<MindMapNode> _collectAllNodes(MindMapNode node, {Set<String>? visited}) {
    visited ??= <String>{};
    if (visited.contains(node.id)) return [];
    visited.add(node.id);

    List<MindMapNode> nodes = [node];

    for (var child in node.children) {
      nodes.addAll(_collectAllNodes(child, visited: Set.from(visited)));
    }

    return nodes;
  }

  /// 축소된 노드들의 예상 경계 계산 / Estimate bounds for collapsed nodes
  Rect? _estimateCollapsedNodesBounds(List<MindMapNode> collapsedNodes) {
    if (collapsedNodes.isEmpty) return null;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var node in collapsedNodes) {
      final nodeSize = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );

      // 축소된 노드의 현재 위치를 기준으로 예상 확장 영역 계산
      // 레이아웃에 따라 확장 방향 예측
      double expandedWidth = nodeSize.width;
      double expandedHeight = nodeSize.height;

      // 자식 노드 수를 고려한 예상 확장 크기
      if (node.children.isNotEmpty) {
        final childCount = node.children.length;
        final estimatedSpacing = widget.style.levelSpacing;

        switch (widget.style.layout) {
          case MindMapLayout.right:
          case MindMapLayout.left:
          case MindMapLayout.horizontal:
            expandedWidth += estimatedSpacing;
            expandedHeight +=
                childCount * (nodeSize.height + widget.style.nodeMargin);
            break;
          case MindMapLayout.top:
          case MindMapLayout.bottom:
          case MindMapLayout.vertical:
            expandedWidth +=
                childCount * (nodeSize.width + widget.style.nodeMargin);
            expandedHeight += estimatedSpacing;
            break;
          case MindMapLayout.radial:
            final radius = estimatedSpacing * 0.8;
            expandedWidth += radius * 2;
            expandedHeight += radius * 2;
            break;
        }
      }

      final nodeLeft = node.position.dx - expandedWidth / 2;
      final nodeRight = node.position.dx + expandedWidth / 2;
      final nodeTop = node.position.dy - expandedHeight / 2;
      final nodeBottom = node.position.dy + expandedHeight / 2;

      minX = math.min(minX, nodeLeft);
      maxX = math.max(maxX, nodeRight);
      minY = math.min(minY, nodeTop);
      maxY = math.max(maxY, nodeBottom);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
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

    final additionalMargin = nodeSize.height * 0.5;
    final minSpacing = widget.style.nodeMargin * 2;

    final childCountFactor = math.max(1.0, node.children.length * 0.2);
    final expandedMargin = additionalMargin * childCountFactor;

    node.subtreeHeight = math.max(
      totalChildHeight + minSpacing,
      nodeSize.height + widget.style.nodeMargin + expandedMargin,
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

    final additionalMargin = nodeSize.width * 0.5;
    final minSpacing = widget.style.nodeMargin * 2;

    final childCountFactor = math.max(1.0, node.children.length * 0.2);
    final expandedMargin = additionalMargin * childCountFactor;

    node.subtreeWidth = math.max(
      totalChildWidth + minSpacing,
      nodeSize.width + widget.style.nodeMargin + expandedMargin,
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

    final nodeBasedSpacing = (parentMaxSize + maxChildSize) / 2 + 60;
    final childCountFactor = math.max(1.0, parent.children.length * 0.15);
    final levelFactor = math.max(1.0, level * 0.1);

    final dynamicSpacing = nodeBasedSpacing * childCountFactor * levelFactor;
    final minSpacing = baseSpacing + 120;

    return math.max(minSpacing, dynamicSpacing);
  }

  /// 오른쪽 방향 레이아웃 / Right direction layout
  void _assignRightLayout(MindMapNode parent, int level) {
    final dynamicSpacing = _calculateDynamicSpacing(parent, level);
    final x = parent.targetPosition.dx + dynamicSpacing;
    double totalHeight = parent.children.fold(
      0.0,
      (sum, child) => sum + child.subtreeHeight,
    );

    // 자식 노드들 사이의 추가 간격 적용
    final childGap = _calculateChildGap(parent.children);
    totalHeight += childGap * (parent.children.length - 1);

    double currentY = parent.targetPosition.dy - totalHeight / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterY = currentY + child.subtreeHeight / 2;
        child.targetPosition = Offset(x, childCenterY);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'right';
      }
      currentY += child.subtreeHeight + childGap;
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

    // 자식 노드들 사이의 추가 간격 적용
    final childGap = _calculateChildGap(parent.children);
    totalHeight += childGap * (parent.children.length - 1);

    double currentY = parent.targetPosition.dy - totalHeight / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterY = currentY + child.subtreeHeight / 2;
        child.targetPosition = Offset(x, childCenterY);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'left';
      }
      currentY += child.subtreeHeight + childGap;
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

    // 자식 노드들 사이의 추가 간격 적용
    final childGap = _calculateChildGap(parent.children);
    totalWidth += childGap * (parent.children.length - 1);

    double currentX = parent.targetPosition.dx - totalWidth / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterX = currentX + child.subtreeWidth / 2;
        child.targetPosition = Offset(childCenterX, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'top';
      }
      currentX += child.subtreeWidth + childGap;
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

    // 자식 노드들 사이의 추가 간격 적용
    final childGap = _calculateChildGap(parent.children);
    totalWidth += childGap * (parent.children.length - 1);

    double currentX = parent.targetPosition.dx - totalWidth / 2;

    for (var child in parent.children) {
      if (!child.hasFixedPosition) {
        final childCenterX = currentX + child.subtreeWidth / 2;
        child.targetPosition = Offset(childCenterX, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
        child.parentDirection = 'bottom';
      }
      currentX += child.subtreeWidth + childGap;
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

    // 자식 노드들 사이의 추가 간격 적용
    final childGap = _calculateChildGap(children);
    totalHeight += childGap * (children.length - 1);

    double currentY = parent.targetPosition.dy - totalHeight / 2;

    for (var child in children) {
      if (!child.hasFixedPosition) {
        final childCenterY = currentY + child.subtreeHeight / 2;
        child.targetPosition = Offset(x, childCenterY);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
      }
      currentY += child.subtreeHeight + childGap;
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

    // 자식 노드들 사이의 추가 간격 적용
    final childGap = _calculateChildGap(children);
    totalWidth += childGap * (children.length - 1);

    double currentX = parent.targetPosition.dx - totalWidth / 2;

    for (var child in children) {
      if (!child.hasFixedPosition) {
        final childCenterX = currentX + child.subtreeWidth / 2;
        child.targetPosition = Offset(childCenterX, y);
        child.position = child.targetPosition;
        child.hasFixedPosition = true;
      }
      currentX += child.subtreeWidth + childGap;
    }
  }

  /// 자식 노드들 사이의 간격 계산 / Calculate gap between child nodes
  double _calculateChildGap(List<MindMapNode> children) {
    if (children.isEmpty) return 0.0;

    // 자식 노드들의 평균 크기 계산
    double avgNodeSize = 0.0;
    for (var child in children) {
      final childSize = widget.style.getActualNodeSize(
        child.title,
        child.level,
        customSize: child.size,
        customTextStyle: child.textStyle,
      );
      avgNodeSize += math.max(childSize.width, childSize.height);
    }
    avgNodeSize /= children.length;

    // 기본 간격 + 노드 크기 기반 간격
    final baseGap = widget.style.nodeMargin;
    final sizeBasedGap = avgNodeSize * 0.3;
    final childCountFactor = math.min(
      2.0,
      children.length * 0.1,
    ); // 자식이 많을수록 간격 증가 (최대 2배)

    return (baseGap + sizeBasedGap) * childCountFactor;
  }

  /// 노드 토글 / Toggle node
  void _toggleNode(MindMapNode node) {
    if (node.children.isEmpty || !mounted) return;

    HapticFeedback.lightImpact();

    // 🎯 노드 토글 상태 설정
    _isTogglingNode = true;

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
        _setAllDescendantsAnimating(node, true);
        _animateChildrenCollapse(node);
      }
    });

    // 🎯 노드 확장 시 카메라 동작 설정에 따라 처리
    _handleNodeExpandCamera(node);

    final originalData = _findOriginalData(node.id);
    if (originalData != null) {
      widget.onNodeExpandChanged?.call(originalData, node.isExpanded);
    }

    // 🎯 토글 완료 후 플래그 리셋 (다음 프레임에서)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isTogglingNode = false;
      }
    });
  }

  /// 노드 확장 시 카메라 동작 처리 / Handle camera behavior on node expand
  void _handleNodeExpandCamera(MindMapNode node) {
    if (!mounted || !(widget.viewerOptions?.enablePanAndZoom ?? true)) return;

    switch (widget.nodeExpandCameraBehavior) {
      case NodeExpandCameraBehavior.none:
        // 카메라 이동 없음
        break;

      case NodeExpandCameraBehavior.focusClickedNode:
        // 클릭한 노드로 포커스
        _focusOnNodeById(node.id);
        break;

      case NodeExpandCameraBehavior.fitExpandedChildren:
        // 새로 펼쳐진 자식 노드들만 보이도록 조정
        if (node.isExpanded && node.children.isNotEmpty) {
          _fitNodesToView(node.children);
        } else {
          _focusOnNodeById(node.id);
        }
        break;

      case NodeExpandCameraBehavior.fitExpandedSubtree:
        // 펼쳐진 전체 서브트리를 보이도록 조정
        _fitSubtreeToView(node);
        break;
    }
  }

  /// 노드 ID로 카메라 포커스 (기존 CameraFocus 시스템 활용)
  void _focusOnNodeById(String nodeId) {
    if (!mounted || !(widget.viewerOptions?.enablePanAndZoom ?? true)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _performCenterViewOnNode(nodeId);
    });
  }

  /// 특정 노드에 대한 중앙 정렬 수행 (기존 로직 재사용)
  void _performCenterViewOnNode(String nodeId) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    final Size viewportSize = renderBox.size;
    final double scale = _transformationController.value.getMaxScaleOnAxis();

    // 타겟 노드 찾기
    final targetNode = _findNodeById(_rootNode, nodeId);
    if (targetNode == null) return;

    final Offset targetPosition = targetNode.position;

    // 정확한 중앙 정렬 계산 (기존 로직과 동일)
    final double viewportCenterX = viewportSize.width / 2;
    final double viewportCenterY = viewportSize.height / 2;

    final double tx = viewportCenterX - (targetPosition.dx * scale);
    final double ty = viewportCenterY - (targetPosition.dy * scale);

    final newTransform =
        Matrix4.identity()
          ..translate(tx, ty)
          ..scale(scale);

    // 부드러운 애니메이션으로 이동 (기존 focusAnimation 지속시간 사용)
    _animateToTransform(newTransform);
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

  /// 카메라 포커스에 따라 InteractiveViewer 중앙 정렬 / Centers the InteractiveViewer based on the camera focus option.
  void _centerView() {
    // 다음 프레임에서 정확한 크기를 얻어 계산 / Get the exact size in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _performCenterView();
    });
  }

  /// 실제 중앙 정렬 수행 / Perform actual center alignment
  void _performCenterView() {
    // RenderBox에서 정확한 크기 획득 / Get the exact size from RenderBox
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    final Size viewportSize = renderBox.size;

    double scale = widget.initialScale;
    Offset targetPosition = _rootPosition;

    switch (widget.cameraFocus) {
      case CameraFocus.rootNode:
        targetPosition = _rootPosition;
        break;

      case CameraFocus.center:
        targetPosition = Offset(
          _actualCanvasSize.width / 2,
          _actualCanvasSize.height / 2,
        );
        break;

      case CameraFocus.fitAll:
        final bounds = _calculateAllNodesBounds();
        if (bounds != null) {
          final double scaleX =
              (viewportSize.width - widget.focusMargin.horizontal) /
              bounds.width;
          final double scaleY =
              (viewportSize.height - widget.focusMargin.vertical) /
              bounds.height;
          scale = math.min(scaleX, math.min(scaleY, widget.initialScale));
          scale = math.max(scale, widget.viewerOptions?.minScale ?? 0.1);

          targetPosition = Offset(
            bounds.left + bounds.width / 2,
            bounds.top + bounds.height / 2,
          );
        }
        break;

      case CameraFocus.firstLeaf:
        final firstLeaf = _findFirstLeafNode(_rootNode);
        if (firstLeaf != null) {
          targetPosition = firstLeaf.position;
        }
        break;

      case CameraFocus.custom:
        if (widget.focusNodeId != null) {
          final targetNode = _findNodeById(_rootNode, widget.focusNodeId!);
          if (targetNode != null) {
            targetPosition = targetNode.position;
          }
        }
        break;
    }

    // 정확한 중앙 정렬 계산
    // 목표: targetPosition이 화면 중앙에 오도록 변환
    final double viewportCenterX = viewportSize.width / 2;
    final double viewportCenterY = viewportSize.height / 2;

    // 변환 공식: 화면중심 = (캔버스좌표 * 스케일) + 이동값
    // 따라서: 이동값 = 화면중심 - (캔버스좌표 * 스케일)
    final double tx = viewportCenterX - (targetPosition.dx * scale);
    final double ty = viewportCenterY - (targetPosition.dy * scale);

    final newTransform =
        Matrix4.identity()
          ..translate(tx, ty)
          ..scale(scale);

    // 애니메이션 또는 즉시 적용
    if (widget.focusAnimation.inMilliseconds > 0) {
      _animateToTransform(newTransform);
    } else {
      _transformationController.value = newTransform;
    }
  }

  /// 모든 노드의 경계 계산 / Calculate bounds of all nodes
  Rect? _calculateAllNodesBounds() {
    final allNodes = <MindMapNode>[];
    final allVisibleNodes = _collectAllVisibleNodes(_rootNode);
    allNodes.addAll(allVisibleNodes);

    if (allNodes.isEmpty) return null;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final node in allNodes) {
      final size = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );

      final left = node.position.dx - size.width / 2;
      final right = node.position.dx + size.width / 2;
      final top = node.position.dy - size.height / 2;
      final bottom = node.position.dy + size.height / 2;

      minX = math.min(minX, left);
      maxX = math.max(maxX, right);
      minY = math.min(minY, top);
      maxY = math.max(maxY, bottom);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// 첫 번째 리프 노드 찾기 / Find first leaf node
  MindMapNode? _findFirstLeafNode(MindMapNode node) {
    if (!node.hasChildren || !node.isExpanded) {
      return node;
    }

    for (final child in node.children) {
      final leaf = _findFirstLeafNode(child);
      if (leaf != null) return leaf;
    }

    return null;
  }

  /// ID로 노드 찾기 / Find node by ID
  MindMapNode? _findNodeById(MindMapNode node, String id) {
    if (node.id == id) return node;

    for (final child in node.children) {
      final found = _findNodeById(child, id);
      if (found != null) return found;
    }

    return null;
  }

  /// 트랜스폼을 애니메이션으로 적용 / Apply transform with animation
  void _animateToTransform(Matrix4 targetTransform) {
    final AnimationController animationController = AnimationController(
      duration: widget.focusAnimation,
      vsync: this,
    );

    final Animation<Matrix4> transformAnimation = Tween<Matrix4>(
      begin: _transformationController.value,
      end: targetTransform,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.addListener(() {
      _transformationController.value = transformAnimation.value;
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        animationController.dispose();
        _activeAnimations.remove(animationController);
      }
    });

    _activeAnimations.add(animationController);
    animationController.forward();
  }

  /// 특정 노드들이 모두 보이도록 카메라 조정 / Fit specific nodes to view
  void _fitNodesToView(List<MindMapNode> nodes) {
    if (nodes.isEmpty || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        return;
      }

      final Size viewportSize = renderBox.size;
      final bounds = _calculateNodesBounds(nodes);

      if (bounds == null) return;

      // 🎯 현재 스케일 유지 (확대/축소 없이 위치만 이동)
      final double currentScale =
          _transformationController.value.getMaxScaleOnAxis();

      // 중심점 계산
      final Offset centerPosition = Offset(
        bounds.left + bounds.width / 2,
        bounds.top + bounds.height / 2,
      );

      final double viewportCenterX = viewportSize.width / 2;
      final double viewportCenterY = viewportSize.height / 2;

      final double tx = viewportCenterX - (centerPosition.dx * currentScale);
      final double ty = viewportCenterY - (centerPosition.dy * currentScale);

      final newTransform =
          Matrix4.identity()
            ..translate(tx, ty)
            ..scale(currentScale);

      _animateToTransform(newTransform);
    });
  }

  /// 서브트리 전체가 보이도록 카메라 조정 / Fit entire subtree to view
  void _fitSubtreeToView(MindMapNode rootNode) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 서브트리의 모든 보이는 노드 수집
      final subtreeNodes = _collectAllVisibleNodes(rootNode);
      _fitNodesToView(subtreeNodes);
    });
  }

  /// 특정 노드들의 경계 계산 / Calculate bounds of specific nodes
  Rect? _calculateNodesBounds(List<MindMapNode> nodes) {
    if (nodes.isEmpty) return null;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final node in nodes) {
      final size = widget.style.getActualNodeSize(
        node.title,
        node.level,
        customSize: node.size,
        customTextStyle: node.textStyle,
      );

      final left = node.position.dx - size.width / 2;
      final right = node.position.dx + size.width / 2;
      final top = node.position.dy - size.height / 2;
      final bottom = node.position.dy + size.height / 2;

      minX = math.min(minX, left);
      maxX = math.max(maxX, right);
      minY = math.min(minY, top);
      maxY = math.max(maxY, bottom);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
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
