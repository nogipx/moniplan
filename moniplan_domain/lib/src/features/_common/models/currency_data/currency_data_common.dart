// Copyright (C) S. Brett Sutton - All Rights Reserved
// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'currency_data.dart';

/// Provides a list of the most common currencies.
///
/// The full list of currencies are available when you
/// parse an amount.
///
/// ```dart
/// Currencies.parse('$AUD10.00', pattern: 'SCCC#.#');
/// ```
///
abstract interface class CurrencyDataCommon {
  /// Factory constructor providing
  /// access to all common currencies.

  /// Afghan Afghani
  static CurrencyData get afn => CurrencyData.create(
        'AFN',
        2,
        symbol: '؋',
        country: 'Afghanistan',
        unit: 'Afghani',
        name: 'Afghan Afghani',
      );

  /// Albanian Lek
  static CurrencyData get all => CurrencyData.create(
        'ALL',
        2,
        symbol: 'L',
        country: 'Albania',
        unit: 'Lek',
        name: 'Albanian Lek',
      );

  /// Algerian Dinar
  static CurrencyData get dzd => CurrencyData.create(
        'DZD',
        2,
        symbol: 'د.ج',
        pattern: '0.00S',
        country: 'Algeria',
        unit: 'Dinar',
        name: 'Algerian Dinar',
      );

  /// Angolan Kwanza
  static CurrencyData get aoa => CurrencyData.create(
        'AOA',
        2,
        symbol: 'Kz',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Angola',
        unit: 'Kwanza',
        name: 'Angolan Kwanza',
      );

  /// Argentine Peso
  static CurrencyData get ars => CurrencyData.create(
        'ARS',
        2,
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Argentina',
        unit: 'Peso',
        name: 'Argentine Peso',
      );

  /// Armenian Dram
  static CurrencyData get amd => CurrencyData.create(
        'AMD',
        2,
        symbol: '֏',
        pattern: '0.00S',
        country: 'Armenia',
        unit: 'Dram',
        name: 'Armenian Dram',
      );

  /// Aruban Florin
  static CurrencyData get awg => CurrencyData.create(
        'AWG',
        2,
        symbol: 'ƒ',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Aruba',
        unit: 'Florin',
        name: 'Aruban Florin',
      );

  /// Australian Dollar
  static CurrencyData get aud => CurrencyData.create(
        'AUD',
        2,
        country: 'Australian',
        unit: 'Dollar',
        name: 'Australian Dollar',
      );

  /// Azerbaijani Manat
  static CurrencyData get azn => CurrencyData.create(
        'AZN',
        2,
        symbol: '₼',
        country: 'Azerbaijan',
        unit: 'Manat',
        name: 'Azerbaijani Manat',
      );

  /// Bahamian Dollar
  static CurrencyData get bsd => CurrencyData.create(
        'BSD',
        2,
        country: 'Bahamas',
        unit: 'Dollar',
        name: 'Bahamian Dollar',
      );

  /// Bahraini Dinar
  static CurrencyData get bhd => CurrencyData.create(
        'BHD',
        3,
        symbol: '.د.ب',
        pattern: '0.000S',
        country: 'Bahrain',
        unit: 'Dinar',
        name: 'Bahraini Dinar',
      );

  /// Bangladeshi Taka
  static CurrencyData get bdt => CurrencyData.create(
        'BDT',
        2,
        symbol: '৳',
        country: 'Bangladesh',
        unit: 'Taka',
        name: 'Bangladeshi Taka',
      );

  /// Barbadian Dollar
  static CurrencyData get bbd => CurrencyData.create(
        'BBD',
        2,
        country: 'Barbados',
        unit: 'Dollar',
        name: 'Barbadian Dollar',
      );

  /// Belarusian Ruble
  static CurrencyData get byn => CurrencyData.create(
        'BYN',
        2,
        symbol: 'Br',
        pattern: 'S0,00',
        groupSeparator: ' ',
        decimalSeparator: ',',
        country: 'Belarus',
        unit: 'Ruble',
        name: 'Belarusian Ruble',
      );

  /// Belize Dollar
  static CurrencyData get bzd => CurrencyData.create(
        'BZD',
        2,
        symbol: r'BZ$',
        country: 'Belize',
        unit: 'Dollar',
        name: 'Belize Dollar',
      );

  /// Bermudian Dollar
  static CurrencyData get bmd => CurrencyData.create(
        'BMD',
        2,
        country: 'Bermuda',
        unit: 'Dollar',
        name: 'Bermudian Dollar',
      );

  /// Bhutanese Ngultrum
  static CurrencyData get btn => CurrencyData.create(
        'BTN',
        2,
        symbol: 'Nu.',
        country: 'Bhutan',
        unit: 'Ngultrum',
        name: 'Bhutanese Ngultrum',
      );

  /// Bitcoin
  static CurrencyData get btc => CurrencyData.create(
        'BTC',
        8,
        symbol: '₿',
        pattern: 'S0.00000000',
        country: 'Digital',
        unit: 'Bitcoin',
        name: 'Bitcon',
      );

  /// Bolivian Boliviano
  static CurrencyData get bob => CurrencyData.create(
        'BOB',
        2,
        symbol: 'Bs.',
        country: 'Bolivia',
        unit: 'Boliviano',
        name: 'Bolivian Boliviano',
      );

