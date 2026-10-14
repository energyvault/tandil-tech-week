import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/event_request_page.dart';
import 'pages/sponsor_request_page.dart';

void main() => runApp(const TechWeekApp());

const electricBlue = Color(0xFF39FF72);
const neonGreen = Color(0xFF39FF72);
const ink = Color(0xFFF0FFF3);
const paper = Color(0xFF030604);

// Reemplazá esta URL por el canal real de Twitch del evento.

const twitchChannelUrl = 'https://www.twitch.tv/';

String googleCalendarUrl(DemoEvent event) {
  // Demo events are scheduled for 17 September 2026, Argentina time (UTC-3).
  final startHour = int.parse(event.time.split(':')[0]);
  final startMinute = int.parse(event.time.split(':')[1]);
  final start = DateTime.utc(2026, 9, 17, startHour + 3, startMinute);
  final end = start.add(Duration(minutes: event.durationMinutes));
  String stamp(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}T'
      '${value.hour.toString().padLeft(2, '0')}'
      '${value.minute.toString().padLeft(2, '0')}00Z';
  final params = <String, String>{
    'action': 'TEMPLATE',
    'text': event.title,
    'dates': '${stamp(start)}/${stamp(end)}',
    'details': event.description,
    'location': '${event.place}, Tandil, Buenos Aires, Argentina',
  };
  return 'https://calendar.google.com/calendar/render?${Uri(queryParameters: params).query}';
}


class TechWeekApp extends StatelessWidget {
  const TechWeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tandil Tech Week 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(seedColor: electricBlue),
        fontFamily: 'Arial',
      ),
      home: Uri.base.queryParameters['event'] == null
          ? const HomePage()
          : EventDetailPage(
              event: demoEvents.firstWhere(
                (item) => item.slug == Uri.base.queryParameters['event'],
                orElse: () => demoEvents.first,
              ),
            ),
    );
  }
}

class DemoEvent {
  final String day, month, time, title, category, place, description;
  final String slug;
  final String duration;
  final String audience;
  final String schedule;
  final bool isLive;
  final int durationMinutes;
  const DemoEvent(this.day, this.month, this.time, this.title, this.category,
      this.place, this.description, this.slug, this.duration, this.audience,
      this.schedule, this.isLive, this.durationMinutes);
}

