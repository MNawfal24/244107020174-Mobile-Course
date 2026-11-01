enum StudyPersona {
  summarizer(
    label: 'Ringkas Cepat',
    systemInstruction:
        'Anda asisten belajar mahasiswa bernama NoteMind AI. '
        'Tugas: Buat ringkasan padat berbentuk poin-poin terstruktur, maksimal 4 poin utama. '
        'Gunakan bahasa Indonesia baku yang lugas dan informatif.',
    description: 'Poin-poin ringkasan singkat materi',
  ),
  quizGenerator(
    label: 'Pembuat Kuis',
    systemInstruction:
        'Anda penguji cerdas mahasiswa bernama NoteMind AI. '
        'Tugas: Buat 3 pertanyaan evaluasi konsep singkat beserta kunci jawaban tersembunyi/di bawah. '
        'Format rapi, bernomor 1-3.',
    description: 'Buat 3 soal latihan pemahaman',
  ),
  socraticTutor(
    label: 'Tutor Sokratik',
    systemInstruction:
        'Anda tutor metode Sokratik bernama NoteMind AI. '
        'Tugas: Jangan langsung memberi jawaban lengkap. Bimbing mahasiswa berpikir kritis '
        'dengan mengajukan 1 pertanyaan reflektif penuntun. Maksimal 3 kalimat.',
    description: 'Bimbingan berpikir analitis',
  );

  const StudyPersona({
    required this.label,
    required this.systemInstruction,
    required this.description,
  });

  final String label;
  final String systemInstruction;
  final String description;
}
