import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/curriculum_models.dart';

class PdfService {
  static Future<File?> generateDailyWorkPadPdf({
    required String day,
    required List<EnhancedEventBlock> lessons,
    required String teacherName,
  }) async {
    try {
      final pdf = pw.Document();

      // Add pages for the daily work pad
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) => [
            // Header
            _buildHeader(day, teacherName),
            pw.SizedBox(height: 20),
            
            // Lessons
            ...lessons.map((lesson) => _buildLessonPage(lesson)).toList(),
          ],
        ),
      );

      // Save PDF to temporary directory with platform-specific handling
      Directory output;
      try {
        if (kIsWeb) {
          // Web platform - use current directory
          output = Directory.current;
        } else if (Platform.isWindows) {
          // Windows - try temporary directory first, then fallback
          try {
            output = await getTemporaryDirectory();
          } catch (e) {
            debugPrint('Windows path_provider failed: $e');
            // Fallback to user temp directory
            output = Directory(Platform.environment['TEMP'] ?? Directory.current.path);
          }
        } else {
          // Other platforms (Android, iOS, etc.)
          output = await getTemporaryDirectory();
        }
      } catch (e) {
        debugPrint('Error getting directory: $e');
        // Final fallback to current directory
        output = Directory.current;
      }

      final file = File('${output.path}/daily_work_pad_${day.toLowerCase()}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  static pw.Widget _buildHeader(String day, String teacherName) {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$day - Daily Work Pad',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Teacher: $teacherName',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Date: ${DateTime.now().toString().split(' ')[0]}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildLessonPage(EnhancedEventBlock lesson) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 20),
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Lesson Header
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  lesson.subject,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                if (lesson.subtitle.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    lesson.subtitle,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          pw.SizedBox(height: 15),
          
          // Lesson Details
          if (lesson.body.isNotEmpty) ...[
            pw.Text(
              'Lesson Details:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.grey200),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                lesson.body,
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.SizedBox(height: 15),
          ],
          
          // Resources
          if (lesson.attachmentIds.isNotEmpty || lesson.hyperlinks.isNotEmpty) ...[
            pw.Text(
              'Resources:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 8),
            
            // Pictures
            if (lesson.attachmentIds.isNotEmpty) ...[
              pw.Text(
                'Pictures:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              ...lesson.attachmentIds.map((url) => pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '• $url',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.blue600,
                  ),
                ),
              )).toList(),
              pw.SizedBox(height: 8),
            ],
            
            // Links
            if (lesson.hyperlinks.isNotEmpty) ...[
              pw.Text(
                'Links:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              ...lesson.hyperlinks.map((linkData) {
                final parts = linkData.split('|');
                final linkTitle = parts.length > 0 ? parts[0] : 'Link';
                final linkUrl = parts.length > 1 ? parts[1] : linkData;
                
                return pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• $linkTitle: $linkUrl',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.blue600,
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ],
      ),
    );
  }

  static Future<void> sharePdf(File pdfFile) async {
    try {
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Daily Work Pad',
        subject: 'Daily Work Pad PDF',
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  static Future<void> printPdf(File pdfFile) async {
    try {
      // For now, we'll just share the PDF which can then be printed
      // In a full implementation, you might want to use a printing package
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Daily Work Pad - Print Version',
        subject: 'Daily Work Pad for Printing',
      );
    } catch (e) {
      debugPrint('Error printing PDF: $e');
    }
  }
} 