class CurrencyService {
  CurrencyService._();

  static const String snapshotDate = '2026-10-21';

  static const Map<String, double> rates = {
    'NGN': 1.0,
    'USD': 1334.99,
    'GBP': 1780.87,
    'EUR': 1498.73,
    'CAD': 949.46,
    'AUD': 934.45,
    'AED': 363.51,
    'CNY': 199.51,
    'ZAR': 81.42,
    'GHS': 114.55,
    'CHF': 1617.53,
    'JPY': 8.44,
    'SAR': 356.00,
    'INR': 14.10,
    'KES': 10.30,
    'UGX': 0.36,
    'TZS': 0.52,
    'XOF': 2.28,
    'XAF': 2.28,
    'EGP': 27.20,
  };

  static const Map<String, String> symbols = {
    'NGN': '₦',
    'USD': r'$',
    'GBP': '£',
    'EUR': '€',
    'CAD': r'CA$',
    'AUD': r'A$',
    'AED': 'د.إ',
    'CNY': '¥',
    'ZAR': 'R',
    'GHS': 'GH₵',
    'CHF': 'CHF ',
    'JPY': '¥',
    'SAR': 'ر.س',
    'INR': '₹',
    'KES': 'KSh ',
    'UGX': 'USh ',
    'TZS': 'TSh ',
    'XOF': 'CFA ',
    'XAF': 'FCFA ',
    'EGP': 'E£',
    'AFN': '؋',
    'ALL': 'L',
    'AMD': '֏',
    'ANG': 'NAƒ',
    'AOA': 'Kz',
    'ARS': r'$',
    'AWG': 'ƒ',
    'AZN': '₼',
    'BAM': 'KM',
    'BBD': r'$',
    'BDT': '৳',
    'BGN': 'лв',
    'BHD': '.د.ب',
    'BIF': 'FBu',
    'BMD': r'$',
    'BND': r'B$',
    'BOB': 'Bs.',
    'BRL': r'R$',
    'BSD': r'$',
    'BTN': 'Nu.',
    'BWP': 'P',
    'BYN': 'Br',
    'BZD': r'BZ$',
    'CDF': 'FC',
    'CLP': r'$',
    'COP': r'$',
    'CRC': '₡',
    'CUP': r'$',
    'CVE': r'$',
    'CZK': 'Kč',
    'DJF': 'Fdj',
    'DKK': 'kr',
    'DOP': r'RD$',
    'DZD': 'د.ج',
    'ERN': 'Nfk',
    'ETB': 'Br',
    'FJD': r'FJ$',
    'FKP': '£',
    'GEL': '₾',
    'GMD': 'D',
    'GNF': 'FG',
    'GTQ': 'Q',
    'GYD': r'$',
    'HKD': r'HK$',
    'HNL': 'L',
    'HTG': 'G',
    'HUF': 'Ft',
    'IDR': 'Rp',
    'ILS': '₪',
    'IQD': 'ع.د',
    'IRR': '﷼',
    'ISK': 'kr',
    'JMD': r'J$',
    'JOD': 'د.ا',
    'KGS': 'с',
    'KHR': '៛',
    'KMF': 'CF',
    'KPW': '₩',
    'KRW': '₩',
    'KWD': 'د.ك',
    'KYD': r'$',
    'KZT': '₸',
    'LAK': '₭',
    'LBP': 'ل.ل',
    'LKR': 'Rs',
    'LRD': r'L$',
    'LSL': 'L',
    'LYD': 'ل.د',
    'MAD': 'د.م.',
    'MDL': 'L',
    'MGA': 'Ar',
    'MKD': 'ден',
    'MMK': 'K',
    'MNT': '₮',
    'MOP': r'MOP$',
    'MRU': 'UM',
    'MUR': '₨',
    'MVR': 'Rf',
    'MWK': 'MK',
    'MXN': r'MX$',
    'MYR': 'RM',
    'MZN': 'MT',
    'NAD': r'N$',
    'NIO': r'C$',
    'NOK': 'kr',
    'NPR': 'रू',
    'NZD': r'NZ$',
    'OMR': 'ر.ع.',
    'PAB': 'B/.',
    'PEN': 'S/',
    'PGK': 'K',
    'PHP': '₱',
    'PKR': '₨',
    'PLN': 'zł',
    'PYG': '₲',
    'QAR': 'ر.ق',
    'RON': 'lei',
    'RSD': 'дин.',
    'RUB': '₽',
    'RWF': 'FRw',
    'SBD': r'SI$',
    'SCR': '₨',
    'SDG': 'ج.س.',
    'SEK': 'kr',
    'SGD': r'S$',
    'SHP': '£',
    'SLE': 'Le',
    'SOS': 'Sh',
    'SRD': r'SR$',
    'SSP': '£',
    'STN': 'Db',
    'SYP': '£',
    'SZL': 'L',
    'THB': '฿',
    'TJS': 'ЅМ',
    'TMT': 'm',
    'TOP': r'T$',
    'TRY': '₺',
    'TTD': r'TT$',
    'TWD': r'NT$',
    'UAH': '₴',
    'UYU': r'$U',
    'UZS': 'soʻm',
    'VES': 'Bs.',
    'VND': '₫',
    'VUV': 'VT',
    'WST': 'T',
    'XCD': r'EC$',
    'XPF': '₣',
    'YER': '﷼',
    'ZMW': 'ZK',
    'ZWG': 'ZiG',
  };

