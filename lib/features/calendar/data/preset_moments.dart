class PresetMoments {
  static const List<Map<String, String>> appointments = [
    {'title': 'سینما', 'emoji': '🎬'},
    {'title': 'رستوران', 'emoji': '🍽️'},
    {'title': 'کنسرت', 'emoji': '🎵'},
    {'title': 'کافه', 'emoji': '☕'},
    {'title': 'سفر', 'emoji': '✈️'},
    {'title': 'پیک‌نیک', 'emoji': '🧺'},
    {'title': 'پارک', 'emoji': '🌳'},
    {'title': 'استخر', 'emoji': '🏊'},
    {'title': 'باشگاه', 'emoji': '💪'},
    {'title': 'خرید', 'emoji': '🛍️'},
    {'title': 'موزه', 'emoji': '🏛️'},
    {'title': 'گالری', 'emoji': '🎨'},
    {'title': 'تئاتر', 'emoji': '🎭'},
    {'title': 'بازی', 'emoji': '🎮'},
    {'title': 'مهمانی', 'emoji': '🎉'},
    {'title': 'قرار کاری', 'emoji': '💼'},
  ];

  static const List<Map<String, String>> milestones = [
    {'title': 'سالگرد ازدواج', 'emoji': '💍'},
    {'title': 'سالگرد آشنایی', 'emoji': '💕'},
    {'title': 'تولد', 'emoji': '🎂'},
    {'title': 'ولنتاین', 'emoji': '❤️'},
    {'title': 'ماهگرد', 'emoji': '🌙'},
    {'title': 'روز مادر', 'emoji': '👩‍👧'},
    {'title': 'روز پدر', 'emoji': '👨‍👧'},
    {'title': 'روز زن', 'emoji': '👩'},
    {'title': 'روز مرد', 'emoji': '👨'},
    {'title': 'سال نو', 'emoji': '🎆'},
    {'title': 'یلدا', 'emoji': '🍉'},
    {'title': 'نوروز', 'emoji': '🌺'},
    {'title': 'کریسمس', 'emoji': '🎄'},
    {'title': 'عید فطر', 'emoji': '🌙'},
    {'title': 'عید قربان', 'emoji': '🐑'},
    {'title': 'نامزدی', 'emoji': '💎'},
    {'title': 'خواستگاری', 'emoji': '💐'},
  ];

  static const List<Map<String, String>> firsts = [
    {'title': 'اولین قرار', 'emoji': '🍿'},
    {'title': 'اولین بوسه', 'emoji': '💋'},
    {'title': 'اولین سفر', 'emoji': '✈️'},
    {'title': 'اولین فیلم', 'emoji': '🎬'},
    {'title': 'اولین آشنایی', 'emoji': '👋'},
    {'title': 'اولین پیام', 'emoji': '💬'},
    {'title': 'اولین تماس', 'emoji': '📞'},
    {'title': 'اولین عکس', 'emoji': '📸'},
    {'title': 'اولین هدیه', 'emoji': '🎁'},
    {'title': 'اولین رستوران', 'emoji': '🍽️'},
    {'title': 'اولین سینما', 'emoji': '🎬'},
    {'title': 'اولین کنسرت', 'emoji': '🎵'},
    {'title': 'اولین مهمانی', 'emoji': '🎉'},
    {'title': 'اولین شب یلدا', 'emoji': '🍉'},
    {'title': 'اولین نوروز', 'emoji': '🌺'},
    {'title': 'اولین دیدار', 'emoji': '👀'},
    {'title': 'اولین قدم زدن', 'emoji': '🚶'},
  ];

  static List<Map<String, String>> getPresetsForCategory(String category) {
    switch (category) {
      case 'appointment':
        return appointments;
      case 'milestone':
        return milestones;
      case 'first':
        return firsts;
      default:
        return [];
    }
  }
}
