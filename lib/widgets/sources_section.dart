import 'package:flutter/material.dart';
import 'package:perplexity/services/chat_web_service.dart';
import 'package:perplexity/theme/colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SourcesSection extends StatefulWidget {
  const SourcesSection({super.key});

  @override
  State<SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<SourcesSection> {
  bool isLoading = true;
  final List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    ChatWebService().searchResultStream.listen((data) {
      final dynamic payload = data['data'];

      if (payload is List) {
        setState(() {
          searchResults.addAll(
            payload.cast<Map<String, dynamic>>(),
          );
          isLoading = false;
        });
      } else {
        debugPrint(
            'Unexpected format in search result: ${payload.runtimeType}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.source,
              color: Colors.white,
            ),
            SizedBox(width: 18),
            Text(
              'Sources',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        isLoading
            ? Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(4, (index) => _buildShimmerCard()),
              )
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: searchResults.map((res) {
                  return InkWell(
                    onTap: () async {
                      final Uri uri = Uri.parse(res['url']);
                      try {
                        await launchUrl(uri,
                            mode: LaunchMode.platformDefault);
                      } catch (e) {
                        debugPrint('Could not launch ${res['url']}: $e');
                      }
                    },
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            res['title'],
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            res['url'],
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  /// Widget shimmer loading giả lập card
  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