const demoEvents = [
  DemoEvent('17', 'SEP', '09:30', 'Apertura & bienvenida', 'COMUNIDAD',
      'Campus tecnológico', 'Arrancamos la jornada conectando ideas, personas y proyectos.',
      'apertura', '45 minutos', 'Público general', '09:30 — Acreditación y bienvenida\\n09:45 — Presentación de la jornada\\n10:00 — Inicio de actividades', false, 45),
  DemoEvent('17', 'SEP', '11:00', 'Hacking Day', 'HACKATHON',
      'Auditorio principal', 'Un espacio para crear soluciones, trabajar en equipo y experimentar.',
      'hacking-day', '4 horas', 'Desarrolladores, estudiantes y personas creativas', '11:00 — Presentación del desafío\\n11:30 — Formación de equipos\\n12:00 — Construcción de prototipos\\n14:30 — Demo de proyectos', true, 240),
  DemoEvent('17', 'SEP', '14:30', 'Startup Day', 'EMPRENDIMIENTO',
      'Sala de conferencias', 'Charlas, ideas y experiencias para convertir proyectos en realidad.',
      'startup-day', '2 horas', 'Emprendedores, estudiantes y equipos de producto', '14:30 — Apertura\\n14:45 — Charlas inspiradoras\\n15:30 — Ideas y oportunidades\\n16:15 — Preguntas y networking', true, 120),
  DemoEvent('17', 'SEP', '17:00', 'Demo & networking', 'NETWORKING',
      'Espacio central', 'Compartí lo que hiciste y conocé a quienes están construyendo el futuro.',
      'networking', '1 hora', 'Toda la comunidad', '17:00 — Muestra de proyectos\\n17:30 — Networking abierto\\n18:00 — Cierre de la jornada', false, 90),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final agendaKey = GlobalKey();
  final organizersKey = GlobalKey();
  final sponsorsKey = GlobalKey();
  final eventKey = GlobalKey();

  void goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
          alignment: 0.04);
    }
  }

  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: paper,
              surfaceTintColor: paper,
              toolbarHeight: 72,
              titleSpacing: 24,
              title: InkWell(
                onTap: () => goTo(eventKey),
                child: const Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Icon(Icons.circle, color: neonGreen, size: 10),
                    Text('TANDIL TECH WEEK',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                            letterSpacing: 1.5, color: ink)),
                    Text('2026', style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w900, letterSpacing: 1.5,
                        color: electricBlue)),
                  ],
                ),
              ),
              actions: [
                if (MediaQuery.sizeOf(context).width > 680) ...[
                  _NavItem('AGENDA', () => goTo(agendaKey)),
                  _NavItem('ORGANIZAN', () => goTo(organizersKey)),
                  _NavItem('SPONSORS', () => goTo(sponsorsKey)),
                ],
                IconButton(
                  tooltip: 'Instagram',
                  onPressed: () => openLink('https://www.instagram.com/'),
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                ),
                IconButton(
                  tooltip: 'X',
                  onPressed: () => openLink('https://x.com/'),
                  icon: const Icon(Icons.close, size: 20),
                ),
                const SizedBox(width: 12),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(height: 3, color: const Color(0xFF173B24)),
                  Container(
                    key: eventKey,
                    width: double.infinity,
                    color: const Color(0xFF050906),
                    padding: const EdgeInsets.fromLTRB(24, 74, 24, 54),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              color: paper,
                              child: const Text('INSCRIPCIONES 2026',
                                  style: TextStyle(color: electricBlue, fontSize: 11,
                                      fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                            ),
                            const SizedBox(height: 28),
                            const Text('Construyamos\njuntos lo que viene.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: ink, fontSize: 64,
                                    height: .98, fontWeight: FontWeight.w900,
                                    letterSpacing: -3.2)),
                            const SizedBox(height: 26),
                            const SizedBox(
                              width: 540,
                              child: Text(
                                'Un encuentro para quienes imaginan, crean y transforman el futuro con tecnología.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: const Color(0xFFD2DED5), fontSize: 20, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 42),
                            const Text('¡La próxima gran idea puede ser la tuya!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: ink, fontSize: 25,
                                    fontWeight: FontWeight.w900, letterSpacing: -.6)),
                            const SizedBox(height: 24),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 14,
                              runSpacing: 12,
                              children: [
                                _HeroButton('VER AGENDA', false, () => goTo(agendaKey)),
                                _HeroButton('CONOCER SPONSORS', true, () => goTo(sponsorsKey)),
                              ],
                            ),
                            const SizedBox(height: 58),
                            Container(height: 1, color: const Color(0xFF24452D)),
                            const SizedBox(height: 25),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 22,
                              runSpacing: 12,
                              children: [
                                const Text('MIENTRAS TANTO, SEGUINOS',
                                    style: TextStyle(color: const Color(0xFFB8C8BC), fontSize: 11,
                                        fontWeight: FontWeight.w900, letterSpacing: 1)),
                                _SocialLink('Instagram @tandiltechweek',
                                    Icons.camera_alt_outlined,
                                    () => openLink('https://www.instagram.com/')),
                                _SocialLink('X @tandiltechweek', Icons.close,
                                    () => openLink('https://x.com/')),
                                _SocialLink('LinkedIn', Icons.work_outline,
                                    () => openLink('https://www.linkedin.com/')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _section(
                    key: agendaKey,
                    eyebrow: 'GUARDÁ LA FECHA',
                    title: 'La agenda',
                    subtitle: 'Un día lleno de ideas, tecnología y gente que hace.',
                    child: Column(
                      children: demoEvents.map((event) => _EventTile(event: event)).toList(),
                    ),
                  ),
                  Container(
                    color: const Color(0xFF050906),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('QUIÉNES LO HACEN POSIBLE',
                                style: TextStyle(color: neonGreen, fontSize: 11,
                                    fontWeight: FontWeight.w900, letterSpacing: 1.7)),
                            const SizedBox(height: 14),
                            const Text('La tecnología se construye en equipo.',
                                style: TextStyle(color: ink, fontSize: 38,
                                    fontWeight: FontWeight.w900, letterSpacing: -1.4)),
                            const SizedBox(height: 14),
                            const Text(
                              'Un encuentro impulsado por personas e instituciones que apuestan por la innovación local.',
                              style: TextStyle(color: const Color(0xFFB8C8BC), fontSize: 16, height: 1.6),
                            ),
                            const SizedBox(height: 34),
                            Container(
                              key: organizersKey,
                              child: LayoutBuilder(builder: (context, constraints) {
                                final wide = constraints.maxWidth > 650;
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    _OrganizerCard(
                                      width: wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                      icon: Icons.groups_2_outlined,
                                      title: 'Comunidad tech',
                                      text: 'Personas curiosas, desarrolladores y equipos que comparten conocimiento.',
                                    ),
                                    _OrganizerCard(
                                      width: wide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                      icon: Icons.rocket_launch_outlined,
                                      title: 'Ecosistema emprendedor',
                                      text: 'Organizaciones y proyectos que acompañan nuevas ideas y talentos.',
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _section(
                    key: sponsorsKey,
                    eyebrow: 'ALIADOS ESTRATÉGICOS',
                    title: 'Sponsors',
                    subtitle: 'Las organizaciones que acompañan y hacen posible esta experiencia.',
                    child: LayoutBuilder(builder: (context, constraints) {
                      final count = constraints.maxWidth > 850 ? 3 : constraints.maxWidth > 560 ? 2 : 1;
                      const gap = 16.0;
                      final width = (constraints.maxWidth - gap * (count - 1)) / count;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          _SponsorCard(
                              width: width,
                              logoAsset: 'assets/sponsors/energyvault.png',
                              name: 'Energy Vault',
                              category: 'SPONSOR PRINCIPAL',
                              description: 'Tu colección de Monster, organizada en un solo lugar.',
                              onTap: () => openLink('https://energyvault.app')),
                          _SponsorCard(
                              width: width,
                              logoAsset: 'assets/sponsors/globant.png',
                              name: 'Globant',
                              category: 'SPONSOR',
                              description: 'Reinventando negocios a través de soluciones tecnológicas.',
                              onTap: () => openLink('https://www.globant.com/es')),
                          _SponsorCard(
                              width: width,
                              logoAsset: 'assets/sponsors/faro_verde.png',
                              name: 'Grupo Faro Verde',
                              category: 'SPONSOR',
                              description: 'Conocé más sobre Grupo Faro Verde y sus proyectos.',
                              onTap: () => openLink('https://grupofaroverde.com')),
                        ],
                      );
                    }),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF070C08),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final compact = constraints.maxWidth < 650;
                          final content = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TENÉS UNA IDEA PARA COMPARTIR?',
                                  style: TextStyle(color: neonGreen, fontSize: 11,
                                      fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              const SizedBox(height: 12),
                              const Text('Solicitar creación de evento',
                                  style: TextStyle(color: Colors.white, fontSize: 36,
                                      fontWeight: FontWeight.w900, letterSpacing: -1.3)),
                              const SizedBox(height: 12),
                              const Text(
                                '¿Querés organizar una charla, hackathon o encuentro? Enviá tu propuesta al equipo administrador.',
                                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                            ],
                          );
                          final button = FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: neonGreen, foregroundColor: const Color(0xFF031006),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                              shape: const RoundedRectangleBorder(),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EventRequestPage())),
                            child: const Text('SOLICITAR EVENTO  →',
                                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .7)),
                          );
                          return compact
                              ? Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [content, const SizedBox(height: 24), button])
                              : Row(children: [Expanded(child: content), const SizedBox(width: 28), button]);
                        }),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF050906),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('¿QUERÉS ACOMPAÑAR EL EVENTO?',
                                      style: TextStyle(color: neonGreen, fontSize: 11, fontWeight: FontWeight.w900,
                                          letterSpacing: 1.4)),
                                  SizedBox(height: 8),
                                  Text('Sumate como sponsor.',
                                      style: TextStyle(color: ink, fontSize: 32, fontWeight: FontWeight.w900,
                                          letterSpacing: -1)),
                                ],
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: neonGreen, foregroundColor: const Color(0xFF031006),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                                shape: const RoundedRectangleBorder(),
                              ),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SponsorRequestPage()),
                              ),
                              child: const Text('HABLEMOS  →',
                                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: paper,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 14,
                          spacing: 20,
                          children: [
                            const Text('●  TANDIL TECH WEEK 2026',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2)),
                            const Text('Una demo hecha con Flutter + Dart',
                                style: TextStyle(color: const Color(0xFF9BAFA0), fontSize: 12)),
                            Wrap(spacing: 4, children: [
                              IconButton(onPressed: () => openLink('https://www.instagram.com/'),
                                  icon: const Icon(Icons.camera_alt_outlined)),
                              IconButton(onPressed: () => openLink('https://x.com/'),
                                  icon: const Icon(Icons.close)),
                              IconButton(onPressed: () => openLink('https://www.linkedin.com/'),
                                  icon: const Icon(Icons.work_outline)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required Key key,
    required String eyebrow,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 76),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow, style: const TextStyle(color: electricBlue, fontSize: 11,
                  fontWeight: FontWeight.w900, letterSpacing: 1.7)),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(color: ink, fontSize: 44,
                  fontWeight: FontWeight.w900, letterSpacing: -1.8)),
              const SizedBox(height: 10),
              Text(subtitle, style: const TextStyle(color: const Color(0xFF9BAFA0),
                  fontSize: 16, height: 1.5)),
              const SizedBox(height: 34),
              child,
            ],
          ),
        ),
      ),
    );
  }
}


