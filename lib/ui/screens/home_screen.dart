import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/constants/app_constants.dart';
import 'package:test_app/providers/ThemeProvider.dart';

class HomeScreen extends StatefulWidget {
   static const routName= "/HomeScreen(";
   
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      // backgroundColor: AppColors.darkScaffoldColor,
      appBar: AppBar(title: Text("Shopify")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Swiper(
                    itemBuilder: (context, index) {
                      return Image.asset(
                        AppConstants.bannerImage[index],
                        fit: BoxFit.cover,
                      );
                    },
                    indicatorLayout: PageIndicatorLayout.COLOR,
                    autoplay: true,
                    itemCount: AppConstants.bannerImage.length,
                    pagination: const SwiperPagination(),
                    control: const SwiperControl(),
                  ),
                ),
              ),
              Text("Buy Now"),
              ElevatedButton(onPressed: () {}, child: Text("Click me ")),
              SwitchListTile(
                title: Text(
                  themeProvider.getIsDarkTHeme ? "Dark theme" : "Light Theme",
                ),
                value: themeProvider.getIsDarkTHeme,
                onChanged: (wilson) {
                  themeProvider.setDarkTheme(wilson);
                  print("Theme state is ${themeProvider.getIsDarkTHeme}");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
