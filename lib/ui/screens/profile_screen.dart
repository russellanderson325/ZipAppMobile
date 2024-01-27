// import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zipapp/business/auth.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/models/user.dart';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:zipapp/ui/widgets/custom_alert_dialog.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zipapp/ui/widgets/custom_flat_button.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late VoidCallback onBackPress;
  final AuthService auth = AuthService();
  final UserService userService = UserService();
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _homeAddress = TextEditingController();
  bool _blackVisible = false;
  bool _isEditing = false;
  late UploadTask? _uploadTask;
  late User user;

  @override
  void initState() {
    super.initState();

    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

/*
  Looks for Storage task created when uploading photo to
  Firestorage.
*/
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
        stream: _uploadTask?.snapshotEvents,
        builder: (_, snapshot) {
          var event = snapshot.data;
          double progress =
              (event != null) ? event.bytesTransferred / event.totalBytes : 0;
          return AlertDialog(
              title: _uploadTask?.snapshot.state == TaskState.running
                  ? const Text("Loading")
                  : const Align(
                      alignment: Alignment.center, child: Text("Finished")),
              content: SizedBox(
                height: 150,
                child: Column(children: <Widget>[
                  if (_uploadTask?.snapshot.state == TaskState.running)
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.green,
                    ),
                  if (_uploadTask?.snapshot.state == TaskState.running)
                    const Icon(Icons.thumb_up, size: 50.0),
                  _uploadTask?.snapshot.state == TaskState.running
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _uploadTask = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(76, 86, 96, 1.0)),
                            child: const Text(
                              "Continue",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Bebas",
                                  fontWeight: FontWeight.w300,
                                  fontSize: 24.0,
                                  decoration: TextDecoration.none),
                            ),
                          ),
                        )
                      : Container(),
                ]),
              ));
        });
  }

  void _changeBlackVisible() {
    setState(() {
      _blackVisible = !_blackVisible;
    });
  }

  Widget getEditButton(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.edit, color: Color.fromRGBO(255, 242, 0, 1.0)),
        onPressed: () {
          setState(() {
            _isEditing = true;
          });
        });
  }

  //Builds action buttons for users when editing profile.
  Widget getSaveAndCancel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ElevatedButton(
            onPressed: () async {
              await _editInfo(
                  firstname: _firstname.text,
                  lastname: _lastname.text,
                  email: _email.text,
                  phone: _number.text,
                  home: _homeAddress.text);

              setState(() {
                _isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text(
              "Save",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(255, 242, 0, 1.0),
                  fontFamily: "Bebas",
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                //reset all textEditing Controllers.
                //_updateTextEditingControllers();
                _isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text(
              "Cancel",
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(255, 242, 0, 1.0),
                  fontFamily: "Bebas",
                  fontWeight: FontWeight.w300,
                  fontSize: 24.0,
                  decoration: TextDecoration.none),
            ),
          ),
        ),
      ],
    );
  }

/*
  Returns a card template.
*/
  Widget buildCards(
      BuildContext context, Icon prefIcon, TextEditingController controller) {
    return Card(
      elevation: 0.0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      color: Colors.white,
      child: TextField(
        enabled: _isEditing,
        controller: controller,
        onChanged: (text) {},
        style: const TextStyle(
            color: Color.fromRGBO(76, 86, 96, 1.0),
            fontFamily: "Poppins",
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.none),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(),
            child: prefIcon,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

/*
  Allows customer to edit information.
*/
  Future<void> _editInfo(
      {required String firstname,
      required String lastname,
      required String phone,
      required String email,
      required String home}) async {
    _changeBlackVisible();
    if (Validator.validateName(firstname) &&
        Validator.validateName(lastname) &&
        Validator.validateEmail(email) &&
        Validator.validateNumber(phone)) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        //Updating information from user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userService.userID)
            .update({
          'firstName': firstname,
          'lastName': lastname,
          'phone': phone,
          'email': email,
          'homeAddress': home
        }).then((blah) {
          _changeBlackVisible();
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error when editing profile information: $e");
        }
        String exception = auth.getExceptionText(e as PlatformException);
        _showErrorAlert(
          title: "Edit profile failed",
          content: exception,
          onPressed: _changeBlackVisible,
        );
        _changeBlackVisible();
      }
    }
  }

  void _showErrorAlert(
      {required String title,
      required String content,
      required VoidCallback onPressed}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          content: content,
          title: title,
          onPressed: onPressed,
        );
      },
    );
  }

  // void _showPasswordChangePopup(
  //     {String title, String content, VoidCallback onPressed}) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return CustomAlertDialog(
  //         content: content,
  //         title: title,
  //         onPressed: onPressed,
  //       );
  //     },
  //   );
  // }

