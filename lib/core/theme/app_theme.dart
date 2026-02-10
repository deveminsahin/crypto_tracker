import 'package:flutter/material.dart';

/// Custom colour tokens exposed as a [ThemeExtension].
///
/// Access via `CryptoColors.of(context)` to obtain the current
/// theme's crypto-specific colour palette.
@immutable
final class CryptoColors extends ThemeExtension<CryptoColors> {
  /// Colour for positive price movement.
  final Color priceUp;

  /// Colour for negative price movement.
  final Color priceDown;

  /// Colour for neutral/unchanged price movement (0.0%).
  final Color priceNeutral;

  /// Warning / caution accent colour.
  final Color warning;

  /// Text colour rendered on top of price-badge backgrounds.
  final Color onPriceBadge;

  /// Base colour for shimmer / skeleton loading animations.
  final Color shimmerBase;

  /// Highlight sweep colour for shimmer animations.
  final Color shimmerHighlight;

  /// Transparent colour used when flash animation is idle.
  /// Keeps widget tree structure stable for state preservation.
  final Color flashIdle;

  const CryptoColors({
    required this.priceUp,
    required this.priceDown,
    required this.priceNeutral,
    required this.warning,
    required this.onPriceBadge,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.flashIdle,
  });

  /// Convenience accessor that retrieves [CryptoColors] from the
  /// nearest [Theme].
  static CryptoColors of(final BuildContext context) =>
      Theme.of(context).extension<CryptoColors>()!;

  @override
  CryptoColors copyWith({
    final Color? priceUp,
    final Color? priceDown,
    final Color? priceNeutral,
    final Color? warning,
    final Color? onPriceBadge,
    final Color? shimmerBase,
    final Color? shimmerHighlight,
    final Color? flashIdle,
  }) => CryptoColors(
    priceUp: priceUp ?? this.priceUp,
    priceDown: priceDown ?? this.priceDown,
    priceNeutral: priceNeutral ?? this.priceNeutral,
    warning: warning ?? this.warning,
    onPriceBadge: onPriceBadge ?? this.onPriceBadge,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    flashIdle: flashIdle ?? this.flashIdle,
  );

  @override
  CryptoColors lerp(final CryptoColors? other, final double t) {
    if (other == null) return this;
    return CryptoColors(
      priceUp: Color.lerp(priceUp, other.priceUp, t)!,
      priceDown: Color.lerp(priceDown, other.priceDown, t)!,
      priceNeutral: Color.lerp(priceNeutral, other.priceNeutral, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onPriceBadge: Color.lerp(onPriceBadge, other.onPriceBadge, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      flashIdle: Color.lerp(flashIdle, other.flashIdle, t)!,
    );
  }
}

/// Application theme configuration.
///
/// Provides the single [darkTheme] used throughout the app, incorporating
/// Binance-inspired colours and the [CryptoColors] extension.
abstract final class AppTheme {
  static const Color _scaffoldBackground = Color(0xFF0B0E11);
  static const Color _cardBackground = Color(0xFF1E2329);
  static const Color _priceUp = Color(0xFF0ECB81);
  static const Color _priceDown = Color(0xFFF6465D);
  static const Color _priceNeutral = Color(0xFF848E9C);
  static const Color _warning = Color(0xFFFCD535);
  static const Color _textPrimary = Color(0xFFEAECEF);
  static const Color _textSecondary = Color(0xFF848E9C);
  static const Color _divider = Color(0xFF2B3139);
  static const Color _white = Colors.white;
  static const Color _shimmerBase = Color(0xFF2A2A2E);
  static const Color _shimmerHighlight = Color(0xFF3A3A3E);
  static const Color _flashIdle = Color(0x00000000);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _scaffoldBackground,
    colorScheme: const ColorScheme.dark(
      surface: _scaffoldBackground,
      surfaceContainerHighest: _cardBackground,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outlineVariant: _divider,
      primary: _priceUp,
    ),
    extensions: const [
      CryptoColors(
        priceUp: _priceUp,
        priceDown: _priceDown,
        priceNeutral: _priceNeutral,
        warning: _warning,
        onPriceBadge: _white,
        shimmerBase: _shimmerBase,
        shimmerHighlight: _shimmerHighlight,
        flashIdle: _flashIdle,
      ),
    ],
    appBarTheme: const AppBarTheme(
      backgroundColor: _scaffoldBackground,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: _cardBackground,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: _divider,
      thickness: 0.8,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _divider,
      hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        side: const BorderSide(color: _divider),
      ),
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: _textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: _textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: _textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: _textSecondary, fontSize: 12),
      titleLarge: TextStyle(
        color: _textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
