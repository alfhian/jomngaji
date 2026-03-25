import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyQuizModernCard extends StatelessWidget {
  final String arabicText;
  final List<String> options;
  final String? selectedAnswer;
  final String correctAnswer;
  final Function(String) onSelect;
  final bool showResult;

  const DailyQuizModernCard({
    super.key,
    required this.arabicText,
    required this.options,
    required this.correctAnswer,
    required this.onSelect,
    this.selectedAnswer,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FFF4), Color(0xFFE0F7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kuis Harian",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF00796B))),
          const SizedBox(height: 6),
          Text("Pilih bunyi yang tepat untuk bacaan ini",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 18),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Text(
                arabicText,
                style: GoogleFonts.amiri(fontSize: 40, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: options.map((opt) {
              final isSelected = selectedAnswer == opt;
              final isCorrect = showResult && opt == correctAnswer;
              final isWrong = showResult && isSelected && opt != correctAnswer;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Icon icon = const Icon(Icons.radio_button_unchecked, color: Colors.grey);

              if (isSelected && !showResult) {
                icon = const Icon(Icons.check_circle_outline, color: Colors.blueAccent);
              } else if (isCorrect) {
                bgColor = const Color(0xFFD0F8CE);
                borderColor = const Color(0xFF66BB6A);
                icon = const Icon(Icons.check_circle, color: Color(0xFF2E7D32));
              } else if (isWrong) {
                bgColor = const Color(0xFFFFEBEE);
                borderColor = const Color(0xFFEF5350);
                icon = const Icon(Icons.cancel, color: Color(0xFFD32F2F));
              }

              return GestureDetector(
                onTap: () => onSelect(opt),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      icon,
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
