import 'package:flutter_test/flutter_test.dart';

import 'helper/person.dart';

void main() {
  test('simple getPerson', () {
    final name = getPerson(1).name;
    expect(name, '1');
  });

  test('almost real getPerson', () {
    final name1 = getPerson2(1)?.name;
    expect(name1, '1');
    final name2 = getPerson2(2)?.name;
    expect(name2, null);
  });
}
