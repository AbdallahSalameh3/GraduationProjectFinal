import 'package:flutter/material.dart';
import 'package:graduation_project/pending_requests.dart';
import 'package:graduation_project/accepted_requests.dart';
import 'package:graduation_project/past_requests.dart';

class charity_dashboard extends StatefulWidget {
  final String charityID;

  charity_dashboard({required this.charityID});

  @override
  _charity_dashboard createState() => _charity_dashboard();
}

class _charity_dashboard extends State<charity_dashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      pending_requests(charityID: widget.charityID),
      accepted_requests(charityID: widget.charityID),
      past_requests(charityID: widget.charityID),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic RTL support
      child: Scaffold(
        body: Container(
          color: Color(0xFFF1FAF2), // very light green background
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions),
              label: 'الطلبات غير المقبولة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'الطلبات المقبولة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'الطلبات السابقة',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
