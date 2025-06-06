class Notification {
  final int id;
  final String message;
  final String status;

  Notification({this.id = 0, required this.message, required this.status});

  // Método para convertir la notificación a un Map, si se necesita enviar a la API
  Map<String, dynamic> toJson() {
    return {'id': id, 'message': message, 'status': status};
  }
}
