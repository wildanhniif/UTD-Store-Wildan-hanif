import 'package:flutter/material.dart';
import '../../domain/todo_model.dart';
import '../../data/isar_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // Panggil service yang kita buat tadi
  final IsarService _isarService = IsarService();
  final TextEditingController _textController = TextEditingController();
  
  // Post-Test: Mengelola state Prioritas Note
  String _selectedPrioritas = 'Medium';
  final List<String> _prioritasOptions = ['Tinggi', 'Medium', 'Rendah'];

  // Fungsi memunculkan pop-up tambah data
  void _showAddDialog() {
    _selectedPrioritas = 'Medium'; // Reset default
    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder digunakan agar SetState bekerja khusus di dalam Dialog (Dropdown)
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Catatan Baru"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(hintText: "Mau ngerjain apa hari ini?"),
                  ),
                  const SizedBox(height: 16),
                  
                  // Elemen tambahan UI hasil Post-Test (Dropdown Prioritas)
                  DropdownButtonFormField<String>(
                    value: _selectedPrioritas,
                    decoration: const InputDecoration(labelText: "Prioritas"),
                    items: _prioritasOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setStateDialog(() {
                        _selectedPrioritas = newValue!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Simpan ke database Lokal
                    if (_textController.text.isNotEmpty) {
                      final newTodo = Todo()
                        ..title = _textController.text
                        ..prioritas = _selectedPrioritas // Memasukkan Prioritas
                        ..isCompleted = false;

                      _isarService.saveTodo(newTodo);
                      _textController.clear();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline-First Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),

      // Keajaiban terjadi di sini! StreamBuilder mendengarkan Isar.
      // KITA TIDAK PERLU SETSTATE SAMA SEKALI!
      body: StreamBuilder<List<Todo>>(
        stream: _isarService.listenToTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data ?? [];
          if (todos.isEmpty) {
            return const Center(child: Text("Belum ada catatan."));
          }
          
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Card(
                child: ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      // Beri coretan jika sudah selesai
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  // Tampilkan Post-Test: Teks Prioritas dan warna yang cocok
                  subtitle: Text(
                    'Prioritas: ${todo.prioritas}', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: todo.prioritas == 'Tinggi' ? Colors.red : 
                            (todo.prioritas == 'Medium' ? Colors.orange : Colors.green)
                    ),
                  ),
                  // Checkbox untuk memicu Update Data
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      _isarService.updateTodoStatus(todo.id, value!);
                    },
                  ),
                  // Tombol Hapus (Delete)
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _isarService.deleteTodo(todo.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
