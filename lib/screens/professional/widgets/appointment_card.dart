import 'package:flutter/material.dart';
import 'package:mihnati2/common/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (appointment.status == 'مؤكدة') statusColor = Colors.green;
    if (appointment.status == 'ملغاة') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1F3440).withOpacity(0.1),
          child: const Icon(Icons.person, color: Color(0xFF1F3440)),
        ),
        title: Text(
          appointment.clientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.serviceName),
            Text('${appointment.date} | ${appointment.time}'),
            Text(appointment.address, maxLines: 1),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            appointment.status,
            style: TextStyle(color: statusColor),
          ),
        ),
      ),
    );
  }
}
