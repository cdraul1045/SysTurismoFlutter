import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class PDFViewerScreen extends StatelessWidget {
  final String path;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.path,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('El PDF se ha generado correctamente'),
            ElevatedButton(
              onPressed: () async {
                await OpenFile.open(path);
              },
              child: Text('Abrir PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
