import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailUser extends StatefulWidget {
  const DetailUser({super.key});

  @override
  State<DetailUser> createState() => _DetailUserState();
}

class _DetailUserState extends State<DetailUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          flexibleSpace: SafeArea(
            child: Center(
              child: Text(
                'User Details',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF5CB58),
          elevation: 0,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Text(
                    'Waiting for the rider pickup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconWithLabel(
                        icon: Icons.receipt_long,
                        label: 'Order',
                        iconColor: Colors.orange,
                      ),
                      DottedLine(),
                      IconWithLabel(
                        icon: Icons.kitchen,
                        label: 'Cooking',
                      ),
                      DottedLine(),
                      IconWithLabel(
                        icon: Icons.delivery_dining,
                        label: 'Delivery',
                      ),
                      DottedLine(),
                      IconWithLabel(
                        icon: Icons.check_circle,
                        label: 'Complete',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Align(
                  //   alignment: Alignment.centerLeft, // ทำให้ชิดซ้าย
                  //   child: Text(
                  //     'Description',
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // Text(
                  //   'Hong Thong is one of Thailand\'s most popular spirits, '
                  //   'known for its distinctive smooth taste and aromatic profile.',
                  //   style: TextStyle(fontSize: 14),
                  //   textAlign: TextAlign.left, // ข้อความคำอธิบายชิดซ้าย
                  // ),
                  Description(
                    context,
                    'Description', // ส่ง title
                    'Hong Thong is one of Thailand\'s most popular spirits, '
                        'known for its distinctive smooth taste and aromatic profile.', // ส่ง description
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Sender', 'Kiw printf',
                      'Mahasarakham University', '0987564213'),
                  _buildInfoRow('Receiver', 'TJ',
                      'Sinsup City Home Mahasarakham University', '0912345678'),
                  SizedBox(height: 16),
                  PicNameAmount(
                    context,
                    'https://www.hokkee.com/hk_shop/images/product/4066a7_e38df6d433a94450b09f95470a026bce_mv2-28-09-2022-16-05-42.jpg', // URL ของรูปภาพ
                    'Hong Thong', // ชื่อสินค้า
                    '1', // จำนวนสินค้า
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String title, String name, String address, String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(name),
                Text(address),
                Text(phone),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IconWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const IconWithLabel({
    required this.icon,
    required this.label,
    this.iconColor = Colors.black,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 30, color: iconColor),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class DottedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: 40,
      child: Row(
        children: List.generate(12, (index) {
          return Expanded(
            child: Container(
              color: index.isEven ? Colors.grey : Colors.transparent,
              height: 2,
            ),
          );
        }),
      ),
    );
  }
}

Widget PicNameAmount(
    BuildContext context, String imageUrl, String productName, String amount) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.network(
          imageUrl, // ใช้ตัวแปร imageUrl ที่ส่งมา
          height: 100, // ลดขนาดความสูง
          width: 100, // เพิ่มขนาดความกว้างเพื่อให้รูปภาพมีสัดส่วนที่เหมาะสม
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName, // ใช้ตัวแปร productName ที่ส่งมา
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Item: $amount', // ใช้ตัวแปร amount ที่ส่งมา
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget Description(BuildContext context, String title, String description) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
    children: [
      Align(
        alignment: Alignment.centerLeft, // ทำให้ชิดซ้าย
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 8), // เว้นระยะห่างระหว่างหัวข้อกับเนื้อหา
      Text(
        description,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.left, // ข้อความคำอธิบายชิดซ้าย
      ),
    ],
  );
}
