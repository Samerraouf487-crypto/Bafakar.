import 'package:flutter/material.dart';

void main() {
  runApp(const BafakarApp());
}

final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(true);

class Game {
  final String name;
  bool borrowed;
  String? cardNumber;
  String? employeeName;
  DateTime? borrowTime;
  DateTime? returnTime;
  int usageCount;

  Game({
    required this.name,
    this.borrowed = false,
    this.cardNumber,
    this.employeeName,
    this.borrowTime,
    this.returnTime,
    this.usageCount = 0,
  });
}

class Movement {
  final String type;
  final String gameName;
  final String cardNumber;
  final String employeeName;
  final DateTime time;

  Movement({
    required this.type,
    required this.gameName,
    required this.cardNumber,
    required this.employeeName,
    required this.time,
  });
}

class AppData {
  static String currentEmployee = '';
  static bool rushMode = false;
  static bool darkMode = true;

  static final Map<String, String> employees = {
    'Naglaa': '2511',
    'Martha': '4678',
    'Samer': '8900',
  };

  static final List<Game> games = [
    Game(name: 'Chess'),
    Game(name: 'Uno'),
    Game(name: 'Jenga'),
    Game(name: 'Monopoly'),
    Game(name: 'Domino'),
    Game(name: 'Cards'),
  ];

  static final List<Movement> history = [];
}

class BafakarApp extends StatelessWidget {
  const BafakarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Bafakar Games',
          debugShowCheckedModeBanner: false,
          theme: isDark
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xff061b24),
                  primaryColor: const Color(0xffe9b872),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xff061b24),
                    foregroundColor: Colors.white,
                  ),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xffe9b872),
                    secondary: Color(0xffe9b872),
                  ),
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor: const Color(0xfff5f5f5),
                  primaryColor: const Color(0xffe9b872),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xfff5f5f5),
                    foregroundColor: Colors.black,
                  ),
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xffe9b872),
                    secondary: Color(0xffe9b872),
                  ),
                ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

