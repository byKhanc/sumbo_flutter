import 'package:flutter/material.dart';
import 'map_page.dart';
import 'mission_page.dart';
import 'my_treasures_page.dart';
import 'treasure_recommendation_page.dart';
import 'platform_map_page.dart';

import '../widgets/scrollable_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onNavigate});

  final void Function(int index)? onNavigate;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 맵 페이지로 이동하는 함수 추가
  void _navigateToPlatformMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlatformMapPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      showScrollButtons: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '숨보 Sumbo에 오신 것을\n환영합니다!',
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
            children: [
              _HomeCard(
                icon: Icons.map,
                title: '보물 지도',
                description: '실시간으로 주변의\n보물들을 찾아보세요.',
                buttonText: '지도 보기 →',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlatformMapPage()),
                ),
              ),
              _HomeCard(
                icon: Icons.task,
                title: '미션',
                description: '다양한 미션에 도전하고\n보상을 받아보세요.',
                buttonText: '미션 보기 →',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MissionPage(fromHome: true),
                  ),
                ),
              ),
              _HomeCard(
                icon: Icons.diamond,
                title: '내 보물',
                description: '내가 찾은 보물들을\n한눈에 확인하세요.',
                buttonText: '보물 보기 →',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyTreasuresPage(fromHome: true),
                  ),
                ),
              ),
              _HomeCard(
                icon: Icons.restaurant,
                title: '보물 추천',
                description: '카테고리별 보물을\n추천받아보세요.',
                buttonText: '추천 보기 →',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const TreasureRecommendationPage(fromHome: true),
                  ),
                ),
              ),
              Card(
                child: InkWell(
                  onTap: () => _navigateToPlatformMap(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                                                         Icon(Icons.map, color: const Color(0xFF2563eb)),
                            const SizedBox(width: 8),
                            const Text(
                              '플랫폼별 맵',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '웹: 카카오맵, 에뮬레이터: 구글맵, 실제 기기: 카카오맵',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 28, color: const Color(0xFF2563eb)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563eb),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                minimumSize: const Size(0, 28),
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}
