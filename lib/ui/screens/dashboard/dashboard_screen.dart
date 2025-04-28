import 'package:flutter/material.dart';
import 'package:techgear/ui/screens/dashboard/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        if (Responsive.isMobile(context)) SizedBox(height: 16),
                        if (Responsive.isMobile(context)) Text("data"),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context)) SizedBox(width: 16),
                  // On Mobile means if the screen is less than 850 we don't want to show it
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child: Text("data"),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
