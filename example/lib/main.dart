import 'package:flutter/material.dart';
import 'package:open_container/open_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenContainer Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'OpenContainer Example Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Tap the card to open details:'),
            const SizedBox(height: 20),
            OpenContainer(
              tag: 'item_1',
              builder: (context) => const ItemCard(id: '1'),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Tap to view details of Item $id',
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            OpenContainerRoute(
              tag: 'item_$id',
              builder: (context) => DetailsPage(id: id),
              transitionDuration: const Duration(milliseconds: 1500),
            ),
          );
        },
        child: Card(
          elevation: 0, // Elevation is handled by OpenContainer
          color: Colors.transparent, // Background color handled by OpenContainer
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory, size: 50),
                const SizedBox(height: 10),
                Text('Item $id'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details Item $id')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory, size: 100),
              const SizedBox(height: 20),
              Text(
                'This is the details page for Item $id',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
