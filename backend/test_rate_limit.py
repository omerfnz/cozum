#!/usr/bin/env python
"""
Rate Limiting Test Script
Bu script rate limiting'in çalışıp çalışmadığını test eder.
"""

import requests
import time
import json

def test_login_rate_limit():
    """Login endpoint'inin rate limiting'ini test eder (5/dakika)"""
    url = "http://localhost:8000/api/auth/login/"
    
    print("🔒 Login Rate Limiting Testi (5 deneme/dakika)")
    print("=" * 50)
    
    # Geçersiz login bilgileri ile test
    data = {
        "email": "test@example.com",
        "password": "wrongpassword"
    }
    
    for i in range(7):  # 5'ten fazla deneme yaparak rate limit'i test et
        try:
            response = requests.post(url, json=data, timeout=5)
            print(f"Deneme {i+1}: Status {response.status_code}")
            
            if response.status_code == 429:  # Too Many Requests
                print("✅ Rate limiting çalışıyor! 429 Too Many Requests alındı.")
                break
            elif response.status_code == 400:
                print("   Geçersiz login bilgileri (beklenen)")
            else:
                print(f"   Beklenmeyen response: {response.text[:100]}")
                
        except requests.exceptions.RequestException as e:
            print(f"   Hata: {e}")
            
        time.sleep(1)  # 1 saniye bekle
    
    print()

def test_register_rate_limit():
    """Register endpoint'inin rate limiting'ini test eder (3/saat)"""
    url = "http://localhost:8000/api/auth/register/"
    
    print("📝 Register Rate Limiting Testi (3 deneme/saat)")
    print("=" * 50)
    
    # Geçersiz register bilgileri ile test
    data = {
        "email": "test@example.com",
        "password": "123",  # Çok kısa şifre
        "first_name": "Test",
        "last_name": "User"
    }
    
    for i in range(5):  # 3'ten fazla deneme yaparak rate limit'i test et
        try:
            response = requests.post(url, json=data, timeout=5)
            print(f"Deneme {i+1}: Status {response.status_code}")
            
            if response.status_code == 429:  # Too Many Requests
                print("✅ Rate limiting çalışıyor! 429 Too Many Requests alındı.")
                break
            elif response.status_code == 400:
                print("   Geçersiz register bilgileri (beklenen)")
            else:
                print(f"   Beklenmeyen response: {response.text[:100]}")
                
        except requests.exceptions.RequestException as e:
            print(f"   Hata: {e}")
            
        time.sleep(1)  # 1 saniye bekle
    
    print()

def test_health_endpoint():
    """Health endpoint'inin çalışıp çalışmadığını kontrol eder"""
    url = "http://localhost:8000/api/health/"
    
    print("🏥 Health Endpoint Testi")
    print("=" * 30)
    
    try:
        response = requests.get(url, timeout=5)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            print("✅ Server çalışıyor")
            return True
        else:
            print(f"❌ Server problemi: {response.text}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Bağlantı hatası: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Rate Limiting Test Başlatılıyor...")
    print("=" * 60)
    
    # Önce server'ın çalışıp çalışmadığını kontrol et
    if not test_health_endpoint():
        print("\n❌ Server çalışmıyor. Önce 'python manage.py runserver' çalıştırın.")
        exit(1)
    
    print("\n")
    
    # Rate limiting testlerini çalıştır
    test_login_rate_limit()
    test_register_rate_limit()
    
    print("\n🎉 Test tamamlandı!")
    print("\n📋 Rate Limiting Özeti:")
    print("- Login: 5 deneme/dakika (IP bazlı)")
    print("- Register: 3 deneme/saat (IP bazlı)")
    print("- Şifre Değiştirme: 3 deneme/dakika (kullanıcı bazlı)")
    print("- Rapor Oluşturma: 10 rapor/saat (kullanıcı bazlı)")
    print("- Yorum Oluşturma: 5 yorum/dakika (kullanıcı bazlı)")