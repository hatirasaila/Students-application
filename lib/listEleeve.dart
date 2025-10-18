import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:newwapp/customappbar.dart';

class Name {
  final String name;
  final String prename; // Add prename property
  final bool isCompleted;

  Name({
    required this.name,
    required this.prename, // Ensure it's required
    required this.isCompleted,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      name: json['Nomfr'],
      prename: json['Prenomfr'], // Parse prename from JSON
      isCompleted: json['etat'],
    );
  }
}

class Screen3 extends StatefulWidget {
  final int homeworkId;
  final int classeId;

  Screen3({required this.homeworkId, required this.classeId});

  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  List<Name> names = [];
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    fetchNames();
  }

  Future<void> fetchNames() async {
    final url = Uri.parse('http://apiserv.ise-college-lycee.com:8415/getElevesByclasse/${widget.classeId}/${widget.homeworkId}/5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Name> fetchedNames = data.map((json) => Name.fromJson(json)).toList();

      setState(() {
        names = fetchedNames;
        isLoading = false;
      });
    } else {
      // Handle the error
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load names');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          width: double.infinity,
          child: CustomAppBar(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                ),
                Container(
                  width: 80,
                  height: 90,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/avaters/HAHA.png'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Classe ',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Display a loading indicator while fetching data
          : Column(
              children: [
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Liste des éleves de la classe ',
                    style: TextStyle(
                      fontFamily: 'Varela',
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color.fromARGB(255, 96, 96, 96),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 103, 103, 103).withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${names[index].prename} ${names[index].name}'), // Display prename and name
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: names[index].isCompleted
                                      ? Color.fromARGB(255, 87, 171, 91)
                                      : Color.fromARGB(255, 210, 98, 90),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  names[index].isCompleted ? 'fait' : 'non fait',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Handle tapping on a name if needed
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

