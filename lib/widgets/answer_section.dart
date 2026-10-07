import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:perplexity/services/chat_web_service.dart';
import 'package:perplexity/theme/colors.dart';
import 'package:shimmer/shimmer.dart';

class AnswerSection extends StatefulWidget {
  const AnswerSection({super.key});

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String fullResponse = '';

  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    ChatWebService().contentStream.listen((data) {
      if (isLoading) {
        fullResponse = "";
      }

      setState(() {
        fullResponse += data['data'] ?? '';
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '------',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        isLoading
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _dotController,
                    builder: (context, child) {
                      int dots = (_dotController.value * 3).floor() + 1;
                      String text = "Đang suy nghĩ${'.' * dots}";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    },
                  ),
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade700,
                        highlightColor: Colors.grey.shade500,
                        child: Container(
                          width: double.infinity,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Markdown(
                data: fullResponse,
                shrinkWrap: true,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  codeblockDecoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  code: const TextStyle(fontSize: 16),
                  p: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
      ],
    );
  }
}