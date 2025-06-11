import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // super()

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 61, 255, 2)),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  List<Widget> _dynamicButtons = []; //List to store buttons

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _addButton() {
    setState(() {
      _dynamicButtons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showInputDialog, // Opens input dialog
            child: Text("New Button ${_dynamicButtons.length + 1}"),
          ),
        ),
      );
    });
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController();
        TextEditingController numberController = TextEditingController();

        return AlertDialog(
          title: Text("Enter Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(labelText: "Enter text"),
              ),
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: "Enter number"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                print("Text: ${textController.text}, Number: ${numberController.text}");
                Navigator.of(context).pop(); // Close dialog after saving
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column( // Change from Center to Column
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView( // Allows scrolling
              child: Column(
                children: _dynamicButtons,
                ),
            ),
          ),
      ],
    ),
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Places buttons at opposite sides
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0), // Aligns left button properly
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _counter = 0; // Resets counter
              });
            },
            child: Text("Reset"),
          ),
        ),
        FloatingActionButton(
          onPressed: _addButton,
          tooltip: 'Add Button',
          child: const Icon(Icons.add),
        ),
      ],
    ),
  );
}
}
