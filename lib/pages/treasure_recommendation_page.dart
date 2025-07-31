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

class _TreasureRecommendationPageState
    extends State<TreasureRecommendationPage> {
  final TreasureService _treasureService = TreasureService();
  final RestaurantService _restaurantService = RestaurantService();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
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
        };
      }).toList();

      // 모든 추천 데이터 합치기
      _recommendations = [
        ...restaurantRecommendations,
        ...treasureRecommendations
      ];

      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: '보물 추천',
      showScrollButtons: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  '카테고리별 보물을\n추천받아보세요!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: _recommendations.map((recommendation) {
                    return _RecommendationCard(
                      recommendation: recommendation,
                      onTap: () => _showRecommendationDetail(recommendation),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  void _showRecommendationDetail(Map<String, dynamic> recommendation) {
    // 상세 페이지로 이동
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recommendation['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recommendation['description']),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text('${recommendation['rating']}'),
                const SizedBox(width: 16),
                Text('${recommendation['reviewCount']} 리뷰'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> recommendation;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = recommendation['icon'] as IconData;
    final color = recommendation['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          const SizedBox(height: 6),
          Text(
            recommendation['title'],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              recommendation['description'],
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${recommendation['rating']}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: onTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
