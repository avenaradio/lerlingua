import 'package:flutter/material.dart';

class ThemeColorsDisplay extends StatelessWidget {
  const ThemeColorsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of color names and their corresponding colors
    final List<MapEntry<String, Color>> colorProperties = [
      MapEntry('primary', colorScheme.primary),
      MapEntry('onPrimary', colorScheme.onPrimary),
      MapEntry('secondary', colorScheme.secondary),
      MapEntry('onSecondary', colorScheme.onSecondary),
      MapEntry('surface', colorScheme.surface),
      MapEntry('onSurface', colorScheme.onSurface),
      MapEntry('error', colorScheme.error),
      MapEntry('onError', colorScheme.onError),
      MapEntry('primaryContainer', colorScheme.primaryContainer),
      MapEntry('onPrimaryContainer', colorScheme.onPrimaryContainer),
      MapEntry('secondaryContainer', colorScheme.secondaryContainer),
      MapEntry('onSecondaryContainer', colorScheme.onSecondaryContainer),
      MapEntry('onSurfaceVariant', colorScheme.onSurfaceVariant),
      MapEntry('outline', colorScheme.outline),
      MapEntry('shadow', colorScheme.shadow),
      MapEntry('inverseSurface', colorScheme.inverseSurface),
      MapEntry('onInverseSurface', colorScheme.onInverseSurface),
      MapEntry('inversePrimary', colorScheme.inversePrimary),
      MapEntry('surfaceTint', colorScheme.surfaceTint),
      MapEntry('outlineVariant', colorScheme.outlineVariant),
      MapEntry('scrim', colorScheme.scrim),
      MapEntry('errorContainer', colorScheme.errorContainer),
      MapEntry('onErrorContainer', colorScheme.onErrorContainer),
      MapEntry('tertiary', colorScheme.tertiary),
      MapEntry('onTertiary', colorScheme.onTertiary),
      MapEntry('tertiaryContainer', colorScheme.tertiaryContainer),
      MapEntry('onTertiaryContainer', colorScheme.onTertiaryContainer),
      MapEntry('surfaceContainerLowest', colorScheme.surfaceContainerLowest),
      MapEntry('surfaceContainerLow', colorScheme.surfaceContainerLow),
      MapEntry('surfaceContainer', colorScheme.surfaceContainer),
      MapEntry('surfaceContainerHigh', colorScheme.surfaceContainerHigh),
      MapEntry('surfaceContainerHighest', colorScheme.surfaceContainerHighest),
      MapEntry('surfaceDim', colorScheme.surfaceDim),
      MapEntry('tertiaryFixed', colorScheme.tertiaryFixed),
      MapEntry('onTertiaryFixed', colorScheme.onTertiaryFixed),
      MapEntry('tertiaryFixedDim', colorScheme.tertiaryFixedDim),
      MapEntry('onTertiaryFixedVariant', colorScheme.onTertiaryFixedVariant),
      MapEntry('primaryFixed', colorScheme.primaryFixed),
      MapEntry('onPrimaryFixed', colorScheme.onPrimaryFixed),
      MapEntry('primaryFixedDim', colorScheme.primaryFixedDim),
      MapEntry('onPrimaryFixedVariant', colorScheme.onPrimaryFixedVariant),
      MapEntry('secondaryFixed', colorScheme.secondaryFixed),
      MapEntry('onSecondaryFixed', colorScheme.onSecondaryFixed),
      MapEntry('secondaryFixedDim', colorScheme.secondaryFixedDim),
      MapEntry('onSecondaryFixedVariant', colorScheme.onSecondaryFixedVariant),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Theme Color Scheme Display',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: colorProperties.map((entry) {
                  final Color backgroundColor = entry.value;
                  final Color textColor = _getContrastingColor(backgroundColor);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                      ],
                    ),
                    height: 60,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${entry.key} - ${_colorToHex(backgroundColor)}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns white or black depending on luminance for contrast
  Color _getContrastingColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  // Converts Color to hex string like #RRGGBB or #AARRGGBB
  String _colorToHex(Color color) =>
      '#${color.a.toInt().toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${color.r.toInt().toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${color.g.toInt().toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${color.b.toInt().toRadixString(16).padLeft(2, '0').toUpperCase()}';
}