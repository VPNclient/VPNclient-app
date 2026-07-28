import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../design/app_theme.dart';
import '../../design/payment_icons.dart';

// Subscription purchase flow (Settings → "Продлить подписку"), per Figma
// Subscribe / Payment-Method / Pay / Succes-* frames: plan picker → payment
// summary with promo code → payment method picker → card entry → success.
class SubscribeSheet extends StatefulWidget {
  const SubscribeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubscribeSheet(),
    );
  }

  @override
  State<SubscribeSheet> createState() => _SubscribeSheetState();
}

const _accentGradient = AppColors.brandGradient;
const _primaryText = AppColors.fg1;
const _muted = AppColors.fg2;

class _Plan {
  final int months;
  final String label;
  final String perMonth;
  final int price;
  final int? originalPrice;
  const _Plan({
    required this.months,
    required this.label,
    required this.perMonth,
    required this.price,
    this.originalPrice,
  });
}

const _plans = [
  _Plan(months: 3, label: '3 месяца', perMonth: '299 ₽ в месяц', price: 897),
  _Plan(
    months: 12,
    label: '12 месяцев',
    perMonth: '195 ₽ в месяц',
    price: 2337,
    originalPrice: 3588,
  ),
];

// TODO(payment-icons): Sber Pay / T-Bank Pay / ЮMoney / QR-код have no
// exported bitmap in the Figma file (their Property1* components are built
// from raw vector paths, not a packaged asset) — only Visa/Mastercard/Mir/
// СБП/crypto had a real Vector.svg to copy. To finish these, re-export each
// missing logo from Figma as SVG (select the component → Export → SVG),
// drop it in assets/images/payment/, and add its path here the same way
// 'assets/images/payment/mir.svg' is wired below.
const _ruMethods = [
  ('Карта рубли', PaymentIcons.card),
  ('МИР', PaymentIcons.mir),
  ('СБП', PaymentIcons.sbp),
  ('Sber Pay', PaymentIcons.sber),
  ('T-Bank Pay', PaymentIcons.tBank),
  ('ЮMoney', PaymentIcons.yandex),
  ('QR-код рубли', PaymentIcons.qr),
];
const _euMethods = [
  ('Карта евро', PaymentIcons.card),
  ('QR евро', PaymentIcons.qr),
];
const _otherMethods = [
  ('Криптовалюта', PaymentIcons.crypto),
  ('Telegram Stars', PaymentIcons.tgStars),
];

class _SubscribeSheetState extends State<SubscribeSheet> {
  final PageController _pageController = PageController();
  int _planIndex = 1;
  String _paymentMethod = 'Карта рубли';
  String? _paymentIcon;
  bool _promoOpen = false;
  bool _promoApplied = false;
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _autopay = false;
  bool _showSuccess = false;

  int get _price {
    final base = _plans[_planIndex].price;
    return _promoApplied ? (base * 0.9).round() : base;
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _applyPromo() {
    if (_promoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните поле промокода')),
      );
      return;
    }
    setState(() => _promoApplied = true);
  }

