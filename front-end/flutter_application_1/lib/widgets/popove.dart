import 'package:flutter/material.dart';

class CallModal extends StatelessWidget{
  final String number;
  final String? formatCell;

  const CallModal({
    super.key,
    required this.number,
    this.formatCell
  });

  @override
  Widget build(BuildContext context){
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
            const Icon(Icons.add_ic_call_sharp, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              number.isNotEmpty ? 'Chamada realizada' : 'Chamada falhou',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              number.isNotEmpty
                  ? 'Para: ${formatCell ?? number}'
                  : 'Digite um número válido para realizar ligação',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fechar'),
            ),
          ],
        ),
      );
  }
}
