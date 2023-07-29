import 'dart:developer' as dev show log;
import 'dart:math' show Random;
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',          
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 123, 31)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var color1 = Colors.yellow;
  var color2 = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Inherited Model"),
      ),
      body: AvailableColorsWidgetModel(
        color1: color1,
        color2: color2,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        color1 = colors.getRandomElement();
                      });
                    },
                    child: const Text(
                      "Change Color1",
                      style: TextStyle(fontSize: 12),
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        color2 = colors.getRandomElement();
                      });
                    },
                    child: const Text(
                      "Change Color2",
                      style: TextStyle(fontSize: 12),
                    ))
              ],
            ),
            const ColorWidget(color: AvailableColors.one),
            const ColorWidget(color: AvailableColors.two),
          ],
        ),
      ),
    );
  }
}

enum AvailableColors { one, two }

class AvailableColorsWidgetModel extends InheritedModel<AvailableColors> {
  final MaterialColor color1;
  final MaterialColor color2;

  const AvailableColorsWidgetModel(
      {Key? key,
      required this.color1,
      required this.color2,
      required Widget child})
      : super(key: key, child: child);

  static AvailableColorsWidgetModel of(
    BuildContext context,
    AvailableColors aspect,
  ) {
    return InheritedModel.inheritFrom<AvailableColorsWidgetModel>(context,
        aspect: aspect)!;
  }

  @override
  bool updateShouldNotify(covariant AvailableColorsWidgetModel oldWidget) {
    dev.log('updateShouldNotify');
    return color1 != oldWidget.color1 || color2 != oldWidget.color2;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant AvailableColorsWidgetModel oldWidget,
    Set<AvailableColors> dependencies,
  ) {
    dev.log('updateShouldNotifyDependent');
    if (dependencies.contains(AvailableColors.one) &&
        color1 != oldWidget.color1) {
      return true;
    } else if (dependencies.contains(AvailableColors.two) &&
        color2 != oldWidget.color2) {
      return true;
    } else {
      return false;
    }
  }
}

class ColorWidget extends StatelessWidget {
  final AvailableColors color;

  const ColorWidget({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (color) {
      case AvailableColors.one:
        dev.log('Color1 widget rebuild');
        break;
      case AvailableColors.two:
        dev.log("Color2 widget rebuild");
        break;
    }
    final provider = AvailableColorsWidgetModel.of(context, color);
    return Container(
      height: 50,
      color: color == AvailableColors.one ? provider.color1 : provider.color2,
    );
  }
}

final colors = [
  Colors.blue,
  Colors.red,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.cyan,
  Colors.brown,
  Colors.amber,
  Colors.deepPurple,
];

extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(Random().nextInt(length));
}
