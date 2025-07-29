#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
빠른 카카오맵 API 테스트
"""

import requests

def quick_test():
    """빠른 API 테스트"""
    
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("🔍 빠른 API 테스트...")
    
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
        
        if response.status_code == 200:
            print("✅ 성공! API가 정상 작동합니다.")
            return True
        else:
            print(f"❌ 실패: {response.status_code}")
            print(f"오류: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 오류: {e}")
        return False

if __name__ == "__main__":
    success = quick_test()
    
    if success:
        print("\n🎉 403 오류가 해결되었습니다!")
    else:
        print("\n⚠️ 카카오 개발자 콘솔에서 서비스를 활성화해주세요.") 