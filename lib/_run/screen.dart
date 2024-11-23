import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

class AppColorsDisplayScreen extends StatelessWidget {
  final AppColors appColors;

  AppColorsDisplayScreen({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsRaw.softWhite,
      appBar: AppBar(
        title: Text('App Colors Display'),
        backgroundColor: appColors.background.appBar,
      ),
      body: ListView(
        children: [
          _buildColorSection('Background Colors', _extractBackgroundColors()),
          _buildColorSection('Text Colors', _extractTextColors()),
          _buildColorSection('Button Colors', _extractButtonColors()),
          _buildColorSection('Element Colors', _extractElementColors()),
          _buildColorSection('State Colors', _extractStateColors()),
        ],
      ),
    );
  }

  List<Map<String, Color>> _extractBackgroundColors() {
    return [
      {'Primary': appColors.background.primary},
      {'Secondary': appColors.background.secondary},
      {'Tertiary': appColors.background.tertiary},
      {'App Bar': appColors.background.appBar},
      {'Drawer': appColors.background.drawer},
      {'Bottom Navigation': appColors.background.bottomNav},
    ];
  }

  List<Map<String, Color>> _extractTextColors() {
    return [
      {'Primary': appColors.text.primary},
      {'Secondary': appColors.text.secondary},
      {'Accent': appColors.text.accent},
      {'Disabled': appColors.text.disabled},
      {'Hint': appColors.text.hint},
      {'Inverse': appColors.text.inverse},
      {'Error': appColors.text.error},
    ];
  }

  List<Map<String, Color>> _extractButtonColors() {
    return [
      {'Primary': appColors.button.primary},
      {'Secondary': appColors.button.secondary},
      {'Tertiary': appColors.button.tertiary},
      {'Pressed': appColors.button.pressed},
      {'Hovered': appColors.button.hovered},
      {'Disabled': appColors.button.disabled},
      {'Overlay': appColors.button.overlay},
    ];
  }

  List<Map<String, Color>> _extractElementColors() {
    return [
      {'Card': appColors.element.card},
      {'Modal': appColors.element.modal},
      {'Border': appColors.element.border},
      {'Shadow': appColors.element.shadow},
      {'Divider': appColors.element.divider},
      {'Highlight': appColors.element.highlight},
      {'Background': appColors.element.background},
    ];
  }

  List<Map<String, Color>> _extractStateColors() {
    return [
      {'Active': appColors.state.active},
      {'Inactive': appColors.state.inactive},
      {'Error': appColors.state.error},
      {'Success': appColors.state.success},
      {'Warning': appColors.state.warning},
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
