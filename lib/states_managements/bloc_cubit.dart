import 'dart:developer' as devtools show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

extension Logger on Object {
  void log() => devtools.log(toString());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ItemCart(1, id: '1', name: 'name', price: 1).hashCode.log();
    (ItemCart(1, id: '1', name: 'name', price: 1).hashCode == ItemCart(1, id: '1', name: 'name', price: 1).hashCode)
        .log();
    mapEquals({'items': ItemCart(1, id: '1', name: 'name', price: 1)},
        {'items': ItemCart(1, id: '1', name: 'name', price: 1)}).log();
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: ShoppingPage(),
    );
  }
}

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final existItem = Item(id: data[1].id, name: data[1].name, price: data[1].price);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CartCubit()),
        BlocProvider(create: (context) => CounterCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Shopping Page'),
              ShoppingCart(),
            ],
          ),
        ),
        body: const ShoppingList(),
      ),
    );
  }
}

class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final cart = context.watch<CartProvider>();
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) => Column(
        children: [
          Text(context.watch<CartCubit>().itemCount().toString()),
          Text(context.watch<CartCubit>().totalPrice().toString()),
          BlocBuilder<CounterCubit, int>(builder: (context, count) => Text(count.toString())),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data[index].name),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              context.read<CounterCubit>().increment();
                              context.read<CartCubit>().addItem(data[index]);
                            },
                            child: Text(data[index].price.toString())),
                        if (state.items[data[index].id] != null)
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              context.read<CounterCubit>().decrement();
                              context.read<CartCubit>().removeItem(data[index]);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: data.length,
            ),
          ),
        ],
      ),
    );
  }
}

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final cart = context.watch<CartProvider>();
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Row(
          children: [
            SizedBox(
              width: 45,
              height: 30,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(left: 0, top: 0, child: Icon(Icons.shopping_cart)),
                  Positioned(
                    top: -3,
                    left: 10,
                    child: CustomPaint(
                      size: const Size(20, 15),
                      painter: OvalPainter(),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: -1,
                    child: Text(
                      context.read<CartCubit>().itemCount().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            Text(context.read<CartCubit>().totalPrice().toString()),
            if (context.read<CartCubit>().itemCount() > 0)
              IconButton(
                onPressed: () {
                  context.read<CartCubit>().empty();
                },
                icon: const Icon(Icons.remove),
              ),
          ],
        );
      },
    );
  }
}

List<Item> data = [
  Item(id: '1', name: 'Flutter', price: 100),
  Item(id: '2', name: 'Dart', price: 200),
  Item(id: '3', name: 'React', price: 300),
  Item(id: '4', name: 'Vue', price: 400),
  Item(id: '5', name: 'Angular', price: 500),
];

class Item {
  final String id;
  final String name;
  final int price;

  Item({required this.id, required this.name, required this.price});
}

class ItemCart extends Item {
  int quantity;

  ItemCart(this.quantity, {required String id, required String name, required int price})
      : super(id: id, name: name, price: price);
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState());

  void addItem(Item item) {
    CartState newState = CartState.clone(state);
    if (newState.items[item.id] != null) {
      newState.items[item.id]!.quantity++;
    } else {
      newState.items[item.id] = ItemCart(1, id: item.id, name: item.name, price: item.price);
    }
    emit(newState);
  }

  void removeItem(Item item) {
    CartState newState = CartState.clone(state);
    if (newState.items[item.id] != null) {
      newState.items[item.id]!.quantity--;
      if (newState.items[item.id]!.quantity == 0) {
        newState.items.remove(item.id);
      }
    }
    emit(newState);
  }

  void empty() {
    state.items.clear();
    emit(state);
  }

  int itemCount() {
    return state.items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  int totalPrice() {
    return state.items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

@immutable
class CartState {
  final Map<String, ItemCart> items = {};

  int itemCount() {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  int totalPrice() {
    return items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
  }

  static CartState clone(CartState state) {
    final newState = CartState();
    state.items.map((key, value) {
      newState.items[key] = value;
      return MapEntry(key, value);
    });
    return newState;
  }
}

class OvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
