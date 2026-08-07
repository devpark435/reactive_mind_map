import 'package:flutter/material.dart';

import 'mind_map_data.dart';

/// 내부 처리용 마인드맵 노드 클래스
class MindMapNode {
  /// 노드 ID
  final String id;

  /// 노드 제목
  final String title;

  /// 노드 설명
  final String description;

  /// 하위 노드들
  final List<MindMapNode> children;

  /// 확장 상태
  bool isExpanded;

  /// 현재 위치
  Offset position;

  /// 목표 위치
  Offset targetPosition;

  /// 노드 색상
  Color color;

  /// 텍스트 색상
  Color? textColor;

  /// 테두리 색상
  Color? borderColor;

  /// Aligning the text in each node, defualt to TextAlign.center
  TextAlign? textAlign;

  /// 텍스트 스타일
  TextStyle? textStyle;

  /// 노드 크기
  Size? size;

  /// 애니메이션 상태
  bool isAnimating;

  /// 고정 위치 여부
  bool hasFixedPosition;

  /// 서브트리 높이
  double subtreeHeight;

  /// 서브트리 너비 (상하 레이아웃용)
  double subtreeWidth;

  /// 최소 Y 좌표
  double minY;

  /// 최대 Y 좌표
  double maxY;

  /// 노드 레벨
  int level;

  /// 부모와의 방향 관계 (방향성 일관성을 위해)
  String? parentDirection;

  /// 사용자 정의 데이터
  final Map<String, dynamic>? customData;

  MindMapNode({
    required this.id,
    required this.title,
    required this.description,
    this.children = const [],
    this.isExpanded = false,
    this.position = Offset.zero,
    this.targetPosition = Offset.zero,
    this.color = Colors.blue,
    this.textColor,
    this.borderColor,
    this.textAlign,
    this.textStyle,
    this.size,
    this.isAnimating = false,
    this.hasFixedPosition = false,
    this.subtreeHeight = 0,
    this.subtreeWidth = 0,
    this.minY = 0,
    this.maxY = 0,
    this.level = 0,
    this.parentDirection,
    this.customData,
  });

  /// MindMapData로부터 MindMapNode를 생성하는 팩토리 메소드
  factory MindMapNode.fromData(
    MindMapData data,
    int level, {
    List<Color>? defaultColors,
  }) {
    final defaultNodeColors =
        defaultColors ??
        [
          const Color(0xFF2563EB),
          const Color(0xFF7C3AED),
          const Color(0xFF059669),
          const Color(0xFFDC2626),
          const Color(0xFFF59E0B),
          const Color(0xFF7C2D12),
          const Color(0xFF6B21A8),
          const Color(0xFF0EA5E9),
          const Color(0xFF10B981),
          const Color(0xFF8B5CF6),
          const Color(0xFF06B6D4),
          const Color(0xFFF97316),
        ];

    final children =
        data.children
            .map(
              (childData) => MindMapNode.fromData(
                childData,
                level + 1,
                defaultColors: defaultColors,
              ),
            )
            .toList();

    return MindMapNode(
      id: data.id,
      title: data.title,
      description: data.description,
      children: children,
      color: data.color ?? defaultNodeColors[level % defaultNodeColors.length],
      textColor: data.textColor,
      textAlign: data.textAlign,
      borderColor: data.borderColor,
      textStyle: data.textStyle,
      size: data.size,
      level: level,
      customData: data.customData,
    );
  }

  /// 노드의 실제 크기를 계산
  Size getActualSize(double defaultSize) {
    return size ?? Size(defaultSize, defaultSize);
  }

  /// 하위 노드가 있는지 확인
  bool get hasChildren => children.isNotEmpty;

  /// 리프 노드인지 확인
  bool get isLeaf => children.isEmpty;

  @override
  String toString() {
    return 'MindMapNode(id: $id, title: $title, level: $level, children: ${children.length})';
  }
}
