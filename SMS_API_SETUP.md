# SMS API Setup Guide

This guide will help you set up SMS OTP authentication for farmer login using free SMS APIs.

## Overview

The app supports **two SMS providers** with automatic fallback:
1. **Fast2SMS** (Primary)
2. **2Factor** (Backup)

## 🚀 Quick Start

### Option 1: Fast2SMS (Recommended)

Fast2SMS is a popular Indian SMS gateway with a free tier.

#### Step 1: Sign Up
1. Go to https://www.fast2sms.com/
2. Click "Sign Up" and register with your mobile number
3. Verify your mobile number via OTP
4. Complete your profile

#### Step 2: Get API Key
1. Log in to your Fast2SMS dashboard
2. Navigate to **Dev API** section: https://www.fast2sms.com/dashboard/dev-api
3. Look for "Authorization" section
4. Copy your **API Key** (starts with your registered number)

#### Step 3: Configure in App
1. Open `.env` file in project root
2. Find the line: `FAST2SMS_API_KEY=your_fast2sms_api_key_here`
3. Replace with your actual API key:
   ```
   FAST2SMS_API_KEY=ABC1234567890XYZ
   ```

#### Step 4: Test
- Fast2SMS provides **50 free SMS per day** on their free tier
- Use test mode for development (debug mode automatically enabled)

---

### Option 2: 2Factor (Backup)

2Factor provides SMS OTP services with a generous free tier.

#### Step 1: Sign Up
1. Go to https://2factor.in/
2. Click "Sign Up" and create account
3. Verify your email

#### Step 2: Get API Key
1. Log in to dashboard: https://2factor.in/dashboard
2. Go to **API Settings** or **Developer** section
3. Copy your **API Key**

#### Step 3: Configure in App
1. Open `.env` file in project root
2. Find the line: `TWOFACTOR_API_KEY=your_2factor_api_key_here`
3. Replace with your actual API key:
   ```
   TWOFACTOR_API_KEY=def4567890123456
   ```

#### Step 4: Test
- 2Factor provides **10 free SMS per day** on their trial account
- OTP validity: 5 minutes (configurable)

---

## 📱 How It Works

### Farmer Login Flow

1. **Farmer enters phone number** → Clicks "Send OTP"
2. **App tries Fast2SMS first** → Sends 6-digit OTP via SMS
3. **If Fast2SMS fails** → Automatically tries 2Factor
4. **Farmer receives OTP** → Enters it in the app
5. **OTP verified** → Farmer logged in

### Admin Login Flow

1. **Admin clicks "Admin" tab** → Switches to admin login
2. **Admin enters email & password** → Clicks "Login"
3. **Credentials verified** → Admin logged in
4. **Or clicks "Create account"** → Fills registration form → Creates admin account

### Default Admin Account

For testing, a default admin account is automatically created:

```
Email: admin@pmfby.gov.in
Password: admin123
```

**⚠️ Important:** Change this password after first login!

---

## 🔧 Configuration

### .env File Structure

Your `.env` file should have these SMS-related variables:

```bash
# SMS API Keys
FAST2SMS_API_KEY=your_fast2sms_api_key_here
TWOFACTOR_API_KEY=your_2factor_api_key_here
```

### Debug Mode

When API keys are not configured or API calls fail, the app automatically enables **debug mode**:

- ✅ OTP verification always succeeds
- 📝 OTP is logged in console for testing
- ⚠️ Shows warning: "Debug mode enabled"

This allows development and testing without actual SMS APIs.

---

## 🎯 Features

### SMS Service Features

- ✅ **Dual API Support** - Fast2SMS + 2Factor with automatic fallback
- ✅ **6-digit OTP** - Randomly generated secure OTP
- ✅ **5-minute expiry** - OTP expires after 5 minutes
- ✅ **3 attempts limit** - Maximum 3 verification attempts
- ✅ **Resend OTP** - User can request new OTP
- ✅ **Debug mode** - Works without API keys for testing
- ✅ **Indian numbers** - Automatically adds +91 prefix

### Admin Auth Features

- ✅ **Email/Password login** - Secure admin authentication
- ✅ **SHA-256 password hashing** - Passwords never stored in plain text
- ✅ **Full profile** - Name, phone, email, designation, department
- ✅ **Admin management** - Activate/deactivate admin accounts
- ✅ **Password change** - Secure password update functionality
- ✅ **Local storage** - Uses SharedPreferences for persistence
- ✅ **Default admin** - Pre-created admin account for testing

---

## 📊 API Comparison

| Feature | Fast2SMS | 2Factor |
|---------|----------|---------|
| Free SMS/day | 50 | 10 |
| Registration | Mobile required | Email required |
| Setup difficulty | Easy | Easy |
| Delivery speed | Fast (1-3 sec) | Fast (1-3 sec) |
| API format | REST POST | REST GET |
| India support | ✅ Excellent | ✅ Excellent |

---

## 🐛 Troubleshooting

### "Failed to send OTP"

**Possible causes:**
1. API key not configured in `.env` file
2. Invalid API key
3. Daily SMS limit exhausted
4. Network connectivity issue
5. Invalid phone number format

