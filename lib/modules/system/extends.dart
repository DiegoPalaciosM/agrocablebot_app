/// Extensión de Dart para la clase `String`.
extension StringExtension on String {
  /// Método para capitalizar la primera letra de la cadena.
  ///
  /// Devuelve la cadena con la primera letra en mayúscula y el resto de la cadena en minúscula.
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

/// Extensión de Dart para la clase `double`.
extension DoubleExtension on double {
  /// Método para redondear un número de tipo `double` a un número específico de decimales.
  ///
  /// [n]: El número de decimales a los que se debe redondear.
  ///
  /// Devuelve el número redondeado con el número especificado de decimales.
  double roundDecimals(int n) => double.parse(toStringAsFixed(n));
}
