import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' as hooks;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Redux'),
    ),
  );
}

class MyHomePage extends hooks.HookWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final store = Store(appStateReducer,
        initialState: const State(items: [], filter: ItemFilter.all));
    final textController = hooks.useTextEditingController();
    return Scaffold(
      backgroundColor: Colors.white54,
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
      body: StoreProvider(
        store: store,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                FunctionTextButton(
                    onPressed: () {
                      store.dispatch(
                          const ChangeFilterTypeAction(filter: ItemFilter.all));
                    },
                    child: const Text('All')),
                FunctionTextButton(
                  onPressed: () {
                    store.dispatch(const ChangeFilterTypeAction(
                        filter: ItemFilter.longTexts));
                  },
                  width: 95,
                  child: const Text('Long Items'),
                ),
                FunctionTextButton(
                    onPressed: () {
                      store.dispatch(const ChangeFilterTypeAction(
                          filter: ItemFilter.shortTexts));
                    },
                    width: 95,
                    child: const Text('Short Items')),
              ],
            ),
            TextField(
              controller: textController,
            ),
            Row(
              children: [
                FunctionTextButton(
                  onPressed: () {
                    final text = textController.text;
                    store.dispatch(AddItemAction(text));
                    textController.clear();
                  },
                  width: 95,
                  child: const Text('Add Item'),
                ),
                FunctionTextButton(
                  onPressed: () {
                    final text = textController.text;
                    store.dispatch(RemoveItemAction(text));
                    textController.clear();
                  },
                  width: 95,
                  onhoverColor: Colors.redAccent,
                  child: const Text('Delete Item'),
                ),
              ],
            ),
            StoreConnector<State, Iterable<String>>(
              converter: (store) => store.state.filterItems,
              builder: (context, vmItems) => Expanded(
                  child: ListView.builder(
                itemCount: vmItems.length,
                itemBuilder: (context, index) {
                  final items = vmItems.elementAt(index);
                  return ListTile(
                    tileColor: Colors.white,
                    shape: Border.all(width: 1),
                    title: Text(items),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

enum ItemFilter {
  all,
  longTexts,
  shortTexts,
}

@immutable
class State {
  final Iterable<String> items;
  final ItemFilter filter;

  const State({required this.items, required this.filter});

  Iterable<String> get filterItems {
    switch (filter) {
      case ItemFilter.all:
        return items;
      case ItemFilter.longTexts:
        return items.where((itemsElement) => itemsElement.length >= 10);
      case ItemFilter.shortTexts:
        return items.where((itemsElement) => itemsElement.length <= 4);
    }
  }
}

@immutable
abstract class Action {
  const Action();
}

@immutable
class ChangeFilterTypeAction extends Action {
  final ItemFilter filter;
  const ChangeFilterTypeAction({required this.filter});
}

@immutable
abstract class ItemAction extends Action {
  final String item;
  const ItemAction(this.item);
}

@immutable
class RemoveItemAction extends ItemAction {
  const RemoveItemAction(super.item);
}

@immutable
class AddItemAction extends ItemAction {
  const AddItemAction(super.item);
}

extension AddRemoveItem<T> on Iterable<T> {
  Iterable<T> operator +(T otherItem) => followedBy([otherItem]);

  Iterable<T> operator -(T deletableItem) =>
      where((itemElements) => itemElements != deletableItem);
}

// Reducer
Iterable<String> addItemReducer(
  Iterable<String> previousItems,
  AddItemAction addAction,
) =>
    previousItems + addAction.item;

Iterable<String> removeItemReducer(
  Iterable<String> previousItems,
  RemoveItemAction removeAction,
) =>
    previousItems - removeAction.item;

Reducer<Iterable<String>> itemReducer = combineReducers<Iterable<String>>([
  TypedReducer<Iterable<String>, AddItemAction>(addItemReducer),
  TypedReducer<Iterable<String>, RemoveItemAction>(removeItemReducer),
]);

ItemFilter itemFilterReducer(
  State oldState,
  Action action,
) {
  if (action is ChangeFilterTypeAction) {
    return action.filter;
  } else {
    return oldState.filter;
  }
}

State appStateReducer(
  State oldState,
  action,
) =>
    State(
      items: itemReducer(oldState.items, action),
      filter: itemFilterReducer(oldState, action),
    );

// Button Design

class FunctionTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final bool baseColor;
  final double? height;
  final Color? onhoverColor;
  const FunctionTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onhoverColor = Colors.amberAccent,
    this.baseColor = true,
    this.width = 50,
    this.height = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: onhoverColor,
        splashColor: Colors.black26,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black12),
            color: Colors.white12,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          height: height,
          width: width,
          child: Center(child: child),
        ));
  }
}
