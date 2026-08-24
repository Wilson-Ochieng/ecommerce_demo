import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:test_app/screens/cartscreen%20.dart';
import 'package:test_app/screens/home_screen.dart';
import 'package:test_app/screens/profilescreen.dart';
import 'package:test_app/screens/searchscreen.dart';

class RootsScreen extends StatefulWidget {
  const RootsScreen({super.key});

  @override
  State<RootsScreen> createState() => _RootsScreenState();
}

class _RootsScreenState extends State<RootsScreen> {
  late List<Widget> screens;
  int currentScreen = 0;
  late PageController controller;

  @override
  void initState() {
    screens = [HomeScreen(), SearchScreen(), Cartscreen(), Profilescreen()];
    controller = PageController(initialPage: currentScreen);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        height: kBottomNavigationBarHeight,

        onDestinationSelected: (index) {

          setState(() {
            currentScreen=index;
            
          });
          
        },
        destinations: [
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.activity),
            icon: Icon(IconlyLight.activity),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.search),
            icon: Icon(IconlyLight.search),
            label: "search",
          ),
          NavigationDestination(
            selectedIcon: Icon(IconlyBold.bag2),
            icon: Icon(IconlyLight.bag2),
            label: "Cart",
          ),
        ],
      ),
    );
  }
}
