import 'package:flutter/material.dart';
import '../../home/presentation/home_screen.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../../maintenance/presentation/maintenance_screen.dart';
import '../../expenses/presentation/expenses_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  // Las pantallas se mantienen vivas con IndexedStack (mejor para hot reload y estado).
  late final List<Widget> _pages = const [
    HomeScreen(),
    TasksScreen(),
    MaintenanceScreen(),
    ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Hoy'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Tareas'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Mantenimiento'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Gastos'),
        ],
      ),
    );
  }
}
