/// All 64 server-country flags — keys match the Figma "Country" variant
/// names. Filenames follow the app's existing `assets/images/flags/` set
/// (some have spaces, unlike the design prototype's PascalCase copies).
class AppFlags {
  AppFlags._();
  static const _base = 'assets/images/flags';

  static const auto = '$_base/auto.svg';
  static const argentina = '$_base/Argentina.svg';
  static const armenia = '$_base/Armenia.svg';
  static const australia = '$_base/Australia.svg';
  static const austria = '$_base/Austria.svg';
  static const belarus = '$_base/Belarus.svg';
  static const belgium = '$_base/Belgium.svg';
  static const bulgaria = '$_base/Bolgaria.svg';
  static const brazil = '$_base/Brazil.svg';
  static const britain = '$_base/Britan.svg';
  static const cambodia = '$_base/Cambodia.svg';
  static const canada = '$_base/Canada.svg';
  static const chile = '$_base/Chilie.svg';
  static const china = '$_base/China.svg';
  static const croatia = '$_base/Croatia.svg';
  static const cuba = '$_base/Cuba.svg';
  static const czech = '$_base/Czech.svg';
  static const denmark = '$_base/Denmark.svg';
  static const estonia = '$_base/Estonia.svg';
  static const finland = '$_base/Finland.svg';
  static const france = '$_base/France.svg';
  static const georgia = '$_base/Georgia.svg';
  static const germany = '$_base/Germany.svg';
  static const greece = '$_base/Greece.svg';
  static const guinea = '$_base/Guinea.svg';
  static const hongKong = '$_base/Hong Kong.svg';
  static const hungary = '$_base/Hungary.svg';
  static const india = '$_base/India.svg';
  static const indonesia = '$_base/Indonesia.svg';
  static const ireland = '$_base/Ireland.svg';
  static const israel = '$_base/Israel.svg';
  static const italy = '$_base/Italy.svg';
  static const japan = '$_base/Japan.svg';
  static const kazakhstan = '$_base/Kazahstan.svg';
  static const latvia = '$_base/Latvia.svg';
  static const lithuania = '$_base/Lithuania.svg';
  static const malaysia = '$_base/Malaysia.svg';
  static const mexico = '$_base/Mexico.svg';
  static const mongolia = '$_base/Mongolia.svg';
  static const montenegro = '$_base/Montenegro.svg';
  static const nepal = '$_base/Nepal.svg';
  static const netherlands = '$_base/Netherlands.svg';
  static const newZealand = '$_base/New Zealand.svg';
  static const norway = '$_base/Norway.svg';
  static const pakistan = '$_base/Pakistan.svg';
  static const poland = '$_base/Poland.svg';
  static const portugal = '$_base/Portugal.svg';
  static const romania = '$_base/Romany.svg';
  static const russia = '$_base/Russia.svg';
  static const saudiArabia = '$_base/Saudi Arabia.svg';
  static const serbia = '$_base/Serbia.svg';
  static const singapore = '$_base/Singapur.svg';
  static const southAfrica = '$_base/South Africa.svg';
  static const southKorea = '$_base/South Korea.svg';
  static const spain = '$_base/Spain.svg';
  static const sweden = '$_base/Sweden.svg';
  static const switzerland = '$_base/Swiss.svg';
  static const thailand = '$_base/Thailand.svg';
  static const tunisia = '$_base/Tunisia.svg';
  static const turkey = '$_base/Turkey.svg';
  static const usa = '$_base/USA.svg';
  static const ukraine = '$_base/Ukraine.svg';
  static const unitedArabEmirates = '$_base/United Arab Emirates.svg';
  static const vietnam = '$_base/Vietnam.svg';

