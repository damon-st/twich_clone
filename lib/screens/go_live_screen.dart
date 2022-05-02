import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:twich_clone/resources/firestore_methods.dart';
import 'package:twich_clone/responsive/responsive.dart';
import 'package:twich_clone/screens/broadcast_audio.dart';
import 'package:twich_clone/screens/broadcast_screen.dart';
import 'package:twich_clone/utils/colors.dart';
import 'package:twich_clone/utils/utils.dart';
import 'package:twich_clone/widgets/custom_botton.dart';
import 'package:twich_clone/widgets/custom_textfiled.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final _titleController = TextEditingController();

  Uint8List? image;

  void selectImage() async {
    Uint8List? pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void goLiveStream() async {
    String channelId = await FirestoreMhetods()
        .starLiveStream(context, _titleController.text, image, type: "audio");

    if (channelId.isNotEmpty) {
      showSnackBar(context, "Livestream has started succesfully");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BroadcastAudio(
            isBroadCaster: true,
            channelId: channelId,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Responsive(
      child: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: selectImage,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 22.0,
                        ),
                        child: image != null
                            ? SizedBox(
                                height: 300,
                                child: Image.memory(image!),
                              )
                            : DottedBorder(
                                strokeCap: StrokeCap.round,
                                color: buttonColor,
                                dashPattern: const [
                                  10,
                                  10,
                                ],
                                radius: const Radius.circular(
                                  10,
                                ),
                                borderType: BorderType.RRect,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.folder_open,
                                        color: buttonColor,
                                        size: 40,
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Selected your thumbnail",
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    color: buttonColor.withOpacity(0.05),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Title",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: CustomTextField(
                            controller: _titleController,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: CustomButton(
                    text: "Go live!",
                    ontTap: goLiveStream,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
