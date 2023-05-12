import "package:flutter/material.dart";

class ImageToSpeechCell extends StatelessWidget {
  final String imageName;
  final String name;
  final List<ImageToSpeechCell>? children;

  const ImageToSpeechCell(this.name, this.imageName, this.children,
      {super.key});

  factory ImageToSpeechCell.fromJson(Map<String, dynamic> json) =>
      ImageToSpeechCell(
        json["cell_name"],
        json["cell_image_name"],
        json["children"] == null
            ? null
            : List<ImageToSpeechCell>.from(
                json["children"]!.map((x) => ImageToSpeechCell.fromJson(x))),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              "images/$imageName",
            ),
          ),
          Text(name),
        ],
      ),
    );
  }
}
