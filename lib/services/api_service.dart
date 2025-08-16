import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart'; // Removed due to build issues
import '../models/post.dart';
import '../config/env_config.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static String authToken = '';
  static String currentUser = '';
  static String sessionCookie = '';   // SESSION

  // JWT 토큰에서 사용자 정보 추출
  static String? _extractUserFromToken(String token) {
    try {
      print('=== JWT 토큰 디코딩 시작 ===');
      print('전체 토큰: $token');
      
      final parts = token.split('.');
      print('토큰 파트 개수: ${parts.length}');
      
      if (parts.length == 3) {
        // Base64 디코딩 (패딩 추가)
        String payload = parts[1];
        print('원본 payload: $payload');
        
        while (payload.length % 4 != 0) {
          payload += '=';
        }
        print('패딩 추가된 payload: $payload');
        
        // Base64 디코딩
        final decoded = utf8.decode(base64Url.decode(payload));
        print('디코딩된 payload: $decoded');
        
        final payloadMap = json.decode(decoded);
        print('JSON 파싱된 payload: $payloadMap');
        
        final user = payloadMap['sub']; // subject 필드에서 사용자명 추출
        print('추출된 사용자: $user');
        
        return user;
      } else {
        print('토큰 파트가 3개가 아님: ${parts.length}');
      }
    } catch (e) {
      print('JWT 토큰 디코딩 에러: $e');
      print('에러 타입: ${e.runtimeType}');
    }
    return null;
  }
  
  static Future<File?> embedWatermark({
  // required String username,
  required String text,
  required File imageFile,
}) async {
  if(sessionCookie.isEmpty || authToken.isEmpty){
    print('세션 또는 토큰이 없습니다. 로그인 필요함');
    return null;
  }
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(EnvConfig.watermarkUrl),
    );

    request.headers['Cookie'] = '$sessionCookie; Access-Token=$authToken; username=$currentUser';
    request.headers['Authorization'] = 'Bearer $authToken';

    final watermarkJson = json.encode({
      "username": currentUser,
      "text": text,
      "apikey": EnvConfig.apiKey, // 올바른 API 키 사용
    });
    request.fields['watermarkData'] = watermarkJson;

    
    // 디버깅을 위한 로그
    print('전송 필드 watermark.username: ${request.fields['watermark.username']}');
    print('전송 필드 watermark.content: ${request.fields['watermark.content']}');
    print('전송 필드 username: ${request.fields['username']}');
    print('전송 필드 content: ${request.fields['content']}');
    print('전송 필드 watermark: ${request.fields['watermark']}');
    print('요청 헤더에 전체 쿠키 추가: $sessionCookie');
    print('요청 헤더에 AccessToken 추가: $authToken');
    print('요청 헤더에 username 추가: $currentUser');
    print('요청 헤더에 watermarkData 추가: $text');

    final imageStream = http.ByteStream(imageFile.openRead());
    final imageLength = await imageFile.length();

    final multipartFile = http.MultipartFile(
      'imgfile',
      imageStream,
      imageLength,
      filename: 'post_image.jpg',
    );

    request.files.add(multipartFile);

    print('워터마크 API 요청 전송 중...');
    final response = await request.send().timeout(const Duration(seconds: 30));

    print('응답 상태 코드: ${response.statusCode}');
    if (response.statusCode == 200) {
      final responseBytes = await response.stream.toBytes();
      
      // 이미지를 Pictures 폴더에 저장 (사용자가 쉽게 찾을 수 있음)
      try {
        final directory = await getApplicationDocumentsDirectory();
        final picturesDir = Directory('${directory.path}/Pictures');
        
        // Pictures 폴더가 없으면 생성
        if (!await picturesDir.exists()) {
          await picturesDir.create(recursive: true);
        }
        
        final filePath = '${picturesDir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(responseBytes);
        
        print('워터마크 이미지가 Pictures 폴더에 저장되었습니다!');
        print('저장 경로: $filePath');
        print('이미지를 갤러리에서 확인하려면:');
        print('1. 에레이터에서 Files 앱 실행');
        print('2. Internal Storage > Android > data > com.example.waterpark_app > app_flutter > Pictures 폴더로 이동');
        print('3. watermark_[timestamp].jpg 파일 확인');
        
        return file;
      } catch (e) {
        print('Pictures 폴더 저장 중 오류: $e');
        // 오류 발생 시 임시 파일에 저장
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(responseBytes);
        print('오류로 인해 임시 파일에 저장: $filePath');
        return file;
      }
    } else {
      final errorResponse = await response.stream.bytesToString();
      print('워터마크 삽입 실패: HTTP ${response.statusCode}');
      print('에러 응답: $errorResponse');
      return null;
    }
  } catch (e) {
    print('워터마크 API 에러: $e');
    return null;
  }
}

  // 갤러리에 이미지 저장 (Flutter 기본 기능 사용)
  static Future<bool> _saveToGallery(File imageFile) async {
    try {
      print('=== 갤러리 저장 시작 ===');
      print('저장할 이미지 경로: ${imageFile.path}');
      
      print('워터마크 이미지가 다음 경로에 저장되었습니다:');
      print('${imageFile.path}');
      print('이미지를 갤러리에서 확인하려면 파일 관리자에서 해당 경로를 확인해주세요.');
      
      // 실제로는 저장 성공으로 처리 (파일은 이미 생성됨)
      return true;
    } catch (e) {
      print('=== 갤러리 저장 에러 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 내용: $e');
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
  try {
    final fingerprint = 'flutter_device_${DateTime.now().millisecondsSinceEpoch}';
    print('생성된 fingerprint: $fingerprint');

    final requestBody = {
      'username': 'seonghun8368',
      'password': 'qwer1234@!',
      'fingerprint': fingerprint,
    };
    print('요청 본문: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(EnvConfig.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final textResponse = response.body;
      print('응답이 성공(200)입니다. 응답 내용: "$textResponse"');

      if (textResponse == "Login successful") {
        // 쿠키 추출
        final cookies = response.headers['set-cookie'];
        print('=== 쿠키 추출 시작 ===');
        print('전체 쿠키: $cookies');
        print('-----------------');
        if (cookies != null) {
          final sessionMatch = RegExp(r'SESSION=([^;]+)').firstMatch(cookies);
          final accessTokenMatch = RegExp(r'Access-Token=([^;]+)').firstMatch(cookies);
          final usernameMatch = RegExp(r'username=([^;]+)').firstMatch(cookies);


          print('accessTokenMatch: ${accessTokenMatch?.group(1)}');
          print('sessionMatch: ${sessionMatch?.group(1)}');
          // print('usernameMatch: ${usernameMatch.group(1)}'); 


          print('-----------------2');
          if (sessionMatch != null) {
            sessionCookie = 'SESSION=${sessionMatch.group(1)}';
            print('SESSION 저장: $sessionCookie');
            print('-----------------3');
          }

          if (accessTokenMatch != null) {
            authToken = accessTokenMatch.group(1)!;
            print('AccessToken 저장: $authToken');
          }

          if (usernameMatch != null) {
            currentUser = usernameMatch.group(1)!;
            print('username 저장: $currentUser');
          }
        } else {
          print('쿠키가 없음');
          return false;
        }

        return true;
      } else {
        print('예상치 못한 응답: "$textResponse" (기대값: "Login successful")');
        return false;
      }
    } else {
      print('로그인 실패: HTTP ${response.statusCode}');
      print('실패 응답 본문: ${response.body}');
      return false;
    }
  } catch (e) {
    print('=== 로그인 API 에러 발생 ===');
    print('에러 타입: ${e.runtimeType}');
    print('에러 내용: $e');
    return false;
  }
}

  
  static Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      // 백엔드 연결 실패 시 더미 데이터 반환
      return _getDummyPosts();
    }
  }