  /// Localized display name -> asset path, for the server list / search.
  static const Map<String, String> byRussianName = {
    'Автовыбор': auto,
    'Аргентина': argentina,
    'Армения': armenia,
    'Австралия': australia,
    'Австрия': austria,
    'Беларусь': belarus,
    'Бельгия': belgium,
    'Болгария': bulgaria,
    'Бразилия': brazil,
    'Великобритания': britain,
    'Камбоджа': cambodia,
    'Канада': canada,
    'Чили': chile,
    'Китай': china,
    'Хорватия': croatia,
    'Куба': cuba,
    'Чехия': czech,
    'Дания': denmark,
    'Эстония': estonia,
    'Финляндия': finland,
    'Франция': france,
    'Грузия': georgia,
    'Германия': germany,
    'Греция': greece,
    'Гвинея': guinea,
    'Гонконг': hongKong,
    'Венгрия': hungary,
    'Индия': india,
    'Индонезия': indonesia,
    'Ирландия': ireland,
    'Израиль': israel,
    'Италия': italy,
    'Япония': japan,
    'Казахстан': kazakhstan,
    'Латвия': latvia,
    'Литва': lithuania,
    'Малайзия': malaysia,
    'Мексика': mexico,
    'Монголия': mongolia,
    'Черногория': montenegro,
    'Непал': nepal,
    'Нидерланды': netherlands,
    'Новая Зеландия': newZealand,
    'Норвегия': norway,
    'Пакистан': pakistan,
    'Польша': poland,
    'Португалия': portugal,
    'Румыния': romania,
    'Россия': russia,
    'Саудовская Аравия': saudiArabia,
    'Сербия': serbia,
    'Сингапур': singapore,
    'ЮАР': southAfrica,
    'Южная Корея': southKorea,
    'Испания': spain,
    'Швеция': sweden,
    'Швейцария': switzerland,
    'Таиланд': thailand,
    'Тунис': tunisia,
    'Турция': turkey,
    'США': usa,
    'Украина': ukraine,
    'ОАЭ': unitedArabEmirates,
    'Вьетнам': vietnam,
  };

  /// ISO 3166-1 alpha-2 -> asset path, for models keyed by country code
  /// (e.g. `Server.flagCode` in `models/server.dart`).
  static const Map<String, String> byIsoCode = {
    'AR': argentina,
    'AM': armenia,
    'AU': australia,
    'AT': austria,
    'BY': belarus,
    'BE': belgium,
    'BG': bulgaria,
    'BR': brazil,
    'GB': britain,
    'KH': cambodia,
    'CA': canada,
    'CL': chile,
    'CN': china,
    'HR': croatia,
    'CU': cuba,
    'CZ': czech,
    'DK': denmark,
    'EE': estonia,
    'FI': finland,
    'FR': france,
    'GE': georgia,
    'DE': germany,
    'GR': greece,
    'GN': guinea,
    'HK': hongKong,
    'HU': hungary,
    'IN': india,
    'ID': indonesia,
    'IE': ireland,
    'IL': israel,
    'IT': italy,
    'JP': japan,
    'KZ': kazakhstan,
    'LV': latvia,
    'LT': lithuania,
    'MY': malaysia,
    'MX': mexico,
    'MN': mongolia,
    'ME': montenegro,
    'NP': nepal,
    'NL': netherlands,
    'NZ': newZealand,
    'NO': norway,
    'PK': pakistan,
    'PL': poland,
    'PT': portugal,
    'RO': romania,
    'RU': russia,
    'SA': saudiArabia,
    'RS': serbia,
    'SG': singapore,
    'ZA': southAfrica,
    'KR': southKorea,
    'ES': spain,
    'SE': sweden,
    'CH': switzerland,
    'TH': thailand,
    'TN': tunisia,
    'TR': turkey,
    'US': usa,
    'UA': ukraine,
    'AE': unitedArabEmirates,
    'VN': vietnam,
  };

  /// Looks up a flag by ISO code, case-insensitively; `null`/unknown codes
  /// fall back to [auto].
  static String forIsoCode(String? code) =>
      byIsoCode[code?.toUpperCase()] ?? auto;
}
