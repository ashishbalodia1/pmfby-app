# KrisiBandhu Website

A modern, responsive website for the KrisiBandhu AI-Powered Crop Insurance platform.

## 🌾 About

KrisiBandhu (meaning "Friend of Farmers") is a digital platform designed to make crop insurance claims faster, fairer, and more transparent for farmers in India. This website serves as the landing page and information portal for the mobile application.

## 🚀 Features

- **Responsive Design**: Fully responsive layout that works on all devices
- **Modern UI/UX**: Clean, agriculture-themed design with smooth animations
- **Performance Optimized**: Fast loading with optimized assets
- **SEO Friendly**: Semantic HTML and meta tags for better search visibility
- **Accessible**: WCAG compliant with keyboard navigation support

## 📁 Project Structure

```
website/
├── index.html              # Main landing page
├── css/
│   └── styles.css         # All styles with CSS variables
├── js/
│   └── script.js          # Interactive features and animations
├── images/                # Image assets
│   └── README.md          # Image requirements and guidelines
└── README.md              # This file
```

## 🛠️ Technologies Used

- **HTML5**: Semantic markup
- **CSS3**: Modern styling with Grid, Flexbox, and CSS Variables
- **Vanilla JavaScript**: No frameworks, pure JS for better performance
- **Google Fonts**: Merriweather, Open Sans, and Roboto

## 🎨 Design System

### Colors
- Primary Green: `#2E7D32`
- Dark Green: `#1B5E20`
- Light Green: `#4CAF50`
- Accent Amber: `#FFA000`
- Accent Yellow: `#FDD835`

### Typography
- Headings: Merriweather (serif)
- Body: Open Sans (sans-serif)
- Buttons: Roboto (sans-serif)

## 🚀 Getting Started

### Prerequisites
- A modern web browser
- A local web server (optional, for development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ashishbalodia1/pmfby-app.git
cd pmfby-app/website
```

2. Open the website:
   - **Option 1**: Simply open `index.html` in your browser
   - **Option 2**: Use a local server (recommended)

### Using a Local Server

#### Python
```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

#### Node.js (with http-server)
```bash
npx http-server -p 8000
```

#### PHP
```bash
php -S localhost:8000
```

Then open `http://localhost:8000` in your browser.

## 📱 Responsive Breakpoints

- Desktop: 1200px+
- Tablet: 768px - 1199px
- Mobile: < 768px
- Small Mobile: < 480px

## ✨ Features Implemented

### Navigation
- Fixed navigation bar with scroll effects
- Mobile-friendly hamburger menu
- Smooth scrolling to sections

### Hero Section
- Full-screen hero with gradient background
- Animated statistics counter
- Call-to-action buttons

### Features Section
- Grid layout with hover effects
- Icon-driven feature cards
- Responsive design

### How It Works
- Step-by-step process visualization
- Numbered steps with descriptions

### About Section
- Two-column layout with image
- Mission and vision highlights

### Technology Stack
- Glass-morphism effect cards
- Hover animations

### Contact Section
- Working contact form with validation
- Contact information display
- Form submission notifications

### Footer
- Multi-column footer layout
- Newsletter subscription
- Social media links

## 🔧 Customization

### Changing Colors
Edit the CSS variables in `css/styles.css`:

```css
:root {
    --primary-green: #2E7D32;
    --accent-amber: #FFA000;
    /* ... other variables */
}
```

### Adding Images
Place your images in the `images/` folder and update references in `index.html`. See `images/README.md` for specifications.

### Modifying Content
Edit the HTML content directly in `index.html`. The structure is well-commented and semantic.

## 📊 Performance

- Minimal dependencies (only Google Fonts)
- Optimized CSS with no preprocessor overhead
- Vanilla JavaScript for better performance
- Lazy loading for images
- Debounced scroll events

## 🌐 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Opera (latest)

## 📄 License

This project is part of the KrisiBandhu platform. All rights reserved.

## 👨‍💻 Development

### Adding New Sections

1. Add HTML markup in `index.html`
2. Add styles in `css/styles.css`
3. Add interactivity in `js/script.js` if needed

### Best Practices

- Keep CSS organized by sections
- Use semantic HTML elements
- Add comments for complex functionality
- Test on multiple devices and browsers
- Optimize images before adding

## 🤝 Contributing

This is part of the KrisiBandhu project. For contributions, please refer to the main project repository.

## 📧 Contact

- Email: support@krisibandhu.in
- Phone: 1800-123-456 (Toll Free)

## 🙏 Acknowledgments

- Designed for Indian farmers
- Built with modern web technologies
- Inspired by Material Design principles

---

**Built with ❤️ for Indian Farmers**
