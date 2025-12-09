import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Themes',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Choose Your Theme',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a color theme for your app. All themes are optimized for readability.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ...AppThemes.allThemes.map((theme) {
                final isSelected = themeProvider.currentTheme.id == theme.id;
                return _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () => themeProvider.setTheme(theme),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? theme.primary 
              : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color Preview
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary, theme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.onPrimary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Check mark for selected
                    if (isSelected)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.onPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: theme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    // Theme name
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.name,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.onPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              theme.isDark ? 'Dark Mode' : 'Light Mode',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Preview Content
              Container(
                color: theme.background,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Text',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is how your text will look in this theme.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Primary button preview
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Button',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Card preview
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Card',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
