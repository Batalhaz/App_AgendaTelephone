import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/newContact.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/widgets/popove.dart';

class SingleContact extends StatefulWidget {
  final int id;
  const SingleContact({super.key, required this.id});

  @override
  State<SingleContact> createState() => _SingleContactState();
}

class _SingleContactState extends State<SingleContact> {
  late Future<Map<String, dynamic>> _contactFuture;
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _loadedContact;

  @override
  void initState() {
    super.initState();
    _contactFuture = _apiService.getContatosById(widget.id).then((data) {
      _loadedContact = data;
      return data;
    });
  }

  void registerCall() async {
    if (_loadedContact == null) return;
    try {
      print("Registrando chamada para: ${_loadedContact!['name']}");
      await _apiService.createCall(_loadedContact!['id'], 0);
    } catch (e) {
      print('erro');
    }
  }

  void _routePageNewContact(
    String name,
    String? photoUrl,
    List<Map<String, String>> phones,
    int categoryId,
    bool isFavorite,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewContact(
          id: widget.id,
          categoryId: categoryId,
          isFavorite: isFavorite,
          name: name,
          phones: phones,
          photoUrl: photoUrl,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _contactFuture = _apiService.getContatosById(widget.id);
      });
    }
  }

  Widget _buildPhoneLine(Map<String, dynamic> phone) {
    IconData getIcon() {
      switch (phone['label']) {
        case 'Trabalho':
          return Icons.work_outline;
        case 'Família':
          return Icons.family_restroom_outlined;
        case 'Escola':
          return Icons.school_outlined;
        default:
          return Icons.smartphone;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          _buildCircleIcon(getIcon(), () {}),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phone['label'] ?? 'Sem categoria',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(100, 116, 139, 1),
                  ),
                ),
                Text(
                  phone['number'] ?? 'Sem número',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildCircleIcon(Icons.call_outlined, () {
            if (phone.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  registerCall();
                  return CallModal(
                    number: phone['number'],
                    formatCell: phone['number'].toString(),
                  );
                },
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color.fromRGBO(226, 232, 240, 1),
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: const Color.fromRGBO(226, 232, 240, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Icon(
                icon,
                size: 30,
                color: const Color.fromRGBO(51, 65, 85, 1),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(100, 116, 139, 1),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.blue,
            size: 25,
          ),
          onTap: () => Navigator.pop(context, true),
        ),
        actions: [
          if (_contactFuture != null)
            FutureBuilder<Map<String, dynamic>>(
              future: _contactFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final d = snapshot.data!;
                return TextButton(
                  onPressed: () => _routePageNewContact(
                    d['name'],
                    d['photoUrl'],
                    (d['phones'] as List)
                        .map(
                          (p) => {
                            'number': p['number'].toString(),
                            'label': p['label'].toString(),
                          },
                        )
                        .toList(),
                    d['category']['id'],
                    d['isFavorite'] ?? false,
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () async{
                  await _apiService.deleteContacts(widget.id);
                  if(mounted){
                    Navigator.pop(context, true);
                  }
                }, 
              child: const Text('Excluir', style: TextStyle(color: Color.fromARGB(255, 218, 49, 49), fontSize: 18))
            ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _contactFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Contato não encontrado'));
          }

          final dates = snapshot.data!;
          final String? photoUrl = dates['photoUrl'];
          final String category =
              dates['category']?['label'] ?? 'Sem categoria';
          final List phones = dates['phones'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 120,
                          height: 120,
                          color: const Color.fromRGBO(43, 108, 238, 0.1),
                          child:
                              (photoUrl != null && photoUrl.trim().isNotEmpty)
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: 25,
                                      ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 80,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        dates['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: category == 'Família'
                              ? const Color.fromRGBO(255, 237, 213, 1)
                              : category == 'Trabalho'
                              ? const Color.fromRGBO(43, 108, 238, 0.1)
                              : const Color.fromRGBO(255, 35, 138, 0.192),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: category == 'Família'
                                ? const Color.fromRGBO(234, 88, 12, 1)
                                : category == 'Trabalho'
                                ? const Color.fromRGBO(43, 108, 238, 1)
                                : const Color.fromRGBO(255, 35, 138, 1),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildButton(Icons.local_phone_rounded, 'Ligar', () {
                            if (phones.isNotEmpty) {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context){
                                  registerCall();
                                  return CallModal(
                                  number: phones[0]['number'].toString(),
                                  formatCell: phones[0]['number'].toString(),
                                );
                                } 
                              );
                            }
                          }),
                          SizedBox(width: 20),
                          _buildButton(Icons.mail_rounded, 'Mensagem', () {}),
                          SizedBox(width: 20),
                          _buildButton(Icons.videocam_rounded, 'Video', () {}),
                        ],
                      ),
                      SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Números",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (dates['phones'] != null &&
                              (dates['phones'] as List).isNotEmpty)
                            ...(dates['phones'] as List)
                                .map(
                                  (p) => _buildPhoneLine(
                                    p as Map<String, dynamic>,
                                  ),
                                )
                                .toList()
                          else
                            const Text(
                              'Nenhum número disponível',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
