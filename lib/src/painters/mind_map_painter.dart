import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/mind_map_node.dart';
import '../models/mind_map_style.dart';
import '../enums/mind_map_layout.dart';

/// 마인드맵 전체를 그리는 커스텀 페인터
class MindMapPainter extends CustomPainter {
  final MindMapNode rootNode;
  final MindMapStyle style;

  MindMapPainter(this.rootNode, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas, rootNode);
  }

  /// 연결선을 그리는 메소드
  void _drawConnections(Canvas canvas, MindMapNode node) {
    if (node.children.isEmpty) return;

    bool shouldShowChildren =
        node.isExpanded || node.children.any((child) => child.isAnimating);

    if (!shouldShowChildren) return;

    for (var child in node.children) {
      _drawConnection(canvas, node, child);
      _drawConnections(canvas, child);
    }
  }

  /// 두 노드 사이의 연결선을 그리는 메소드
  void _drawConnection(Canvas canvas, MindMapNode parent, MindMapNode child) {
    final paint =
        Paint()
          ..color = style.connectionColor.withValues(alpha: 0.6)
          ..strokeWidth = style.connectionWidth
          ..style = PaintingStyle.stroke;

    if (style.useCustomCurve) {
      _drawCurvedConnection(canvas, parent, child, paint);
    } else {
      _drawStraightConnection(canvas, parent, child, paint);
    }
  }

  /// 곡선 연결선 그리기
  void _drawCurvedConnection(
    Canvas canvas,
    MindMapNode parent,
    MindMapNode child,
    Paint paint,
  ) {
    final path = Path();

    // 레이아웃에 따라 연결점 계산
    final connectionPoints = _getConnectionPoints(parent, child);
    final startPoint = connectionPoints['start']!;
    final endPoint = connectionPoints['end']!;

    path.moveTo(startPoint.dx, startPoint.dy);

    // 레이아웃에 따른 제어점 계산
    final controlPoints = _getControlPoints(
      startPoint,
      endPoint,
      parent,
      child,
    );

    path.cubicTo(
      controlPoints['control1']!.dx,
      controlPoints['control1']!.dy,
      controlPoints['control2']!.dx,
      controlPoints['control2']!.dy,
      endPoint.dx,
      endPoint.dy,
    );

    canvas.drawPath(path, paint);
  }

  /// 직선 연결선 그리기
  void _drawStraightConnection(
    Canvas canvas,
    MindMapNode parent,
    MindMapNode child,
    Paint paint,
  ) {
    final connectionPoints = _getConnectionPoints(parent, child);
    final startPoint = connectionPoints['start']!;
    final endPoint = connectionPoints['end']!;

    canvas.drawLine(startPoint, endPoint, paint);
  }

  /// 레이아웃에 따른 연결점 계산
  Map<String, Offset> _getConnectionPoints(
    MindMapNode parent,
    MindMapNode child,
  ) {
    // 동적 크기 계산
    final parentSize = style.getActualNodeSize(
      parent.title,
      parent.level,
      customSize: parent.size,
      customTextStyle: parent.textStyle,
    );
    final childSize = style.getActualNodeSize(
      child.title,
      child.level,
      customSize: child.size,
      customTextStyle: child.textStyle,
    );

    Offset startPoint;
    Offset endPoint;

    // 분할 레이아웃에서는 자식의 parentDirection을 기준으로 연결점 계산
    if ((style.layout == MindMapLayout.horizontal ||
            style.layout == MindMapLayout.vertical) &&
        child.parentDirection != null) {
      switch (child.parentDirection) {
        case 'right':
          startPoint = Offset(
            parent.position.dx + parentSize.width / 2,
            parent.position.dy,
          );
          endPoint = Offset(
            child.position.dx - childSize.width / 2,
            child.position.dy,
          );
          break;
        case 'left':
          startPoint = Offset(
            parent.position.dx - parentSize.width / 2,
            parent.position.dy,
          );
          endPoint = Offset(
            child.position.dx + childSize.width / 2,
            child.position.dy,
          );
          break;
        case 'top':
          startPoint = Offset(
            parent.position.dx,
            parent.position.dy - parentSize.height / 2,
          );
          endPoint = Offset(
            child.position.dx,
            child.position.dy + childSize.height / 2,
          );
          break;
        case 'bottom':
          startPoint = Offset(
            parent.position.dx,
            parent.position.dy + parentSize.height / 2,
          );
          endPoint = Offset(
            child.position.dx,
            child.position.dy - childSize.height / 2,
          );
          break;
        default:
          // 기본값: 각도 기반 계산
          final angle = math.atan2(
            child.position.dy - parent.position.dy,
            child.position.dx - parent.position.dx,
          );
          startPoint = Offset(
            parent.position.dx + math.cos(angle) * parentSize.width / 2,
            parent.position.dy + math.sin(angle) * parentSize.height / 2,
          );
          endPoint = Offset(
            child.position.dx - math.cos(angle) * childSize.width / 2,
            child.position.dy - math.sin(angle) * childSize.height / 2,
          );
      }
    } else {
      // 기존 레이아웃별 로직
      switch (style.layout) {
        case MindMapLayout.right:
          startPoint = Offset(
            parent.position.dx + parentSize.width / 2,
            parent.position.dy,
          );
          endPoint = Offset(
            child.position.dx - childSize.width / 2,
            child.position.dy,
          );
          break;

        case MindMapLayout.left:
          startPoint = Offset(
            parent.position.dx - parentSize.width / 2,
            parent.position.dy,
          );
          endPoint = Offset(
            child.position.dx + childSize.width / 2,
            child.position.dy,
          );
          break;

        case MindMapLayout.top:
          startPoint = Offset(
            parent.position.dx,
            parent.position.dy - parentSize.height / 2,
          );
          endPoint = Offset(
            child.position.dx,
            child.position.dy + childSize.height / 2,
          );
          break;

        case MindMapLayout.bottom:
          startPoint = Offset(
            parent.position.dx,
            parent.position.dy + parentSize.height / 2,
          );
          endPoint = Offset(
            child.position.dx,
            child.position.dy - childSize.height / 2,
          );
          break;

        case MindMapLayout.radial:
        case MindMapLayout.horizontal:
        case MindMapLayout.vertical:
          // 각도 기반 연결점 계산
          final angle = math.atan2(
            child.position.dy - parent.position.dy,
            child.position.dx - parent.position.dx,
          );
          startPoint = Offset(
            parent.position.dx + math.cos(angle) * parentSize.width / 2,
            parent.position.dy + math.sin(angle) * parentSize.height / 2,
          );
          endPoint = Offset(
            child.position.dx - math.cos(angle) * childSize.width / 2,
            child.position.dy - math.sin(angle) * childSize.height / 2,
          );
          break;
      }
    }

    return {'start': startPoint, 'end': endPoint};
  }

  /// 베지어 곡선의 제어점 계산 / Calculate control points for Bezier curves
  Map<String, Offset> _getControlPoints(
    Offset start,
    Offset end,
    MindMapNode parent,
    MindMapNode child,
  ) {
    Offset control1, control2;

    // 노드 크기 고려 / Consider node sizes
    final parentSize = style.getActualNodeSize(
      parent.title,
      parent.level,
      customSize: parent.size,
      customTextStyle: parent.textStyle,
    );
    final childSize = style.getActualNodeSize(
      child.title,
      child.level,
      customSize: child.size,
      customTextStyle: child.textStyle,
    );

    // 노드 간 거리 계산 / Calculate distance between nodes
    final distance = math.sqrt(
      math.pow(end.dx - start.dx, 2) + math.pow(end.dy - start.dy, 2),
    );

    // 제어점 거리: 노드 크기와 거리에 비례하여 동적 계산 / Control point distance: dynamic calculation based on node size and distance
    final maxNodeSize = math.max(
      math.max(parentSize.width, parentSize.height),
      math.max(childSize.width, childSize.height),
    );
    final controlDistance = math.max(
      60.0,
      math.min(distance * 0.4, maxNodeSize + 60),
    );

    // 분할 레이아웃에서는 방향에 따라 제어점을 다르게 계산 / Calculate control points differently based on direction in split layouts
    final direction = _getConnectionDirection(start, end);

    switch (direction) {
      case 'right':
        control1 = Offset(start.dx + controlDistance, start.dy);
        control2 = Offset(end.dx - controlDistance, end.dy);
        break;
      case 'left':
        control1 = Offset(start.dx - controlDistance, start.dy);
        control2 = Offset(end.dx + controlDistance, end.dy);
        break;
      case 'top':
        control1 = Offset(start.dx, start.dy - controlDistance);
        control2 = Offset(end.dx, end.dy + controlDistance);
        break;
      case 'bottom':
        control1 = Offset(start.dx, start.dy + controlDistance);
        control2 = Offset(end.dx, end.dy - controlDistance);
        break;
      default:
        // 기본값: 거리 기반 제어점 / Default: distance-based control points
        final midX = (start.dx + end.dx) / 2;
        final midY = (start.dy + end.dy) / 2;
        final controlOffset = controlDistance * 0.6;
        control1 = Offset(
          midX + (start.dx - midX) * 0.5 + controlOffset,
          midY + (start.dy - midY) * 0.5,
        );
        control2 = Offset(
          midX + (end.dx - midX) * 0.5 - controlOffset,
          midY + (end.dy - midY) * 0.5,
        );
    }

    return {'control1': control1, 'control2': control2};
  }

  /// 연결 방향 결정 / Determine connection direction
  String _getConnectionDirection(Offset start, Offset end) {
    switch (style.layout) {
      case MindMapLayout.right:
        return 'right';
      case MindMapLayout.left:
        return 'left';
      case MindMapLayout.top:
        return 'top';
      case MindMapLayout.bottom:
        return 'bottom';
      case MindMapLayout.horizontal:
      case MindMapLayout.vertical:
      case MindMapLayout.radial:
        // 좌표 차이로 방향 판단 / Determine direction based on coordinate difference
        final dx = end.dx - start.dx;
        final dy = end.dy - start.dy;

        if (dx.abs() > dy.abs()) {
          return dx > 0 ? 'right' : 'left';
        } else {
          return dy > 0 ? 'bottom' : 'top';
        }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! MindMapPainter ||
        oldDelegate.rootNode != rootNode ||
        oldDelegate.style != style;
  }
}