  static const String _countryNames = '''
AD|Andorra
AE|United Arab Emirates
AF|Afghanistan
AG|Antigua and Barbuda
AI|Anguilla
AL|Albania
AM|Armenia
AO|Angola
AQ|Antarctica
AR|Argentina
AS|American Samoa
AT|Austria
AU|Australia
AW|Aruba
AX|Åland Islands
AZ|Azerbaijan
BA|Bosnia and Herzegovina
BB|Barbados
BD|Bangladesh
BE|Belgium
BF|Burkina Faso
BG|Bulgaria
BH|Bahrain
BI|Burundi
BJ|Benin
BL|Saint Barthélemy
BM|Bermuda
BN|Brunei
BO|Bolivia
BQ|Caribbean Netherlands
BR|Brazil
BS|Bahamas
BT|Bhutan
BV|Bouvet Island
BW|Botswana
BY|Belarus
BZ|Belize
CA|Canada
CC|Cocos (Keeling) Islands
CD|Democratic Republic of the Congo
CF|Central African Republic
CG|Republic of the Congo
CH|Switzerland
CI|Ivory Coast
CK|Cook Islands
CL|Chile
CM|Cameroon
CN|China
CO|Colombia
CR|Costa Rica
CU|Cuba
CV|Cape Verde
CW|Curaçao
CX|Christmas Island
CY|Cyprus
CZ|Czechia
DE|Germany
DJ|Djibouti
DK|Denmark
DM|Dominica
DO|Dominican Republic
DZ|Algeria
EC|Ecuador
EE|Estonia
EG|Egypt
EH|Western Sahara
ER|Eritrea
ES|Spain
ET|Ethiopia
FI|Finland
FJ|Fiji
FK|Falkland Islands
FM|Micronesia
FO|Faroe Islands
FR|France
GA|Gabon
GB|United Kingdom
GD|Grenada
GE|Georgia
GF|French Guiana
GG|Guernsey
GH|Ghana
GI|Gibraltar
GL|Greenland
GM|The Gambia
GN|Guinea
GP|Guadeloupe
GQ|Equatorial Guinea
GR|Greece
GS|South Georgia and the South Sandwich Islands
GT|Guatemala
GU|Guam
GW|Guinea-Bissau
GY|Guyana
HK|Hong Kong
HM|Heard Island and McDonald Islands
HN|Honduras
HR|Croatia
HT|Haiti
HU|Hungary
ID|Indonesia
IE|Ireland
IL|Israel
IM|Isle of Man
IN|India
IO|British Indian Ocean Territory
IQ|Iraq
IR|Iran
IS|Iceland
IT|Italy
JE|Jersey
JM|Jamaica
JO|Jordan
JP|Japan
KE|Kenya
KG|Kyrgyzstan
KH|Cambodia
KI|Kiribati
KM|Comoros
KN|Saint Kitts and Nevis
KP|North Korea
KR|South Korea
KW|Kuwait
KY|Cayman Islands
KZ|Kazakhstan
LA|Laos
LB|Lebanon
LC|Saint Lucia
LI|Liechtenstein
LK|Sri Lanka
LR|Liberia
LS|Lesotho
LT|Lithuania
LU|Luxembourg
LV|Latvia
LY|Libya
MA|Morocco
MC|Monaco
MD|Moldova
ME|Montenegro
MF|Saint Martin
MG|Madagascar
MH|Marshall Islands
MK|North Macedonia
ML|Mali
MM|Myanmar
MN|Mongolia
MO|Macao
MP|Northern Mariana Islands
MQ|Martinique
MR|Mauritania
MS|Montserrat
MT|Malta
MU|Mauritius
MV|Maldives
MW|Malawi
MX|Mexico
MY|Malaysia
MZ|Mozambique
NA|Namibia
NC|New Caledonia
NE|Niger
NF|Norfolk Island
NG|Nigeria
NI|Nicaragua
NL|Netherlands
NO|Norway
NP|Nepal
NR|Nauru
NU|Niue
NZ|New Zealand
OM|Oman
PA|Panama
PE|Peru
PF|French Polynesia
PG|Papua New Guinea
PH|Philippines
PK|Pakistan
PL|Poland
PM|Saint Pierre and Miquelon
PN|Pitcairn Islands
PR|Puerto Rico
PS|Palestine
PT|Portugal
PW|Palau
PY|Paraguay
QA|Qatar
RE|Réunion
RO|Romania
RS|Serbia
RU|Russia
RW|Rwanda
SA|Saudi Arabia
SB|Solomon Islands
SC|Seychelles
SD|Sudan
SE|Sweden
SG|Singapore
SH|Saint Helena
SI|Slovenia
SJ|Svalbard and Jan Mayen
SK|Slovakia
SL|Sierra Leone
SM|San Marino
SN|Senegal
SO|Somalia
SR|Suriname
SS|South Sudan
ST|São Tomé and Príncipe
SV|El Salvador
SX|Sint Maarten
SY|Syria
SZ|Eswatini
TC|Turks and Caicos Islands
TD|Chad
TF|French Southern Territories
TG|Togo
TH|Thailand
TJ|Tajikistan
TK|Tokelau
TL|Timor-Leste
TM|Turkmenistan
TN|Tunisia
TO|Tonga
TR|Türkiye
TT|Trinidad and Tobago
TV|Tuvalu
TW|Taiwan
TZ|Tanzania
UA|Ukraine
UG|Uganda
UM|United States Minor Outlying Islands
US|United States
UY|Uruguay
UZ|Uzbekistan
VA|Vatican City
VC|Saint Vincent and the Grenadines
VE|Venezuela
VG|British Virgin Islands
VI|United States Virgin Islands
VN|Vietnam
VU|Vanuatu
WF|Wallis and Futuna
WS|Samoa
XK|Kosovo
YE|Yemen
YT|Mayotte
ZA|South Africa
ZM|Zambia
ZW|Zimbabwe
AC|Ascension Island
''';

