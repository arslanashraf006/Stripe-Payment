import 'package:flutter/material.dart';
import 'package:stripe_payment/views/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DashBoardScreen extends StatefulWidget {
  final String accountLink;
  const DashBoardScreen({super.key, required this.accountLink});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  WebViewController? _webViewController;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: widget.accountLink,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onProgress: (_) async {
          if (_webViewController != null) {
            String? url = await _webViewController!.currentUrl();
            if (url != null && url == 'https://api.stripe.com/') {
              //Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return HomeScreen();
              }));
            }
          }
        },
      ),
    );
  }
}