  /// Bosnia and Herzegovina Convertible Mark
  static CurrencyData get bam => CurrencyData.create(
        'BAM',
        2,
        symbol: 'KM',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Bosnia and Herzegovina',
        unit: 'Mark',
        name: 'Bosnia and Herzegovina Convertible Mark',
      );

  /// Botswana Pula
  static CurrencyData get bwp => CurrencyData.create(
        'BWP',
        2,
        symbol: 'P',
        country: 'Botswana',
        unit: 'Pula',
        name: 'Botswana Pula',
      );

  /// Brazilian Real
  static CurrencyData get brl => CurrencyData.create(
        'BRL',
        2,
        symbol: r'R$',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Brazil',
        unit: 'Real',
        name: 'Brazilian Real',
      );

  /// British Pound Sterling
  static CurrencyData get gbp => CurrencyData.create(
        'GBP',
        2,
        symbol: '£',
        country: 'Britan',
        unit: 'Pound Sterling',
        name: 'British Pound Sterling',
      );

  /// Brunei Dollar
  static CurrencyData get bnd => CurrencyData.create(
        'BND',
        2,
        country: 'Brunei',
        unit: 'Dollar',
        name: 'Brunei Dollar',
      );

  /// Bulgarian Lev
  static CurrencyData get bgn => CurrencyData.create(
        'BGN',
        2,
        symbol: 'лв',
        pattern: 'S0,00',
        groupSeparator: ' ',
        decimalSeparator: ',',
        country: 'Bulgaria',
        unit: 'Lev',
        name: 'Bulgarian Lev',
      );

  /// Burundian Franc
  static CurrencyData get bif => CurrencyData.create(
        'BIF',
        0,
        symbol: 'FBu',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Burundi',
        unit: 'Franc',
        name: 'Burundian Franc',
      );

  /// Cambodian Riel
  static CurrencyData get khr => CurrencyData.create(
        'KHR',
        2,
        symbol: '៛',
        country: 'Cambodia',
        unit: 'Riel',
        name: 'Cambodian Riel',
      );

  /// Canadian Dollar
  static CurrencyData get cad => CurrencyData.create(
        'CAD',
        2,
        country: 'Canada',
        unit: 'Dollar',
        name: 'Canadian Dollar',
      );

  /// Cape Verdean Escudo
  static CurrencyData get cve => CurrencyData.create(
        'CVE',
        2,
        country: 'Cape Verde',
        unit: 'Escudo',
        name: 'Cape Verdean Escudo',
      );

  /// Cayman Islands Dollar
  static CurrencyData get kyd => CurrencyData.create(
        'KYD',
        2,
        country: 'Cayman Islands',
        unit: 'Dollar',
        name: 'Cayman Islands Dollar',
      );

  /// Central African CFA Franc
  static CurrencyData get xaf => CurrencyData.create(
        'XAF',
        0,
        symbol: 'FCFA',
        pattern: 'S0',
        groupSeparator: ' ',
        decimalSeparator: '',
        country: 'Central African States',
        unit: 'Franc',
        name: 'Central African CFA Franc',
      );

  /// CFP Franc
  static CurrencyData get xpf => CurrencyData.create(
        'XPF',
        0,
        symbol: '₣',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'French Polynesia, New Caledonia, Wallis and Futuna',
        unit: 'Franc',
        name: 'CFP Franc',
      );

  /// Chilean Peso
  static CurrencyData get clp => CurrencyData.create(
        'CLP',
        0,
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Chile',
        unit: 'Peso',
        name: 'Chilean Peso',
      );

  /// Chinese Renminbi
  static CurrencyData get cny => CurrencyData.create(
        'CNY',
        2,
        symbol: '¥',
        country: 'China',
        unit: 'Renminbi',
        name: 'Chinese Renminbi',
      );

  /// Colombian Peso
  static CurrencyData get cop => CurrencyData.create(
        'COP',
        2,
        pattern: '0,00S',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Colombia',
        unit: 'Peso',
        name: 'Colombian Peso',
      );

  /// Comorian Franc
  static CurrencyData get kmf => CurrencyData.create(
        'KMF',
        0,
        symbol: 'CF',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Comoros',
        unit: 'Franc',
        name: 'Comorian Franc',
      );

  /// Congolese Franc
  static CurrencyData get cdf => CurrencyData.create(
        'CDF',
        2,
        symbol: 'FC',
        country: 'Congo (DRC)',
        unit: 'Franc',
        name: 'Congolese Franc',
      );

  /// Costa Rican Colón
  static CurrencyData get crc => CurrencyData.create(
        'CRC',
        2,
        symbol: '₡',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Costa Rica',
        unit: 'Colón',
        name: 'Costa Rican Colón',
      );

  /// Cuban Peso
  static CurrencyData get cup => CurrencyData.create(
        'CUP',
        2,
        country: 'Cuba',
        unit: 'Peso',
        name: 'Cuban Peso',
      );

  /// Czech Koruna
  static CurrencyData get czk => CurrencyData.create(
        'CZK',
        2,
        symbol: 'Kč',
        groupSeparator: '.',
        decimalSeparator: ',',
        pattern: '0.00S',
        country: 'Czech',
        unit: 'Koruna',
        name: 'Czech Koruna',
      );

