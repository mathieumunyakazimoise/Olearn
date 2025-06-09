import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/l10n/app_localizations.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: AppConstants.onboardingScreens.length,
            itemBuilder: (context, index) {
              final screen = AppConstants.onboardingScreens[index];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for feature image
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.school,
                        size: 120,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      AppLocalizations.of(context)!.onboardingTitle,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.onboardingDescription,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          // Bottom Navigation
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    AppConstants.onboardingScreens.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      if (_currentPage < AppConstants.onboardingScreens.length - 1)
                        TextButton(
                          onPressed: _navigateToHome,
                          child: const Text('Skip'),
                        )
                      else
                        const SizedBox.shrink(),
                      // Next/Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < AppConstants.onboardingScreens.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _navigateToHome();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            _currentPage < AppConstants.onboardingScreens.length - 1
                                ? 'Next'
                                : 'Get Started',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 