  static const Map<String, String> countryCurrencyByCode = {
    'AD': 'EUR',
    'AE': 'AED',
    'AF': 'AFN',
    'AG': 'XCD',
    'AI': 'XCD',
    'AL': 'ALL',
    'AM': 'AMD',
    'AO': 'AOA',
    'AR': 'ARS',
    'AS': 'USD',
    'AT': 'EUR',
    'AU': 'AUD',
    'AW': 'AWG',
    'AX': 'EUR',
    'AZ': 'AZN',
    'BA': 'BAM',
    'BB': 'BBD',
    'BD': 'BDT',
    'BE': 'EUR',
    'BF': 'XOF',
    'BG': 'BGN',
    'BH': 'BHD',
    'BI': 'BIF',
    'BJ': 'XOF',
    'BL': 'EUR',
    'BM': 'BMD',
    'BN': 'BND',
    'BO': 'BOB',
    'BQ': 'USD',
    'BR': 'BRL',
    'BS': 'BSD',
    'BT': 'BTN',
    'BW': 'BWP',
    'BY': 'BYN',
    'BZ': 'BZD',
    'CA': 'CAD',
    'CC': 'AUD',
    'CD': 'CDF',
    'CF': 'XAF',
    'CG': 'XAF',
    'CH': 'CHF',
    'CI': 'XOF',
    'CK': 'NZD',
    'CL': 'CLP',
    'CM': 'XAF',
    'CN': 'CNY',
    'CO': 'COP',
    'CR': 'CRC',
    'CU': 'CUP',
    'CV': 'CVE',
    'CW': 'ANG',
    'CX': 'AUD',
    'CY': 'EUR',
    'CZ': 'CZK',
    'DE': 'EUR',
    'DJ': 'DJF',
    'DK': 'DKK',
    'DM': 'XCD',
    'DO': 'DOP',
    'DZ': 'DZD',
    'EC': 'USD',
    'EE': 'EUR',
    'EG': 'EGP',
    'EH': 'MAD',
    'ER': 'ERN',
    'ES': 'EUR',
    'ET': 'ETB',
    'FI': 'EUR',
    'FJ': 'FJD',
    'FK': 'FKP',
    'FM': 'USD',
    'FO': 'DKK',
    'FR': 'EUR',
    'GA': 'XAF',
    'GB': 'GBP',
    'GD': 'XCD',
    'GE': 'GEL',
    'GF': 'EUR',
    'GG': 'GBP',
    'GH': 'GHS',
    'GI': 'GBP',
    'GL': 'DKK',
    'GM': 'GMD',
    'GN': 'GNF',
    'GP': 'EUR',
    'GQ': 'XAF',
    'GR': 'EUR',
    'GS': 'GBP',
    'GT': 'GTQ',
    'GU': 'USD',
    'GW': 'XOF',
    'GY': 'GYD',
    'HK': 'HKD',
    'HM': 'AUD',
    'HN': 'HNL',
    'HR': 'EUR',
    'HT': 'HTG',
    'HU': 'HUF',
    'ID': 'IDR',
    'IE': 'EUR',
    'IL': 'ILS',
    'IM': 'GBP',
    'IN': 'INR',
    'IO': 'USD',
    'IQ': 'IQD',
    'IR': 'IRR',
    'IS': 'ISK',
    'IT': 'EUR',
    'JE': 'GBP',
    'JM': 'JMD',
    'JO': 'JOD',
    'JP': 'JPY',
    'KE': 'KES',
    'KG': 'KGS',
    'KH': 'KHR',
    'KI': 'AUD',
    'KM': 'KMF',
    'KN': 'XCD',
    'KP': 'KPW',
    'KR': 'KRW',
    'KW': 'KWD',
    'KY': 'KYD',
    'KZ': 'KZT',
    'LA': 'LAK',
    'LB': 'LBP',
    'LC': 'XCD',
    'LI': 'CHF',
    'LK': 'LKR',
    'LR': 'LRD',
    'LS': 'LSL',
    'LT': 'EUR',
    'LU': 'EUR',
    'LV': 'EUR',
    'LY': 'LYD',
    'MA': 'MAD',
    'MC': 'EUR',
    'MD': 'MDL',
    'ME': 'EUR',
    'MF': 'EUR',
    'MG': 'MGA',
    'MH': 'USD',
    'MK': 'MKD',
    'ML': 'XOF',
    'MM': 'MMK',
    'MN': 'MNT',
    'MO': 'MOP',
    'MP': 'USD',
    'MQ': 'EUR',
    'MR': 'MRU',
    'MS': 'XCD',
    'MT': 'EUR',
    'MU': 'MUR',
    'MV': 'MVR',
    'MW': 'MWK',
    'MX': 'MXN',
    'MY': 'MYR',
    'MZ': 'MZN',
    'NA': 'NAD',
    'NC': 'XPF',
    'NE': 'XOF',
    'NF': 'AUD',
    'NG': 'NGN',
    'NI': 'NIO',
    'NL': 'EUR',
    'NO': 'NOK',
    'NP': 'NPR',
    'NR': 'AUD',
    'NU': 'NZD',
    'NZ': 'NZD',
    'OM': 'OMR',
    'PA': 'PAB',
    'PE': 'PEN',
    'PF': 'XPF',
    'PG': 'PGK',
    'PH': 'PHP',
    'PK': 'PKR',
    'PL': 'PLN',
    'PM': 'EUR',
    'PN': 'NZD',
    'PR': 'USD',
    'PS': 'ILS',
    'PT': 'EUR',
    'PW': 'USD',
    'PY': 'PYG',
    'QA': 'QAR',
    'RE': 'EUR',
    'RO': 'RON',
    'RS': 'RSD',
    'RU': 'RUB',
    'RW': 'RWF',
    'SA': 'SAR',
    'SB': 'SBD',
    'SC': 'SCR',
    'SD': 'SDG',
    'SE': 'SEK',
    'SG': 'SGD',
    'SH': 'SHP',
    'SI': 'EUR',
    'SK': 'EUR',
    'SL': 'SLE',
    'SM': 'EUR',
    'SN': 'XOF',
    'SO': 'SOS',
    'SR': 'SRD',
    'SS': 'SSP',
    'ST': 'STN',
    'SV': 'USD',
    'SX': 'ANG',
    'SY': 'SYP',
    'SZ': 'SZL',
    'TC': 'USD',
    'TD': 'XAF',
    'TG': 'XOF',
    'TH': 'THB',
    'TJ': 'TJS',
    'TK': 'NZD',
    'TL': 'USD',
    'TM': 'TMT',
    'TN': 'TND',
    'TO': 'TOP',
    'TR': 'TRY',
    'TT': 'TTD',
    'TV': 'AUD',
    'TW': 'TWD',
    'TZ': 'TZS',
    'UA': 'UAH',
    'UG': 'UGX',
    'UM': 'USD',
    'US': 'USD',
    'UY': 'UYU',
    'UZ': 'UZS',
    'VA': 'EUR',
    'VC': 'XCD',
    'VE': 'VES',
    'VG': 'USD',
    'VI': 'USD',
    'VN': 'VND',
    'VU': 'VUV',
    'WF': 'XPF',
    'WS': 'WST',
    'XK': 'EUR',
    'YE': 'YER',
    'YT': 'EUR',
    'ZA': 'ZAR',
    'ZM': 'ZMW',
    'ZW': 'ZWG',
    'AC': 'SHP',
  };

