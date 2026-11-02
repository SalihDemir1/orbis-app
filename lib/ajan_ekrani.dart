import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

/// ═══════════════════════════════════════════════════════════════════════════
///  AJAN MODU TAM EKRANI
///  Koyu, ciddi, profesyonel. Merkezi morphing orb animasyonu.
/// ═══════════════════════════════════════════════════════════════════════════

// ─── Ajan Ekranı Renkleri ──────────────────────────────────────────────
class AjanRenk {
  static const bg        = Color(0xFF020C18); // çok koyu lacivert
  static const surface   = Color(0xFF071428);
  static const card      = Color(0xFF0A1A35);

  // Orb renkleri — derin elektrik mavisi
  static const orbCore   = Color(0xFF0288D1); // canlı gökküzü mavisi
  static const orbMid    = Color(0xFF01579B); // koyu mavi
  static const orbGlow   = Color(0xFF80D8FF); // açık buz mavisi

  // Aksan
  static const accent    = Color(0xFF80D8FF); // buz mavisi
  static const accentHot = Color(0xFF00B0FF); // elektrik mavisi

  static const text      = Color(0xFFF0F8FF);
  static const textSoft  = Color(0x70F0F8FF);
  static const textDim   = Color(0x38F0F8FF);
}

/// Ana Ajan Modu ekranı widget'ı
class AjanModeEkrani extends StatefulWidget {
  const AjanModeEkrani({super.key});

  @override
  State<AjanModeEkrani> createState() => _AjanModeEkraniState();
}

