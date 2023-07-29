import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // TakesTheSnapshop and listens to the changes as continues stream
    final dateTime = useStream(getTime());

    // useState and useEffect, useState bring the changes which has happened inside useEffect
    final textController = useTextEditingController();
    final text = useState('');

    useEffect(() {
      textController.addListener(() {
        text.value = textController.text;
      });
      return null;
    }, [textController]);

    // useMemorized to cache the value, if not than get the future value
    const imageurl =
        'https://toppng.com/uploads/preview/insta-simbolo-11658796329vx1gnqepwv.png';
    final future = useMemoized(
      () => NetworkAssetBundle(Uri.parse(imageurl))
          .load(imageurl)
          .then((data) => data.buffer.asUint8List())
          .then((data) => Image.memory(data)),
    );
    final snapshot = useFuture(future);

    // useLisnable to see the changes
    final countdown = useMemoized(() => CountDown(from: 100));
    final notifier = useListenable(countdown);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            text.value.isEmpty ? 'Hello' : text.value,
            style: TextStyle(
                fontSize: 12,
                color: text.value.isEmpty ? Colors.black : Colors.blue[900]),
          ),
        ),
      ),
      body: Row(
        children: [
          SizedBox(width: MediaQuery.sizeOf(context).width / 6),
          Column(
            children: [
              const SizedBox(height: 30),
              Column(
                children: [
                  text.value.isEmpty && snapshot.hasData
                      ? SizedBox(
                          height: 200,
                          width: 200,
                          child: snapshot.data!,
                        )
                      : Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.white38,
                              border:
                                  Border.all(width: 2, color: Colors.green)),
                          child: Text(
                            text.value,
                            maxLines: 5,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                ],
              ),
              SizedBox(
                width: 190,
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  controller: textController,
                ),
              ),
              SizedBox(
                width: 200,
                child: Text(
                  "'useStream' is in use => ${dateTime.data ?? 'Time...'} \n-------------------------------------------",
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ),
              Text(
                "'useLisnable' is in use => ${notifier.value.toString()}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Stream<String> getTime() => Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now().toIso8601String(),
    );

extension CompactMap<T> on Iterable<T?> {
  Iterable<T> compactMap<E>([E? Function(T?)? transform]) =>
      map(transform ?? (e) => e).where((e) => e != null).cast();
}

class CountDown extends ValueNotifier<int> {
  late StreamSubscription sub;
  CountDown({required int from}) : super(from) {
    sub = Stream.periodic(
      const Duration(seconds: 1),
      (val) => from - val,
    ).takeWhile((val) => val >= 0).listen((element) {
      value = element;
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }
}
