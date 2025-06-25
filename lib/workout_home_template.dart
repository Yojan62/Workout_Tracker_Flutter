import 'package:flutter/material.dart';

class WorkoutHomeTemplate extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? fabLeft;
  final Widget? fabRight;

  const WorkoutHomeTemplate({
    super.key,
    required this.title,
    required this.children,
    this.fabLeft,
    this.fabRight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (fabLeft != null)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: fabLeft!,
            ),
          if (fabRight != null) fabRight!,
        ],
      ),
    );
  }
}