import 'package:addpost/Config/constants/constants.dart';
import 'package:addpost/Config/constants/widgets.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/bibleoteka_screen/bibleoteka_screen.dart';
import 'package:addpost/Screens/category_screens/category_content.dart';
import 'package:addpost/Screens/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    homeController.initializeCategories();
    homeController.checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          logoadmin,
          height: 40,
          width: 130,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(const BibliotekaScreen());
            },
            icon: SvgPicture.asset(
              logo,
              colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (!homeController.isConnected.value) {
          return _buildNoInternetWidget();
        }
        if (homeController.categories.isEmpty) {
          return Center(child: spinKit());
        }
        return Column(
          children: [
            TabBar(
              onTap: homeController.changeTab,
              isScrollable: true,
              dividerColor: white,
              controller: homeController.tabController.value,
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              labelStyle: TextStyle(
                color: white,
                fontSize: 16,
              ),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: black2,
              ),
              tabs: homeController.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Tab(text: category['name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: homeController.tabIndex.value,
                  children: homeController.categories.map((category) {
                    return CategoryContent(
                      categoryname: category['name'],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNoInternetWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 75,
                color: grey1,
              ),
              const SizedBox(height: 40),
              Text(
                'У вас нет подключения к Интернету.',
                style: TextStyle(fontSize: 19, color: black2),
              ),
              const SizedBox(height: 40),
              Obx(() {
                if (homeController.isLoading.value) {
                  return Center(child: spinKit());
                }
                return ElevatedButton(
                  onPressed: homeController.retryConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                  ),
                  child: Text(
                    'Попробуйте еще раз',
                    style: TextStyle(color: white, fontSize: 16),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