  /// Danish Krone
  static CurrencyData get dkk => CurrencyData.create(
        'DKK',
        2,
        symbol: 'kr',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Denmark',
        unit: 'Krone',
        name: 'Danish Krone',
      );

  /// Djiboutian Franc
  static CurrencyData get djf => CurrencyData.create(
        'DJF',
        0,
        symbol: 'Fdj',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Djibouti',
        unit: 'Franc',
        name: 'Djiboutian Franc',
      );

  /// Dominican Peso
  static CurrencyData get dop => CurrencyData.create(
        'DOP',
        2,
        country: 'Dominican Republic',
        unit: 'Peso',
        name: 'Dominican Peso',
      );

  /// East Caribbean Dollar
  static CurrencyData get xcd => CurrencyData.create(
        'XCD',
        2,
        country: 'East Caribbean',
        unit: 'Dollar',
        name: 'East Caribbean Dollar',
      );

  /// Egyptian Pound
  static CurrencyData get egp => CurrencyData.create(
        'EGP',
        2,
        symbol: '£',
        country: 'Egypt',
        unit: 'Pound',
        name: 'Egyptian Pound',
      );

  /// Eritrean Nakfa
  static CurrencyData get ern => CurrencyData.create(
        'ERN',
        2,
        symbol: 'Nfk',
        country: 'Eritrea',
        unit: 'Nakfa',
        name: 'Eritrean Nakfa',
      );

  /// Ethiopian Birr
  static CurrencyData get etb => CurrencyData.create(
        'ETB',
        2,
        symbol: 'Br',
        country: 'Ethiopia',
        unit: 'Birr',
        name: 'Ethiopian Birr',
      );

  /// European Union Euro
  static CurrencyData get euro => CurrencyData.create(
        'EUR',
        2,
        symbol: '€',
        groupSeparator: '.',
        decimalSeparator: ',',
        pattern: '0.00S',
        country: 'European Union',
        unit: 'Euro',
        name: 'European Union Euro',
      );

  /// Falkland Islands Pound
  static CurrencyData get fkp => CurrencyData.create(
        'FKP',
        2,
        symbol: '£',
        country: 'Falkland Islands',
        unit: 'Pound',
        name: 'Falkland Islands Pound',
      );

  /// Fijian Dollar
  static CurrencyData get fjd => CurrencyData.create(
        'FJD',
        2,
        country: 'Fiji',
        unit: 'Dollar',
        name: 'Fijian Dollar',
      );

  /// Gambian Dalasi
  static CurrencyData get gmd => CurrencyData.create(
        'GMD',
        2,
        symbol: 'D',
        country: 'Gambia',
        unit: 'Dalasi',
        name: 'Gambian Dalasi',
      );

  /// Georgian Lari
  static CurrencyData get gel => CurrencyData.create(
        'GEL',
        2,
        symbol: '₾',
        pattern: 'S0,00',
        groupSeparator: ' ',
        decimalSeparator: ',',
        country: 'Georgia',
        unit: 'Lari',
        name: 'Georgian Lari',
      );

  /// Ghana Cedi
  static CurrencyData get ghs => CurrencyData.create(
        'GHS',
        2,
        symbol: '₵',
        country: 'Ghana',
        unit: 'Cedi',
        name: 'Ghana Cedi',
      );

  /// Gibraltar Pound
  static CurrencyData get gip => CurrencyData.create(
        'GIP',
        2,
        symbol: '£',
        country: 'Gibraltar',
        unit: 'Pound',
        name: 'Gibraltar Pound',
      );

  /// Guatemalan Quetzal
  static CurrencyData get gtq => CurrencyData.create(
        'GTQ',
        2,
        symbol: 'Q',
        country: 'Guatemala',
        unit: 'Quetzal',
        name: 'Guatemalan Quetzal',
      );

  /// Guinean Franc
  static CurrencyData get gnf => CurrencyData.create(
        'GNF',
        0,
        symbol: 'FG',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Guinea',
        unit: 'Franc',
        name: 'Guinean Franc',
      );

  /// Guyanese Dollar
  static CurrencyData get gyd => CurrencyData.create(
        'GYD',
        2,
        country: 'Guyana',
        unit: 'Dollar',
        name: 'Guyanese Dollar',
      );

  /// Haitian Gourde
  static CurrencyData get htg => CurrencyData.create(
        'HTG',
        2,
        symbol: 'G',
        country: 'Haiti',
        unit: 'Gourde',
        name: 'Haitian Gourde',
      );

  /// Honduran Lempira
  static CurrencyData get hnl => CurrencyData.create(
        'HNL',
        2,
        symbol: 'L',
        country: 'Honduras',
        unit: 'Lempira',
        name: 'Honduran Lempira',
      );

  /// Hong Kong Dollar
  static CurrencyData get hkd => CurrencyData.create(
        'HKD',
        2,
        country: 'Hong Kong',
        unit: 'Dollar',
        name: 'Hong Kong Dollar',
      );

  /// Hungarian Forint
  static CurrencyData get huf => CurrencyData.create(
        'HUF',
        0,
        symbol: 'Ft',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Hungary',
        unit: 'Forint',
        name: 'Hungarian Forint',
      );

