import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/pages/newContact.dart';
import 'package:flutter_application_1/pages/singleContact.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/services/database_helper.dart';
import 'package:flutter_application_1/widgets/popove.dart';
import 'package:popover/popover.dart';

class KeypadScreen extends StatefulWidget {
  const KeypadScreen({super.key});

  @override
  State<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends State<KeypadScreen> {
  String _numberEntered = '';
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _contactsFuture;
  Map<String, dynamic>? _foundContact;

  @override
  void initState() {
    super.initState();
    _contactsFuture = _apiService.getContatos();
  }

  void registerCall(String numberEntered) async {
    final List<dynamic> contacts = await _contactsFuture;
    final String cleanEntered = numberEntered.replaceAll(RegExp(r'[^0-9]'), '');

    final contactExist = contacts.firstWhere((c) {
      final List<dynamic> phoneList = c['phones'] ?? [];
      return phoneList.any(
        (p) =>
            p['number'].toString().replaceAll(RegExp(r'[^0-9]'), '') ==
            cleanEntered,
      );
    }, orElse: () => null);

    if (contactExist != null) {
      print("Contato encontrado: ${contactExist['name']}");
      final response = await _apiService.createCall(contactExist['id'], 0);
      print("Resposta da API: $response");
    } else {
      print("Nenhum contato corresponde ao número: $numberEntered");
      await DatabaseHelper.instance.registrarChamada(numberEntered);
    }
  }

  String formatCell(String s) {
    if (s.isEmpty) return 'Digite um número';

    if (s.length == 11) {
      return '(${s.substring(0, 2)}) ${s.substring(2, 7)}-${s.substring(7)}';
    } else if (s.length == 10) {
      return '(${s.substring(0, 2)}) ${s.substring(2, 6)}-${s.substring(6)}';
    }

    if (s.length > 2) {
      return '(${s.substring(0, 2)}) ${s.substring(2)}';
    }
    return s;
  }

  void _updateNumber(String value) {
    if (_numberEntered.length < 11) {
      setState(() {
        _numberEntered += value;
      });
      _searchContact(_numberEntered);
    }
  }

  void _searchContact(String number) async {
    final List<dynamic> contacts = await _contactsFuture;
    final String cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');

    final contact = contacts.cast<Map<String, dynamic>>().firstWhere((c) {
      final List<dynamic> phones = c['phones'] ?? [];
      return phones.any(
        (p) =>
            p['number'].toString().replaceAll(RegExp(r'[^0-9]'), '') ==
            cleanNumber,
      );
    }, orElse: () => {});
    setState(() {
      _foundContact = contact.isNotEmpty ? contact : null;
    });
  }

  void _deleteEndNumber() {
    if (_numberEntered.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _numberEntered = _numberEntered.substring(0, _numberEntered.length - 1);
      });
      _searchContact(_numberEntered);
    }
  }

  

  Widget _buildPopoverError(String value) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 211, 211, 211),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Icon(Icons.call_end_rounded, size: 40, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            'Chamada falhou',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text('Número inválido', textAlign: TextAlign.center),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number, VoidCallback onTap, String subText) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(15, 23, 42, 1),
              ),
            ),
            Text(
              subText.isNotEmpty ? subText : ' ',
              style: const TextStyle(
                fontSize: 13,
                color: Color.fromRGBO(148, 163, 184, 1),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // APPBAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_outlined,
              color: Color(0xFF475569),
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => NewContact(
                    categoryId: null,
                    isFavorite: false,
                    name: null,
                    phones: _numberEntered.isNotEmpty
                      ? [{'number': _numberEntered, 'label': 'Celular'}]
                      : [],
                    photoUrl: null,
                    ),
                ),
              );
            },
          ),
        ),
        title: const Text(
          'ARAPIRACA, ALAGOAS',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF475569),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Teclado'),
                    content: const Text('Digite o número que deseja ligar.'),
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
          ),
        ],
      ),

      // BODY
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_foundContact != null)
                  GestureDetector(
                    onTap: () {
                      final idContact = _foundContact!['id'];
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => SingleContact(id: idContact),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Container(
                              width: 30,
                              height: 30,
                              color: const Color.fromRGBO(43, 108, 238, 0.1),
                              child:
                                  (_foundContact?['photoUrl'] != null &&
                                      _foundContact!['photoUrl'].isNotEmpty)
                                  ? Image.network(
                                      _foundContact!['photoUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                size: 18,
                                                color: Colors.blue,
                                              ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _foundContact!['name'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 2),
                Text(
                  formatCell(_numberEntered),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: _numberEntered.isEmpty
                        ? Colors.grey
                        : const Color(0xFF0F172A),
                  ),
                ),
                if (_numberEntered.isNotEmpty && _foundContact == null)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NewContact(
                                categoryId: null,
                                isFavorite: false,
                                name: null,
                                phones: _numberEntered.isNotEmpty
                                  ? [{'number': _numberEntered, 'label': 'Celular'}]
                                  : [],
                                photoUrl: null,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Adicionar contato',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),

                SizedBox(
                  height: 50,
                  child: _numberEntered.isNotEmpty
                      ? IconButton(
                          onPressed: _deleteEndNumber,
                          icon: const Icon(
                            Icons.backspace_outlined,
                            color: Color(0xFF94A3B8),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          SizedBox(height: 5),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double aspect =
                    constraints.maxWidth / (constraints.maxHeight * 0.8);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    mainAxisSpacing: 3,
                    crossAxisCount: 3,
                    childAspectRatio: aspect > 1.8 ? 1.8 : aspect,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildKey('1', () => _updateNumber('1'), ''),
                      _buildKey('2', () => _updateNumber('2'), 'ABC'),
                      _buildKey('3', () => _updateNumber('3'), 'DEF'),
                      _buildKey('4', () => _updateNumber('4'), 'GHI'),
                      _buildKey('5', () => _updateNumber('5'), 'JKL'),
                      _buildKey('6', () => _updateNumber('6'), 'MNO'),
                      _buildKey('7', () => _updateNumber('7'), 'PQRS'),
                      _buildKey('8', () => _updateNumber('8'), 'TUV'),
                      _buildKey('9', () => _updateNumber('9'), 'WXYZ'),
                      _buildKey('*', () => _updateNumber('*'), ''),
                      _buildKey('0', () => _updateNumber('0'), '+'),
                      _buildKey('#', () => _updateNumber('#'), ''),
                    ],
                  ),
                );
              },
            ),
          ),

          // Ligar
          Padding(
            padding: EdgeInsets.only(
              bottom: screenHeight * 0.05,
              top: screenHeight * 0.01,
            ),
            child: Center(
              child: InkWell(
                onTap: () async {
                  if (_numberEntered.isEmpty || _numberEntered.length < 11) {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return _buildPopoverError(_numberEntered);
                      },
                    );
                    return;
                  }

                  final String numberToDisplay = _numberEntered;

                  registerCall(numberToDisplay);
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => CallModal(number: numberToDisplay, formatCell: formatCell(numberToDisplay))
                  );
                  setState(() {
                    _numberEntered = '';
                    _foundContact = null;
                  });
                },
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2B6CEE),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call, size: 40, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
