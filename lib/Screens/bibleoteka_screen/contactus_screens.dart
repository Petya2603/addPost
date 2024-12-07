import 'package:addpost/config/constants/constants.dart';
import 'package:addpost/config/constants/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  ContactUsScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  Future<void> sendContactUsData() async {
    if (nameController.text.isNotEmpty && contactController.text.isNotEmpty && messageController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection("Contact_Us").add({
          'name': nameController.text,
          'contact': contactController.text,
          'message': messageController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        nameController.clear();
        contactController.clear();
        messageController.clear();
      } catch (e) {
        return;
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Связаться с нами',
              style: TextStyle(color: AppColors.black),
            ),
          ],
        ),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Сотрудничество',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'По вопросам сотрудничества в информационном обеспечении вашего мероприятия, используйте нашу контактную форму для всех информационных запросов. Мы обязательно рассмотрим ваше предложение и свяжемся с вами.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: nameController,
                labelText: 'Имя',
                hintText: 'Введите свое имя',
              ),
              const SizedBox(height: 16),
              buildTextFormField(controller: contactController, labelText: 'Номер телефона или почта', hintText: 'Введите номер телефона'),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: messageController,
                labelText: 'Сообщение',
                hintText: 'Введите ваше сообщение...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: sendContactUsData,
                  child: const Text(
                    'Отправить',
                    style: TextStyle(fontSize: 18, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
