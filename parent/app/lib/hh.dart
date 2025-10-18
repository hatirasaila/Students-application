import 'dart:convert';
import 'package:app/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class News {
  final String title;
  final String description;
  final String content;
  final DateTime date;
  final String pdfUrl;
  bool isSelected;
  bool isDone;
  bool compte; // Added to track if the field is compulsory

  News({
    required this.title,
    required this.description,
    required this.content,
    required this.date,
    required this.pdfUrl,
    this.isSelected = false,
    this.isDone = false,
    this.compte = false, // Initialize isCompulsory to false by default
  });

  factory News.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'http://apiserv.ise-college-lycee.com:8415/gethomeworkandPiecebyEleve/4317';
    return News(
      title: json['titre'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      date: DateTime.parse(json['datelimite'] ?? DateTime.now().toIso8601String()),
      pdfUrl: '$baseUrl${json['pdf'] ?? ''}',
      compte: json['compterendu'],
      isDone : json ['etat']
    );
  }
}

class Actualite extends StatefulWidget {
  @override
  _ActualiteState createState() => _ActualiteState();
}

class _ActualiteState extends State<Actualite> {
  List<News> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('http://apiserv.ise-college-lycee.com:8415/gethomeworkandPiecebyEleve/4317'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        newsList = data.map((json) => News.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  Future<void> downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse("http://apiserv.ise-college-lycee.com:8415/gethomeworkandPiecebyEleve/4317")); // Use the URL from the PDF

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Get the directory to save the file
        final dir = await getApplicationDocumentsDirectory();
        final fileName = url.split('/').last;
        final file = File('${dir.path}/$fileName');

        // Write the file to the disk
        await file.writeAsBytes(bytes);

        // Show success message
        Fluttertoast.showToast(
          msg: "Téléchargement de fichier en cours ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Color.fromARGB(255, 105, 105, 105),
          textColor: Colors.white,
        );
      } else {
        throw Exception('Failed to download file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error and show an error message
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    // Group news items by date
    Map<DateTime, List<News>> groupedNews = {};
    newsList.forEach((news) {
      if (!groupedNews.containsKey(news.date)) {
        groupedNews[news.date] = [];
      }
      groupedNews[news.date]!.add(news);
    });

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
                      image: AssetImage('assets/avaters/hi.png'),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Devoirs  à  faire',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: const Text(
              'Travail à faire pour les prochains jours',
              style: TextStyle(
                fontFamily: 'Varela',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 63, 10, 84),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: groupedNews.length,
              itemBuilder: (context, index) {
                DateTime date = groupedNews.keys.elementAt(index);
                List<News> newsForDate = groupedNews[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 30, top: 4, bottom: 4, right: 80),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 232, 207, 243),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pour ',
                              style: TextStyle(
                                fontFamily: 'Varela',
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: _formatDate(date),
                              style: TextStyle(
                                fontFamily: 'Varela',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: newsForDate.length,
                      itemBuilder: (context, idx) {
                        News news = newsForDate[idx];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  news.isSelected = !news.isSelected;
                                });
                              },
                                    title: Row(
                              children: [
                                Icon(
                                  Icons.more_vert_outlined,
                                  color: news.isSelected ? Color.fromARGB(255, 34, 108, 168) : const Color.fromARGB(255, 236, 217, 54),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  news.title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                                  trailing: Container(
                                width: 70,
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: news.isDone ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  news.isDone ? 'Fait' : 'Non fait',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: news.isDone ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                              subtitle: Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(news.description),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Compte rendu: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          news.compte ? 'obligatoire' : 'non obligatoire',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: news.compte ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text('Contenu: ${news.content}'),
                                    SizedBox(height: 8),
                                    if (news.pdfUrl.isNotEmpty)
                                      GestureDetector(
                                        onTap: () => downloadPdf(news.pdfUrl),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 232, 207, 243),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                     child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          news.pdfUrl.endsWith('.pdf')
                                            ? Icon(Icons.picture_as_pdf, color: const Color.fromARGB(255, 110, 18, 146), size: 20)
                                            : (news.pdfUrl.endsWith('.jpg') || news.pdfUrl.endsWith('.jpeg') || news.pdfUrl.endsWith('.png'))
                                                ? Icon(Icons.image_outlined, color: const Color.fromARGB(255, 110, 18, 146), size: 18)
                                                : SizedBox(width: 20),
                                          SizedBox(width: 5),
                                          Text(

                                            news.pdfUrl.split('/').last,
                                            style: TextStyle(color: Color.fromARGB(255, 110, 18, 146), fontSize: 13, fontFamily: 'Varela', 
                                            fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}
