import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'home_admin.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> foodItems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  String? category;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  File? selectedImage;

  // Méthode pour choisir une image depuis le stockage
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> addFood() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.24:5000/foods/add'));

    // Attacher le fichier image
    var imageStream = http.ByteStream(selectedImage!.openRead());
    var length = await selectedImage!.length();
    var multipartFile = http.MultipartFile(
      'image',
      imageStream,
      length,
      filename: selectedImage!.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    // Attacher les autres champs du formulaire
    request.fields['name'] = nameController.text;
    request.fields['description'] = detailController.text;
    request.fields['price'] = priceController.text;
    request.fields['category'] = category!;

    try {
      // Envoyer la requête
      var response = await request.send();

      // Vérification du code de statut de la réponse
      if (response.statusCode == 200) {
        // Assurez-vous que la réponse a été traitée correctement
        var responseBody = await response.stream.bytesToString();
        print('Server Response: $responseBody'); // Debugging : afficher la réponse du serveur

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Food item added successfully')),
        );

        // Rediriger directement vers HomeAdmin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeAdmin()),
        );
      } else {
        // Si le statut HTTP n'est pas 200, afficher l'erreur
        var responseBody = await response.stream.bytesToString();
        print('Error Response: $responseBody'); // Debugging : afficher l'erreur du serveur

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add food item')),
        );
      }
    } catch (e) {
      print('Error: $e'); // Pour voir l'erreur réelle en cas de problème de connexion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred, please try again later')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Color(0xFF373866),
            )),
        centerTitle: true,
        title: Text(
          "Add Item",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upload the Item Picture"),
              SizedBox(height: 20),
              selectedImage == null
                  ? GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
                  : Center(
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text("Item Name"),
              SizedBox(height: 10),
              TextField(controller: nameController, decoration: InputDecoration(hintText: "Enter Item Name")),
              SizedBox(height: 30),
              Text("Item Price"),
              SizedBox(height: 10),
              TextField(controller: priceController, decoration: InputDecoration(hintText: "Enter Item Price")),
              SizedBox(height: 30),
              Text("Item Detail"),
              SizedBox(height: 10),
              TextField(controller: detailController, decoration: InputDecoration(hintText: "Enter Item Detail")),
              SizedBox(height: 30),
              Text("Select Category"),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: category,
                hint: Text("Select Category"),
                items: foodItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    category = newValue!;
                  });
                },
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: addFood,
                child: Center(
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Add",
                          style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
