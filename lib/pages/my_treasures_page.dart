import 'package:flutter/material.dart';
import '../services/treasure_service.dart';
import '../widgets/scrollable_page.dart';

class MyTreasuresPage extends StatefulWidget {
  final bool fromHome;
  const MyTreasuresPage({super.key, this.fromHome = false});

  @override
  State<MyTreasuresPage> createState() => _MyTreasuresPageState();
}

class _MyTreasuresPageState extends State<MyTreasuresPage>
    with TickerProviderStateMixin {
  final TreasureService _treasureService = TreasureService();
  List<Map<String, dynamic>> _allTreasures = [];
  List<Map<String, dynamic>> _filteredTreasures = [];
  bool _isLoading = true;
  String _selectedCategory = '전체';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = ['전체', '문화', '자연', '시장', '쇼핑', '기타'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadTreasures();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTreasures() async {
    try {
      // Load all treasures from TreasureService
      final treasures = _treasureService.getAllTreasures();

      // Convert Treasure objects to Map<String, dynamic> for display
      _allTreasures = treasures.map((treasure) {
        return {
          'id': treasure.id,
          'name': treasure.name,
          'description': treasure.description,
          'category': treasure.tags.isNotEmpty ? treasure.tags.first : '기타',
          'imageUrl': 'https://via.placeholder.com/150', // Placeholder image
          'rating': 4.0, // Dummy rating
          'points': 100, // Dummy points
          'type': 'cert', // Dummy type
          'typeText': '인증', // Dummy type text
          'location': treasure.address,
          'date': '2024-01-01',
          'icon': _getCategoryIcon(
              treasure.tags.isNotEmpty ? treasure.tags.first : '기타'),
          'color': _getCategoryColor(
              treasure.tags.isNotEmpty ? treasure.tags.first : '기타'),
        };
      }).toList();

      _filteredTreasures = List.from(_allTreasures);

      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('보물 데이터 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '문화':
        return Icons.museum;
      case '자연':
        return Icons.park;
      case '시장':
        return Icons.store;
      case '쇼핑':
        return Icons.shopping_bag;
      default:
        return Icons.star;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '문화':
        return Colors.purple;
      case '자연':
        return Colors.green;
      case '시장':
        return Colors.orange;
      case '쇼핑':
        return const Color(0xFF2563eb);
      default:
        return Colors.amber;
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == '전체') {
        _filteredTreasures = List.from(_allTreasures);
      } else {
        _filteredTreasures = _allTreasures
            .where((treasure) => treasure['category'] == category)
            .toList();
      }
    });
  }

  int get _totalPoints {
    return _allTreasures.fold(
        0, (sum, treasure) => sum + (treasure['points'] as int));
  }

  int get _totalTreasures => _allTreasures.length;

  Map<String, int> get _categoryStats {
    Map<String, int> stats = {};
    for (var treasure in _allTreasures) {
      String category = treasure['category'];
      stats[category] = (stats[category] ?? 0) + 1;
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: '내 보물',
      showScrollButtons: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 통계 대시보드
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2563eb).withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563eb),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '내 보물 컬렉션',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '총 $_totalTreasures개의 보물',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2563eb),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 통계 카드들
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: '총 포인트',
                                value: '$_totalPoints',
                                icon: Icons.stars,
                                color: const Color(0xFF2563eb),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: '카테고리',
                                value: '${_categoryStats.length}',
                                icon: Icons.category,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 카테고리 필터
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;

                        return Container(
                          margin: EdgeInsets.only(
                            right: index < _categories.length - 1 ? 8 : 0,
                          ),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) => _filterByCategory(category),
                            backgroundColor: Colors.grey.shade100,
                            selectedColor:
                                const Color(0xFF2563eb).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF2563eb)
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 보물 리스트
                  if (_filteredTreasures.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '해당 카테고리의 보물이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredTreasures.length,
                      itemBuilder: (context, index) {
                        return _TreasureCard(
                          treasure: _filteredTreasures[index],
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TreasureCard extends StatefulWidget {
  final Map<String, dynamic> treasure;

  const _TreasureCard({
    required this.treasure,
  });

  @override
  State<_TreasureCard> createState() => _TreasureCardState();
}

class _TreasureCardState extends State<_TreasureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treasure = widget.treasure;
    final icon = treasure['icon'] as IconData;
    final color = treasure['color'] as Color;
    final points = treasure['points'] as int;
    final rating = treasure['rating'] as double;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        // 보물 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _TreasureDetailPage(treasure: treasure),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 영역
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 40,
                          color: color,
                        ),
                      ),
                    ),
                  ),

                  // 내용 영역
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            treasure['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            treasure['category'],
                            style: TextStyle(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF2563eb).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$points점',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563eb),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TreasureDetailPage extends StatelessWidget {
  final Map<String, dynamic> treasure;

  const _TreasureDetailPage({
    required this.treasure,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(treasure['name']),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 보물 이미지
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: treasure['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  treasure['icon'],
                  size: 80,
                  color: treasure['color'],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 보물 정보
            Text(
              treasure['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              treasure['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // 상세 정보
            _DetailRow(
              icon: Icons.category,
              label: '카테고리',
              value: treasure['category'],
            ),
            _DetailRow(
              icon: Icons.location_on,
              label: '위치',
              value: treasure['location'],
            ),
            _DetailRow(
              icon: Icons.stars,
              label: '포인트',
              value: '${treasure['points']}점',
            ),
            _DetailRow(
              icon: Icons.star,
              label: '평점',
              value: '${treasure['rating']}',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2563eb),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
