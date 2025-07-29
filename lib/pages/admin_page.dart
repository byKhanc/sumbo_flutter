import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_drawer.dart';
import '../models/treasure.dart';
import '../services/treasure_service.dart';
import '../widgets/scroll_buttons.dart';
import '../widgets/stat_card.dart';
import '../widgets/admin_treasure_item.dart';
import '../widgets/admin_function_item.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ScrollController _scrollController = ScrollController();
  bool _treasureCategoryExpanded = false;
  bool _scrollButtonsEnabled = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortBy = 'name';
  List<Map<String, dynamic>> _filteredTreasures = [];

  @override
  void initState() {
    super.initState();
    _loadScrollButtonsSetting();
    _filteredTreasures = _getRegisteredTreasures();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScrollButtonsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scrollButtonsEnabled = prefs.getBool('scrollButtonsEnabled') ?? true;
    });
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      double inMan = number / 10000;
      if (inMan >= 1) {
        return '${inMan.toStringAsFixed(inMan.truncateToDouble() == inMan ? 0 : 1)}만';
      }
    }
    return number.toString();
  }

  List<Treasure> _getTreasures() {
    return TreasureService().getAllTreasures();
  }

  List<Map<String, dynamic>> _getRegisteredTreasures() {
    final treasures = TreasureService().getAllTreasures();
    return treasures.map((treasure) {
      String currentCategory = '그 외';
      if (treasure.tags.contains('맛집')) {
        currentCategory = '맛집';
      } else if (treasure.tags.contains('영화')) {
        currentCategory = '영화';
      } else if (treasure.tags.contains('책')) {
        currentCategory = '책';
      } else if (treasure.tags.contains('패션')) {
        currentCategory = '패션';
      } else if (treasure.tags.contains('문화')) {
        currentCategory = '문화';
      } else if (treasure.tags.contains('사람')) {
        currentCategory = '사람';
      }

      return {
        'id': treasure.id,
        'name': treasure.name,
        'currentCategory': currentCategory,
        'description': treasure.description,
        'address':
            '${treasure.latitude.toStringAsFixed(6)}, ${treasure.longitude.toStringAsFixed(6)}',
        'date': '2024-01-15',
        'tags': treasure.tags,
        'treasure': treasure,
      };
    }).toList();
  }

  final List<String> _availableCategories = [
    '맛집',
    '영화',
    '책',
    '패션',
    '문화',
    '사람',
    '그 외',
  ];

  final List<Map<String, dynamic>> _missions = [
    {
      'id': 1,
      'title': '첫 번째 보물 찾기',
      'description': '앱에서 첫 번째 보물을 찾아보세요',
      'location': '서울',
      'points': 100,
      'status': 'completed',
    },
    {
      'id': 2,
      'title': '카테고리 탐험',
      'description': '다양한 카테고리의 보물을 찾아보세요',
      'location': '전국',
      'points': 200,
      'status': 'available',
    },
    {
      'id': 3,
      'title': '보물 추천하기',
      'description': '새로운 보물을 추천해보세요',
      'location': '전국',
      'points': 300,
      'status': 'available',
    },
  ];

  void _filterTreasures() {
    final searchTerm = _searchController.text.toLowerCase();
    final allTreasures = _getRegisteredTreasures();

    setState(() {
      _filteredTreasures = allTreasures.where((treasure) {
        final name = treasure['name'].toString().toLowerCase();
        final description = treasure['description'].toString().toLowerCase();
        final category = treasure['currentCategory'].toString().toLowerCase();
        final tags = (treasure['tags'] as List<String>)
            .map((tag) => tag.toLowerCase())
            .join(' ');

        return name.contains(searchTerm) ||
            description.contains(searchTerm) ||
            category.contains(searchTerm) ||
            tags.contains(searchTerm);
      }).toList();

      // 정렬 적용
      _sortTreasures();
    });
  }

  void _sortTreasures() {
    switch (_selectedSortBy) {
      case 'name':
        _filteredTreasures.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'date':
        _filteredTreasures.sort((a, b) => a['date'].compareTo(b['date']));
        break;
      case 'category':
        _filteredTreasures.sort(
          (a, b) => a['currentCategory'].compareTo(b['currentCategory']),
        );
        break;
    }
  }

  void _changeTreasureCategory(
    Map<String, dynamic> treasure,
    String newCategory,
  ) {
    final treasureObj = treasure['treasure'] as Treasure;
    final updatedTags = List<String>.from(treasureObj.tags);

    // 기존 카테고리 태그 제거
    updatedTags.removeWhere((tag) => _availableCategories.contains(tag));

    // 새 카테고리 태그 추가
    if (newCategory != '그 외') {
      updatedTags.add(newCategory);
    }

    // Treasure 객체 업데이트 (실제 구현에서는 새로운 객체 생성)
    // treasureObj.tags = updatedTags;

    // TreasureService를 통해 저장 (실제 구현에서는 데이터베이스 업데이트)
    // TreasureService().updateTreasure(treasureObj);

    setState(() {
      treasure['currentCategory'] = newCategory;
      treasure['tags'] = updatedTags;
    });

    _showCategoryChangedSnackBar(treasure['name'], newCategory);
  }

  @override
  Widget build(BuildContext context) {
    final registeredTreasures = _getRegisteredTreasures();

    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdminStats(),
                const SizedBox(height: 20),
                _buildTreasureCategorySettings(),
                const SizedBox(height: 20),
                _buildOtherAdminFunctions(),
              ],
            ),
          ),
          if (_scrollButtonsEnabled)
            ScrollButtons(
              scrollController: _scrollController,
              enabled: _scrollButtonsEnabled,
            ),
        ],
      ),
    );
  }

  Widget _buildAdminStats() {
    final registeredTreasures = _getRegisteredTreasures();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 관리자 통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: '총 보물',
                    value: '${_formatNumber(registeredTreasures.length)}개',
                    icon: Icons.diamond,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: '카테고리',
                    value: '${_formatNumber(_availableCategories.length)}개',
                    icon: Icons.category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: '활성 사용자',
                    value: '1,218명',
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    label: '추가 예정',
                    value: '',
                    icon: Icons.add_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(label: '추가 예정', value: '', icon: Icons.star),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasureCategorySettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _treasureCategoryExpanded = !_treasureCategoryExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category, color: Color(0xFF2563eb)),
                      const SizedBox(width: 8),
                      const Text(
                        '보물 카테고리 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _treasureCategoryExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF2563eb),
                  ),
                ],
              ),
            ),
          ),
          if (_treasureCategoryExpanded) ...[
            const SizedBox(height: 16),
            const Text(
              '보물을 검색하여 카테고리를 변경할 수 있습니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '보물 이름, 설명, 카테고리로 검색...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterTreasures(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSortButton('이름순', 'name'),
                const SizedBox(width: 8),
                _buildSortButton('등록순', 'date'),
                const SizedBox(width: 8),
                _buildSortButton('카테고리순', 'category'),
              ],
            ),
            const SizedBox(height: 16),
            if (_searchController.text.isEmpty) ...[
              const Text(
                '검색어를 입력하여 보물을 찾아보세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ] else if (_filteredTreasures.isEmpty) ...[
              const Text(
                '검색 결과가 없습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ] else ...[
              const Text(
                '검색 결과:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._filteredTreasures.map((treasure) {
                return AdminTreasureItem(
                  treasure: treasure,
                  onEdit: () => _editTreasure(treasure),
                  onDelete: () => _deleteTreasure(treasure),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, String sortBy) {
    final isSelected = _selectedSortBy == sortBy;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedSortBy = sortBy;
            _sortTreasures();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF2563eb)
              : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildOtherAdminFunctions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 관리자 기능',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AdminFunctionItem(
              title: '사용자 관리',
              description: '사용자 계정 및 권한 관리',
              icon: Icons.people,
              onTap: () => _showComingSoon('사용자 관리'),
            ),
            AdminFunctionItem(
              title: '보물 승인',
              description: '신고된 보물 검토 및 승인',
              icon: Icons.verified,
              onTap: () => _showComingSoon('보물 승인'),
            ),
            AdminFunctionItem(
              title: '통계 보고서',
              description: '상세한 사용 통계 확인',
              icon: Icons.analytics,
              onTap: () => _showComingSoon('통계 보고서'),
            ),
            AdminFunctionItem(
              title: '시스템 설정',
              description: '앱 설정 및 환경 구성',
              icon: Icons.settings,
              onTap: () => _showComingSoon('시스템 설정'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryChangedSnackBar(String treasureName, String newCategory) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$treasureName이(가) $newCategory 카테고리로 변경되었습니다.'),
        backgroundColor: const Color(0xFF2563eb),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 기능은 준비 중입니다.'),
        backgroundColor: const Color(0xFF2563eb),
      ),
    );
  }

  void _editTreasure(Map<String, dynamic> treasure) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController(text: treasure['name']);
        final descriptionController = TextEditingController(
          text: treasure['description'],
        );
        String selectedCategory = treasure['currentCategory'];

        return AlertDialog(
          title: const Text('보물 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedCategory = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                // 실제 구현에서는 데이터베이스 업데이트
                setState(() {
                  treasure['name'] = nameController.text;
                  treasure['description'] = descriptionController.text;
                  if (selectedCategory != treasure['currentCategory']) {
                    _changeTreasureCategory(treasure, selectedCategory);
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTreasure(Map<String, dynamic> treasure) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('보물 삭제'),
          content: Text('${treasure['name']}을(를) 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                // 실제 구현에서는 데이터베이스에서 삭제
                setState(() {
                  _filteredTreasures.remove(treasure);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${treasure['name']}이(가) 삭제되었습니다.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
