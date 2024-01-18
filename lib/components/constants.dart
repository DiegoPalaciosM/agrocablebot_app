import 'package:flutter/material.dart';

const naranja = Color(0xFFFB6542);
const gris = Color(0xFF505160);
const azul = Color(0xFF375E97);
const verde = Color(0xFF8CC640);
const amarillo = Color(0xFFFFBB00);

const dPrimaryColor = Color(0xFF00a65e);
//const lPrimaryColor = Color(0xFF61BB94);
const lPrimaryColor = azul;
const dTextColor = Color(0xFFFFFFFF);
//const lTextColor = Color(0xFF000000);
const lTextColor = Colors.white;
const dBackgroundColor = Color(0xFF000000);
//const lBackgroundColor = Color(0XFFC1D1B1);
const lBackgroundColor = Colors.white;
//const lElevatedColor = Color(0xFF6EA087);
const lElevatedColor = amarillo;
//const lFLoatingColor = Color(0xFF31BB94);
const lFLoatingColor = verde;

const mqttUser = 'imacuna';
const mqttPassword = 'pi';

final Map<String, List<dynamic>> items = {
  'Acciones': [Icons.gamepad_outlined, '/actions'],
  'Configuracion': [Icons.settings, '/config'],
  'Cultivo': [Icons.local_florist, '/crop'],
  'Dashboard': [Icons.dashboard, '/dashboard'],
  'Graficos': [Icons.show_chart_sharp, '/charts'],
  'Sensores': [Icons.sensors, '/realtime']
};
