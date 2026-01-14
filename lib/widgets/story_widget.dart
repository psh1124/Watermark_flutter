import 'package:flutter/material.dart';

class StoryWidget extends StatelessWidget {
  final String username;
  final bool hasNewStory;
  final bool isMyStory;

  const StoryWidget({
    super.key,
    required this.username,
    this.hasNewStory = false,
    this.isMyStory = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 스토리 아바타
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasNewStory
                  ? const LinearGradient(
                      colors: [Color(0xFF667DEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasNewStory ? null : const Color(0xFFE0E0E0),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getAvatarColor(),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Center(
                child: _getAvatarIcon(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 사용자명
          Text(
            username,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor() {
    if (isMyStory) {
      return const Color(0xFFF0F0F0);
    }

    switch (username) {
      case 'john_doe':
        return const Color(0xFFD9D9D9);
      case 'jane_smith':
        return const Color(0xFFE81F63);
      default:
        return const Color(0xFFD9D9D9);
    }
  }

  Widget _getAvatarIcon() {
    return const Icon(
      Icons.person,
      size: 24,
      color: Color(0xFF999999),
    );
  }
}

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = [
      {'username': '내 스토리', 'hasNewStory': false, 'isMyStory': true},
      {'username': 'john_doe', 'hasNewStory': true, 'isMyStory': false},
      {'username': 'jane_smith', 'hasNewStory': true, 'isMyStory': false},
      {'username': 'user3', 'hasNewStory': false, 'isMyStory': false},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 20),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: stories.map((story) {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: StoryWidget(
                username: story['username'] as String,
                hasNewStory: story['hasNewStory'] as bool,
                isMyStory: story['isMyStory'] as bool,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
