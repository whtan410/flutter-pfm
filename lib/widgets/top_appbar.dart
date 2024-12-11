import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../screens/auth_screen.dart';  
import '../providers/navigation_provider.dart'; 

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,  
        children: [
          const Spacer(),  
          Text(title),
          const SizedBox(width: 8),  
          const Icon(Icons.account_balance_wallet), 
          const Spacer(),  
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {

              context.read<NavigationProvider>().setIndex(0);
              
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {  
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                  (route) => false, 
                );
              }
            },
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}