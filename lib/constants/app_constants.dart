// FILE: constants/app_constants.dart
import 'package:flutter/material.dart';

// --- Colors ---
const kPrimaryColor = Color(0xFF006400);
const kAccentColor = Color(0xFFE0F2F1); // Light teal/mint color
const kWarningColor = Colors.red;
const kNormalColor = Colors.blue;
const kTextColor = Colors.black;
const kGreyColor = Colors.grey;

// --- Dimensions ---
const double kPagePadding = 16.0;
const double kCardPadding = 12.0;
const double kItemSpacing = 10.0;
const double kSectionSpacing = 20.0;

// --- Border Radius ---
final kBorderRadius = BorderRadius.circular(12.0);
const kModalBorderRadius = BorderRadius.vertical(top: Radius.circular(20));

// --- Text Styles ---
const kTitleTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor);
const kCardTitleTextStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
const kBodyTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);