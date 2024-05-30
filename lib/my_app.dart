import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _image;
  String? _imageUrl;
  final picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _imageKey = 'uploaded_image_url';

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imageUrl = prefs.getString(_imageKey);
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final ref = _storage.ref(
          'uploads/${DateTime.now().millisecondsSinceEpoch}.${_image!.path.split('.').last}');
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imageKey, url);

      setState(() {
        _imageUrl = url;
        _image = null;
      });

      print('Upload complete');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteImage() async {
    if (_imageUrl == null) return;

    try {
      final ref = _storage.refFromURL(_imageUrl!);
      await ref.delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_imageKey);

      setState(() {
        _imageUrl = null;
      });

      print('Delete complete');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Storage Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? (_imageUrl == null
                      ? Text('No image selected.')
                      : Image.network(_imageUrl!))
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload Image'),
              ),
              ElevatedButton(
                onPressed: _deleteImage,
                child: Text('Delete Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