class EventDetailPage extends StatelessWidget {
  final DemoEvent event;
  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paper,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: paper,
            surfaceTintColor: paper,
            title: const Text('TANDIL TECH WEEK 2026',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                    letterSpacing: 1.4, color: ink)),
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: () => html.window.close(),
              icon: const Icon(Icons.close),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => html.window.open(Uri.base.origin + Uri.base.path, '_blank'),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('INICIO'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(height: 3, color: const Color(0xFF173B24)),
                Container(
                  width: double.infinity,
                  color: const Color(0xFF050906),
                  padding: const EdgeInsets.fromLTRB(24, 58, 24, 62),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            color: neonGreen,
                            child: Text(event.category,
                              style: const TextStyle(color: ink, fontSize: 10,
                                fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          ),
                          const SizedBox(height: 22),
                          Text(event.title,
                            style: const TextStyle(color: ink, fontSize: 58,
                              height: 1.02, fontWeight: FontWeight.w900, letterSpacing: -2.5)),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 680,
                            child: Text(event.description,
                              style: TextStyle(color: const Color(0xFFD2DED5),
                                fontSize: 19, height: 1.6)),
                          ),
                          const SizedBox(height: 34),
                          Wrap(spacing: 12, runSpacing: 12, children: [
                            _DetailPill(icon: Icons.calendar_month_outlined, label: '${event.day} de septiembre de 2026'),
                            _DetailPill(icon: Icons.schedule, label: event.time),
                            _DetailPill(icon: Icons.location_on_outlined, label: event.place),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 760;
                        final mainInfo = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SOBRE EL EVENTO',
                              style: TextStyle(color: electricBlue, fontSize: 11,
                                fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                            const SizedBox(height: 14),
                            const Text('Ideas que se convierten en acción.',
                              style: TextStyle(fontSize: 34, height: 1.1,
                                fontWeight: FontWeight.w900, letterSpacing: -1.2)),
                            const SizedBox(height: 16),
                            Text('${event.description} Esta actividad forma parte de Tandil Tech Week: un punto de encuentro para aprender, compartir experiencias y conectar con la comunidad tecnológica.',
                              style: const TextStyle(color: const Color(0xFF9BAFA0),
                                fontSize: 16, height: 1.7)),
                            const SizedBox(height: 30),
                            _InfoRow(icon: Icons.access_time, label: 'DURACIÓN', value: event.duration),
                            _InfoRow(icon: Icons.groups_outlined, label: 'DIRIGIDO A', value: event.audience),
                            _InfoRow(icon: Icons.place_outlined, label: 'LUGAR', value: event.place),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final query = Uri.encodeComponent(
                                    '${event.place}, Tandil, Buenos Aires, Argentina',
                                  );
                                  html.window.open(
                                    'https://www.google.com/maps/search/?api=1&query=$query',
                                    '_blank',
                                  );
                                },
                                icon: const Icon(Icons.map_outlined, size: 18),
                                label: const Text('VER UBICACIÓN EN GOOGLE MAPS'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: electricBlue,
                                  side: const BorderSide(color: electricBlue),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  shape: const RoundedRectangleBorder(),
                                  textStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .45,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => html.window.open(
                                  googleCalendarUrl(event),
                                  '_blank',
                                ),
                                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                                label: const Text('AGREGAR A GOOGLE CALENDAR'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ink,
                                  side: const BorderSide(color: Color(0xFF39FF72)),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  shape: const RoundedRectangleBorder(),
                                  textStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .45,
                                  ),
                                ),
                              ),
                            ),
                            if (event.isLive) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () => html.window.open(twitchChannelUrl, '_blank'),
                                  icon: const Icon(Icons.sensors, size: 19),
                                  label: const Text(
                                    'VER TRANSMISIÓN EN VIVO EN TWITCH',
                                    textAlign: TextAlign.center,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF39FF72),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                                    shape: const RoundedRectangleBorder(),
                                    textStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .45,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                        final schedule = Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080D09),
                            border: Border.all(color: const Color(0xFF39FF72), width: 0.8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AGENDA DEL EVENTO',
                                style: TextStyle(color: electricBlue, fontSize: 11,
                                  fontWeight: FontWeight.w900, letterSpacing: 1.3)),
                              const SizedBox(height: 22),
                              ...event.schedule.split('\\n').map((line) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Icon(Icons.circle, size: 8, color: neonGreen),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(line,
                                    style: const TextStyle(color: ink, fontSize: 14, height: 1.5,
                                      fontWeight: FontWeight.w600))),
                                ]),
                              )),
                            ],
                          ),
                        );
                        if (!isWide) {
                          return Column(children: [mainInfo, const SizedBox(height: 30), schedule]);
                        }
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 6, child: mainInfo),
                          const SizedBox(width: 48),
                          Expanded(flex: 5, child: schedule),
                        ]);
                      }),
                    ),
                  ),
                ),
                Container(
                  color: const Color(0xFF050906),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('GALERÍA',
                          style: TextStyle(color: neonGreen, fontSize: 11,
                            fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                        const SizedBox(height: 12),
                        const Text('Momentos que inspiran.',
                          style: TextStyle(color: const Color(0xFFF0FFF3), fontSize: 34,
                            fontWeight: FontWeight.w900, letterSpacing: -1)),
                        const SizedBox(height: 10),
                        const Text('Galería de ejemplo: más adelante podés reemplazar estos bloques por fotos reales de ediciones anteriores.',
                          style: TextStyle(color: const Color(0xFFB8C8BC), fontSize: 14, height: 1.5)),
                        const SizedBox(height: 24),
                        LayoutBuilder(builder: (context, constraints) {
                          final count = constraints.maxWidth > 760 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
                          final gap = 14.0;
                          final width = (constraints.maxWidth - gap * (count - 1)) / count;
                          return Wrap(spacing: gap, runSpacing: gap, children: [
                            _GalleryPlaceholder(width: width, number: '01', label: 'Comunidad'),
                            _GalleryPlaceholder(width: width, number: '02', label: 'Ideas en acción'),
                            _GalleryPlaceholder(width: width, number: '03', label: 'Nuevas conexiones'),
                          ]);
                        }),
                      ]),
                    ),
                  ),
                ),
                Container(
                  color: const Color(0xFF030604),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: const Center(child: Text('TANDIL TECH WEEK 2026  ·  TECNOLOGÍA, COMUNIDAD E IDEAS',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: neonGreen, fontSize: 11, fontWeight: FontWeight.w900,
                      letterSpacing: 1.1))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailPill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    color: Colors.white.withValues(alpha: .12),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 17, color: neonGreen),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12,
        fontWeight: FontWeight.w700)),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(
        color: const Color(0xFF0C1A10),
        border: Border.all(color: const Color(0xFF39FF72), width: 0.7),
      ),
        child: Icon(icon, color: electricBlue, size: 20)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: electricBlue,
          fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

