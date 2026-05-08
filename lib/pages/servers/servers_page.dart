import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/server.dart';
import '../../models/subscription.dart';
import '../../providers/subscription_provider.dart';
import 'subscription_import_page.dart';

/// Servers screen — horizontal subscription strip on top, search field, then
/// "Selected" + "All servers" lists. Tapping the "+" opens the import sheet
/// (URL / QR / file), modelled on v2rayNG / Hiddify.
class ServersPage extends StatefulWidget {
  const ServersPage({super.key});

  @override
  State<ServersPage> createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<SubscriptionProvider>();
    final theme = Theme.of(context);

    final filtered = prov.servers.where((s) {
      if (_query.isEmpty) return true;
      return s.displayName.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      children: [
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: prov.subscriptions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (ctx, i) {
              if (i == prov.subscriptions.length) {
                return _AddSubscriptionCard(
                  onTap: () => _openImport(context),
                );
              }
              final sub = prov.subscriptions[i];
              return _SubscriptionCard(
                sub: sub,
                active: prov.activeSubscriptionId == sub.id,
                onTap: () => prov.setActive(sub.id),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SearchField(onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: AppSpacing.sm),
        _GroupLabel(text: l.selected_server),
        _ServerTile(
          flagCode: null,
          name: l.auto_select,
          subtitle: l.fastest,
          selected: prov.selectedServerId == null,
          onTap: () => prov.selectServer(null),
        ),
        const SizedBox(height: AppSpacing.sm),
        _GroupLabel(text: l.all_servers),
        for (final s in filtered)
          _ServerTile(
            flagCode: s.flagCode,
            name: s.displayName,
            ping: s.pingMs,
            selected: prov.selectedServerId == s.id,
            onTap: () => prov.selectServer(s.id),
          ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _openImport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubscriptionImportPage(),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription sub;
  final bool active;
  final VoidCallback onTap;
  const _SubscriptionCard({
    required this.sub,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: active ? AppColors.brandGradient : null,
          color: active ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.cloud_outlined,
                  size: 16,
                  color: active ? Colors.white : theme.colorScheme.onSurface),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sub.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: active ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${sub.servers.length} servers',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: active
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textMuted,
                    )),
                Text(sub.expiry,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: active
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textMuted,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSubscriptionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSubscriptionCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Center(
          child:
              Icon(Icons.add_rounded, color: theme.colorScheme.primary, size: 28),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: l.search,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  final String? flagCode;
  final String name;
  final String? subtitle;
  final int? ping;
  final bool selected;
  final VoidCallback onTap;
  const _ServerTile({
    required this.flagCode,
    required this.name,
    this.subtitle,
    this.ping,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuto = flagCode == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAuto ? AppColors.brandGradient : null,
                  color: isAuto ? null : const Color(0xFFECEFF1),
                ),
                alignment: Alignment.center,
                child: isAuto
                    ? const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 22)
                    : Text(flagCode!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(name, style: theme.textTheme.titleMedium),
              ),
              if (ping != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text('$ping ms',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.pingColor(ping!),
                      )),
                )
              else if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: Text(subtitle!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.success)),
                ),
              if (selected)
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
