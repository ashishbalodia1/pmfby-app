# Email SMTP Setup Guide

## Current Status
🔐 **OTP Service is Working!** The OTP is being generated and shown in your terminal console.

❌ **Emails are NOT being sent** because SMTP is not configured (running in DEMO mode).

## Quick Solution: Use Console OTP

For testing, **use the OTP displayed in your terminal**. Look for this line:
```
🔐 OTP for your-email@example.com: 123456 (Valid for 10 minutes)
```

Just copy the 6-digit code and paste it in the app!

---

## Production Solution: Configure Gmail SMTP (Free & Easy)

### Step 1: Prepare Your Gmail Account

1. Go to **Google Account Settings**: https://myaccount.google.com/security
2. **Enable 2-Factor Authentication** (if not already enabled)
   - Click "2-Step Verification"
   - Follow the setup wizard

### Step 2: Generate App Password

1. Visit: https://myaccount.google.com/apppasswords
2. If you don't see "App passwords", make sure 2FA is enabled first
3. Select app: **Mail**
4. Select device: **Other (Custom name)**
5. Enter name: `Krishi Bandhu App`
6. Click **Generate**
7. **Copy the 16-character password** (format: xxxx xxxx xxxx xxxx)

### Step 3: Configure the Code

Open `lib/src/services/email_otp_service.dart` and find the `_getSmtpServer()` method (around line 175).

**Uncomment and update this section:**

```dart
static Future<SmtpServer?> _getSmtpServer() async {
  // UNCOMMENT THESE LINES:
  const gmailEmail = 'your-email@gmail.com';  // ← Replace with your Gmail
  const gmailAppPassword = 'xxxx xxxx xxxx xxxx';  // ← Paste the 16-char password
  developer.log('📤 [EmailOTP] Using Gmail SMTP: $gmailEmail');
  return gmail(gmailEmail, gmailAppPassword);
  
  // COMMENT OUT OR DELETE THIS:
  // return null;
}
```

### Step 4: Update Sender Information

In the same file, update the `_getSenderEmail()` method (around line 215):

```dart
static String _getSenderEmail() {
  return 'your-email@gmail.com';  // ← Use the same Gmail
}
```

### Step 5: Test

1. **Hot reload** the app: Press `r` in the terminal
2. Try registering with a real email address
3. Check your inbox (and spam folder!)
4. You should receive a professional-looking email with your OTP

---

## Alternative: Other Email Providers

### Outlook/Hotmail (Free)
```dart
const email = 'your-email@outlook.com';
const password = 'your-password';
return hotmail(email, password);
```

### Custom SMTP Server
```dart
return SmtpServer(
  'smtp.your-provider.com',
  port: 587,
  username: 'your-email@example.com',
  password: 'your-password',
  ssl: false,
  allowInsecure: false,
);
```

---

## Troubleshooting

### "Email send failed" Error
- ✅ Verify 2FA is enabled
- ✅ Use App Password, NOT your regular Gmail password
- ✅ Check if "Less secure app access" is turned off (you don't need it with App Password)
- ✅ Make sure there are no spaces in the app password (it should be 16 characters)

### Emails Going to Spam
- Add a custom sender name: `..from = Address('your-email@gmail.com', 'Krishi Bandhu')`
- Ask users to mark your email as "Not Spam"
- In production, use a custom domain with proper SPF/DKIM records

### Rate Limiting
- Gmail free tier: **500 emails per day**
- If you need more, consider:
  - SendGrid (100 emails/day free)
  - Mailgun (5,000 emails/month free)
  - Amazon SES (62,000 emails/month free for first year)

---

## Security Best Practices

### ⚠️ Do NOT commit credentials to Git!

**Option 1: Use Environment Variables**
```dart
// Add to pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0

// Create .env file (add to .gitignore!)
GMAIL_EMAIL=your-email@gmail.com
GMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx

// Load in code
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
const gmailEmail = dotenv.env['GMAIL_EMAIL']!;
const gmailAppPassword = dotenv.env['GMAIL_APP_PASSWORD']!;
```

**Option 2: Use Secure Storage**
```dart
// Add to pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0

// Store credentials securely
final storage = FlutterSecureStorage();
await storage.write(key: 'gmail_email', value: 'your-email@gmail.com');
await storage.write(key: 'gmail_app_password', value: 'xxxx xxxx xxxx xxxx');

// Retrieve in code
final email = await storage.read(key: 'gmail_email');
final password = await storage.read(key: 'gmail_app_password');
```

---

## Quick Test Checklist

- [ ] 2FA enabled on Gmail
- [ ] App Password generated
- [ ] Code uncommented and credentials added
- [ ] Sender email updated
- [ ] App hot reloaded (press `r`)
- [ ] Test registration with real email
- [ ] Check inbox (and spam!)
- [ ] OTP received within 1-2 minutes

---

## Current Behavior

**Debug Mode (Default):**
- ✅ OTP generated
- ✅ OTP stored in memory
- ✅ OTP shown in console: `🔐 OTP for email: 123456`
- ❌ Email NOT sent
- ✅ App accepts console OTP

**Production Mode (After SMTP Setup):**
- ✅ OTP generated
- ✅ OTP stored in memory
- ✅ Email sent to user's inbox
- ❌ OTP NOT shown in console (for security)
- ✅ App accepts emailed OTP

---

## Need Help?

If you encounter issues:
1. Check the console logs for detailed error messages
2. Look for lines starting with `[EmailOTP]`
3. Common errors:
   - "Invalid credentials" → Wrong email or app password
   - "Authentication failed" → Use App Password, not regular password
   - "Connection timeout" → Check internet connection

---

**Remember:** For now, you can continue testing using the console OTP! No configuration needed for development. 🚀
