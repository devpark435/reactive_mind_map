import 'package:flutter/material.dart';

/// 마인드맵 노드 데이터를 나타내는 클래스
class MindMapData {
  /// 노드의 고유 식별자
  final String id;

  /// 노드의 제목
  final String title;

  /// Align text
  final TextAlign textAlign;

  /// 노드의 상세 설명
  final String description;

  /// 하위 노드들
  final List<MindMapData> children;

  /// 노드의 색상 (null이면 기본 색상 사용)
  final Color? color;

  /// 노드의 텍스트 색상 (null이면 기본 색상 사용)
  final Color? textColor;

  /// 노드의 테두리 색상 (null이면 기본 색상 사용)
  final Color? borderColor;

  /// 노드의 텍스트 스타일 (null이면 기본 스타일 사용)
  final TextStyle? textStyle;

  /// 노드의 크기 (null이면 레벨에 따른 기본 크기 사용)
  final Size? size;

  /// 사용자 정의 데이터
  final Map<String, dynamic>? customData;

  const MindMapData({
    required this.id,
    required this.title,
    this.description = '',
    this.children = const [],
    this.color,
    this.textColor,
    this.textAlign = TextAlign.center,
    this.borderColor,
    this.textStyle,
    this.size,
    this.customData,
  });

  /// 데이터 복사를 위한 copyWith 메소드
  MindMapData copyWith({
    String? id,
    String? title,
    String? description,
    List<MindMapData>? children,
    Color? color,
    Color? textColor,
    TextAlign? textAlign,
    Color? borderColor,
    TextStyle? textStyle,
    Size? size,
    Map<String, dynamic>? customData,
  }) {
    return MindMapData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      children: children ?? this.children,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      borderColor: borderColor ?? this.borderColor,
      textStyle: textStyle ?? this.textStyle,
      size: size ?? this.size,
      customData: customData ?? this.customData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MindMapData &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.children == children &&
        other.color == color &&
        other.textColor == textColor &&
        other.textAlign == textAlign &&
        other.borderColor == borderColor &&
        other.textStyle == textStyle &&
        other.size == size &&
        other.customData == customData;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      children,
      color,
      textColor,
      textAlign,
      borderColor,
      textStyle,
      size,
      customData,
    );
  }

  @override
  String toString() {
    return 'MindMapData(id: $id, title: $title, children: ${children.length})';
  }
}