  /// Icelandic Krona
  static CurrencyData get isk => CurrencyData.create(
        'ISK',
        0,
        symbol: 'kr',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Iceland',
        unit: 'Krona',
        name: 'Icelandic Krona',
      );

  /// Indian Rupee
  static CurrencyData get inr => CurrencyData.create(
        'INR',
        2,
        symbol: '₹',
        country: 'Indian',
        unit: 'Rupee',
        name: 'Indian Rupee',
      );

  /// Indonesian Rupiah
  static CurrencyData get idr => CurrencyData.create(
        'IDR',
        2,
        symbol: 'Rp',
        country: 'Indonesia',
        unit: 'Rupiah',
        name: 'Indonesian Rupiah',
      );

  /// Iranian Rial
  static CurrencyData get irr => CurrencyData.create(
        'IRR',
        2,
        symbol: '﷼',
        pattern: 'S0,00',
        country: 'Iran',
        unit: 'Rial',
        name: 'Iranian Rial',
      );

  /// Iraqi Dinar
  static CurrencyData get iqd => CurrencyData.create(
        'IQD',
        3,
        symbol: 'ع.د',
        pattern: '0.000S',
        country: 'Iraq',
        unit: 'Dinar',
        name: 'Iraqi Dinar',
      );

  /// Israeli New Shekel
  static CurrencyData get ils => CurrencyData.create(
        'ILS',
        2,
        symbol: '₪',
        country: 'Israel',
        unit: 'Shekel',
        name: 'Israeli New Shekel',
      );

  /// Jamaican Dollar
  static CurrencyData get jmd => CurrencyData.create(
        'JMD',
        2,
        country: 'Jamaica',
        unit: 'Dollar',
        name: 'Jamaican Dollar',
      );

  /// Japanese Yen
  static CurrencyData get jpy => CurrencyData.create(
        'JPY',
        0,
        symbol: '¥',
        pattern: 'S0',
        country: 'Japanese',
        unit: 'Yen',
        name: 'Japanese Yen',
      );

  /// Jordanian Dinar
  static CurrencyData get jod => CurrencyData.create(
        'JOD',
        3,
        symbol: 'د.ا',
        pattern: '0.000S',
        country: 'Jordan',
        unit: 'Dinar',
        name: 'Jordanian Dinar',
      );

  /// Kazakhstani Tenge
  static CurrencyData get kzt => CurrencyData.create(
        'KZT',
        2,
        symbol: '₸',
        country: 'Kazakhstan',
        unit: 'Tenge',
        name: 'Kazakhstani Tenge',
      );

  /// Kenyan Shilling
  static CurrencyData get kes => CurrencyData.create(
        'KES',
        2,
        symbol: 'KSh',
        country: 'Kenya',
        unit: 'Shilling',
        name: 'Kenyan Shilling',
      );

  /// Kuwaiti Dinar
  static CurrencyData get kwd => CurrencyData.create(
        'KWD',
        3,
        symbol: 'د.ك',
        pattern: '0.000S',
        country: 'Kuwait',
        unit: 'Dinar',
        name: 'Kuwaiti Dinar',
      );

  /// Kyrgyzstani Som
  static CurrencyData get kgs => CurrencyData.create(
        'KGS',
        2,
        symbol: 'с',
        country: 'Kyrgyzstan',
        unit: 'Som',
        name: 'Kyrgyzstani Som',
      );

  /// Lao Kip
  static CurrencyData get lak => CurrencyData.create(
        'LAK',
        2,
        symbol: '₭',
        country: 'Laos',
        unit: 'Kip',
        name: 'Lao Kip',
      );

  /// Lebanese Pound
  static CurrencyData get lbp => CurrencyData.create(
        'LBP',
        2,
        symbol: 'ل.ل',
        country: 'Lebanon',
        unit: 'Pound',
        name: 'Lebanese Pound',
      );

  /// Lesotho Loti
  static CurrencyData get lsl => CurrencyData.create(
        'LSL',
        2,
        symbol: 'L',
        country: 'Lesotho',
        unit: 'Loti',
        name: 'Lesotho Loti',
      );

  /// Liberian Dollar
  static CurrencyData get lrd => CurrencyData.create(
        'LRD',
        2,
        country: 'Liberia',
        unit: 'Dollar',
        name: 'Liberian Dollar',
      );

  /// Libyan Dinar
  static CurrencyData get lyd => CurrencyData.create(
        'LYD',
        3,
        symbol: 'ل.د',
        pattern: '0.000S',
        country: 'Libya',
        unit: 'Dinar',
        name: 'Libyan Dinar',
      );

  /// Macanese Pataca
  static CurrencyData get mop => CurrencyData.create(
        'MOP',
        2,
        symbol: r'MOP$',
        country: 'Macao',
        unit: 'Pataca',
        name: 'Macanese Pataca',
      );

  /// Macedonian Denar
  static CurrencyData get mkd => CurrencyData.create(
        'MKD',
        2,
        symbol: 'ден',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'North Macedonia',
        unit: 'Denar',
        name: 'Macedonian Denar',
      );

  /// Malagasy Ariary
  static CurrencyData get mga => CurrencyData.create(
        'MGA',
        2,
        symbol: 'Ar',
        country: 'Madagascar',
        unit: 'Ariary',
        name: 'Malagasy Ariary',
      );

