import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Redux_async'),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final store = Store(reducer,
        initialState: const State.initialState(),
        middleware: [loadNSEStockMiddleware, loadNSEStockImageMiddleware]);
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
            children: [
              FunctionTextButton(
                onPressed: () {
                  store.dispatch(const LoadNSEStockAction());
                },
                width: 250,
                height: 75,
                child: const Text('Load Stock Data'),
              ),
              StoreConnector<State, bool>(
                converter: (store) => store.state.isLoading,
                builder: (context, isLoading) {
                  if (isLoading) {
                    return const CircularProgressIndicator();
                  }
                  return const SizedBox();
                },
              ),
              StoreConnector<State, Iterable<NSEStock>?>(
                converter: (store) => store.state.shortedFetchedNSEStocks,
                builder: (context, nseStocks) {
                  if (nseStocks == null) {
                    return const SizedBox();
                  }

                  return Expanded(
                      child: ListView.builder(
                    itemCount: nseStocks.length,
                    itemBuilder: (context, index) {
                      final nseStock = nseStocks.elementAt(index);
                      final infoWidget = Text('${nseStock.currentPrice}');
                      final Widget subtitle = nseStock.imageData == null
                          ? infoWidget
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoWidget,
                                Image.memory(nseStock.imageData!),
                              ],
                            );
                      final Widget trailing = nseStock.isLoading
                          ? const CircularProgressIndicator()
                          : FunctionTextButton(
                              onPressed: () {
                                store.dispatch(LoadNSEStockImageAction(
                                    nseStockId: nseStock.id));
                              },
                              width: 80,
                              height: 30,
                              child: const Text("Load Chart"));
                      return ListTile(
                        style: ListTileStyle.drawer,
                        title: Text(nseStock.stock),
                        subtitle: subtitle,
                        trailing: trailing,
                      );
                    },
                  ));
                },
              ),
            ],
          )),
    );
  }
}

const nseApiUrl = 'http://127.0.0.1:5500/api/nse_stock.json';

@immutable
class NSEStock {
  final String id;
  final String stock;
  final double currentPrice;
  final String imageUrl;
  final Uint8List? imageData;
  final bool isLoading;

  const NSEStock(
      {required this.id,
      required this.stock,
      required this.currentPrice,
      required this.imageUrl,
      required this.imageData,
      required this.isLoading});

  NSEStock copiedWith([bool? isloading, Uint8List? imageData]) => NSEStock(
        id: id,
        stock: stock,
        currentPrice: currentPrice,
        imageUrl: imageUrl,
        imageData: imageData ?? this.imageData,
        isLoading: isLoading,
      );

  NSEStock.fromJson(Map<String, dynamic> json)
      : id = json["id"] as String,
        stock = json["stock"] as String,
        currentPrice = json["current_price"] as double,
        imageUrl = json["image_url"] as String,
        imageData = null,
        isLoading = false;

  @override
  String toString() =>
      'NSEStock for the id $id => stock: $stock - current_price is $currentPrice';
}

// Json Parsing
Future<Iterable<NSEStock>> getNSEStockDate() => HttpClient()
    .getUrl(Uri.parse(nseApiUrl))
    .then((req) => req.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((element) => NSEStock.fromJson(element)));

// define Action
@immutable
abstract class Action {
  const Action();
}

@immutable
class LoadNSEStockAction extends Action {
  const LoadNSEStockAction();
}

// Action initiated by middleware on suceess and failure on fatching json data
@immutable
class SuccessfullyFetchedNSEStockAction extends Action {
  final Iterable<NSEStock> nseStock;

  const SuccessfullyFetchedNSEStockAction({required this.nseStock});
}

@immutable
class FailedtoFetchNSEStockAction extends Action {
  final Object error;

  const FailedtoFetchNSEStockAction({required this.error});
}

// Defining Application states

@immutable
class State {
  final bool isLoading;
  final Iterable<NSEStock>? fetchNseStock;
  final Object? error;

  Iterable<NSEStock>? get shortedFetchedNSEStocks => fetchNseStock?.toList()
    ?..sort((s1, s2) => int.parse(s1.id).compareTo(int.parse(s2.id)));

  const State(
      {required this.isLoading,
      required this.fetchNseStock,
      required this.error});

  // Initial State
  const State.initialState()
      : isLoading = false,
        fetchNseStock = null,
        error = null;
}

@immutable
class LoadNSEStockImageAction extends Action {
  final String nseStockId;

  const LoadNSEStockImageAction({required this.nseStockId});
}

@immutable
class SuccessfullyLoadedNSEStockImageAction extends Action {
  final String nseStockId;
  final Uint8List imageData;

  const SuccessfullyLoadedNSEStockImageAction(
      {required this.nseStockId, required this.imageData});
}

State reducer(State oldState, action) {
  // Loading State
  if (action is SuccessfullyLoadedNSEStockImageAction) {
    final nseStock =
        oldState.fetchNseStock?.firstWhere((s) => s.id == action.nseStockId);
    if (nseStock != null) {
      return State(
        isLoading: false,
        fetchNseStock: oldState.fetchNseStock
            ?.where((s) => s.id != nseStock.id)
            .followedBy([nseStock.copiedWith(false, action.imageData)]),
        error: oldState.error,
      );
    } else {
      // if person is null
      return oldState;
    }
  } else if (action is LoadNSEStockImageAction) {
    final nseStock =
        oldState.fetchNseStock?.firstWhere((s) => s.id == action.nseStockId);
    if (nseStock != null) {
      return State(
        isLoading: false,
        fetchNseStock: oldState.fetchNseStock
            ?.where((s) => s.id != nseStock.id)
            .followedBy([nseStock.copiedWith(true)]),
        error: oldState.error,
      );
    } else {
      // if person is null
      return oldState;
    }
  } else if (action is LoadNSEStockAction) {
    return const State(
      isLoading: true,
      fetchNseStock: null,
      error: null,
    );
    // Success
  } else if (action is SuccessfullyFetchedNSEStockAction) {
    return State(
      isLoading: false,
      fetchNseStock: action.nseStock,
      error: null,
    );
    // Failure
  } else if (action is FailedtoFetchNSEStockAction) {
    return State(
      isLoading: false,
      fetchNseStock: oldState.fetchNseStock,
      error: action.error,
    );
  }
  return oldState;
}

// Middleware
void loadNSEStockMiddleware(
  Store<State> store,
  action,
  NextDispatcher next,
) {
  if (action is LoadNSEStockAction) {
    getNSEStockDate().then((stocks) {
      store.dispatch(SuccessfullyFetchedNSEStockAction(nseStock: stocks));
    }).catchError((error) {
      store.dispatch(FailedtoFetchNSEStockAction(error: error));
    });
  }
  next(action);
}

void loadNSEStockImageMiddleware(
  Store<State> store,
  action,
  NextDispatcher next,
) {
  if (action is LoadNSEStockImageAction) {
    final nseStock =
        store.state.fetchNseStock?.firstWhere((s) => s.id == action.nseStockId);
    if (nseStock != null) {
      final url = nseStock.imageUrl;
      final bundle = NetworkAssetBundle(Uri.parse(url));
      bundle.load(url).then((byteData) => byteData.buffer.asUint8List()).then(
        (data) {
          store.dispatch(
            SuccessfullyLoadedNSEStockImageAction(
                nseStockId: nseStock.id, imageData: data),
          );
        },
      );
    }
  }
  next(action);
}

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
