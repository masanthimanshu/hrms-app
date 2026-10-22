import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xffF4EEFF),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      foregroundColor: const WidgetStatePropertyAll(Color(0xff6B4EE6)),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
      backgroundColor: const WidgetStatePropertyAll(Color(0xff6B4EE6)),
      textStyle: WidgetStatePropertyAll(
        GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  ),
);
