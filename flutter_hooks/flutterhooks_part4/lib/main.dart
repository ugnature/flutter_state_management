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
    final store = useReducer<State, Action?>(
      reducer,
      initialState: const State.zero(),
      initialAction: null,
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
      body: Column(
        children: [
          Opacity(
            opacity: store.state.alpha,
            child: RotationTransition(
                turns: AlwaysStoppedAnimation(store.state.rotationDegree / 360),
                child: SizedBox(
                    height: 400, width: 400, child: Image.network(imageUrl))),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              RotateLeftButton(store: store),
              RotateRIghtButton(store: store),
              LessVisibleButton(store: store),
              MoreVisibleButton(store: store),
            ],
          ),
        ],
      ),
    );
  }
}

class MoreVisibleButton extends StatelessWidget {
  const MoreVisibleButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          store.dispatch(Action.moreVisible);
        },
        child: const Text("More Visible", style: TextStyle(fontSize: 10)));
  }
}

class LessVisibleButton extends StatelessWidget {
  const LessVisibleButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          store.dispatch(Action.lessVisible);
        },
        child: const Text("Less Visible", style: TextStyle(fontSize: 10)));
  }
}

class RotateRIghtButton extends StatelessWidget {
  const RotateRIghtButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          store.dispatch(Action.rotateRight);
        },
        child: const Text("Rotate Right", style: TextStyle(fontSize: 10)));
  }
}

class RotateLeftButton extends StatelessWidget {
  const RotateLeftButton({
    super.key,
    required this.store,
  });

  final Store<State, Action?> store;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          store.dispatch(Action.rotateLeft);
        },
        child: const Text("Rotate Left", style: TextStyle(fontSize: 10)));
  }
}

const imageUrl =
    'https://cdn.dribbble.com/users/1875232/screenshots/15296613/media/1dd002f70b4dae1bb35a2a29375c916b.png';

enum Action {
  rotateLeft,
  rotateRight,
  moreVisible,
  lessVisible,
}

@immutable
class State {
  final double rotationDegree;
  final double alpha;

  const State({required this.rotationDegree, required this.alpha});

  // initial State
  const State.zero()
      : rotationDegree = 0.0,
        alpha = 1.0;

  State rotateRight() =>
      State(alpha: alpha, rotationDegree: rotationDegree + 10.0);

  State rotateLeft() =>
      State(alpha: alpha, rotationDegree: rotationDegree - 10.0);

  State increaseAlpha() =>
      State(alpha: min(alpha + 0.1, 1.0), rotationDegree: rotationDegree);

  State decreaseAlpha() =>
      State(alpha: max(alpha - 0.1, 0.0), rotationDegree: rotationDegree);
}
// Reducer => NewState

State reducer(State oldState, Action? action) {
  switch (action) {
    case Action.rotateLeft:
      return oldState.rotateLeft();
    case Action.rotateRight:
      return oldState.rotateRight();
    case Action.lessVisible:
      return oldState.decreaseAlpha();
    case Action.moreVisible:
      return oldState.increaseAlpha();
    case null:
      return oldState;
  }
}
