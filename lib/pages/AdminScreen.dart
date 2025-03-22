import 'package:flutter/material.dart';
import 'package:onpoint/widgets/CustomButton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onpoint/widgets/ErrorDialog.dart';
import 'package:onpoint/auth_service/AuthService.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final authService = AuthService();
  final email = AuthService().getUserEmail();
  List<dynamic> rooms = [];

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final response = await supabase.from('Rooms').select();
    setState(() {
      rooms = response;
    });
  }

  Future<void> deleteRoom(String roomId) async {
    await supabase.from('Rooms').delete().eq('id', roomId);
    fetchRooms();
  }

  Future<void> toggleRoomStatus(String roomId, bool currentStatus) async {
    await supabase
        .from('Rooms')
        .update({'active': !currentStatus})
        .eq('id', roomId);
    fetchRooms();
  }

  Future<void> createRoom(String roomName) async {
    if (roomName.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder:
            (context) => ErrorDialog(errorMessage: "Usuario no autenticado."),
      );
      return;
    }

    await supabase.from('Rooms').insert({
      'name': roomName,
      'active': true,
      'created_by': user.id,
    });

    fetchRooms();
  }

  void showCreateRoomDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Crear nueva sala"),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre de la sala"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  createRoom(nameController.text);
                },
                child: Text("Crear"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: Text(
          "ADMIN SALAS",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: IconButton(
              icon: const Icon(Icons.account_circle, size: 35),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          "Haz iniciado sesión como: $email",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await authService.signOut();
                            },
                            child: Text(
                              "Cerrar Sesión",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Aceptar",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchRooms,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "CREAR NUEVA SALA",
                    onPressed: showCreateRoomDialog,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Listado de Salas",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                rooms.isEmpty
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  room['name'],
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                              Row(
                                children: [
                                  Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: room['active'] ?? false,
                                    onChanged: (value) => toggleRoomStatus(
                                    room['id'].toString(),
                                    room['active'],
                                    ),
                                  ),
                                  ),
                                  IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Eliminar sala"),
                                      content: Text(
                                        "¿Estás seguro de eliminar la sala '${room['name']}'?"),
                                      actions: [
                                      TextButton(
                                        onPressed: () {
                                        Navigator.pop(context);
                                        deleteRoom(room['id'].toString());
                                        },
                                        child: Text("Eliminar"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancelar"),
                                      ),
                                      ],
                                    ),
                                    );
                                  },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
