import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../services/api_service.dart';
import 'package:path/path.dart' as path;
import '../services/media_scanner.dart';

class WatermarkDetectionScreen extends StatefulWidget {
  const WatermarkDetectionScreen({super.key});

  @override
  State<WatermarkDetectionScreen> createState() =>
      _WatermarkDetectionScreenState();
}

class _WatermarkDetectionScreenState extends State<WatermarkDetectionScreen> {
  File? _selectedImage;
  bool _isDetecting = false;
  String? _detectedWatermark;
  String? _detectionError;
  final TextEditingController _watermarkDataController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          '워터마크 검출',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context, 0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상단 설명
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF667DEB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          size: 36,
                          color: Color(0xFF667DEB),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '워터마크 검출',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '워터마크가 삽입된 이미지를 선택하여\n숨겨진 정보를 검출할 수 있습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 이미지 선택/촬영 버튼들
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_outlined,
                        title: '갤러리에서 선택',
                        onTap: _selectFromGallery,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.camera_alt_outlined,
                        title: '사진 촬영',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 선택된 이미지 표시
                if (_selectedImage != null) ...[
                  _buildSelectedImageSection(),
                  const SizedBox(height: 24),
                  _buildDetectionButton(),
                ],

                const SizedBox(height: 24),

                // 검출 결과 표시
                if (_detectedWatermark != null) _buildSuccessResult(),

                // 에러 메시지 표시
                if (_detectionError != null) _buildErrorResult(),

                const SizedBox(height: 20), // 하단 여백
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '선택된 이미지',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _detectedWatermark = null;
                      _detectionError = null;
                      _watermarkDataController.clear();
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFF667DEB),
                  ),
                  label: const Text(
                    '변경',
                    style: TextStyle(
                      color: Color(0xFF667DEB),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            constraints: const BoxConstraints(
              maxHeight: 280,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '이미지를 불러올 수 없습니다',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: _isDetecting
            ? null
            : const LinearGradient(
                colors: [Color(0xFF667DEB), Color(0xFF5A67D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isDetecting
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF667DEB).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isDetecting ? null : _detectWatermark,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isDetecting ? Colors.grey[300] : Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isDetecting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '검출 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '워터마크 검출하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessResult() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth, // 부모 Column의 폭에 맞춤
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50).withOpacity(0.1),
                const Color(0xFF66BB6A).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '워터마크 검출 성공!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '검출된 정보:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _detectedWatermark ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF44336).withOpacity(0.1),
            const Color(0xFFEF5350).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF44336).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '✅ 검출된 데이터가 확인되었습니다.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF44336).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _detectionError!,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF667DEB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF667DEB),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final File originalFile = File(result.files.single.path!);

        final directory =
            Directory('/storage/emulated/0/Pictures/WaterparkApp');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final externalPath =
            '${directory.path}/${path.basename(originalFile.path)}';
        final File externalFile = await originalFile.copy(externalPath);

        await MediaScanner.scanFile(externalFile.path);

        setState(() {
          _selectedImage = externalFile;
        });

        debugPrint(
          '_selectedImage 값 (갤러리 외부 경로): ${_selectedImage!.path}',
        );
      } else {
        debugPrint('이미지 선택이 취소되었습니다.');
      }
    } catch (e) {
      debugPrint('갤러리에서 이미지 선택 중 오류 발생: $e');
    }
  }

  Future<void> _detectWatermark() async {
    if (_selectedImage == null) return;

    setState(() {
      _isDetecting = true;
      _detectedWatermark = null;
    });

    debugPrint('=== 워터마크 검출 시작 ===');
    debugPrint('이미지 경로: ${_selectedImage!.path}');

    try {
      final result = await ApiService.detectWatermark(
        _selectedImage!,
        '',
      );
      await Future.delayed(const Duration(seconds: 3));
      if (result != null) {
        debugPrint('워터마크 검출 성공 : $result');
        setState(() {
          _detectedWatermark = result;
        });
      } else {
        debugPrint('워터마크 검출 결과 없음');
        setState(() {
          _detectedWatermark = '워터마크가 검출되지 않았습니다.';
        });
      }
    } catch (e, stack) {
      debugPrint('워터마크 검출 중 예외 발생: $e');
      debugPrint(stack.toString());

      setState(() {
        _detectedWatermark = '워터마크 검출에 실패했습니다. 다시 시도해주세요.';
      });
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _watermarkDataController.dispose();
    super.dispose();
  }
}
