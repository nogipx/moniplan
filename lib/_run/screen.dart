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
        backgroundColor: widget.appColors.background.appBar,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'App Colors'),
            Tab(text: 'ColorScheme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            children: [
              _buildColorSection('Background Colors', _extractBackgroundColors()),
              _buildColorSection('Text Colors', _extractTextColors()),
              _buildColorSection('Button Colors', _extractButtonColors()),
              _buildColorSection('Element Colors', _extractElementColors()),
              _buildColorSection('State Colors', _extractStateColors()),
            ],
          ),
          ListView(
            children: [
              _buildColorSection('ColorScheme Colors', _extractColorSchemeColors()),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, Color>> _extractBackgroundColors() {
    return [
      {'Primary': widget.appColors.background.primary},
      {'Secondary': widget.appColors.background.secondary},
      {'Tertiary': widget.appColors.background.tertiary},
      {'App Bar': widget.appColors.background.appBar},
      {'Drawer': widget.appColors.background.drawer},
      {'Bottom Navigation': widget.appColors.background.bottomNav},
    ];
  }

  List<Map<String, Color>> _extractTextColors() {
    return [
      {'Primary': widget.appColors.text.primary},
      {'Secondary': widget.appColors.text.secondary},
      {'Accent': widget.appColors.text.accent},
      {'Disabled': widget.appColors.text.disabled},
      {'Hint': widget.appColors.text.hint},
      {'Inverse': widget.appColors.text.inverse},
      {'Error': widget.appColors.text.error},
    ];
  }

  List<Map<String, Color>> _extractButtonColors() {
    return [
      {'Primary': widget.appColors.button.primary},
      {'Secondary': widget.appColors.button.secondary},
      {'Tertiary': widget.appColors.button.tertiary},
      {'Pressed': widget.appColors.button.pressed},
      {'Hovered': widget.appColors.button.hovered},
      {'Disabled': widget.appColors.button.disabled},
      {'Overlay': widget.appColors.button.overlay},
    ];
  }

  List<Map<String, Color>> _extractElementColors() {
    return [
      {'Card': widget.appColors.element.card},
      {'Modal': widget.appColors.element.modal},
      {'Border': widget.appColors.element.border},
      {'Shadow': widget.appColors.element.shadow},
      {'Divider': widget.appColors.element.divider},
      {'Highlight': widget.appColors.element.highlight},
      {'Background': widget.appColors.element.background},
    ];
  }

  List<Map<String, Color>> _extractStateColors() {
    return [
      {'Active': widget.appColors.state.active},
      {'Inactive': widget.appColors.state.inactive},
      {'Error': widget.appColors.state.error},
      {'Success': widget.appColors.state.success},
      {'Warning': widget.appColors.state.warning},
    ];
  }

  List<Map<String, Color>> _extractColorSchemeColors() {
    final colorScheme = widget.colorScheme;
    return [
      {'Primary': colorScheme.primary},
      {'On Primary': colorScheme.onPrimary},
      {'Primary Container': colorScheme.primaryContainer},
      {'On Primary Container': colorScheme.onPrimaryContainer},
      {'Primary Fixed': colorScheme.primaryFixed},
      {'Primary Fixed Dim': colorScheme.primaryFixedDim},
      {'On Primary Fixed': colorScheme.onPrimaryFixed},
      {'On Primary Fixed Variant': colorScheme.onPrimaryFixedVariant},
      {'Secondary': colorScheme.secondary},
      {'On Secondary': colorScheme.onSecondary},
      {'Secondary Container': colorScheme.secondaryContainer},
      {'On Secondary Container': colorScheme.onSecondaryContainer},
      {'Secondary Fixed': colorScheme.secondaryFixed},
      {'Secondary Fixed Dim': colorScheme.secondaryFixedDim},
      {'On Secondary Fixed': colorScheme.onSecondaryFixed},
      {'On Secondary Fixed Variant': colorScheme.onSecondaryFixedVariant},
      {'Tertiary': colorScheme.tertiary},
      {'On Tertiary': colorScheme.onTertiary},
      {'Tertiary Container': colorScheme.tertiaryContainer},
      {'On Tertiary Container': colorScheme.onTertiaryContainer},
      {'Tertiary Fixed': colorScheme.tertiaryFixed},
      {'Tertiary Fixed Dim': colorScheme.tertiaryFixedDim},
      {'On Tertiary Fixed': colorScheme.onTertiaryFixed},
      {'On Tertiary Fixed Variant': colorScheme.onTertiaryFixedVariant},
      {'Error': colorScheme.error},
      {'On Error': colorScheme.onError},
      {'Error Container': colorScheme.errorContainer},
      {'On Error Container': colorScheme.onErrorContainer},
      {'Surface': colorScheme.surface},
      {'On Surface': colorScheme.onSurface},
      {'Surface Dim': colorScheme.surfaceDim},
      {'Surface Bright': colorScheme.surfaceBright},
      {'Surface Container Lowest': colorScheme.surfaceContainerLowest},
      {'Surface Container Low': colorScheme.surfaceContainerLow},
      {'Surface Container': colorScheme.surfaceContainer},
      {'Surface Container High': colorScheme.surfaceContainerHigh},
      {'Surface Container Highest': colorScheme.surfaceContainerHighest},
      {'On Surface Variant': colorScheme.onSurfaceVariant},
      {'Outline': colorScheme.outline},
      {'Outline Variant': colorScheme.outlineVariant},
      {'Shadow': colorScheme.shadow},
      {'Scrim': colorScheme.scrim},
      {'Inverse Surface': colorScheme.inverseSurface},
      {'On Inverse Surface': colorScheme.onInverseSurface},
      {'Inverse Primary': colorScheme.inversePrimary},
      {'Surface Tint': colorScheme.surfaceTint},
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
