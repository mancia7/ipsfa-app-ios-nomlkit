import 'package:flutter/material.dart';

class SectionCard extends StatefulWidget {
  final String title ;
  final List<Widget> children;
  const SectionCard({super.key, required this.title, required this.children});

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).size.width;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                //Icon(icon,color: Provider.of<ThemeProvider>(context,listen: false).iconColor, size: textScale*0.08,),
                const SizedBox(width: 8),
                Text(widget.title,
                    style: TextStyle(
                        fontSize: textScale*0.08, fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.children
          ],
        ),
      ),
    );
  }
}
