import 'package:flutter/material.dart';
import '../services/treasure_service.dart';

class TreasureRecommendationDetailPage extends StatefulWidget {
  final String route;
  const TreasureRecommendationDetailPage({super.key, required this.route});

  @override
  State<TreasureRecommendationDetailPage> createState() =>
      _TreasureRecommendationDetailPageState();
}

class _TreasureRecommendationDetailPageState
    extends State<TreasureRecommendationDetailPage> {
  final TreasureService _treasureService = TreasureService();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      // 보물 추천 데이터 로드
      final treasures = _treasureService.getAllTreasures();
      _recommendations = treasures.map((treasure) {
        return {
          'id': treasure.id,
          'title': treasure.name,
          'description': treasure.description,
          'category': treasure.tags.isNotEmpty ? treasure.tags.first : '기타',
          'rating': 4.5, // Dummy rating
          'reviewCount': 50, // Dummy review count
        };
      }).toList();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보물 추천'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = _recommendations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(recommendation['title']),
                    subtitle: Text(recommendation['description']),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${recommendation['rating']}'),
                        Text('${recommendation['reviewCount']} 리뷰'),
                      ],
                    ),
                    onTap: () {
                      // 상세 페이지로 이동
                    },
                  ),
                );
              },
            ),
    );
  }
}
