import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controller/authController.dart';
import 'package:note_app/model/model.dart';

class NoteController extends GetxController {
  TextEditingController addnote = TextEditingController();
  TextEditingController editnote = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        getNote();
      } else {
        noteList.clear();
      }
    });
    if (auth.currentUser != null) {
      await getNote();
    }
  }

  final noteList = <NoteModel>[].obs;

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  AuthController authController = Get.put(AuthController());
  NoteModel noteModel = Get.put(NoteModel());
// dialog box
  void showAddNoteDialog() {
    Get.defaultDialog(
      title: "Add Note",
      content: TextFormField(
        controller: addnote,
        decoration: const InputDecoration(
          hintText: "Enter your note",
        ),
      ),
      textConfirm: "Add",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Add your note here
        addNote();
        Get.back();
      },
      onCancel: () {
        addnote.clear();
      },
    );
  }

// edit dialog box
  void showEditNoteDialog() {
    Get.defaultDialog(
      title: "Edit Note",
      content: TextFormField(
        controller: editnote,
        decoration: const InputDecoration(
          hintText: "Edit your note",
        ),
      ),
      textConfirm: "Edit",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Add your note here
        Get.back();
        editNote(DateTime.now().millisecondsSinceEpoch.toString()+);
      },
      onCancel: () {
        addnote.clear();
      },
    );
  }

// add note function
  void addNote() async {
    var notemodel = NoteModel(
      note: addnote.text,
      userName: authController.userName.text,
      noteI: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("note")
        .doc(notemodel.noteI)
        .set(notemodel.toJson());

    getNote();

    Get.snackbar("Note Added", "Note Added to Firestore",
        backgroundColor: Colors.green);
  }

// get note function
  Future<void> getNote() async {
    try {
      var data = await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("note")
          .get();
      noteList.clear();

      for (var note in data.docs) {
        noteList.add(NoteModel.fromJson(note.data()));
      }

      noteList.refresh();
    } catch (ex) {
      Get.snackbar("Error", ex.toString());
    }
  }

// delete note function
  Future<void> deleteNote(String noteId) async {
    try {
      await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("note")
          .doc(noteId)
          .delete()
          .then((value) => {
                Get.snackbar(
                    "Note Deleted", "Note Successfully Deleted form Firestore",
                    backgroundColor: Colors.green)
              });
      getNote();
    } catch (ex) {
      Get.snackbar("Error", ex.toString());
    }
  }

// edit not function
  Future<void> editNote(String edit) async {
   
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("note")
        .doc(edit)
        .update({"note": editnote.text});
    editnote.clear();
    getNote();
  }
}
