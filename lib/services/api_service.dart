import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../models/post.dart';
import '../config/env_config.dart';
import 'media_scanner.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static String authToken = '';
  static String currentUser = '';
  static String sessionCookie = '';

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
      return _getDummyPosts();
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
          final cookies = response.headers['set-cookie'];
          print('=== 쿠키 추출 시작 ===');

          if (cookies != null) {
            final sessionMatch = RegExp(r'SESSION=([^;]+)').firstMatch(cookies);
            final accessTokenMatch = RegExp(r'Access-Token=([^;]+)').firstMatch(cookies);
            final usernameMatch = RegExp(r'username=([^;]+)').firstMatch(cookies);
  
            print('sessionMatch: ${sessionMatch?.group(1)}');
  
            if (sessionMatch != null) {
              sessionCookie = 'SESSION=${sessionMatch.group(1)}';
              print('SESSION 저장: $sessionCookie');
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


static Future<File?> saveImageToGallery(File imageFile) async {
  if (Platform.isAndroid && !(await Permission.photos.request()).isGranted) {
    print('저장 권한이 필요합니다.');
    return null;
  }

  try {
    final bytes = await imageFile.readAsBytes();

    final directory = Directory('/storage/emulated/0/Pictures/WaterparkApp');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final filePath =
        '${directory.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Android 미디어 스캐너 호출
    await MediaScanner.scanFile(file.path);

    print('이미지 저장 및 갤러리 반영 완료: $filePath');
    return file;
  } catch (e) {
    print('이미지 저장 에러: $e');
    return null;
  }
}


  // JWT 토큰에서 사용자 정보 추출
  // static String? _extractUserFromToken(String token) {
  //   try {
  //     print('=== JWT 토큰 디코딩 시작 ===');
  //     print('전체 토큰: $token');
      
  //     final parts = token.split('.');
  //     print('토큰 파트 개수: ${parts.length}');
      
  //     if (parts.length == 3) {
  //       // Base64 디코딩 (패딩 추가)
  //       String payload = parts[1];
  //       print('원본 payload: $payload');
        
  //       while (payload.length % 4 != 0) {
  //         payload += '=';
  //       }
  //       print('패딩 추가된 payload: $payload');
        
  //       // Base64 디코딩
  //       final decoded = utf8.decode(base64Url.decode(payload));
  //       print('디코딩된 payload: $decoded');
        
  //       final payloadMap = json.decode(decoded);
  //       print('JSON 파싱된 payload: $payloadMap');
        
  //       final user = payloadMap['sub']; // subject 필드에서 사용자명 추출
  //       print('추출된 사용자: $user');
        
  //       return user;
  //     } else {
  //       print('토큰 파트가 3개가 아님: ${parts.length}');
  //     }
  //   } catch (e) {
  //     print('JWT 토큰 디코딩 에러: $e');
  //     print('에러 타입: ${e.runtimeType}');
  //   }
  //   return null;
  // }


  static Future<File?> embedWatermark({
    String text = '',
    required File imageFile,
  }) async {
    if(sessionCookie.isEmpty || authToken.isEmpty){
      print('세션 또는 토큰이 없습니다. 로그인 필요함');
      return null;
    }

    if (Platform.isAndroid && (await Permission.photos.request()).isGranted) {
      print('Storage permission granted (Android 10 이하)');
    }
    else {
      print('저장 권한이 필요합니다.');
      return null;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(EnvConfig.watermarkEmbedUrl),
      );

      request.headers['Cookie'] = '$sessionCookie; Access-Token=$authToken; username=$currentUser';
      request.headers['Authorization'] = 'Bearer $authToken';

      request.fields['watermarkData'] = json.encode({
        "username": currentUser,
        "text": json.encode({
          "originalUsername": "john_doe",
          "SNS": "Instagram",
          "createdAt": "2025-08-18T18:31:27"
        }),
        "apikey": EnvConfig.apiKey,
      });

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

      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();

        final directory = Directory('/storage/emulated/0/Pictures/WaterparkApp');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final filePath = '${directory.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File(filePath);
        await file.writeAsBytes(responseBytes);

        await MediaScanner.scanFile(file.path);

        print('워터마크 이미지 저장 완료 및 갤러리 반영: $filePath');
        return file;
      } else {
        final errorResponse = await response.stream.bytesToString();
        print('워터마크 삽입 실패: HTTP ${response.statusCode}, $errorResponse');
        return null;
      }
    } catch (e) {
      print('워터마크 API 에러: $e');
      return null;
    }
  }

  static Future<String?> detectWatermark(File imageFile, String watermarkData) async {
    try {
      print('=== 워터마크 검출 시작 ===');
      print('이미지 파일 경로: ${imageFile.path}');

      if (authToken.isEmpty || isTokenExpired(authToken)) {
        print('⚠️ AccessToken이 없거나 만료됨. 재로그인 필요');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${EnvConfig.watermarkDetectionUrl}'),
      );
      
      request.headers['Authorization'] = 'Bearer $authToken';
      request.headers['Cookie'] = '$sessionCookie; Access-Token=$authToken; username=$currentUser';
      request.fields['watermarkData'] = json.encode({
        "username": currentUser,
        "apikey": EnvConfig.apiKey,
      });;
      final multipartFile = await http.MultipartFile.fromPath(
        'imgfile',
        imageFile.path,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      print('전송 데이터 확인:');
      print('- watermarkData: ${request.fields['watermarkData']}');
      print('- imgfile: ${multipartFile.filename}');

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print(response);

        try {
          final data = json.decode(responseBody);
          print(data);
          String textStr = data['text'] ?? '';
          String originalUsername = 'unknown';
          String sns = 'unknown';
          String createdAt = 'unknown';

          final regExp = RegExp(r'"(\w+)":"([^"]*)"');
          for (final match in regExp.allMatches(textStr)) {
            final key = match.group(1);
            final value = match.group(2);
            if (key == 'originalUsername') originalUsername = value!;
            if (key == 'SNS') sns = value!;
            if (key == 'createdAt') createdAt = value!;
          }
          final result =
              '🕒 검출 시간: ${DateTime.now()}\n'
              '🧬 워터마크 해시: ${data['hash'] ?? 'N/A'}\n'
              '💬 삽입된 문구:\n'
              '   - photo_owner : $originalUsername\n'
              '   - savedByUser : ${data['username'] ?? 'unknown'}\n'
              '   - SNS         : $sns\n'
              '   - createdAt   : $createdAt\n'
              '📁 원본 파일명: ${path.basename(imageFile.path)}\n'
              '🕒 사진 업로드 날짜(최초)   : ${data['createdAt'] ?? 'unknown'}';
          return result;
        } catch (e) {
          return responseBody;
        }
      } else {
        print('워터마크 검출 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        print('⚠️ 요청 시간 초과 - 네트워크 연결을 확인해주세요.');
      } else {
        print('워터마크 검출 API 에러: $e');
      }
      return null;
    }
  }

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
      return true;
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
}