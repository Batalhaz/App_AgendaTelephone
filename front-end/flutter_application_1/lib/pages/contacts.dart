import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pages/favorites.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/pages/keypad.dart';
import 'package:flutter_application_1/pages/recents.dart';
import 'package:flutter_application_1/pages/singleContact.dart';
import '/widgets/pulse_button.dart';

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const TabNavigator({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) =>
          MaterialPageRoute(builder: (context) => child),
    );
  }
}

class FilterItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(225, 109, 150, 231)
              : const Color.fromRGBO(109, 150, 231, 0.185),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : const Color.fromRGBO(69, 83, 121, 0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class ContactsPages extends StatefulWidget {
  final TextEditingController searchController;
  const ContactsPages({super.key, required this.searchController});

  @override
  State<ContactsPages> createState() => _ContactsPagesState();
}

class _ContactsPagesState extends State<ContactsPages> {
  final List<String> categorias = [
    'Todos',
    'Família',
    'Trabalho',
    'Escola',
    'Outros',
  ];
  String filtroAtivo = 'Todos';
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _contatosFuture;
  Set<int> _contactsSelecteds = {};
  bool _selectMode = false;

  @override
  void initState() {
    super.initState();
    _contatosFuture = apiService.getContatos();

    widget.searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void refreshContacts() {
    setState(() {
      _contatosFuture = apiService.getContatos();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_contactsSelecteds.contains(id)) {
        _contactsSelecteds.remove(id);
        if (_contactsSelecteds.isEmpty) _selectMode = false;
      } else {
        _contactsSelecteds.add(id);
        _selectMode = true;
      }
    });
  }

  Widget _buildBottomCancel(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: TextButton(
        onPressed: (){
          setState(() {
            _selectMode = false;
            _contactsSelecteds.clear();
          });
          }, 
        child: const Text(
          'Cancelar',
          style: TextStyle(
          color: Colors.blue,
          fontSize:  16
          ),
        )
      ),
    );
  }

  Widget _buildBottomDel(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      child: IconButton(
        onPressed: ()async{
          if(_contactsSelecteds.isNotEmpty){
            final deleteAll = _contactsSelecteds.map((id){
              return apiService.deleteContacts(id);
            }).toList();

            await Future.wait(deleteAll);

            setState(() {
              _contactsSelecteds.clear();
              _selectMode = false;
              _contatosFuture = apiService.getContatos();
            });
            HapticFeedback.lightImpact();
          }
          }, 
        icon: Icon(
          Icons.delete_rounded,
          color: const Color.fromARGB(166, 244, 67, 54),
          size: 40,
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contatos',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                PulseButton(
                  onContactCreated: () {
                    setState(() {
                      _contatosFuture = apiService.getContatos();
                    });
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(226, 232, 240, 0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: widget.searchController,
                decoration: InputDecoration(
                  hintText: 'Procurar por contato',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color.fromRGBO(148, 163, 184, 1),
                  ),
                  suffixIcon: widget.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            widget.searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          _selectMode
            ? Row(
              children: [
                _buildBottomDel(),
                Expanded(
                  child: _contactsSelecteds.length > 1
                  ? Text(
                    '${_contactsSelecteds.length} Contatos selecionados',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    )
                  : Text(
                    '1 Contato selecionado',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    ),
                  ),
                
                _buildBottomCancel(),
              ],
            )
          : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: categorias
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: FilterItem(
                        label: cat,
                        isSelected: filtroAtivo == cat,
                        onTap: () => setState(() => filtroAtivo = cat),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _contatosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final todosContatos = snapshot.data ?? [];
                final String termoBusca = widget.searchController.text
                    .toLowerCase();
                final contatos = todosContatos.where((c) {
                  final String nameContact = (c['name'] ?? '').toLowerCase();
                  final String categoryContact =
                      c['category']?['label'] ?? 'Geral';
                  bool bateCategoria =
                      filtroAtivo == 'Todos' || categoryContact == filtroAtivo;
                  bool bateBusca = nameContact.contains(termoBusca);
                  return bateCategoria && bateBusca;
                }).toList();

                if (contatos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum contato encontrado.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: contatos.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final contato = contatos[index];
                    final String name = contato['name'] ?? 'Sem nome';
                    final String categoryName = contato['category']?['label'] ?? 'Geral';
                    final String photoUrl = contato['photoUrl'] ?? '';

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _contactsSelecteds.contains(contato['id'])
                            ? const Color.fromRGBO(158, 158, 158, 0.301)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: InkWell(
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          _toggleSelect(contato['id']);
                        },
                        onTap: () async{
                          if (_selectMode) {
                            _toggleSelect(contato['id']);
                          } else{
                            final result = await Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute( builder: (context) => SingleContact(id: contato['id']),),
                            );
                            if(result == true){
                            refreshContacts();
                            }
                          }
                        },

                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _contactsSelecteds.contains(contato['id'])
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color.fromRGBO(33, 149, 243, 0.623),
                                  size: 50,
                                )
                              : ClipOval(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: const Color.fromRGBO(
                                      43,
                                      108,
                                      238,
                                      0.1,
                                    ),
                                    child:
                                        (photoUrl != null &&
                                            photoUrl.trim().isNotEmpty)
                                        ? Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.person,
                                                      color: Colors.blue,
                                                    ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: Colors.blue,
                                          ),
                                  ),
                                ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryName == 'Família'
                                      ? const Color.fromRGBO(255, 237, 213, 1)
                                      : categoryName == 'Trabalho'
                                      ? const Color.fromRGBO(43, 108, 238, 0.1)
                                      : categoryName == 'Escola'
                                      ? const Color.fromRGBO(
                                          255,
                                          35,
                                          138,
                                          0.192,
                                        )
                                      : const Color.fromARGB(
                                          104,
                                          128,
                                          128,
                                          128,
                                        ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: categoryName == 'Família'
                                        ? const Color.fromRGBO(234, 88, 12, 1)
                                        : categoryName == 'Trabalho'
                                        ? const Color.fromRGBO(43, 108, 238, 1)
                                        : categoryName == 'Escola'
                                        ? const Color.fromRGBO(255, 35, 138, 1)
                                        : const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5)
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContactsHome extends StatefulWidget {
  const ContactsHome({super.key});

  @override
  State<ContactsHome> createState() => _ContactsHomeState();
}

class _ContactsHomeState extends State<ContactsHome> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RecentsScreenState> _recentsKey = GlobalKey<RecentsScreenState>();
  final GlobalKey<FavoritesPageState> _favoritesKey = GlobalKey<FavoritesPageState>();
  final GlobalKey<_ContactsPagesState> _contactsKey = GlobalKey<_ContactsPagesState>();
  int _indiceAtual = 2;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  List<Widget> get _pages => [
    TabNavigator(
      navigatorKey: _navigatorKeys[0],
      child: FavoritesPage(
        key: _favoritesKey,
        searchController: _searchController,
      ),
    ),
    TabNavigator(
      navigatorKey: _navigatorKeys[1],
      child: RecentsScreen(
        key: _recentsKey,
        onNavigateToKeypad: () async {
          setState(() => _indiceAtual = 3);
        },
      ),
    ),
    TabNavigator(
      key: _contactsKey,
      navigatorKey: _navigatorKeys[2],
      child: ContactsPages(searchController: _searchController),
    ),
    TabNavigator(navigatorKey: _navigatorKeys[3], child: KeypadScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final navigator = _navigatorKeys[_indiceAtual].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          if (_indiceAtual != 2) {
            setState(() => _indiceAtual = 2);
          } else {}
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _indiceAtual, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indiceAtual,
          selectedItemColor: const Color.fromRGBO(43, 108, 238, 1),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() => _indiceAtual = index);
            if (index == 1) {
              _recentsKey.currentState?.refreshCalls();
              _contactsKey.currentState?.refreshContacts();
            }
            if (index == 0) {
              _favoritesKey.currentState?.refreshFavorites();
              _contactsKey.currentState?.refreshContacts();
            }
            if(index == 2){
              _contactsKey.currentState?.refreshContacts();
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Recentes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Contatos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dialpad),
              label: 'Teclado',
            ),
          ],
        ),
      ),
    );
  }
}
