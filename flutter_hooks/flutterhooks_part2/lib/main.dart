import 'dart:math';

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
    final opacity = useAnimationController(
      duration: const Duration(seconds: 1),
      initialValue: 1.0,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    final size = useAnimationController(
      duration: const Duration(seconds: 1),
      initialValue: 1.0,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    final controller = useScrollController();

    useEffect(() {
      controller.addListener(() {
        final newOpacity = max(imageHeight - controller.offset, 0.0);
        final normalized = newOpacity.normalized(0.0, imageHeight).toDouble();
        opacity.value = normalized;
        size.value = normalized;
      });
      return null;
    }, [controller]);

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
      body: Column(
        children: [
          SizeTransition(
            sizeFactor: size,
            axis: Axis.vertical,
            axisAlignment: -1.0,
            child: FadeTransition(
              opacity: opacity,
              child: Image.network(
                imageUrl,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    "Person ${index + 1}",
                    style: const TextStyle(color: Colors.white54),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

const imageUrl =
    'https://imgd-ct.aeplcdn.com/1056x660/n/cw/ec/127563/alto-k10-exterior-front-view.jpeg?isig=0&q=75';
const imageHeight = 300.0;

extension Normalize on num {
  num normalized(
    num selfRangeMin,
    num selfRangeMax, [
    num normalizedRangeMin = 0.0,
    num normalizedRangeMax = 1.0,
  ]) {
    return (normalizedRangeMax - normalizedRangeMin) *
            ((this - selfRangeMin) / (selfRangeMax - selfRangeMin)) +
        normalizedRangeMin;
  }
}
