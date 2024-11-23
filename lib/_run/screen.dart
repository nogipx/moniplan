import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColorsDisplayScreen extends StatefulWidget {
  final AppColors appColors;
  final ColorScheme colorScheme;

  AppColorsDisplayScreen({required this.appColors, required this.colorScheme});

  @override
  _AppColorsDisplayScreenState createState() => _AppColorsDisplayScreenState();
}

class _AppColorsDisplayScreenState extends State<AppColorsDisplayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Colors Display'),
        backgroundColor: widget.appColors.background.surface,
      ),
      body: ListView(
        children: [
          _buildColorSection('BackgroundColors', _extractColorSchemeColorsBackground()),
          _buildColorSection('TextColors', _extractColorSchemeColorsTextColors()),
          _buildColorSection('ButtonColors', _extractColorSchemeColorsButtonColors()),
          _buildColorSection('ElementColors', _extractColorSchemeColorsElementColors()),
          _buildColorSection('StateColors', _extractColorSchemeColorsStateColors()),
        ],
      ),
    );
  }

  // List<Map<String, Color>> _extractBackgroundColors() {
  //   return [
  //     {'Primary': widget.appColors.background.primary},
  //     {'Secondary': widget.appColors.background.secondary},
  //     {'Tertiary': widget.appColors.background.tertiary},
  //     {'App Bar': widget.appColors.background.appBar},
  //     {'Drawer': widget.appColors.background.drawer},
  //     {'Bottom Navigation': widget.appColors.background.bottomNav},
  //   ];
  // }
  //
  // List<Map<String, Color>> _extractTextColors() {
  //   return [
  //     {'Primary': widget.appColors.text.primary},
  //     {'Secondary': widget.appColors.text.secondary},
  //     {'Accent': widget.appColors.text.accent},
  //     {'Disabled': widget.appColors.text.disabled},
  //     {'Hint': widget.appColors.text.hint},
  //     {'Inverse': widget.appColors.text.inverse},
  //     {'Error': widget.appColors.text.error},
  //   ];
  // }
  //
  // List<Map<String, Color>> _extractButtonColors() {
  //   return [
  //     {'Primary': widget.appColors.button.primary},
  //     {'Secondary': widget.appColors.button.secondary},
  //     {'Tertiary': widget.appColors.button.tertiary},
  //     {'Pressed': widget.appColors.button.pressed},
  //     {'Hovered': widget.appColors.button.hovered},
  //     {'Disabled': widget.appColors.button.disabled},
  //     {'Overlay': widget.appColors.button.overlay},
  //   ];
  // }
  //
  // List<Map<String, Color>> _extractElementColors() {
  //   return [
  //     {'Card': widget.appColors.element.card},
  //     {'Modal': widget.appColors.element.modal},
  //     {'Border': widget.appColors.element.border},
  //     {'Shadow': widget.appColors.element.shadow},
  //     {'Divider': widget.appColors.element.divider},
  //     {'Highlight': widget.appColors.element.highlight},
  //     {'Background': widget.appColors.element.background},
  //   ];
  // }
  //
  // List<Map<String, Color>> _extractStateColors() {
  //   return [
  //     {'Active': widget.appColors.state.active},
  //     {'Inactive': widget.appColors.state.inactive},
  //     {'Error': widget.appColors.state.error},
  //     {'Success': widget.appColors.state.success},
  //     {'Warning': widget.appColors.state.warning},
  //   ];
  // }

  List<Map<String, Color>> _extractColorSchemeColorsBackground() {
    final colorScheme = widget.colorScheme;
    return [
      {'Surface': colorScheme.surface},
      {'On Surface': colorScheme.onSurface},
      {'Surface Dim': colorScheme.surfaceDim},
      {'Surface Bright': colorScheme.surfaceBright},
      {'Surface Container Lowest': colorScheme.surfaceContainerLowest},
      {'Surface Container Low': colorScheme.surfaceContainerLow},
      {'Surface Container': colorScheme.surfaceContainer},
      {'Surface Container High': colorScheme.surfaceContainerHigh},
      {'Surface Container Highest': colorScheme.surfaceContainerHighest},
      {'Primary Container': colorScheme.primaryContainer},
      {'On Primary Container': colorScheme.onPrimaryContainer},
      {'Secondary Container': colorScheme.secondaryContainer},
      {'On Secondary Container': colorScheme.onSecondaryContainer},
      {'Tertiary Container': colorScheme.tertiaryContainer},
      {'On Tertiary Container': colorScheme.onTertiaryContainer},
    ];
  }

  List<Map<String, Color>> _extractColorSchemeColorsTextColors() {
    final colorScheme = widget.colorScheme;
    return [
      {'On Primary': colorScheme.onPrimary},
      {'On Primary Fixed': colorScheme.onPrimaryFixed},
      {'On Primary Fixed Variant': colorScheme.onPrimaryFixedVariant},
      {'On Secondary': colorScheme.onSecondary},
      {'On Secondary Fixed': colorScheme.onSecondaryFixed},
      {'On Secondary Fixed Variant': colorScheme.onSecondaryFixedVariant},
      {'On Tertiary': colorScheme.onTertiary},
      {'On Tertiary Fixed': colorScheme.onTertiaryFixed},
      {'On Tertiary Fixed Variant': colorScheme.onTertiaryFixedVariant},
      {'On Error': colorScheme.onError},
      {'On Error Container': colorScheme.onErrorContainer},
      {'On Surface Variant': colorScheme.onSurfaceVariant},
      {'On Inverse Surface': colorScheme.onInverseSurface},
    ];
  }

  List<Map<String, Color>> _extractColorSchemeColorsButtonColors() {
    final colorScheme = widget.colorScheme;
    return [
      {'Primary': colorScheme.primary},
      {'Primary Fixed': colorScheme.primaryFixed},
      {'Primary Fixed Dim': colorScheme.primaryFixedDim},
      {'Secondary': colorScheme.secondary},
      {'Secondary Fixed': colorScheme.secondaryFixed},
      {'Secondary Fixed Dim': colorScheme.secondaryFixedDim},
      {'Tertiary': colorScheme.tertiary},
      {'Tertiary Fixed': colorScheme.tertiaryFixed},
      {'Tertiary Fixed Dim': colorScheme.tertiaryFixedDim},
      {'Surface Tint': colorScheme.surfaceTint},
      {'Shadow': colorScheme.shadow},
      {'Scrim': colorScheme.scrim},
    ];
  }

  List<Map<String, Color>> _extractColorSchemeColorsElementColors() {
    final colorScheme = widget.colorScheme;
    return [
      {'Outline': colorScheme.outline},
      {'Outline Variant': colorScheme.outlineVariant},
      {'Inverse Surface': colorScheme.inverseSurface},
      {'Inverse Primary': colorScheme.inversePrimary},
    ];
  }

  List<Map<String, Color>> _extractColorSchemeColorsStateColors() {
    final colorScheme = widget.colorScheme;
    return [
      {'Error': colorScheme.error},
      {'Error Container': colorScheme.errorContainer},
    ];
  }

  Widget _buildColorSection(String title, List<Map<String, Color>> colors) {
    return Builder(builder: (context) {
      final style = context.theme.textTheme.bodyMedium?.copyWith(
        color: Colors.black,
      );
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: style,
            ),
            SizedBox(height: 8),
            Column(
              children: colors.map((colorMap) {
                final colorName = colorMap.keys.first;
                final color = colorMap.values.first;
                return ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    colorName,
                    style: style,
                  ),
                  subtitle: Text(
                    '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                    style: style,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}
