import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MaterialApp(
    title: 'My Contact Book',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      useMaterial3: true,
    ),
    home: const MyHomePage(),
    routes: {
      '/new_contact': (context) => const NewContactView(),
    },
  ));
}

// an single contact
class Contact {
  final String name;
  final String id;
  // to access the contact or delete it's good that we a unique id cause two contact can have same name
  Contact({required this.name}) : id = const Uuid().v4();
}

// list of contacts
class ContactBook extends ValueNotifier<List<Contact>> {
  // created a singlton here
  // manage an empty an empty list in which all the contacts will be added
  ContactBook._sharedInstance() : super([]);
  static final ContactBook _shared = ContactBook._sharedInstance();
  factory ContactBook() => _shared;

  // created a length variable which return total contacts which we will need in listview builder index
  int get length => value.length;

  // this will just add contact to this contact list
  void add({required Contact contact}) {
    final contacts = value;
    contacts.add(contact);
    notifyListeners();
  }

  // to remove a contact from this contact list
  void remove({required Contact contact}) {
    final contacts = value;
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      notifyListeners();
    }
  }

  // return a contact using an index
  Contact? contact({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Center(child: Text('My Contact Book')),
      ),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (context, value, child) {
          // this value is coming from contactbook valueNotifier
          final contacts = value;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Dismissible(
                key: ValueKey(contact.id),
                child: Material(
                  color: Colors.white,
                  elevation: 6.0,
                  child: ListTile(
                    title: Text(contact.name),
                  ),
                ),
                onDismissed: (direction) {
                  ContactBook().remove(contact: contact);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/new_contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Center(child: Text('Add a new contact')),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter new contact...'),
          ),
          TextButton(
            onPressed: () {
              final contact = Contact(name: _controller.text);
              ContactBook().add(contact: contact);
              Navigator.of(context).pop();
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }
}
