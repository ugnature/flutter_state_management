import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) {
        return BreadCrumbProvider();
      },
      child: MaterialApp(
        title: 'Provider',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Provider'),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  final bool ishovered = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: 32,
        child: BottomNavigationBar(
          useLegacyColorScheme: true,
          selectedFontSize: 8,
          currentIndex: 1,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.text_fields,
                size: 10,
              ),
              label: 'Text',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 10,
              ),
              label: 'Home',
            ),
          ],
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 20,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
            child: Text(
          title,
          style: const TextStyle(fontSize: 14),
        )),
      ),
      body: Center(
        child: SizedBox(
          child: Column(
            children: [
              Consumer<BreadCrumbProvider>(
                builder: (context, bcpvalue, child) {
                  return BreadCrumbWidget(breadcrumb: bcpvalue.items);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 130,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          ishovered;
                          return Colors
                              .green; // Color when the button is disabled
                        } else {
                          ishovered == false;
                          return const Color.fromARGB(255, 147, 110, 0);
                        } // Color when the button is enabled
                      },
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/new');
                  },
                  child: Center(
                    child: Text(
                      "Add New Bread Crumb",
                      style: TextStyle(
                        fontSize: 9,
                        color: ishovered == false ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: 130,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          ishovered;
                          return Colors
                              .red; // Color when the button is disabled
                        } else {
                          ishovered == false;
                          return const Color.fromARGB(255, 147, 110, 0);
                        } // Color when the button is enabled
                      },
                    ),
                  ),
                  onPressed: () {
                    context.read<BreadCrumbProvider>().reset();
                  },
                  child: Center(
                    child: Text(
                      "reset",
                      style: TextStyle(
                        fontSize: 9,
                        color: ishovered == false ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({
    required this.name,
    required this.isActive,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

class BreadCrumbWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadcrumb;

  const BreadCrumbWidget({super.key, required this.breadcrumb});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadcrumb.map(
        (breadCrumb) {
          return Column(
            children: [
              Text(
                breadCrumb.title,
                style: TextStyle(
                  fontSize: 11,
                  color: breadCrumb.isActive ? Colors.blue : Colors.black,
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({super.key});

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Give a Bread Crumb',
          style: TextStyle(fontSize: 10),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter a new breadcrumb here...',
                hintStyle: TextStyle(fontSize: 10),
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                final text = _controller.text;
                if (text.isNotEmpty) {
                  final breadCrumb = BreadCrumb(name: text, isActive: false);
                  context.read<BreadCrumbProvider>().add(breadCrumb);
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                "Press Okay",
                style: TextStyle(fontSize: 12, color: Colors.green),
              ))
        ],
      ),
    );
  }
}
