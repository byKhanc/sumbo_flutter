import 'package:flutter/material.dart';
import '../services/treasure_service.dart';
import '../widgets/scrollable_page.dart';

class MyTreasuresPage extends StatefulWidget {
  final bool fromHome;
  const MyTreasuresPage({super.key, this.fromHome = false});

  @override
  State<MyTreasuresPage> createState() => _MyTreasuresPageState();
}

class _MyTreasuresPageState extends State<MyTreasuresPage> {
  final TreasureService _treasureService = TreasureService();
  List<Map<String, dynamic>> _allTreasures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreasures();
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

      setState(() {
        _isLoading = false;
      });
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

  int get _totalPoints {
    return _allTreasures.fold(
        0, (sum, treasure) => sum + (treasure['points'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: '내 보물',
      showScrollButtons: true,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  '내가 찾은 보물들을\n한눈에 확인하세요!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 포인트:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_totalPoints점',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563eb),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: _allTreasures.map((treasure) {
                    return _TreasureCard(
                      treasure: treasure,
                      onTap: () => _showTreasureDetail(treasure),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  void _showTreasureDetail(Map<String, dynamic> treasure) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreasureDetailPage(treasure: treasure),
      ),
    );
  }
}

class _TreasureCard extends StatelessWidget {
  final Map<String, dynamic> treasure;
  final VoidCallback onTap;

  const _TreasureCard({
    required this.treasure,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = treasure['icon'] as IconData;
    final color = treasure['color'] as Color;

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
            treasure['name'],
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
              treasure['description'],
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
                '${treasure['points']}점',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563eb),
                ),
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

class TreasureDetailPage extends StatelessWidget {
  final Map<String, dynamic> treasure;

  const TreasureDetailPage({super.key, required this.treasure});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(treasure['name']),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treasure['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    treasure['description'],
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        treasure['location'],
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${treasure['rating']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
