import 'package:flutter/material.dart';
import '../widgets/story_widget.dart';
import '../widgets/post_widget.dart';
import '../widgets/bottom_navigation.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'restore_screen.dart';
import 'watermark_detection_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentNavIndex = 0;
  List<Post> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await ApiService.getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildMainContent()),
            CustomBottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFDBDBDB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 앱 제목
          const Text(
            'WaterPark SNS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          // 로그인 버튼
          ElevatedButton(
            onPressed: () {
              print('=== 헤더 로그인 버튼 클릭됨 ===');
              _showLoginDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667DEB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '로그인',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const StoriesSection(),
            const SizedBox(height: 20),
            _buildFeedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: CircularProgressIndicator(color: Color(0xFF667DEB)),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Text(
            '게시글이 없습니다',
            style: TextStyle(fontSize: 16, color: Color(0xFF8F8F8F)),
          ),
        ),
      );
    }

    return Column(
      children: _posts.map((post) {
        return PostWidget(post: post, onLikeToggle: () {});
      }).toList(),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    
    if (index == 1) { // 워터마크 검출 탭
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WatermarkDetectionScreen()),
      );
    } else if (index == 2) { // 프로필 탭
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필 기능이 곧 제공됩니다!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF667DEB),
        ),
      );
    }
  }

  String _getNavTitle(int index) {
    switch (index) {
      case 1: return '워터마크 검출';
      case 2: return '프로필';
      default: return '홈';
    }
  }

  // 로그인 다이얼로그 표시
  void _showLoginDialog() {
    print('=== 헤더 로그인 다이얼로그 표시 ===');
    
    final usernameController = TextEditingController(text: 'seonghun8368');
    final passwordController = TextEditingController(text: 'qwer1234@!');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('로그인 취소 버튼 클릭');
              Navigator.pop(context);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('헤더 로그인 버튼 클릭 - 로그인 처리 시작');
              await _handleHeaderLogin(usernameController.text, passwordController.text);
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  // 헤더 로그인 처리
  Future<void> _handleHeaderLogin(String username, String password) async {
    print('=== 헤더 로그인 처리 시작 ===');
    print('입력된 사용자명: $username');
    print('입력된 비밀번호 길이: ${password.length}');
    
    if (username.isEmpty || password.isEmpty) {
      print('로그인 실패: 사용자명 또는 비밀번호가 비어있음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요')),
      );
      return;
    }

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print('=== 헤더 로그인 API 호출 시작 ===');
      final success = await ApiService.login(username, password);
      
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      
      if (success) {
        print('헤더 로그인 성공!');
        // 로그인 성공 시 다이얼로그 닫기
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username님, 로그인 성공!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('헤더 로그인 실패: 백엔드에서 실패 응답');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 실패. 아이디와 비밀번호를 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('=== 헤더 로그인 에러 발생 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 내용: $e');
      
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 