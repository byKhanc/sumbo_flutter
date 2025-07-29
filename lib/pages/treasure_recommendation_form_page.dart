import 'package:flutter/material.dart';
import '../widgets/main_drawer.dart';
import '../services/treasure_service.dart';
import '../models/treasure.dart';

class TreasureRecommendationFormPage extends StatefulWidget {
  final String category;
  final String route;

  const TreasureRecommendationFormPage({
    super.key,
    required this.category,
    required this.route,
  });

  @override
  State<TreasureRecommendationFormPage> createState() =>
      _TreasureRecommendationFormPageState();
}

class _TreasureRecommendationFormPageState
    extends State<TreasureRecommendationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  String _selectedSubCategory = '';
  double _rating = 5.0;
  final List<String> _selectedTags = [];

  List<String> get _subCategories {
    switch (widget.route) {
      case 'restaurant':
        return ['한식', '중식', '일식', '양식', '카페', '디저트', '분식', '치킨', '피자', '햄버거'];
      case 'movie':
        return ['액션', '로맨스', '코미디', '스릴러', '드라마', 'SF', '호러', '다큐멘터리'];
      case 'book':
        return ['소설', '자기계발', '경제', '역사', '과학', '철학', '예술', '여행'];
      case 'culture':
        return ['박물관', '미술관', '공연장', '전시회', '축제', '문화재'];
      case 'person':
        return ['유명인', '전문가', '아티스트', '작가', '음악가'];
      case 'other':
        return ['랜드마크', '공원', '쇼핑', '엔터테인먼트', '스포츠'];
      default:
        return [];
    }
  }

  List<String> get _availableTags {
    switch (widget.route) {
      case 'restaurant':
        return ['맛있음', '분위기좋음', '친절함', '깔끔함', '가성비좋음', '신선함', '매운맛', '달콤함'];
      case 'movie':
        return ['감동적', '재미있음', '긴장감', '로맨틱', '액션', '유머', '감동', '스릴'];
      case 'book':
        return ['인사이트', '감동적', '재미있음', '유익함', '깊이있음', '실용적', '창의적'];
      case 'culture':
        return ['교육적', '감동적', '아름다움', '역사적', '예술적', '특별함', '체험'];
      case 'person':
        return ['영감', '전문성', '창의성', '열정', '성공', '뛰어남', '특별함'];
      case 'other':
        return ['아름다움', '특별함', '재미있음', '편안함', '활기참', '조용함', '관광지'];
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    if (_subCategories.isNotEmpty) {
      _selectedSubCategory = _subCategories[0];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} 추천하기'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(currentPage: 'recommendation'),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 20.0,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보
              _buildSectionTitle('기본 정보'),
              const SizedBox(height: 16),

              // 이름
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름 *',
                  hintText: '추천할 ${widget.category}의\n이름을 입력하세요',
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                enableIMEPersonalizedLearning: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 카테고리 선택
              DropdownButtonFormField<String>(
                value: _selectedSubCategory.isNotEmpty
                    ? _selectedSubCategory
                    : null,
                decoration: const InputDecoration(
                  labelText: '카테고리 *',
                  border: OutlineInputBorder(),
                ),
                items: _subCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '카테고리를 선택해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 평점
              Text('평점: ${_rating.toStringAsFixed(1)}점'),
              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                label: _rating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 상세 정보
              _buildSectionTitle('상세 정보'),
              const SizedBox(height: 16),

              // 설명
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 *',
                  hintText: '추천하는 이유나 특징을\n설명해주세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.multiline,
                enableIMEPersonalizedLearning: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '설명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 주소
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '주소 *',
                  hintText: '정확한 주소를 입력해주세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                enableIMEPersonalizedLearning: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '주소를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 연락처
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '연락처',
                  hintText: '전화번호 (선택사항)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // 웹사이트
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: '웹사이트',
                  hintText: '웹사이트 주소 (선택사항)',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // 태그 선택
              _buildSectionTitle('태그 선택'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF2563eb).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2563eb),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // 제출 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563eb),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '추천 제출하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2563eb),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 새 보물 생성
      final newTreasure = Treasure(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // 임시 ID
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        latitude: 37.5665, // 기본 서울 좌표 (실제로는 주소를 좌표로 변환해야 함)
        longitude: 126.9780,
        tags: [widget.category, _selectedSubCategory, ..._selectedTags],
      );

      // TreasureService에 새 보물 추가
      TreasureService().addTreasure(newTreasure);

      // 성공 메시지 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('추천 제출 완료'),
            content: const Text('보물 추천이 성공적으로 제출되었습니다.\n앱에 즉시 반영됩니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // 폼 페이지 닫기
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}
