import 'package:flutter/material.dart';
import './request_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Trading Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Trading Dashboard'),
      ),
      body: FutureBuilder(
        future: fetchWithJwt(), // 비동기 함수를 FutureBuilder에 전달
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터 로딩 중일 때 로딩 인디케이터 표시
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 오류 발생 시 오류 메시지 표시
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Row(
            children: [
              NavigationRail(
                selectedIndex: 0,
                onDestinationSelected: (int index) {
                  // Handle navigation
                },
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_balance_wallet),
                    label: Text('Wallet'),
                  ),
                  // Add other destinations
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    // Placeholder for chart
                    Expanded(
                      child: Placeholder(),
                    ),
                    // Placeholder for table or list of trades
                    Expanded(
                      child: Placeholder(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action button press
        },
        child: Icon(Icons.add),
        tooltip: 'New Trade',
      ),
    );
  }
}
