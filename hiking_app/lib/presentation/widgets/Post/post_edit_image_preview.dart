import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatelessWidget {
  final Image imageWidget;
  final String? imageName;
  final VoidCallback onRemove;
  final VoidCallback onChange;

  const ImagePreviewWidget({
    Key? key,
    required this.imageWidget,
    required this.imageName,
    required this.onRemove,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Selected: ${imageName ?? 'Image'}',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Remove'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: onChange,
          icon: const Icon(Icons.image),
          label: const Text('Change Image'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }
}
