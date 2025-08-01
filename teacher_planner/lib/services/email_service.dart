// lib/services/email_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Email service for verification, password reset, and notifications
/// Adapted from JS email patterns
class EmailService {
  static EmailService? _instance;
  static EmailService get instance => _instance ??= EmailService._();
  
  EmailService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Email templates and configuration
  static const String _appName = 'Teacher Planner';
  static const String _appUrl = 'https://teacherplanner.app'; // Replace with your domain
  static const String _supportEmail = 'support@teacherplanner.app';

  /// Send email verification (matching JS email verification pattern)
  Future<bool> sendVerificationEmail(String email, String userId) async {
    try {
      // Generate verification token
      final verificationToken = _generateVerificationToken();
      final expiresAt = DateTime.now().add(Duration(hours: 24));

      // Store verification token in database
      await _supabase.from('email_verifications').insert({
        'user_id': userId,
        'email': email,
        'token': verificationToken,
        'type': 'email_verification',
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Create verification URL
      final verificationUrl = '$_appUrl/verify-email?token=$verificationToken&email=${Uri.encodeComponent(email)}';

      // Email content
      final subject = 'Verify your email address - $_appName';
      final htmlContent = _buildVerificationEmailHtml(email, verificationUrl);
      final textContent = _buildVerificationEmailText(email, verificationUrl);

      // Send email using Supabase Edge Functions or external service
      final success = await _sendEmail(
        to: email,
        subject: subject,
        htmlContent: htmlContent,
        textContent: textContent,
      );

      if (success) {
        debugPrint('✅ Verification email sent to: $email');
        return true;
      } else {
        debugPrint('❌ Failed to send verification email to: $email');
        return false;
      }

    } catch (e) {
      debugPrint('❌ Error sending verification email: $e');
      return false;
    }
  }

  /// Send password reset email (matching JS password reset pattern)
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      // Check if user exists
      final user = await _supabase
          .from('users')
          .select('id, first_name')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      if (user == null) {
        debugPrint('User not found for password reset: $email');
        return false;
      }

      // Generate reset token
      final resetToken = _generateResetToken();
      final expiresAt = DateTime.now().add(Duration(hours: 1)); // 1 hour expiry

      // Store reset token in database
      await _supabase.from('password_resets').insert({
        'user_id': user['id'],
        'email': email,
        'token': resetToken,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'used': false,
      });

      // Create reset URL
      final resetUrl = '$_appUrl/reset-password?token=$resetToken&email=${Uri.encodeComponent(email)}';

      // Email content
      final subject = 'Reset your password - $_appName';
      final htmlContent = _buildPasswordResetEmailHtml(email, resetUrl);
      final textContent = _buildPasswordResetEmailText(email, resetUrl);

      // Send email
      final success = await _sendEmail(
        to: email,
        subject: subject,
        htmlContent: htmlContent,
        textContent: textContent,
      );

      if (success) {
        debugPrint('✅ Password reset email sent to: $email');
        return true;
      } else {
        debugPrint('❌ Failed to send password reset email to: $email');
        return false;
      }

    } catch (e) {
      debugPrint('❌ Error sending password reset email: $e');
      return false;
    }
  }

