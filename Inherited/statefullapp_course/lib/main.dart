import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme:
          ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 5, 195, 8)),
      useMaterial3: true,
    ),
    home: ApiProvider(
      api: Api(),
      child: const MyHomePage(),
    ),
  ));
}

class ApiProvider extends InheritedWidget {
  final Api api;
  final String uuid;

  ApiProvider({Key? key, required this.api, required Widget child})
      : uuid = const Uuid().v4(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant ApiProvider oldWidget) {
    return uuid != oldWidget.uuid;
  }

  static ApiProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiProvider>()!;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueKey _textKey = const ValueKey<String?>(null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          ApiProvider.of(context).api.dateAndTime ?? '',
          style: const TextStyle(fontSize: 12, color: Colors.blue),
        )),
        elevation: 2.0,
      ),
      body: GestureDetector(
          onTap: () async {
            final api = ApiProvider.of(context).api;
            final timeAndDate = await api.getDateAndTime();
            setState(() {
              _textKey = ValueKey(timeAndDate);
            });
          },
          child: SizedBox.expand(
            child: Container(
              color: Colors.white,
              child: DateTimeWidget(key: _textKey),
            ),
          )),
    );
  }
}

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final api = ApiProvider.of(context).api;
    return const Center(
        child: Text('Tap the screen to fatch \n the date and time'));
  }
}

class Api {
  String? dateAndTime;

  Future<String> getDateAndTime() {
    return Future.delayed(
      const Duration(milliseconds: 10),
      () => DateTime.now().toIso8601String(),
    ).then((value) {
      dateAndTime = value;
      return value;
    });
  }
}