class _GalleryPlaceholder extends StatelessWidget {
  final double width;
  final String number, label;
  const _GalleryPlaceholder({required this.width, required this.number, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 190,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF080D09),
      border: Border.all(color: const Color(0xFF244D30), width: 1),
      boxShadow: const [
        BoxShadow(color: Color(0x1600FF55), blurRadius: 18, spreadRadius: 0),
      ],
    ),
    child: Stack(children: [
      Positioned(top: 0, left: 0, right: 0,
        child: Container(height: 3, color: neonGreen)),
      Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(number, style: const TextStyle(color: neonGreen, fontSize: 12,
          fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const Center(
          child: Icon(Icons.photo_library_outlined,
            color: Color(0xFF39FF72), size: 42),
        ),
        Text(label, style: const TextStyle(color: Color(0xFFF0FFF3), fontSize: 16,
          fontWeight: FontWeight.w800)),
      ]),
    ]),
  );
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(foregroundColor: const Color(0xFF9BAFA0),
        padding: const EdgeInsets.symmetric(horizontal: 17)),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
        letterSpacing: 1.2)),
  );
}

class _HeroButton extends StatelessWidget {
  final String label;
  final bool green;
  final VoidCallback onTap;
  const _HeroButton(this.label, this.green, this.onTap);
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    height: 48,
    child: Material(
      color: green ? neonGreen : paper,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(
                  color: green ? ink : electricBlue, fontSize: 11,
                  fontWeight: FontWeight.w900, letterSpacing: 1))),
              Icon(Icons.arrow_forward, size: 18, color: green ? ink : electricBlue),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SocialLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SocialLink(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 15, color: Colors.white),
      const SizedBox(width: 7),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ]),
  );
}

