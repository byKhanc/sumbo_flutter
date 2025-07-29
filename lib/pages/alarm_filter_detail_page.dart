import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/scroll_buttons.dart';

class AlarmFilterDetailPage extends StatefulWidget {
  final String mainCategory;
  final List<String> subCategories;
  final Set<String> selectedFilters;

  const AlarmFilterDetailPage({
    super.key,
    required this.mainCategory,
    required this.subCategories,
    required this.selectedFilters,
  });

  @override
  State<AlarmFilterDetailPage> createState() => _AlarmFilterDetailPageState();
}

class _AlarmFilterDetailPageState extends State<AlarmFilterDetailPage> {
  final ScrollController _scrollController = ScrollController();
  late Set<String> _selectedFilters;
  bool _scrollButtonsEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.selectedFilters);
    _loadScrollButtonsSetting();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadScrollButtonsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scrollButtonsEnabled = prefs.getBool('scrollButtonsEnabled') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mainCategory} 알림 설정'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      drawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0.0,
      body: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF6F8FB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.mainCategory} 카테고리',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '알림을 받고 싶은 세부\n카테고리를 선택하세요.',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 체크박스 목록
          Expanded(
            child: Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 전체 선택/해제 버튼
                    Row(
                      children: [
                        TextButton(
                          onPressed: _selectAll,
                          child: const Text('전체 선택'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: _deselectAll,
                          child: const Text('전체 해제'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 세부 카테고리 체크박스들
                    ...widget.subCategories.map((category) {
                      return _buildCategoryCheckbox(category);
                    }),

                    const SizedBox(height: 32),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563eb),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          '설정 저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ScrollButtons(
                  scrollController: _scrollController,
                  enabled: _scrollButtonsEnabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCheckbox(String category) {
    final isSelected = _selectedFilters.contains(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(
          category,
          style: const TextStyle(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        subtitle: Text(
          '${widget.mainCategory} - $category\n알림을 받습니다.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedFilters.add(category);
            } else {
              _selectedFilters.remove(category);
            }
          });
        },
        activeColor: const Color(0xFF2563eb),
        checkColor: Colors.white,
      ),
    );
  }

  void _selectAll() {
    setState(() {
      _selectedFilters.addAll(widget.subCategories);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedFilters.clear();
    });
  }

  void _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 기존 설정 가져오기
      final existingFilters = prefs.getStringList('alarmFilters') ?? [];

      // 현재 카테고리의 기존 필터 제거
      final updatedFilters = existingFilters.where((filter) {
        return !widget.subCategories.contains(filter);
      }).toList();

      // 새로 선택된 필터 추가
      updatedFilters.addAll(_selectedFilters);

      // 저장
      await prefs.setStringList('alarmFilters', updatedFilters);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('알림 설정이 저장되었습니다.'),
            backgroundColor: const Color(0xFF2563eb),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onVisible: () {
              // SnackBar가 표시되면 GestureDetector로 감싸서 터치 이벤트 처리
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final overlay = Overlay.of(context);
                final overlayEntry = OverlayEntry(
                  builder: (context) => Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      child: Container(height: 80, color: Colors.transparent),
                    ),
                  ),
                );
                overlay.insert(overlayEntry);

                // 3초 후 자동으로 제거
                Future.delayed(const Duration(seconds: 3), () {
                  overlayEntry.remove();
                });
              });
            },
          ),
        );

        Navigator.pop(context, true); // 설정이 변경되었음을 알림
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('설정 저장 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onVisible: () {
              // SnackBar가 표시되면 GestureDetector로 감싸서 터치 이벤트 처리
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final overlay = Overlay.of(context);
                final overlayEntry = OverlayEntry(
                  builder: (context) => Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      child: Container(height: 80, color: Colors.transparent),
                    ),
                  ),
                );
                overlay.insert(overlayEntry);

                // 3초 후 자동으로 제거
                Future.delayed(const Duration(seconds: 3), () {
                  overlayEntry.remove();
                });
              });
            },
          ),
        );
      }
    }
  }
}