// JWT 토큰 만료 여부 확인
static bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;

    String payload = parts[1];
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64Url.decode(payload));
    final payloadMap = json.decode(decoded);
    if (!payloadMap.containsKey('exp')) return true;

    final exp = payloadMap['exp'];
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final now = DateTime.now();

    print('토큰 만료 시간: $expiryDate');
    print('현재 시간: $now');
    return now.isAfter(expiryDate);
  } catch (e) {
    print('토큰 만료 확인 중 오류: $e');
    return true; // 오류 시 만료로 간주
  }
}


  static Future<File?> downloadPostImage(int postId) async {
  // 1️⃣ 토큰 만료 여부 먼저 체크
  if (authToken.isEmpty || isTokenExpired(authToken)) {
    print('⚠️ AccessToken이 없거나 만료됨. 재로그인 필요');
    return null;
  }

  final url = Uri.parse('$baseUrl/posts/$postId/download');
  try {
    final response = await http.get(
      url,
      headers: {
        'Cookie': sessionCookie,          // 세션 쿠키 포함
        'Authorization': 'Bearer $authToken', // JWT 토큰 포함
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/post_$postId.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      print('다운로드 실패: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('다운로드 에러: $e');
    return null;
  }
}

  
  static Future<bool> toggleLike(int postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['liked'] ?? false;
      } else {
        throw Exception('Failed to toggle like');
      }
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }
  
  static List<Post> _getDummyPosts() {
    return [
      Post(
        id: 1,
        username: 'john_doe',
        imageUrl: null,
        caption: 'john_doe 오늘 찍은 일몰 사진입니다 🌅',
        likeCount: 15,
        isLikedByUser: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 2,
        username: 'jane_smith',
        imageUrl: null,
        caption: 'jane_smith 새로 간 카페가 너무 예뻐요! ☕',
        likeCount: 24,
        isLikedByUser: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  // 워터마크 검출 API (DecodeWaterMark)
  static Future<String?> detectWatermark(File imageFile, String watermarkData) async {
    try {
      print('=== 워터마크 검출 시작 ===');
      print('이미지 파일 경로: ${imageFile.path}');
      
      // 1️⃣ 토큰 만료 여부 먼저 체크
      if (authToken.isEmpty || isTokenExpired(authToken)) {
        print('⚠️ AccessToken이 없거나 만료됨. 재로그인 필요');
        return null;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(EnvConfig.watermarkDetectionUrl),
      );

      // 인증 헤더 추가
      request.headers['Cookie'] = '$sessionCookie; Access-Token=$authToken; username=$currentUser';
      request.headers['Authorization'] = 'Bearer $authToken';

      // 이미지 파일 추가 (imgfile 필드명 사용)
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      
      final multipartFile = http.MultipartFile(
        'imgfile',
        imageStream,
        imageLength,
        filename: 'watermark_detection.jpg',
      );
      request.files.add(multipartFile);

      // watermarkData 필드 추가 (백엔드 명세에 따라 필수)
      request.fields['watermarkData'] = watermarkData;
      
      print('전송할 watermarkData: $watermarkData');

      print('워터마크 검출 API 요청 전송 중...');
      final response = await request.send().timeout(const Duration(seconds: 30));

      print('응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('워터마크 검출 성공! 응답: $responseBody');
        
        try {
          final data = json.decode(responseBody);
          if (data is Map<String, dynamic>) {
            // 서버 응답에서 워터마크 텍스트 추출
            if (data.containsKey('watermark')) {
              return data['watermark'];
            } else if (data.containsKey('text')) {
              return data['text'];
            } else if (data.containsKey('message')) {
              return data['message'];
            } else {
              print('응답에 워터마크 정보가 없습니다. 전체 응답: $data');
              return responseBody; // 전체 응답 반환
            }
          } else {
            return responseBody; // JSON이 아닌 경우 전체 응답 반환
          }
        } catch (e) {
          print('응답 파싱 중 오류: $e');
          return responseBody; // 파싱 실패 시 전체 응답 반환
        }
      } else {
        final errorResponse = await response.stream.bytesToString();
        print('워터마크 검출 실패: HTTP ${response.statusCode}');
        print('에러 응답: $errorResponse');
        return null;
      }
    } catch (e) {
      print('워터마크 검출 API 에러: $e');
      return null;
    }
  }
}