import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/widgets/unread_badge.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/config_service.dart';
import '../../theme_provider.dart';
import '../../unread_notifier.dart';
import 'subscribe_sheet.dart';
import 'support_chat_page.dart';

/// Settings — profile, connection, appearance (theme + language) and
/// subscription/account groups. Language picker writes to [LocaleProvider]
/// so the entire app flips between RU/EN/ZH/TH instantly.
class SettingsPage extends StatelessWidget {
  final VoidCallback onOpenServers;
  const SettingsPage({super.key, required this.onOpenServers});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProv = context.watch<LocaleProvider>();
    final themeProv = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.xs,
        AppSpacing.pageGutter,
        AppSpacing.xxl,
      ),
      children: [
        _Profile(),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel(text: 'Connection'),
        _Group(items: [
          _Item(
            icon: Icons.dns_rounded,
            label: l.servers_subscriptions,
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textMuted),
            onTap: onOpenServers,
          ),
          _Item(
            icon: Icons.swap_horiz_rounded,
            label: l.protocol,
            trailing: _Trail(text: 'Auto'),
          ),
          _Item(
            icon: Icons.shield_outlined,
            label: l.kill_switch,
            sub: l.kill_switch_hint,
            // Real value from ConfigService (.env-configured per deployment,
            // same pattern as SHOW_APPS_PAGE etc.) — not user-toggleable at
            // runtime today, so the switch reflects but doesn't accept input.
            trailing: Switch(value: ConfigService.enableKillSwitch, onChanged: null),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionLabel(text: 'Appearance'),
        _Group(items: [
          _Item(
            icon: Icons.brightness_4_rounded,
            label: l.theme,
            trailing: _Trail(text: _themeLabel(themeProv.themeMode, l)),
            onTap: () => _pickTheme(context, themeProv),
          ),
          _Item(
            icon: Icons.language_rounded,
            label: l.language,
            trailing: _Trail(text: _localeLabel(localeProv.locale)),
            onTap: () => _pickLanguage(context, localeProv),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionLabel(text: 'Subscription'),
        _Group(items: [
          _Item(
            icon: Icons.workspace_premium_rounded,
            label: l.upgrade_pro,
            // Real billing is flows/sdd-vpnclient-payment's job; this opens
            // the (mocked-plan-data) subscribe sheet UI shell.
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: const Text('Pro',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            onTap: () => SubscribeSheet.show(context),
          ),
          _Item(
            icon: Icons.percent_rounded,
            label: l.promo_code,
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textMuted),
            onTap: () => SubscribeSheet.show(context),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionLabel(text: 'About'),
        _Group(items: [
          _Item(
            icon: Icons.support_agent_rounded,
            label: l.telegram_support,
            trailing: AnimatedBuilder(
              animation: UnreadNotifier.instance,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UnreadBadge(count: UnreadNotifier.instance.count),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SupportChatPage()),
            ),
          ),
          _Item(
            icon: Icons.info_outline_rounded,
            label: l.about,
            trailing: _Trail(text: 'v ${ConfigService.appVersion}'),
          ),
        ]),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l.reset_settings),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: BorderSide(color: AppColors.divider),
          ),
          onPressed: () => _confirmReset(context, themeProv, localeProv, l),
        ),
      ],
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    ThemeProvider themeProv,
    LocaleProvider localeProv,
    AppLocalizations l,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.reset_settings),
        content: Text(l.are_you_sure_reset),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await themeProv.setThemeMode(ThemeMode.light);
    await localeProv.setLocale(null);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.connection_reset)));
    }
  }

  String _themeLabel(ThemeMode mode, AppLocalizations l) => switch (mode) {
        ThemeMode.system => l.theme_system,
        ThemeMode.light => l.theme_light,
        ThemeMode.dark => l.theme_dark,
      };

  String _localeLabel(Locale? loc) {
    if (loc == null) return 'Auto';
    return switch (loc.languageCode) {
      'en' => 'English',
      'ru' => 'Русский',
      'zh' => '中文',
      'th' => 'ไทย',
      _ => loc.languageCode,
    };
  }

  void _pickTheme(BuildContext context, ThemeProvider prov) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final m in ThemeMode.values)
            RadioListTile<ThemeMode>(
              value: m,
              groupValue: prov.themeMode,
              onChanged: (v) {
                if (v != null) prov.setThemeMode(v);
                Navigator.of(context).pop();
              },
              title: Text(_themeLabel(m, l)),
            ),
        ]),
      ),
    );
  }

  void _pickLanguage(BuildContext context, LocaleProvider prov) {
    final names = {
      'en': 'English',
      'ru': 'Русский',
      'zh': '中文',
      'th': 'ไทย',
    };
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RadioListTile<Locale?>(
            value: null,
            groupValue: prov.locale,
            onChanged: (v) {
              prov.setLocale(v);
              Navigator.of(context).pop();
            },
            title: const Text('Auto / System'),
          ),
          for (final loc in LocaleProvider.supported)
            RadioListTile<Locale>(
              value: loc,
              groupValue: prov.locale,
              onChanged: (v) {
                if (v != null) prov.setLocale(v);
                Navigator.of(context).pop();
              },
              title: Text(names[loc.languageCode] ?? loc.languageCode),
            ),
        ]),
      ),
    );
  }
}

/// Identity row. STUB: the app has no user-account system (see
/// flows/sdd-vpnclient-profile) — kept visually present per design with a
/// placeholder identity rather than fabricated-but-plausible real-looking data.
class _Profile extends StatelessWidget {
  static const _placeholderName = 'Anonymous';
  static const _placeholderId = 'ID 2485926342';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, gradient: AppColors.brandGradient),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_placeholderName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('$_placeholderId · ${l.free_plan}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, 0, AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<_Item> items;
  const _Group({required this.items});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Divider(
                    height: 1, color: theme.dividerColor),
              ),
          ]
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _Item({
    required this.icon,
    required this.label,
    this.sub,
    this.trailing,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.titleMedium),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Trail extends StatelessWidget {
  final String text;
  const _Trail({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textMuted)),
      const SizedBox(width: 2),
      const Icon(Icons.chevron_right, color: AppColors.textMuted),
    ]);
  }
}
