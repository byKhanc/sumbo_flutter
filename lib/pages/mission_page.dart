import 'package:flutter/material.dart';
import '../services/treasure_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/scrollable_page.dart';

class MissionPage extends StatefulWidget {
  final bool fromHome;
  const MissionPage({super.key, this.fromHome = false});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> with TickerProviderStateMixin {
  final TreasureService _treasureService = TreasureService();
  final RestaurantService _restaurantService = RestaurantService();

  Map<String, List<Map<String, dynamic>>> _missions = {};
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadMissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    try {
      final restaurants = await _restaurantService.getAllRestaurants();

      _missions = {
        '맛집 탐방': restaurants.take(5).map((restaurant) {
          return {
            'id': restaurant.id,
            'title': '${restaurant.name} 방문하기',
            'description':
                '${restaurant.address}에 위치한 ${restaurant.category} 맛집을 방문해보세요!',
            'points': 50,
            'category': restaurant.category,
            'completed': false,
            'icon': Icons.restaurant,
            'color': Colors.orange,
            'progress': 0.0,
          };
        }).toList(),
        '문화 탐방': [
          {
            'id': 'culture_1',
            'title': '박물관 방문하기',
            'description': '역사적인 박물관을 방문하여 문화를 체험해보세요!',
            'points': 100,
            'category': '문화',
            'completed': false,
            'icon': Icons.museum,
            'color': Colors.purple,
            'progress': 0.0,
          },
          {
            'id': 'culture_2',
            'title': '공연장 방문하기',
            'description': '문화 공연장에서 공연을 관람해보세요!',
            'points': 80,
            'category': '문화',
            'completed': false,
            'icon': Icons.theater_comedy,
            'color': Colors.purple,
            'progress': 0.0,
          },
        ],
        '자연 탐방': [
          {
            'id': 'nature_1',
            'title': '공원 산책하기',
            'description': '아름다운 공원에서 산책을 즐겨보세요!',
            'points': 30,
            'category': '자연',
            'completed': false,
            'icon': Icons.park,
            'color': Colors.green,
            'progress': 0.0,
          },
        ],
        '쇼핑 탐방': [
          {
            'id': 'shopping_1',
            'title': '쇼핑몰 방문하기',
            'description': '현대적인 쇼핑몰에서 쇼핑을 즐겨보세요!',
            'points': 60,
            'category': '쇼핑',
            'completed': false,
            'icon': Icons.shopping_bag,
            'color': const Color(0xFF2563eb),
            'progress': 0.0,
          },
        ],
      };

      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('미션 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _completeMission(String category, String missionId) {
    setState(() {
      final missions = _missions[category];
      if (missions != null) {
        final mission = missions.firstWhere((m) => m['id'] == missionId);
        mission['completed'] = true;
        mission['progress'] = 1.0;
      }
    });
  }

  double _getCategoryProgress(String category) {
    final missions = _missions[category];
    if (missions == null || missions.isEmpty) return 0.0;
    
    final completedCount = missions.where((m) => m['completed'] == true).length;
    return completedCount / missions.length;
  }

  int _getTotalPoints() {
    int total = 0;
    for (var missions in _missions.values) {
      for (var mission in missions) {
        if (mission['completed'] == true) {
          total += mission['points'] as int;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: '미션',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icons.task_alt,
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
                                    '미션 진행도',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_getTotalPoints()}점 획득',
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
                  const SizedBox(height: 24),
                  
                  // 미션 카테고리들
                  ..._missions.entries.map((entry) {
                    final category = entry.key;
                    final missions = entry.value;
                    final progress = _getCategoryProgress(category);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 카테고리 헤더
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563eb).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563eb),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563eb),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // 진행률 바
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2563eb),
                            ),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 16),
                          
                          // 미션 카드들
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 3.5,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: missions.length,
                            itemBuilder: (context, index) {
                              return _MissionCard(
                                mission: missions[index],
                                onComplete: () => _completeMission(
                                  category,
                                  missions[index]['id'],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class _MissionCard extends StatefulWidget {
  final Map<String, dynamic> mission;
  final VoidCallback onComplete;

  const _MissionCard({
    required this.mission,
    required this.onComplete,
  });

  @override
  State<_MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<_MissionCard>
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
    final isCompleted = widget.mission['completed'] as bool;
    final icon = widget.mission['icon'] as IconData;
    final color = widget.mission['color'] as Color;
    final points = widget.mission['points'] as int;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: isCompleted ? null : widget.onComplete,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.grey.shade200,
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
                  // 아이콘
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green.withOpacity(0.1)
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: isCompleted ? Colors.green : color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 내용
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.mission['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.green : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.mission['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // 포인트 및 완료 버튼
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563eb).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$points점',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563eb),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCompleted 
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: isCompleted ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ],
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
