import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class NewContact extends StatefulWidget {
  final int? id;
  final String? name;
  final String? photoUrl;
  final List<Map<String, String>>? phones;
  final int? categoryId;
  final bool? isFavorite;

  const NewContact({
    super.key,
    this.id,
    this.name,
    this.photoUrl,
    this.phones,
    this.categoryId,
    this.isFavorite,
  });

  @override
  State<NewContact> createState() => _NewContactState();
}

class _NewContactState extends State<NewContact> {
  final TextEditingController _textController = TextEditingController();
  final List<TextEditingController> _phoneControllers = [];
  final ApiService _apiService = ApiService();
  bool _isFavorite = false;
  bool _isPhoneValid = false;
  int? _selectedCategory;
  File? _imageFile;

  static const List<Map<String, dynamic>> _categories = [
    {'id': 1, 'label': 'Família'},
    {'id': 2, 'label': 'Trabalho'},
    {'id': 3, 'label': 'Escola'},
    {'id': 4, 'label': 'Outros'},
  ];

  final BorderRadius _borderRadius = BorderRadius.circular(15);
  late final OutlineInputBorder _defaultBorder = OutlineInputBorder(borderRadius: _borderRadius);
  late final OutlineInputBorder _enabledBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Color.fromARGB(162, 109, 174, 206), width: 2),
  );
  late final OutlineInputBorder _focusedBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Colors.blue, width: 2),
  );
  late final OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Color.fromRGBO(244, 67, 54, 0.322), width: 2),
  );

  @override
  void initState() {
    super.initState();
    _textController.text = widget.name ?? '';
    _selectedCategory = widget.categoryId;
    _isFavorite = widget.isFavorite ?? false;

    if (widget.phones != null && widget.phones!.isNotEmpty) {
      for (var phone in widget.phones!) {
        _phoneControllers.add(TextEditingController(text: phone['number'] ?? ''));
      }
    } else {
      _phoneControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String formatCell(String s) {
    s = s.replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return '';

    if (s.length >= 11) {
      return '(${s.substring(0, 2)}) ${s.substring(2, 7)}-${s.substring(7, 11)}';
    } else if (s.length >= 7) {
      return '(${s.substring(0, 2)}) ${s.substring(2, 6)}-${s.substring(6)}';
    } else if (s.length >= 3) {
      return '(${s.substring(0, 2)}) ${s.substring(2)}';
    }
    return s;
  }

  InputDecoration _buildInputDecoration(
    String label,
    String hin,
    IconData prefixIcon,
    Widget? suffixIcon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: hin,
      prefixIcon: Icon(prefixIcon, color: const Color.fromARGB(190, 33, 149, 243)),
      suffixIcon: suffixIcon,
      border: _defaultBorder,
      enabledBorder: _enabledBorder,
      focusedBorder: _focusedBorder,
      errorBorder: _errorBorder,
    );
  }

  void _checkPhone(String value, TextEditingController controller) {
    if (!mounted) return;
    String numeros = value.replaceAll(RegExp(r'\D'), '');
    String formatado = formatCell(value);

    if (controller.text != formatado) {
      controller.value = TextEditingValue(
        text: formatado,
        selection: TextSelection.collapsed(offset: formatado.length),
      );
    }
    
    if (_isPhoneValid != (numeros.length == 11)) {
      setState(() {
        _isPhoneValid = numeros.length == 11;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final fileName = '${DateTime.now().microsecondsSinceEpoch}.png';

    try {
      await supabase.storage
          .from('photosContacts')
          .uploadBinary(fileName, await _imageFile!.readAsBytes());

      final String publicUrl = supabase.storage.from('photosContacts').getPublicUrl(fileName);
      print('Url gerada $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Erro na imagem: $e');
      return null;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 150,
      height: 150,
      color: const Color.fromARGB(50, 33, 149, 243),
      child: const Stack(
        children: [
          Positioned(
            bottom: -30,
            left: -10,
            right: -10,
            child: Icon(
              Icons.person_rounded,
              size: 170,
              color: Color.fromARGB(90, 33, 149, 243),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckFavorite() {
    return CheckboxListTile(
      title: const Text('Marcar como favorito'),
      subtitle: const Text('Este contato ficará na sessão "Favoritos"'),
      value: _isFavorite,
      onChanged: (bool? value) {
        setState(() {
          _isFavorite = value ?? false;
        });
      },
      activeColor: Colors.blue,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownInput() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedCategory,
      decoration: _buildInputDecoration(
        'Categoria',
        'Selecione uma categoria',
        Icons.category_outlined,
        null,
      ),
      items: _categories.map((Map<String, dynamic> category) {
        return DropdownMenuItem<int>(
          value: category['id'] as int,
          child: Text(category['label'] as String),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue == null) return;
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? 'Por favor, selecione uma categoria' : null,
    );
  }

  Widget _buildInputText() {
    return TextFormField(
      controller: _textController,
      keyboardType: TextInputType.text,
      onChanged: (value) => setState(() {}),
      decoration: _buildInputDecoration(
        'Nome',
        'Digite o nome do contato',
        Icons.person,
        _textController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _textController.clear();
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  Widget _buildInputNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._phoneControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (val) => _checkPhone(val, controller),
              decoration: _buildInputDecoration(
                index != 0 ? 'Telefone extra' : 'Telefone',
                'Digite o número',
                Icons.call,
                index != 0
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline_outlined, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _phoneControllers.removeAt(index);
                          });
                        },
                      )
                    : null,
              ),
            ),
          );
        }),
        if (_isPhoneValid)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _phoneControllers.add(TextEditingController());
                _isPhoneValid = false;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('adicionar telefone'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Criar Novo Contato',
          style: TextStyle(
            color: Color.fromARGB(190, 33, 149, 243),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color.fromARGB(190, 33, 149, 243),
            size: 25,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(
                Icons.check,
                color: Color.fromARGB(190, 33, 149, 243),
                size: 26,
              ),
              onPressed: () async {
                String? photoUrl = _imageFile != null
                    ? await _uploadImage()
                    : widget.photoUrl;

                List<Map<String, String>> phoneList = _phoneControllers.map((p) {
                  return {'number': p.text, 'label': 'Celular'};
                }).toList();

                if (widget.id != null && _selectedCategory != null) {
                  print('lista de phones $phoneList');
                  await _apiService.editContact(
                    widget.id!,
                    _textController.text,
                    photoUrl,
                    phoneList,
                    _selectedCategory!,
                    _isFavorite,
                  );
                } else if(_selectedCategory != null){
                  await _apiService.createContact(
                    _textController.text,
                    photoUrl,
                    phoneList,
                    _selectedCategory!,
                    _isFavorite,
                  );
                }

                if (mounted) Navigator.pop(context, true);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipOval(
                              child: _imageFile != null
                                  ? Image.file(
                                      _imageFile!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.photoUrl != null && widget.photoUrl!.isNotEmpty)
                                      ? Image.network(
                                          widget.photoUrl!,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              _buildPlaceholder(),
                                        )
                                      : _buildPlaceholder(),
                            ),
                            IgnorePointer(
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(57, 131, 154, 255),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color.fromRGBO(114, 114, 114, 0.302),
                                    width: 4.0,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(66, 123, 230, 1),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add, size: 28, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildInputText(),
            _buildCheckFavorite(),
            const SizedBox(height: 25),
            _buildDropdownInput(),
            const SizedBox(height: 25),
            _buildInputNumber(),
          ],
        ),
      ),
    );
  }
}