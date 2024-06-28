import 'package:flutter/material.dart';

class ToolItem extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onTap;
  const ToolItem({Key? key, required this.image, required this.text, required this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 4.5,
        height: 70,
        margin: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 51,
              height: 51,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 5),
            Text(text,softWrap: true,style: const TextStyle(fontSize: 12),),
          ],
        ),
      ),
    );
  }
}