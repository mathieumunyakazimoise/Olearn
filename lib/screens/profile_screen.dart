import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/providers/theme_provider.dart';
import 'package:olearn/providers/locale_provider.dart';
import 'package:olearn/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    final isDarkTheme = themeProvider.themeMode == ThemeMode.dark;
    final selectedLanguage = localeProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
              child: const Icon(Icons.person, size: 56, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.profileName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.profileEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations.language),
              trailing: SizedBox(
                width: 160,
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'sw', child: Text('Kiswahili')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      localeProvider.setLocale(Locale(value));
                    }
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: Text(localizations.theme),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: isDarkTheme,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: Text(localizations.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 