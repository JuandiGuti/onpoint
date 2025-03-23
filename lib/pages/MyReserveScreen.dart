import 'package:flutter/material.dart';
import 'package:onpoint/auth_service/AuthService.dart';
import 'package:onpoint/widgets/CustomButton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class MyReserveScreen extends StatefulWidget {
  const MyReserveScreen({super.key});

  @override
  State<MyReserveScreen> createState() => _MyReserveScreenState();
}

class _MyReserveScreenState extends State<MyReserveScreen> {
  final authService = AuthService();
  final email = AuthService().getUserEmail();
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> reservations = [];
  late DateTime displayDate;

  @override
  void initState() {
    super.initState();
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    final user = supabase.auth.currentUser;
    DateTime now = DateTime.now();

    // Si ya son más de las 5 PM, se usan reservas del siguiente día
    if (now.hour >= 17) {
      now = now.add(const Duration(days: 1));
    }

    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    displayDate = now; // Guardamos la fecha que se va a mostrar

    final response = await supabase
        .from('reservations')
        .select('id, start_at, end_at, room, Rooms(name)')
        .eq('owned_by', user!.id)
        .gte('start_at', startOfDay.toIso8601String())
        .lte('start_at', endOfDay.toIso8601String())
        .order('start_at');

    setState(() {
      reservations = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> deleteReservation(String id) async {
    await supabase.from('reservations').delete().eq('id', id);
    fetchReservations(); // Refrescar la lista después de eliminar
  }

  String formatTime(String datetime) {
    final date = DateTime.parse(datetime);
    return DateFormat.Hm().format(date); // Ej: 13:00
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final showDate = today.hour >= 17 ? today.add(const Duration(days: 1)) : today;

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
        onRefresh: fetchReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Mis salas reservadas. Más información en el boton flotante.",
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                reservations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text(
                            "No tienes reservas activas.",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final res = reservations[index];
                          final start = DateFormat.Hm().format(
                            DateTime.parse(res['start_at']).toLocal(),
                          );
                          final end = DateFormat.Hm().format(
                            DateTime.parse(res['end_at']).toLocal(),
                          );
                          final roomName = res['Rooms']['name'];

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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$start - $end",
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                      Text(
                                        roomName,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ],
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
                                        title: const Text("Cancelar reserva"),
                                        content: const Text(
                                            "¿Deseas cancelar esta reserva?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              deleteReservation(res['id']);
                                            },
                                            child: const Text("Eliminar"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancelar"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
      floatingActionButton: infoFloatingButton(context, "Recuerda que las reservas observadas en esta pantalla son para el día de hoy, pero si pasan de las 5 PM, se mostrarán las reservas del siguiente día."),
    );
  }
}
