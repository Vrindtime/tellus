import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFF1F2F4),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 31, 102, 224), // --primary-500 #1f66e0
    onPrimary: Color(0xFFFFFFFF), // Typically white or a light color
    secondary: Color(0xFFFF8C00), // --secondary-500
    onSecondary: Color(0xFFFFFFFF), // Typically white or a light color
    // scaffoldBackgroundColor: Color(0xFFF1F2F4), // --background-50
    onBackground: Color(0xFF0A062D), // --text-900
    surface: Color(0xFFFFFFFF), // Typically white for light themes
    onSurface: Color(0xFF0A062D), // --text-900
    error: Color(0xFFB00020), // Standard error color
    onError: Color(0xFFFFFFFF), // Typically white or a light color
    primaryContainer: Color(0xFF1851B4), // --primary-600
    secondaryContainer: Color(0xFFCC7000), // --secondary-600
  ),
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.plusJakartaSans(color: Color(0xFF0A062D),fontSize: 32,fontWeight: FontWeight.w900),
    bodyLarge: GoogleFonts.plusJakartaSans(color: Color(0xFFFFFFFF),fontSize: 20,fontWeight: FontWeight.w600), 
    bodyMedium: GoogleFonts.plusJakartaSans(color: Color(0xFF0A062D)),
    bodySmall: GoogleFonts.plusJakartaSans(color: Color(0xFF1E1287)), 
    titleLarge: GoogleFonts.plusJakartaSans(color: Color.fromARGB(255, 31, 102, 224),fontSize: 26,fontWeight: FontWeight.w700), 
    titleMedium: GoogleFonts.plusJakartaSans(color: Color.fromARGB(255, 31, 102, 224),fontSize: 22,fontWeight: FontWeight.w500), 
    // Define other text styles as needed
  ),
  // Define other theme properties as needed
);

// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme(
//     brightness: Brightness.dark,
//     primary: Color(0xFF281FE0), // --text-500
//     onPrimary: Color(0xFF0B0C0E), // --background-50
//     secondary: Color(0xFFFF8C00), // --secondary-500
//     onSecondary: Color(0xFF0B0C0E), // --background-50
//     surfaceBright: Color(0xFF0B0C0E), // --background-50
//     onBackground: Color(0xFFD4D2F9), // --text-900
//     surface: Color(0xFF16191D), // --background-100
//     onSurface: Color(0xFFD4D2F9), // --text-900
//     error: Color(0xFFCF6679), // Standard error color for dark themes
//     onError: Color(0xFF0B0C0E), // --background-50
//     primaryContainer: Color(0xFF534BE7), // --text-600
//     secondaryContainer: Color(0xFFCC7000), // --secondary-600
//   ),
//   textTheme: TextTheme(
//     bodyMedium: TextStyle(color: Color(0xFFD4D2F9)), // --text-900
//     bodySmall: TextStyle(color: Color(0xFFA9A5F3)), // --text-800
//     titleLarge: TextStyle(color: Color(0xFF7E78ED)), // --text-700
//     // Define other text styles as needed
//   ),
//   // Define other theme properties as needed
// );