  static Map<String, String> _parseCountryNames() => {
        for (final line in _countryNames.trim().split('\n'))
          line.split('|')[1]: line.split('|')[0],
      };

  static final Map<String, String> countryNameToCode = _parseCountryNames();

  static final Map<String, String> countryDefaults = {
    for (final entry in countryNameToCode.entries)
      entry.key: countryCurrencyByCode[entry.value] ?? 'USD',
  };

  static final List<String> countries = () {
    final remaining = countryDefaults.keys.toList()
      ..remove('United States')
      ..remove('Nigeria')
      ..sort();
    return ['United States', 'Nigeria', ...remaining];
  }();

  static final List<String> supportedCurrencies = () {
    final remaining = countryDefaults.values.toSet()
      ..remove('USD')
      ..remove('NGN');
    final sortedRemaining = remaining.toList()..sort();
    return ['USD', 'NGN', ...sortedRemaining];
  }();

  static String currentCurrencyCode = 'USD';

  static double usdReferenceRate() => rates['USD'] ?? 1.0;

  static double selectedCurrencyUnitsPerUsd(String currencyCode) {
    final key = currencyCode.toUpperCase();
    final usdRate = usdReferenceRate();
    final selectedRate = rates[key] ?? usdRate;
    return usdRate / selectedRate;
  }

