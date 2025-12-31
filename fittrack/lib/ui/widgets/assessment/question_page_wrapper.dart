import 'package:flutter/material.dart';

// ====================
// 1. QUESTION PAGE WRAPPER
// ====================
class QuestionPageWrapper extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onNext;
  final bool isLastPage;

  const QuestionPageWrapper({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.onNext,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          ],
          const SizedBox(height: 40),
          Expanded(child: child),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onNext,
              child: Text(
                isLastPage ? 'Complete' : 'Continue',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}