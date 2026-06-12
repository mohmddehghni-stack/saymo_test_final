import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/providers/calendar_provider.dart';
import 'package:flutter_application_1/core/providers/notes_manager_provider.dart';
import '../widgets/notes_grid_painter.dart';
import '../widgets/notes_toolbar.dart';
import '../widgets/notes_input_bar.dart';
import '../widgets/notes_my_list.dart';
import '../widgets/notes_partner_list.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart'; // 🔥 اضافه شد

class NotesTabContent extends StatefulWidget {
  const NotesTabContent({super.key});

  @override
  State<NotesTabContent> createState() => _NotesTabContentState();
}

class _NotesTabContentState extends State<NotesTabContent> {
  final TextEditingController _noteController = TextEditingController();

  bool _isEditMode = false;
  bool _isDeleteMode = false;
  int? _editingId;
  bool _isTickMode = false;

  @override
  void initState() {
    super.initState();
    final notesProvider = context.read<NotesManagerProvider>();
    final cp = context.read<CalendarProvider>();
    notesProvider.setup(cp.userId ?? '', cp.partnerId ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesManagerProvider>();
    // 🔥 دریافت تم
    final appTheme = Theme.of(context).extension<AppTheme>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // رنگ‌های پویا
    final Color scaffoldBg =
        appTheme?.surfaceBackground ?? const Color(0xFFF5F0E8);
    final Color cardBg = appTheme?.cardBackground ?? Colors.white;
    final Color textColor = appTheme?.textPrimary ?? const Color(0xFF1A1A2E);
    final Color hintColor = appTheme?.textHint ?? const Color(0xFF8E8E98);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: scaffoldBg, // 👈 پس‌زمینه اصلی
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: NotesGridPainter())),
            Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : NotesPartnerList(notes: provider.partnerNotes),
                  ),
                ),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.primaryDark.withOpacity(isDark ? 0.5 : 0.3),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: NotesMyList(
                      notes: provider.myNotes,
                      isTickMode: _isTickMode,
                      isEditMode: _isEditMode,
                      isDeleteMode: _isDeleteMode,
                      editingId: _editingId,
                      onTick: (id) => provider.toggleTickApi(id),
                      onEdit: (id) {
                        setState(() {
                          _editingId = id;
                          final note =
                              provider.allNotes.firstWhere((n) => n.id == id);
                          _noteController.text = note.text;
                        });
                      },
                      provider: provider,
                    ),
                  ),
                ),
                // نوار وضعیت ویرایش
                if (_isEditMode)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDark
                        ? AppColors.primaryDark.withOpacity(0.15)
                        : AppColors.periodBackground,
                    child: Row(
                      children: [
                        const Icon(Icons.edit,
                            size: 16, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Text(
                          'روی یادداشت بزن تا ویرایش کنی ✏️',
                          style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 12,
                            color:
                                isDark ? Colors.white70 : AppColors.primaryDark,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isEditMode = false;
                            _editingId = null;
                            _noteController.clear();
                          }),
                          child: const Text('لغو',
                              style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 12,
                                  color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                // نوار وضعیت حذف
                if (_isDeleteMode)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDark
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFFFFF0F0),
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline,
                            size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'تیک بزن و دوباره حذف رو بزن 🗑️',
                          style: TextStyle(
                              fontFamily: 'Vazir',
                              fontSize: 12,
                              color: Colors.red),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _isDeleteMode = false),
                          child: const Text('لغو',
                              style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 12,
                                  color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                NotesToolbar(
                  isEditMode: _isEditMode,
                  isDeleteMode: _isDeleteMode,
                  isTickMode: _isTickMode,
                  onNewNote: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: cardBg, // 👈
                        title: Text('پاک کردن همه',
                            style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 16,
                                color: textColor)),
                        content: Text('همه یادداشت‌ها پاک بشن؟',
                            style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 14,
                                color: hintColor)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('نه',
                                  style: TextStyle(color: hintColor))),
                          ElevatedButton(
                            onPressed: () {
                              provider.deleteAllNotes();
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('آره',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  onToggleEdit: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                      _isDeleteMode = false;
                      _isTickMode = false;
                      _editingId = null;
                      _noteController.clear();
                    });
                  },
                  onToggleDelete: () {
                    setState(() {
                      _isDeleteMode = !_isDeleteMode;
                      _isEditMode = false;
                      _isTickMode = false;
                      _editingId = null;
                      _noteController.clear();
                      if (_isDeleteMode) provider.clearDeleteSelection();
                    });
                  },
                  onConfirmDelete: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: cardBg, // 👈
                        title: Text('حذف',
                            style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 16,
                                color: textColor)),
                        content: Text('یادداشت‌های انتخاب‌شده حذف بشن؟',
                            style: TextStyle(
                                fontFamily: 'Vazir',
                                fontSize: 14,
                                color: hintColor)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('نه',
                                  style: TextStyle(color: hintColor))),
                          ElevatedButton(
                            onPressed: () {
                              provider.deleteSelected();
                              setState(() => _isDeleteMode = false);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('آره حذف کن',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  onToggleTick: () {
                    setState(() {
                      _isTickMode = !_isTickMode;
                      _isEditMode = false;
                      _isDeleteMode = false;
                      _editingId = null;
                      _noteController.clear();
                    });
                  },
                ),
                NotesInputBar(
                  controller: _noteController,
                  onSend: () {
                    final text = _noteController.text.trim();
                    if (text.isNotEmpty) {
                      if (_editingId != null) {
                        provider.updateNote(_editingId!, text);
                        setState(() {
                          _editingId = null;
                          _isEditMode = false;
                        });
                      } else {
                        provider.addNote(text);
                      }
                      _noteController.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
