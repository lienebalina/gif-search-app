import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gif search'),
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
  TextEditingController editingController = TextEditingController();
  String _searchQuery = "";
  List<dynamic> _gifs = [];

  Future<void> _fetchGifs() async {
    Uri apiUrl;
    if (_searchQuery == "") {
      apiUrl = Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=DOthYIIXGUzcO2eqKtZkE9WIUxHZLO9n&lang=en');
    } else {
      apiUrl = Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=DOthYIIXGUzcO2eqKtZkE9WIUxHZLO9n&q=$_searchQuery&lang=en');
    }

    final response = await http.get(apiUrl);
    final data = json.decode(response.body);
    setState(() {
      _gifs = data['data'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchGifs().then((value) => print);
  }

  Timer? timer;
  onSearchTextChanged(String text) async {
    timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 250),
      () {
        setState(() {
          _searchQuery = text;
        });
        _fetchGifs();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (text) {
                onSearchTextChanged(text);
              },
            ),
            Text(
              'text',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
