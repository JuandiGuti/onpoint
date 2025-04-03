import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onpoint/auth_service/AuthService.dart';
import 'package:onpoint/widgets/CustomButton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MakeReserveScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const MakeReserveScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<MakeReserveScreen> createState() => _MakeReserveScreenState();
}

class _MakeReserveScreenState extends State<MakeReserveScreen> {
  final authService = AuthService();
  final email = AuthService().getUserEmail();
  final supabase = Supabase.instance.client;

  DateTime? selectedStartTime;
  int? selectedDuration;
  List<Map<String, dynamic>> reservations = [];

  late DateTime fixedTargetDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final todayFivePM = DateTime(now.year, now.month, now.day, 17);
    fixedTargetDate = now.isBefore(todayFivePM) ? now : now.add(const Duration(days: 1));

    _fetchRoomReservations();
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 6, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              secondary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.hour < 6 || picked.hour >= 17) {
        _showError("La hora debe estar entre 6:00 AM y 5:00 PM.");
        return;
      }
      if(picked.hour < DateTime.now().hour || picked.minute < DateTime.now().minute) {
        _showError("No se puede reservar una sala en el pasado.");
        return;
      }

      final pickedDateTime = DateTime(
        fixedTargetDate.year,
        fixedTargetDate.month,
        fixedTargetDate.day,
        picked.hour,
        picked.minute,
      );

      final existing = await _checkStartConflict(pickedDateTime);
      if (existing) {
        _showError("La hora seleccionada se cruza con otra reserva.");
        return;
      }

      setState(() {
        selectedStartTime = pickedDateTime;
      });

      _selectDuration();
    }
  }

  Future<void> _selectDuration() async {
    final List<int> durations = [10, 20, 30, 40, 50, 60];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Seleccionar duración"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: durations.length,
            itemBuilder: (context, index) {
              final dur = durations[index];
              return ListTile(
                title: Text("$dur minutos"),
                onTap: () async {
                  final valid = await _checkEndConflict(dur);
                  if (!valid) {
                    _showError("La duración invade otra reserva.");
                    return;
                  }

                  setState(() {
                    selectedDuration = dur;
                  });

                  Navigator.pop(context);
                  _confirmReservation();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReservation() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar reserva"),
        content: Text(
          "¿Deseas reservar desde ${DateFormat.Hm().format(selectedStartTime!)} por $selectedDuration minutos?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _makeReservation();
    }
  }

  Future<void> _makeReservation() async {
    final user = supabase.auth.currentUser;
    final start = selectedStartTime!;
    final end = start.add(Duration(minutes: selectedDuration!));

    await supabase.from('reservations').insert({
      'owned_by': user!.id,
      'start_at': start.toIso8601String(),
      'end_at': end.toIso8601String(),
      'duration': selectedDuration! * 60,
      'room': int.tryParse(widget.roomId) ?? 0,
    });

    await _fetchRoomReservations();
    setState(() {});
    _showSuccess("Reserva realizada exitosamente.");
  }

  Future<bool> _checkStartConflict(DateTime startTime) async {
    final startOfDay = DateTime(startTime.year, startTime.month, startTime.day);
    final endOfDay = DateTime(startTime.year, startTime.month, startTime.day, 23, 59, 59);

    final response = await supabase
        .from('reservations')
        .select('start_at, end_at')
        .eq('room', int.tryParse(widget.roomId) ?? 0)
        .gte('start_at', startOfDay.toIso8601String())
        .lte('start_at', endOfDay.toIso8601String());

    for (var res in response) {
      final existingStart = DateTime.parse(res['start_at']);
      final existingEnd = DateTime.parse(res['end_at']);
      if (startTime.isAfter(existingStart) && startTime.isBefore(existingEnd) ||
          startTime.isAtSameMomentAs(existingStart)) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _checkEndConflict(int durationMinutes) async {
    final start = selectedStartTime!;
    final end = start.add(Duration(minutes: durationMinutes));
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(start.year, start.month, start.day, 23, 59, 59);

    final response = await supabase
        .from('reservations')
        .select('start_at, end_at')
        .eq('room', int.tryParse(widget.roomId) ?? 0)
        .gte('start_at', startOfDay.toIso8601String())
        .lte('start_at', endOfDay.toIso8601String());

    for (var res in response) {
      final existingStart = DateTime.parse(res['start_at']);
      final existingEnd = DateTime.parse(res['end_at']);
      if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _fetchRoomReservations() async {
    final date = fixedTargetDate;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final response = await supabase
        .from('reservations')
        .select('start_at, end_at')
        .eq('room', int.tryParse(widget.roomId) ?? 0)
        .gte('start_at', startOfDay.toIso8601String())
        .lte('start_at', endOfDay.toIso8601String());

    setState(() {
      reservations = List<Map<String, dynamic>>.from(response);
    });
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Intentar de nuevo"),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Éxito"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${fixedTargetDate.day}/${fixedTargetDate.month}/${fixedTargetDate.year}";

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
                        child: Text("Cerrar Sesión",
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Aceptar",
                            style: Theme.of(context).textTheme.titleSmall),
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
        onRefresh: _fetchRoomReservations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "HACER MI RESERVA",
                    onPressed: _selectTime,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Reservas actuales para la sala (${widget.roomName}).  Más información en el boton flotante.",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                reservations.isEmpty
                    ? Text(
                        "No hay reservas para esta sala.",
                        style: Theme.of(context).textTheme.bodySmall,
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

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              "$start - $end",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: infoFloatingButton(context, "Recuerda que solo puedes reservar entre las 6:00 AM y 5:00 PM y si pasan de las 5:00 PM reservara el siguiente día."),
    );
  }
}
