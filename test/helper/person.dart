class Person {
  final String name;

  Person(this.name);
}

Person getPerson(int id) {
  return Person(id.toString());
}

Person? getPerson2(int id) {
  if (id % 2 == 0) return null;
  return Person(id.toString());
}
