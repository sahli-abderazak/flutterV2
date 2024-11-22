import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widget/widget_support.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> foods = [];
  String selectedCategory = 'all'; // Par défaut, afficher tous les aliments

  bool icecream = false, pizza = false, salad = false, burger = false, all = true;

  Future<void> fetchFoodsByCategory(String category) async {
    // Si la catégorie est 'all', utilisez l'endpoint pour récupérer tous les aliments
    String url = category == 'all'
        ? 'http://192.168.1.24:5000/allfoods'
        : 'http://192.168.1.24:5000/foods/category/$category'; // Utiliser l'URL pour les autres catégories

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        foods = data['foods']; // Mettre à jour les aliments avec les données de l'API
        selectedCategory = category; // Mettre à jour la catégorie sélectionnée
      });
    } else {
      // Gérer les erreurs
      throw Exception('Failed to load foods');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFoodsByCategory(selectedCategory); // Charger tous les aliments par défaut
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to our FoodDelivery'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligner les textes à gauche
        children: [
          // Texte principal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligner les textes à gauche
              children: [
                Text(
                  "Delicious Food",
                  style: AppWidget.HeadlineTextFeildStyle(),
                ),
                SizedBox(height: 5), // Espacement entre les textes
                Text(
                  "Discover and Get Great Food",
                  style: AppWidget.LightTextFeildStyle(),
                ),
              ],
            ),
          ),

          // Section des boutons de catégories
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              height: 60,
              width: 500,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(), // Défilement fluide
                itemCount: 5, // Nombre de boutons
                itemBuilder: (context, index) {
                  Widget button;
                  switch (index) {
                    case 0:
                      button = categoryButton2('All', 'all');
                      break;
                    case 1:
                      button = categoryButton('Ice-cream', 'Ice-cream', 'images/ice-cream.png');
                      break;
                    case 2:
                      button = categoryButton('Burgers', 'burger', 'images/burger.png');
                      break;
                    case 3:
                      button = categoryButton('Pizza', 'Pizza', 'images/pizza.png');
                      break;
                    case 4:
                      button = categoryButton('Salads', 'salad', 'images/salad.png');
                      break;
                    default:
                      button = Container(); // Default return
                  }
                  // Ajouter un espacement entre les éléments
                  return Padding(
                    padding: const EdgeInsets.only(right: 20.0), // Espace à droite de chaque bouton
                    child: button,
                  );
                },
              ),
            ),
          ),

          // Affichage des aliments dans un GridView
          Expanded(
            child: foods.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Image.network(
                        foods[index]['image_url'],
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                      Text(foods[index]['name']),
                      Text("${foods[index]['price']} DNT"),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  // Fonction pour créer un bouton de catégorie avec une icône
  Widget categoryButton(String label, String category, String iconPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          all = false;
          icecream = category == 'Ice-cream';
          pizza = category == 'Pizza';
          salad = category == 'salad';
          burger = category == 'burger';
          selectedCategory = category;
        });
        fetchFoodsByCategory(category); // Charger les aliments pour la catégorie sélectionnée
      },
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: category == 'all' ? (all ? Colors.black : Colors.white) :
            (category == 'Ice-cream' ? (icecream ? Colors.black : Colors.white) :
            category == 'burger' ? (burger ? Colors.black : Colors.white) :
            category == 'Pizza' ? (pizza ? Colors.black : Colors.white) :
            (salad ? Colors.black : Colors.white)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            iconPath,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            color: category == 'all' ? (all ? Colors.white : Colors.black) :
            (category == 'Ice-cream' ? (icecream ? Colors.white : Colors.black) :
            category == 'burger' ? (burger ? Colors.white : Colors.black) :
            category == 'Pizza' ? (pizza ? Colors.white : Colors.black) :
            (salad ? Colors.white : Colors.black)),
          ),
        ),
      ),
    );
  }

  Widget categoryButton2(String label, String category) {
    return ElevatedButton(
      onPressed: () {
        fetchFoodsByCategory(category);
      },
      child: Text(label),
    );
  }
}
