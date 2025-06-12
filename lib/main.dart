import 'package:flutter/material.dart';
import 'package:reactive_mind_map/reactive_mind_map.dart';

import 'src/controllers/mind_map_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reactive Mind Map Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MindMapLayout _selectedLayout = MindMapLayout.right;
  NodeShape _selectedShape = NodeShape.roundedRectangle;
  bool _useCustomAnimation = false;
  bool _showNodeShadows = true;
  bool _useBoldConnections = false;

  // 풀 커스텀 테스트 데이터
  final _customTestData = MindMapData(
    id: 'root',
    title: '🚀 커스텀 마인드맵\n테스트',
    description: '풀 커스터마이징 루트 노드',
    color: const Color(0xFF1E40AF), // 진한 파란색
    textColor: Colors.white,
    borderColor: const Color(0xFFFFD700), // 금색 테두리
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
    size: const Size(140, 140), // 큰 루트 노드
    customData: {'priority': 'high', 'category': 'main', 'icon': '🚀'},
    children: [
      MindMapData(
        id: '1',
        title: '💡 혁신 아이디어',
        description: '창의적 솔루션들',
        color: const Color(0xFF7C3AED), // 보라색
        textColor: Colors.white,
        borderColor: const Color(0xFFFFFFFF),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
        size: const Size(110, 85),
        customData: {'priority': 'high', 'department': 'R&D'},
        children: [
          MindMapData(
            id: '1-1',
            title: '🔬 AI 기술',
            description: '인공지능 연구',
            color: const Color(0xFF06B6D4), // 시안색
            textColor: const Color(0xFF0F172A),
            borderColor: const Color(0xFF075985),
            size: const Size(95, 75),
            customData: {'tech_stack': 'Python, TensorFlow', 'budget': 50000},
            children: [
              MindMapData(
                id: '1-1-1',
                title: '🤖 머신러닝',
                description: 'ML 알고리즘',
                color: const Color(0xFF10B981), // 녹색
                textColor: Colors.white,
                size: const Size(80, 65),
              ),
              MindMapData(
                id: '1-1-2',
                title: '🧠 딥러닝',
                description: '신경망 구조',
                color: const Color(0xFFEF4444), // 빨간색
                textColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                size: const Size(85, 60),
                children: [
                  MindMapData(
                    id: '1-1-2-1',
                    title: '🕸️ CNN',
                    color: const Color(0xFFDC2626),
                    textColor: Colors.white,
                    size: const Size(70, 55),
                    children: [
                      MindMapData(
                        id: '1-1-2-1-1',
                        title: '🏗️ ResNet',
                        color: const Color(0xFF991B1B),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                      MindMapData(
                        id: '1-1-2-1-2',
                        title: '🔍 VGG',
                        color: const Color(0xFF7F1D1D),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-1-2-2',
                    title: '🎯 객체 탐지',
                    color: const Color(0xFF991B1B),
                    textColor: Colors.white,
                    size: const Size(60, 45),
                    children: [
                      MindMapData(
                        id: '1-1-2-2-1',
                        title: '⚡ YOLO',
                        color: const Color(0xFF7F1D1D),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                      MindMapData(
                        id: '1-1-2-2-2',
                        title: '🎪 R-CNN',
                        color: const Color(0xFF450A0A),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                    ],
                  ),
                ],
              ),
              MindMapData(
                id: '1-1-3',
                title: '📊 데이터 분석',
                description: '빅데이터 처리',
                color: const Color(0xFFF59E0B), // 주황색
                textColor: const Color(0xFF1F2937),
                borderColor: const Color(0xFFD97706),
                size: const Size(90, 70),
                children: [
                  MindMapData(
                    id: '1-1-3-1',
                    title: '🐼 Pandas',
                    color: const Color(0xFF059669),
                    textColor: Colors.white,
                    size: const Size(70, 55),
                    children: [
                      MindMapData(
                        id: '1-1-3-1-1',
                        title: '📋 DataFrame',
                        color: const Color(0xFF047857),
                        textColor: Colors.white,
                        size: const Size(60, 45),
                      ),
                      MindMapData(
                        id: '1-1-3-1-2',
                        title: '🔄 데이터 변환',
                        color: const Color(0xFF065F46),
                        textColor: Colors.white,
                        size: const Size(60, 45),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-1-3-2',
                    title: '📈 Matplotlib',
                    color: const Color(0xFF0891B2),
                    textColor: Colors.white,
                    size: const Size(70, 55),
                    children: [
                      MindMapData(
                        id: '1-1-3-2-1',
                        title: '📊 차트',
                        color: const Color(0xFF0E7490),
                        textColor: Colors.white,
                        size: const Size(60, 45),
                      ),
                      MindMapData(
                        id: '1-1-3-2-2',
                        title: '🎨 시각화',
                        color: const Color(0xFF155E75),
                        textColor: Colors.white,
                        size: const Size(60, 45),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-1-3-3',
                    title: '🔢 NumPy',
                    color: const Color(0xFF7C3AED),
                    textColor: Colors.white,
                    size: const Size(70, 55),
                    children: [
                      MindMapData(
                        id: '1-1-3-3-1',
                        title: '🧮 배열 연산',
                        color: const Color(0xFF6D28D9),
                        textColor: Colors.white,
                        size: const Size(60, 45),
                      ),
                      MindMapData(
                        id: '1-1-3-3-2',
                        title: '🔢 수학 함수',
                        color: const Color(0xFF5B21B6),
                        textColor: Colors.white,
                        size: const Size(60, 45),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          MindMapData(
            id: '1-2',
            title: '🌐 웹 개발',
            description: '프론트엔드/백엔드',
            color: const Color(0xFF8B5CF6), // 연보라색
            textColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            size: const Size(100, 80),
            children: [
              MindMapData(
                id: '1-2-1',
                title: '⚛️ React',
                description: 'UI 라이브러리',
                color: const Color(0xFF3B82F6), // 파란색
                textColor: Colors.white,
                size: const Size(75, 55),
                children: [
                  MindMapData(
                    id: '1-2-1-1',
                    title: '🪝 Hooks',
                    color: const Color(0xFF2563EB),
                    textColor: Colors.white,
                    size: const Size(65, 50),
                    children: [
                      MindMapData(
                        id: '1-2-1-1-1',
                        title: '🔄 useState',
                        color: const Color(0xFF1D4ED8),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                      MindMapData(
                        id: '1-2-1-1-2',
                        title: '⚡ useEffect',
                        color: const Color(0xFF1E40AF),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-2-1-2',
                    title: '🔄 Redux',
                    color: const Color(0xFF1D4ED8),
                    textColor: Colors.white,
                    size: const Size(65, 50),
                    children: [
                      MindMapData(
                        id: '1-2-1-2-1',
                        title: '🏪 Store',
                        color: const Color(0xFF1E40AF),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                      MindMapData(
                        id: '1-2-1-2-2',
                        title: '⚡ Actions',
                        color: const Color(0xFF1E3A8A),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-2-1-3',
                    title: '🎨 Styled Components',
                    color: const Color(0xFF1E40AF),
                    textColor: Colors.white,
                    size: const Size(65, 50),
                  ),
                ],
              ),
              MindMapData(
                id: '1-2-2',
                title: '🟢 Node.js',
                description: '백엔드 런타임',
                color: const Color(0xFF059669), // 진녹색
                textColor: Colors.white,
                size: const Size(80, 60),
                children: [
                  MindMapData(
                    id: '1-2-2-1',
                    title: '🚀 Express',
                    color: const Color(0xFF047857),
                    textColor: Colors.white,
                    size: const Size(65, 50),
                    children: [
                      MindMapData(
                        id: '1-2-2-1-1',
                        title: '🛣️ 라우팅',
                        color: const Color(0xFF065F46),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                      MindMapData(
                        id: '1-2-2-1-2',
                        title: '🔌 미들웨어',
                        color: const Color(0xFF064E3B),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-2-2-2',
                    title: '🍃 MongoDB',
                    color: const Color(0xFF065F46),
                    textColor: Colors.white,
                    size: const Size(65, 50),
                    children: [
                      MindMapData(
                        id: '1-2-2-2-1',
                        title: '📄 Document',
                        color: const Color(0xFF064E3B),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                      MindMapData(
                        id: '1-2-2-2-2',
                        title: '🔍 Query',
                        color: const Color(0xFF052E16),
                        textColor: Colors.white,
                        size: const Size(55, 40),
                      ),
                    ],
                  ),
                  MindMapData(
                    id: '1-2-2-3',
                    title: '🔐 JWT',
                    color: const Color(0xFF064E3B),
                    textColor: Colors.white,
                    size: const Size(65, 50),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      MindMapData(
        id: '2',
        title: '📈 마케팅 전략',
        description: '브랜드 홍보 방안',
        color: const Color(0xFFDC2626), // 빨간색
        textColor: Colors.white,
        borderColor: const Color(0xFFFEE2E2), // 연한 빨간색 테두리
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        size: const Size(120, 90),
        customData: {'priority': 'medium', 'budget': 30000},
        children: [
          MindMapData(
            id: '2-1',
            title: '📱 소셜미디어',
            description: 'SNS 마케팅',
            color: const Color(0xFFFF6B9D), // 핑크색
            textColor: Colors.white,
            size: const Size(105, 75),
            children: [
              MindMapData(
                id: '2-1-1',
                title: '📘 Facebook',
                description: '페이스북 광고',
                color: const Color(0xFF1877F2), // 페이스북 블루
                textColor: Colors.white,
                size: const Size(85, 65),
              ),
              MindMapData(
                id: '2-1-2',
                title: '📷 Instagram',
                description: '인스타그램 마케팅',
                color: const Color(0xFFE1306C), // 인스타그램 핑크
                textColor: Colors.white,
                size: const Size(90, 65),
              ),
            ],
          ),
        ],
      ),
      MindMapData(
        id: '3',
        title: '💰 비즈니스 모델',
        description: '수익 창출 방안',
        color: const Color(0xFF059669), // 녹색
        textColor: Colors.white,
        borderColor: const Color(0xFFFFD700), // 금색
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black26),
          ],
        ),
        size: const Size(130, 95),
        customData: {'priority': 'critical', 'roi_target': 200},
        children: [
          MindMapData(
            id: '3-1',
            title: '💳 구독 서비스',
            description: '월정액 모델',
            color: const Color(0xFF7C2D12), // 갈색
            textColor: const Color(0xFFFEF3C7),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            size: const Size(110, 80),
            children: [
              MindMapData(
                id: '3-1-1',
                title: '🥉 Basic',
                description: '기본 플랜',
                color: const Color(0xFF6B7280), // 회색
                textColor: Colors.white,
                size: const Size(80, 60),
              ),
              MindMapData(
                id: '3-1-2',
                title: '🥈 Pro',
                description: '프로 플랜',
                color: const Color(0xFF374151), // 진회색
                textColor: Colors.white,
                size: const Size(75, 60),
              ),
              MindMapData(
                id: '3-1-3',
                title: '🥇 Enterprise',
                description: '기업용 플랜',
                color: const Color(0xFF111827), // 거의 검정
                textColor: const Color(0xFFFFD700), // 금색 텍스트
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                size: const Size(95, 70),
              ),
            ],
          ),
        ],
      ),
      MindMapData(
        id: '4',
        title: '🎯 목표 달성',
        description: 'KPI 및 성과 지표',
        color: const Color(0xFFF59E0B), // 주황색
        textColor: const Color(0xFF1F2937), // 진한 회색 텍스트
        borderColor: const Color(0xFFDC2626),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
        size: const Size(125, 85),
        customData: {
          'priority': 'high',
          'deadline': '2024-12-31',
          'responsible': 'CEO',
        },
        children: [
          MindMapData(
            id: '4-1',
            title: '📊 매출 증대',
            description: '수익 향상',
            color: const Color(0xFF065F46), // 진녹색
            textColor: const Color(0xFFECFDF5),
            size: const Size(100, 75),
          ),
          MindMapData(
            id: '4-2',
            title: '👥 팀 확장',
            description: '인력 증원',
            color: const Color(0xFF7C3AED), // 보라색
            textColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            size: const Size(95, 70),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reactive Mind Map Package'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          PopupMenuButton<MindMapLayout>(
            icon: const Icon(Icons.view_quilt),
            tooltip: '레이아웃 변경',
            onSelected: (layout) {
              setState(() {
                _selectedLayout = layout;
              });
            },
            itemBuilder:
                (context) =>
                    MindMapLayout.values.map((layout) {
                      return PopupMenuItem(
                        value: layout,
                        child: Text(_getLayoutName(layout)),
                      );
                    }).toList(),
          ),
          PopupMenuButton<NodeShape>(
            icon: const Icon(Icons.category),
            tooltip: '모양 변경',
            onSelected: (shape) {
              setState(() {
                _selectedShape = shape;
              });
            },
            itemBuilder:
                (context) =>
                    NodeShape.values.map((shape) {
                      return PopupMenuItem(
                        value: shape,
                        child: Text(_getShapeName(shape)),
                      );
                    }).toList(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            tooltip: '고급 설정',
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'animation',
                    child: Row(
                      children: [
                        Icon(
                          _useCustomAnimation
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        const SizedBox(width: 8),
                        const Text('빠른 애니메이션'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'shadows',
                    child: Row(
                      children: [
                        Icon(
                          _showNodeShadows
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        const SizedBox(width: 8),
                        const Text('노드 그림자'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'connections',
                    child: Row(
                      children: [
                        Icon(
                          _useBoldConnections
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        const SizedBox(width: 8),
                        const Text('굵은 연결선'),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case 'animation':
                    _useCustomAnimation = !_useCustomAnimation;
                    break;
                  case 'shadows':
                    _showNodeShadows = !_showNodeShadows;
                    break;
                  case 'connections':
                    _useBoldConnections = !_useBoldConnections;
                    break;
                }
              });
            },
          ),
        ],
      ),
      body: MindMapWidget(
        controller: MindMapController(_customTestData),
        style: MindMapStyle(
          layout: _selectedLayout,
          nodeShape: _selectedShape,
          animationDuration:
              _useCustomAnimation
                  ? const Duration(milliseconds: 300)
                  : const Duration(milliseconds: 600),
          animationCurve:
              _useCustomAnimation ? Curves.easeInOut : Curves.easeOutCubic,
          enableNodeShadow: _showNodeShadows,
          nodeShadowColor: Colors.black.withValues(alpha: 0.3),
          nodeShadowBlurRadius: 8,
          nodeShadowSpreadRadius: 2,
          nodeShadowOffset: const Offset(2, 4),
          connectionWidth: _useBoldConnections ? 3.0 : 2.0,
          connectionColor:
              _useBoldConnections
                  ? Colors.black87
                  : Colors.grey.withValues(alpha: 0.6),
          useCustomCurve: true,
          backgroundColor: Colors.grey[50]!,
          levelSpacing: 160,
          nodeMargin: 15,
        ),
        onNodeTap: (node) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('탭: ${node.title.replaceAll('\n', ' ')}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onNodeLongPress: (node) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(node.title.replaceAll('\n', ' ')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${node.id}'),
                      const SizedBox(height: 8),
                      Text('설명: ${node.description}'),
                      const SizedBox(height: 8),
                      Text('자식 수: ${node.children.length}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Reactive Mind Map Package'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎨 완전한 커스터마이징'),
                      Text('🎯 다양한 레이아웃'),
                      Text('⚡ 부드러운 애니메이션'),
                      Text('🖱️ 풍부한 인터랙션'),
                      SizedBox(height: 16),
                      Text('상단 메뉴에서 레이아웃과 모양을 변경해보세요!'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('확인'),
                    ),
                  ],
                ),
          );
        },
        child: const Icon(Icons.info),
      ),
    );
  }

  String _getLayoutName(MindMapLayout layout) {
    switch (layout) {
      case MindMapLayout.right:
        return '오른쪽';
      case MindMapLayout.left:
        return '왼쪽';
      case MindMapLayout.top:
        return '위쪽';
      case MindMapLayout.bottom:
        return '아래쪽';
      case MindMapLayout.radial:
        return '원형';
      case MindMapLayout.horizontal:
        return '좌우 분할';
      case MindMapLayout.vertical:
        return '상하 분할';
    }
  }

  String _getShapeName(NodeShape shape) {
    switch (shape) {
      case NodeShape.roundedRectangle:
        return '둥근 사각형';
      case NodeShape.circle:
        return '원형';
      case NodeShape.rectangle:
        return '사각형';
      case NodeShape.diamond:
        return '다이아몬드';
      case NodeShape.hexagon:
        return '육각형';
      case NodeShape.ellipse:
        return '타원';
    }
  }
}
