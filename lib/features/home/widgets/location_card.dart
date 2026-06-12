import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_1/shared/services/couple_service.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  double _distance = 85;
  String _myLastUpdate = 'همین الان';
  String _partnerLastUpdate = '۵ دقیقه پیش';
  bool _isUpdating = false;
  double _myPinX = 0.6;
  double _myPinY = 0.5;
  double _partnerPinX = 0.3;
  double _partnerPinY = 0.35;

  // رنگ‌های جدید برند
  static const Color primaryPink = Color(0xFFFE4773);
  static const Color primaryPurple = Color(0xFF862AF5);

  void _updateLocation() async {
    setState(() => _isUpdating = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isUpdating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'برای استفاده از موقعیت مکانی، لطفاً دسترسی رو فعال کن 🗺️')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await CoupleService.updateLocation(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _isUpdating = false;
          _myLastUpdate = 'همین الان';
        });
        _showUpdateMessage();
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('خطا در گرفتن موقعیت 📡',
                style: TextStyle(fontFamily: 'Vazir'))),
      );
    }
  }

  void _showUpdateMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPink, primaryPurple], // صورتی → بنفش
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'موقعیتت بروز شد! 📍',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'عشقت می‌تونه ببینه کجایی... ❤️',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'باشه 😊',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // نقشه با دو پین
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryPink.withOpacity(0.03), // صورتی خیلی کمرنگ
                  primaryPurple.withOpacity(0.02), // بنفش خیلی کمرنگ
                ],
              ),
            ),
            child: Stack(
              children: [
                // شبکه خیابان‌های ساختگی
                ...List.generate(5, (i) {
                  return Positioned(
                    top: 25.0 + (i * 32),
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 1,
                      color: primaryPink.withOpacity(0.08),
                    ),
                  );
                }),
                ...List.generate(4, (i) {
                  return Positioned(
                    left: 25.0 + (i * 60),
                    top: 10,
                    bottom: 10,
                    child: Container(
                      width: 1,
                      color: primaryPurple.withOpacity(0.08),
                    ),
                  );
                }),

                // پین پارتنر (بنفش)
                Positioned(
                  left: MediaQuery.of(context).size.width * _partnerPinX,
                  top: 20 + (_partnerPinY * 100),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Text(
                          'عشقت ❤️',
                          style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 9,
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: primaryPurple,
                            size: 36,
                          ),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              color: primaryPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // پین خودم (صورتی)
                Positioned(
                  left: MediaQuery.of(context).size.width * _myPinX,
                  top: 20 + (_myPinY * 100),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Text(
                          'من 📍',
                          style: TextStyle(
                            fontFamily: 'Vazir',
                            fontSize: 9,
                            color: primaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: primaryPink.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: primaryPink,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryPink.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // اطلاعات و دکمه
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ردیف وضعیت‌ها
                Row(
                  children: [
                    // وضعیت من
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryPink.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'موقعیت تو',
                                    style: TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 10,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  Text(
                                    _myLastUpdate,
                                    style: const TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryPink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // وضعیت پارتنر
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryPurple.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: _partnerLastUpdate == 'آنلاین'
                                    ? const Color(0xFF4CAF50)
                                    : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'موقعیت عشقت',
                                    style: TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 10,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  Text(
                                    _partnerLastUpdate,
                                    style: const TextStyle(
                                      fontFamily: 'Vazir',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // نمایش فاصله
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: primaryPink,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'فاصله: ${_distance.toInt()} کیلومتر',
                        style: const TextStyle(
                          fontFamily: 'Vazir',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryPink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('❤️', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // دکمه بروزرسانی
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _updateLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      disabledBackgroundColor: primaryPink.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      _isUpdating
                          ? 'در حال بروزرسانی...'
                          : 'بروزرسانی موقعیت من',
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
