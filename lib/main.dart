import 'package:flutter/material.dart';
import 'package:reactive_mind_map/reactive_mind_map.dart';
import 'src/models/mind_map_node.dart';

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

  // 노드 타입 선택
  NodeType _selectedNodeType = NodeType.basic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reactive Mind Map Package'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          _buildLayoutMenu(),
          _buildNodeTypeMenu(),
          _buildShapeMenu(),
          _buildSettingsMenu(),
        ],
      ),
      body: MindMapWidget(
        data: _getUnifiedData(),
        style: _getStyleForNodeType(_selectedNodeType),
        onNodeTap: _handleNodeTap,
        onNodeLongPress: _handleNodeLongPress,
      ),
      floatingActionButton: _buildInfoButton(),
    );
  }

  // MARK: - 메뉴 빌더들

  Widget _buildLayoutMenu() {
    return PopupMenuButton<MindMapLayout>(
      icon: const Icon(Icons.view_quilt),
      tooltip: '레이아웃 변경',
      onSelected: (layout) => setState(() => _selectedLayout = layout),
      itemBuilder:
          (context) =>
              MindMapLayout.values.map((layout) {
                return PopupMenuItem(
                  value: layout,
                  child: Text(_getLayoutName(layout)),
                );
              }).toList(),
    );
  }

  Widget _buildNodeTypeMenu() {
    return PopupMenuButton<NodeType>(
      icon: const Icon(Icons.dashboard),
      tooltip: '노드 타입 선택',
      onSelected: (type) => setState(() => _selectedNodeType = type),
      itemBuilder:
          (context) =>
              NodeType.values.map((type) {
                return PopupMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
    );
  }

  Widget _buildShapeMenu() {
    return PopupMenuButton<NodeShape>(
      icon: const Icon(Icons.category),
      tooltip: '모양 변경',
      onSelected: (shape) => setState(() => _selectedShape = shape),
      itemBuilder:
          (context) =>
              NodeShape.values.map((shape) {
                return PopupMenuItem(
                  value: shape,
                  child: Text(_getShapeName(shape)),
                );
              }).toList(),
    );
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.tune),
      tooltip: '고급 설정',
      itemBuilder:
          (context) => [
            _buildSettingItem('animation', '빠른 애니메이션', _useCustomAnimation),
            _buildSettingItem('shadows', '노드 그림자', _showNodeShadows),
            _buildSettingItem('connections', '굵은 연결선', _useBoldConnections),
          ],
      onSelected: _handleSettingChange,
    );
  }

  PopupMenuItem<String> _buildSettingItem(
    String value,
    String title,
    bool isEnabled,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(isEnabled ? Icons.check_box : Icons.check_box_outline_blank),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildInfoButton() {
    return FloatingActionButton(
      onPressed: _showInfoDialog,
      child: const Icon(Icons.info),
    );
  }

  // MARK: - 통합 데이터 및 스타일

  MindMapData _getUnifiedData() {
    return MindMapData(
      id: 'root',
      title: '프로젝트 관리 시스템',
      description: '완전한 프로젝트 생명주기',
      color: const Color(0xFF3B82F6),
      textColor: Colors.white,
      size: const Size(160, 90),
      children: [
        MindMapData(
          id: 'planning',
          title: '기획 단계',
          description: '프로젝트 기획 및 설계',
          color: const Color(0xFF10B981),
          textColor: Colors.white,
          size: const Size(140, 80),
          customData: {'icon': '📝', 'priority': 'high'},
          children: [
            MindMapData(
              id: 'planning-1',
              title: '요구사항 분석',
              description: '사용자 니즈 파악 및 분석',
              color: const Color(0xFF059669),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🔍', 'department': 'PM'},
              children: [
                MindMapData(
                  id: 'planning-1-1',
                  title: '사용자 인터뷰',
                  description: '직접 사용자와의 면담',
                  color: const Color(0xFF047857),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '👥', 'method': 'interview'},
                ),
                MindMapData(
                  id: 'planning-1-2',
                  title: '시장 조사',
                  description: '경쟁사 및 시장 분석',
                  color: const Color(0xFF065F46),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '📊', 'method': 'research'},
                ),
              ],
            ),
            MindMapData(
              id: 'planning-2',
              title: '기능 정의',
              description: '핵심 기능 및 요구사항 정의',
              color: const Color(0xFF047857),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '⚙️', 'department': 'UX'},
              children: [
                MindMapData(
                  id: 'planning-2-1',
                  title: '사용자 스토리',
                  description: '사용자 관점의 기능 정의',
                  color: const Color(0xFF065F46),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '📖', 'type': 'story'},
                ),
                MindMapData(
                  id: 'planning-2-2',
                  title: '기능 명세서',
                  description: '상세한 기능 명세 작성',
                  color: const Color(0xFF064E3B),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '📋', 'type': 'spec'},
                ),
              ],
            ),
            MindMapData(
              id: 'planning-3',
              title: '아키텍처 설계',
              description: '시스템 아키텍처 설계',
              color: const Color(0xFF065F46),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🏗️', 'department': 'Architecture'},
            ),
          ],
        ),
        MindMapData(
          id: 'development',
          title: '개발 단계',
          description: '실제 코드 구현',
          color: const Color(0xFFF59E0B),
          textColor: Colors.white,
          size: const Size(140, 80),
          customData: {'icon': '💻', 'priority': 'medium'},
          children: [
            MindMapData(
              id: 'development-1',
              title: '프론트엔드',
              description: '사용자 인터페이스 개발',
              color: const Color(0xFFDC2626),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🖥️', 'tech': 'Flutter'},
              children: [
                MindMapData(
                  id: 'development-1-1',
                  title: 'UI 컴포넌트',
                  description: '재사용 가능한 UI 컴포넌트',
                  color: const Color(0xFFB91C1C),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '🧩', 'type': 'component'},
                ),
                MindMapData(
                  id: 'development-1-2',
                  title: '페이지 구현',
                  description: '각 페이지별 화면 구현',
                  color: const Color(0xFF991B1B),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '📄', 'type': 'page'},
                ),
                MindMapData(
                  id: 'development-1-3',
                  title: '상태 관리',
                  description: '애플리케이션 상태 관리',
                  color: const Color(0xFF7F1D1D),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '🔄', 'type': 'state'},
                ),
              ],
            ),
            MindMapData(
              id: 'development-2',
              title: '백엔드',
              description: '서버 로직 및 API 개발',
              color: const Color(0xFF7C3AED),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '⚙️', 'tech': 'Node.js'},
              children: [
                MindMapData(
                  id: 'development-2-1',
                  title: 'API 엔드포인트',
                  description: 'RESTful API 구현',
                  color: const Color(0xFF6D28D9),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '🔗', 'type': 'api'},
                ),
                MindMapData(
                  id: 'development-2-2',
                  title: '데이터베이스',
                  description: '데이터베이스 설계 및 구현',
                  color: const Color(0xFF5B21B6),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '🗄️', 'type': 'database'},
                ),
                MindMapData(
                  id: 'development-2-3',
                  title: '인증 시스템',
                  description: '사용자 인증 및 권한 관리',
                  color: const Color(0xFF4C1D95),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '🔐', 'type': 'auth'},
                ),
              ],
            ),
            MindMapData(
              id: 'development-3',
              title: 'DevOps',
              description: '배포 및 인프라 관리',
              color: const Color(0xFF059669),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🚀', 'tech': 'Docker'},
              children: [
                MindMapData(
                  id: 'development-3-1',
                  title: 'CI/CD 파이프라인',
                  description: '지속적 통합 및 배포',
                  color: const Color(0xFF047857),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '⚡', 'type': 'pipeline'},
                ),
                MindMapData(
                  id: 'development-3-2',
                  title: '모니터링',
                  description: '시스템 모니터링 및 로깅',
                  color: const Color(0xFF065F46),
                  textColor: Colors.white,
                  size: const Size(110, 60),
                  customData: {'icon': '📊', 'type': 'monitoring'},
                ),
              ],
            ),
          ],
        ),
        MindMapData(
          id: 'testing',
          title: '테스트 단계',
          description: '품질 보증 및 테스트',
          color: const Color(0xFF8B5CF6),
          textColor: Colors.white,
          size: const Size(140, 80),
          customData: {'icon': '🧪', 'priority': 'low'},
          children: [
            MindMapData(
              id: 'testing-1',
              title: '단위 테스트',
              description: '개별 컴포넌트 테스트',
              color: const Color(0xFF7C3AED),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🔬', 'type': 'unit'},
            ),
            MindMapData(
              id: 'testing-2',
              title: '통합 테스트',
              description: '시스템 통합 테스트',
              color: const Color(0xFF6D28D9),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🔗', 'type': 'integration'},
            ),
            MindMapData(
              id: 'testing-3',
              title: '사용자 테스트',
              description: '실제 사용자 환경 테스트',
              color: const Color(0xFF5B21B6),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '👥', 'type': 'user'},
            ),
          ],
        ),
        MindMapData(
          id: 'deployment',
          title: '배포 단계',
          description: '프로덕션 환경 배포',
          color: const Color(0xFFEF4444),
          textColor: Colors.white,
          size: const Size(140, 80),
          customData: {'icon': '🚀', 'priority': 'high'},
          children: [
            MindMapData(
              id: 'deployment-1',
              title: '스테이징 배포',
              description: '테스트 환경 배포',
              color: const Color(0xFFDC2626),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🧪', 'env': 'staging'},
            ),
            MindMapData(
              id: 'deployment-2',
              title: '프로덕션 배포',
              description: '실제 서비스 배포',
              color: const Color(0xFFB91C1C),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🌐', 'env': 'production'},
            ),
          ],
        ),
        MindMapData(
          id: 'maintenance',
          title: '유지보수',
          description: '지속적인 서비스 관리',
          color: const Color(0xFF6B7280),
          textColor: Colors.white,
          size: const Size(140, 80),
          customData: {'icon': '🔧', 'priority': 'medium'},
          children: [
            MindMapData(
              id: 'maintenance-1',
              title: '버그 수정',
              description: '발견된 문제점 수정',
              color: const Color(0xFF4B5563),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '🐛', 'type': 'bugfix'},
            ),
            MindMapData(
              id: 'maintenance-2',
              title: '성능 최적화',
              description: '시스템 성능 개선',
              color: const Color(0xFF374151),
              textColor: Colors.white,
              size: const Size(120, 70),
              customData: {'icon': '⚡', 'type': 'optimization'},
            ),
          ],
        ),
      ],
    );
  }

  MindMapStyle _getStyleForNodeType(NodeType type) {
    switch (type) {
      case NodeType.basic:
        return _getBasicStyle();
      case NodeType.custom:
        return _getCustomStyle();
    }
  }

  // MARK: - 스타일 정의

  MindMapStyle _getBasicStyle() {
    return MindMapStyle(
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
    );
  }

  MindMapStyle _getCustomStyle() {
    return MindMapStyle(
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
      nodeBuilder: _buildStyleLevelCustomNode, // 스타일 레벨에서 노드 빌더 설정
    );
  }

  // MARK: - 스타일 레벨 커스텀 노드 빌더 (스타일에 포함된 버전)
  Widget _buildStyleLevelCustomNode(
    MindMapNode node,
    bool isSelected,
    VoidCallback onTap,
    VoidCallback onLongPress,
    VoidCallback onDoubleTap,
  ) {
    final icon = node.customData?['icon'] as String? ?? '📋';
    final priority = node.customData?['priority'] as String? ?? 'medium';

    final actualSize = MindMapStyle().getActualNodeSize(
      node.title,
      node.level,
      customSize: node.size,
      customTextStyle: node.textStyle,
    );

    // 노드 크기에 따른 레이아웃 결정
    final isSmallNode = actualSize.width < 80 || actualSize.height < 50;
    final canShowPriority = !isSmallNode && actualSize.width >= 60;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: actualSize.width,
        height: actualSize.height,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: BorderRadius.circular(12), // 스타일 버전은 더 둥근 모서리
          border: Border.all(
            color: _getPriorityColor(priority),
            width: 2,
          ), // 더 얇은 테두리
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.yellow.withValues(alpha: .5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallNode ? 4.0 : 6.0), // 더 작은 패딩
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘과 우선순위 태그
                if (!isSmallNode) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 12),
                      ), // 더 작은 아이콘
                      if (canShowPriority) ...[
                        const SizedBox(width: 3),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                priority,
                              ).withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(priority),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                ] else ...[
                  Text(icon, style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 1),
                ],
                // 제목 텍스트
                Flexible(
                  child: Text(
                    node.title,
                    style: TextStyle(
                      fontSize: isSmallNode ? 8 : 10, // 더 작은 폰트
                      fontWeight: FontWeight.bold,
                      color: node.textColor ?? Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: isSmallNode ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - 헬퍼 메서드

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // MARK: - 이벤트 핸들러

  void _handleNodeTap(MindMapData node) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('탭: ${node.title.replaceAll('\n', ' ')}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleNodeLongPress(MindMapData node) {
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
                Text('설명: ${node.description ?? '없음'}'),
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
  }

  void _handleSettingChange(String value) {
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
  }

  void _showInfoDialog() {
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

// MARK: - 노드 타입 enum

enum NodeType {
  basic('🧠', '기본 노드'),
  custom('⚡', '위젯 커스텀');

  const NodeType(this.icon, this.displayName);
  final String icon;
  final String displayName;
}
