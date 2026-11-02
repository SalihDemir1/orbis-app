import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:isar/isar.dart';
import 'sohbet_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'ajan_ekrani.dart';

// ─── RENK PALETİ ───────────────────────────────────────────────────────────
class OrbisColors {
  // Arka planlar
  static const bg          = Color(0xFF0E0E1A); // gece mavisi
  static const surface     = Color(0xFF16162A); // derin lacivert-mor
  static const surfaceHigh = Color(0xFF1E1B4B); // indigo (kullanıcı balonu)
  static const card        = Color(0xFF12122A); // orbis balonu

  // Aksan renkler
  static const lila  = Color(0xFFA78BFA); // yumuşak mor/lila  ← ana aksan
  static const sky   = Color(0xFF38BDF8); // açık gökyüzü mavisi
  static const rose  = Color(0xFFF472B6); // pembe (aktif/dinleme)

  // Metin
  static const text     = Color(0xFFF1F5F9);
  static const textSoft = Color(0x80F1F5F9);

  // Kenarlık
  static const border = Color(0x14A78BFA); // çok ince lila
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [SohbetMesajiSchema],
    directory: dir.path,
  );
  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orbis',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: OrbisColors.bg,
        primaryColor: OrbisColors.lila,
        iconTheme: const IconThemeData(color: OrbisColors.text),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: OrbisColors.lila,
          selectionColor: Color(0x30A78BFA),
          selectionHandleColor: OrbisColors.lila,
        ),
      ),
      home: OrbisAnaEkran(isar: isar),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
class OrbisAnaEkran extends StatefulWidget {
  final Isar isar;
  const OrbisAnaEkran({super.key, required this.isar});

  @override
  State<OrbisAnaEkran> createState() => _OrbisAnaEkranState();
}

