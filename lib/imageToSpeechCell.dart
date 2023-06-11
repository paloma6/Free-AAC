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

  Map<String, dynamic> toJson() => {
        "cell_name": name,
        "cell_image_name": imageName,
        "children": children == null
            ? null
            : List<dynamic>.from(children!.map((x) => x.toJson())),
      };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/$imageName",
    );
  }
}
