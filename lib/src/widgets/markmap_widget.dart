import 'package:flutter/material.dart';
import '../models/mind_map_data.dart';
import '../models/mind_map_style.dart';
import '../painters/markmap_painter.dart';

class MarkmapWidget extends StatefulWidget {
  final MindMapData data;
  final MindMapStyle style;
  final Function(MindMapData node)? onNodeTap;
  final Function(MindMapData node)? onNodeLongPress;

  const MarkmapWidget({
    super.key,
    required this.data,
    required this.style,
    this.onNodeTap,
    this.onNodeLongPress,
  });

  @override
  State<MarkmapWidget> createState() => _MarkmapWidgetState();
}

class _MarkmapWidgetState extends State<MarkmapWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String? _selectedNodeId;
  final Map<String, Offset> _nodePositions = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.style.animationCurve,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.style.backgroundColor,
      child: GestureDetector(
        onTapDown: (details) => _handleTap(details.localPosition),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: MarkmapPainter(
                data: widget.data,
                style: widget.style,
                animationValue: _animation.value,
                selectedNodeId: _selectedNodeId,
                onNodePositionCalculated: (nodeId, position) {
                  _nodePositions[nodeId] = position;
                },
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  void _handleTap(Offset tapPosition) {
    // 가장 가까운 노드 찾기
    String? tappedNodeId;
    double minDistance = double.infinity;

    _nodePositions.forEach((nodeId, position) {
      final distance = (tapPosition - position).distance;
      if (distance < 50 && distance < minDistance) {
        minDistance = distance;
        tappedNodeId = nodeId;
      }
    });

    if (tappedNodeId != null) {
      setState(() {
        _selectedNodeId = _selectedNodeId == tappedNodeId ? null : tappedNodeId;
      });

      // 노드 데이터 찾기 및 콜백 호출
      final tappedNode = _findNodeById(widget.data, tappedNodeId!);
      if (tappedNode != null && widget.onNodeTap != null) {
        widget.onNodeTap!(tappedNode);
      }
    }
  }

  MindMapData? _findNodeById(MindMapData node, String id) {
    if (node.id == id) return node;

    for (final child in node.children) {
      final result = _findNodeById(child, id);
      if (result != null) return result;
    }

    return null;
  }
}
