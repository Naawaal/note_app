import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/controller/authController.dart';
import 'package:note_app/model/model.dart';

class NoteController extends GetxController {
  TextEditingController addnote = TextEditingController();
  TextEditingController adddes = TextEditingController();
  TextEditingController editnote = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();
    hasNote.value = noteList.isNotEmpty;
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

  RxBool hasNote = false.obs;

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  AuthController authController = Get.put(AuthController());

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
        addNote();
        Get.back();
      },
      onCancel: () {
        addnote.clear();
      },
    );
  }

  void showEditNoteDialog({required String docNoteID}) {
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
        Get.back();
        editNote(docNoteID);
      },
      onCancel: () {
        addnote.clear();
      },
    );
  }

  void addNote() async {
    var notemodel = NoteModel(
      note: addnote.text,
      des: adddes.text,
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

      hasNote.value = noteList.isNotEmpty; // Update hasNote based on noteList

      noteList.refresh();
      getNote();
    } catch (ex) {
      Get.snackbar("Error", ex.toString());
    }
  }

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

  Future<void> editNote(String noteDocID) async {
    await db
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("note")
        .doc(noteDocID)
        .update({"note": editnote.text});
    editnote.clear();
    getNote();
  }
}
