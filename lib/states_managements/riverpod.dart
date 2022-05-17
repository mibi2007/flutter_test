import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.read(cartProvider.notifier).addItem(existItem);
        ref.read(counterProvider.notifier).increment();
        return Scaffold(
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
        );
      },
    );
  }
}

class ShoppingList extends ConsumerWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final counterState = ref.watch(counterProvider);
    final counterNotifier = ref.read(counterProvider.notifier);
    return Column(
      children: [
        Text('CartState: ${cartState.itemCount().toString()}'),
        Text('CartState: ${cartState.totalPrice().toString()}'),
        Text('CounterState: ${counterState.toString()}'),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(data[index].name),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () {
                          cartNotifier.addItem(data[index]);
                          counterNotifier.increment();
                        },
                        child: Text(data[index].price.toString())),
                    if (cartState.items[data[index].id] != null)
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          cartNotifier.removeItem(data[index]);
                          counterNotifier.decrement();
                        },
                      ),
                  ],
                ),
              ),
            ),
            itemCount: data.length,
          ),
        ),
      ],
    );
  }
}

class ShoppingCart extends ConsumerWidget {
  const ShoppingCart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final counterNotifier = ref.read(counterProvider.notifier);
    return Row(
      children: [
        SizedBox(
          width: 45,
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(left: 0, top: 0, child: Icon(Icons.shopping_cart)),
              if (cartState.itemCount() > 0)
                Positioned(
                  top: -3,
                  left: 10,
                  child: CustomPaint(
                    size: const Size(20, 15),
                    painter: OvalPainter(),
                  ),
                ),
              if (cartState.itemCount() > 0)
                Positioned(
                  left: 8,
                  top: -1,
                  width: 25,
                  child: Center(
                    child: Text(
                      cartState.itemCount().toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Text(cartState.totalPrice().toString()),
        if (cartState.itemCount() > 0)
          IconButton(
            onPressed: () {
              cartNotifier.empty();
              counterNotifier.reset();
            },
            icon: const Icon(Icons.clear),
          ),
      ],
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

final cartProvider = StateNotifierProvider.autoDispose<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(Item item) {
    if (state.items[item.id] != null) {
      state.items[item.id]!.quantity++;
    } else {
      state.items[item.id] = ItemCart(1, id: item.id, name: item.name, price: item.price);
    }
    state = CartState.clone(state);
  }

  void removeItem(Item item) {
    if (state.items[item.id] != null) {
      state.items[item.id]!.quantity--;
      if (state.items[item.id]!.quantity == 0) {
        state.items.remove(item.id);
      }
    }
    state = CartState.clone(state);
  }

  void empty() {
    state.items.clear();
    state = CartState.clone(state);
  }
}

@immutable
class CartState {
  final Map<String, ItemCart> items = {};

  static CartState clone(CartState state) {
    final newState = CartState();
    state.items.map((key, value) {
      newState.items[key] = value;
      return MapEntry(key, value);
    });
    return newState;
  }

  int itemCount() {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  int totalPrice() {
    return items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
  }
}

final counterProvider = StateNotifierProvider.autoDispose<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }

  void reset() {
    state = 0;
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
