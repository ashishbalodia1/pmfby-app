# Email OTP Service - Debug Logging Guide

## Overview
The Email OTP Service now has comprehensive checkpoint logging at every step. All logs are prefixed with `[EmailOTP]` for easy filtering.

---

## 📋 Complete Log Flow

### 1️⃣ **OTP Generation Flow**

#### When `sendOTP()` is called:
```
📧 [EmailOTP] Starting OTP send process for: user@email.com, purpose: register
🔍 [EmailOTP] Checking rate limit for: user@email.com
✅ [EmailOTP] Rate limit check passed
🔢 [EmailOTP] Generating new OTP...
✅ [EmailOTP] OTP generated successfully: 12****
🔐 [EmailOTP] OTP generated: 12****, length: 6
💾 [EmailOTP] Storing OTP in memory...
💾 [EmailOTP] OTP stored in memory for email: user@email.com
📊 [EmailOTP] Current OTP storage size: 1 entries
```

#### In Debug Mode (default):
```
🚧 [EmailOTP] Running in DEBUG MODE
🔐 [EmailOTP] DEBUG MODE - OTP: 123456 (Valid for 10 minutes)
✅ [EmailOTP] Returning from DEBUG MODE without sending email
```

#### In Production Mode (SMTP configured):
```
📤 [EmailOTP] Running in PRODUCTION MODE
🔧 [EmailOTP] Retrieving SMTP server configuration...
⚙️ [EmailOTP] _getSmtpServer() called
⚠️ [EmailOTP] SMTP not configured - Running in DEMO mode
💡 [EmailOTP] To send real emails, configure SMTP in _getSmtpServer() method
⚠️ [EmailOTP] SMTP not configured, using demo mode
```

#### When SMTP is properly configured:
```
📤 [EmailOTP] Using Gmail SMTP: your-email@gmail.com
📧 [EmailOTP] Getting sender email address...
📧 [EmailOTP] Sender email: your-email@gmail.com
📄 [EmailOTP] Building email template for purpose: register
📝 [EmailOTP] Building email message...
📨 [EmailOTP] Sending email to: user@email.com
✅ [EmailOTP] Email sent successfully: <send report details>
```

---

### 2️⃣ **OTP Verification Flow**

#### When `verifyOTP()` is called:
```
🔐 [EmailOTP] Starting OTP verification for: user@email.com
🔐 [EmailOTP] Provided OTP: 12****, length: 6
💾 [EmailOTP] Found stored OTP created at: 2025-12-08 10:30:45.123
⏱️ [EmailOTP] Time since OTP creation: 0 minutes, 15 seconds
✅ [EmailOTP] OTP verified successfully for: user@email.com
```

#### Common Error Cases:

**No OTP Found:**
```
🔐 [EmailOTP] Starting OTP verification for: user@email.com
❌ [EmailOTP] No OTP found in storage for: user@email.com
```

**OTP Expired:**
```
🔐 [EmailOTP] Starting OTP verification for: user@email.com
💾 [EmailOTP] Found stored OTP created at: 2025-12-08 10:20:45.123
⏱️ [EmailOTP] Time since OTP creation: 11 minutes, 30 seconds
❌ [EmailOTP] OTP expired (validity: 10 minutes)
```

**Invalid OTP:**
```
🔐 [EmailOTP] Starting OTP verification for: user@email.com
💾 [EmailOTP] Found stored OTP created at: 2025-12-08 10:30:45.123
⏱️ [EmailOTP] Time since OTP creation: 2 minutes, 5 seconds
❌ [EmailOTP] Invalid OTP - Expected: 12****, Got: 45****
```

---

### 3️⃣ **Rate Limiting Flow**

#### When rate limit is active:
```
📧 [EmailOTP] Starting OTP send process for: user@email.com, purpose: register
🔍 [EmailOTP] Checking rate limit for: user@email.com
⏰ [EmailOTP] Rate limit active: Wait 45 seconds
❌ [EmailOTP] Error sending OTP: Exception: Please wait 45 seconds before requesting another OTP
```

---

### 4️⃣ **OTP Management Flow**

#### When `clearOTP()` is called:
```
🗑️ [EmailOTP] Clearing OTP for: user@email.com
✅ [EmailOTP] OTP cleared successfully (had OTP: true)
```

#### When `getRemainingValidity()` is called:
```
⏱️ [EmailOTP] Checking remaining validity for: user@email.com
⏱️ [EmailOTP] Remaining validity: 8m 45s
```

Or if no OTP exists:
```
⏱️ [EmailOTP] Checking remaining validity for: user@email.com
❌ [EmailOTP] No OTP found for validity check
```

---

## 🎯 How to Use These Logs

### Viewing Logs in Flutter
1. **Run your app**: `flutter run`
2. **Watch console output** - all logs appear in real-time
3. **Filter by prefix**: Search for `[EmailOTP]` in your terminal

