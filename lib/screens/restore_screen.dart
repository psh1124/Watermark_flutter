import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, String>? _analysisResult;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
        _startAnalysis();
      }
    } catch (e) {
      _showError('이미지를 선택할 수 없습니다: ${e.toString()}');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이미지 선택'),
          content: const Text('이미지를 가져올 방법을 선택하세요'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('갤러리'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('카메라'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    // QR 분석 시뮬레이션 (실제로는 백엔드 API 호출)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      _analysisResult = {
        'name': '김철수',
        'id': 'chulsoo123',
        'download_time': '2024-01-15 14:32:18',
        'download_ip': '192.168.1.105',
      };
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR코드 분석이 완료되었습니다!'),
          backgroundColor: Color(0xFF667DEB),
        ),
      );
    }
  }

  void _resetAnalysis() {
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
      _isAnalyzing = false;
    });
  }

  void _generateDocumentation() {
    if (_analysisResult == null) {
      _showError('분석 결과가 없습니다.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('보고서가 생성되었습니다!'),
        backgroundColor: Color(0xFF667DEB),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '딥페이크 추적',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildUploadSection(),
              if (_isAnalyzing) _buildAnalyzingSection(),
              if (_analysisResult != null) _buildResultSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '이미지 속 QR코드를 복원하여 최초 유포자를 찾습니다',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF8E8E8E),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        border: Border.all(
          color: const Color(0xFF667DEB),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(15),
          child: _selectedImage != null
              ? _buildSelectedImageView()
              : _buildUploadPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildSelectedImageView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _selectedImage!,
              width: 120,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            '이미지가 선택되었습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            'QR코드 분석을 시작합니다',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E8E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667DEB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text('다른 이미지 선택'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 50,
            color: Color(0xFF8E8E8E),
          ),
          SizedBox(height: 15),
          Text(
            '분석할 이미지를 업로드하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            'QR코드가 숨겨진 이미지를 선택해주세요',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E8E),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Icon(
            Icons.touch_app,
            size: 24,
            color: Color(0xFF667DEB),
          ),
          Text(
            '탭하여 파일 선택',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667DEB),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF667DEB)),
          SizedBox(height: 20),
          Text(
            'QR코드 분석 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '이미지에서 숨겨진 QR코드를 추출하고 있습니다',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8E8E8E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결과:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoItem('이름', _analysisResult!['name']!),
          _buildInfoItem('ID', _analysisResult!['id']!),
          _buildInfoItem('다운로드 시각', _analysisResult!['download_time']!),
          _buildInfoItem('다운로드 IP', _analysisResult!['download_ip']!),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667DEB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('새로 분석하기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _generateDocumentation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF667DEB),
                    side: const BorderSide(color: Color(0xFF667DEB), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('문서화하기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 