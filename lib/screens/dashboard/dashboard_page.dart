import 'package:flutter/material.dart';
import '../../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {

  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Kewéré Smart",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,

                mainAxisSpacing: 16,

                crossAxisSpacing: 16,

                childAspectRatio: 1.3,

                children: const [

                  StatCard(
                    title: "Fermes",
                    value: "12",
                    icon: Icons.home,
                    color: Colors.blue,
                  ),

                  StatCard(
                    title: "Employés",
                    value: "48",
                    icon: Icons.people,
                    color: Colors.green,
                  ),

                  StatCard(
                    title: "Cycles",
                    value: "9",
                    icon: Icons.loop,
                    color: Colors.orange,
                  ),

                  StatCard(
                    title: "Alertes",
                    value: "3",
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [

                    BoxShadow(

                      color: Colors.grey.withOpacity(0.1),

                      blurRadius: 10,
                    )
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Résumé Avicole",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: const [

                        Text("Production"),

                        Text(
                          "2450",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: const [

                        Text("Mortalité"),

                        Text(
                          "18",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: const [

                        Text("Bénéfices"),

                        Text(
                          "1 250 000 FCFA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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