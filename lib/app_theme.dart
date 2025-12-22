import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

const Color grayBorderColor = Color(0xFF25292a);

const Color backgroundColor = Color(0xFF0b0f10);
const Color surfaceColor = Color(0xFF1e1e1e);
const Color inverseSurfaceColor = Color(0xFF2a2a2a);

const Color primaryGreen = Color(0xFF66bb6a);
const Color secondaryGreen = Color(0xFF27AE60);
const Color mutedGreen = Color(0xFF1E3A2B);
const Color textPrimary = Color(0xFFEAF4ED);
const Color textSecondary = Color(0xFF9FB5A7);

ThemeData appTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    extensions: [
      SkeletonizerConfigData(
          containersColor: Colors.grey[900]!,
          ignoreContainers: false,
          enableSwitchAnimation: true,
          justifyMultiLineText: true,
          effect: PulseEffect(
              duration: Duration(milliseconds: 1500),
              from: Colors.grey[800]!,
              to: Colors.grey[700]!)),
    ],
    colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: secondaryGreen,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onBackground: textPrimary,
        onSurface: textPrimary,
        inverseSurface: inverseSurfaceColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryGreen,
      size: 24,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: inverseSurfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.black,
      shape: StadiumBorder(),
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: primaryGreen,
      textColor: Colors.black,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      largeSize: 26,
      smallSize: 20,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    ));
