import 'package:flutter/material.dart';

class HijaiyahData {
  final String huruf;     // huruf dasar Arab (visual utama)
  final String nama;      // nama huruf
  final String arabic;    // target evaluasi (huruf Arab)
  final String latin;     // transliterasi Latin
  final String awal;
  final String tengah;
  final String akhir;
  final Color color;

  const HijaiyahData({
    required this.huruf,
    required this.nama,
    required this.arabic,
    required this.latin,
    required this.awal,
    required this.tengah,
    required this.akhir,
    required this.color,
  });

  // HARAKAT
  String get fathah => "$hurufَ";
  String get dhammah => "$hurufُ";
  String get kasrah => "$hurufِ";
  String get tanwinFathah => "$hurufً";
  String get tanwinDhammah => "$hurufٌ";
  String get tanwinKasrah => "$hurufٍ";
}

// ====================
// 28 Huruf Hijaiyah
// ====================
const List<HijaiyahData> hijaiyahList = [
  HijaiyahData(huruf: "ا", nama: "Alif", arabic: "أ", latin: "A", awal: "ا", tengah: "ـا", akhir: "ـا", color: Color(0xFFFFF3E0)),
  HijaiyahData(huruf: "ب", nama: "Ba", arabic: "ب", latin: "Ba", awal: "بـ", tengah: "ـبـ", akhir: "ـب", color: Color(0xFFE3F2FD)),
  HijaiyahData(huruf: "ت", nama: "Ta", arabic: "ت", latin: "Ta", awal: "تـ", tengah: "ـتـ", akhir: "ـت", color: Color(0xFFFFEBEE)),
  HijaiyahData(huruf: "ث", nama: "Tsa", arabic: "ث", latin: "Tsa", awal: "ثـ", tengah: "ـثـ", akhir: "ـث", color: Color(0xFFE8F5E9)),
  HijaiyahData(huruf: "ج", nama: "Jim", arabic: "ج", latin: "Jim", awal: "جـ", tengah: "ـجـ", akhir: "ـج", color: Color(0xFFFFFDE7)),
  HijaiyahData(huruf: "ح", nama: "Ha", arabic: "ح", latin: "Ha", awal: "حـ", tengah: "ـحـ", akhir: "ـح", color: Color(0xFFF3E5F5)),
  HijaiyahData(huruf: "خ", nama: "Kha", arabic: "خ", latin: "Kha", awal: "خـ", tengah: "ـخـ", akhir: "ـخ", color: Color(0xFFE1F5FE)),
  HijaiyahData(huruf: "د", nama: "Dal", arabic: "د", latin: "Da", awal: "د", tengah: "ـد", akhir: "ـد", color: Color(0xFFFFEBEE)),
  HijaiyahData(huruf: "ذ", nama: "Dzal", arabic: "ذ", latin: "Dza", awal: "ذ", tengah: "ـذ", akhir: "ـذ", color: Color(0xFFE0F7FA)),
  HijaiyahData(huruf: "ر", nama: "Ra", arabic: "ر", latin: "Ra", awal: "ر", tengah: "ـر", akhir: "ـر", color: Color(0xFFFFF3E0)),
  HijaiyahData(huruf: "ز", nama: "Zai", arabic: "ز", latin: "Za", awal: "ز", tengah: "ـز", akhir: "ـز", color: Color(0xFFE3F2FD)),
  HijaiyahData(huruf: "س", nama: "Sin", arabic: "س", latin: "Si", awal: "سـ", tengah: "ـسـ", akhir: "ـس", color: Color(0xFFE8F5E9)),
  HijaiyahData(huruf: "ش", nama: "Syin", arabic: "ش", latin: "Syi", awal: "شـ", tengah: "ـشـ", akhir: "ـش", color: Color(0xFFFFFDE7)),
  HijaiyahData(huruf: "ص", nama: "Shad", arabic: "ص", latin: "Sha", awal: "صـ", tengah: "ـصـ", akhir: "ـص", color: Color(0xFFF3E5F5)),
  HijaiyahData(huruf: "ض", nama: "Dhad", arabic: "ض", latin: "Dha", awal: "ضـ", tengah: "ـضـ", akhir: "ـض", color: Color(0xFFE1F5FE)),
  HijaiyahData(huruf: "ط", nama: "Tha", arabic: "ط", latin: "Tha", awal: "طـ", tengah: "ـطـ", akhir: "ـط", color: Color(0xFFFFECF1)),
  HijaiyahData(huruf: "ظ", nama: "Zha", arabic: "ظ", latin: "Zha", awal: "ظـ", tengah: "ـظـ", akhir: "ـظ", color: Color(0xFFE0F7FA)),
  HijaiyahData(huruf: "ع", nama: "Ain", arabic: "ع", latin: "‘A", awal: "عـ", tengah: "ـعـ", akhir: "ـع", color: Color(0xFFE3F2FD)),
  HijaiyahData(huruf: "غ", nama: "Ghain", arabic: "غ", latin: "Gho", awal: "غـ", tengah: "ـغـ", akhir: "ـغ", color: Color(0xFFE8F5E9)),
  HijaiyahData(huruf: "ف", nama: "Fa", arabic: "ف", latin: "Fa", awal: "فـ", tengah: "ـفـ", akhir: "ـف", color: Color(0xFFFFFDE7)),
  HijaiyahData(huruf: "ق", nama: "Qaf", arabic: "ق", latin: "Qa", awal: "قـ", tengah: "ـقـ", akhir: "ـق", color: Color(0xFFF3E5F5)),
  HijaiyahData(huruf: "ك", nama: "Kaf", arabic: "ك", latin: "Ka", awal: "كـ", tengah: "ـكـ", akhir: "ـك", color: Color(0xFFE1F5FE)),
  HijaiyahData(huruf: "ل", nama: "Lam", arabic: "ل", latin: "La", awal: "لـ", tengah: "ـلـ", akhir: "ـل", color: Color(0xFFFFF3E0)),
  HijaiyahData(huruf: "م", nama: "Mim", arabic: "م", latin: "Ma", awal: "مـ", tengah: "ـمـ", akhir: "ـم", color: Color(0xFFE3F2FD)),
  HijaiyahData(huruf: "ن", nama: "Nun", arabic: "ن", latin: "Na", awal: "نـ", tengah: "ـنـ", akhir: "ـن", color: Color(0xFFFFEBEE)),
  HijaiyahData(huruf: "ه", nama: "Ha'", arabic: "ه", latin: "Ha", awal: "هـ", tengah: "ـهـ", akhir: "ـه", color: Color(0xFFE8F5E9)),
  HijaiyahData(huruf: "و", nama: "Wau", arabic: "و", latin: "Wa", awal: "و", tengah: "ـو", akhir: "ـو", color: Color(0xFFFFFDE7)),
  HijaiyahData(huruf: "ي", nama: "Ya", arabic: "ي", latin: "Ya", awal: "يـ", tengah: "ـيـ", akhir: "ـي", color: Color(0xFFF3E5F5)),
];