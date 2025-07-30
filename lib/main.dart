import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/my_treasures_page.dart';
import 'pages/mission_page.dart';
import 'pages/treasure_recommendation_page.dart';
import 'widgets/main_drawer.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'Sumbo',
      appUserModelId: 'com.example.sumbo_flutter',
      guid: '12345678-1234-1234-1234-123456789012',
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      windows: initializationSettingsWindows,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sumbo_channel',
      'Sumbo 알림',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const WindowsNotificationDetails windowsPlatformChannelSpecifics =
        WindowsNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      windows: windowsPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 캐시 서비스 초기화 (앱 시작 시 한 번만)
  print('앱 시작 - 캐시 서비스 초기화 중...');
  try {
    // await RestaurantCacheService().initialize(); // Removed as per edit hint
    print('캐시 서비스 초기화 완료');
  } catch (e) {
    print('캐시 서비스 초기화 실패: $e');
  }

  // 자동 업데이트 스케줄러 시작
  // await RestaurantUpdateScheduler().startScheduler(); // Removed as per edit hint

  runApp(const SumboApp());
}

class SumboApp extends StatelessWidget {
  const SumboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '숨보',
      theme: ThemeData(
        primaryColor: const Color(0xFF2563eb),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563eb),
          primary: const Color(0xFF2563eb),
        ),
        useMaterial3: true,
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563eb),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563eb),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: child!,
        );
      },
      home: const MainDrawerPage(),
    );
  }
}

class MainDrawerPage extends StatefulWidget {
  final int initialIndex;
  const MainDrawerPage({super.key, this.initialIndex = 0});

  @override
  State<MainDrawerPage> createState() => _MainDrawerPageState();
}

class _MainDrawerPageState extends State<MainDrawerPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    MapPage(),
    MyTreasuresPage(fromHome: false),
    MissionPage(fromHome: false),
    TreasureRecommendationPage(fromHome: false),
  ];

  final List<String> _titles = const ['홈', '보물지도', '내 보물', '미션', '보물 추천'];

  // MainDrawer에서 네비게이션을 처리하므로 이 메서드는 더 이상 필요하지 않습니다

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex < _titles.length ? _titles[_selectedIndex] : '',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const MainDrawer(),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 20.0,
      body: _selectedIndex == 0
          ? HomePage(
              onNavigate: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )
          : _pages[_selectedIndex - 1],
    );
  }
}

class CategoryHomePage extends StatelessWidget {
  const CategoryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': '인증 미션', 'type': 'cert'},
      {'title': '리뷰 미션', 'type': 'review'},
      {'title': '투표 미션', 'type': 'vote'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('숨보 미션'), centerTitle: true),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...categories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MissionListPage(category: cat['type']!),
                          ),
                        );
                      },
                      child: Text(cat['title']!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MissionListPage extends StatelessWidget {
  final String category;
  const MissionListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // 카테고리별 더미 맛집 리스트
    final dummyData = {
      'cert': [
        {'name': '숨보김밥', 'address': '서울 강남구', 'id': 1},
        {'name': '숨보치킨', 'address': '서울 서초구', 'id': 2},
      ],
      'review': [
        {'name': '숨보피자', 'address': '서울 송파구', 'id': 3},
        {'name': '숨보버거', 'address': '서울 강동구', 'id': 4},
      ],
      'vote': [
        {'name': '숨보카페', 'address': '서울 마포구', 'id': 5},
        {'name': '숨보분식', 'address': '서울 종로구', 'id': 6},
      ],
    };
    final list = dummyData[category] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('맛집 리스트 ($category)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: list.isEmpty
            ? const Center(child: Text('해당 카테고리의 맛집이 없습니다.'))
            : DataTable(
                columns: const [
                  DataColumn(label: Text('이름')),
                  DataColumn(label: Text('주소')),
                ],
                rows: list
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item['name'] as String)),
                          DataCell(Text(item['address'] as String)),
                        ],
                        onSelectChanged: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MissionDetailPage(
                                name: item['name'] as String,
                                address: item['address'] as String,
                                id: item['id'] as int,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class MissionDetailPage extends StatelessWidget {
  final String name;
  final String address;
  final int id;
  const MissionDetailPage({
    super.key,
    required this.name,
    required this.address,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('미션 상세')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이름: $name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('주소: $address', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text('여기에 미션 상세 정보 및 인증/리뷰/투표 기능이 추가될 예정입니다.'),
          ],
        ),
      ),
    );
  }
}

// 위치-보물 거리 체크 및 알림 트리거 예시 (실제 로직은 MapPage 등에서 주기적으로 호출)
Future<void> checkNearbyTreasuresAndNotify({
  required Position myPosition,
  required List<LatLng> treasurePositions,
  required double radiusKm,
}) async {
  for (final treasure in treasurePositions) {
    final distance = Geolocator.distanceBetween(
      myPosition.latitude,
      myPosition.longitude,
      treasure.latitude,
      treasure.longitude,
    );
    if (distance <= radiusKm * 1000) {
      await NotificationService().showNotification(
        '근처에 보물이 있습니다!',
        '설정한 거리($radiusKm km) 내에 보물이 있습니다. 확인해보세요!',
      );
      break;
    }
  }
}
