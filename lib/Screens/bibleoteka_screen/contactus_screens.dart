import 'package:addpost/Config/constants/widgets.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Связаться с нами',
              style: TextStyle(color: black),
            ),
          ],
        ),
      ),
      body: ListView(children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
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
                  labelText: 'Имя', hintText: 'Введите свое имя'),
              const SizedBox(height: 16),
              buildTextFormField(
                  labelText: 'Номер телефона или почта',
                  hintText: 'Введите номер телефона'),
              const SizedBox(height: 16),
              buildTextFormField(
                labelText: 'Сообщение',
                hintText: 'Введите ваше сообщение...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Отправить',
                    style: TextStyle(fontSize: 18, color: white),
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
