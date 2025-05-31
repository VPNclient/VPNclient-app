import 'package:flutter/material.dart';
import 'package:vpn_client/design/dimensions.dart';

import '../../design/custom_icons.dart';

class StatBar extends StatefulWidget {
  const StatBar({super.key});

  @override
  State<StatBar> createState() => StatBarState();
}

class StatBarState extends State<StatBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(CustomIcons.download, '0 Mb/s', context),
        _buildStatItem(CustomIcons.upload, '0 Mb/s', context),
        _buildStatItem(CustomIcons.ping, '0 ms', context),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, BuildContext context) {
    return Container(
      width:
          (MediaQuery.of(context).size.width / 3) - 20, // Para dar algum espaço
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(
              context,
            ).shadowColor.withAlpha((255 * 0.1).round()), // Usar cor do tema
            offset: const Offset(0.0, 2.0),
            blurRadius: 8.0,
          ),
        ],
      ),
      // Se precisar de ação de clique, envolva com InkWell ou GestureDetector
      // InkWell(
      //   onTap: () {},
      //   borderRadius: BorderRadius.circular(12),
      //   child: ...
      // )
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(
              4,
            ), // Espaçamento interno para o ícone
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(
                (255 * 0.1).round(),
              ), // Cor de fundo suave
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize14, // Usando constante de dimensions.dart
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
