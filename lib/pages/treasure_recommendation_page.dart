import 'package:flutter/material.dart';
import '../services/treasure_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/scrollable_page.dart';

class TreasureRecommendationPage extends StatefulWidget {
  final bool fromHome;
  const TreasureRecommendationPage({super.key, this.fromHome = false});

  @override
  State<TreasureRecommendationPage> createState() =>
      _TreasureRecommendationPageState();
}

class _TreasureRecommendationPageState extends State<TreasureRecommendationPage>
    with TickerProviderStateMixin {
  final TreasureService _treasureService = TreasureService();
  final RestaurantService _restaurantService = RestaurantService();
  List<Map<String, dynamic>> _recommendations = [];
  List<Map<String, dynamic>> _filteredRecommendations = [];
  bool _isLoading = true;
  String _selectedCategory = '전체';
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = ['전체', '맛집', '문화', '자연', '시장', '쇼핑', '기타'];

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
    _loadRecommendations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    try {
      // 맛집 추천 데이터 로드
      final restaurants = await _restaurantService.getAllRestaurants();
      final restaurantRecommendations = restaurants.take(10).map((restaurant) {
        return {
          'id': restaurant.id,
          'title': restaurant.name,
          'description': restaurant.address,
          'category': restaurant.category,
          'rating': restaurant.rating,
          'reviewCount': restaurant.reviewCount,
          'type': 'restaurant',
          'icon': Icons.restaurant,
          'color': Colors.orange,
          'tags': restaurant.tags,
        };
      }).toList();

      // 보물 추천 데이터 로드
      final treasures = _treasureService.getAllTreasures();
      final treasureRecommendations = treasures.take(10).map((treasure) {
        return {
          'id': treasure.id,
          'title': treasure.name,
          'description': treasure.description,
          'category': treasure.tags.isNotEmpty ? treasure.tags.first : '기타',
          'rating': 4.5,
          'reviewCount': 50,
          'type': 'treasure',
          'icon': _getCategoryIcon(
              treasure.tags.isNotEmpty ? treasure.tags.first : '기타'),
          'color': _getCategoryColor(
              treasure.tags.isNotEmpty ? treasure.tags.first : '기타'),
          'tags': treasure.tags,
        };
      }).toList();

      // 모든 추천 데이터 합치기
      _recommendations = [
        ...restaurantRecommendations,
        ...treasureRecommendations
      ];
      _filteredRecommendations = List.from(_recommendations);

      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('추천 데이터 로드 실패: $e');
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
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredRecommendations = _recommendations.where((item) {
      // 카테고리 필터
      bool categoryMatch =
          _selectedCategory == '전체' || item['category'] == _selectedCategory;

      // 검색어 필터
      bool searchMatch = _searchQuery.isEmpty ||
          item['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['description']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: '보물 추천',
      showScrollButtons: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 섹션
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
                                Icons.recommend,
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
                                    '맞춤 추천',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_filteredRecommendations.length}개의 추천',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 검색바
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: '보물이나 맛집을 검색해보세요...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () => _onSearchChanged(''),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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

                  // 추천 리스트
                  if (_filteredRecommendations.isEmpty)
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
                            _searchQuery.isNotEmpty
                                ? '"$_searchQuery"에 대한 추천이 없습니다'
                                : '해당 카테고리의 추천이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredRecommendations.length,
                      itemBuilder: (context, index) {
                        return _RecommendationCard(
                          recommendation: _filteredRecommendations[index],
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  final Map<String, dynamic> recommendation;

  const _RecommendationCard({
    required this.recommendation,
  });

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard>
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
    final recommendation = widget.recommendation;
    final icon = recommendation['icon'] as IconData;
    final color = recommendation['color'] as Color;
    final rating = recommendation['rating'] as double;
    final reviewCount = recommendation['reviewCount'] as int;
    final type = recommendation['type'] as String;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        // 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _RecommendationDetailPage(
              recommendation: recommendation,
            ),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
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
              child: Row(
                children: [
                  // 이미지 영역
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
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

                  // 내용 영역
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  recommendation['category'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: type == 'restaurant'
                                      ? Colors.orange.withOpacity(0.1)
                                      : const Color(0xFF2563eb)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  type == 'restaurant' ? '맛집' : '보물',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: type == 'restaurant'
                                        ? Colors.orange
                                        : const Color(0xFF2563eb),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            recommendation['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($reviewCount)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade400,
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

class _RecommendationDetailPage extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const _RecommendationDetailPage({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final type = recommendation['type'] as String;
    final icon = recommendation['icon'] as IconData;
    final color = recommendation['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Text(recommendation['title']),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 이미지
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 80,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 제목 및 카테고리
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recommendation['category'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: type == 'restaurant'
                        ? Colors.orange.withOpacity(0.1)
                        : const Color(0xFF2563eb).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type == 'restaurant' ? '맛집' : '보물',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: type == 'restaurant'
                          ? Colors.orange
                          : const Color(0xFF2563eb),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 제목
            Text(
              recommendation['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 평점
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  recommendation['rating'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${recommendation['reviewCount']}개의 리뷰)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 설명
            Text(
              recommendation['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // 액션 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 지도에서 보기 또는 방문하기
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${recommendation['title']}로 이동합니다'),
                      backgroundColor: const Color(0xFF2563eb),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563eb),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  type == 'restaurant' ? '방문하기' : '지도에서 보기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
