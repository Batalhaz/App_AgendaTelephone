import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/singleContact.dart';
import 'package:flutter_application_1/services/api_service.dart';

class FavoritesPage extends StatefulWidget {
  final TextEditingController searchController;
  const FavoritesPage({super.key, required this.searchController});

  @override
  State<FavoritesPage> createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _ListFavorites;

   void refreshFavorites() {
    setState(() {
      _ListFavorites = apiService.getFavorites();
    });
  }

  @override
  void initState() {
    super.initState();
    _ListFavorites = apiService.getFavorites();
  }

  
  Widget _buildContactsFavorites(List<dynamic> contactsFavorites) { 
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: contactsFavorites.length,
      itemBuilder: (context, index) {
        final contact = contactsFavorites[index];

        final String name = contact['name'] ?? 'Sem nome';
        final String category = contact['category']?['label'] ?? 'Geral';
        final String? photoUrl = contact['photoUrl'];

        return InkWell(
          onTap: () async{
            await Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => SingleContact(id: contact['id']),
              ),
            );
            refreshFavorites();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color.fromRGBO(226, 232, 240, 1),
                  child: (photoUrl != null && photoUrl.isNotEmpty)
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Colors.blue),
                        )
                      : const Icon(Icons.person, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                category,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
              child: Text(
                'Favoritos',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(226, 232, 240, 0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: widget.searchController,
                  onChanged: (value) => setState(() {}),
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
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _ListFavorites,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar favoritos'),
                    );
                  }

                  final favorits = snapshot.data ?? [];
                  final String termoBusca = widget.searchController.text
                      .toLowerCase();

                  final favoritFilter = favorits.where((c) {
                    final String search = (c['name'] ?? '').toLowerCase();
                    bool bateBusca = search.startsWith(termoBusca);
                    return bateBusca;
                  }).toList();

                  if (favorits.isEmpty) {
                    return Center(child: Text('Nenhum favorito encontrado!'));
                  }

                  return _buildContactsFavorites(favoritFilter);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
