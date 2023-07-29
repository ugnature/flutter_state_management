import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    Center(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: MultiProvider(
        providers: [
          StreamProvider.value(
            value: Stream<Seconds>.periodic(
              const Duration(seconds: 1),
              (_) => Seconds(),
            ),
            initialData: Seconds(),
          ),
          StreamProvider.value(
            value: Stream<Minutes>.periodic(
              const Duration(seconds: 5),
              (_) => Minutes(),
            ),
            initialData: Minutes(),
          ),
        ],
        child: const Column(
          children: [
            Row(
              children: [SecondsWidget(), MinutesWidget()],
            )
          ],
        ),
      ),
    );
  }
}

class SecondsWidget extends StatelessWidget {
  const SecondsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final seconds = context.watch<Seconds>();
    return Container(
      color: Colors.amber,
      height: 100,
      width: MediaQuery.sizeOf(context).width / 2,
      child: Center(child: Text(seconds.value)),
    );
  }
}

class MinutesWidget extends StatelessWidget {
  const MinutesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final minutes = context.watch<Minutes>();
    return Container(
      color: Colors.blue,
      height: 100,
      width: MediaQuery.sizeOf(context).width / 2,
      child: Center(child: Text(minutes.value)),
    );
  }
}

String now() => DateTime.now().toIso8601String();

@immutable
class Seconds {
  final String value;
  Seconds() : value = now();
}

@immutable
class Minutes {
  final String value;
  Minutes() : value = now();
}