class _OrbisAnaEkranState extends State<OrbisAnaEkran>
    with SingleTickerProviderStateMixin {
  // ── Kontrolcüler ──────────────────────────────────────────────────────────
  final _textCtrl      = TextEditingController();
  final _searchCtrl    = TextEditingController();
  final _editCtrl      = TextEditingController();
  final _scaffoldKey   = GlobalKey<ScaffoldState>();
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  // ── State ─────────────────────────────────────────────────────────────────
  bool   _listening     = false;
  bool   _orbisPlaying  = false;
  bool   _processing    = false;
  String _sessionId     = DateTime.now().millisecondsSinceEpoch.toString();
  String _chatTitle     = 'Yeni Sohbet';
  int?   _editingMsgId;
  String _searchQuery   = '';
  Timer? _silenceTimer;

  // ── Input aksiyonları ─────────────────────────────────────────────────────
  bool   _actionsExpanded = false; // "+" butonu durumu
  bool   _agentMode       = false; // Ajan modu açık/kapalı

  // ── Animasyon ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _loadLatestSession();
    _stt.initialize();

    _tts.setStartHandler(()      => _setPlaying(true));
    _tts.setCompletionHandler(() => _setPlaying(false));
    _tts.setCancelHandler(()     => _setPlaying(false));

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  void _setPlaying(bool v) { if (mounted) setState(() => _orbisPlaying = v); }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    _searchCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  // ─── KURULUM ──────────────────────────────────────────────────────────────
  Future<void> _setupTts() async {
    await _tts.setLanguage("tr-TR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _loadLatestSession() async {
    final last = await widget.isar.sohbetMesajis.where()
        .sortByTarihDesc().findFirst();
    if (last != null && last.sessionId != null && mounted) {
      setState(() {
        _sessionId  = last.sessionId!;
        _chatTitle  = last.baslik ?? 'Yeni Sohbet';
      });
    }
  }

  // ─── YENI SOHBET ──────────────────────────────────────────────────────────
  void _newChat() {
    setState(() {
      _sessionId    = DateTime.now().millisecondsSinceEpoch.toString();
      _chatTitle    = 'Yeni Sohbet';
      _editingMsgId = null;
      _processing   = false;
    });
    _textCtrl.clear();
    Navigator.pop(context);
  }

  // ─── DÜZENLEME SİL + YENİDEN GÖNDER ──────────────────────────────────────
  Future<void> _editAndResend(int msgId, DateTime date, String newText) async {
    setState(() { _editingMsgId = null; });

    await widget.isar.writeTxn(() async {
      final all = await widget.isar.sohbetMesajis.filter()
          .sessionIdEqualTo(_sessionId).findAll();
      final ids = all
          .where((m) => m.tarih.isAfter(date) || m.tarih.isAtSameMomentAs(date) || m.id == msgId)
          .map((m) => m.id).toList();
      await widget.isar.sohbetMesajis.deleteAll(ids);
      
      // Removed the logic that resets the chatTitle to 'Yeni Sohbet'.
      // If we are editing the very first message of a chat, we SHOULD NOT change the title
      // back to 'Yeni Sohbet', because _sendToLlm relies on the title to determine if it's
      // a brand new session vs an existing session.
    });
    
    // Explicitly pass isEdit=true so _sendToLlm knows not to reset sessionId
    _sendToLlm(newText, isEdit: true);
  }

  // ─── VERİTABANINA YAZ ─────────────────────────────────────────────────────
  Future<void> _saveMsg(String text, bool isAssistant, {String? title}) async {
    String? t = title;
    if (!isAssistant && t == null) {
      if (_chatTitle != 'Yeni Sohbet') {
        t = _chatTitle;
      } else {
        final words = text.trim().split(RegExp(r'\s+'));
        t = words.take(4).join(' ');
        if (words.length > 4) t += '...';
      }
    }
    final msg = SohbetMesaji()
      ..metin     = text
      ..tarih     = DateTime.now()
      ..asistanMi = isAssistant
      ..baslik    = t
      ..sessionId = _sessionId;
    await widget.isar.writeTxn(() => widget.isar.sohbetMesajis.put(msg));
  }

  // ─── LLM'E GÖNDER ─────────────────────────────────────────────────────────
  Future<void> _sendToLlm(String prompt, {bool isEdit = false}) async {
    if (prompt.trim().isEmpty || _processing) return;
    await _saveMsg(prompt, false);
    _textCtrl.clear();

    if (_chatTitle == 'Yeni Sohbet' && !isEdit) {
      final words = prompt.trim().split(RegExp(r'\s+'));
      String title = words.take(4).join(' ');
      if (words.length > 4) title += '...';
      setState(() { _chatTitle = title; _processing = true; });
    } else {
      setState(() => _processing = true);
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:8000/sohbet'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'mesaj': prompt}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body);
        final answer  = data['cevap'] as String;
        await _saveMsg(answer, true);
        await _tts.speak(answer);
      } else {
        await _saveMsg("Bağlantı hatası: ${response.statusCode}", true);
      }
    } catch (e) {
      debugPrint("Bağlantı Hatası: $e");
      await _saveMsg("Sunucuya ulaşılamadı. Lütfen sunucunun açık olduğundan emin ol.", true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ─── MİKROFON ─────────────────────────────────────────────────────────────
  Future<void> _toggleMic() async {
    await _tts.stop();
    if (mounted) setState(() => _orbisPlaying = false);

    if (!_listening) {
      final available = await _stt.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _listening = false);
            if (_textCtrl.text.trim().isNotEmpty) {
              _sendToLlm(_textCtrl.text.trim());
            }
          }
        },
        onError: (e) { if (mounted) setState(() => _listening = false); },
      );
      if (available) {
        setState(() { _listening = true; _textCtrl.clear(); });
        await _stt.listen(
          localeId: "tr_TR",
          onResult: (r) {
            setState(() => _textCtrl.text = r.recognizedWords);
            _silenceTimer?.cancel();
            _silenceTimer = Timer(const Duration(seconds: 2), () {
              if (_listening && _textCtrl.text.trim().isNotEmpty) {
                _stt.stop();
                setState(() => _listening = false);
                _sendToLlm(_textCtrl.text.trim());
              }
            });
          },
        );
      }
    } else {
      _silenceTimer?.cancel();
      setState(() => _listening = false);
      _stt.stop();
      if (_textCtrl.text.trim().isNotEmpty) _sendToLlm(_textCtrl.text.trim());
    }
  }

  // ─── SOHBET YÖNETİMİ ──────────────────────────────────────────────────────
  Future<void> _deleteChat(String sid) async {
    await widget.isar.writeTxn(() async {
      await widget.isar.sohbetMesajis.filter().sessionIdEqualTo(sid).deleteAll();
    });
    if (_sessionId == sid && mounted) _newChat();
  }

  Future<void> _renameChat(String sid, String old) async {
    final ctrl = TextEditingController(text: old);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: OrbisColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sohbeti Adlandır",
            style: TextStyle(color: OrbisColors.text, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: OrbisColors.text),
          decoration: InputDecoration(
            hintText: "Yeni başlık",
            hintStyle: const TextStyle(color: OrbisColors.textSoft),
            filled: true, fillColor: OrbisColors.card,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: OrbisColors.textSoft))),
          TextButton(
            onPressed: () async {
              final newT = ctrl.text.trim();
              if (newT.isNotEmpty && newT != old) {
                final msgs = await widget.isar.sohbetMesajis.filter()
                    .sessionIdEqualTo(sid).findAll();
                if (msgs.isNotEmpty) {
                  await widget.isar.writeTxn(() async {
                    for (var m in msgs) {
                      m.baslik = newT;
                      await widget.isar.sohbetMesajis.put(m);
                    }
                  });
                }
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Kaydet",
                style: TextStyle(color: OrbisColors.lila, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChatOptions(String sid, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OrbisColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: OrbisColors.textSoft,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: OrbisColors.lila),
              title: const Text("Yeniden Adlandır",
                  style: TextStyle(color: OrbisColors.text)),
              onTap: () { Navigator.pop(context); _renameChat(sid, title); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: OrbisColors.rose),
              title: const Text("Sohbeti Sil",
                  style: TextStyle(color: OrbisColors.rose)),
              onTap: () { Navigator.pop(context); _deleteChat(sid); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: OrbisColors.bg,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // ── Arka plan orb animasyonu ────────────────────────────────────
          Positioned.fill(child: _OrbBackground(ctrl: _pulseCtrl, active: _processing)),

          // ── Ana içerik (sohbet + input) ─────────────────────────────────
          Column(children: [
            _buildChatStream(),
            _buildInputBar(),
          ]),

          // ── Üst bar (blur) ───────────────────────────────────────────────
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
        ],
      ),
    );
  }

  // ─── ÜST BAR ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            left: 4, right: 16, bottom: 10,
          ),
          decoration: BoxDecoration(
            color: OrbisColors.bg.withValues(alpha: 0.75),
            border: Border(
                bottom: BorderSide(
                    color: OrbisColors.lila.withValues(alpha: 0.12))),
          ),
          child: Row(children: [
            // Menü butonu
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: OrbisColors.text, size: 24),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            const SizedBox(width: 4),
            // Orbis logo + yazı
            _OrbisLogoMini(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ORBIS",
                    style: TextStyle(
                      color: OrbisColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(_chatTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: OrbisColors.textSoft,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Durum indikatörü
            if (_processing)
              _GlowDot(color: OrbisColors.lila)
            else if (_orbisPlaying)
              _GlowDot(color: OrbisColors.sky)
            else
              _GlowDot(color: OrbisColors.textSoft.withValues(alpha: 0.3)),
          ]),
        ),
      ),
    );
  }

  // ─── SOHBET AKIŞI ─────────────────────────────────────────────────────────
  Widget _buildChatStream() {
    return Expanded(
      child: StreamBuilder<List<SohbetMesaji>>(
        stream: widget.isar.sohbetMesajis.where()
            .filter().sessionIdEqualTo(_sessionId)
            .sortByTarihDesc().watch(fireImmediately: true).asBroadcastStream(),
        builder: (_, snap) {
          final msgs = snap.data ?? [];
          if (msgs.isEmpty) return _buildEmptyState();
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(16, 90, 16, 12),
            itemCount: msgs.length + (_processing ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (_processing && i == 0) return _buildTypingIndicator();
              final msg = msgs[_processing ? i - 1 : i];
              return _buildBubble(msg, i);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 100),
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: [OrbisColors.lila, OrbisColors.sky],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(b),
            child: const Text("ORBIS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 10,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Sana nasıl yardımcı olabilirim?",
            style: TextStyle(color: OrbisColors.textSoft, fontSize: 15, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  // ─── YAZMA GÖSTERGESİ ─────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: OrbisColors.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: OrbisColors.lila.withValues(alpha: 0.18)),
        ),
        child: _TypingDots(),
      ),
    );
  }

  // ─── MESAJ BALONU ─────────────────────────────────────────────────────────
  Widget _buildBubble(SohbetMesaji m, int index) {
    final isUser = !m.asistanMi;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? OrbisColors.surfaceHigh : OrbisColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: Border.all(
            color: isUser
                ? OrbisColors.lila.withValues(alpha: 0.35)
                : OrbisColors.sky.withValues(alpha: 0.12),
          ),
          boxShadow: isUser
              ? [BoxShadow(
                  color: OrbisColors.lila.withValues(alpha: 0.12),
                  blurRadius: 12, spreadRadius: 0,
                  offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Orbis mesajına sol cyan şerit
            if (!isUser)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(4)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 3, color: OrbisColors.sky.withValues(alpha: 0.6),
                        constraints: const BoxConstraints(minHeight: 40)),
                    Expanded(
                      child: _buildBubbleContent(m, isUser, index),
                    ),
                  ],
                ),
              )
            else
              _buildBubbleContent(m, isUser, index),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleContent(SohbetMesaji m, bool isUser, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Düzenleme modu
          if (_editingMsgId == m.id) ...[
            TextField(
              controller: _editCtrl,
              maxLines: null,
              autofocus: true,
              style: const TextStyle(color: OrbisColors.text, fontSize: 15, height: 1.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: OrbisColors.bg,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: OrbisColors.lila, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: OrbisColors.lila, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: OrbisColors.lila.withValues(alpha: 0.3))),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _editingMsgId = null),
                  child: const Text("İptal",
                      style: TextStyle(color: OrbisColors.textSoft, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrbisColors.lila,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_editCtrl.text.trim().isNotEmpty) {
                      _editAndResend(m.id, m.tarih, _editCtrl.text.trim());
                    }
                  },
                  child: const Text("Gönder", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ] else
            // Normal metin
            Text(m.metin,
                style: TextStyle(
                  color: isUser ? OrbisColors.text : const Color(0xFFCDD6E0),
                  fontSize: 15, height: 1.55,
                )),

          // Sesi kapat (sadece en son orbis mesajı konuşurken)
          if (m.asistanMi && index == (_processing ? 1 : 0) && _orbisPlaying) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () { _tts.stop(); setState(() => _orbisPlaying = false); },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.volume_off, color: OrbisColors.textSoft, size: 14),
                const SizedBox(width: 4),
                Text("Sesi kapat",
                    style: TextStyle(color: OrbisColors.textSoft, fontSize: 11)),
              ]),
            ),
          ],

          // Kullanıcı aksiyonları
          if (isUser && _editingMsgId != m.id) ...[
            const SizedBox(height: 8),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _ActionChip(
                icon: Icons.copy_outlined, label: "Kopyala",
                onTap: () {
                  Clipboard.setData(ClipboardData(text: m.metin));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Kopyalandı",
                          style: TextStyle(color: OrbisColors.text)),
                      backgroundColor: OrbisColors.surface,
                      duration: const Duration(milliseconds: 1500),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _ActionChip(
                icon: Icons.edit_outlined, label: "Düzenle",
                onTap: () => setState(() {
                  _editingMsgId = m.id;
                  _editCtrl.text = m.metin;
                }),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  // ─── GİRİŞ ALANI ──────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    final isListening = _listening;
    final borderColor = isListening
        ? OrbisColors.rose
        : _agentMode
            ? OrbisColors.sky.withValues(alpha: 0.45)
            : OrbisColors.lila.withValues(alpha: 0.25);

    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 6, 12, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: OrbisColors.bg.withValues(alpha: 0.97),
        border: Border(top: BorderSide(
            color: OrbisColors.lila.withValues(alpha: 0.10))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ══ GENİŞLEYEN AKSİYON PANELİ ══════════════════════════════════
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _actionsExpanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [

                        // ── Kamera ────────────────────────────────────────
                        _InputActionChip(
                          icon: Icons.camera_alt_outlined,
                          label: "Kamera",
                          color: const Color(0xFFFBBF24), // amber
                          onTap: () {
                            setState(() => _actionsExpanded = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Kamera entegrasyonu yakında!",
                                  style: TextStyle(color: OrbisColors.text),
                                ),
                                backgroundColor: OrbisColors.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(milliseconds: 2000),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        // ── Ajan Modu ─────────────────────────────────────
                        _InputActionChip(
                          icon: Icons.bolt,
                          label: "Ajan Modu",
                          color: OrbisColors.sky,
                          active: false,
                          onTap: () {
                            setState(() => _actionsExpanded = false);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const AjanModeEkrani(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(
                                      opacity: anim,
                                      child: child,
                                    ),
                                transitionDuration:
                                    const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),

                        // ── Galeriden seç (placeholder) ────────────────────
                        _InputActionChip(
                          icon: Icons.image_outlined,
                          label: "Galeri",
                          color: const Color(0xFF34D399), // emerald
                          onTap: () {
                            setState(() => _actionsExpanded = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Galeri entegrasyonu yakında!",
                                  style: TextStyle(color: OrbisColors.text),
                                ),
                                backgroundColor: OrbisColors.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(milliseconds: 2000),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Ajan modu aktifken üst bilgi şeridi ─────────────────────────
          if (_agentMode)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: OrbisColors.sky.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: OrbisColors.sky.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: OrbisColors.sky, size: 15),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      "Ajan Modu aktif — Orbis araçlarını kullanarak yanıt verir",
                      style: TextStyle(
                          color: OrbisColors.sky, fontSize: 11,
                          letterSpacing: 0.2),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _agentMode = false),
                    child: Icon(Icons.close, color: OrbisColors.sky, size: 14),
                  ),
                ],
              ),
            ),

          // ══ ANA INPUT SATIRI ═════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              // ── "+" Aksiyon aç/kapat ─────────────────────────────────────
              GestureDetector(
                onTap: () => setState(() => _actionsExpanded = !_actionsExpanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _actionsExpanded
                        ? OrbisColors.lila.withValues(alpha: 0.18)
                        : OrbisColors.surface,
                    border: Border.all(
                      color: _actionsExpanded
                          ? OrbisColors.lila.withValues(alpha: 0.5)
                          : OrbisColors.border,
                    ),
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: _actionsExpanded ? 0.125 : 0, // 45° döndür
                    child: Icon(
                      Icons.add_rounded,
                      color: _actionsExpanded
                          ? OrbisColors.lila
                          : OrbisColors.textSoft,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Input alanı ─────────────────────────────────────────────
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: OrbisColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                    boxShadow: isListening
                        ? [BoxShadow(
                            color: OrbisColors.rose.withValues(alpha: 0.20),
                            blurRadius: 12)]
                        : _agentMode
                            ? [BoxShadow(
                                color: OrbisColors.sky.withValues(alpha: 0.15),
                                blurRadius: 12)]
                            : null,
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    minLines: 1,
                    maxLines: 5,
                    style: const TextStyle(
                        color: OrbisColors.text, fontSize: 15, height: 1.4),
                    decoration: InputDecoration(
                      hintText: isListening
                          ? "Orbis dinliyor..."
                          : _agentMode
                              ? "Ajan modunda sor..."
                              : "Mesaj yaz...",
                      hintStyle: TextStyle(
                        color: isListening
                            ? OrbisColors.rose.withValues(alpha: 0.7)
                            : _agentMode
                                ? OrbisColors.sky.withValues(alpha: 0.6)
                                : OrbisColors.textSoft,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _sendToLlm(v.trim());
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Mikrofon ────────────────────────────────────────────────
              GestureDetector(
                onTap: _toggleMic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening
                        ? OrbisColors.rose.withValues(alpha: 0.18)
                        : OrbisColors.surface,
                    border: Border.all(
                      color: isListening
                          ? OrbisColors.rose
                          : OrbisColors.border,
                    ),
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: isListening ? OrbisColors.rose : OrbisColors.textSoft,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Gönder butonu ───────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  if (_listening) {
                    _silenceTimer?.cancel();
                    _stt.stop();
                    setState(() => _listening = false);
                  }
                  if (_textCtrl.text.trim().isNotEmpty) {
                    _sendToLlm(_textCtrl.text.trim());
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _agentMode
                          ? [OrbisColors.sky, const Color(0xFF0284C7)]
                          : [OrbisColors.lila, const Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_agentMode ? OrbisColors.sky : OrbisColors.lila)
                            .withValues(alpha: 0.45),
                        blurRadius: 14, spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _agentMode ? Icons.bolt : Icons.arrow_upward_rounded,
                    color: Colors.white, size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── DRAWER ───────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0B0B18),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                _OrbisLogoMini(),
                const SizedBox(width: 12),
                const Text("ORBIS",
                    style: TextStyle(
                      color: OrbisColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    )),
              ]),
            ),
            const SizedBox(height: 16),
            // Yeni sohbet butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: _newChat,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  decoration: BoxDecoration(
                    color: OrbisColors.lila.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: OrbisColors.lila.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.add_rounded, color: OrbisColors.lila, size: 20),
                    SizedBox(width: 10),
                    Text("Yeni Sohbet",
                        style: TextStyle(
                          color: OrbisColors.lila,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        )),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Arama çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                style: const TextStyle(color: OrbisColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Sohbetlerde ara...",
                  hintStyle: const TextStyle(color: OrbisColors.textSoft, fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: OrbisColors.textSoft, size: 18),
                  filled: true,
                  fillColor: OrbisColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text("GEÇMİŞ",
                  style: TextStyle(
                    color: OrbisColors.textSoft,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
            ),

            // Sohbet listesi
            Expanded(
              child: StreamBuilder<List<SohbetMesaji>>(
                stream: widget.isar.sohbetMesajis.where()
                    .filter().asistanMiEqualTo(false)
                    .sortByTarihDesc().watch(fireImmediately: true)
                    .asBroadcastStream(),
                builder: (_, snap) {
                  final all = snap.data ?? [];
                  final Map<String, SohbetMesaji> sessions = {};
                  for (var m in all) {
                    if (m.sessionId != null &&
                        !sessions.containsKey(m.sessionId) &&
                        m.baslik != null) {
                      if (_searchQuery.isEmpty ||
                          m.baslik!.toLowerCase().contains(_searchQuery)) {
                        sessions[m.sessionId!] = m;
                      }
                    }
                  }

                  if (sessions.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? "Henüz sohbet yok"
                            : "Sonuç bulunamadı",
                        style: const TextStyle(color: OrbisColors.textSoft, fontSize: 13),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: sessions.values.map((m) {
                      final isActive = m.sessionId == _sessionId;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? OrbisColors.lila.withValues(alpha: 0.10)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive
                              ? Border.all(
                                  color: OrbisColors.lila.withValues(alpha: 0.25))
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          minLeadingWidth: 20,
                          leading: Container(
                            width: 3, height: 36,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? OrbisColors.lila
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            m.baslik!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isActive ? OrbisColors.text : OrbisColors.textSoft,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert,
                                color: isActive
                                    ? OrbisColors.textSoft
                                    : const Color(0x00000000),
                                size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                _showChatOptions(m.sessionId!, m.baslik!),
                          ),
                          onTap: () {
                            setState(() {
                              _sessionId = m.sessionId!;
                              _chatTitle = m.baslik ?? 'Yeni Sohbet';
                            });
                            Navigator.pop(context);
                          },
                          onLongPress: () =>
                              _showChatOptions(m.sessionId!, m.baslik!),
                        ),
                      );
                    }).toList(),
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

// ══════════════════════════════════════════════════════════════════════════════
//  YARDIMCI WIDGET'LAR
// ══════════════════════════════════════════════════════════════════════════════

/// Üst bardaki küçük glowing orb logo
class _OrbisLogoMini extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [OrbisColors.sky, OrbisColors.lila, Color(0xFF0E0E1A)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: OrbisColors.lila.withValues(alpha: 0.5),
            blurRadius: 10, spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/orbis_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
              Icons.blur_circular, color: Colors.white70, size: 18),
        ),
      ),
    );
  }
}

/// Aksiyon chip (kopyala / düzenle)
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: OrbisColors.textSoft, size: 13),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: OrbisColors.textSoft, fontSize: 11)),
        ],
      ),
    );
  }
}

