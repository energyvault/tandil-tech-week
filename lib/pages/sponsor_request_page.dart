import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_request_page.dart' show adminEmail;

const sponsorNeon = Color(0xFF39FF72);
const sponsorInk = Color(0xFFF0FFF3);
const sponsorBackground = Color(0xFF030604);
const sponsorMuted = Color(0xFFB8C8BC);
const sponsorBorder = Color(0xFF244D30);

class SponsorRequestPage extends StatefulWidget {
  const SponsorRequestPage({super.key});

  @override
  State<SponsorRequestPage> createState() => _SponsorRequestPageState();
}

class _SponsorRequestPageState extends State<SponsorRequestPage> {
  final formKey = GlobalKey<FormState>();
  final companyController = TextEditingController();
  final websiteController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final socialController = TextEditingController();
  final ideaController = TextEditingController();
  final contributionController = TextEditingController();
  final budgetController = TextEditingController();

  @override
  void dispose() {
    companyController.dispose();
    websiteController.dispose();
    contactController.dispose();
    emailController.dispose();
    phoneController.dispose();
    socialController.dispose();
    ideaController.dispose();
    contributionController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, color: sponsorNeon, size: 19),
      filled: true,
      fillColor: const Color(0xFF080D09),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: const TextStyle(color: Color(0xFF9BAFA0)),
      hintStyle: const TextStyle(color: Color(0xFF6E8172)),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: sponsorBorder),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: sponsorBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: sponsorNeon, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFFF6B6B)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
    );
  }

  String? requiredValue(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio.';
    return null;
  }

  String? validEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Ingresá un correo válido.';
    }
    return null;
  }

  Future<void> prepareSponsorRequest() async {
    if (!formKey.currentState!.validate()) return;

    final body = '''
SOLICITUD DE PATROCINIO — TANDIL TECH WEEK 2026
================================================

EMPRESA / ORGANIZACIÓN
Nombre: ${companyController.text.trim()}
Sitio web: ${websiteController.text.trim().isEmpty ? 'No indicado' : websiteController.text.trim()}
Redes sociales: ${socialController.text.trim().isEmpty ? 'No indicadas' : socialController.text.trim()}

PERSONA DE CONTACTO
Nombre y apellido: ${contactController.text.trim()}
Correo electrónico: ${emailController.text.trim()}
Teléfono: ${phoneController.text.trim().isEmpty ? 'No indicado' : phoneController.text.trim()}

IDEA DE PATROCINIO
Descripción de la propuesta:
${ideaController.text.trim()}

Tipo de colaboración o aporte:
${contributionController.text.trim().isEmpty ? 'A definir' : contributionController.text.trim()}

Presupuesto o recursos disponibles:
${budgetController.text.trim().isEmpty ? 'A definir / no indicado' : budgetController.text.trim()}

---
Solicitud generada desde la demo local de Tandil Tech Week.
''';

    final uri = Uri(
      scheme: 'mailto',
      path: adminEmail,
      queryParameters: {
        'subject': 'Propuesta de patrocinio: ${companyController.text.trim()}',
        'body': body,
      },
    );

    final opened = await launchUrl(uri);
    if (!mounted) return;
    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se abrió tu aplicación de correo con la propuesta preparada.')),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF101811),
          title: const Text('No se pudo abrir el correo', style: TextStyle(color: sponsorInk)),
          content: Text(
            'Configurá una aplicación de correo en tu equipo o revisá el correo administrador configurado: $adminEmail',
            style: const TextStyle(color: sponsorMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ENTENDIDO', style: TextStyle(color: sponsorNeon)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sponsorBackground,
      appBar: AppBar(
        backgroundColor: sponsorBackground,
        surfaceTintColor: sponsorBackground,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: sponsorInk),
        ),
        title: const Row(children: [
          Icon(Icons.circle, color: sponsorNeon, size: 10),
          SizedBox(width: 9),
          Text('TANDIL TECH WEEK', style: TextStyle(
            color: sponsorInk, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
          SizedBox(width: 8),
          Text('2026', style: TextStyle(
            color: sponsorNeon, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ]),
      ),
      body: ListView(children: [
        Container(
          color: const Color(0xFF050906),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PROPUESTAS DE COLABORACIÓN', style: TextStyle(
                  color: sponsorNeon, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                const SizedBox(height: 16),
                const Text('Sumate como\nsponsor.', style: TextStyle(
                  color: sponsorInk, fontSize: 48, height: 1, fontWeight: FontWeight.w900, letterSpacing: -2)),
                const SizedBox(height: 18),
                const Text(
                  'Contanos quiénes son, qué tienen en mente y cómo les gustaría acompañar a la comunidad tecnológica.',
                  style: TextStyle(color: sponsorMuted, fontSize: 16, height: 1.6)),
              ]),
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _SponsorFormHeading(number: '01', title: 'Sobre la organización',
                    subtitle: 'Datos para conocer a la marca o equipo que propone colaborar.'),
                  const SizedBox(height: 22),
                  TextFormField(controller: companyController,
                    decoration: fieldDecoration('Empresa, marca u organización', hint: 'Ej. Empresa Tech', icon: Icons.business_outlined),
                    validator: requiredValue),
                  const SizedBox(height: 16),
                  TextFormField(controller: websiteController,
                    keyboardType: TextInputType.url,
                    decoration: fieldDecoration('Sitio web (opcional)', hint: 'https://', icon: Icons.language),),
                  const SizedBox(height: 16),
                  TextFormField(controller: socialController,
                    decoration: fieldDecoration('Redes sociales (opcional)', hint: '@usuario o enlaces', icon: Icons.share_outlined),),
                  const SizedBox(height: 38),
                  const _SponsorFormHeading(number: '02', title: 'Datos de contacto',
                    subtitle: '¿Con quién puede comunicarse el equipo organizador?'),
                  const SizedBox(height: 22),
                  TextFormField(controller: contactController,
                    decoration: fieldDecoration('Nombre y apellido', icon: Icons.person_outline),
                    validator: requiredValue),
                  const SizedBox(height: 16),
                  TextFormField(controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: fieldDecoration('Correo electrónico', hint: 'vos@ejemplo.com', icon: Icons.mail_outline),
                    validator: validEmail),
                  const SizedBox(height: 16),
                  TextFormField(controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: fieldDecoration('Teléfono (opcional)', icon: Icons.phone_outlined),),
                  const SizedBox(height: 38),
                  const _SponsorFormHeading(number: '03', title: 'Tu idea de patrocinio',
                    subtitle: 'Explicanos la propuesta y qué tipo de colaboración imaginan.'),
                  const SizedBox(height: 22),
                  TextFormField(controller: ideaController,
                    minLines: 4, maxLines: 8,
                    decoration: fieldDecoration('Descripción de la idea',
                      hint: '¿Por qué les interesa acompañar Tandil Tech Week? ¿Qué les gustaría proponer?', icon: Icons.lightbulb_outline),
                    validator: requiredValue),
                  const SizedBox(height: 16),
                  TextFormField(controller: contributionController,
                    minLines: 2, maxLines: 4,
                    decoration: fieldDecoration('Tipo de colaboración (opcional)',
                      hint: 'Ej. apoyo económico, premios, productos, espacio o difusión'),),
                  const SizedBox(height: 16),
                  TextFormField(controller: budgetController,
                    decoration: fieldDecoration('Presupuesto o recursos disponibles (opcional)',
                      hint: 'Ej. aporte estimado, productos o recursos'),),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A140D),
                      border: Border.all(color: sponsorBorder),
                    ),
                    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.info_outline, color: sponsorNeon),
                      SizedBox(width: 12),
                      Expanded(child: Text(
                        'Esta demo local no guarda datos en un servidor. Al continuar, se abrirá tu aplicación de correo con la propuesta lista para revisar y enviar.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: sponsorMuted),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: prepareSponsorRequest,
                      icon: const Icon(Icons.outgoing_mail),
                      label: const Text('PREPARAR PROPUESTA POR CORREO'),
                      style: FilledButton.styleFrom(
                        backgroundColor: sponsorNeon,
                        foregroundColor: const Color(0xFF031006),
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                        shape: const RoundedRectangleBorder(),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SponsorFormHeading extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  const _SponsorFormHeading({required this.number, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(number, style: const TextStyle(color: sponsorNeon, fontSize: 13,
        fontWeight: FontWeight.w900, letterSpacing: 1)),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
          letterSpacing: -.7, color: sponsorInk)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: Color(0xFF9BAFA0), fontSize: 14)),
      ])),
    ],
  );
}
