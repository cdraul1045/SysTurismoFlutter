import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import '../models/destino_model.dart';
import '../screens/pdf_viewer_screen.dart';

class ReportService {
  Future<void> generarReportePDF(BuildContext context, List<Destino> destinos) async {
    try {
      // Create PDF document
      final pdfDoc = pdf.Document();

      // Add title
      pdfDoc.addPage(pdf.Page(
        build: (pdf.Context context) {
          return pdf.Column(
            children: [
              pdf.Text(
                'Reporte de Destinos Turísticos',
                style: pdf.TextStyle(
                  fontSize: 24,
                  fontWeight: pdf.FontWeight.bold,
                ),
              ),
              pdf.SizedBox(height: 20),
              pdf.Text(
                'Fecha: ${DateTime.now().toString().split('.')[0]}',
                style: pdf.TextStyle(fontSize: 12),
              ),
              pdf.SizedBox(height: 30),
              
              // Table header
              pdf.Table(
                border: pdf.TableBorder.all(),
                children: [
                  pdf.TableRow(
                    children: [
                      pdf.Center(child: pdf.Text('ID', style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold))),
                      pdf.Center(child: pdf.Text('Nombre', style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold))),
                      pdf.Center(child: pdf.Text('Descripción', style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold))),
                      pdf.Center(child: pdf.Text('Ubicación', style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold))),
                      pdf.Center(child: pdf.Text('Imagen', style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold))),
                    ],
                  ),
                ],
              ),
              pdf.SizedBox(height: 10),
              
              // Table data
              pdf.Table(
                border: pdf.TableBorder.all(),
                children: destinos.map((destino) {
                  return pdf.TableRow(
                    children: [
                      pdf.Center(child: pdf.Text(destino.idDestino.toString())),
                      pdf.Center(child: pdf.Text(destino.nombre ?? '')),
                      pdf.Center(child: pdf.Text(destino.descripcion ?? '')),
                      pdf.Center(child: pdf.Text(destino.ubicacion ?? '')),
                      pdf.Center(child: pdf.Text(destino.imagenPath ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        },
      ));

      // Save PDF to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/reporte_destinos.pdf');
      await tempFile.writeAsBytes(await pdfDoc.save());

      // Open the PDF file using native viewer
      if (context.mounted) {
        await OpenFile.open(tempFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar el reporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
