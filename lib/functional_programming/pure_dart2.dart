void main(List<String> args) async {
  final myCard = CreditCard();
  final paymentSystem = PaymentSystem();

  final rooms = bookRooms(myCard, 3);
  paymentSystem.charge(rooms.second.cc, rooms.second.amount);
  print('${rooms.first.join(' ')} booked');
  print(rooms.second.amount);
}

typedef BookRoomFunction = Future<Room> Function(CreditCard);

Tuple<List<Room>, Charge> bookRooms(CreditCard cc, int n) {
  final purchases = List<Tuple<Room, Charge>>.generate(n, (_) => bookRoom(cc));
  return Tuple(purchases.map((p) => p.first).toList(),
      purchases.map((p) => p.second).reduce((acc, next) => Charge.combine(acc, next)));
}

class Tuple<T1, T2> {
  const Tuple(this.first, this.second);

  final T1 first;
  final T2 second;
}

class Charge {
  const Charge(this.cc, this.amount);

  final CreditCard cc;
  final double amount;

  factory Charge.combine(Charge first, Charge second) {
    if (first.cc != second.cc) {
      throw Exception('Can not charge with different cards');
    }
    return Charge(first.cc, first.amount + second.amount);
  }
}

Tuple<Room, Charge> bookRoom(CreditCard cc) {
  final room = Room();
  return Tuple(room, Charge(cc, room.price));
}

// ---------------- This might come from a third-party library ----------------
class Room {
  Room({this.price = 20});

  final double price;

  @override
  String toString() => 'Room with price $price';
}

class PaymentSystem {
  Future<void> charge(CreditCard cc, double amount) => Future.delayed(
        Duration(milliseconds: 500),
      );
}

class CreditCard {}
