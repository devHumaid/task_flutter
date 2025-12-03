import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/core/theme/app_theme.dart';
import 'package:flutter_task/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_bloc.dart';
import 'package:flutter_task/routes/app_router.dart';
import 'package:flutter_task/routes/route_names.dart';
import 'package:flutter_task/injection_container.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        BlocProvider<PersonnelBloc>(
          create: (context) => sl<PersonnelBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Beechem Personnel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: RouteNames.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}