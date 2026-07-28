import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/flags.dart';
import '../../l10n/app_localizations.dart';
import '../../vpn_state.dart';

/// "Your location" card — currently-selected server, tap to open Servers.
/// Reads the real [VpnState.selectedServerName]/[selectedFlagCode].
class LocationWidget extends StatelessWidget {
  final VoidCallback onTap;
  const LocationWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnState>();
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final flagCode = vpn.selectedFlagCode;
    final isAuto = flagCode == null;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.your_location,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vpn.selectedServerName ?? l.auto_select,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAuto ? AppColors.brandGradient : null,
                  color: isAuto ? null : const Color(0xFFECEFF1),
                ),
                child: Center(
                  child: isAuto
                      ? const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 22)
                      : ClipOval(
                          child: SvgPicture.asset(
                            AppFlags.forIsoCode(flagCode),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
