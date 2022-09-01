import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class Person {
  final String id;
  final String name;
  final int age;
  Person(this.name, this.age) : id = const Uuid().v4();
}

class ContactList extends ValueNotifier<List<Person>> {
  ContactList._sharedInstance() : super([]);
  static final ContactList _shared = ContactList._sharedInstance();

  factory ContactList() => _shared;
  int get length => value.length;
  void add({required Person person}) {
    final contact = value;
    contact.add(person);
    notifyListeners();
  }

  void remove({required Person person}) {
    final contact = value;
    contact.remove(person);
    notifyListeners();
  }

  Person? contact({required int index}) => value.length > index ? value.elementAt(index) : null;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: const HomePage(),
      routes: {
        '/new-contact': (context) => const NewContactPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Flutter'),
      ),
      body: Center(
        child: ValueListenableBuilder<List<Person>>(
          valueListenable: ContactList(),
          builder: (context, value, child) {
            return ContactListwidget(contacts: value);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-contact');
        },
        tooltip: 'Add Contact',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ContactListwidget extends StatelessWidget {
  final List<Person> contacts;
  const ContactListwidget({Key? key, required this.contacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return Container();
    }
    return ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final person = ContactList().contact(index: index)!;
          return Dismissible(
            onDismissed: (_) => ContactList().remove(person: person),
            key: ValueKey(person.id),
            child: ListTile(
              title: Text(person.name),
              subtitle: Text('${person.age} years old'),
            ),
          );
        });
  }
}

class NewContactPage extends StatefulWidget {
  const NewContactPage({Key? key}) : super(key: key);

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Contact'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
              ),
              keyboardType: TextInputType.number),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              ContactList().add(person: Person(_nameController.text, int.parse(_ageController.text)));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
