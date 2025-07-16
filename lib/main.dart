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
        customNodeBuilder: _getWidgetLevelNodeBuilder(_selectedNodeType),
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
      title: '마인드맵 데모',
      description: '다양한 노드 타입 비교',
      color: const Color(0xFF3B82F6),
      textColor: Colors.white,
      size: const Size(140, 80),
      children: [
        MindMapData(
          id: 'planning',
          title: '기획 단계',
          description: '프로젝트 기획',
          color: const Color(0xFF10B981),
          textColor: Colors.white,
          size: const Size(120, 70),
          customData: {'icon': '📝', 'priority': 'high'},
          children: [
            MindMapData(
              id: 'planning-1',
              title: '요구사항 분석',
              description: '사용자 니즈 파악',
              color: const Color(0xFF059669),
              textColor: Colors.white,
              size: const Size(100, 60),
              customData: {'icon': '🔍', 'department': 'PM'},
            ),
            MindMapData(
              id: 'planning-2',
              title: '기능 정의',
              description: '핵심 기능 설계',
              color: const Color(0xFF047857),
              textColor: Colors.white,
              size: const Size(100, 60),
              customData: {'icon': '⚙️', 'department': 'UX'},
            ),
          ],
        ),
        MindMapData(
          id: 'development',
          title: '개발 단계',
          description: '실제 구현',
          color: const Color(0xFFF59E0B),
          textColor: Colors.white,
          size: const Size(120, 70),
          customData: {'icon': '💻', 'priority': 'medium'},
          children: [
            MindMapData(
              id: 'development-1',
              title: '프론트엔드',
              description: '사용자 인터페이스',
              color: const Color(0xFFDC2626),
              textColor: Colors.white,
              size: const Size(100, 60),
              customData: {'icon': '🖥️', 'tech': 'Flutter'},
            ),
            MindMapData(
              id: 'development-2',
              title: '백엔드',
              description: '서버 로직',
              color: const Color(0xFF7C3AED),
              textColor: Colors.white,
              size: const Size(100, 60),
              customData: {'icon': '⚙️', 'tech': 'Node.js'},
            ),
          ],
        ),
        MindMapData(
          id: 'testing',
          title: '테스트 단계',
          description: '품질 보증',
          color: const Color(0xFF8B5CF6),
          textColor: Colors.white,
          size: const Size(120, 70),
          customData: {'icon': '🧪', 'priority': 'low'},
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
      // case NodeType.markmap:
      //   return MindMapStyle().getMarkmapStyle();
    }
  }

  // MARK: - 위젯 레벨 노드 빌더 (스타일과 독립적으로 사용)

  Widget Function(MindMapNode, bool, VoidCallback, VoidCallback, VoidCallback)?
  _getWidgetLevelNodeBuilder(NodeType type) {
    switch (type) {
      case NodeType.basic:
        return null; // 기본 노드는 스타일의 기본 빌더 사용
      case NodeType.custom:
        return _buildWidgetCustomNode;
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
      nodeBuilder: _buildCustomNode,
    );
  }

  // MARK: - 커스텀 노드 빌더 (아이콘 + 설명)

  Widget _buildCustomNode(
    MindMapNode node,
    bool isSelected,
    VoidCallback onTap,
    VoidCallback onLongPress,
    VoidCallback onDoubleTap,
  ) {
    final icon = node.customData?['icon'] as String? ?? '📋';

    final actualSize = MindMapStyle().getActualNodeSize(
      node.title,
      node.level,
      customSize: node.size,
      customTextStyle: node.textStyle,
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: actualSize.width,
        height: actualSize.height,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: node.borderColor ?? Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.yellow.withValues(alpha: .8),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              if (node.description != null) ...[
                Text(
                  node.description!,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        node.textColor?.withValues(alpha: .8) ?? Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              Text(
                node.title,
                style:
                    node.textStyle ??
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: node.textColor ?? Colors.white,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - 위젯 레벨 커스텀 노드 빌더 (카드 스타일)

  Widget _buildWidgetCustomNode(
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

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Container(
        width: actualSize.width,
        height: actualSize.height,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getPriorityColor(priority), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.yellow.withValues(alpha: .6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority).withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                node.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: node.textColor ?? Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
  custom('🎨', '커스텀 노드');

  const NodeType(this.icon, this.displayName);
  final String icon;
  final String displayName;
}
