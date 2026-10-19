import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
    const Sidebar({super.key});

    @override
    Widget build(BuildContext context) {
        return Container(
            width: 260,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 197, 211, 241),
            ),
            child: Column(
                children: [
                    const SizedBox(height: 40),

                    const Text(
                        'Seqotia',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                const SizedBox(height: 40),

                ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text("Dashboard"),
                    onTap: () {},
                ),

                ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text("Users"),
                    onTap: () {},
                ),
                
                ],
            ),
        );
    }
}