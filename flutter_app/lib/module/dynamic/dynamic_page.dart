import 'package:flutter/material.dart';

class DynamicPage extends StatefulWidget {
  const DynamicPage({super.key});

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('动态'), centerTitle: true),
      body: Center(
        child: Text('动态'),
      ),
    );
  }
}
