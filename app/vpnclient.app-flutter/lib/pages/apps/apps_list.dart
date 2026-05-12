import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apps_list_item.dart';
import 'package:vpn_client/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:vpn_client/core/constants/storage_keys.dart'; // Importar as constantes

class AppsList extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onAppsLoaded;
  final List<Map<String, dynamic>>? apps;

  const AppsList({super.key, this.onAppsLoaded, this.apps});

  @override
  State<AppsList> createState() => AppsListState();
}

class AppsListState extends State<AppsList> {
  List<Map<String, dynamic>> _apps = [];
  bool _isLoading = true;
  bool _dataLoaded = false; // Flag para controlar o carregamento inicial

  @override
  void initState() {
    super.initState();
    if (widget.apps != null && widget.apps!.isNotEmpty) {
      _apps = widget.apps!;
      _isLoading = false;
      _dataLoaded =
          true; // Marcar como carregado se dados iniciais foram fornecidos
      // widget.onAppsLoaded é chamado em didUpdateWidget ou após _loadApps
    }
  }

  late String textallapps;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      // Carregar apenas se os dados não foram carregados via widget.apps ou anteriormente
      textallapps = AppLocalizations.of(context)!.all_apps;
      _loadApps();
    }
  }

  @override
  void didUpdateWidget(covariant AppsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.apps != null && widget.apps != oldWidget.apps) {
      setState(() {
        _apps = widget.apps!;
        _isLoading = false;
        _dataLoaded = true;
      });
      _saveSelectedApps();
    }
  }

  Future<void> _loadApps() async {
    setState(() {
      // Evitar mostrar loading se já estiver carregando ou já carregou
      if (!_dataLoaded) _isLoading = true;
    });

    // Simulação de carregamento
    // Em um app real, aqui viria a lógica de buscar dados de uma API ou DB
    await Future.delayed(const Duration(milliseconds: 100)); // Simular delay

    // Definir textallapps aqui se ainda não foi definido em didChangeDependencies
    // Isso é um fallback, idealmente textallapps já está disponível.
    // Adicionando verificação de 'mounted' para o BuildContext
    if (!mounted) return;
    final localizations = AppLocalizations.of(context);
    textallapps = localizations?.all_apps ?? "All Applications";

    try {
      // Se os dados já foram carregados (ex: por uma busca anterior que atualizou widget.apps), não recarregar do zero
      if (_dataLoaded && _apps.isNotEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      List<Map<String, dynamic>> appsList = [
        {
          'icon': null,
          'image': null,
          'text': textallapps, // Usar a string localizada
          'isSwitch': true,
          'isActive': false,
        },
      ];

      appsList.addAll([
        {
          'icon': null,
          'image': 'assets/images/Instagram.png',
          'text': 'Instagram',
          'isSwitch': false,
          'isActive': false,
        },
        {
          'icon': null,
          'image': 'assets/images/TikTok.png',
          'text': 'TikTok',
          'isSwitch': false,
          'isActive': true,
        },
        {
          'icon': null,
          'image': 'assets/images/Twitter.png',
          'text': 'X (Twitter)',
          'isSwitch': false,
          'isActive': false,
        },
        {
          'icon': null,
          'image': 'assets/images/Amazon.png',
          'text': 'Amazon',
          'isSwitch': false,
          'isActive': false,
        },
      ]);

      final prefs = await SharedPreferences.getInstance();
      final String? savedApps = prefs.getString(StorageKeys.selectedApps);
      if (savedApps != null) {
        final List<dynamic> savedAppsList = jsonDecode(savedApps);
        for (var savedApp in savedAppsList) {
          final index = appsList.indexWhere(
            (app) => app['text'] == savedApp['text'],
          );
          if (index != -1) {
            appsList[index]['isActive'] = savedApp['isActive'];
          }
        }
      }

      setState(() {
        _apps = appsList;
        _isLoading = false;
        _dataLoaded = true; // Marcar que os dados foram carregados
      });

      if (widget.onAppsLoaded != null) {
        widget.onAppsLoaded!(_apps);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _dataLoaded = true; // Marcar como tentado carregar para evitar loop
      });
      debugPrint('Error loading apps: $e');
    }
  }

  Future<void> _saveSelectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedApps =
        _apps
            .map((app) => {'text': app['text'], 'isActive': app['isActive']})
            .toList();
    await prefs.setString(StorageKeys.selectedApps, jsonEncode(selectedApps));
  }

  List<Map<String, dynamic>> get apps => _apps;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0 && _apps[index]['isSwitch']) {
        _apps[0]['isActive'] = !_apps[0]['isActive'];
        // Se "Todos os aplicativos" for ativado, desabilitar os outros itens da lista (visual)
        // A lógica de 'isEnabled' no AppListItem já cuida disso visualmente.
        // Aqui, garantimos que os outros não estejam 'isActive' se "Todos" estiver ativo.
        if (_apps[0]['isActive']) {
          for (int i = 1; i < _apps.length; i++) {
            _apps[i]['isActive'] =
                false; // Desmarcar outros se "Todos" for selecionado
          }
        }
      } else {
        _apps[index]['isActive'] = !_apps[index]['isActive'];
        // Se um app individual for ativado, "Todos os aplicativos" deve ser desativado
        if (_apps[index]['isActive'] && index != 0) {
          _apps[0]['isActive'] = false;
        }
      }
    });
    _saveSelectedApps();
    debugPrint(
      'Tapped app at index $index, new state: ${_apps[index]['isActive']}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Garante que textallapps seja inicializado se didChangeDependencies não for chamado a tempo
    // ou se o widget for reconstruído antes.
    textallapps = AppLocalizations.of(context)?.all_apps ?? "All Applications";

    // Atualiza o texto do primeiro item se ele ainda não estiver com o texto localizado
    // Isso pode acontecer se _loadApps for chamado antes de textallapps ser definido por didChangeDependencies
    if (_apps.isNotEmpty &&
        _apps[0]['text'] != textallapps &&
        _apps[0]['isSwitch'] == true) {
      _apps[0]['text'] = textallapps;
    }

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_apps.length, (index) {
                    return AppListItem(
                      icon: _apps[index]['icon'],
                      image: _apps[index]['image'],
                      text: _apps[index]['text'],
                      isSwitch: _apps[index]['isSwitch'],
                      isActive: _apps[index]['isActive'],
                      isEnabled:
                          index == 0 ||
                          !_apps[0]['isActive'], // Item é habilitado se for o switch "Todos" ou se "Todos" não estiver ativo
                      onTap: () => _onItemTapped(index),
                    );
                  }),
                ),
              ),
    );
  }
}
