// Tarea 6 - Rainer Cruz - Matrícula 2025-0061
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

Future<dynamic> getJson(String url) async {
  final r = await http.get(Uri.parse(url));
  if (r.statusCode != 200) throw Exception('Error ${r.statusCode}');
  return jsonDecode(utf8.decode(r.bodyBytes));
}

Future<void> openUrl(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

class FutureBox<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;
  const FutureBox({super.key, required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (future == null) return const SizedBox();
    return FutureBuilder<T>(
      future: future,
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError) return Center(child: Text('Error: ${s.error}'));
        return builder(s.data as T);
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Tarea 6',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final items = <(String, IconData, Widget)>[
    ('Caja de herramientas', Icons.handyman, const ToolboxPage()),
    ('Género por nombre', Icons.person_search, const GenderPage()),
    ('Persona aleatoria', Icons.casino, const RandomUserPage()),
    ('Universidades', Icons.school, const UniversitiesPage()),
    ('Clima en RD', Icons.wb_sunny, const WeatherPage()),
    ('Pokémon', Icons.catching_pokemon, const PokemonPage()),
    ('WordPress', Icons.article, const WordPressPage()),
    ('Acerca de', Icons.info, const AboutPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(items[index].$1)),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Tarea 6', style: TextStyle(fontSize: 28)),
            ),
            for (var i = 0; i < items.length; i++)
              ListTile(
                leading: Icon(items[i].$2),
                title: Text(items[i].$1),
                selected: i == index,
                onTap: () {
                  setState(() => index = i);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: items[index].$3,
    );
  }
}

// 1. Caja de herramientas
class ToolboxPage extends StatelessWidget {
  const ToolboxPage({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/toolbox.jpg',
            height: 280,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.handyman, size: 200),
          ),
          const SizedBox(height: 16),
          const Text('Esta aplicación sirve para varias cosas.',
              style: TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );
}

// 2. Género
class GenderPage extends StatefulWidget {
  const GenderPage({super.key});
  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  final ctrl = TextEditingController();
  Future<dynamic>? future;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              labelText: 'Nombre', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),

        FilledButton(
          onPressed: () {
            setState(() {
              future = getJson(
                  'https://api.genderize.io/?name=${Uri.encodeQueryComponent(ctrl.text.trim())}');
            });
          },
          child: const Text('Predecir género'),
        ),


        const SizedBox(height: 16),
        Expanded(
          child: FutureBox<dynamic>(
            future: future,
            builder: (d) {
              final g = d['gender'];
              final color = g == 'male'
                  ? Colors.blue
                  : g == 'female'
                  ? Colors.pink.shade200
                  : Colors.grey;
              final texto = g == 'male'
                  ? 'Masculino'
                  : g == 'female'
                  ? 'Femenino'
                  : 'No se pudo predecir';
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text(
                    '$texto\n(${((d['probability'] ?? 0) * 100).round()}%)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// 3. Persona aleatoria
class RandomUserPage extends StatefulWidget {
  const RandomUserPage({super.key});
  @override
  State<RandomUserPage> createState() => _RandomUserPageState();
}

class _RandomUserPageState extends State<RandomUserPage> {
  late Future<dynamic> future;
  void load() => future = getJson('https://randomuser.me/api/?results=1');

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: FutureBox<dynamic>(
          future: future,
          builder: (d) {
            final u = d['results'][0];
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(u['picture']['large'])),
                const SizedBox(height: 16),
                Text('${u['name']['first']} ${u['name']['last']}',
                    style: const TextStyle(fontSize: 24)),
                Text('Nacimiento: ${u['dob']['date'].toString().substring(0, 10)}'),
                Text('Edad: ${u['dob']['age']} años'),
              ]),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
            onPressed: () => setState(load), child: const Text('Otra persona')),
      ),
    ]);
  }
}

