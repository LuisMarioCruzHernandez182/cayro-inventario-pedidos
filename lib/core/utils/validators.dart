class Validators {
  static String? validateUser(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Usuario es requerido';
    }

    final input = value.trim();

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final phoneRegex = RegExp(r'^\d{10}$');

    if (!emailRegex.hasMatch(input) && !phoneRegex.hasMatch(input)) {
      return 'Debe ser un correo válido o un número de teléfono de 10 dígitos';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contraseña es requerida';
    }

    if (value.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }
}
