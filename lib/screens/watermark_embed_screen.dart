import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/media_scanner.dart';

class WatermarkEmbedScreen extends StatefulWidget {
  final String username;
  const WatermarkEmbedScreen({super.key, required this.username});

  @override
  State<WatermarkEmbedScreen> createState() => _WatermarkEmbedScreenState();
}

class _WatermarkEmbedScreenState extends State<WatermarkEmbedScreen> {
  File? _selectedImage;
  bool _isEmbedding = false;
  File? _watermarkedImage;
  String? _embeddingError;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _watermarkTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          '워터마크 삽입',
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
                        '워터마크 삽입',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '이미지를 선택하고 원하는 문구를 입력하여\n워터마크를 삽입할 수 있습니다.',
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

                // 워터마크 입력
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _watermarkTextController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '워터마크 문구를 입력하세요',
                    ),
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
                        onTap: _takePhoto,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 선택된 이미지 표시
                if (_selectedImage != null) ...[
                  _buildSelectedImageSection(),
                  const SizedBox(height: 24),
                  _buildEmbeddingButton(),
                ],

                const SizedBox(height: 24),

                // 삽입 결과 표시
                if (_watermarkedImage != null) _buildSuccessResult(),

                // 에러 메시지 표시
                if (_embeddingError != null) _buildErrorResult(),

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
                      _watermarkedImage = null;
                      _embeddingError = null;
                      _watermarkTextController.clear();
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
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddingButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: _isEmbedding 
          ? null 
          : const LinearGradient(
              colors: [Color(0xFF667DEB), Color(0xFF5A67D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _isEmbedding ? null : _embedWatermark,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isEmbedding ? Colors.grey[300] : Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isEmbedding
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text(
                  '삽입 중...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : const Text(
              '워터마크 삽입 및 다운로드 하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  Widget _buildSuccessResult() {
    return Column(
      children: [
        const Text(
          '워터마크 삽입 성공!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
        ),
        const SizedBox(height: 12),
        if (_watermarkedImage != null)
          Image.file(_watermarkedImage!, height: 200),
      ],
    );
  }

  Widget _buildErrorResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        _embeddingError!,
        style: const TextStyle(color: Colors.red, fontSize: 14),
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
              child: Icon(icon, size: 24, color: const Color(0xFF667DEB)),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _embedWatermark() async {
    if (_selectedImage == null) return;

    setState(() {
      _isEmbedding = true;
      _embeddingError = null;
    });

    try {
      final result = await ApiService.embedWatermark(
        imageFile: _selectedImage!,
      );

      setState(() {
        _watermarkedImage = result;
      });
    } catch (e) {
      setState(() {
        _embeddingError = '워터마크 삽입 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isEmbedding = false;
      });
    }
  }

  @override
  void dispose() {
    _watermarkTextController.dispose();
    super.dispose();
  }
}