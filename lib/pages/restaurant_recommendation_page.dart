import 'package:flutter/material.dart';
import '../services/restaurant_service_kakao.dart';
import '../services/restaurant_cache_service.dart';

class RestaurantRecommendationPage extends StatefulWidget {
  const RestaurantRecommendationPage({super.key});

  @override
  State<RestaurantRecommendationPage> createState() =>
      _RestaurantRecommendationPageState();
}

class _RestaurantRecommendationPageState
    extends State<RestaurantRecommendationPage> {
  String _selectedCategory = '전체';
  final List<String> _categories = [
    '전체',
    '한식',
    '중식',
    '일식',
    '양식',
    '카페',
    '치킨',
    '피자',
    '술집',
    '기타',
  ];

  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 캐시에서 먼저 로드 (API 호출 없음)
      final restaurants = await RestaurantCacheService().getCachedRestaurants();

      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });

      print('맛집 추천 페이지 로드 완료: ${restaurants.length}개');
    } catch (e) {
      print('맛집 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 카테고리별 맛집 필터링
  List<Restaurant> _getFilteredRestaurants() {
    if (_selectedCategory == '전체') {
      return _restaurants;
    }

    return _restaurants.where((restaurant) {
      // 카테고리 매핑 함수 사용
      final category = _getCategoryFromTypes(restaurant.types);
      return category == _selectedCategory;
    }).toList();
  }

  // 타입에서 카테고리 추출
  String _getCategoryFromTypes(List<String> types) {
    for (final type in types) {
      final lowerType = type.toLowerCase();

      // 한식 관련
      if (lowerType.contains('한식') ||
          lowerType.contains('한정식') ||
          lowerType.contains('삼겹살') ||
          lowerType.contains('갈비') ||
          lowerType.contains('부대찌개') ||
          lowerType.contains('김밥') ||
          lowerType.contains('국밥') ||
          lowerType.contains('순대') ||
          lowerType.contains('떡볶이') ||
          lowerType.contains('분식')) {
        return '한식';
      }

      // 중식 관련
      if (lowerType.contains('중식') ||
          lowerType.contains('중국요리') ||
          lowerType.contains('짜장면') ||
          lowerType.contains('짬뽕') ||
          lowerType.contains('탕수육') ||
          lowerType.contains('마파두부')) {
        return '중식';
      }

      // 일식 관련
      if (lowerType.contains('일식') ||
          lowerType.contains('초밥') ||
          lowerType.contains('롤') ||
          lowerType.contains('우동') ||
          lowerType.contains('라멘') ||
          lowerType.contains('돈부리')) {
        return '일식';
      }

      // 양식 관련
      if (lowerType.contains('양식') ||
          lowerType.contains('이탈리안') ||
          lowerType.contains('파스타') ||
          lowerType.contains('스테이크') ||
          lowerType.contains('버거')) {
        return '양식';
      }

      // 카페/디저트 관련
      if (lowerType.contains('카페') ||
          lowerType.contains('커피') ||
          lowerType.contains('디저트') ||
          lowerType.contains('베이커리') ||
          lowerType.contains('빵') ||
          lowerType.contains('케이크')) {
        return '카페';
      }

      // 치킨/피자 관련
      if (lowerType.contains('치킨') || lowerType.contains('닭')) {
        return '치킨';
      }
      if (lowerType.contains('피자')) {
        return '피자';
      }

      // 술집 관련
      if (lowerType.contains('술집') ||
          lowerType.contains('바') ||
          lowerType.contains('호프') ||
          lowerType.contains('맥주')) {
        return '술집';
      }
    }

    return '기타';
  }

  @override
  Widget build(BuildContext context) {
    final filteredRestaurants = _getFilteredRestaurants();

    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 추천'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 카테고리 필터
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF2563eb),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // 맛집 리스트
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRestaurants.isEmpty
                ? const Center(child: Text('해당 카테고리의 맛집이 없습니다.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = filteredRestaurants[index];
                      final category = _getCategoryFromTypes(restaurant.types);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                restaurant.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '카테고리: $category',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (restaurant.phoneNumber != null &&
                                  restaurant.phoneNumber!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '전화: ${restaurant.phoneNumber}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // 맛집 상세 페이지로 이동 (나중에 구현)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${restaurant.name} 상세 정보'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
