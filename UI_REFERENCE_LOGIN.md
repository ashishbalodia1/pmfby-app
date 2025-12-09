# New Login Screen - UI Reference

## 🎨 Visual Structure

```
┌─────────────────────────────────────────┐
│  🌾 Bandhu                              │
│  किसान लॉगिन | Farmer Login            │
├─────────────────────────────────────────┤
│  ┌─────────────┬─────────────┐          │
│  │ 👨‍🌾 Farmer  │ 👨‍💼 Admin  │  ← TABS  │
│  └─────────────┴─────────────┘          │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  Login करें                        │ │
│  │  मोबाइल नंबर से लॉगिन करें       │ │
│  │                                    │ │
│  │  मोबाइल नंबर | Mobile Number      │ │
│  │  ┌──────────────────────────────┐ │ │
│  │  │ 📱 [9589191560____________] │ │ │
│  │  └──────────────────────────────┘ │ │
│  │                                    │ │
│  │  ➕ अधिक जानकारी | Add Details   │ │
│  │     (Optional - Expandable)        │ │
│  │                                    │ │
│  │  [After OTP Sent:]                 │ │
│  │  OTP                               │ │
│  │  ┌──────────────────────────────┐ │ │
│  │  │ 🔒 [______]                  │ │ │
│  │  └──────────────────────────────┘ │ │
│  │  OTP received?     [Resend OTP]   │ │
│  │                                    │ │
│  │  ┌──────────────────────────────┐ │ │
│  │  │  OTP भेजें | Send OTP       │ │ │
│  │  └──────────────────────────────┘ │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 👨‍🌾 Farmer Tab - Detailed Flow

### State 1: Initial
```
┌────────────────────────────────────┐
│  Login करें                        │
│  मोबाइल नंबर से लॉगिन करें       │
│                                    │
│  मोबाइल नंबर | Mobile Number      │
│  ┌──────────────────────────────┐ │
│  │ 📱 [          ]              │ │  ← Type 10 digits
│  └──────────────────────────────┘ │
│                                    │
│  ➕ अधिक जानकारी | Add Details   │  ← Optional name
│                                    │
│  ┌──────────────────────────────┐ │
│  │  OTP भेजें | Send OTP       │ │  ← Primary action
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

### State 2: Optional Details Expanded
```
┌────────────────────────────────────┐
│  मोबाइल नंबर | Mobile Number      │
│  ┌──────────────────────────────┐ │
│  │ 📱 [9876543210]              │ │
│  └──────────────────────────────┘ │
│                                    │
│  नाम (वैकल्पिक)                   │
│  ┌──────────────────────────────┐ │
│  │ 👤 [अपना नाम दर्ज करें_____] │ │  ← Optional name input
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  OTP भेजें | Send OTP       │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

### State 3: OTP Sent
```
┌────────────────────────────────────┐
│  मोबाइल नंबर | Mobile Number      │
│  ┌──────────────────────────────┐ │
│  │ 📱 [9876543210]              │ │  ← Disabled (grayed out)
│  └──────────────────────────────┘ │
│                                    │
│  OTP                               │
│  ┌──────────────────────────────┐ │
│  │ 🔒 [      ]                  │ │  ← Enter 6-digit OTP
│  └──────────────────────────────┘ │
│  OTP received?     [Resend OTP]   │  ← Resend link
│                                    │
│  ┌──────────────────────────────┐ │
│  │      Verify OTP              │ │  ← Changed button text
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

