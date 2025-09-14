import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'maain_shell.dart'; // MainShell.of(context) 사용

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});
  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  late final WebViewController controller;

  void _handleBackToMain() {
    final shell = MainShell.of(context);
    if (shell != null) {
      shell.jumpTo(0);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleBack() {
    final shell = MainShell.of(context);
    if (shell != null) {
      shell.jumpTo(0);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://tukorea.ac.kr/tukorea/7607/subview.do'),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _handleBack,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.close, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),


                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '공지사항',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),


                          IconButton(
                            tooltip: '새로고침',
                            onPressed: () => controller.reload(),
                            icon: const Icon(Icons.refresh, size: 20),
                            color: Colors.black54,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),


                          IconButton(
                            tooltip: '뒤로가기',
                            onPressed: () async {
                              if (await controller.canGoBack()) {
                                await controller.goBack();
                              } else {
                                _handleBackToMain();
                              }
                            },
                            icon: const Icon(Icons.arrow_back, size: 20),
                            color: Colors.black54,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}