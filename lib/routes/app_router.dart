import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/injection_container.dart';
import 'package:flutter_task/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_task/presentation/auth/pages/login_page.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_bloc.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_event.dart';
import 'package:flutter_task/presentation/personnel/pages/personal_list_page.dart';
import 'package:flutter_task/presentation/personnel/pages/personnel_form_page.dart';
import 'package:flutter_task/routes/route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: const LoginPage(),
          ),
        );
        
      case RouteNames.personnelList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<PersonnelBloc>()
              ..add(LoadPersonnelList()),
            child: const PersonnelListPage(),
          ),
        );
        
      case RouteNames.personnelAdd:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<PersonnelBloc>()
              ..add(LoadRoles()),
            child: const PersonnelFormPage(),
          ),
        );
        
      case RouteNames.personnelEdit:
        final personnelId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<PersonnelBloc>()
              ..add(LoadPersonnelDetails(personnelId))
              ..add(LoadRoles()),
            child: PersonnelFormPage(personnelId: personnelId),
          ),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}