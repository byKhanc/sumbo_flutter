import 'package:flutter/material.dart';
import '../widgets/scrollable_page.dart';
import '../widgets/mission_card.dart';

class MissionListPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> missions;
  final Set<int> completedMissions;

  const MissionListPage({
    super.key,
    required this.category,
    required this.missions,
    required this.completedMissions,
  });

  @override
  State<MissionListPage> createState() => _MissionListPageState();
}

class _MissionListPageState extends State<MissionListPage> {
  @override
  Widget build(BuildContext context) {
    return ScrollablePage(
      title: _getCategoryTitle(widget.category),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.missions.length,
        itemBuilder: (context, index) {
          final mission = widget.missions[index];
          final isCompleted = widget.completedMissions.contains(mission['id']);

          return MissionCard(
            mission: {
              'title': mission['title'],
              'description': mission['description'],
              'location': mission['location'],
              'points':
                  int.tryParse(mission['reward'].toString().split(' ')[0]) ??
                  100,
              'status': isCompleted ? 'completed' : 'available',
            },
            onStart: () {
              // 미션 시작 로직 (필요시 구현)
              if (!isCompleted) {
                setState(() {
                  widget.completedMissions.add(mission['id']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${mission['title']} 미션을 시작했습니다!')),
                );
              }
            },
          );
        },
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'cert':
        return '인증 미션';
      case 'review':
        return '리뷰 미션';
      case 'vote':
        return '투표 미션';
      case 'special':
        return '특별 미션';
      default:
        return '미션 목록';
    }
  }
}
