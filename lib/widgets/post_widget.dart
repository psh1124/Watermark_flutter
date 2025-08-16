import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../config/env_config.dart';
import 'dart:io'; // Added for File
import 'package:http/http.dart' as http; // Added for http
import 'package:path_provider/path_provider.dart'; // Added for getTemporaryDirectory

class PostWidget extends StatefulWidget {
  final Post post;
  final VoidCallback? onLikeToggle;
  
  const PostWidget({
    super.key,
    required this.post,
    this.onLikeToggle,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isLiked = false;
  int _likeCount = 0;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLikedByUser;
    _likeCount = widget.post.likeCount;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 메뉴 외부 클릭 시 드롭다운 닫기
        if (_showDropdown) {
          setState(() {
            _showDropdown = false;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(),
                _buildPostImage(),
                _buildActionButtons(),
                _buildCaptionSection(),
              ],
            ),
            if (_showDropdown) _buildDropdownMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getProfileColor(),
            ),
            child: const Icon(
              Icons.person,
              size: 20,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.post.getTimeAgo(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8F8F8F),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              print('=== 점 세개 버튼 클릭됨 ===');
              print('현재 포스트: ${widget.post.username}');
              print('드롭다운 메뉴를 표시합니다.');
              
              setState(() {
                _showDropdown = !_showDropdown;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text(
                '⋯',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF808080),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _getImageUrl().startsWith('assets/') 
          ? Image.asset(
              _getImageUrl(),
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.error,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
              },
            )
          : Image.network(
              _getImageUrl(),
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.error,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
              },
            ),
      ),
    );
  }

  String _getImageUrl() {
    switch (widget.post.username) {
      case 'john_doe':
        // Local asset - 첫 번째 아시아인 사진
        return 'assets/images/asian.jpg';
      case 'jane_smith':
        // Local asset - 두 번째 아시아인 사진
        return 'assets/images/asian2.jpg';
      default:
        return 'https://picsum.photos/id/65/300/300';
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              size: 24,
              color: _isLiked ? const Color(0xFFE81F63) : const Color(0xFF4D4D4D),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.chat_bubble_outline, size: 24, color: Color(0xFF4D4D4D)),
          const SizedBox(width: 20),
          const Icon(Icons.send, size: 24, color: Color(0xFF4D4D4D)),
        ],
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_likeCount명이 좋아합니다',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.caption,
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildDropdownMenu() {
    return Positioned(
      top: 60,
      right: 15,
      child: GestureDetector(
        onTap: () {
          // 메뉴 내부 클릭 시 아무것도 하지 않음 (메뉴가 닫히지 않도록)
        },
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
          ),
          child: Column(
            children: [
              _buildDropdownItem('◉', '정보'),
              _buildDropdownItem('↓', '다운로드'),
              _buildDropdownItem('●', '설정'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(String icon, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDropdown = false;
        });

        if (title == '다운로드') {
          _handleWatermarkDownload();  // 워터마크 다운로드 함수 호출
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('$title 선택됨'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333))),
          ],
        ),
      ),
    );
  }

  // 워터마크 다운로드 처리
  // 워터마크 다운로드 처리 (수정 버전)
