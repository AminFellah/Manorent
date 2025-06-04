import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informativa Privacy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle('Allegato 15 - Informativa per clienti, fornitori, partner e altri soggetti di cui all’Art. 13 del Regolamento Europeo n. 679/2016'),

            buildParagraph(
              'Roberta Banchelli, in qualità di Titolare del trattamento dei dati personali di Manorent S.r.l. (P.IVA 02418150518) con sede in Via Galileo Ferraris 89, Arezzo, 52100 (AR), desidera fornire questa informativa ai sensi dell’art. 13 del GDPR 679/2016.',
            ),

            buildSectionTitle('1. Dati oggetto del trattamento'),
            buildParagraph('I dati personali trattati sono dati anagrafici e di contatto, ottenuti in occasione di:'),
            buildParagraph('- Visite, telefonate, email;\n- Partecipazione ad eventi;\n- Richieste di informazioni, offerte o contatti;\n- Compilazione di form su siti web;\n- Transazioni e comunicazioni post-ordine.'),

            buildSectionTitle('2. Finalità del trattamento'),
            buildParagraph('I dati personali sono trattati per:'),
            buildParagraph('- Inoltrare comunicazioni;\n- Formulare o evadere richieste;\n- Gestire il rapporto contrattuale;\n- Adempiere a obblighi di legge.'),
            buildParagraph('Il conferimento dei dati è necessario per la corretta gestione del rapporto.'),

            buildSectionTitle('3. Base giuridica'),
            buildParagraph(
              'Il trattamento è basato sull’art. 6.1 lett. b) e c) del GDPR: esecuzione di un contratto e adempimento di obblighi legali.'
            ),

            buildSectionTitle('4. Modalità del trattamento'),
            buildParagraph(
              'Il trattamento avviene con strumenti manuali o digitali, nel rispetto delle normative, senza decisioni automatizzate.'
            ),

            buildSectionTitle('5. Destinatari dei dati'),
            buildParagraph(
              'I dati possono essere comunicati a soggetti autorizzati interni o esterni, per le finalità previste. Non saranno diffusi a terzi non autorizzati.'
            ),

            buildSectionTitle('6. Trasferimento dei dati'),
            buildParagraph(
              'I dati non saranno trasferiti fuori dall’Unione Europea, salvo casi eccezionali con garanzie adeguate.'
            ),

            buildSectionTitle('7. Conservazione dei dati'),
            buildParagraph(
              'I dati verranno conservati fino a un massimo di 15 anni, o secondo quanto previsto da obblighi normativi specifici.'
            ),

            buildSectionTitle('8. Diritti dell’interessato'),
            buildParagraph(
              'L’interessato può esercitare i diritti di accesso, rettifica, cancellazione, limitazione, portabilità e opposizione scrivendo a:'
            ),
            buildParagraph('r.banchelli@manorent.it\n Allegando copia del documento di identità'),

            buildSectionTitle('9. Reclamo'),
            buildParagraph(
              'L’interessato può presentare reclamo all’autorità di controllo (Garante per la protezione dei dati personali).'
            ),

            buildSectionTitle('10. Titolare del trattamento'),
            buildParagraph(
              'Roberta Banchelli – Manorent S.r.l. (P.IVA 02418150518)\nVia Galileo Ferraris 89, Arezzo, 52100 (AR)\n r.banchelli@manorent.it'
            ),

            const SizedBox(height: 32),
            const Text(
              'Si invita a dare ampia diffusione della presente informativa ai soggetti i cui dati verranno comunicati a Manorent S.r.l.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