/// Input bar için büyük aksiyon pill butonu (kamera, ajan modu, galeri)
class _InputActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool active;

  const _InputActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.18)
              : OrbisColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.55)
                : color.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? color : OrbisColors.textSoft,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Küçük parlayan nokta (durum göstergesi)
class _GlowDot extends StatelessWidget {
  final Color color;
  const _GlowDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
      ),
    );
  }
}

/// Üç noktalı yazıyor animasyonu
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}
class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final progress = (_c.value * 3 - i).clamp(0.0, 1.0);
            final opacity  = (sin(progress * pi)).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7, height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OrbisColors.lila.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ARKA PLAN ORB ANİMASYONU
// ══════════════════════════════════════════════════════════════════════════════
class _OrbBackground extends StatelessWidget {
  final AnimationController ctrl;
  final bool active;
  const _OrbBackground({required this.ctrl, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _OrbPainter(ctrl.value, active),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double t;
  final bool active;
  _OrbPainter(this.t, this.active);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.42; // hafif yukarı
    final center = Offset(cx, cy);

    // Nefes animasyonu
    final breathe = active
        ? 1.0
        : 0.55 + 0.45 * sin(t * 2 * pi);

    // Radial gradient orb
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFA78BFA).withValues(alpha: active ? 0.22 : 0.12 * breathe),
          const Color(0xFF38BDF8).withValues(alpha: active ? 0.10 : 0.06 * breathe),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 200));

    canvas.drawCircle(center, 200, paint);

    // Dış halka dalgaları (sadece aktifken)
    if (active) {
      for (int i = 0; i < 3; i++) {
        final progress = (t + i * 0.33) % 1.0;
        final opacity  = (1.0 - progress) * 0.5;
        final radius   = 120 + progress * 200;
        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFFA78BFA).withValues(alpha: opacity);
        canvas.drawCircle(center, radius, ringPaint);
      }
    }

    // Statik arka plan: ince grid noktaları
    final dotPaint = Paint()
      ..color = const Color(0xFFA78BFA).withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.t != t || old.active != active;
}