class _AjanModeEkraniState extends State<AjanModeEkrani>
    with TickerProviderStateMixin {

  // ── Animasyon kontrolcüleri ────────────────────────────────────────────
  late AnimationController _orbCtrl;     // Ana orb nefes animasyonu
  late AnimationController _morphCtrl;   // Orb şekil morph animasyonu
  late AnimationController _scanCtrl;    // Tarama çizgisi animasyonu
  late AnimationController _pulseCtrl;   // Dış halka dalgaları

  // ── UI state ──────────────────────────────────────────────────────────
  bool _ajanAktif  = false;
  bool _islemde    = false;
  bool _dinliyor   = false;  // Ses dinleme aktif mi
  String _durum    = "GELİŞMİŞ AJAN MODU";
  String _altDurum = "Konuşarak talimat verin.";

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  Timer? _silenceTimer;
  String _dinlenenMetin = ''; // STT'den gelen anlık metin

  @override
  void initState() {
    super.initState();
    _setupTts();
    _stt.initialize();

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Kısa süre sonra "aktif" olduğunu göster
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _ajanAktif = true);
      }
    });
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _stt.stop();
    _orbCtrl.dispose();
    _morphCtrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage("tr-TR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  // Ana ajan API çağrısı — metin al ve sesli cevap al
  Future<void> _ajanKomutGonder(String txt) async {
    if (txt.trim().isEmpty || _islemde) return;
    setState(() {
      _islemde  = true;
      _dinliyor = false;
      _durum    = "AJAN İŞLENYOR";
      _altDurum = "Derin düşünce modu aktif...";
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:8000/sohbet'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'mesaj': txt, 'is_agent': true}),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data   = jsonDecode(response.body);
        final answer = data['cevap'] as String;
        if (mounted) {
          setState(() {
            _islemde  = false;
            _durum    = "AJAN KONUŞUYOR";
            _altDurum = answer.length > 80 ? '${answer.substring(0, 80)}...' : answer;
          });
        }
        await _tts.speak(answer);
        _tts.setCompletionHandler(() {
          if (mounted) {
            setState(() {
              _durum    = "GELİŞMİŞ AJAN MODU";
              _altDurum = "Konuşarak talimat verin.";
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _islemde  = false;
            _durum    = "BAĞLANTI HATASI";
            _altDurum = "Sunucu: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _islemde  = false;
          _durum    = "SUNUCU ERiŞİM HATASI";
          _altDurum = "Ağ bağlantısını kontrol edin.";
        });
      }
    }
  }

  // ─── Mikrofon Kontrolü ───────────────────────────────────────────────────
  Future<void> _toggleMic() async {
    if (_islemde) return;
    
    await _tts.stop();

    if (!_dinliyor) {
      final available = await _stt.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _dinliyor = false);
            if (_dinlenenMetin.trim().isNotEmpty) {
              _ajanKomutGonder(_dinlenenMetin.trim());
            }
          }
        },
        onError: (e) {
          if (mounted) setState(() => _dinliyor = false);
        },
      );

      if (available) {
        setState(() {
          _dinliyor = true;
          _dinlenenMetin = '';
          _durum = "DİNLEME MODU";
          _altDurum = "Söyleyin, Orbis dinliyor...";
        });

        await _stt.listen(
          localeId: "tr_TR",
          onResult: (r) {
            setState(() {
              _dinlenenMetin = r.recognizedWords;
              // Ekranda dinlediğini anlık göstersin diye alt duruma yazalım
              _altDurum = _dinlenenMetin.isEmpty 
                  ? "Söyleyin, Orbis dinliyor..." 
                  : _dinlenenMetin;
            });
            
            // 2 saniye sessizlik olursa otomatik gönder
            _silenceTimer?.cancel();
            _silenceTimer = Timer(const Duration(seconds: 2), () {
              if (_dinliyor && _dinlenenMetin.trim().isNotEmpty) {
                _stt.stop();
                setState(() => _dinliyor = false);
                _ajanKomutGonder(_dinlenenMetin.trim());
              }
            });
          },
        );
      } else {
         setState(() {
            _durum = "HATA";
            _altDurum = "Mikrofon başlatılamadı.";
         });
      }
    } else {
      // Manuel kapatma
      _silenceTimer?.cancel();
      setState(() => _dinliyor = false);
      _stt.stop();
      if (_dinlenenMetin.trim().isNotEmpty) {
        _ajanKomutGonder(_dinlenenMetin.trim());
      } else {
        setState(() {
          _durum    = "GELİŞMİŞ AJAN MODU";
          _altDurum = "Konuşarak talimat verin.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AjanRenk.bg,
      body: Stack(
        children: [

          // 1. Arka plan: derin uzay gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.4,
                colors: [Color(0xFF001A3A), AjanRenk.bg],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // 2. Grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // 3. Tarama çizgisi
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, __) => Positioned(
              top: _scanCtrl.value * MediaQuery.of(context).size.height,
              left: 0, right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AjanRenk.accentHot.withValues(alpha: 0.5),
                      AjanRenk.orbCore.withValues(alpha: 0.6),
                      AjanRenk.accentHot.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Ana içerik
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(child: _buildOrbSection()),
                _buildVoiceBar(context),  // Ses butonu
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ÜST BAR ────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AjanRenk.surface.withValues(alpha: 0.6),
            border: Border(
              bottom: BorderSide(
                  color: AjanRenk.accentHot.withValues(alpha: 0.20)),
            ),
          ),
          child: Row(
            children: [
              // Geri butonu
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AjanRenk.card,
                    border: Border.all(
                        color: AjanRenk.accentHot.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AjanRenk.accent, size: 16),
                ),
              ),
              const SizedBox(width: 14),

              // Başlık
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AJAN MODU",
                    style: TextStyle(
                      color: AjanRenk.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                  Text("ORBIS ADVANCED AGENT SYSTEM",
                    style: TextStyle(
                      color: AjanRenk.accentHot.withValues(alpha: 0.7),
                      fontSize: 9,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Durum göstergesi
              _StatusBadge(aktif: _ajanAktif, islemde: _islemde),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ORB + DURUM BÖLGESİ ─────────────────────────────────────────────────
  Widget _buildOrbSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 12),

        // Ana orb
        SizedBox(
          width: 290, height: 290,
          child: AnimatedBuilder(
            animation: Listenable.merge([_orbCtrl, _morphCtrl, _pulseCtrl]),
            builder: (_, __) {
              return CustomPaint(
                painter: _AjanOrbPainter(
                  breathe: _orbCtrl.value,
                  morph: _morphCtrl.value,
                  pulse: _pulseCtrl.value,
                  islemde: _islemde || _dinliyor,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // Durum metni
        Text(_durum,
          style: TextStyle(
            color: (_islemde || _dinliyor) ? AjanRenk.accentHot : AjanRenk.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(_altDurum,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AjanRenk.textSoft,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Sadece: İnternet + Komut chip'leri
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CapChip(icon: Icons.language_rounded, label: "İnternet"),
            const SizedBox(width: 10),
            _CapChip(icon: Icons.terminal_rounded, label: "Komut"),
          ],
        ),
      ],
    );
  }

  // ─── SESLE TALIMAT BAR (komut girişi yok, sadece mikrofon) ─────────────
  Widget _buildVoiceBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(
            color: AjanRenk.surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                  color: AjanRenk.accentHot.withValues(alpha: 0.18)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kılavuz metni
              Text(
                _dinliyor ? "ORBIS DİNLİYOR" : _islemde ? "İŞLENİYOR" : "KONUŞUN",
                style: TextStyle(
                  color: AjanRenk.accentHot.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 14),

              // Büyük mikrofon butonu
              GestureDetector(
                onTap: _islemde ? null : _toggleMic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _dinliyor
                        ? RadialGradient(colors: [
                            AjanRenk.accentHot,
                            AjanRenk.orbCore,
                          ])
                        : RadialGradient(colors: [
                            AjanRenk.orbCore.withValues(alpha: _islemde ? 0.3 : 0.9),
                            AjanRenk.orbMid.withValues(alpha: _islemde ? 0.2 : 0.7),
                          ]),
                    boxShadow: [
                      BoxShadow(
                        color: (_dinliyor ? AjanRenk.accentHot : AjanRenk.orbCore)
                            .withValues(alpha: _islemde ? 0.1 : 0.45),
                        blurRadius: _dinliyor ? 28 : 18,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _dinliyor ? Icons.mic : _islemde ? Icons.hourglass_top_rounded : Icons.mic_none_rounded,
                    color: Colors.white.withValues(alpha: _islemde ? 0.35 : 1.0),
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  YARDIMCI WIDGET'LAR
// ══════════════════════════════════════════════════════════════════════════════

/// Üst köşe durum badge'i
class _StatusBadge extends StatelessWidget {
  final bool aktif;
  final bool islemde;
  const _StatusBadge({required this.aktif, required this.islemde});

  @override
  Widget build(BuildContext context) {
    final Color c = islemde
        ? AjanRenk.accentHot
        : aktif
            ? const Color(0xFF00E676)
            : AjanRenk.textDim;
    final String t = islemde ? "İŞLEM" : aktif ? "AKTİF" : "HAZIR";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: c,
                boxShadow: [BoxShadow(color: c, blurRadius: 6)])),
          const SizedBox(width: 6),
          Text(t,
            style: TextStyle(
              color: c, fontSize: 10,
              fontWeight: FontWeight.w700, letterSpacing: 1.5,
            )),
        ],
      ),
    );
  }
}



/// Yetenek chip
class _CapChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CapChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AjanRenk.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AjanRenk.accentHot.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AjanRenk.accent, size: 13),
          const SizedBox(width: 5),
          Text(label,
            style: const TextStyle(
              color: AjanRenk.textSoft,
              fontSize: 11,
              letterSpacing: 0.5,
            )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

/// Ajan orb: nefes alan, morphing, halkalı pembe-mor parlayan top
class _AjanOrbPainter extends CustomPainter {
  final double breathe;
  final double morph;
  final double pulse;
  final bool islemde;

  _AjanOrbPainter({
    required this.breathe,
    required this.morph,
    required this.pulse,
    required this.islemde,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Nefes: orb boyutu salınım yapar
    final scale = islemde
        ? 0.88 + 0.12 * sin(breathe * 2 * pi)         // işlemdeyken daha aktif
        : 0.78 + 0.10 * sin(breathe * 2 * pi);         // beklerken yavaş nefes
    final r = (size.width * 0.35) * scale;

    // ── Dış dalgalar (pulse) ───────────────────────────────────────────
    for (int i = 0; i < 3; i++) {
      final p = (pulse + i * 0.33) % 1.0;
      final alpha = (1.0 - p) * (islemde ? 0.45 : 0.22);
      final pr = r + p * 80;
      canvas.drawCircle(
        center, pr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = AjanRenk.orbCore.withValues(alpha: alpha),
      );
    }

    // ── Morphing dış şekil (blob) ──────────────────────────────────────
    final path = _buildBlobPath(center, r, morph);

    // Blob glow katmanı
    canvas.drawPath(path,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
        ..shader = RadialGradient(
          colors: [
            AjanRenk.orbCore.withValues(alpha: islemde ? 0.75 : 0.50),
            AjanRenk.orbMid.withValues(alpha:  islemde ? 0.50 : 0.30),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r * 1.5)),
    );

    // Blob iç dolu
    canvas.drawPath(path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AjanRenk.orbGlow,
            AjanRenk.orbCore,
            AjanRenk.orbMid,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // ── İç parlak nokta ────────────────────────────────────────────────
    final innerR = r * 0.30;
    canvas.drawCircle(center, innerR,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
        ..color = Colors.white.withValues(alpha: 0.6),
    );

    // ── Tarama çizgileri (yalnızca işlemdeyken) ────────────────────────
    if (islemde) {
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = AjanRenk.orbGlow.withValues(alpha: 0.3);

      for (int i = -3; i <= 3; i++) {
        final y = center.dy + i * (r / 3.5);
        canvas.drawLine(
          Offset(center.dx - r, y),
          Offset(center.dx + r, y),
          linePaint,
        );
      }
    }
  }

  /// Organic blob yolu oluşturur (spline yerine çokgen interpolasyon)
  Path _buildBlobPath(Offset center, double r, double t) {
    const pts = 12;
    final path = Path();
    for (int i = 0; i <= pts; i++) {
      final angle = (i / pts) * 2 * pi - pi / 2;
      // Her noktaya farklı frekanslarda sinüzoidel bozunum ekliyoruz
      final distortion =
          0.06 * sin(3 * angle + t * 2 * pi) +
          0.04 * sin(5 * angle - t * 1.3 * 2 * pi) +
          0.03 * cos(7 * angle + t * 0.7 * 2 * pi);
      final rr = r * (1 + distortion);
      final px = center.dx + rr * cos(angle);
      final py = center.dy + rr * sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_AjanOrbPainter old) =>
      old.breathe != breathe ||
      old.morph   != morph   ||
      old.pulse   != pulse   ||
      old.islemde != islemde;
}

/// Arka plan grid noktaları
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AjanRenk.accentHot.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
    // Köşe aksan çizgileri
    final linePaint = Paint()
      ..color = AjanRenk.accentHot.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Sol üst köşe
    canvas.drawLine(const Offset(20, 80), const Offset(80, 80), linePaint);
    canvas.drawLine(const Offset(20, 80), const Offset(20, 140), linePaint);
    // Sağ üst köşe
    canvas.drawLine(Offset(size.width - 20, 80), Offset(size.width - 80, 80), linePaint);
    canvas.drawLine(Offset(size.width - 20, 80), Offset(size.width - 20, 140), linePaint);
    // Sol alt köşe
    canvas.drawLine(Offset(20, size.height - 200), Offset(80, size.height - 200), linePaint);
    canvas.drawLine(Offset(20, size.height - 200), Offset(20, size.height - 260), linePaint);
    // Sağ alt köşe
    canvas.drawLine(Offset(size.width - 20, size.height - 200), Offset(size.width - 80, size.height - 200), linePaint);
    canvas.drawLine(Offset(size.width - 20, size.height - 200), Offset(size.width - 20, size.height - 260), linePaint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
