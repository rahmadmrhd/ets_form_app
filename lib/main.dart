import 'package:ets_form_app/nota/nota_detail.dart';
import 'package:ets_form_app/nota/nota_form.dart';
import 'package:ets_form_app/nota/nota_list_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Nota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo[900]!),
        useMaterial3: true,
      ),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case NotaDetail.routeName:
                return const NotaDetail();
              case NotaForm.routeName:
                return const NotaForm();
              case NotaHomePage.routeName:
              default:
                return const NotaHomePage();
            }
          },
        );
      },
    );
  }
}
