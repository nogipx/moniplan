import 'package:flutter/material.dart';
import 'package:moniplan_uikit/moniplan_uikit.dart';

extension MoniplanExtraColorsExtension on BuildContext {
  MoniplanExtraColors get extra => theme.ext<MoniplanExtraColors>()!;
}

class MoniplanExtraColors extends ThemeExtension<MoniplanExtraColors> {
  final Brightness brightness;
  final Color moniplanBrand;
  final Color moneyPositive;
  final Color moneyNegative;

  const MoniplanExtraColors({
    required this.brightness,
    required this.moniplanBrand,
    required this.moneyPositive,
    required this.moneyNegative,
  });

  MoniplanExtraColors.dark()
      : brightness = Brightness.dark,
        moniplanBrand = ExperimentColor.moniplanBrand,
        moneyPositive = Colors.green,
        moneyNegative = Colors.red;

  MoniplanExtraColors.light()
      : brightness = Brightness.light,
        moniplanBrand = ExperimentColor.moniplanBrand,
        moneyPositive = Colors.green.shade900,
        moneyNegative = Colors.red.shade900;

  static MoniplanExtraColors from<T>(Brightness brightness) =>
      brightness == Brightness.dark ? MoniplanExtraColors.dark() : MoniplanExtraColors.light();

  @override
  MoniplanExtraColors lerp(MoniplanExtraColors? other, double t) {
    return MoniplanExtraColors(
      brightness: other?.brightness ?? brightness,
      moniplanBrand: Color.lerp(moniplanBrand, other?.moniplanBrand, t) ?? moniplanBrand,
      moneyPositive: Color.lerp(moneyPositive, other?.moneyPositive, t) ?? moneyPositive,
      moneyNegative: Color.lerp(moneyNegative, other?.moneyNegative, t) ?? moneyNegative,
    );
  }

  @override
  ThemeExtension<MoniplanExtraColors> copyWith() {
    return MoniplanExtraColors.from(brightness);
  }

  Map<String, Color> get names => {
        'Brand': moniplanBrand,
        'Money Positive': moneyPositive,
        'Money Negative': moneyNegative,
      };
}
