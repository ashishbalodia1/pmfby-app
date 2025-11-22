# Website Deployment Guide

This guide covers multiple deployment options for the KrisiBandhu website.

## Quick Deployment Options

### 1. GitHub Pages (FREE)

#### Setup
1. Push your code to GitHub
2. Go to repository Settings → Pages
3. Select branch (usually `main` or `master`)
4. Set folder to `/website` or root
5. Click Save

Your site will be live at: `https://yourusername.github.io/pmfby-app/`

#### Custom Domain (Optional)
1. Add a `CNAME` file with your domain name
2. Configure DNS with your domain provider
3. Add custom domain in GitHub Pages settings

### 2. Netlify (FREE)

#### Manual Deploy
1. Go to [netlify.com](https://netlify.com)
2. Sign up/Login
3. Drag and drop the `website` folder
4. Your site is live!

#### Continuous Deployment
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd website
netlify deploy

# Production deploy
netlify deploy --prod
```

#### netlify.toml Configuration
Create this file in the website root:
```toml
[build]
  publish = "."

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 3. Vercel (FREE)

#### Deploy with CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd website
vercel

# Production
vercel --prod
```

#### Deploy via GitHub
1. Go to [vercel.com](https://vercel.com)
2. Import your GitHub repository
3. Set root directory to `website`
4. Deploy!

### 4. Firebase Hosting (FREE)

#### Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize
cd /workspaces/pmfby-app
firebase init hosting

# Select options:
# - Public directory: website
# - Single-page app: No
# - Automatic builds: No

# Deploy
firebase deploy --only hosting
```

#### firebase.json Configuration
```json
{
  "hosting": {
    "public": "website",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
```

### 5. Cloudflare Pages (FREE)

1. Go to [pages.cloudflare.com](https://pages.cloudflare.com)
2. Connect your GitHub account
3. Select repository
4. Build settings:
   - Build command: (leave empty)
   - Build output directory: `website`
5. Deploy!

### 6. Surge (FREE)

```bash
# Install Surge
npm install -g surge

# Deploy
cd website
surge

# Deploy to custom domain
surge . yourdomain.com
```

### 7. Traditional Web Hosting

#### Via FTP/SFTP
1. Get hosting credentials (FTP details)
2. Use FileZilla or similar FTP client
3. Upload entire `website` folder to `public_html` or `www`
4. Access via your domain

#### Via cPanel
1. Log into cPanel
2. Go to File Manager
3. Navigate to `public_html`
4. Upload website files
5. Extract if uploaded as ZIP

### 8. AWS S3 + CloudFront

#### Setup S3 Bucket
```bash
# Install AWS CLI
pip install awscli

# Configure
aws configure

# Create bucket
aws s3 mb s3://krisibandhu-website

# Upload files
cd website
aws s3 sync . s3://krisibandhu-website

# Enable static website hosting
aws s3 website s3://krisibandhu-website \
  --index-document index.html \
  --error-document index.html

# Make bucket public
aws s3api put-bucket-policy --bucket krisibandhu-website \
  --policy file://bucket-policy.json
```

#### bucket-policy.json
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::krisibandhu-website/*"
    }
  ]
}
```

### 9. Azure Static Web Apps (FREE)

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Create static web app
az staticwebapp create \
  --name krisibandhu \
  --resource-group YourResourceGroup \
  --source . \
  --location "Central US" \
  --branch main \
  --app-location "/website"
```

### 10. Docker Container

#### Dockerfile
Create in website directory:
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Build and Run
```bash
cd website

# Build image
docker build -t krisibandhu-website .

# Run container
docker run -d -p 80:80 krisibandhu-website

# Access at http://localhost
```

#### Deploy to Docker Hub
```bash
# Tag image
docker tag krisibandhu-website yourusername/krisibandhu-website

# Push
docker push yourusername/krisibandhu-website
```

## Performance Optimization Before Deployment

### 1. Minify CSS
```bash
# Using clean-css-cli
npm install -g clean-css-cli
cleancss -o css/styles.min.css css/styles.css
```

### 2. Minify JavaScript
```bash
# Using terser
npm install -g terser
terser js/script.js -o js/script.min.js -c -m
```

### 3. Optimize Images
```bash
# Using ImageMagick
convert images/farmer-with-phone.jpg -quality 85 -resize 800x600 images/farmer-with-phone-optimized.jpg

# Using imageoptim-cli (Mac)
imageoptim images/*.jpg images/*.png
```

### 4. Enable Gzip Compression

#### Nginx Configuration
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
```

#### Apache (.htaccess)
```apache
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
</IfModule>
```

## SSL/HTTPS Setup

Most modern platforms (Netlify, Vercel, Cloudflare) provide FREE SSL automatically.

### Manual SSL with Let's Encrypt
```bash
# Install Certbot
sudo apt install certbot

# Get certificate
sudo certbot certonly --webroot -w /var/www/html -d yourdomain.com
```

## Custom Domain Configuration

### DNS Settings
Add these records at your domain provider:

#### For GitHub Pages / Netlify / Vercel
```
Type: CNAME
Name: www
Value: your-deployment-url

Type: A
Name: @
Value: (provided by hosting service)
```

#### For Cloudflare
- Automatically configured when using Cloudflare Pages
- Point DNS to Cloudflare nameservers

## Monitoring & Analytics

### Google Analytics
Add to `<head>` section of index.html:
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

### Microsoft Clarity
```html
<script type="text/javascript">
    (function(c,l,a,r,i,t,y){
        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
        t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
    })(window, document, "clarity", "script", "YOUR_CLARITY_ID");
</script>
```

## Maintenance

### Regular Updates
- Update content regularly
- Monitor broken links
- Check performance metrics
- Update SSL certificates (if manual)
- Monitor uptime

### Backup
```bash
# Create backup
tar -czf website-backup-$(date +%Y%m%d).tar.gz website/

# Automated daily backup
echo "0 2 * * * tar -czf /backups/website-\$(date +\%Y\%m\%d).tar.gz /var/www/website/" | crontab -
```

## Troubleshooting

### Common Issues

#### 404 Errors
- Check file paths are correct
- Ensure index.html is in root
- Verify server configuration

#### CSS Not Loading
- Check file paths in HTML
- Verify MIME types
- Clear browser cache

#### Mobile Display Issues
- Test responsive design
- Check viewport meta tag
- Validate media queries

## Recommended: Netlify (Easiest)

For beginners, we recommend **Netlify** because:
- ✅ FREE forever plan
- ✅ Automatic SSL
- ✅ Global CDN
- ✅ Easy custom domain
- ✅ Continuous deployment from Git
- ✅ Instant rollbacks
- ✅ Form handling built-in

## Support

For deployment help:
- Email: support@krisibandhu.in
- Documentation: See hosting provider docs

---

**Choose any method above and your website will be live in minutes!**