Future<void> _handleWatermarkDownload() async {
  print('=== 워터마크 다운로드 시작 ===');
  print('포스트 캡션: ${widget.post.caption}');
  
  try {
    // 현재 포스트의 이미지를 가져오기
    final imageFile = await _getCurrentPostImage();
    
    if (imageFile == null) {
      print('이미지 파일을 가져올 수 없습니다.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지를 가져올 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('이미지 파일 경로: ${imageFile.path}');
    
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('워터마크 삽입 중...'),
          ],
        ),
      ),
    );
    
    // 워터마크 삽입 API 호출
    final watermarkImage = await ApiService.embedWatermark(
      // username: widget.post.username,
      text: widget.post.caption,
      imageFile: imageFile,
    );
    
    // 로딩 다이얼로그 닫기
    Navigator.pop(context);
    
    if (watermarkImage != null) {
      print('워터마크 이미지 생성 성공: ${watermarkImage.path}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('워터마크가 삽입된 이미지가 생성되었습니다!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '파일 경로',
            textColor: Colors.white,
            onPressed: () {
              print('워터마크 이미지 경로: ${watermarkImage.path}');
              _showImagePathInfo(watermarkImage.path);
            },
          ),
        ),
      );
    } else {
      print('워터마크 이미지 생성 실패');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('워터마크 삽입에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('=== 워터마크 다운로드 에러 발생 ===');
    print('에러 타입: ${e.runtimeType}');
    print('에러 내용: $e');
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('워터마크 다운로드 중 오류가 발생했습니다: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  // 현재 포스트의 이미지 파일 가져오기
  Future<File?> _getCurrentPostImage() async {
    try {
      final imageUrl = _getImageUrl();
      print('이미지 URL: $imageUrl');
      
      if (imageUrl.startsWith('assets/')) {
        // 로컬 에셋 이미지인 경우
        print('로컬 에셋 이미지 처리 시작: $imageUrl');
        
        try {
          // assets를 ByteData로 읽기
          print('rootBundle.load() 호출 중...');
          final ByteData data = await rootBundle.load(imageUrl);
          print('ByteData 로드 완료, 크기: ${data.lengthInBytes} bytes');
          
          final List<int> bytes = data.buffer.asUint8List();
          print('바이트 배열 변환 완료, 크기: ${bytes.length} bytes');
          
          // 임시 파일로 저장
          print('임시 디렉토리 가져오는 중...');
          final directory = await getTemporaryDirectory();
          print('임시 디렉토리: ${directory.path}');
          
          final imagePath = '${directory.path}/asset_${widget.post.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          print('저장할 이미지 경로: $imagePath');
          
          final imageFile = File(imagePath);
          print('File 객체 생성 완료');
          
          print('바이트를 파일에 쓰는 중...');
          await imageFile.writeAsBytes(bytes);
          print('로컬 에셋 이미지 임시 저장 완료: $imagePath');
          
          // 파일이 실제로 생성되었는지 확인
          final exists = await imageFile.exists();
          print('파일 존재 여부: $exists');
          
          if (exists) {
            final fileSize = await imageFile.length();
            print('저장된 파일 크기: $fileSize bytes');
            return imageFile;
          } else {
            print('파일이 생성되지 않았습니다.');
            return null;
          }
        } catch (assetError) {
          print('에셋 처리 중 에러 발생: $assetError');
          print('에러 타입: ${assetError.runtimeType}');
          return null;
        }
      } else {
        // 네트워크 이미지인 경우
        print('네트워크 이미지 처리 시작: $imageUrl');
        
        try {
          // 이미지를 다운로드하여 임시 파일로 저장
          print('HTTP GET 요청 시작...');
          final response = await http.get(Uri.parse(imageUrl));
          print('HTTP 응답 상태 코드: ${response.statusCode}');
          
          if (response.statusCode == 200) {
            print('이미지 다운로드 성공, 크기: ${response.bodyBytes.length} bytes');
            
            final directory = await getTemporaryDirectory();
            final imagePath = '${directory.path}/post_${widget.post.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final imageFile = File(imagePath);
            
            await imageFile.writeAsBytes(response.bodyBytes);
            print('네트워크 이미지 임시 저장 완료: $imagePath');
            return imageFile;
          } else {
            print('HTTP 요청 실패: ${response.statusCode}');
            return null;
          }
        } catch (networkError) {
          print('네트워크 이미지 처리 중 에러 발생: $networkError');
          print('에러 타입: ${networkError.runtimeType}');
          return null;
        }
      }
    } catch (e) {
      print('=== 이미지 파일 가져오기 전체 에러 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 내용: $e');
      return null;
    }
  }


  // 갤러리 앱 열기
  void _openGallery() {
    print('=== 갤러리 앱 열기 시도 ===');
    try {
      // Android에서는 갤러리 앱을 직접 열 수 있습니다
      // iOS에서는 제한이 있을 수 있습니다
      print('갤러리 앱을 열어주세요. 워터마크 이미지가 "WaterPark SNS" 앨범에 저장되었습니다.');
      
      // 사용자에게 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('갤러리 앱에서 "WaterPark SNS" 앨범을 확인해보세요!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('갤러리 열기 에러: $e');
    }
  }

  // 워터마크 이미지 경로 정보 표시
  void _showImagePathInfo(String imagePath) {
    print('=== 워터마크 이미지 경로 정보 표시 ===');
    print('이미지 경로: $imagePath');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('워터마크 이미지 생성 완료'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('워터마크가 삽입된 이미지가 다음 경로에 저장되었습니다:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                imagePath,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '이미지를 확인하려면:\n'
              '1. 파일 관리자에서 해당 경로 확인\n'
              '2. 또는 터미널에서 경로 복사하여 확인',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Color _getProfileColor() {
    switch (widget.post.username) {
      case 'john_doe': return const Color(0xFF667DEB);
      case 'jane_smith': return const Color(0xFFE81F63);
      default: return const Color(0xFFD9D9D9);
    }
  }

  Color _getImageColor() {
    switch (widget.post.username) {
      case 'john_doe': return const Color(0xFFD9A6F2);
      case 'jane_smith': return const Color(0xFF66CCBA);
      default: return const Color(0xFFD9D9D9);
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });
  }
} 