String formatTime(DateTime? time) {
  if (time == null) return '-';
  return '${time.day}/${time.month}/${time.year}  ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

String borrowedSince(DateTime? time) {
  if (time == null) return '-';

  final diff = DateTime.now().difference(time);
  final hours = diff.inHours;
  final minutes = diff.inMinutes % 60;

  if (hours == 0) {
    return '$minutes min ago';
  }

  return '$hours h $minutes min ago';
}

bool isLate(Game game) {
  if (!game.borrowed || game.borrowTime == null) return false;
  return DateTime.now().difference(game.borrowTime!).inHours >= 3;
}

void showMsg(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  String error = '';

  void login() {
    final user = username.text.trim();
    final pass = password.text.trim();

    if (AppData.employees[user] == pass) {
      AppData.currentEmployee = user;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() => error = 'Wrong username or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpeg',
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.sports_esports,
                  size: 90,
                  color: Color(0xffe9b872),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Bafakar Games Tracking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('نظام تتبع الألعاب'),
            const SizedBox(height: 35),
            appInput(username, 'Username', Icons.person),
            const SizedBox(height: 15),
            appInput(password, 'Password', Icons.lock, obscure: true),
            const SizedBox(height: 25),
            mainButton('Login', login),
            const SizedBox(height: 15),
            Text(error, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final search = TextEditingController();
  String filter = 'all';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      startReminder();
    });
  }

  void startReminder() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(hours: 1));

      if (!mounted) return false;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reminder'),
          content: const Text(
            'Please organize the wardrobe\nبرجاء تنظيم الدولاب',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return true;
    });
  }

  List<Game> get filteredGames {
    final q = search.text.trim().toLowerCase();
    List<Game> games = AppData.games;

    if (filter == 'available') {
      games = games.where((g) => !g.borrowed).toList();
    }

    if (filter == 'borrowed') {
      games = games.where((g) => g.borrowed).toList();
    }

    if (filter == 'late') {
      games = games.where((g) => isLate(g)).toList();
    }

    if (q.isNotEmpty) {
      games = games.where((g) {
        return g.name.toLowerCase().contains(q) ||
            (g.cardNumber ?? '').toLowerCase().contains(q);
      }).toList();
    }

    return games;
  }

  @override
  Widget build(BuildContext context) {
    final total = AppData.games.length;
    final borrowed = AppData.games.where((g) => g.borrowed).length;
    final available = total - borrowed;
    final late = AppData.games.where((g) => isLate(g)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppData.currentEmployee = '';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                statCard('Total', total.toString(), Icons.grid_view),
                statCard('Borrowed', borrowed.toString(), Icons.logout),
                statCard('Available', available.toString(), Icons.check_circle),
                statCard('Late', late.toString(), Icons.warning_amber),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: fieldDecoration(
                'Search by card number or game name',
                Icons.search,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: filterButton(
                    'All',
                    filter == 'all',
                    () => setState(() => filter = 'all'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: filterButton(
                    'Available',
                    filter == 'available',
                    () => setState(() => filter = 'available'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: filterButton(
                    'Borrowed',
                    filter == 'borrowed',
                    () => setState(() => filter = 'borrowed'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: filterButton(
                    'Late',
                    filter == 'late',
                    () => setState(() => filter = 'late'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: mainButton('Borrow', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BorrowScreen()),
                    ).then((_) => setState(() {}));
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: mainButton('Return', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReturnScreen()),
                    ).then((_) => setState(() {}));
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: mainButton('History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: mainButton('Stats', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsScreen()),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: mainButton('Add Game', () {
                    if (AppData.currentEmployee != 'Samer') {
                      showMsg(context, 'Only Samer can add games');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddGameScreen()),
                    ).then((_) => setState(() {}));
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: mainButton('Manage Users', () {
                    if (AppData.currentEmployee != 'Samer') {
                      showMsg(context, 'Only Samer can manage users');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddUserScreen()),
                    ).then((_) => setState(() {}));
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            mainButton(
              AppData.rushMode ? 'Rush Mode: ON' : 'Rush Mode: OFF',
              () {
                if (AppData.currentEmployee != 'Samer') {
                  showMsg(context, 'Only Samer can control Rush Mode');
                  return;
                }
                setState(() => AppData.rushMode = !AppData.rushMode);
                showMsg(
                  context,
                  AppData.rushMode
                      ? 'Rush Mode Enabled'
                      : 'Rush Mode Disabled',
                );
              },
            ),
            const SizedBox(height: 8),
            mainButton(
              AppData.darkMode ? 'Mode: Dark' : 'Mode: Light',
              () {
                if (AppData.currentEmployee != 'Samer') {
                  showMsg(context, 'Only Samer can change mode');
                  return;
                }

                setState(() {
                  AppData.darkMode = !AppData.darkMode;
                  themeNotifier.value = AppData.darkMode;
                });

                showMsg(
                  context,
                  AppData.darkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled',
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredGames.isEmpty
                  ? const Center(child: Text('No games found'))
                  : ListView.builder(
                      itemCount: filteredGames.length,
                      itemBuilder: (_, i) {
                        final g = filteredGames[i];
                        final lateGame = isLate(g);

                        return appCard(
                          child: ListTile(
                            leading: Icon(
                              lateGame
                                  ? Icons.warning_amber
                                  : g.borrowed
                                      ? Icons.logout
                                      : Icons.check_circle_outline,
                              color: lateGame
                                  ? Colors.redAccent
                                  : g.borrowed
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent,
                            ),
                            title: Text(g.name),
                            subtitle: Text(
                              g.borrowed
                                  ? 'Status: Borrowed\nCard: ${g.cardNumber ?? "-"}\nBy: ${g.employeeName ?? "-"}\nTaken At: ${formatTime(g.borrowTime)}\nBorrowed Since: ${borrowedSince(g.borrowTime)}\n${lateGame ? "Late: More than 3 hours" : ""}'
                                  : 'Status: Available\nLast Return: ${formatTime(g.returnTime)}\nUsed: ${g.usageCount} times',
                            ),
                            trailing: AppData.currentEmployee == 'Samer'
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      if (g.borrowed) {
                                        showMsg(
                                          context,
                                          'Cannot delete borrowed game',
                                        );
                                        return;
                                      }
                                      setState(() {
                                        AppData.games.remove(g);
                                      });
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  final cardNumber = TextEditingController();
  final pinController = TextEditingController();

  String selectedEmployee = 'Naglaa';
  Game? selectedGame;
  String msg = '';

  void borrowGame() {
    final card = cardNumber.text.trim();
    final pin = pinController.text.trim();

    if (!AppData.rushMode && AppData.employees[selectedEmployee] != pin) {
      setState(() => msg = 'Wrong employee PIN');
      return;
    }

    if (card.isEmpty) {
      setState(() => msg = 'Enter card number');
      return;
    }

    if (selectedGame == null) {
      setState(() => msg = 'Select a game');
      return;
    }

    final cardAlreadyUsed = AppData.games.any(
      (g) => g.borrowed && g.cardNumber == card,
    );

    if (cardAlreadyUsed) {
      setState(() => msg = 'This card already has a game');
      return;
    }

    final selected = selectedGame!;

    selected.borrowed = true;
    selected.cardNumber = card;
    selected.employeeName = selectedEmployee;
    selected.borrowTime = DateTime.now();
    selected.returnTime = null;
    selected.usageCount++;

    AppData.history.add(
      Movement(
        type: 'Borrow',
        gameName: selected.name,
        cardNumber: card,
        employeeName: selectedEmployee,
        time: DateTime.now(),
      ),
    );

    setState(() {
      msg = 'Game borrowed successfully';
      cardNumber.clear();
      pinController.clear();
      selectedGame = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableGames = AppData.games.where((g) => !g.borrowed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Borrow Game')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            appInput(cardNumber, 'Card Number', Icons.credit_card),
            const SizedBox(height: 12),
            employeeDropdown(
              selectedEmployee,
              (v) => setState(() => selectedEmployee = v!),
            ),
            if (!AppData.rushMode) ...[
              const SizedBox(height: 12),
              appInput(pinController, 'Employee PIN', Icons.lock, obscure: true),
            ],
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Game',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: availableGames.isEmpty
                  ? const Center(child: Text('No available games'))
                  : ListView.builder(
                      itemCount: availableGames.length,
                      itemBuilder: (_, i) {
                        final g = availableGames[i];
                        final selected = selectedGame == g;

                        return GestureDetector(
                          onTap: () => setState(() => selectedGame = g),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xffe9b872)
                                  : cardColor(),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.casino,
                                  color:
                                      selected ? Colors.black : textColor(),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  g.name,
                                  style: TextStyle(
                                    color:
                                        selected ? Colors.black : textColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Text(msg),
            const SizedBox(height: 12),
            mainButton('Borrow Game', borrowGame),
          ],
        ),
      ),
    );
  }
}

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final search = TextEditingController();
  final pinController = TextEditingController();

  String selectedEmployee = 'Naglaa';
  String msg = '';

  void returnGame() {
    final q = search.text.trim().toLowerCase();
    final pin = pinController.text.trim();

    if (!AppData.rushMode && AppData.employees[selectedEmployee] != pin) {
      setState(() => msg = 'Wrong employee PIN');
      return;
    }

    if (q.isEmpty) {
      setState(() => msg = 'Enter card number or game name');
      return;
    }

    Game? selected;

    for (final g in AppData.games) {
      if (g.borrowed &&
          (g.name.toLowerCase() == q ||
              (g.cardNumber ?? '').toLowerCase() == q)) {
        selected = g;
      }
    }

    if (selected == null) {
      setState(() => msg = 'No active borrowed game found');
      return;
    }

    final oldCard = selected.cardNumber ?? '-';

    selected.returnTime = DateTime.now();
    selected.borrowed = false;
    selected.cardNumber = null;
    selected.employeeName = selectedEmployee;
    selected.borrowTime = null;

    AppData.history.add(
      Movement(
        type: 'Return',
        gameName: selected.name,
        cardNumber: oldCard,
        employeeName: selectedEmployee,
        time: DateTime.now(),
      ),
    );

    setState(() {
      msg = 'Game returned successfully';
      search.clear();
      pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            appInput(search, 'Card Number or Game Name', Icons.search),
            const SizedBox(height: 12),
            employeeDropdown(
              selectedEmployee,
              (v) => setState(() => selectedEmployee = v!),
            ),
            if (!AppData.rushMode) ...[
              const SizedBox(height: 12),
              appInput(pinController, 'Employee PIN', Icons.lock, obscure: true),
            ],
            const SizedBox(height: 20),
            mainButton('Return Game', returnGame),
            const SizedBox(height: 15),
            Text(msg),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppData.history.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.isEmpty
          ? const Center(child: Text('No history yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: history.length,
              itemBuilder: (_, i) {
                final h = history[i];

                return appCard(
                  child: ListTile(
                    leading: Icon(
                      h.type == 'Borrow'
                          ? Icons.logout
                          : Icons.keyboard_return,
                      color: h.type == 'Borrow'
                          ? Colors.orangeAccent
                          : Colors.greenAccent,
                    ),
                    title: Text('${h.type} - ${h.gameName}'),
                    subtitle: Text(
                      'Card: ${h.cardNumber}\nEmployee: ${h.employeeName}\nTime: ${formatTime(h.time)}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final todayBorrows = AppData.history.where((h) {
      return h.type == 'Borrow' &&
          h.time.day == today.day &&
          h.time.month == today.month &&
          h.time.year == today.year;
    }).toList();

    String topGame = '-';
    int topGameCount = 0;

    for (final game in AppData.games) {
      if (game.usageCount > topGameCount) {
        topGame = game.name;
        topGameCount = game.usageCount;
      }
    }

    final Map<String, int> employeeCount = {};

    for (final h in todayBorrows) {
      employeeCount[h.employeeName] = (employeeCount[h.employeeName] ?? 0) + 1;
    }

    String topEmployee = '-';
    int topEmployeeCount = 0;

    employeeCount.forEach((employee, count) {
      if (count > topEmployeeCount) {
        topEmployee = employee;
        topEmployeeCount = count;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Stats')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            appCard(
              child: ListTile(
                leading: const Icon(Icons.today, color: Color(0xffe9b872)),
                title: const Text('Games Borrowed Today'),
                trailing: Text(
                  todayBorrows.length.toString(),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            appCard(
              child: ListTile(
                leading: const Icon(Icons.star, color: Color(0xffe9b872)),
                title: const Text('Most Used Game'),
                subtitle: Text(topGame),
                trailing: Text(topGameCount.toString()),
              ),
            ),
            appCard(
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xffe9b872)),
                title: const Text('Top Employee Today'),
                subtitle: Text(topEmployee),
                trailing: Text(topEmployeeCount.toString()),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Game Usage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: AppData.games.map((g) {
                  return appCard(
                    child: ListTile(
                      title: Text(g.name),
                      trailing: Text('${g.usageCount} times'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final gameName = TextEditingController();
  final copiesController = TextEditingController(text: '1');
  String msg = '';

  void addGame() {
    final name = gameName.text.trim();
    final copies = int.tryParse(copiesController.text.trim()) ?? 1;

    if (AppData.currentEmployee != 'Samer') {
      setState(() => msg = 'Only Samer can add games');
      return;
    }

    if (name.isEmpty) {
      setState(() => msg = 'Enter game name');
      return;
    }

    if (copies <= 0) {
      setState(() => msg = 'Copies must be at least 1');
      return;
    }

    for (int i = 1; i <= copies; i++) {
      final gameFinalName = copies == 1 ? name : '$name Copy $i';
      AppData.games.add(Game(name: gameFinalName));
    }

    setState(() {
      msg = '$copies copy/copies added successfully';
      gameName.clear();
      copiesController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            appInput(gameName, 'Game Name', Icons.sports_esports),
            const SizedBox(height: 12),
            appInput(copiesController, 'Copies', Icons.copy),
            const SizedBox(height: 20),
            mainButton('Add Game', addGame),
            const SizedBox(height: 15),
            Text(msg),
          ],
        ),
      ),
    );
  }
}

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final newUsername = TextEditingController();
  final newPassword = TextEditingController();

  String msg = '';

  void addUser() {
    final username = newUsername.text.trim();
    final password = newPassword.text.trim();

    if (AppData.currentEmployee != 'Samer') {
      setState(() => msg = 'Only Samer can manage users');
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      setState(() => msg = 'Enter username and password');
      return;
    }

    if (AppData.employees.containsKey(username)) {
      setState(() => msg = 'User already exists');
      return;
    }

    AppData.employees[username] = password;

    setState(() {
      msg = 'User added successfully';
      newUsername.clear();
      newPassword.clear();
    });
  }

  void deleteUser(String username) {
    if (AppData.currentEmployee != 'Samer') {
      setState(() => msg = 'Only Samer can delete users');
      return;
    }

    if (username == 'Samer') {
      setState(() => msg = 'Samer cannot be deleted');
      return;
    }

    setState(() {
      AppData.employees.remove(username);
      msg = '$username deleted successfully';
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = AppData.employees.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            appInput(newUsername, 'New Username', Icons.person_add),
            const SizedBox(height: 12),
            appInput(newPassword, 'New Password', Icons.lock, obscure: true),
            const SizedBox(height: 20),
            mainButton('Add User', addUser),
            const SizedBox(height: 15),
            Text(msg),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final user = users[i];

                  return appCard(
                    child: ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xffe9b872),
                      ),
                      title: Text(user),
                      subtitle: Text(user == 'Samer' ? 'Admin' : 'Employee'),
                      trailing: user == 'Samer'
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => deleteUser(user),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget employeeDropdown(String selected, ValueChanged<String?> onChanged) {
  return DropdownButtonFormField<String>(
    value: selected,
    dropdownColor: cardColor(),
    decoration: fieldDecoration('Employee', Icons.person),
    items: AppData.employees.keys.map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e),
      );
    }).toList(),
    onChanged: onChanged,
  );
}

Widget appInput(
  TextEditingController controller,
  String hint,
  IconData icon, {
  bool obscure = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: hint == 'Copies' ? TextInputType.number : TextInputType.text,
    decoration: fieldDecoration(hint, icon),
  );
}

InputDecoration fieldDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: const Color(0xffe9b872)),
    filled: true,
    fillColor: cardColor(),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

Widget mainButton(String text, VoidCallback onTap) {
  return SizedBox(
    height: 52,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffe9b872),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}

Widget filterButton(String text, bool active, VoidCallback onTap) {
  return SizedBox(
    height: 45,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xffe9b872) : cardColor(),
        foregroundColor: active ? Colors.black : textColor(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    ),
  );
}

Widget statCard(String title, String value, IconData icon) {
  return Expanded(
    child: appCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xffe9b872), size: 18),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget appCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.all(5),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: cardColor(),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

Color cardColor() {
  return AppData.darkMode ? const Color(0xff102f3c) : Colors.white;
}

Color textColor() {
  return AppData.darkMode ? Colors.white : Colors.black;
}