### Filtering Logs
```bash
# In your terminal while app is running, pipe output to grep:
flutter run | grep '\[EmailOTP\]'

# Or save to file for analysis:
flutter run > logs.txt 2>&1
grep '\[EmailOTP\]' logs.txt
```

### VS Code Debug Console
- Logs appear in the "Debug Console" tab
- Use the filter input to search for `[EmailOTP]`

---

## 🔍 Troubleshooting with Logs

### Problem: "OTP not received"
**Look for these logs:**
```
✅ [EmailOTP] OTP generated successfully: 12****
💾 [EmailOTP] OTP stored in memory
🚧 [EmailOTP] Running in DEBUG MODE
```
**Solution:** You're in debug mode. Check the console for the OTP number.

---

### Problem: "Invalid OTP"
**Look for this log:**
```
❌ [EmailOTP] Invalid OTP - Expected: 12****, Got: 45****
```
**Solution:** You entered the wrong OTP. Check the first 2 digits to verify.

---

### Problem: "OTP expired"
**Look for these logs:**
```
⏱️ [EmailOTP] Time since OTP creation: 11 minutes, 30 seconds
❌ [EmailOTP] OTP expired (validity: 10 minutes)
```
**Solution:** Request a new OTP.

---

### Problem: "Email not sending in production"
**Look for these logs:**
```
📤 [EmailOTP] Running in PRODUCTION MODE
⚙️ [EmailOTP] _getSmtpServer() called
⚠️ [EmailOTP] SMTP not configured - Running in DEMO mode
```
**Solution:** SMTP is not configured. Follow `EMAIL_SMTP_SETUP.md` guide.

---

### Problem: "Rate limited"
**Look for this log:**
```
⏰ [EmailOTP] Rate limit active: Wait 45 seconds
```
**Solution:** Wait the specified time or call `clearOTP(email)` to reset.

---

## 📊 Log Emojis Reference

| Emoji | Meaning |
|-------|---------|
| 📧 | Email/OTP operation start |
| 🔍 | Checking/Validating |
| ✅ | Success |
| ❌ | Error/Failure |
| 🔐 | Security/OTP related |
| 💾 | Storage operation |
| 📊 | Statistics/Info |
| ⏰ | Timing/Rate limit |
| ⏱️ | Duration/Validity |
| 🚧 | Debug mode |
| 📤 | Production/Sending |
| 🔧 | Configuration |
| ⚙️ | Internal method call |
| 📧 | Sender info |
| 📄 | Template building |
| 📝 | Message building |
| 📨 | Actual sending |
| 🗑️ | Cleanup |
| 🔢 | Generation |

---

## 💡 Pro Tips

### Enable verbose logging
All logs are already at the right verbosity level. You'll see:
- ✅ Success operations
- ❌ Errors with details
- 💾 State changes
- ⏱️ Timing information

### Debug a specific user
Filter logs by email:
```bash
flutter run | grep 'user@example.com'
```

### Track OTP lifecycle
1. Search for "Starting OTP send process"
2. Follow the flow until "OTP verified successfully"
3. Check timing at each step

### Monitor storage size
Look for:
```
📊 [EmailOTP] Current OTP storage size: X entries
```
This helps detect memory leaks if the number keeps growing.

---

## 🎬 Example Complete Flow

Here's what you'll see for a successful registration:

```
📧 [EmailOTP] Starting OTP send process for: farmer@gmail.com, purpose: register
🔍 [EmailOTP] Checking rate limit for: farmer@gmail.com
✅ [EmailOTP] Rate limit check passed
🔢 [EmailOTP] Generating new OTP...
✅ [EmailOTP] OTP generated successfully: 57****
🔐 [EmailOTP] OTP generated: 57****, length: 6
💾 [EmailOTP] Storing OTP in memory...
💾 [EmailOTP] OTP stored in memory for email: farmer@gmail.com
📊 [EmailOTP] Current OTP storage size: 1 entries
🚧 [EmailOTP] Running in DEBUG MODE
🔐 [EmailOTP] DEBUG MODE - OTP: 578923 (Valid for 10 minutes)
✅ [EmailOTP] Returning from DEBUG MODE without sending email

[User enters OTP in app]

🔐 [EmailOTP] Starting OTP verification for: farmer@gmail.com
🔐 [EmailOTP] Provided OTP: 57****, length: 6
💾 [EmailOTP] Found stored OTP created at: 2025-12-08 10:30:45.123
⏱️ [EmailOTP] Time since OTP creation: 0 minutes, 15 seconds
✅ [EmailOTP] OTP verified successfully for: farmer@gmail.com
```

**Total time:** ~15 seconds from request to verification ✅

---

## 🔧 Advanced: Custom Logging

If you need even more detailed logs, you can modify the service to add:
- Request IDs for tracking
- Performance metrics
- Network latency
- Detailed error stack traces

All logs use `dart:developer` which supports:
- Log levels
- Zones
- Stack traces
- Custom metadata

---

**Happy Debugging! 🐛🔍**