### State 4: Loading
```
┌────────────────────────────────────┐
│  ┌──────────────────────────────┐ │
│  │         ⌛ Loading...        │ │  ← Spinner shown
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

## 👨‍💼 Admin Tab - Login Mode

```
┌────────────────────────────────────┐
│  Admin Login                       │
│  Email & Password                  │
│                                    │
│  Email                             │
│  ┌──────────────────────────────┐ │
│  │ 📧 [admin@pmfby.gov.in_____] │ │
│  └──────────────────────────────┘ │
│                                    │
│  Password                          │
│  ┌──────────────────────────────┐ │
│  │ 🔒 [••••••••]           👁   │ │  ← Visibility toggle
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │         Login                │ │
│  └──────────────────────────────┘ │
│                                    │
│      [New admin? Create account]  │  ← Link to signup
│                                    │
│  ╔══════════════════════════════╗ │
│  ║ ℹ️  Default Admin Credentials ║ │
│  ║ Email: admin@pmfby.gov.in   ║ │
│  ║ Password: admin123          ║ │
│  ╚══════════════════════════════╝ │
└────────────────────────────────────┘
```

## 👨‍💼 Admin Tab - Signup Mode

```
┌────────────────────────────────────┐
│  Admin Signup                      │
│  Create admin account              │
│                                    │
│  Email                             │
│  ┌──────────────────────────────┐ │
│  │ 📧 [              ]          │ │
│  └──────────────────────────────┘ │
│                                    │
│  Password                          │
│  ┌──────────────────────────────┐ │
│  │ 🔒 [              ]      👁  │ │
│  └──────────────────────────────┘ │
│                                    │
│  Full Name *                       │
│  ┌──────────────────────────────┐ │
│  │ 👤 [              ]          │ │
│  └──────────────────────────────┘ │
│                                    │
│  Phone Number *                    │
│  ┌──────────────────────────────┐ │
│  │ 📱 [              ]          │ │
│  └──────────────────────────────┘ │
│                                    │
│  Designation (Optional)            │
│  ┌──────────────────────────────┐ │
│  │ 💼 [e.g., District Officer_] │ │
│  └──────────────────────────────┘ │
│                                    │
│  Department (Optional)             │
│  ┌──────────────────────────────┐ │
│  │ 🏢 [e.g., Agriculture______] │ │
│  └──────────────────────────────┘ │
│                                    │
│  ┌──────────────────────────────┐ │
│  │      Create Account          │ │
│  └──────────────────────────────┘ │
│                                    │
│  [Already have an account? Login] │
└────────────────────────────────────┘
```

## 🎨 Color Scheme

### Primary Colors
- **Background Gradient**: 
  - Green.shade700 (top)
  - Green.shade500 (middle)
  - LightGreen.shade300 (bottom)

- **Cards**: White with shadow
- **Primary Button**: Green.shade700
- **Text**: Grey.shade700 (labels), Grey.shade600 (hints)
- **Icons**: Green.shade700

### States
- **Enabled Input**: White background, grey border
- **Disabled Input**: Grey.shade100 background
- **Focused Input**: Green.shade700 border (2px)
- **Error**: Red background for snackbar
- **Success**: Green background for snackbar

## 📱 Responsive Behavior

### Phone Layout (Default)
- Full screen card
- 16px padding
- Scrollable content

### Tablet Layout (Future)
- Centered card (max 500px width)
- Larger padding (24px)
- Same scrollable behavior

## 🔔 Notifications (SnackBars)

### Success Messages (Green)
```
✅ OTP भेजा गया है। कृपया अपना मोबाइल चेक करें।
✅ OTP दोबारा भेजा गया है।
✅ लॉगिन सफल!
✅ Admin login successful!
✅ Admin registered successfully! Please login.
```

### Error Messages (Red)
```
❌ कृपया 10 अंकों का मोबाइल नंबर दर्ज करें
❌ OTP भेजने में विफल। कृपया पुनः प्रयास करें।
❌ कृपया 6 अंकों का OTP दर्ज करें
❌ गलत OTP। कृपया पुनः प्रयास करें।
❌ कृपया ईमेल और पासवर्ड दर्ज करें
❌ Invalid email or password
❌ कृपया सभी आवश्यक फील्ड भरें
❌ Registration failed. Email may already exist.
❌ त्रुटि: [error details]
```

## 🎯 Interactive Elements

### Tab Bar
- **Inactive**: White text on transparent background
- **Active**: Green.shade700 text on white background
- **Animation**: Smooth slide transition
- **Icons**: 👨‍🌾 (Farmer), 👨‍💼 (Admin)

### Input Fields
- **Prefix Icons**: 
  - 📱 Phone
  - 🔒 Lock (OTP/Password)
  - 📧 Email
  - 👤 Person
  - 💼 Work
  - 🏢 Business

- **Suffix Icons**:
  - 👁 / 👁‍🗨 Password visibility toggle

### Buttons
- **Primary Action**: Full width, 50px height, rounded (12px)
- **Text Button**: Transparent, green text, bold
- **Resend OTP**: Small text button, right-aligned

### Links
- **Signup/Login Toggle**: Centered, green text, bold
- **Resend OTP**: Right-aligned, small font
- **Add Details**: Left-aligned with + icon

## 📐 Spacing & Sizing

### Card Container
- Padding: 24px all sides
- Border Radius: 20px
- Shadow: 0px 5px 20px rgba(0,0,0,0.1)

### Vertical Spacing
- Between sections: 24px
- Between label and input: 8px
- Between input fields: 16px
- Between button and link: 16px

### Input Fields
- Height: Auto (based on content)
- Border Radius: 12px
- Border Width: 1px (default), 2px (focused)

### Buttons
- Height: 50px
- Border Radius: 12px
- Font Size: 16px
- Font Weight: Bold

### Typography
- **Title**: 24px, bold, Poppins
- **Subtitle**: 14px, regular, Noto Sans Devanagari
- **Labels**: 14px, medium weight
- **Hints**: 14px, grey
- **Buttons**: 16px, bold

## 🔄 Transitions & Animations

### Tab Switch
- Duration: 300ms
- Curve: Ease-in-out
- Effect: Fade + Slide

### Button Loading
- Spinner: White color
- Size: 24px diameter
- Animation: Continuous rotation

### SnackBar
- Slide up from bottom
- Duration: 2-3 seconds
- Dismissible: Swipe down

### OTP Field Appearance
- Fade in when OTP sent
- Phone field fade to grey
- Duration: 200ms

## 📱 Keyboard Behavior

### Phone Input
- Type: Number pad
- Max Length: 10 digits
- Auto-dismiss: On "Send OTP"

### OTP Input
- Type: Number pad
- Max Length: 6 digits
- Auto-dismiss: On "Verify"

### Email Input
- Type: Email keyboard
- Auto-lowercase: Yes
- Auto-correct: No

### Password Input
- Type: Secure text
- Auto-correct: No
- Visibility toggle: Available

### Name/Text Input
- Type: Text keyboard
- Auto-capitalize: Words
- Auto-correct: Yes

## ✅ Validation States

### Phone Number
- ✅ Valid: 10 digits
- ❌ Invalid: Less than 10 digits
- Show error: On submit

### OTP
- ✅ Valid: 6 digits
- ❌ Invalid: Less than 6 digits
- Show error: On verify

### Email
- ✅ Valid: Contains @ and .
- ❌ Invalid: Missing @ or .
- Show error: On submit

### Password
- ✅ Valid: Any length (min 1 char)
- ❌ Invalid: Empty
- Show error: On submit

### Required Fields (Signup)
- Email, Password, Name, Phone: Must be filled
- Designation, Department: Optional

## 🎭 Edge Cases Handled

1. **OTP expires**: Show "Resend OTP" option
2. **3 failed attempts**: Must request new OTP
3. **Network failure**: Falls back to debug mode
4. **API rate limit**: Shows user-friendly error
5. **Keyboard overlap**: Content scrolls automatically
6. **Tab switching**: Form resets, clears inputs
7. **Back button**: Returns to previous screen
8. **Session management**: Preserves login state

## 🔧 Developer Notes

### Debug Mode Features
- Auto-logs OTP to console
- Any 6 digits work for verification
- Warning message shown in UI
- No actual SMS sent

### Hot Reload Support
- All state preserved
- Controllers disposed properly
- No memory leaks

### Accessibility
- Semantic labels on all inputs
- Focus order: Top to bottom
- Error messages read by screen readers
- High contrast colors

---

**File Location:** `lib/src/features/auth/presentation/new_login_screen.dart`

**Route:** `/login` (default), `/login-old` (fallback)

**Entry Point:** `main.dart` → `GoRouter` → `/login`
