import 'package:flutter/material.dart';
import 'package:flutter_application_rider/pages/order/order_card.dart';
import 'package:google_fonts/google_fonts.dart';

class CompletedOrderPage extends StatefulWidget {
  const CompletedOrderPage({super.key});

  @override
  State<CompletedOrderPage> createState() => _CompletedOrderPageState();
}

class _CompletedOrderPageState extends State<CompletedOrderPage> {
  bool isReceiveMode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isReceiveMode = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isReceiveMode ? const Color(0xFFE95322) : const Color(0xFFFFDECF),
                  textStyle: GoogleFonts.leagueSpartan(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Send',
                  style: TextStyle(color: !isReceiveMode ? Colors.white : const Color(0xFFE95322)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isReceiveMode = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReceiveMode ? const Color(0xFFE95322) : const Color(0xFFFFDECF),
                  textStyle: GoogleFonts.leagueSpartan(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Receive',
                  style: TextStyle(color: isReceiveMode ? Colors.white : const Color(0xFFE95322)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isReceiveMode ? _buildReceivedOrderList() : _buildSentOrderList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentOrderList() {
    return ListView(
      children: [
        _buildReceivedOrderCard('Order #1234', 'Strawberry Shake', '3 items', '฿150', 'Delivered'),
        _buildReceivedOrderCard('Order #5678', 'Hong Thong', '2 items', '฿120', 'Delivered'),
        _buildReceivedOrderCard('Order #9101', 'White Whisky', '1 item', '฿200', 'Delivered'),
      ],
    );
  }

  Widget _buildReceivedOrderList() {
    return ListView(
      children: [
        _buildReceivedOrderCard('Order #1234', 'Strawberry Shake', '3 items', '฿150', 'Delivered'),
        _buildReceivedOrderCard('Order #5678', 'Hong Thong', '2 items', '฿120', 'Delivered'),
        _buildReceivedOrderCard('Order #9101', 'White Whisky', '1 item', '฿200', 'Delivered'),
      ],
    );
  }

  Widget _buildReceivedOrderCard(String orderNumber, String itemName, String items, String price, String status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderNumber,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              itemName,
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              items,
              style: GoogleFonts.leagueSpartan(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE95322),
              ),
            ),
          ],
        ),
      ),
    );
  }
}