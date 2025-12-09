import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:http/http.dart' as http;

/// Professional SMS OTP Service using Twilio
/// Twilio is the most reliable SMS provider for hackathons and production
class TwilioSmsService {
  static final TwilioSmsService instance = TwilioSmsService._internal();
  factory TwilioSmsService() => instance;
  TwilioSmsService._internal();

  // Twilio Configuration - CONSOLE MODE (for development/demo)
  // Set to real credentials for production SMS
  static const String _accountSid = 'CONSOLE_MODE';
  static const String _authToken = 'CONSOLE_MODE';
  static const String _fromNumber = '+911234567890'; // Demo mode
  
  // Demo mode settings
  static const bool _useDemoMode = true; // Set to false for real OTP
  static const String _demoOTP = '111111'; // Fixed OTP for easy testing
  
  // OTP storage for verification
  final Map<String, _OTPData> _otpStorage = {};
  static const Duration otpValidity = Duration(minutes: 5);
  static const int maxAttempts = 3;
  
  final Random _random = Random.secure();

  /// Generate a 6-digit OTP
  String _generateOTP() {
    return (100000 + _random.nextInt(900000)).toString();
  }

  /// Send OTP via Twilio SMS
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // Clean phone number
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // Validate
      if (cleanPhone.length != 10) {
        developer.log('❌ Invalid phone number: $cleanPhone', name: 'TwilioSMS');
        return false;
      }

      // Add country code for India
      final fullPhone = '+91$cleanPhone';

      // Generate OTP (use demo OTP if enabled)
      final otp = _useDemoMode ? _demoOTP : _generateOTP();
      
      // Store OTP
      _otpStorage[cleanPhone] = _OTPData(
        otp: otp,
        createdAt: DateTime.now(),
        attempts: 0,
      );

      developer.log(
        '\n\n🚀 ═══════════════════════════════════════',
        name: 'OTP_SERVICE',
      );
      developer.log(
        '📱 SENDING OTP TO: $fullPhone',
        name: 'OTP_SERVICE',
      );

      // Send via Twilio
      final success = await _sendViaTwilio(fullPhone, otp);

      if (success) {
        print('\n\n');
        print('╔═══════════════════════════════════════╗');
        print('║         🔐 YOUR OTP CODE 🔐          ║');
        print('╠═══════════════════════════════════════╣');
        print('║                                       ║');
        print('║         📱 Phone: $cleanPhone        ║');
        print('║         🔢 OTP: $otp              ║');
        print('║         ⏰ Valid: 5 minutes           ║');
        print('║                                       ║');
        print('╚═══════════════════════════════════════╝');
        print('\n\n');
        
        developer.log('✅ OTP GENERATED SUCCESSFULLY!', name: 'OTP_SERVICE');
        developer.log('═══════════════════════════════════════\n\n', name: 'OTP_SERVICE');
      }

      return success;
    } catch (e) {
      developer.log('❌ Error sending OTP: $e', name: 'TwilioSMS');
      return false;
    }
  }

  /// Send SMS via Twilio API
  Future<bool> _sendViaTwilio(String phoneNumber, String otp) async {
    try {
      // Check if Twilio is configured for real SMS
      if (_accountSid == 'CONSOLE_MODE' || _accountSid == 'YOUR_TWILIO_ACCOUNT_SID') {
        developer.log('📱 CONSOLE MODE: Simulating SMS delivery...', name: 'TwilioSMS');
        // Simulate network delay for realistic experience
        await Future.delayed(const Duration(milliseconds: 800));
        developer.log('✅ SMS "sent successfully" (console mode)', name: 'TwilioSMS');
        return true; // Return success for console mode
      }

      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json'
      );

      // Create message
      final message = 'Your Krishi Bandhu OTP is: $otp. Valid for 5 minutes. Do not share with anyone.';

      // Prepare auth header (Basic Auth)
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _fromNumber,
          'To': phoneNumber,
          'Body': message,
        },
      );

      developer.log('Twilio Response: ${response.statusCode}', name: 'TwilioSMS');
      developer.log('Response Body: ${response.body}', name: 'TwilioSMS');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        developer.log('✅ Message SID: ${data['sid']}', name: 'TwilioSMS');
        return true;
      } else {
        final error = jsonDecode(response.body);
        developer.log('❌ Twilio error: ${error['message']}', name: 'TwilioSMS');
        return false;
      }
    } catch (e) {
      developer.log('❌ Twilio API error: $e', name: 'TwilioSMS');
      return false;
    }
  }

  /// Verify OTP
  bool verifyOTP(String phoneNumber, String enteredOTP) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    final data = _otpStorage[cleanPhone];
    if (data == null) {
      developer.log('❌ No OTP found for $cleanPhone', name: 'TwilioSMS');
      return false;
    }

    // Check expiry
    if (DateTime.now().difference(data.createdAt) > otpValidity) {
      _otpStorage.remove(cleanPhone);
      developer.log('❌ OTP expired for $cleanPhone', name: 'TwilioSMS');
      return false;
    }

    // Check attempts
    if (data.attempts >= maxAttempts) {
      _otpStorage.remove(cleanPhone);
      developer.log('❌ Max attempts exceeded for $cleanPhone', name: 'TwilioSMS');
      return false;
    }

    // Increment attempts
    data.attempts++;

    // Verify OTP
    if (data.otp == enteredOTP) {
      _otpStorage.remove(cleanPhone);
      developer.log('✅ OTP verified successfully for $cleanPhone', name: 'TwilioSMS');
      return true;
    }

    developer.log('❌ Invalid OTP. Attempts: ${data.attempts}/$maxAttempts', name: 'TwilioSMS');
    return false;
  }

  /// Clear expired OTPs (cleanup)
  void clearExpiredOTPs() {
    final now = DateTime.now();
    _otpStorage.removeWhere((phone, data) {
      return now.difference(data.createdAt) > otpValidity;
    });
  }

  /// Get OTP for testing (DEBUG ONLY - remove in production)
  String? getOTPForTesting(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return _otpStorage[cleanPhone]?.otp;
  }
}

/// Internal class to store OTP data
class _OTPData {
  final String otp;
  final DateTime createdAt;
  int attempts;

  _OTPData({
    required this.otp,
    required this.createdAt,
    required this.attempts,
  });
}
