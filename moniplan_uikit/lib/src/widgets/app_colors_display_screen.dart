import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColorsDisplayScreen extends StatefulWidget {
  AppColorsDisplayScreen();

  @override
  _AppColorsDisplayScreenState createState() => _AppColorsDisplayScreenState();
}

class _AppColorsDisplayScreenState extends State<AppColorsDisplayScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      _buildColorSection('Extra', _extractExtra()),
      _buildColorSection('Primary', _extractPrimary()),
      _buildColorSection('Secondary', _extractSecondary()),
      _buildColorSection('Tertiary', _extractTertiary()),
      _buildColorSection('Surface', _extractSurface()),
      _buildColorSection('Error', _extractError()),
      _buildColorSection('Other', _extractOthers()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('App Colors Display'),
        bottom: TabBar(
          isScrollable: true,
          padding: EdgeInsets.zero,
          controller: _tabController,
          tabs: sections
              .map(
                (e) => Tab(
                  text: e.$1,
                ),
              )
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: sections.map((e) => e.$2).toList(),
      ),
    );
  }

  Map<String, Color> _extractPrimary() {
    final colorScheme = context.color;
    return {
      'Primary': colorScheme.primary,
      'Inverse Primary': colorScheme.inversePrimary,
      'Primary Fixed': colorScheme.primaryFixed,
      'Primary Fixed Dim': colorScheme.primaryFixedDim,
      'Primary Container': colorScheme.primaryContainer,
      'On Primary': colorScheme.onPrimary,
      'On Primary Fixed': colorScheme.onPrimaryFixed,
      'On Primary Fixed Variant': colorScheme.onPrimaryFixedVariant,
      'On Primary Container': colorScheme.onPrimaryContainer,
    };
  }

  Map<String, Color> _extractSecondary() {
    final colorScheme = context.color;
    return {
      'Secondary': colorScheme.secondary,
      'Secondary Fixed': colorScheme.secondaryFixed,
      'Secondary Fixed Dim': colorScheme.secondaryFixedDim,
      'Secondary Container': colorScheme.secondaryContainer,
      'On Secondary': colorScheme.onSecondary,
      'On Secondary Fixed': colorScheme.onSecondaryFixed,
      'On Secondary Fixed Variant': colorScheme.onSecondaryFixedVariant,
      'On Secondary Container': colorScheme.onSecondaryContainer,
    };
  }

  Map<String, Color> _extractTertiary() {
    final colorScheme = context.color;
    return {
      'Tertiary': colorScheme.tertiary,
      'Tertiary Fixed': colorScheme.tertiaryFixed,
      'Tertiary Fixed Dim': colorScheme.tertiaryFixedDim,
      'Tertiary Container': colorScheme.tertiaryContainer,
      'On Tertiary': colorScheme.onTertiary,
      'On Tertiary Fixed': colorScheme.onTertiaryFixed,
      'On Tertiary Fixed Variant': colorScheme.onTertiaryFixedVariant,
      'On Tertiary Container': colorScheme.onTertiaryContainer,
    };
  }

  Map<String, Color> _extractSurface() {
    final colorScheme = context.color;
    return {
      'Surface': colorScheme.surface,
      'Inverse Surface': colorScheme.inverseSurface,
      'On Surface': colorScheme.onSurface,
      'On Surface Variant': colorScheme.onSurfaceVariant,
      'On Inverse Surface': colorScheme.onInverseSurface,
      'Surface Dim': colorScheme.surfaceDim,
      'Surface Bright': colorScheme.surfaceBright,
      'Surface Tint': colorScheme.surfaceTint,
      'Surface Container Lowest': colorScheme.surfaceContainerLowest,
      'Surface Container Low': colorScheme.surfaceContainerLow,
      'Surface Container': colorScheme.surfaceContainer,
      'Surface Container High': colorScheme.surfaceContainerHigh,
      'Surface Container Highest': colorScheme.surfaceContainerHighest,
    };
  }

  Map<String, Color> _extractError() {
    final colorScheme = context.color;
    return {
      'Error': colorScheme.error,
      'Error Container': colorScheme.errorContainer,
      'On Error': colorScheme.onError,
      'On Error Container': colorScheme.onErrorContainer,
    };
  }

  Map<String, Color> _extractOthers() {
    final colorScheme = context.color;
    return {
      'Outline': colorScheme.outline,
      'Outline Variant': colorScheme.outlineVariant,
      'Shadow': colorScheme.shadow,
      'Scrim': colorScheme.scrim,
    };
  }

  Map<String, Color> _extractExtra() => context.extra.names;

  (String, Widget) _buildColorSection(String title, Map<String, Color> colors) {
    final widget = Builder(
      builder: (context) {
        final entries = colors.entries.toList();
        final style = context.theme.textTheme.bodyMedium;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              final colorMap = entries[index];
              final colorName = colorMap.key;
              final color = colorMap.value;
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
            },
          ),
        );
      },
    );

    return (title, widget);
  }
}
