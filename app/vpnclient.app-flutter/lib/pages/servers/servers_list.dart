import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/pages/servers/servers_list_item.dart';
import 'package:vpn_client/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:vpn_client/core/constants/storage_keys.dart';

class ServersList extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onServersLoaded;
  final List<Map<String, dynamic>>? servers;
  final Function(int)?
  onItemTapNavigate; // Renomeado para clareza ou pode ser uma callback mais específica

  const ServersList({
    super.key,
    this.onServersLoaded,
    this.servers,
    this.onItemTapNavigate,
  });

  @override
  State<ServersList> createState() => ServersListState();
}

class ServersListState extends State<ServersList> {
  List<Map<String, dynamic>> _servers = [];
  bool _isLoading = true;
  bool _dataLoaded = false; // Flag para controlar o carregamento inicial

  @override
  void initState() {
    super.initState();
    if (widget.servers != null && widget.servers!.isNotEmpty) {
      _servers = widget.servers!;
      _isLoading = false;
      _dataLoaded =
          true; // Marcar como carregado se dados iniciais foram fornecidos
      // widget.onServersLoaded é chamado em didUpdateWidget ou após _loadServers
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      // Carregar apenas se os dados não foram carregados via widget.servers ou anteriormente
      _loadServers();
    }
  }

  @override
  void didUpdateWidget(covariant ServersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.servers != null && widget.servers != oldWidget.servers) {
      setState(() {
        _servers = widget.servers!;
        _isLoading = false;
        _dataLoaded = true;
      });
      _saveSelectedServers();
    }
  }

  Future<void> _loadServers() async {
    setState(() {
      // Evitar mostrar loading se já estiver carregando ou já carregou
      if (!_dataLoaded) _isLoading = true;
    });

    // Simulação de carregamento
    await Future.delayed(const Duration(milliseconds: 100)); // Simular delay

    try {
      // Se os dados já foram carregados (ex: por uma busca anterior que atualizou widget.servers), não recarregar do zero
      if (_dataLoaded && _servers.isNotEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // É importante que AppLocalizations.of(context) seja chamado quando o context está pronto.
      // didChangeDependencies é um bom lugar, ou aqui se garantirmos que o context está disponível.
      // Adicionando verificação de 'mounted' para o BuildContext
      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;

      List<Map<String, dynamic>> serversList = [
        {
          'icon': 'assets/images/flags/auto.svg',
          'text': localizations.auto_select,
          'ping': localizations.fastest,
          'isActive': true,
        },
        {
          'icon': 'assets/images/flags/Kazahstan.svg',
          'text': localizations.kazakhstan,
          'ping': '48',
          'isActive': false,
        },
        {
          'icon': 'assets/images/flags/Turkey.svg',
          'text': localizations.turkey,
          'ping': '142',
          'isActive': false,
        },
        {
          'icon': 'assets/images/flags/Poland.svg',
          'text': localizations.poland,
          'ping': '298',
          'isActive': false,
        },
      ];

      final prefs = await SharedPreferences.getInstance();
      final String? savedServers = prefs.getString(StorageKeys.selectedServers);
      if (savedServers != null) {
        final List<dynamic> savedServersList = jsonDecode(savedServers);
        for (var savedServerItem in savedServersList) {
          final index = serversList.indexWhere(
            (server) => server['text'] == savedServerItem['text'],
          );
          if (index != -1) {
            serversList[index]['isActive'] = savedServerItem['isActive'];
          }
        }
      }

      setState(() {
        _servers = serversList;
        _isLoading = false;
        _dataLoaded = true; // Marcar que os dados foram carregados
      });

      if (widget.onServersLoaded != null) {
        widget.onServersLoaded!(_servers);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _dataLoaded = true; // Marcar como tentado carregar para evitar loop
      });
      debugPrint('Error loading servers: $e');
    }
  }

  Future<void> _saveSelectedServers() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedServersData =
        _servers
            .map(
              (server) => {
                'text': server['text'],
                'isActive': server['isActive'],
                'icon': server['icon'],
                'ping': server['ping'],
              },
            )
            .toList();
    await prefs.setString(
      StorageKeys.selectedServers,
      jsonEncode(selectedServersData),
    );
  }

  List<Map<String, dynamic>> get servers => _servers;

  void _onItemTapped(int indexInFullList) {
    setState(() {
      for (int i = 0; i < _servers.length; i++) {
        _servers[i]['isActive'] = (i == indexInFullList);
      }
    });

    _saveSelectedServers();
    if (widget.onServersLoaded != null) {
      widget.onServersLoaded!(_servers);
    }

    if (widget.onItemTapNavigate != null) {
      widget.onItemTapNavigate!(indexInFullList);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Garante que as strings localizadas sejam usadas se _loadServers for chamado antes de didChangeDependencies
    // ou se o widget for reconstruído.
    if (_servers.isNotEmpty && AppLocalizations.of(context) != null) {
      final localizations = AppLocalizations.of(context)!;
      if (_servers[0]['text'] != localizations.auto_select) {
        // Isso pode ser perigoso se a ordem dos servidores mudar.
        // É melhor garantir que _loadServers seja chamado com o contexto correto.
        // Para simplificar, vamos assumir que _loadServers já lidou com isso.
      }
    }

    final activeServers =
        _servers.where((server) => server['isActive'] == true).toList();
    final inactiveServers =
        _servers.where((server) => server['isActive'] != true).toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeServers.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(
                          left: 10,
                          top: 10,
                          bottom: 5,
                        ), // Adicionado espaçamento
                        child: Text(
                          AppLocalizations.of(context)!.selected_server,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14, // Consistência de tamanho
                          ),
                        ),
                      ),
                      ...activeServers.map((server) {
                        return ServerListItem(
                          icon: server['icon'],
                          text: server['text'],
                          ping: server['ping'],
                          isActive: server['isActive'],
                          onTap: () => _onItemTapped(_servers.indexOf(server)),
                        );
                      }),
                    ],
                    if (inactiveServers.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(
                          left: 10,
                          top: 15,
                          bottom: 5,
                        ), // Adicionado espaçamento
                        child: Text(
                          AppLocalizations.of(context)!.all_servers,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14, // Consistência de tamanho
                          ),
                        ),
                      ),
                      ...inactiveServers.map((server) {
                        return ServerListItem(
                          icon: server['icon'],
                          text: server['text'],
                          ping: server['ping'],
                          isActive: server['isActive'],
                          onTap: () => _onItemTapped(_servers.indexOf(server)),
                        );
                      }),
                    ],
                  ],
                ),
              ),
    );
  }
}
