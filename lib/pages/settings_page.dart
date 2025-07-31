import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm_filter_detail_page.dart';

import 'dart:developer';
import '../widgets/main_drawer.dart';
import '../widgets/scrollable_page.dart';
import '../utils/logger.dart';
import '../services/backup_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _moveMode = 'walk'; // 'walk' or 'drive'
  double _walkDistance = 1.0;
  double _driveDistance = 10.0;
  bool _alarmOn = true;
  bool _alarmRepeat = true;
  int _alarmCheckInterval = 30; // 알림 반복 주기 (초)
  String _alarmCheckUnit = '초'; // 알림 반복 주기 단위
  String _nickname = 'sumbo_user';
  bool _prefsLoaded = false;
  bool _alarmFilterExpanded = false; // 보물 알림 설정 펼치기/접기 상태
  final Map<String, List<String>> _alarmFilterCategories = {
    '맛집': ['한식', '중식', '일식', '양식', '카페', '디저트', '분식', '치킨', '피자', '햄버거'],
    '영화': ['액션', '로맨스', '코미디', '스릴러', '드라마', 'SF', '호러', '다큐멘터리'],
    '책': ['소설', '자기계발', '경제', '역사', '과학', '철학', '예술', '여행'],
    '패션': ['의류', '신발', '가방', '액세서리', '화장품', '스포츠웨어', '언더웨어'],
    '문화': ['박물관', '미술관', '공연장', '전시회', '축제', '문화재', '도서관'],
    '사람': ['유명인', '전문가', '아티스트', '작가', '음악가', '스포츠스타'],
    '그 외': ['랜드마크', '공원', '쇼핑', '엔터테인먼트', '스포츠', '숙박'],
  };
  Set<String> _selectedAlarmFilters = {};
  final TextEditingController _alarmCheckIntervalController =
      TextEditingController();
  final FocusNode _alarmCheckIntervalFocusNode = FocusNode();
  bool _scrollButtonsEnabled = true; // 스크롤 버튼 활성화 상태
  bool _notificationsEnabled = true;
  bool _autoBackupEnabled = false;
  Map<String, dynamic>? _backupInfo;
  Map<String, dynamic>? _currentRadiusInfo; // 현재 반경거리 정보

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrefs();
    });
  }

  @override
  void dispose() {
    _alarmCheckIntervalController.dispose();
    _alarmCheckIntervalFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _alarmOn = prefs.getBool('alarmOn') ?? true;
        _alarmRepeat = prefs.getBool('alarmRepeat') ?? true;
        _nickname = prefs.getString('nickname') ?? 'sumbo_user';
        _moveMode = prefs.getString('moveMode') ?? 'walk';
        _walkDistance = prefs.getDouble('walkDistance') ?? 1.0;
        _driveDistance = prefs.getDouble('driveDistance') ?? 10.0;
        _alarmCheckInterval = prefs.getInt('alarmCheckInterval') ?? 30;
        _alarmCheckUnit = prefs.getString('alarmCheckUnit') ?? '초';
        // 저장된 값을 TextField에 표시
        _alarmCheckIntervalController.text = _alarmCheckInterval.toString();
        _selectedAlarmFilters =
            (prefs.getStringList('alarmFilters') ?? []).toSet();
        _scrollButtonsEnabled = prefs.getBool('scrollButtonsEnabled') ?? true;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _autoBackupEnabled = prefs.getBool('auto_backup_enabled') ?? false;
        _prefsLoaded = true;
      });
      _loadBackupInfo();
      _loadCurrentRadiusInfo();
      log(
        '[Prefs] Loaded: alarmOn=$_alarmOn, alarmRepeat=$_alarmRepeat, nickname=$_nickname, moveMode=$_moveMode, walkDistance=$_walkDistance, driveDistance=$_driveDistance, alarmCheckInterval=$_alarmCheckInterval, alarmCheckUnit=$_alarmCheckUnit, alarmFilters=$_selectedAlarmFilters',
      );
    } catch (e) {
      setState(() {
        _prefsLoaded = true;
      });
      log('[Prefs] Load error: $e');
    }
  }

  Future<void> _loadBackupInfo() async {
    final info = await BackupService.getBackupInfo();
    setState(() {
      _backupInfo = info;
    });
  }

  Future<void> _loadCurrentRadiusInfo() async {
    try {
      // 현재 설정된 반경거리 정보 계산
      final moveMode = _moveMode;
      double distance;
      String mode;

      if (moveMode == 'walk') {
        distance = _walkDistance;
        mode = 'walk';
      } else {
        distance = _driveDistance;
        mode = 'drive';
      }

      setState(() {
        _currentRadiusInfo = {
          'mode': mode,
          'distance': distance,
          'unit': 'km',
          'radius_meters': (distance * 1000).round(),
        };
      });
    } catch (e) {
      print('반경거리 정보 로드 실패: $e');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
      setState(() {
        _notificationsEnabled = value;
      });
    } catch (e) {
      print('알림 설정 저장 실패: $e');
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', value);
      setState(() {
        _autoBackupEnabled = value;
      });

      if (value) {
        await BackupService.setupAutoBackup();
      }
    } catch (e) {
      print('자동 백업 설정 저장 실패: $e');
    }
  }

  Future<void> _createBackup() async {
    final success = await BackupService.createBackup();
    if (success) {
      _loadBackupInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업이 성공적으로 생성되었습니다.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업 생성에 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    final success = await BackupService.restoreBackup();
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업이 성공적으로 복구되었습니다.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업 복구에 실패했습니다.')),
        );
      }
    }
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2563EB)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '없음';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '오류';
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarmOn', _alarmOn);
    await prefs.setBool('alarmRepeat', _alarmRepeat);
    await prefs.setString('nickname', _nickname);
    await prefs.setString('moveMode', _moveMode);
    await prefs.setDouble('walkDistance', _walkDistance);
    await prefs.setDouble('driveDistance', _driveDistance);
    await prefs.setInt('alarmCheckInterval', _alarmCheckInterval);
    await prefs.setString('alarmCheckUnit', _alarmCheckUnit);
    await prefs.setStringList('alarmFilters', _selectedAlarmFilters.toList());
    await prefs.setBool('scrollButtonsEnabled', _scrollButtonsEnabled);
    log(
      '[Prefs] Saved: alarmOn=$_alarmOn, alarmRepeat=$_alarmRepeat, nickname=$_nickname, moveMode=$_moveMode, walkDistance=$_walkDistance, driveDistance=$_driveDistance, alarmCheckInterval=$_alarmCheckInterval, alarmCheckUnit=$_alarmCheckUnit, alarmFilters=$_selectedAlarmFilters',
    );
  }

  void _onAlarmChanged(bool value) {
    setState(() {
      _alarmOn = value;
    });
    _savePrefs();
  }

  void _onAlarmRepeatChanged(bool value) {
    setState(() {
      _alarmRepeat = value;
    });
    _savePrefs();
  }

  void _onMoveModeChanged(String value) {
    setState(() {
      _moveMode = value;
    });
    _savePrefs();
    _loadCurrentRadiusInfo(); // 반경거리 정보 업데이트
  }

  void _onWalkDistanceChanged(double value) {
    setState(() {
      _walkDistance = value;
    });
    _savePrefs();
    _loadCurrentRadiusInfo(); // 반경거리 정보 업데이트
  }

  void _onDriveDistanceChanged(double value) {
    setState(() {
      _driveDistance = value;
    });
    _savePrefs();
    _loadCurrentRadiusInfo(); // 반경거리 정보 업데이트
  }

  void _onAlarmCheckIntervalChanged(int value) {
    setState(() {
      _alarmCheckInterval = value;
    });
    _savePrefs();
  }

  void _onAlarmCheckUnitChanged(String value) {
    setState(() {
      _alarmCheckUnit = value;
    });
    _savePrefs();
  }

  void _onScrollButtonsChanged(bool value) {
    setState(() {
      _scrollButtonsEnabled = value;
    });
    _savePrefs();
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(nickname: _nickname),
      ),
    ).then((newNickname) {
      if (newNickname != null) {
        setState(() {
          _nickname = newNickname;
        });
        _savePrefs();
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '맛집':
        return Icons.restaurant;
      case '영화':
        return Icons.movie;
      case '책':
        return Icons.book;
      case '패션':
        return Icons.checkroom;
      case '문화':
        return Icons.museum;
      case '사람':
        return Icons.person;
      case '그 외':
        return Icons.place;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('설정'),
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ScrollablePage(
      title: '설정',
      showScrollButtons: true,
      drawer: const MainDrawer(),
      child: Column(
        children: [
          // 프로필 섹션
          Container(
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
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '닉네임',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nickname,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
                  onPressed: _editProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 12),
          // 이동방식
          Container(
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
                const Text(
                  '이동방식',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  '선택한 이동방식에 따라 맛집 검색 반경이 자동으로 조정됩니다.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Radio<String>(
                      value: 'walk',
                      groupValue: _moveMode,
                      onChanged: (v) => _onMoveModeChanged(v!),
                    ),
                    const Text('걷는 중'),
                    const SizedBox(width: 16),
                    Radio<String>(
                      value: 'drive',
                      groupValue: _moveMode,
                      onChanged: (v) => _onMoveModeChanged(v!),
                    ),
                    const Text('운전 중'),
                  ],
                ),
                if (_moveMode == 'walk') ...[
                  Slider(
                    value: _walkDistance,
                    min: 0,
                    max: 10,
                    divisions: 100,
                    label: '${_walkDistance.round()}km',
                    onChanged: _onWalkDistanceChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '반경거리: ${_walkDistance.round()}km',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563eb).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(_walkDistance * 1000).round()}m',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563eb),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_moveMode == 'drive') ...[
                  Slider(
                    value: _driveDistance,
                    min: 0,
                    max: 300,
                    divisions: 300,
                    label: '${_driveDistance.round()}km',
                    onChanged: _onDriveDistanceChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '반경거리: ${_driveDistance.round()}km',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563eb).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(_driveDistance * 1000).round()}m',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563eb),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 알림 기능
          _CustomSwitchCard(
            title: '알림 기능',
            value: _alarmOn,
            onChanged: _onAlarmChanged,
          ),
          const SizedBox(height: 24),
          // 알림 반복
          _CustomSwitchCard(
            title: '알림 반복',
            value: _alarmRepeat,
            onChanged: _onAlarmRepeatChanged,
          ),
          const SizedBox(height: 24),
          // 알림 체크 주기
          Container(
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
                const Text(
                  '알림 반복 주기',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: true,
                        autofocus: false,
                        focusNode: _alarmCheckIntervalFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '숫자',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        controller: _alarmCheckIntervalController,
                        onTapOutside: (event) {
                          _alarmCheckIntervalFocusNode.unfocus();
                        },
                        onChanged: (value) {
                          Logger.debug('입력된 값: $value');
                          if (value.isEmpty) {
                            // 빈 값일 때는 아무것도 하지 않음
                            Logger.debug('빈 값 - 설정 변경하지 않음');
                          } else {
                            final intValue = int.tryParse(value);
                            Logger.debug('변환된 숫자: $intValue');
                            if (intValue != null && intValue > 0) {
                              setState(() {
                                _alarmCheckInterval = intValue;
                              });
                              _onAlarmCheckIntervalChanged(intValue);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _alarmCheckUnit,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '단위',
                        ),
                        items: const [
                          DropdownMenuItem(value: '초', child: Text('초')),
                          DropdownMenuItem(value: '분', child: Text('분')),
                          DropdownMenuItem(value: '시간', child: Text('시간')),
                          DropdownMenuItem(value: '일', child: Text('일')),
                          DropdownMenuItem(value: '주', child: Text('주')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _onAlarmCheckUnitChanged(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '현재 설정: $_alarmCheckInterval$_alarmCheckUnit마다 보물을 체크합니다',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 보물 알림 설정
          Container(
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
                      _alarmFilterExpanded = !_alarmFilterExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '보물 알림 설정',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Icon(
                        _alarmFilterExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF2563eb),
                      ),
                    ],
                  ),
                ),
                if (_alarmFilterExpanded) ...[
                  const SizedBox(height: 10),
                  const Text(
                    '알림을 받고 싶은 카테고리를 선택하세요.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ..._alarmFilterCategories.entries.map((entry) {
                    final mainCategory = entry.key;
                    final subCategories = entry.value;
                    final selectedCount = subCategories
                        .where(
                          (category) =>
                              _selectedAlarmFilters.contains(category),
                        )
                        .length;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getCategoryIcon(mainCategory),
                          color: const Color(0xFF2563eb),
                        ),
                        title: Text(mainCategory),
                        subtitle: Text(
                          selectedCount > 0
                              ? '$selectedCount개 선택됨'
                              : '선택된 항목 없음',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlarmFilterDetailPage(
                                mainCategory: mainCategory,
                                subCategories: subCategories,
                                selectedFilters: _selectedAlarmFilters,
                              ),
                            ),
                          );
                          // 설정이 변경되었으면 다시 로드
                          if (result == true) {
                            await _loadPrefs();
                          }
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 스크롤 버튼 설정
          Container(
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
                const Text(
                  '스크롤 버튼',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  '화면에서 스크롤 버튼 사용 여부를 설정합니다.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('스크롤 버튼 활성화', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _scrollButtonsEnabled,
                      onChanged: _onScrollButtonsChanged,
                      activeColor: const Color(0xFF2563eb),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 앱 정보
          Container(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('앱 정보', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('버전: 1.0.0'),
                Text('제작: 숨보팀'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 데이터 관리
          Container(
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
                const Text(
                  '데이터 관리',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.notifications,
                  title: '알림',
                  subtitle: '푸시 알림 받기',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: const Color(0xFF2563EB),
                  ),
                ),
                _buildSettingCard(
                  icon: Icons.backup,
                  title: '자동 백업',
                  subtitle: '24시간마다 자동으로 데이터 백업',
                  trailing: Switch(
                    value: _autoBackupEnabled,
                    onChanged: _toggleAutoBackup,
                    activeColor: const Color(0xFF2563EB),
                  ),
                ),
                _buildSettingCard(
                  icon: Icons.save,
                  title: '수동 백업',
                  subtitle: _backupInfo != null
                      ? '마지막 백업: ${_formatTimestamp(_backupInfo!['timestamp'])}'
                      : '백업 데이터 없음',
                  onTap: _createBackup,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
                _buildSettingCard(
                  icon: Icons.restore,
                  title: '백업 복구',
                  subtitle: '저장된 백업 데이터로 복구',
                  onTap: _restoreBackup,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 문의/피드백
          Container(
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
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackPage()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.email, color: Color(0xFF2563EB)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('문의/피드백 보내기', style: TextStyle(fontSize: 16)),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomSwitchCard extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitchCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 54,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value ? const Color(0xFF2563EB) : Colors.grey[300],
              ),
              child: Row(
                mainAxisAlignment:
                    value ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      value ? 'On' : 'Off',
                      style: TextStyle(
                        color: value ? const Color(0xFF2563EB) : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileEditPage extends StatefulWidget {
  final String nickname;
  const ProfileEditPage({super.key, required this.nickname});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.nickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('닉네임 수정'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newNickname = _controller.text.trim();
                    if (newNickname.isNotEmpty) {
                      Navigator.pop(context, newNickname);
                    }
                  },
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문의/피드백'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('문의/피드백 기능은 준비 중입니다.', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
