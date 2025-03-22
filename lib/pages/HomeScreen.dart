import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/AuthService.dart';
import 'package:onpoint/pages/MyReserveScreen.dart';
import 'package:onpoint/widgets/CustomButton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:onpoint/pages/MakeReserveScreen.dart';
import 'package:onpoint/pages/AdminScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  final email = AuthService().getUserEmail();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> rooms = [];
  bool fromAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['fromAdmin'] == true) {
      setState(() {
        fromAdmin = true;
      });
    }
  }

  Future<void> _fetchRooms() async {
    final response = await supabase
        .from('Rooms')
        .select('id, name')
        .eq('active', true);
    setState(() {
      rooms = List<Map<String, dynamic>>.from(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: Text("ON POINT", style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: IconButton(
              icon: const Icon(Icons.account_circle, size: 35),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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
        onRefresh: _fetchRooms,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.only(right: 40, left: 40),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "MIS RESERVAS",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyReserveScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Salas Disponibles para el: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                rooms.isEmpty
                    ? Text(
                        "No hay salas disponibles.",
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return RoomButton(
                            roomId: room['id'].toString(),
                            roomName: room['name'],
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
