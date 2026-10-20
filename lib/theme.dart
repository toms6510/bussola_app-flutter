import 'package:flutter/material.dart';

const Color verde = Color(0xFF1F4D3A);
const Color verdeEscuro = Color(0xFF143528);
const Color areia = Color(0xFFF6F0E4);
const Color papel = Color(0xFFFFFDF8);
const Color terracota = Color(0xFFD1603D);
const Color suave = Color(0xFF6B766F);
const Color borda = Color(0xFFE6DFD0);

ThemeData buildTheme() {
  final esquema = ColorScheme.fromSeed(
    seedColor: verde,
    primary: verde,
    secondary: terracota,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: areia,
    appBarTheme: const AppBarTheme(
      backgroundColor: verde,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: 'serif',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: verde, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: terracota,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: verde,
        side: const BorderSide(color: verde, width: 1.5),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: papel,
      indicatorColor: verde.withOpacity(0.15),
    ),
  );
}

TextStyle titulo(double tamanho, {Color cor = verdeEscuro}) => TextStyle(
      fontFamily: 'serif',
      fontSize: tamanho,
      fontWeight: FontWeight.w700,
      color: cor,
      height: 1.15,
    );