  /// Verify email token (matching JS verification pattern)
  Future<bool> verifyEmailToken(String token, String email) async {
    try {
      // Find verification record
      final verification = await _supabase
          .from('email_verifications')
          .select('*')
          .eq('token', token)
          .eq('email', email)
          .eq('type', 'email_verification')
          .maybeSingle();

      if (verification == null) {
        debugPrint('Verification token not found: $token');
        return false;
      }

      // Check if token is expired
      final expiresAt = DateTime.parse(verification['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        debugPrint('Verification token expired: $token');
        return false;
      }

      // Update user verification status
      await _supabase
          .from('users')
          .update({
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', verification['user_id']);

      // Mark verification as used
      await _supabase
          .from('email_verifications')
          .update({
            'verified': true,
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', verification['id']);

      debugPrint('✅ Email verified successfully: $email');
      return true;

    } catch (e) {
      debugPrint('❌ Error verifying email token: $e');
      return false;
    }
  }

  /// Verify password reset token
  Future<bool> verifyPasswordResetToken(String token, String email) async {
    try {
      // Find reset record
      final reset = await _supabase
          .from('password_resets')
          .select('*')
          .eq('token', token)
          .eq('email', email)
          .maybeSingle();

      if (reset == null) {
        debugPrint('Password reset token not found: $token');
        return false;
      }

      // Check if token is expired
      final expiresAt = DateTime.parse(reset['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        debugPrint('Password reset token expired: $token');
        return false;
      }

      // Check if already used
      if (reset['used'] == true) {
        debugPrint('Password reset token already used: $token');
        return false;
      }

      return true;

    } catch (e) {
      debugPrint('❌ Error verifying password reset token: $e');
      return false;
    }
  }

  /// Complete password reset
  Future<bool> completePasswordReset(String token, String email, String newPassword) async {
    try {
      // Verify token first
      final isValid = await verifyPasswordResetToken(token, email);
      if (!isValid) return false;

      // Get reset record
      final reset = await _supabase
          .from('password_resets')
          .select('*')
          .eq('token', token)
          .eq('email', email)
          .single();

      // Hash new password
      final salt = await AuthService.instance.generateSecureSalt();
      final hashedPassword = await AuthService.instance.hashPassword(newPassword, salt);

      // Update user password
      await _supabase
          .from('users')
          .update({
            'password_hash': hashedPassword,
            'salt': salt,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reset['user_id']);

      // Mark reset as used
      await _supabase
          .from('password_resets')
          .update({
            'used': true,
            'used_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reset['id']);

      debugPrint('✅ Password reset completed successfully: $email');
      return true;

    } catch (e) {
      debugPrint('❌ Error completing password reset: $e');
      return false;
    }
  }

  /// Send welcome email
  Future<bool> sendWelcomeEmail(String email, String firstName) async {
    try {
      final subject = 'Welcome to $_appName!';
      final htmlContent = _buildWelcomeEmailHtml(firstName);
      final textContent = _buildWelcomeEmailText(firstName);

      final success = await _sendEmail(
        to: email,
        subject: subject,
        htmlContent: htmlContent,
        textContent: textContent,
      );

      if (success) {
        debugPrint('✅ Welcome email sent to: $email');
        return true;
      } else {
        debugPrint('❌ Failed to send welcome email to: $email');
        return false;
      }

    } catch (e) {
      debugPrint('❌ Error sending welcome email: $e');
      return false;
    }
  }

  /// Send security alert email
  Future<bool> sendSecurityAlertEmail(String email, String action, String details) async {
    try {
      final subject = 'Security Alert - $_appName';
      final htmlContent = _buildSecurityAlertEmailHtml(action, details);
      final textContent = _buildSecurityAlertEmailText(action, details);

      final success = await _sendEmail(
        to: email,
        subject: subject,
        htmlContent: htmlContent,
        textContent: textContent,
      );

      if (success) {
        debugPrint('✅ Security alert email sent to: $email');
        return true;
      } else {
        debugPrint('❌ Failed to send security alert email to: $email');
        return false;
      }

    } catch (e) {
      debugPrint('❌ Error sending security alert email: $e');
      return false;
    }
  }

  // Private methods

  String _generateVerificationToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _generateResetToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  Future<bool> _sendEmail({
    required String to,
    required String subject,
    required String htmlContent,
    required String textContent,
  }) async {
    try {
      // Get Mailgun configuration from environment
      final mailgunApiKey = dotenv.env['EMAIL_SERVICE_API_KEY'];
      final mailgunDomain = dotenv.env['EMAIL_SERVICE_URL'];
      
      if (mailgunApiKey == null || mailgunApiKey.isEmpty || 
          mailgunDomain == null || mailgunDomain.isEmpty) {
        debugPrint('❌ Mailgun configuration missing. Please check your .env file.');
        return false;
      }

      // Mailgun API endpoint
      final mailgunUrl = 'https://api.mailgun.net/v3/$mailgunDomain/messages';
      
      // Prepare form data for Mailgun
      final formData = {
        'from': 'TeacherPlanner <noreply@$mailgunDomain>',
        'to': to,
        'subject': subject,
        'html': htmlContent,
        'text': textContent,
      };

      // Make HTTP request to Mailgun
      final response = await http.post(
        Uri.parse(mailgunUrl),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('api:$mailgunApiKey'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully via Mailgun to: $to');
        return true;
      } else {
        debugPrint('❌ Mailgun API error: ${response.statusCode} - ${response.body}');
        return false;
      }

    } catch (e) {
      debugPrint('❌ Error sending email via Mailgun: $e');
      return false;
    }
  }

  // Email templates

  String _buildVerificationEmailHtml(String email, String verificationUrl) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Verify your email</title>
    </head>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #2563eb;">Welcome to $_appName!</h1>
            <p>Hi there,</p>
            <p>Thank you for signing up for $_appName. To complete your registration, please verify your email address by clicking the button below:</p>
            
            <div style="text-align: center; margin: 30px 0;">
                <a href="$verificationUrl" style="background-color: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">Verify Email Address</a>
            </div>
            
            <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #666;">$verificationUrl</p>
            
            <p>This link will expire in 24 hours.</p>
            
            <p>If you didn't create an account with $_appName, you can safely ignore this email.</p>
            
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #666; font-size: 14px;">
                Need help? Contact us at <a href="mailto:$_supportEmail">$_supportEmail</a>
            </p>
        </div>
    </body>
    </html>
    ''';
  }

  String _buildVerificationEmailText(String email, String verificationUrl) {
    return '''
    Welcome to $_appName!
    
    Thank you for signing up for $_appName. To complete your registration, please verify your email address by visiting the link below:
    
    $verificationUrl
    
    This link will expire in 24 hours.
    
    If you didn't create an account with $_appName, you can safely ignore this email.
    
    Need help? Contact us at $_supportEmail
    ''';
  }

  String _buildPasswordResetEmailHtml(String email, String resetUrl) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Reset your password</title>
    </head>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #dc2626;">Reset Your Password</h1>
            <p>Hi there,</p>
            <p>We received a request to reset your password for your $_appName account. Click the button below to create a new password:</p>
            
            <div style="text-align: center; margin: 30px 0;">
                <a href="$resetUrl" style="background-color: #dc2626; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">Reset Password</a>
            </div>
            
            <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #666;">$resetUrl</p>
            
            <p>This link will expire in 1 hour.</p>
            
            <p>If you didn't request a password reset, you can safely ignore this email.</p>
            
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #666; font-size: 14px;">
                Need help? Contact us at <a href="mailto:$_supportEmail">$_supportEmail</a>
            </p>
        </div>
    </body>
    </html>
    ''';
  }

  String _buildPasswordResetEmailText(String email, String resetUrl) {
    return '''
    Reset Your Password
    
    We received a request to reset your password for your $_appName account. Visit the link below to create a new password:
    
    $resetUrl
    
    This link will expire in 1 hour.
    
    If you didn't request a password reset, you can safely ignore this email.
    
    Need help? Contact us at $_supportEmail
    ''';
  }

  String _buildWelcomeEmailHtml(String firstName) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Welcome to $_appName!</title>
    </head>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #059669;">Welcome to $_appName, $firstName!</h1>
            <p>Hi $firstName,</p>
            <p>Welcome to $_appName! Your account has been successfully created and verified.</p>
            
            <p>Here's what you can do with $_appName:</p>
            <ul>
                <li>Create and manage weekly lesson plans</li>
                <li>Organize term planning with events and holidays</li>
                <li>Develop long-term curriculum planning</li>
                <li>Access curriculum resources and outcomes</li>
                <li>Share and collaborate with other teachers</li>
            </ul>
            
            <p>Ready to get started? Log in to your account and start planning!</p>
            
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #666; font-size: 14px;">
                Need help? Contact us at <a href="mailto:$_supportEmail">$_supportEmail</a>
            </p>
        </div>
    </body>
    </html>
    ''';
  }

  String _buildWelcomeEmailText(String firstName) {
    return '''
    Welcome to $_appName, $firstName!
    
    Hi $firstName,
    
    Welcome to $_appName! Your account has been successfully created and verified.
    
    Here's what you can do with $_appName:
    - Create and manage weekly lesson plans
    - Organize term planning with events and holidays
    - Develop long-term curriculum planning
    - Access curriculum resources and outcomes
    - Share and collaborate with other teachers
    
    Ready to get started? Log in to your account and start planning!
    
    Need help? Contact us at $_supportEmail
    ''';
  }

  String _buildSecurityAlertEmailHtml(String action, String details) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Security Alert</title>
    </head>
    <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #dc2626;">Security Alert</h1>
            <p>Hi there,</p>
            <p>We detected a security event on your $_appName account:</p>
            
            <div style="background-color: #fef2f2; border: 1px solid #fecaca; padding: 15px; border-radius: 6px; margin: 20px 0;">
                <p><strong>Action:</strong> $action</p>
                <p><strong>Details:</strong> $details</p>
            </div>
            
            <p>If this was you, you can safely ignore this email. If you didn't perform this action, please contact us immediately.</p>
            
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
            <p style="color: #666; font-size: 14px;">
                Need help? Contact us at <a href="mailto:$_supportEmail">$_supportEmail</a>
            </p>
        </div>
    </body>
    </html>
    ''';
  }

  String _buildSecurityAlertEmailText(String action, String details) {
    return '''
    Security Alert
    
    Hi there,
    
    We detected a security event on your $_appName account:
    
    Action: $action
    Details: $details
    
    If this was you, you can safely ignore this email. If you didn't perform this action, please contact us immediately.
    
    Need help? Contact us at $_supportEmail
    ''';
  }
} 