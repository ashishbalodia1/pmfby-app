# Quick Start Guide - KrisiBandhu Website

Get your website up and running in 5 minutes!

## 🚀 Fastest Way to Deploy (Netlify)

### Step 1: Prepare Your Files
Your website is already ready in the `website/` folder!

### Step 2: Deploy to Netlify (Drag & Drop)

1. Go to [netlify.com](https://www.netlify.com/)
2. Sign up or log in (it's FREE!)
3. Click "Add new site" → "Deploy manually"
4. Drag and drop the `website` folder
5. Done! Your site is live! 🎉

### Step 3: Custom Domain (Optional)
1. In Netlify dashboard, go to "Domain settings"
2. Click "Add custom domain"
3. Follow the DNS configuration steps
4. Wait for DNS propagation (usually 5-30 minutes)
5. Netlify automatically provides FREE SSL certificate!

---

## 📱 Local Development

### Test Locally in 30 Seconds

**Option 1: Python (Easiest)**
```bash
cd website
python3 -m http.server 8000
```
Open: http://localhost:8000

**Option 2: PHP**
```bash
cd website
php -S localhost:8000
```
Open: http://localhost:8000

**Option 3: Node.js**
```bash
cd website
npx http-server -p 8000
```
Open: http://localhost:8000

**Option 4: Just Open in Browser**
Simply double-click `index.html` (works for testing, but some features may not work)

---

## 🎨 Customize Your Website

### Change Colors
Edit `css/styles.css` - Line 6-14:
```css
:root {
    --primary-green: #2E7D32;    /* Change this */
    --accent-amber: #FFA000;     /* And this */
    /* ... */
}
```

### Update Content
Edit `index.html` - All text is easy to find and modify:
- Hero title: Line 45
- Features: Starting Line 82
- Contact info: Starting Line 215
- Footer: Starting Line 276

### Add Your Logo
1. Replace the emoji "🌾" with your logo image
2. Edit Line 24 in `index.html`:
```html
<div class="logo">
    <img src="images/logo.png" alt="KrisiBandhu">
</div>
```

### Change Images
1. Add your images to `website/images/` folder
2. Update image paths in `index.html`
3. See `images/README.md` for image specifications

---

## ✅ Checklist Before Going Live

- [ ] Updated contact information (email, phone)
- [ ] Added your images
- [ ] Tested on mobile device
- [ ] Checked all links work
- [ ] Reviewed all content for typos
- [ ] Added Google Analytics (optional)
- [ ] Configured custom domain (if applicable)
- [ ] Tested contact form
- [ ] Checked browser compatibility

---

## 🆘 Common Issues & Solutions

### Issue: CSS not loading
**Solution:** Check that `css/styles.css` path is correct

### Issue: Images not showing
**Solution:** 
1. Verify images are in `website/images/` folder
2. Check image paths in HTML
3. Use correct file extensions (.jpg, .png, .svg)

### Issue: Mobile menu not working
**Solution:** 
1. Ensure `js/script.js` is loading
2. Check browser console for errors
3. Clear browser cache

### Issue: Contact form not submitting
**Solution:** 
- Current form shows notification only
- For real submissions, integrate with backend service:
  - Formspree (easiest)
  - Netlify Forms
  - EmailJS
  - Your own backend

---

## 🔥 Pro Tips

1. **Test on Real Devices**: Open on your phone to see how it looks
2. **Use Browser DevTools**: Press F12 to inspect and debug
3. **Check Performance**: Use Google PageSpeed Insights
4. **Monitor Uptime**: Use UptimeRobot (free monitoring)
5. **Analytics**: Add Google Analytics to track visitors

---

## 📞 Need Help?

**Quick Fixes:**
- Clear browser cache: Ctrl+Shift+Delete (Ctrl+Shift+R on Mac)
- Hard refresh: Ctrl+F5 (Cmd+Shift+R on Mac)
- Check browser console: F12 → Console tab

**Still Stuck?**
- Review the [main README](README.md)
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for detailed guides
- Email: support@krisibandhu.in

---

## 🎯 Next Steps

1. ✅ Deploy website (you're here!)
2. 📱 Launch mobile app
3. 🤖 Integrate AI features
4. 📊 Add analytics
5. 🔔 Set up notifications
6. 🌍 Go live!

---

**Your website is ready to go live! Choose Netlify for the easiest deployment.** 🚀

**Good luck! 🌾**
