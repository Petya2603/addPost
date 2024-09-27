import 'dart:async';
import 'dart:io';
import 'package:addpost/Config/contstants/constants.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/home/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConnectionCheckView extends StatefulWidget {
  const ConnectionCheckView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnectionCheckViewState createState() => _ConnectionCheckViewState();
}

class _ConnectionCheckViewState extends State {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 4), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const HomeScreen();
              },
            ),
          );
        });
      }
    } on SocketException catch (_) {
      _showDialog();
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                padding: const EdgeInsets.only(top: 80, left: 15, right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 100,
                      color: grey2,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Нет соединение!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 1000),
                            () => checkConnection());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                      ),
                      child: Text(
                        'Попробуйте еще раз',
                        style: TextStyle(color: white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Lottie.asset(loading, width: 90, height: 90)));
  }
}
