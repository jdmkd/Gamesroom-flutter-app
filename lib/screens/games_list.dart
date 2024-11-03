import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Games {
  final int id;
  final String name;
  final List<String> type;
  final String image;
  final String description;

  Games({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.description,
  });

  factory Games.fromJson(Map<String, dynamic> json) {
    return Games(
      id: json['id'] is String ? int.parse(json['id']) : json['id'], // Handle string to int conversion
      name: json['name'],
      type: List<String>.from(json['type']),
      image: json['image'],
      description: json['description'],
    );
  }
}

class GameListScreen extends StatelessWidget {
  Future<List<Games>> fetchGames() async {
    final response = await http.get(Uri.parse('https://nodejs-flutter-gamesroom-api.vercel.app/games'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((gamesJson) => Games.fromJson(gamesJson)).toList().cast<Games>();
    } else {
      throw Exception('Failed to load Games');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Games')),
      body: FutureBuilder<List<Games>>(
        future: fetchGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final games = snapshot.data!;
            return ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 6,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container for image with fixed height and width
                      Container(
                        width: 160, // Fixed width for image
                        // height: 120, // Fixed height for image
                        height: MediaQuery.of(context).size.width * 0.30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                          ),
                          child: Image.asset(
                            'Images/Games/${game.image}',
                            fit: BoxFit.cover, // Cover maintains aspect ratio
                          ),
                        ),
                      ),
                      // Game details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Game Name
                              Text(
                                game.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 6),
                              // Full Description
                              Text(
                                game.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 3, // Limit to 3 lines
                                overflow: TextOverflow.ellipsis, // Manage overflow for text
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );


          }
        },
      ),
    );
  }
}
