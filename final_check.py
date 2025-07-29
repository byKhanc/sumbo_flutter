#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
최종 카카오맵 API 확인
"""

import requests

def final_check():
    """최종 API 확인"""
    
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("🔍 최종 카카오맵 API 확인...")
    
    url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}'
    }
    params = {
        'query': '강남역',
        'size': 1
    }
    
    try:
        response = requests.get(url, headers=headers, params=params)
        
        print(f"응답 코드: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ 성공! API가 정상 작동합니다.")
            data = response.json()
            if data.get('documents'):
                result = data['documents'][0]
                print(f"📍 검색 결과: {result.get('place_name', 'N/A')}")
            return True
        else:
            print(f"❌ 실패: {response.status_code}")
            print(f"오류 메시지: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 오류: {e}")
        return False

if __name__ == "__main__":
    print("="*50)
    print("🎯 최종 카카오맵 API 확인")
    print("="*50)
    
    success = final_check()
    
    print("\n" + "="*50)
    if success:
        print("🎉 403 오류가 완전히 해결되었습니다!")
        print("✅ 카카오맵 API가 정상 작동합니다!")
        print("✅ Flutter 앱에서 사용할 수 있습니다!")
    else:
        print("❌ 아직 403 오류가 발생하고 있습니다.")
        print("카카오 개발자 콘솔에서 서비스를 활성화해주세요.")
    print("="*50) 