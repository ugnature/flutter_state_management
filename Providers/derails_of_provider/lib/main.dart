import 'package:flutter/material.dart';

import 'dart:async';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        return ObjectProvider();
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromRGBO(76, 175, 80, 1)),
          useMaterial3: true,
        ),
        home: const HomePage(title: 'Provider State Management'),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 20),
          const Row(
            children: [
              CheapWidget(),
              ExpensiveWidget(),
            ],
          ),
          const Row(
            children: [ObjectProviderWidget()],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    context.read<ObjectProvider>().start();
                  },
                  child: const Text("Start")),
              TextButton(
                  onPressed: () {
                    context.read<ObjectProvider>().stop();
                  },
                  child: const Text("Stop")),
            ],
          )
        ],
      ),
    );
  }
}

@immutable
class BaseObject {
  final String id;
  final String lastUpdated;

  BaseObject()
      : id = const Uuid().v4(), // where id is =
        lastUpdated = DateTime.now().toIso8601String();

  @override
  bool operator ==(covariant BaseObject other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class ExpensiveObject extends BaseObject {}

@immutable
class CheapObject extends BaseObject {}

// Provider
class ObjectProvider extends ChangeNotifier {
  late String id;
  late CheapObject _cheapObject;
  late StreamSubscription _cheapStreamSubscription;
  late ExpensiveObject _expensiveObject;
  late StreamSubscription _expensiveStreamSubscription;

  CheapObject get cheapObject => _cheapObject;
  ExpensiveObject get expensiveObject => _expensiveObject;

  ObjectProvider()
      : id = const Uuid().v4(),
        _cheapObject = CheapObject(),
        _expensiveObject = ExpensiveObject() {
    start();
  }

  @override
  void notifyListeners() {
    id = const Uuid().v4();
    super.notifyListeners();
  }

  void start() {
    _cheapStreamSubscription =
        Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _cheapObject = CheapObject();
      notifyListeners();
    });
    _expensiveStreamSubscription =
        Stream.periodic(const Duration(seconds: 10)).listen((_) {
      _expensiveObject = ExpensiveObject();
      notifyListeners();
    });
  }

  void stop() {
    _cheapStreamSubscription.cancel();
    _expensiveStreamSubscription.cancel();
  }
}

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final expensiveObject = context.select<ObjectProvider, ExpensiveObject>(
      (provider) => provider.expensiveObject,
    );

    return Container(
      height: 100,
      width: MediaQuery.sizeOf(context).width / 2,
      color: Colors.amber,
      child: Column(
        children: [
          const Text("Expensive Widget"),
          const Text("Last Updated"),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}

class CheapWidget extends StatelessWidget {
  const CheapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
      (provider) => provider.cheapObject,
    );
    return Container(
      height: 100,
      width: MediaQuery.sizeOf(context).width / 2,
      color: Colors.blue,
      child: Column(
        children: [
          const Text("Cheap Widget"),
          const Text("Last Updated"),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}

class ObjectProviderWidget extends StatelessWidget {
  const ObjectProviderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObjectProvider>();
    return Container(
      height: 100,
      width: MediaQuery.sizeOf(context).width,
      color: Colors.orange,
      child: Column(
        children: [
          const Text("Object Provider widget"),
          const Text("ID: "),
          Text(provider.id),
        ],
      ),
    );
  }
}