**Solutions:**
1. Verify API key in `.env` file
2. Check Fast2SMS/2Factor dashboard for key validity
3. Wait for daily limit reset (12:00 AM IST)
4. Check internet connection
5. Ensure phone number is 10 digits without +91

### "Invalid OTP"

**Possible causes:**
1. OTP expired (5 minutes)
2. Wrong OTP entered
3. Maximum 3 attempts exceeded

**Solutions:**
1. Click "Resend OTP" to get new code
2. Carefully enter the 6-digit OTP from SMS
3. Request new OTP after 3 failed attempts

### Debug Mode Not Working

**Symptoms:**
- App still tries to send SMS even without API keys

**Solution:**
- Debug mode automatically activates when API calls fail
- Check console logs for OTP code
- Ensure you're entering any 6-digit number (in debug mode)

---

## 🔐 Security Best Practices

### Production Deployment

1. **Never commit API keys** - Always use `.env` file (already in `.gitignore`)
2. **Rotate API keys** - Change keys periodically
3. **Monitor usage** - Check SMS dashboard for unusual activity
4. **Rate limiting** - Implement app-level rate limiting for OTP requests
5. **IP whitelisting** - Configure IP restrictions in SMS provider dashboard
6. **HTTPS only** - Ensure all API calls use HTTPS
7. **Change default admin** - Update admin password immediately

### Admin Passwords

1. Use strong passwords (min 8 characters, mix of letters, numbers, symbols)
2. Change default admin password immediately
3. Implement password reset functionality (future enhancement)
4. Enable two-factor authentication (future enhancement)

---

## 📝 Testing Checklist

### Farmer Login Testing

- [ ] Enter 10-digit phone number
- [ ] Receive OTP SMS within 5 seconds
- [ ] Enter correct OTP → Success
- [ ] Enter wrong OTP → Error message
- [ ] Wait 5 minutes → OTP expires
- [ ] Click "Resend OTP" → Receive new OTP
- [ ] Try 3 wrong OTPs → Locked out
- [ ] Add optional name → Name appears in dashboard

### Admin Login Testing

- [ ] Login with default admin (admin@pmfby.gov.in / admin123)
- [ ] Create new admin account
- [ ] Login with new admin credentials
- [ ] Test password visibility toggle
- [ ] Verify admin dashboard access
- [ ] Test logout and re-login

### Debug Mode Testing

- [ ] Run app without API keys configured
- [ ] Check console for OTP code
- [ ] Enter any 6-digit number → Success
- [ ] Verify warning message displayed

---

## 💡 Tips

### For Development

1. **Use debug mode** - Save SMS credits by not configuring API keys during development
2. **Console logs** - Check console for OTP codes in debug mode
3. **Test numbers** - Use your own number for testing to receive actual SMS
4. **Mock data** - Optional name field helps test different user scenarios

### For Production

1. **Configure both APIs** - Redundancy ensures high delivery rate
2. **Monitor limits** - Track daily SMS usage to avoid service interruption
3. **Upgrade plans** - Consider paid plans for unlimited SMS in production
4. **Analytics** - Track OTP success/failure rates
5. **User feedback** - Provide clear messages for all scenarios

---

## 🚀 Next Steps

1. **Get API keys** from Fast2SMS and/or 2Factor
2. **Update .env file** with your API keys
3. **Test farmer login** with your phone number
4. **Test admin login** with default credentials
5. **Create admin accounts** for your team
6. **Deploy to production** with proper security measures

---

## 📞 Support

### Fast2SMS Support
- Website: https://www.fast2sms.com/
- Support: https://www.fast2sms.com/support
- Documentation: https://docs.fast2sms.com/

### 2Factor Support
- Website: https://2factor.in/
- Support: support@2factor.in
- Documentation: https://docs.2factor.in/

### App Issues
- Check existing documentation in project
- Review console logs for detailed error messages
- Ensure all dependencies are installed: `flutter pub get`

---

## 📄 Related Documentation

- [AUTHENTICATION_SUMMARY.md](./AUTHENTICATION_SUMMARY.md) - Firebase auth setup
- [EMAIL_OTP_DEBUG_GUIDE.md](./EMAIL_OTP_DEBUG_GUIDE.md) - Email OTP testing
- [TESTING_GUIDE.md](./TESTING_GUIDE.md) - General testing guide
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) - Complete project setup

---

## ✅ Verification

After setup, verify everything works:

```bash
# Run the app
flutter run

# Check for initialization logs
# Should see:
# ✅ SMS Service initialized
# ✅ Admin Auth Service initialized

# Test farmer login:
# 1. Switch to "Farmer" tab
# 2. Enter phone number
# 3. Click "Send OTP"
# 4. Check console for OTP (if debug mode)
# 5. Or check your phone for SMS
# 6. Enter OTP and verify login

# Test admin login:
# 1. Switch to "Admin" tab
# 2. Use: admin@pmfby.gov.in / admin123
# 3. Click "Login"
# 4. Verify officer dashboard loads
```

---

**Status:** ✅ Setup complete! Your SMS authentication is ready to use.