  static double convertUsdToCurrency(double usdAmount, String currencyCode) {
    final code = (currencyCode.isEmpty ? 'USD' : currencyCode).toUpperCase();
    if (code == 'USD') return usdAmount;
    return usdAmount * selectedCurrencyUnitsPerUsd(code);
  }

  static double convertCurrencyToUsd(double amount, String currencyCode) {
    final code = (currencyCode.isEmpty ? 'USD' : currencyCode).toUpperCase();
    if (code == 'USD') return amount;
    final unitsPerUsd = selectedCurrencyUnitsPerUsd(code);
    return amount / unitsPerUsd;
  }

  static double convertUsdCentsToCurrency(int usdCents, String currencyCode) {
    return convertUsdToCurrency(usdCents / 100, currencyCode);
  }

  static int convertCurrencyToUsdCents(num amount, String currencyCode) {
    return (convertCurrencyToUsd(amount.toDouble(), currencyCode) * 100)
        .round();
  }

  static String formatAmount(num amount, String currencyCode) {
    final sign = amount < 0 ? '-' : '';
    final absValue = amount.abs();
    final normalizedCode = currencyCode.toUpperCase();
    final symbol = symbols[normalizedCode] ?? '$normalizedCode ';

    if (absValue < 1) {
      return '$sign$symbol${absValue.toStringAsFixed(2)}';
    }

    final asString = absValue.toStringAsFixed(absValue % 1 == 0 ? 0 : 2);
    final parts = asString.split('.');
    final integerPart = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );

    if (parts.length == 1) {
      return '$sign$symbol$integerPart';
    }

    final decimalPart = parts[1].replaceFirst(RegExp(r'0+$'), '');
    if (decimalPart.isEmpty) {
      return '$sign$symbol$integerPart';
    }
    return '$sign$symbol$integerPart.$decimalPart';
  }
}
