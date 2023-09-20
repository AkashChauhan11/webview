import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';

class Igschool extends StatefulWidget {
  const Igschool({super.key});

  @override
  State<Igschool> createState() => _WebViewState();
}

class _WebViewState extends State<Igschool> {
  bool isConnected = true;
  late InAppWebViewController controller;
  late PullToRefreshController refreshController;

  @override
  void initState() {
    getConnectivity();
    super.initState();
    refreshController = PullToRefreshController(
      onRefresh: () {
        controller.reload();
      },
    );
  }

  getConnectivity() async {
    final checker = InternetConnectionChecker();
    isConnected = await checker.hasConnection;

    checker.onStatusChange.listen((event) {
      setState(() {
        isConnected = event == InternetConnectionStatus.connected;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (!isConnected) {
          return showExitDialog();
        } else if (await controller.getUrl() ==
            Uri.parse('https://media.igschoolkaithal.com/')) {
          return showExitDialog();
        } else {
          controller.goBack();
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () async {
                if (!isConnected) {
                  showExitDialog();
                } else if (await controller.getUrl() ==
                    Uri.parse('https://media.igschoolkaithal.com/')) {
                  showExitDialog();
                } else {
                  controller.goBack();
                }
              },
              icon: const Icon(Icons.arrow_back)),
        ),
        body: !isConnected
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * 0.4,
                      child: LottieBuilder.asset(
                        "assets/json/no_internet.json",
                        animate: true,
                        repeat: true,
                      ),
                    ),
                    const Text("Internet Not Available!!"),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await controller.reload();
                        },
                        child: const Text("Reload"))
                  ],
                ),
              )
            : SizedBox(
                width: size.width,
                height: size.height,
                child: InAppWebView(
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                    transparentBackground: true,
                  )),
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  initialUrlRequest: URLRequest(
                    url: Uri.parse("https://media.igschoolkaithal.com/"),
                  ),
                  onWebViewCreated: (webcontroller) {
                    controller = webcontroller;
                  },
                  onLoadStart: (controller, url) {
                    refreshController.beginRefreshing();
                  },
                  onLoadStop: (controller, url) {
                    refreshController.endRefreshing();
                  },
                  pullToRefreshController: refreshController,
                ),
              ),
      ),
    );
  }

  Future<bool> showExitDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Are you sure want to exit app?"),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Exit"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Continue"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