//Will check if user has a image for original display
//If no picture, display default
//Else, grab photo from URL provided by FireStorage
  // void _takePicOrGalleryPopup() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           contentPadding: const EdgeInsets.all(5.0),
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(32.0))),
  //           title: const Text(
  //             "Upload Photo",
  //             softWrap: true,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: Colors.black,
  //               decoration: TextDecoration.none,
  //               fontSize: 18,
  //               fontWeight: FontWeight.w700,
  //               fontFamily: "Bebas",
  //             ),
  //           ),
  //           content: SizedBox(
  //             height: 275,
  //             child: Column(
  //               children: <Widget>[
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 40.0, bottom: 15.0),
  //                   child: CustomTextButton(
  //                     title: "Take a picture",
  //                     fontSize: 18.0,
  //                     fontWeight: FontWeight.w700,
  //                     textColor: const Color.fromRGBO(76, 86, 96, 1.0),
  //                     onPressed: () {
  //                       _takePictureFromPhone();
  //                       Navigator.of(context).pop();
  //                     },
  //                     splashColor: Colors.black12,
  //                     borderColor: Colors.black12,
  //                     borderWidth: 2,
  //                   ),
  //                 ),
  //                 const Text(
  //                   "Or",
  //                   softWrap: true,
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: Colors.black,
  //                     decoration: TextDecoration.none,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w700,
  //                     fontFamily: "Bebas",
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
  //                   child: CustomTextButton(
  //                     title: "Choose a picture from photos",
  //                     fontSize: 18.0,
  //                     fontWeight: FontWeight.w700,
  //                     textColor: const Color.fromRGBO(76, 86, 96, 1.0),
  //                     onPressed: () {
  //                       _getPictureFromGallery();
  //                       Navigator.of(context).pop();
  //                     },
  //                     splashColor: Colors.black12,
  //                     borderColor: Colors.black12,
  //                     borderWidth: 2,
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
  //                   child: CustomTextButton(
  //                     title: "Cancel",
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w700,
  //                     textColor: Colors.black,
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     splashColor: Colors.black12,
  //                     borderColor: Colors.black12,
  //                     borderWidth: 2,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

/*
  Takes picture from CAMERA using image picture package.
*/
  // Future<void> _takePictureFromPhone() async {
  //   var img = await ImagePicker.pickImage(source: ImageSource.camera);
  //   await _uploadPhoto(img);
  // }

/*
  Takes picture from GALLERY using image picture package.
*/
  // Future<void> _getPictureFromGallery() async {
  //   var img = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   await _uploadPhoto(img);
  // }

  // Future<void> _uploadPhoto(File img) async {
  //   try {
  //     final StorageReference storageRef = FirebaseStorage.instance
  //         .ref()
  //         .child('FCMImages/user_profiles/${userService.userID}');
  //     setState(() {
  //       _uploadTask = storageRef.putFile(img);
  //     });
  //     _uploadTask.onComplete.then((asd) {
  //       storageRef.getDownloadURL().then((fileURL) async {
  //         await Firestore.instance
  //             .collection('users')
  //             .document(userService.userID)
  //             .updateData({'profilePictureURL': fileURL});
  //       });
  //     });
  //   } catch (e) {
  //     _showErrorAlert(
  //       title: "Upload photo failed",
  //       content: e,
  //       onPressed: _changeBlackVisible,
  //     );
  //   }
  // }
}