class _LiveStatus extends StatelessWidget {
  final bool isLive;
  const _LiveStatus({required this.isLive});

  @override
  Widget build(BuildContext context) {
    final color = isLive ? const Color(0xFF39FF72) : const Color(0xFFB8C8BC);
    final background = isLive ? const Color(0xFF102116) : const Color(0xFF151B16);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(3)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isLive ? Icons.sensors : Icons.videocam_off_outlined, size: 13, color: color),
        const SizedBox(width: 6),
        Text(isLive ? 'TRANSMISIÓN EN VIVO' : 'NO SE TRANSMITE EN VIVO',
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900,
                letterSpacing: .55)),
      ]),
    );
  }
}

class _EventTile extends StatelessWidget {
  final DemoEvent event;
  const _EventTile({required this.event});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF080D09),
      border: Border.all(color: const Color(0xFF244D30), width: 0.8),
    ),
    child: LayoutBuilder(builder: (context, constraints) {
      final date = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.day, style: const TextStyle(fontSize: 32, height: 1,
              fontWeight: FontWeight.w900, color: electricBlue)),
          Text(event.month, style: const TextStyle(fontSize: 10,
              fontWeight: FontWeight.w900, letterSpacing: 1.3)),
        ],
      );
      final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${event.time}  ·  ${event.category}',
            style: const TextStyle(color: electricBlue, fontSize: 10,
                fontWeight: FontWeight.w900, letterSpacing: .8)),
        const SizedBox(height: 7),
        _LiveStatus(isLive: event.isLive),
        const SizedBox(height: 9),
        Text(event.title, style: const TextStyle(color: ink, fontSize: 21,
            fontWeight: FontWeight.w900, letterSpacing: -.5)),
        const SizedBox(height: 6),
        Text(event.description, style: const TextStyle(color: const Color(0xFF9BAFA0),
            fontSize: 13, height: 1.45)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on_outlined, size: 15, color: const Color(0xFF9BAFA0)),
          const SizedBox(width: 4),
          Flexible(child: Text(event.place, style: const TextStyle(fontSize: 12, color: const Color(0xFF9BAFA0)))),
        ]),
      ]);
      return InkWell(
        onTap: () => html.window.open(
          '${Uri.base.origin}${Uri.base.path}?event=${event.slug}',
          '_blank',
        ),
        hoverColor: electricBlue.withValues(alpha: .035),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          date,
          const SizedBox(width: 22),
          Expanded(child: details),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_outward, color: electricBlue),
        ]),
      );
    }),
  );
}

