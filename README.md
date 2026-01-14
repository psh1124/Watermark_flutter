# Watermark_flutter

워터마크 인스타그램 버전 Flutter 프로젝트입니다.

## 프로젝트 개요

이 프로젝트는 Flutter를 기반으로 한 모바일 및 데스크톱 워터마크 검출/삽입 앱입니다. 사용자가 이미지에서 숨겨진 워터마크를 검출하거나, 워터마크를 삽입할 수 있는 기능을 제공합니다.

주요 기능:
- 갤러리 이미지 선택 및 카메라 촬영
- 이미지 워터마크 검출
- 이미지 워터마크 삽입
- Android, iOS, Windows, Linux, macOS 지원

## 설치 및 실행

1. Flutter SDK 설치: [Flutter 설치 가이드](https://docs.flutter.dev/get-started/install)
2. 레포지토리 클론
   ```bash
   git clone https://github.com/psh1124/Watermark_flutter.git
   cd Watermark_flutter
   ```
3.필요한 패키지 설치
  ```bash
  flutter pub get
  ```
4. 디바이스 또는 에뮬레이터 선택 후 실행
  ```bash
  flutter run
  ```

5. 폴더 구조
   ```bash
   Watermark_flutter/
   ├─ android/               # Android 관련 설정 및 코드
   ├─ ios/                   # iOS 관련 설정 및 코드
   ├─ lib/                   # Flutter Dart 코드
   │  ├─ screens/            # 화면별 위젯
   │  ├─ widgets/            # 공통 UI 위젯
   │  └─ services/           # API 및 로컬 서비스
   ├─ assets/                # 이미지, 아이콘 등
   ├─ windows/ linux/ macos/  # 각 데스크톱 플랫폼 관련 코드
   ├─ pubspec.yaml           # Flutter 의존성 설정
   └─ README.md
   ```

## 기술 스택

Flutter & Dart

Android, iOS, Windows, Linux, macOS 플랫폼 지원

HTTP API 연동 (ApiService)

이미지 파일 관리 (FilePicker, MediaScanner)
