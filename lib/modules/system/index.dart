import 'dart:math' as math;

/// Función para calcular el índice de una selección en una cuadrícula bidimensional.
///
/// [selected]: El número de elementos seleccionados.
/// [total]: El número total de elementos en la cuadrícula.
///
/// Devuelve una lista con las coordenadas (fila, columna) del elemento seleccionado.

getIndex(selected, total) {
  var res = selected / math.sqrt(total);
  var row = res.truncate();
  var column = ((res - row) * math.sqrt(total)).round();
  return [column - 4, 4 - row];
}

/// Función para calcular el elemento seleccionado en una cuadrícula bidimensional a partir de las coordenadas x e y.
///
/// [payload]: Un mapa que contiene las coordenadas x e y del punto seleccionado.
/// [total]: El número total de elementos en la cuadrícula.
/// [radius]: El radio de la cuadrícula.
///
/// Devuelve el índice del elemento seleccionado en la cuadrícula.

getSelected(payload, total, radius) {
  double res = 0;
  double x = 0;
  double y = 0;
  x = payload['x'] * 1.0;
  y = payload['y'] * 1.0;
  res = (x + (4 * radius)) + ((-y + (4 * radius)) * math.sqrt(total));
  res = (res / 100);
  return res.round();
}