  /// Malawian Kwacha
  static CurrencyData get mwk => CurrencyData.create(
        'MWK',
        2,
        symbol: 'MK',
        country: 'Malawi',
        unit: 'Kwacha',
        name: 'Malawian Kwacha',
      );

  /// Malaysian Ringgit
  static CurrencyData get myr => CurrencyData.create(
        'MYR',
        2,
        symbol: 'RM',
        country: 'Malaysia',
        unit: 'Ringgit',
        name: 'Malaysian Ringgit',
      );

  /// Maldivian Rufiyaa
  static CurrencyData get mvr => CurrencyData.create(
        'MVR',
        2,
        symbol: 'ރ.',
        country: 'Maldives',
        unit: 'Rufiyaa',
        name: 'Maldivian Rufiyaa',
      );

  /// Mauritanian Ouguiya
  static CurrencyData get mru => CurrencyData.create(
        'MRU',
        2,
        symbol: 'UM',
        country: 'Mauritania',
        unit: 'Ouguiya',
        name: 'Mauritanian Ouguiya',
      );

  /// Mauritian Rupee
  static CurrencyData get mur => CurrencyData.create(
        'MUR',
        2,
        symbol: '₨',
        country: 'Mauritius',
        unit: 'Rupee',
        name: 'Mauritian Rupee',
      );

  /// Mexican Peso
  static CurrencyData get mxn => CurrencyData.create(
        'MXN',
        2,
        country: 'Mexican',
        unit: 'Peso',
        name: 'Mexican Peso',
      );

  /// Moldovan Leu
  static CurrencyData get mdl => CurrencyData.create(
        'MDL',
        2,
        symbol: 'L',
        country: 'Moldova',
        unit: 'Leu',
        name: 'Moldovan Leu',
      );

  /// Mongolian Tugrik
  static CurrencyData get mnt => CurrencyData.create(
        'MNT',
        2,
        symbol: '₮',
        country: 'Mongolia',
        unit: 'Tugrik',
        name: 'Mongolian Tugrik',
      );

  /// Moroccan Dirham
  static CurrencyData get mad => CurrencyData.create(
        'MAD',
        2,
        symbol: 'د.م.',
        pattern: 'S0,00',
        groupSeparator: ' ',
        decimalSeparator: ',',
        country: 'Morocco',
        unit: 'Dirham',
        name: 'Moroccan Dirham',
      );

  /// Mozambican Metical
  static CurrencyData get mzn => CurrencyData.create(
        'MZN',
        2,
        symbol: 'MT',
        country: 'Mozambique',
        unit: 'Metical',
        name: 'Mozambican Metical',
      );

  /// Myanmar Kyat
  static CurrencyData get mmk => CurrencyData.create(
        'MMK',
        2,
        symbol: 'K',
        country: 'Myanmar (Burma)',
        unit: 'Kyat',
        name: 'Myanmar Kyat',
      );

  /// Namibian Dollar
  static CurrencyData get nad => CurrencyData.create(
        'NAD',
        2,
        country: 'Namibia',
        unit: 'Dollar',
        name: 'Namibian Dollar',
      );

  /// Nepalese Rupee
  static CurrencyData get npr => CurrencyData.create(
        'NPR',
        2,
        symbol: 'रू',
        country: 'Nepal',
        unit: 'Rupee',
        name: 'Nepalese Rupee',
      );

  /// Netherlands Antillean Guilder
  static CurrencyData get ang => CurrencyData.create(
        'ANG',
        2,
        symbol: 'ƒ',
        country: 'Curaçao and Sint Maarten',
        unit: 'Guilder',
        name: 'Netherlands Antillean Guilder',
      );

  /// New Taiwan Dollar
  static CurrencyData get twd => CurrencyData.create(
        'TWD',
        0,
        symbol: r'NT$',
        pattern: 'S0',
        country: 'New Taiwan',
        unit: 'Dollar',
        name: 'New Taiwan Dollar',
      );

  /// New Zealand Dollar
  static CurrencyData get nzd => CurrencyData.create(
        'NZD',
        2,
        country: 'New Zealand',
        unit: 'Dollar',
        name: 'New Zealand Dollar',
      );

  /// Nicaraguan Córdoba
  static CurrencyData get nio => CurrencyData.create(
        'NIO',
        2,
        symbol: r'C$',
        country: 'Nicaragua',
        unit: 'Córdoba',
        name: 'Nicaraguan Córdoba',
      );

  /// Nigerian Naira
  static CurrencyData get ngn => CurrencyData.create(
        'NGN',
        2,
        symbol: '₦',
        country: 'Nigerian',
        unit: 'Naira',
        name: 'Nigerian Naira',
      );

  /// North Korean Won
  static CurrencyData get kpw => CurrencyData.create(
        'KPW',
        2,
        symbol: '₩',
        country: 'North Korea',
        unit: 'Won',
        name: 'North Korean Won',
      );

  /// Norwegian Krone
  static CurrencyData get nok => CurrencyData.create(
        'NOK',
        2,
        symbol: 'kr',
        country: 'Norwegian',
        unit: 'Krone',
        name: 'Norwegian Krone',
      );

