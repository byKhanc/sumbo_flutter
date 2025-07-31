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

class _MissionPageState extends State<MissionPage> {
  final TreasureService _treasureService = TreasureService();
  final RestaurantService _restaurantService = RestaurantService();

  Map<String, List<Map<String, dynamic>>> _missions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissions();
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
          },
        ],
      };

      setState(() {
        _isLoading = false;
      });
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: '미션',
      showScrollButtons: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  '다양한 미션에 도전하고\n보상을 받아보세요!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ..._missions.entries.map((entry) {
                  final category = entry.key;
                  final missions = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563eb),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: missions.map((mission) {
                          return _MissionCard(
                            mission: mission,
                            onComplete: () =>
                                _completeMission(category, mission['id']),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ],
            ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  final VoidCallback onComplete;

  const _MissionCard({
    required this.mission,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = mission['completed'] as bool;
    final icon = mission['icon'] as IconData;
    final color = mission['color'] as Color;

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
            color: isCompleted ? Colors.green : color,
          ),
          const SizedBox(height: 6),
          Text(
            mission['title'],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green : Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              mission['description'],
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
              Text(
                '${mission['points']}점',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563eb),
                ),
              ),
              IconButton(
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 20,
                ),
                onPressed: isCompleted ? null : onComplete,
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
