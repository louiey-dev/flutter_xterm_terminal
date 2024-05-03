import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:flutter_xterm_terminal/page/menu_page.dart';
import 'package:flutter_xterm_terminal/page/terminal_page.dart';
import 'package:flutter_xterm_terminal/platform_menu.dart';
import 'package:xterm/xterm.dart';

void main() {
  runApp(const MyApp());
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xTerm Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const AppPlatformMenu(child: Home()),
      // home: Home(),
      // shortcuts: ,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(
      //   title: const Text("xTerm Terminal"),
      // ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            MenuPage(),
            SizedBox(height: 10),
            TerminalPage(),
          ],
        ),
      ),
    );
  }
}
