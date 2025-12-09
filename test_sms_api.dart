import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Fast2SMS API...\n');
  
  const apiKey = 'CQLzbGWl7HZwv1uiYSKVykdJPcrt2EeoFTXB6DIxnhjA9g5q3UTxbH4kMI1mG2pB6liUSOY9VZDzh7NJ';
  const phone = '9876543210'; // Test number
  const otp = '123456';
  
  print('API Key: ${apiKey.substring(0, 20)}...');
  print('Phone: $phone');
  print('OTP: $otp\n');
  
  // Test 1: OTP route with form data
  print('📤 Test 1: OTP route with form data');
  try {
    final response1 = await http.post(
      Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
      headers: {
        'authorization': apiKey,
      },
      body: {
        'route': 'otp',
        'variables_values': otp,
        'flash': '0',
        'numbers': phone,
      },
    ).timeout(const Duration(seconds: 15));
    
    print('Status: ${response1.statusCode}');
    print('Response: ${response1.body}\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }
  
  // Test 2: Quick route with message
  print('📤 Test 2: Quick route with direct message');
  try {
    final message = 'Your PMFBY OTP is $otp. Valid for 5 minutes.';
    final response2 = await http.post(
      Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
      headers: {
        'authorization': apiKey,
      },
      body: {
        'route': 'q',
        'message': message,
        'flash': '0',
        'numbers': phone,
      },
    ).timeout(const Duration(seconds: 15));
    
    print('Status: ${response2.statusCode}');
    print('Response: ${response2.body}\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }
  
  // Test 3: DLT route
  print('📤 Test 3: DLT route');
  try {
    final response3 = await http.post(
      Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
      headers: {
        'authorization': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'route': 'dlt',
        'sender_id': 'TXTIND',
        'message': '137668',
        'variables_values': otp,
        'flash': 0,
        'numbers': phone,
      }),
    ).timeout(const Duration(seconds: 15));
    
    print('Status: ${response3.statusCode}');
    print('Response: ${response3.body}\n');
  } catch (e) {
    print('❌ Error: $e\n');
  }
  
  print('✅ Test complete!');
}
