import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const requestBlue = Color(0xFF39FF72);
const requestGreen = Color(0xFF39FF72);
const requestInk = Color(0xFFF0FFF3);
const requestPaper = Color(0xFF030604);

// Reemplazá este correo por el correo real del administrador.
const adminEmail = 'administrador@tandiltechweek.com';

class EventRequestPage extends StatefulWidget {
  const EventRequestPage({super.key});

  @override
  State<EventRequestPage> createState() => _EventRequestPageState();
}

class _EventRequestPageState extends State<EventRequestPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final placeController = TextEditingController();
  final budgetController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final organizationController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    placeController.dispose();
    budgetController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    super.dispose();
  }

  InputDecoration decoration(String label, {String? hint, String? prefix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: const Color(0xFF080D09),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      labelStyle: const TextStyle(color: Color(0xFF9BAFA0)),
      hintStyle: const TextStyle(color: Color(0xFF6E8172)),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF244D30)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF244D30)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: requestGreen, width: 1.5),
      ),
    );
  }

  String? requiredValue(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio.';
    return null;
  }

  Future<void> sendRequest() async {
    if (!formKey.currentState!.validate()) return;

    final body = '''
SOLICITUD DE CREACIÓN DE EVENTO
================================

INFORMACIÓN DEL EVENTO
Título: ${titleController.text.trim()}
Descripción: ${descriptionController.text.trim()}
Fecha propuesta: ${dateController.text.trim()}
Lugar: ${placeController.text.trim()}
Presupuesto estimado: ${budgetController.text.trim().isEmpty ? 'A definir' : budgetController.text.trim()}

DATOS DEL SOLICITANTE
Nombre y apellido: ${nameController.text.trim()}
Correo electrónico: ${emailController.text.trim()}
Teléfono: ${phoneController.text.trim().isEmpty ? 'No indicado' : phoneController.text.trim()}
Organización / equipo: ${organizationController.text.trim().isEmpty ? 'No indicado' : organizationController.text.trim()}

---
Solicitud generada desde la demo local de Tandil Tech Week.
''';

    final uri = Uri(
      scheme: 'mailto',
      path: adminEmail,
      queryParameters: {
        'subject': 'Solicitud de creación de evento: ${titleController.text.trim()}',
        'body': body,
      },
    );

    final opened = await launchUrl(uri);
    if (!mounted) return;

    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se abrió tu aplicación de correo con la solicitud preparada.')),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se pudo abrir el correo'),
          content: Text(
            'Configurá una aplicación de correo en tu equipo o cambiá el correo administrador en el archivo event_request_page.dart.\n\nCorreo configurado: $adminEmail',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ENTENDIDO'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: requestPaper,
      appBar: AppBar(
        backgroundColor: requestPaper,
        surfaceTintColor: requestPaper,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Row(
          children: [
            Icon(Icons.circle, color: requestGreen, size: 10),
            SizedBox(width: 9),
            Text('TANDIL TECH WEEK',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                    letterSpacing: 1.3, color: requestInk)),
            SizedBox(width: 8),
            Text('2026',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                    letterSpacing: 1.2, color: requestBlue)),
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: const Color(0xFF050906),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROPUESTAS ABIERTAS',
                        style: TextStyle(color: requestGreen, fontSize: 11,
                            fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                    const SizedBox(height: 16),
                    const Text('Solicitar creación\nde evento.',
                        style: TextStyle(color: Colors.white, fontSize: 48,
                            height: 1, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    const SizedBox(height: 18),
                    const Text(
                      'Contanos qué querés organizar. El equipo administrador podrá revisar tu propuesta y contactarte.',
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 42),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormHeading(number: '01', title: 'Sobre el evento',
                          subtitle: 'La información básica de tu propuesta.'),
                      const SizedBox(height: 22),
                      TextFormField(controller: titleController,
                          decoration: decoration('Título del evento', hint: 'Ej. Encuentro de desarrollo web'),
                          validator: requiredValue),
                      const SizedBox(height: 16),
                      TextFormField(controller: descriptionController,
                          minLines: 4, maxLines: 7,
                          decoration: decoration('Descripción del evento',
                              hint: '¿De qué se trata? ¿Qué actividades se realizarán?'),
                          validator: requiredValue),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: (context, constraints) {
                        final stack = constraints.maxWidth < 600;
                        final date = TextFormField(controller: dateController,
                            decoration: decoration('Fecha propuesta', hint: 'Ej. 17/11/2026'),
                            validator: requiredValue);
                        final place = TextFormField(controller: placeController,
                            decoration: decoration('Lugar', hint: 'Ciudad, dirección o modalidad virtual'),
                            validator: requiredValue);
                        return stack
                            ? Column(children: [date, const SizedBox(height: 16), place])
                            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(child: date),
                                const SizedBox(width: 16),
                                Expanded(child: place),
                              ]);
                      }),
                      const SizedBox(height: 16),
                      TextFormField(controller: budgetController,
                          decoration: decoration('Presupuesto estimado', hint: 'Ej. 250000 ARS o “a definir”')),
                      const SizedBox(height: 42),
                      _FormHeading(number: '02', title: 'Tus datos',
                          subtitle: 'Así podremos comunicarnos con vos sobre la propuesta.'),
                      const SizedBox(height: 22),
                      TextFormField(controller: nameController,
                          decoration: decoration('Nombre y apellido'),
                          validator: requiredValue),
                      const SizedBox(height: 16),
                      TextFormField(controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: decoration('Correo electrónico', hint: 'vos@ejemplo.com'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio.';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                              return 'Ingresá un correo válido.';
                            }
                            return null;
                          }),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: (context, constraints) {
                        final stack = constraints.maxWidth < 600;
                        final phone = TextFormField(controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: decoration('Teléfono (opcional)'));
                        final organization = TextFormField(controller: organizationController,
                            decoration: decoration('Organización / equipo (opcional)'));
                        return stack
                            ? Column(children: [phone, const SizedBox(height: 16), organization])
                            : Row(children: [
                                Expanded(child: phone),
                                const SizedBox(width: 16),
                                Expanded(child: organization),
                              ]);
                      }),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFF14251A),
                        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(Icons.info_outline, color: requestBlue),
                          SizedBox(width: 12),
                          Expanded(child: Text(
                            'Esta demo no guarda ni envía solicitudes a un servidor. Al enviar, se abrirá tu aplicación de correo con el mensaje listo para revisar y enviar.',
                            style: TextStyle(fontSize: 13, height: 1.5, color: requestInk),
                          )),
                        ]),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: sendRequest,
                          icon: const Icon(Icons.outgoing_mail),
                          label: const Text('PREPARAR SOLICITUD POR CORREO'),
                          style: FilledButton.styleFrom(
                            backgroundColor: requestGreen,
                            foregroundColor: const Color(0xFF031006),
                            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                            shape: const RoundedRectangleBorder(),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900,
                                letterSpacing: .5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormHeading extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  const _FormHeading({required this.number, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(number, style: const TextStyle(color: requestBlue, fontSize: 13,
          fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
            letterSpacing: -.7, color: requestInk)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: const Color(0xFF9BAFA0), fontSize: 14)),
      ])),
    ],
  );
}