// 4. Universidades
class UniversitiesPage extends StatefulWidget {
  const UniversitiesPage({super.key});
  @override
  State<UniversitiesPage> createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage> {
  final ctrl = TextEditingController(text: 'Dominican Republic');
  Future<dynamic>? future;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              labelText: 'País (en inglés)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            setState(() {
              future = getJson(
                  'https://adamix.net/proxy.php?country=${Uri.encodeQueryComponent(ctrl.text.trim())}');
            });
          },
          child: const Text('Buscar universidades'),
        ),
        Expanded(
          child: FutureBox<dynamic>(
            future: future,
            builder: (d) {
              final list = d as List;
              if (list.isEmpty) {
                return const Center(child: Text('Sin resultados'));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final u = list[i];
                  final web = (u['web_pages'] as List).isNotEmpty
                      ? u['web_pages'][0].toString()
                      : '';
                  return Card(
                    child: ListTile(
                      title: Text(u['name'].toString()),
                      subtitle: Text(
                          'Dominio: ${(u['domains'] as List).join(", ")}\n$web'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.open_in_new),
                      onTap: web.isEmpty ? null : () => openUrl(web),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

// 5. Clima en RD (Open-Meteo, sin API key)
class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  String desc(int c) {
    if (c == 0) return 'Despejado';
    if (c <= 3) return 'Parcialmente nublado';
    if (c <= 48) return 'Neblina';
    if (c <= 67) return 'Lluvia';
    if (c <= 82) return 'Chubascos';
    return 'Tormenta eléctrica';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBox<dynamic>(
      future: getJson(
          'https://api.open-meteo.com/v1/forecast?latitude=18.49&longitude=-69.93'
              '&current=temperature_2m'
              '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode'
              '&timezone=America%2FSanto_Domingo&forecast_days=1'),
      builder: (d) {
        final dl = d['daily'];
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Santo Domingo, RD', style: TextStyle(fontSize: 22)),
            Text('${d['current']['temperature_2m']}°C',
                style: const TextStyle(fontSize: 64)),
            Text(desc(dl['weathercode'][0]),
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 12),
            Text('Máx ${dl['temperature_2m_max'][0]}°C  /  Mín ${dl['temperature_2m_min'][0]}°C'),
            Text('Prob. de lluvia: ${dl['precipitation_probability_max'][0]}%'),
            Text('Fecha: ${dl['time'][0]}'),
          ]),
        );
      },
    );
  }
}

// 6. Pokémon
class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});
  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final ctrl = TextEditingController();
  final player = AudioPlayer();
  Future<dynamic>? future;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              labelText: 'Nombre del Pokémon (ej: pikachu)',
              border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            setState(() {
              future = getJson(
                  'https://pokeapi.co/api/v2/pokemon/${ctrl.text.trim().toLowerCase()}');
            });
          },
          child: const Text('Buscar'),
        ),
        Expanded(
          child: FutureBox<dynamic>(
            future: future,
            builder: (d) {
              final abilities = (d['abilities'] as List)
                  .map((a) => a['ability']['name'])
                  .join(', ');
              final cry = d['cries']?['latest'];
              return SingleChildScrollView(
                child: Column(children: [
                  Image.network(d['sprites']['front_default'] ?? '',
                      height: 200,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 120)),
                  Text(d['name'].toString().toUpperCase(),
                      style: const TextStyle(fontSize: 26)),
                  Text('Experiencia base: ${d['base_experience']}'),
                  Text('Habilidades: $abilities'),
                  const SizedBox(height: 8),
                  if (cry != null)
                    FilledButton.icon(
                      onPressed: () => player.play(UrlSource(cry)),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Escuchar sonido'),
                    ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// 7. WordPress (cambia el sitio aquí si quieres otro)
const wpSite = 'https://kinsta.com';

class WordPressPage extends StatelessWidget {
  const WordPressPage({super.key});

  String clean(String html) => html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&#8217;', "'")
      .replaceAll('&#8220;', '"')
      .replaceAll('&#8221;', '"')
      .replaceAll('&hellip;', '...')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();

  Future<List<dynamic>> load() async => [
    await getJson('$wpSite/wp-json'),
    await getJson('$wpSite/wp-json/wp/v2/posts?per_page=3'),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBox<List<dynamic>>(
      future: load(),
      builder: (data) {
        final info = data[0];
        final posts = data[1] as List;
        final icon = info['site_icon_url']?.toString() ?? '';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: icon.isEmpty
                  ? const Icon(Icons.public, size: 80)
                  : Image.network(icon, height: 80),
            ),
            Center(
              child: Text(info['name'].toString(),
                  style: const TextStyle(fontSize: 22)),
            ),
            const Divider(height: 32),
            for (final p in posts)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clean(p['title']['rendered']),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(clean(p['excerpt']['rendered'])),
                        TextButton(
                          onPressed: () => openUrl(p['link']),
                          child: const Text('Visitar'),
                        ),
                      ]),
                ),
              ),
          ],
        );
      },
    );
  }
}

// 8. Acerca de
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircleAvatar(
          radius: 80, backgroundImage: AssetImage('assets/foto.jpeg')),
      const SizedBox(height: 16),
      const Text('Rainer Cruz', style: TextStyle(fontSize: 26)),
      const Text('Desarrollador de software'),
      const SizedBox(height: 16),
      const ListTile(
          leading: Icon(Icons.email), title: Text('rainercruzdelarosa@gmail.com')),
      const ListTile(
          leading: Icon(Icons.phone), title: Text('8295635112')),
      ListTile(
        leading: const Icon(Icons.code),
        title: const Text('github.com/SoyRainerxd'),
        onTap: () => openUrl('https://github.com/TU_USUARIO'),
      ),
    ]),
  );
}