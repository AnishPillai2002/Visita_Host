import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visita_host/constants.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visita_host/pages/home_page.dart';
import 'package:visita_host/pages/root_app.dart';

class FacilityDetails extends StatefulWidget {
  const FacilityDetails({super.key});

  @override
  State<FacilityDetails> createState() => _FacilityDetailsState();
}

class _FacilityDetailsState extends State<FacilityDetails> {
  TextEditingController accomodation = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController facilities = TextEditingController();
  TextEditingController nameofHost = TextEditingController();
  TextEditingController phone = TextEditingController();
  late Position position;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;

  XFile? imageFile;

  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final ImagePicker picker = ImagePicker();
      print("CApturing");
      imageFile = await picker.pickImage(source: imageSource);
      setState(() {
        imageFile = imageFile;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> setHost(XFile? image) async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print(position.longitude); //Output: 80.24599079
        print(position.latitude);
        try {
          print("Uploading Faclities");
          var response = await http.post(
              Uri.parse("https://visita-api.onrender.com/api/v1/facilities/"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "id": firebaseUser!.uid,
                "accommodation": accomodation.text,
                "location": location.text,
                "facility": facilities.text,
                "hostName": nameofHost.text,
                "phone": phone.text,
                "price": price.text,
                "postedBy": firebaseUser.displayName,
                "userURL": firebaseUser.photoURL,
                "lat": position.latitude.toString(),
                "long": position.longitude.toString(),
              }));
          print(response.body);
          String id = jsonDecode(response.body)['_id'];

          print("Sending second resp");

          var request = http.MultipartRequest(
              "POST",
              Uri.parse(
                  "https://visita-api.onrender.com/api/v1/facilities/$id"));
          request.files.add(http.MultipartFile.fromBytes(
              'image', File(imageFile!.path).readAsBytesSync(),
              filename: imageFile!.path));
          var res = await request.send();
          final respStr = await res.stream.bytesToString();
          print(respStr);
          print(res.statusCode);

          // print(widget.metaMaskaddress);
          // if (widget.metaMaskaddress != null) {
          //   MintNFT();
          // }
        } catch (e) {
          print(e);
        }
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: Colors.transparent,

          // Status bar brightness (optional)
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Facility"),
          ],
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageFile != null
                  ? Image.file(File(imageFile!.path))
                  : SizedBox(
                      height: 180,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        color: Color.fromARGB(255, 231, 235, 237),
                        child: Center(
                          child: ElevatedButton(
                            child: Text("Add Image"),
                            onPressed: () {
                              captureImage(ImageSource.gallery);
                            },
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              Text("Accomomdation Name",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: accomodation,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  hintText: "Enter the Name of the Accomodation",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 8, 45, 15),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Price ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: price,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  hintText: "Enter the Price You Charge",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 8, 45, 15),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Location",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: location,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  hintText: "Enter the Location",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 8, 45, 15),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Facilities ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: facilities,
                minLines: 1,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  hintText: "Enter the Facilities You Offer",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 8, 45, 15),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Name of Host ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: nameofHost,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  hintText: "Enter Your Name",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 8, 45, 15),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Contact Number ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  )),
              SizedBox(
                height: 5,
              ),
              TextField(
                controller: phone,
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 1,
                    ),
                  ),
                  hintText: "Phone Number",
                  hintStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 8, 45, 15),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text(
                      'Submit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      backgroundColor: Color.fromARGB(255, 129, 185, 231),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    onPressed: () {
                      SnackBar s;
                      if (imageFile == null) {
                        s = SnackBar(content: Text("Please add an Image"));
                      }
                      if (accomodation.text.isEmpty) {
                        s = SnackBar(
                            content:
                                Text("Please add a name for Accomodation"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (imageFile == null) {
                        s = SnackBar(content: Text("Please add an Image"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (phone.text.isEmpty) {
                        s = SnackBar(
                            content: Text("Please add a Contact Number"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (location.text.isEmpty) {
                        s = SnackBar(content: Text("Please add a Location"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (price.text.isEmpty) {
                        s = SnackBar(content: Text("Please add a Price"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (phone.text.isEmpty) {
                        s = SnackBar(
                            content: Text("Please add a Contact Number"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (facilities.text.isEmpty) {
                        s = SnackBar(
                            content: Text("Please add atleast one facility"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }
                      if (nameofHost.text.isEmpty) {
                        s = SnackBar(
                            content: Text("Please add name of the Host"));
                        ScaffoldMessenger.of(context).showSnackBar(s);
                        return;
                      }

                      setHost(imageFile).then((value) => setState(() {
                            accomodation.text = "";
                            nameofHost.text = "";
                            facilities.text = "";
                            phone.text = "";
                            price.text = "";
                            location.text = "";
                            phone.text = "";
                            imageFile = null;
                          }));
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    child: const Text(
                      'Reset',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      backgroundColor: Color.fromARGB(255, 129, 185, 231),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        imageFile = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
