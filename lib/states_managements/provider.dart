import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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
    return ChangeNotifierProvider(
      create: (context) => CartProvider()..addItem(existItem),
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
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Column(
        children: [
          Text(cart.itemCount().toString()),
          Text(cart.totalPrice().toString()),
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
                              cart.addItem(data[index]);
                            },
                            child: Text(data[index].price.toString())),
                        if (cart.items[data[index].id] != null)
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              cart.removeItem(data[index]);
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
    return Consumer<CartProvider>(
      builder: (context, cart, child) => Row(
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
                    cart.itemCount().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Text(cart.totalPrice().toString()),
          if (cart.itemCount() > 0)
            IconButton(
              onPressed: () {
                cart.empty();
              },
              icon: const Icon(Icons.remove),
            ),
        ],
      ),
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

class CartProvider extends ChangeNotifier {
  final Map<String, ItemCart> items = {};
  void addItem(Item item) {
    if (items[item.id] != null) {
      items[item.id]!.quantity++;
    } else {
      items[item.id] = ItemCart(1, id: item.id, name: item.name, price: item.price);
    }
    notifyListeners();
  }

  void removeItem(Item item) {
    if (items[item.id] != null) {
      items[item.id]!.quantity--;
      if (items[item.id]!.quantity == 0) {
        items.remove(item.id);
      }
    }
    notifyListeners();
  }

  void empty() {
    items.clear();
    notifyListeners();
  }

  int itemCount() {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  int totalPrice() {
    return items.values.fold(0, (sum, item) => sum + item.price * item.quantity);
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
