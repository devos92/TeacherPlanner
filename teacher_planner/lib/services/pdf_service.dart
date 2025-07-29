// lib/services/pdf_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// PDF service for generating lesson plans, reports, and documents
/// Used in day detail page for exporting lesson plans
class PdfService {
  static PdfService? _instance;
  static PdfService get instance => _instance ??= PdfService._();
  
  PdfService._();

  /// Generate weekly lesson plan PDF
  Future<Uint8List?> generateWeeklyPlanPdf({
    required String title,
    required List<Map<String, dynamic>> lessons,
    required DateTime weekStart,
    String? teacherName,
    String? schoolName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(title, teacherName, schoolName, weekStart),
                pw.SizedBox(height: 20),
                
                // Lessons
                ...lessons.map((lesson) => _buildLessonCard(lesson)),
              ],
            );
          },
        ),
      );

      return await pdf.save();
    } catch (e) {
      debugPrint('❌ Error generating weekly plan PDF: $e');
      return null;
    }
  }

  /// Generate daily lesson plan PDF
  Future<Uint8List?> generateDailyPlanPdf({
    required String title,
    required Map<String, dynamic> lesson,
    required DateTime date,
    String? teacherName,
    String? schoolName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(title, teacherName, schoolName, date),
                pw.SizedBox(height: 20),
                
                // Lesson details
                _buildDetailedLessonCard(lesson),
              ],
            );
          },
        ),
      );

      return await pdf.save();
    } catch (e) {
      debugPrint('❌ Error generating daily plan PDF: $e');
      return null;
    }
  }

  /// Generate term plan PDF
  Future<Uint8List?> generateTermPlanPdf({
    required String title,
    required List<Map<String, dynamic>> events,
    required DateTime termStart,
    required DateTime termEnd,
    String? teacherName,
    String? schoolName,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(title, teacherName, schoolName, termStart),
                pw.SizedBox(height: 20),
                
                // Term period
                _buildTermPeriod(termStart, termEnd),
                pw.SizedBox(height: 20),
                
                // Events
                ...events.map((event) => _buildEventCard(event)),
              ],
            );
          },
        ),
      );

      return await pdf.save();
    } catch (e) {
      debugPrint('❌ Error generating term plan PDF: $e');
      return null;
    }
  }

  /// Save PDF to local storage
  Future<String?> savePdfLocally({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      debugPrint('✅ PDF saved locally: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error saving PDF locally: $e');
      return null;
    }
  }

  /// Share PDF file
  Future<bool> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      // In a real implementation, you'd use share_plus package
      debugPrint('✅ PDF ready for sharing: $filePath');
      return true;
    } catch (e) {
      debugPrint('❌ Error preparing PDF for sharing: $e');
      return false;
    }
  }

  // Private helper methods

  pw.Widget _buildHeader(String title, String? teacherName, String? schoolName, DateTime date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 8),
        if (teacherName != null)
          pw.Text(
            'Teacher: $teacherName',
            style: pw.TextStyle(fontSize: 14),
          ),
        if (schoolName != null)
          pw.Text(
            'School: $schoolName',
            style: pw.TextStyle(fontSize: 14),
          ),
        pw.Text(
          'Date: ${_formatDate(date)}',
          style: pw.TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  pw.Widget _buildLessonCard(Map<String, dynamic> lesson) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 10),
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lesson['title'] ?? 'Untitled Lesson',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          if (lesson['period'] != null)
            pw.Text(
              'Period: ${lesson['period']}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
          if (lesson['body'] != null)
            pw.Text(
              lesson['body'],
              style: pw.TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailedLessonCard(Map<String, dynamic> lesson) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            lesson['title'] ?? 'Untitled Lesson',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 10),
          if (lesson['period'] != null) ...[
            pw.Text(
              'Period: ${lesson['period']}',
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 8),
          ],
          if (lesson['body'] != null) ...[
            pw.Text(
              'Lesson Details:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              lesson['body'],
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),
          ],
          if (lesson['notes'] != null) ...[
            pw.Text(
              'Notes:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              lesson['notes'],
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildTermPeriod(DateTime start, DateTime end) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'Term Period: ${_formatDate(start)} - ${_formatDate(end)}',
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildEventCard(Map<String, dynamic> event) {
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: 8),
      padding: pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              color: _getEventColor(event['type']),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  event['title'] ?? 'Untitled Event',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (event['date'] != null)
                  pw.Text(
                    'Date: ${_formatDate(DateTime.parse(event['date']))}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PdfColor _getEventColor(String? eventType) {
    switch (eventType?.toLowerCase()) {
      case 'holiday':
        return PdfColors.red;
      case 'exam':
        return PdfColors.orange;
      case 'event':
        return PdfColors.blue;
      default:
        return PdfColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 