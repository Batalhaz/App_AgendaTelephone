import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:intl/intl.dart';

class RecentsScreen extends StatefulWidget {
  final Future<void> Function()? onNavigateToKeypad;
  const RecentsScreen({super.key, this.onNavigateToKeypad});

  @override
  State<RecentsScreen> createState() => RecentsScreenState();
}

class RecentsScreenState extends State<RecentsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _allCallsFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _modeSearching = false;

  Future<List<dynamic>> _fetchCombineCalls() async {
    final remoteCalls = await _apiService.showAllCalls();
    final localCalls = await DatabaseHelper.instance.getCallList();
    final allCalls = [...localCalls, ...remoteCalls];

    allCalls.sort((a, b) {
      DateTime dateA = DateTime.parse(a['data_hora'] ?? a['startTime']);
      DateTime dateB = DateTime.parse(b['data_hora'] ?? b['startTime']);
      return dateB.compareTo(dateA);
    });

    return allCalls;
  }

  @override
  void initState() {
    super.initState();
    _allCallsFuture = _fetchCombineCalls();
  }

  void refreshCalls() {
    setState(() {
      _allCallsFuture = _fetchCombineCalls();
    });
  }

  void deleteCall(int idCall) async {
    try {
      final calls = await _allCallsFuture;

      final callExist = calls.firstWhere(
        (c) => c['id'] == idCall,
        orElse: () => null,
      );

      if (callExist != null) {
        final bool isLocal = callExist.containsKey('numero');

        if (isLocal) {
          await DatabaseHelper.instance.deleteCall(idCall);
        } else {
          await _apiService.deleteCall(idCall);
        }
        setState(() {
          _allCallsFuture = _fetchCombineCalls();
        });
      }
    } catch (e) {
      print('Erro ao deletar chamada: $e');
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatTime(String isoDate) {
    try {
      DateTime date = DateTime.parse(isoDate);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return "--:--";
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchBar(
        controller: _searchController,
        elevation: WidgetStatePropertyAll(0),
        backgroundColor: const WidgetStatePropertyAll(
          Color.fromARGB(255, 240, 240, 240),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        hintText: 'Pesquisar por nome ou número...',
        leading: const Icon(Icons.search),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        trailing: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: !_modeSearching
              ? const Text(
                  'Recentes',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : _buildSearchBar(),
          actions: [
            _modeSearching == true
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _modeSearching = false;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF475569)),
                    onPressed: () {
                      setState(() {
                        _modeSearching = true;
                      });
                    },
                  ),
            if (!_modeSearching)
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF475569)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Recentes'),
                      content: const Text(
                        'Histórico das ligações efetuadas ou perdidas.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fechar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2B6CEE),
            unselectedLabelColor: Color(0xFF94A3B8),
            indicatorColor: Color(0xFF2B6CEE),
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Text(
                  "Chamadas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  "Perdidas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _allCallsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final List<dynamic> dadosBrutos = snapshot.data ?? [];
            final List<dynamic> todasAsChamadas = dadosBrutos.where((call) {
              final bool isLocal = call.containsKey('numero');
              final String name = (isLocal ? call['numero']
                          : call['contact']?['name'] ?? 'Desconhecido').toString().toLowerCase();
              return name.contains(_searchQuery);
            }).toList();

            if (todasAsChamadas.isEmpty) {
              return const Center(child: Text('Nenhum resultado encontrado.'));
            }

            final perdidas = todasAsChamadas
                .where((c) => c['isLost'] == true)
                .toList();

            return TabBarView(
              children: [
                _buildListView(todasAsChamadas),
                _buildListView(perdidas),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (widget.onNavigateToKeypad != null) {
              await widget.onNavigateToKeypad!();

              setState(() {
                _allCallsFuture = _fetchCombineCalls();
              });
            }
          },
          backgroundColor: const Color(0xFF2B6CEE),
          shape: const CircleBorder(),
          child: const Icon(Icons.add_ic_call, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> calls) {
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final bool isLost = call['isLost'] == true;
        final bool isLocal = call.containsKey('numero');
        final photoUrl = call['contact']?['photoUrl'];

        final String time = isLocal ? call['data_hora'] : call['startTime'];
        final String name = isLocal
            ? call['numero']
            : call['contact']?['name'] ?? 'Desconecido';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0) _buildSectionHeader("Histórico de Chamadas"),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: ClipOval(
                child: Container(
                  width: 50,
                  height: 50,
                  child: (photoUrl != null && photoUrl.toString().isNotEmpty)
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Colors.blue),
                        )
                      : const Icon(Icons.person, color: Colors.blue),
                ),
              ),

              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    isLost ? Icons.call_missed : Icons.call_made,
                    size: 14,
                    color: isLost ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      isLocal
                          ? "Local ${_formatTime(time)}"
                          : "Servidor ${_formatTime(time)} • ${_formatDuration(call['duration'])}",
                      style: const TextStyle(color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      deleteCall(call['id']);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