  // TODO(subscription-state): a real purchase must be sent to your payment
  // provider (per the chosen _paymentMethod) and, on success, the resulting
  // subscription (plan, expiry, autopay) should be persisted — e.g. write to
  // SharedPreferences the same way lib/vpn_state.dart / servers_list.dart do,
  // then read it back in setting_page.dart's SettingInfoCard so "Подписка"
  // reflects the real plan/expiry instead of the static mock values there.
  Future<void> _pay() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _showSuccess = true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _promoController.dispose();
    _cardController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.93;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _planPage(),
                _paymentPage(),
                _methodPage(),
                _payPage(),
              ],
            ),
            if (_showSuccess) _successOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _header({
    required String title,
    bool showBack = false,
    VoidCallback? onBack,
  }) {
    return SizedBox(
      height: 57,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _primaryText,
            ),
          ),
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onBack,
                child: const Text('Назад', style: TextStyle(fontSize: 17)),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть', style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctaButton(String text, VoidCallback onTap) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: _accentGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      boxShadow: AppShadows.card,
    ),
    child: child,
  );

  // Step 0 — plan picker
  Widget _planPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(title: 'Подписка'),
          const SizedBox(height: 8),
          const Text(
            'Выберите план подписки, чтобы продолжить пользоваться ВПН.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: _primaryText),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < _plans.length; i++) ...[
            _planTile(i),
            const SizedBox(height: 14),
          ],
          const Spacer(),
          _ctaButton(
            'Оплатить ${_plans[_planIndex].months == 12 ? "на год" : "за 3 месяца"}',
            () => _goTo(1),
          ),
        ],
      ),
    );
  }

  Widget _planTile(int i) {
    final plan = _plans[i];
    final selected = _planIndex == i;
    return GestureDetector(
      onTap: () => setState(() => _planIndex = i),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.brandBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.label,
                        style: const TextStyle(fontSize: 17, color: _primaryText),
                      ),
                      if (plan.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: _accentGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '-25%',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.perMonth,
                    style: const TextStyle(fontSize: 14, color: _muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.price} ₽',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _primaryText,
                  ),
                ),
                if (plan.originalPrice != null)
                  Text(
                    '${plan.originalPrice} ₽',
                    style: const TextStyle(
                      fontSize: 13,
                      color: _muted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Step 1 — payment summary + promo
  Widget _paymentPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(title: 'Оплата', showBack: true, onBack: () => _goTo(0)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _goTo(2),
            child: _card(
              child: Row(
                children: [
                  if (_paymentIcon != null) ...[
                    SvgPicture.asset(_paymentIcon!, width: 30, height: 20),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      _paymentMethod,
                      style: const TextStyle(fontSize: 17, color: _primaryText),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _promoOpen = !_promoOpen),
            child: _card(
              child: Row(
                children: [
                  Icon(
                    _promoApplied
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _promoApplied ? AppColors.brandBlue : _muted,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'У меня есть промокод!',
                      style: TextStyle(fontSize: 17, color: _primaryText),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_promoOpen && !_promoApplied) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Промокод',
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 100,
                  height: 52,
                  child: _ctaButton('Готово', _applyPromo),
                ),
              ],
            ),
          ],
          if (_promoApplied) ...[
            const SizedBox(height: 14),
            const Text(
              'Скидка 10% на годовую подписку',
              style: TextStyle(fontSize: 17, color: _primaryText),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Подписка на ${_plans[_planIndex].months * 30} дней VPN Client',
                  style: const TextStyle(fontSize: 17, color: _primaryText),
                ),
              ),
              Text(
                '$_price ₽',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _primaryText,
                ),
              ),
            ],
          ),
          const Spacer(),
          _ctaButton('Перейти к оплате', () => _goTo(3)),
        ],
      ),
    );
  }

  // Step 2 — payment method list
  Widget _methodPage() {
    Widget group(String title, List<(String, String?)> methods) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 15, color: _muted)),
        ),
        for (final m in methods) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _paymentMethod = m.$1;
                _paymentIcon = m.$2;
              });
              _goTo(1);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _card(
                child: Row(
                  children: [
                    if (m.$2 != null) ...[
                      SvgPicture.asset(m.$2!, width: 30, height: 20),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(m.$1, style: const TextStyle(fontSize: 17, color: _primaryText)),
                    ),
                    if (_paymentMethod == m.$1)
                      const Icon(Icons.check, color: AppColors.brandBlue),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(title: 'Способ оплаты', showBack: true, onBack: () => _goTo(1)),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  group('Оплата рублями', _ruMethods),
                  group('Оплата евро', _euMethods),
                  group('Другое', _otherMethods),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 3 — card entry
  Widget _payPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(title: 'Оплата', showBack: true, onBack: () => _goTo(1)),
          const SizedBox(height: 20),
          TextField(
            controller: _cardController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // TODO(card-validation): add real formatting/validation before
            // enabling "Оплатить" — group digits in 4s as the user types,
            // run a Luhn checksum, and detect the card network (Visa/
            // Mastercard/Mir prefixes) to swap in the matching logo from
            // assets/images/payment/. Same for the MM/YY field below (reject
            // past dates) and CVV (require exactly 3-4 digits).
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Номер карты',
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'ММ/ГГ',
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'CVV',
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _autopay = !_autopay),
            child: _card(
              child: Row(
                children: [
                  Icon(
                    _autopay ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: _autopay ? AppColors.brandBlue : _muted,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Подключить автосписание',
                      style: TextStyle(fontSize: 17, color: _primaryText),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Подписка на ${_plans[_planIndex].months * 30} дней VPN Client',
                  style: const TextStyle(fontSize: 17, color: _primaryText),
                ),
              ),
              Text(
                '$_price ₽',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _primaryText,
                ),
              ),
            ],
          ),
          const Spacer(),
          _ctaButton('Оплатить', _pay),
        ],
      ),
    );
  }

  // Success — plays automatically after payment (per Figma Succes-Start note)
  Widget _successOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {}, // absorb taps; dismissal is via the button only
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Поздравляем!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _primaryText,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Вы успешно оплатили подписку.\nМожете начинать пользоваться интернетом без ограничений',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: _primaryText),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: _ctaButton(
                  'Отлично!',
                  () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
