import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:note_app/components/image.dart';
import 'package:note_app/controller/authController.dart';
import 'package:note_app/controller/noteController.dart';
import 'package:note_app/pages/editor/editor.dart';
import 'package:note_app/widgets/blanknote.dart';
import 'package:note_app/widgets/notesearchtile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    NoteController noteController = Get.put(NoteController());
    return SafeArea(
      child: Scaffold(
        floatingActionButton: SizedBox(
          height: 75,
          width: 80,
          child: FloatingActionButton(
              shape: CircleBorder(),
              elevation: 5,
              backgroundColor: Theme.of(context).colorScheme.background,
              onPressed: () {
                // noteController.showAddNoteDialog();
                Get.to(Editor());
              },
              child: Center(
                child: SvgPicture.asset(
                  MyIcons.add,
                ),
              )),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
            child: Column(
              children: [
                NoteSearchtile(),
                const SizedBox(
                  height: 15,
                ),
                Obx(() => noteController.hasNote.value
                    ? Column(
                        children: List.generate(
                          noteController.noteList.length,
                          (i) {
                            final note = noteController.noteList[i];
                            final Color backgroundColor = i % 2 == 0
                                ? Theme.of(context).colorScheme.background
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer;

                            return Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    note.note.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    String noteIdToDelete =
                                        note.noteI.toString();
                                    noteController.deleteNote(noteIdToDelete);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : BlankNote()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
