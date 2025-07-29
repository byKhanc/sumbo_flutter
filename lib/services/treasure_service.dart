import '../models/treasure.dart';

class TreasureService {
  static final TreasureService _instance = TreasureService._internal();
  factory TreasureService() => _instance;

  List<Treasure> _treasures = [];

  TreasureService._internal() {
    _initializeTreasures();
  }

  void _initializeTreasures() {
    _treasures = [
      const Treasure(
        id: '1',
        name: '역사적인 박물관',
        description: '한국의 역사를 한눈에 볼 수 있는 박물관',
        address: '서울시 종로구 세종로 1-57',
        latitude: 37.5796,
        longitude: 126.9770,
        tags: ['문화', '역사', '박물관'],
      ),
      const Treasure(
        id: '2',
        name: '아름다운 공원',
        description: '도시의 녹지 공간으로 휴식을 취할 수 있는 공원',
        address: '서울시 강남구 테헤란로 427',
        latitude: 37.5665,
        longitude: 126.9780,
        tags: ['자연', '공원', '휴식'],
      ),
      const Treasure(
        id: '3',
        name: '전통 시장',
        description: '다양한 먹거리와 생활용품을 구할 수 있는 전통 시장',
        address: '서울시 마포구 동교동 159-1',
        latitude: 37.5575,
        longitude: 126.9250,
        tags: ['시장', '음식', '전통'],
      ),
      const Treasure(
        id: '4',
        name: '현대적인 쇼핑몰',
        description: '최신 트렌드의 쇼핑을 즐길 수 있는 쇼핑몰',
        address: '서울시 강남구 테헤란로 152',
        latitude: 37.5665,
        longitude: 126.9780,
        tags: ['쇼핑', '패션', '현대'],
      ),
      const Treasure(
        id: '5',
        name: '문화 공연장',
        description: '다양한 문화 공연을 관람할 수 있는 공연장',
        address: '서울시 중구 세종대로 110',
        latitude: 37.5665,
        longitude: 126.9780,
        tags: ['문화', '공연', '예술'],
      ),
    ];
  }

  List<Treasure> getAllTreasures() {
    return _treasures;
  }

  List<Treasure> getTreasuresByCategory(String category) {
    return _treasures
        .where((treasure) => treasure.tags.contains(category))
        .toList();
  }

  Treasure? getTreasureById(String id) {
    try {
      return _treasures.firstWhere((treasure) => treasure.id == id);
    } catch (e) {
      return null;
    }
  }

  void addTreasure(Treasure treasure) {
    _treasures.add(treasure);
  }
}
