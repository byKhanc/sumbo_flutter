# 새로운 데이터 구조 설계

## 1. Restaurant 모델 (기존 Treasure 확장)

```dart
class Restaurant {
  final String id;                    // 고유 ID
  final String name;                  // 식당명
  final double latitude;              // 위도
  final double longitude;             // 경도
  final String address;               // 주소
  final String roadAddress;           // 도로명 주소
  final String category;              // 카테고리 (한식, 중식, 일식, 양식)
  final String subCategory;           // 세부 카테고리 (치킨, 피자 등)
  final String phone;                 // 전화번호
  final double rating;                // 평점 (0.0 ~ 5.0)
  final int reviewCount;              // 리뷰 개수
  final String openingHours;          // 영업시간
  final String region;                // 지역 (seoul, gyeonggi)
  final String district;              // 구/시 (강남구, 판교 등)
  final List<String> tags;            // 태그 (맛집, 분위기 좋은, 가성비 등)
  final String description;           // 설명
  final String mission;               // 미션 설명
  final int reward;                   // 보상 포인트
  final bool isOpen;                  // 영업 상태
  final String lastUpdated;           // 마지막 업데이트 시간
  
  // 이미지 URL들
  final String? mainImageUrl;         // 메인 이미지
  final List<String> imageUrls;       // 추가 이미지들
  
  // 소셜 정보
  final int likeCount;                // 좋아요 수
  final int visitCount;               // 방문 수
  final bool isRecommended;           // 추천 여부
}
```

## 2. 지역별 데이터 구조

### 서울 지역
```json
{
  "region": "seoul",
  "districts": [
    "강남구", "서초구", "마포구", "종로구", "중구",
    "용산구", "성동구", "광진구", "동대문구", "중랑구",
    "성북구", "강북구", "도봉구", "노원구", "은평구",
    "서대문구", "양천구", "강서구", "구로구", "금천구",
    "영등포구", "동작구", "관악구", "서초구", "강남구"
  ],
  "restaurants": [...]
}
```

### 경기도 지역
```json
{
  "region": "gyeonggi",
  "districts": [
    "판교", "광교", "분당", "일산", "과천", "안양"
  ],
  "restaurants": [...]
}
```

## 3. 카테고리 분류

### 메인 카테고리
- **한식** (Korean)
- **중식** (Chinese)
- **일식** (Japanese)
- **양식** (Western)
- **분식** (Street Food)
- **카페** (Cafe)
- **디저트** (Dessert)

### 세부 카테고리
- **한식:** 치킨, 삼겹살, 김치찌개, 갈비, 닭볶음탕
- **중식:** 짜장면, 탕수육, 마파두부, 깐풍기
- **일식:** 초밥, 라멘, 돈까스, 우동
- **양식:** 피자, 파스타, 스테이크, 햄버거
- **분식:** 떡볶이, 김밥, 순대, 어묵
- **카페:** 커피, 차, 주스, 스무디
- **디저트:** 빵, 케이크, 아이스크림, 마카롱

## 4. 태그 시스템

### 인기 태그
- **맛집** (맛있는 음식)
- **분위기 좋은** (인테리어가 예쁜)
- **가성비** (가격 대비 만족도 높은)
- **혼밥하기 좋은** (1인 식사하기 좋은)
- **데이트하기 좋은** (커플 데이트 장소)
- **가족과 함께** (가족 모임하기 좋은)
- **회식하기 좋은** (단체 모임하기 좋은)
- **24시간** (24시간 영업)
- **배달 가능** (배달 서비스 제공)
- **주차 가능** (주차 시설 있음)

## 5. 미션 시스템 확장

### 기존 미션 유지
- **방문 인증** (사진 촬영)
- **리뷰 작성** (한 줄 리뷰)
- **별점 매기기** (평점 등록)

### 새로운 미션 추가
- **체크인** (위치 기반 인증)
- **음식 사진 공유** (SNS 연동)
- **친구와 함께** (그룹 미션)
- **첫 방문** (신규 방문자)
- **정기 방문** (연속 방문)

## 6. 데이터 소스별 역할

### 공공데이터포털
- 기본 정보 (이름, 주소, 좌표, 전화번호)
- 영업시간, 업종 분류
- 위생 등급 정보

### 카카오맵
- 상세 정보 (평점, 리뷰, 사진)
- 카테고리 분류
- 실시간 영업 상태
- 방문자 수, 좋아요 수

### 네이버맵
- 대체 정보 (카카오에 없는 데이터)
- 상세 주소 (도로명 주소)
- 부가 정보 (주차, 배달 등)
- 검색 키워드 분석 