  /// Omani Rial
  static CurrencyData get omr => CurrencyData.create(
        'OMR',
        3,
        symbol: 'ر.ع.',
        pattern: '0.000S',
        country: 'Oman',
        unit: 'Rial',
        name: 'Omani Rial',
      );

  /// Pakistani Rupee
  static CurrencyData get pkr => CurrencyData.create(
        'PKR',
        2,
        symbol: '₨',
        country: 'Pakistan',
        unit: 'Rupee',
        name: 'Pakistani Rupee',
      );

  /// Panamanian Balboa
  static CurrencyData get pab => CurrencyData.create(
        'PAB',
        2,
        symbol: 'B/.',
        country: 'Panama',
        unit: 'Balboa',
        name: 'Panamanian Balboa',
      );

  /// Papua New Guinean Kina
  static CurrencyData get pgk => CurrencyData.create(
        'PGK',
        2,
        symbol: 'K',
        country: 'Papua New Guinea',
        unit: 'Kina',
        name: 'Papua New Guinean Kina',
      );

  /// Paraguayan Guarani
  static CurrencyData get pyg => CurrencyData.create(
        'PYG',
        0,
        symbol: '₲',
        pattern: 'S0',
        groupSeparator: '.',
        decimalSeparator: '',
        country: 'Paraguay',
        unit: 'Guarani',
        name: 'Paraguayan Guarani',
      );

  /// Peruvian Sol
  static CurrencyData get pen => CurrencyData.create(
        'PEN',
        2,
        symbol: 'S/.',
        country: 'Peru',
        unit: 'Sol',
        name: 'Peruvian Sol',
      );

  /// Philippine Peso
  static CurrencyData get php => CurrencyData.create(
        'PHP',
        2,
        symbol: '₱',
        country: 'Philippines',
        unit: 'Peso',
        name: 'Philippine Peso',
      );

  /// Polish Zloty
  static CurrencyData get pln => CurrencyData.create(
        'PLN',
        2,
        symbol: 'zł',
        groupSeparator: '.',
        decimalSeparator: ',',
        pattern: '0.00S',
        country: 'Polish',
        unit: 'Zloty',
        name: 'Polish Zloty',
      );

  /// Qatari Riyal
  static CurrencyData get qar => CurrencyData.create(
        'QAR',
        2,
        symbol: 'ر.ق',
        country: 'Qatar',
        unit: 'Riyal',
        name: 'Qatari Riyal',
      );

  /// Romanian Leu
  static CurrencyData get ron => CurrencyData.create(
        'RON',
        2,
        symbol: 'lei',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Romania',
        unit: 'Leu',
        name: 'Romanian Leu',
      );

  /// Russian Ruble
  static CurrencyData get rub => CurrencyData.create(
        'RUB',
        2,
        symbol: '₽',
        country: 'Russia',
        unit: 'Ruble',
        name: 'Russian Ruble',
      );

  /// Rwandan Franc
  static CurrencyData get rwf => CurrencyData.create(
        'RWF',
        0,
        symbol: 'RF',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Rwanda',
        unit: 'Franc',
        name: 'Rwandan Franc',
      );

  /// Saint Helena Pound
  static CurrencyData get shp => CurrencyData.create(
        'SHP',
        2,
        symbol: '£',
        country: 'Saint Helena',
        unit: 'Pound',
        name: 'Saint Helena Pound',
      );

  /// Samoan Tala
  static CurrencyData get wst => CurrencyData.create(
        'WST',
        2,
        symbol: r'WS$',
        country: 'Samoa',
        unit: 'Tala',
        name: 'Samoan Tala',
      );

  /// São Tomé and Príncipe Dobra
  static CurrencyData get stn => CurrencyData.create(
        'STN',
        2,
        symbol: 'Db',
        country: 'São Tomé and Príncipe',
        unit: 'Dobra',
        name: 'São Tomé and Príncipe Dobra',
      );

  /// Saudi Riyal
  static CurrencyData get sar => CurrencyData.create(
        'SAR',
        2,
        symbol: 'ر.س',
        country: 'Saudi Arabia',
        unit: 'Riyal',
        name: 'Saudi Riyal',
      );

  /// Serbian Dinar
  static CurrencyData get rsd => CurrencyData.create(
        'RSD',
        2,
        symbol: 'дин',
        pattern: 'S0,00',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Serbia',
        unit: 'Dinar',
        name: 'Serbian Dinar',
      );

  /// Seychellois Rupee
  static CurrencyData get scr => CurrencyData.create(
        'SCR',
        2,
        symbol: '₨',
        country: 'Seychelles',
        unit: 'Rupee',
        name: 'Seychellois Rupee',
      );

  /// Sierra Leonean Leone
  static CurrencyData get sle => CurrencyData.create(
        'SLE',
        2,
        symbol: 'Le',
        country: 'Sierra Leone',
        unit: 'Leone',
        name: 'Sierra Leonean Leone',
      );

  /// Singapore Dollar
  static CurrencyData get sgd => CurrencyData.create(
        'SGD',
        2,
        country: 'Singapore',
        unit: 'Dollar',
        name: 'Singapore Dollar',
      );