class _OrganizerCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title, text;
  const _OrganizerCard({required this.width, required this.icon,
      required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF244D30), width: 0.8),
      color: const Color(0xFF080D09),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: neonGreen, size: 30),
      const SizedBox(height: 22),
      Text(title, style: const TextStyle(color: ink, fontSize: 21,
          fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Text(text, style: const TextStyle(color: Color(0xFFB8C8BC), fontSize: 14, height: 1.6)),
    ]),
  );
}

class _SponsorCard extends StatelessWidget {
  final double width;
  final String logoAsset, name, category, description;
  final VoidCallback onTap;
  const _SponsorCard({required this.width, required this.logoAsset,
      required this.name, required this.category, required this.description,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF080D09),
      border: Border.all(color: const Color(0xFF244D30), width: 0.8),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 68,
        width: double.infinity,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            logoAsset,
            height: 64,
            width: 180,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) => Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(category, style: const TextStyle(color: electricBlue, fontSize: 10,
          fontWeight: FontWeight.w900, letterSpacing: 1.3)),
      const SizedBox(height: 8),
      Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Text(description, style: const TextStyle(color: const Color(0xFF9BAFA0),
          fontSize: 14, height: 1.5)),
      const SizedBox(height: 22),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(foregroundColor: ink,
            side: const BorderSide(color: Color(0xFF34483A)),
            shape: const RoundedRectangleBorder()),
          child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('VISITAR SITIO WEB', style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w900, letterSpacing: 1)), Icon(Icons.arrow_forward, size: 16)]),
        ),
      ),
    ]),
  );
}
