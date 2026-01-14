import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 0.5, 
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, '🏠', '홈', const Color(0xFF667DEB)),
          _buildNavItem(1, '➕', '워터마크 삽입', const Color(0xFFFF9800)),
          _buildNavItem(2, '🔍', '워터마크 검출', const Color(0xFFFF9800)),
          _buildNavItem(3, '👤', '프로필', const Color(0xFF8F8F8F)),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label, Color activeColor) {
    final isSelected = currentIndex == index;
    final color = isSelected ? activeColor : const Color(0xFFB0B0B0);
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 70, // 너비 조정
        height: 50, // 높이를 50으로 증가
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 추가
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: isSelected ? 22 : 20, // 크기 더 줄임
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
            const SizedBox(height: 1), // 간격 더 줄임
            Text(
              label,
              style: TextStyle(
                fontSize: 9, // 폰트 크기 더 줄임
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 