  /// Solomon Islands Dollar
  static CurrencyData get sbd => CurrencyData.create(
        'SBD',
        2,
        country: 'Solomon Islands',
        unit: 'Dollar',
        name: 'Solomon Islands Dollar',
      );

  /// Somali Shilling
  static CurrencyData get sos => CurrencyData.create(
        'SOS',
        2,
        symbol: 'Sh',
        country: 'Somalia',
        unit: 'Shilling',
        name: 'Somali Shilling',
      );

  /// South African Rand
  static CurrencyData get zar => CurrencyData.create(
        'ZAR',
        2,
        symbol: 'R',
        country: 'South African',
        unit: 'Rand',
        name: 'South African Rand',
      );

  /// South Korean Won
  static CurrencyData get krw => CurrencyData.create(
        'KRW',
        0,
        symbol: '₩',
        pattern: 'S0',
        country: 'South Korean',
        unit: 'Won',
        name: 'South Korean Won',
      );

  /// South Sudanese Pound
  static CurrencyData get ssp => CurrencyData.create(
        'SSP',
        2,
        symbol: '£',
        country: 'South Sudan',
        unit: 'Pound',
        name: 'South Sudanese Pound',
      );

  /// Sri Lankan Rupee
  static CurrencyData get lkr => CurrencyData.create(
        'LKR',
        2,
        symbol: 'Rs',
        country: 'Sri Lanka',
        unit: 'Rupee',
        name: 'Sri Lankan Rupee',
      );

  /// Sudanese Pound
  static CurrencyData get sdg => CurrencyData.create(
        'SDG',
        2,
        symbol: '£',
        country: 'Sudan',
        unit: 'Pound',
        name: 'Sudanese Pound',
      );

  /// Surinamese Dollar
  static CurrencyData get srd => CurrencyData.create(
        'SRD',
        2,
        country: 'Suriname',
        unit: 'Dollar',
        name: 'Surinamese Dollar',
      );

  /// Swazi Lilangeni
  static CurrencyData get szl => CurrencyData.create(
        'SZL',
        2,
        symbol: 'E',
        country: 'Eswatini',
        unit: 'Lilangeni',
        name: 'Swazi Lilangeni',
      );

  /// Swedish Krona
  static CurrencyData get sek => CurrencyData.create(
        'SEK',
        2,
        symbol: 'kr',
        pattern: 'S0,00',
        groupSeparator: ' ',
        decimalSeparator: ',',
        country: 'Sweden',
        unit: 'Krona',
        name: 'Swedish Krona',
      );

  /// Swiss Franc
  static CurrencyData get chf => CurrencyData.create(
        'CHF',
        2,
        symbol: 'fr',
        country: 'Switzerland',
        unit: 'Franc',
        name: 'Swiss Franc',
      );

  /// Syrian Pound
  static CurrencyData get syp => CurrencyData.create(
        'SYP',
        2,
        symbol: '£',
        country: 'Syria',
        unit: 'Pound',
        name: 'Syrian Pound',
      );

  /// Tajikistani Somoni
  static CurrencyData get tjs => CurrencyData.create(
        'TJS',
        2,
        symbol: 'ЅМ',
        country: 'Tajikistan',
        unit: 'Somoni',
        name: 'Tajikistani Somoni',
      );

  /// Tanzanian Shilling
  static CurrencyData get tzs => CurrencyData.create(
        'TZS',
        2,
        symbol: 'Sh',
        country: 'Tanzania',
        unit: 'Shilling',
        name: 'Tanzanian Shilling',
      );

  /// Thai Baht
  static CurrencyData get thb => CurrencyData.create(
        'THB',
        2,
        symbol: '฿',
        country: 'Thailand',
        unit: 'Baht',
        name: 'Thai Baht',
      );

  /// Tongan Paʻanga
  static CurrencyData get top => CurrencyData.create(
        'TOP',
        2,
        symbol: r'T$',
        country: 'Tonga',
        unit: 'Paʻanga',
        name: 'Tongan Paʻanga',
      );

  /// Trinidad and Tobago Dollar
  static CurrencyData get ttd => CurrencyData.create(
        'TTD',
        2,
        symbol: r'TT$',
        country: 'Trinidad and Tobago',
        unit: 'Dollar',
        name: 'Trinidad and Tobago Dollar',
      );

  /// Tunisian Dinar
  static CurrencyData get tnd => CurrencyData.create(
        'TND',
        3,
        symbol: 'د.ت',
        pattern: '0.000S',
        country: 'Tunisia',
        unit: 'Dinar',
        name: 'Tunisian Dinar',
      );

  /// Turkish Lira
  static CurrencyData get ltry => CurrencyData.create(
        'TRY',
        2,
        symbol: '₺',
        country: 'Turkish',
        unit: 'Lira',
        name: 'Turkish Lira',
      );

  /// Turkmenistani Manat
  static CurrencyData get tmt => CurrencyData.create(
        'TMT',
        2,
        symbol: 'm',
        country: 'Turkmenistan',
        unit: 'Manat',
        name: 'Turkmenistani Manat',
      );

  /// Ugandan Shilling
  static CurrencyData get ugx => CurrencyData.create(
        'UGX',
        0,
        symbol: 'USh',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Uganda',
        unit: 'Shilling',
        name: 'Ugandan Shilling',
      );

