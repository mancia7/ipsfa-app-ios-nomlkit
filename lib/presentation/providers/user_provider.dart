

import 'package:flutter/material.dart';
import 'package:ipsfa/infrastucture/models/usuario.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User usuario)  {
    _user = usuario;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void updDisponibilidad(String disponibleDoc)  {
    _user!.disponibleDoc = disponibleDoc;
    notifyListeners();
  }

  void updVivencia(String realizoVivencia)  {
    _user!.realizoVivencia = realizoVivencia;
    notifyListeners();
  }

  void updDisponibilidadFotos(String disponibleFotos)  {
    _user!.disponibleFotos = disponibleFotos;
    notifyListeners();
  }

}
