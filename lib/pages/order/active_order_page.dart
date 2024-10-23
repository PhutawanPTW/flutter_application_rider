import 'package:flutter/material.dart';
import 'package:flutter_application_rider/pages/dialog/add_order_dialog.dart';
import 'package:flutter_application_rider/pages/order/detail.dart';
import 'package:flutter_application_rider/providers/auth_provider.dart';
import 'package:flutter_application_rider/providers/order_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ActiveOrderPage extends StatefulWidget {
  const ActiveOrderPage({super.key});

  @override
  State<ActiveOrderPage> createState() => _ActiveOrderPageState();
}

class _ActiveOrderPageState extends State<ActiveOrderPage> {
  @override
  void initState() {
    super.initState();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? currentUserPhone = authProvider.currentUserPhoneNumber;

    if (currentUserPhone != null) {
      // ดึงทั้ง Orders ที่เราส่งและ Orders ที่ส่งมาหาเรา
      orderProvider.fetchOrdersByCreator(currentUserPhone);
      orderProvider.fetchReceivedOrders(currentUserPhone);
    }
  }

  bool isReceiveMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Padding(
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
                    backgroundColor: !isReceiveMode
                        ? const Color(0xFFE95322)
                        : const Color(0xFFFFDECF),
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
                    style: TextStyle(
                        color: !isReceiveMode
                            ? Colors.white
                            : const Color(0xFFE95322)),
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
                    backgroundColor: isReceiveMode
                        ? const Color(0xFFE95322)
                        : const Color(0xFFFFDECF),
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
                    style: TextStyle(
                        color: isReceiveMode
                            ? Colors.white
                            : const Color(0xFFE95322)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isReceiveMode
                  ? _buildReceiveOrderList()
                  : _buildSendOrderList(),
            ),
            if (!isReceiveMode) ...[
              const SizedBox(height: 20),
              _buildAddNewOrderButton(),
            ],
          ],
        ),
      ),
    );
  }

// สร้างฟังก์ชัน widget สำหรับปุ่ม Add New Order
  Widget _buildAddNewOrderButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddOrderPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFDECF),
        textStyle: GoogleFonts.leagueSpartan(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Add New Order',
        style: TextStyle(color: Color(0xFFE95322)),
      ),
    );
  }

  Widget _buildSendOrderList() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserPhone = authProvider.currentUserPhoneNumber;

    return StreamBuilder<List<Order>>(
      stream: Provider.of<OrderProvider>(context, listen: false)
          .getSentOrdersStream(currentUserPhone!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No sent orders',
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(
              order.imageUrl,
              order.name,
              order.status,
              order.amount.toString(),
              order.recivePhone,
              order, // เพิ่ม parameter order
            );
          },
        );
      },
    );
  }

  Widget _buildReceiveOrderList() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserPhone = authProvider.currentUserPhoneNumber;

    return StreamBuilder<List<Order>>(
      stream: Provider.of<OrderProvider>(context, listen: false)
          .getReceivedOrdersStream(currentUserPhone!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No received orders',
              style: GoogleFonts.leagueSpartan(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(
              order.imageUrl,
              order.name,
              order.status,
              order.amount.toString(),
              order.senderPhone,
              order, // เพิ่ม parameter order
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(String? imageUrl, String title, String status,
      String itemCount, String senderPhone, Order order) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFD4D4D4), width: 1),
      ),
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$itemCount item${itemCount != '1' ? 's' : ''}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Status: $status',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailUser(
                                  order: order,
                                  isReceiveMode: isReceiveMode,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(20, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(color: Color(0xFFE95322)),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE95322),
                              textStyle: GoogleFonts.leagueSpartan(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: const Text(
                              'Check on Maps',
                              style: TextStyle(color: Colors.white),
                            ),
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
      ),
    );
  }
}