  /// Ukrainian Hryvnia
  static CurrencyData get uah => CurrencyData.create(
        'UAH',
        2,
        symbol: '₴',
        country: 'Ukraine',
        unit: 'Hryvnia',
        name: 'Ukrainian Hryvnia',
      );

  /// United Arab Emirates Dirham
  static CurrencyData get aed => CurrencyData.create(
        'AED',
        2,
        symbol: 'د.إ',
        country: 'United Arab Emirates',
        unit: 'Dirham',
        name: 'United Arab Emirates Dirham',
      );

  /// United States Dollar
  static CurrencyData get usd => CurrencyData.create(
        'USD',
        2,
        country: 'United States of America',
        unit: 'Dollar',
        name: 'United States Dollar',
      );

  /// Uruguayan Peso
  static CurrencyData get uyu => CurrencyData.create(
        'UYU',
        2,
        symbol: r'$U',
        country: 'Uruguay',
        unit: 'Peso',
        name: 'Uruguayan Peso',
      );

  /// Uzbekistani Som
  static CurrencyData get uzs => CurrencyData.create(
        'UZS',
        2,
        symbol: 'soʻm',
        country: 'Uzbekistan',
        unit: 'Som',
        name: 'Uzbekistani Som',
      );

  /// Vanuatu Vatu
  static CurrencyData get vuv => CurrencyData.create(
        'VUV',
        0,
        symbol: 'Vt',
        pattern: 'S0',
        decimalSeparator: '',
        country: 'Vanuatu',
        unit: 'Vatu',
        name: 'Vanuatu Vatu',
      );

  /// Venezuelan Bolívar
  static CurrencyData get ves => CurrencyData.create(
        'VES',
        2,
        symbol: 'Bs',
        groupSeparator: '.',
        decimalSeparator: ',',
        country: 'Venezuela',
        unit: 'Bolívar',
        name: 'Venezuelan Bolívar',
      );

  /// Vietnamese Dong
  static CurrencyData get vnd => CurrencyData.create(
        'VND',
        0,
        symbol: '₫',
        pattern: 'S0',
        groupSeparator: '.',
        decimalSeparator: '',
        country: 'Vietnam',
        unit: 'Dong',
        name: 'Vietnamese Dong',
      );

  /// West African CFA Franc
  static CurrencyData get xof => CurrencyData.create(
        'XOF',
        0,
        symbol: 'CFA',
        pattern: 'S0',
        groupSeparator: ' ',
        decimalSeparator: '',
        country: 'West African States',
        unit: 'Franc',
        name: 'West African CFA Franc',
      );

  /// Yemeni Rial
  static CurrencyData get yer => CurrencyData.create(
        'YER',
        2,
        symbol: '﷼',
        country: 'Yemen',
        unit: 'Rial',
        name: 'Yemeni Rial',
      );

  /// Zambian Kwacha
  static CurrencyData get zmw => CurrencyData.create(
        'ZMW',
        2,
        symbol: 'ZK',
        country: 'Zambia',
        unit: 'Kwacha',
        name: 'Zambian Kwacha',
      );

  /// Return list of all of the common CurrencyData.
  List<CurrencyData> asList() => [
        aed,
        afn,
        all,
        amd,
        ang,
        aoa,
        ars,
        aud,
        awg,
        azn,
        bam,
        bbd,
        bdt,
        bgn,
        bhd,
        bif,
        bmd,
        bnd,
        bob,
        brl,
        bsd,
        btc,
        btn,
        bwp,
        byn,
        bzd,
        cad,
        cdf,
        chf,
        clp,
        cny,
        cop,
        crc,
        cup,
        cve,
        czk,
        djf,
        dkk,
        dop,
        dzd,
        egp,
        ern,
        etb,
        euro,
        fjd,
        fkp,
        gbp,
        gel,
        ghs,
        gip,
        gmd,
        gnf,
        gtq,
        gyd,
        hnl,
        htg,
        huf,
        idr,
        ils,
        inr,
        iqd,
        irr,
        isk,
        jmd,
        jod,
        jpy,
        kes,
        kgs,
        khr,
        kmf,
        kpw,
        krw,
        kwd,
        kyd,
        kzt,
        lak,
        lbp,
        lkr,
        lrd,
        lsl,
        ltry,
        lyd,
        mad,
        mdl,
        mga,
        mkd,
        mmk,
        mnt,
        mop,
        mru,
        mur,
        mvr,
        mwk,
        mxn,
        myr,
        mzn,
        nad,
        ngn,
        nio,
        nok,
        npr,
        nzd,
        omr,
        pab,
        pen,
        pgk,
        php,
        pkr,
        pln,
        pyg,
        qar,
        ron,
        rsd,
        rub,
        rwf,
        sar,
        sbd,
        scr,
        sdg,
        sek,
        sgd,
        shp,
        sle,
        sos,
        srd,
        ssp,
        stn,
        syp,
        szl,
        thb,
        tjs,
        tmt,
        tnd,
        top,
        ttd,
        twd,
        tzs,
        uah,
        ugx,
        usd,
        uyu,
        uzs,
        ves,
        vnd,
        vuv,
        wst,
        xaf,
        xcd,
        xof,
        xpf,
        yer,
        zar,
        zmw,
      ];
}
