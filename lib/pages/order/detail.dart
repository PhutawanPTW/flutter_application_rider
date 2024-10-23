import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/order_provider.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DetailUser extends StatefulWidget {
  final Stream<Order?> orderStream; // Change to nullable Order
  final bool isReceiveMode;

  const DetailUser({
    Key? key,
    required this.orderStream,
    required this.isReceiveMode,
  }) : super(key: key);

  @override
  State<DetailUser> createState() => _DetailUserState();
}

class _DetailUserState extends State<DetailUser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateStep(String status) {
    switch (status) {
      case 'Wait for Rider':
        currentStep = 0;
        break;
      case 'Cooking':
        currentStep = 1;
        break;
      case 'Delivery':
        currentStep = 2;
        break;
      case 'Complete':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }

    if (currentStep < 3) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Center(
              child: Text(
                'Detail Order',
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
      body: StreamBuilder<Order?>(
        stream: widget.orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading order details'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;

          // อัปเดต currentStep ตาม status ของ order
          updateStep(order.status);

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 20,
                child: Container(
                  color: const Color(0xFFF5CB58),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderStatus(order),
                        const SizedBox(height: 24),
                        _buildDescription(order),
                        const SizedBox(height: 24),
                        widget.isReceiveMode
                            ? Column(
                                children: [
                                  _buildContactInfo(
                                      'Sender', order.senderPhone),
                                  const SizedBox(height: 16),
                                  _buildContactInfo(
                                      'Receiver', order.recivePhone),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildContactInfo(
                                      'Sender', order.senderPhone),
                                  const SizedBox(height: 16),
                                  _buildContactInfo(
                                      'Receiver', order.recivePhone),
                                ],
                              ),
                        const SizedBox(height: 24),
                        _buildOrderItem(order),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderStatus(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4D4D4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.status,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5C5352),
                  ),
                ),
                Image.asset(
                  'assets/images/completed_task.png',
                  height: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildOrderProgress(),
        ],
      ),
    );
  }

  Widget _buildOrderProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOrderStep(
          activeSvg: 'assets/svg/Order.svg',
          inactiveSvg: 'assets/svg/Order.svg',
          isActive: currentStep >= 0,
          isSvg: true,
        ),
        _buildDottedLine(
          isActive: currentStep == 0,
          isPassed: currentStep > 0,
        ),
        _buildOrderStep(
          activeSvg: 'assets/svg/CookingColor.png',
          inactiveSvg: 'assets/svg/Cooking.png',
          isActive: currentStep >= 1,
          isSvg: false,
        ),
        _buildDottedLine(
          isActive: currentStep == 1,
          isPassed: currentStep > 1,
        ),
        _buildOrderStep(
          activeSvg: 'assets/svg/DeliveryColor.png',
          inactiveSvg: 'assets/svg/Delivery.png',
          isActive: currentStep >= 2,
          isSvg: false,
        ),
        _buildDottedLine(
          isActive: currentStep == 2,
          isPassed: currentStep > 2,
        ),
        _buildOrderStep(
          activeSvg: 'assets/svg/Complete.svg',
          inactiveSvg: 'assets/svg/Complete.svg',
          isActive: currentStep >= 3,
          isSvg: true,
        ),
      ],
    );
  }

  Widget _buildOrderStep({
    required String activeSvg,
    required String inactiveSvg,
    bool isActive = false,
    required bool isSvg,
  }) {
    return SizedBox(
      width: 24,
      height: 24,
      child: isSvg
          ? SvgPicture.asset(
              isActive ? activeSvg : inactiveSvg,
              color: isActive ? const Color(0xFFFE8C00) : null,
            )
          : Image.asset(
              isActive ? activeSvg : inactiveSvg,
            ),
    );
  }

  Widget _buildDottedLine({required bool isActive, required bool isPassed}) {
    if (isPassed) {
      return SizedBox(
        width: 50,
        child: Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: const Color(0xFFFE8C00),
              ),
            ),
          ),
        ),
      );
    }

    if (!isActive) {
      return SizedBox(
        width: 50,
        child: Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 50,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            children: List.generate(
              6,
              (index) {
                final position = _animation.value;
                final dotPosition = index / 5;
                final distance = (position - dotPosition).abs();
                final opacity = (1.0 - distance).clamp(0.3, 1.0);

                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: const Color(0xFFFE8C00).withOpacity(opacity),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescription(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.leagueSpartan(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5C5352),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          order.detail,
          style: GoogleFonts.leagueSpartan(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF878787),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(String title, String phone) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: Provider.of<UserProvider>(context, listen: false)
          .fetchUserData(phone),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final userData = snapshot.data;
        if (userData == null) {
          return const Text('User not found');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.leagueSpartan(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5C5352),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                userData['fullName'] ?? 'Unknown',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF878787),
                ),
              ),
            ),
            _buildContactDetailWithImage(
              'assets/images/placeholder.png',
              userData['address'] ?? 'No address',
            ),
            _buildContactDetailWithImage(
              'assets/images/phone-call.png',
              phone,
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactDetailWithImage(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.leagueSpartan(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF878787),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              order.imageUrl ?? '',
              height: 110,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 110,
                  width: 90,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.name,
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5C5352),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.amount} items',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF5C5352),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
