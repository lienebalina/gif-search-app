// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  ScrollController scrollController = ScrollController();
  String _searchQuery = "";
  num _offset = 0;
  final int _nextPageTrigger = 6;
  List<dynamic> _gifs = [];

  void _fetchGifs() async {
    Uri apiUrl;
    if (_searchQuery == "") {
      apiUrl = Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=DOthYIIXGUzcO2eqKtZkE9WIUxHZLO9n&offset=$_offset&lang=en');
    } else {
      apiUrl = Uri.parse(
          'https://api.giphy.com/v1/gifs/search?q=$_searchQuery&api_key=DOthYIIXGUzcO2eqKtZkE9WIUxHZLO9n&offset=$_offset&lang=en');
    }

    final response = await http.get(apiUrl);
    final data = json.decode(response.body);
    setState(() {
      _gifs.addAll(data['data']);
      _offset += data['pagination']['count'];
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchGifs();
  }

  Timer? timer;
  onSearchValuesChanged(String text) async {
    timer?.cancel();
    timer = Timer(
      const Duration(milliseconds: 250),
      () {
        setState(() {
          _searchQuery = text;
          _offset = 0;
          _gifs.clear();
        });
        _fetchGifs();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (text) {
                onSearchValuesChanged(text);
              },
              controller: editingController,
              decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8),
                    itemCount: _gifs.length,
                    itemBuilder: (context, index) {
                      if (index == _gifs.length - _nextPageTrigger) {
                        _fetchGifs();
                      }
                      final gif = _gifs[index];
                      final imageUrl = gif['images']['fixed_height']['url'];
                      return CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ));
                    }))
          ],
        ),
      ),
    );
  }
}
