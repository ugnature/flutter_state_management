import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Hooks'),
    ),
  );
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    late final StreamController<double> controller;
    controller = useStreamController<double>(
      onListen: () {
        controller.sink.add(0);
      },
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      body: StreamBuilder<double>(
        stream: controller.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            final rotation = snapshot.data ?? 0.0;
            return GestureDetector(
              onTap: () {
                controller.sink.add(rotation + 10.0);
              },
              child: RotationTransition(
                  turns: AlwaysStoppedAnimation(rotation / 360),
                  child: Center(child: Image.network(imageUrlLink))),
            );
          }
        },
      ),
    );
  }
}

const imageUrlLink =
    'https://cdn.dribbble.com/users/1875232/screenshots/15296613/media/1dd002f70b4dae1bb35a2a29375c916b.png';
