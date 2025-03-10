import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'generated/v1.swagger.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  var timeStress = 5;
  var selectedTest = 0;
  V1? _api;
  List<Status> data = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _api = V1.create(baseUrl: Uri.parse('http://localhost:5231'));
    timer = Timer.periodic(Duration(milliseconds: 100), (t) async {
      await updateData();
    });
  }

  Future updateData() async {
    if (_api == null) {
      return;
    }

    var result = await _api!.stressngGetHistoryGet();

    if (result.isSuccessful && mounted) {
      setState(() {
        data = result.body!;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //disk Read/Write
    var diskR =
        data
            .mapIndexed((index, obj) => FlSpot(index.toDouble(), obj.diskR!))
            .toList();
    var diskW =
        data
            .mapIndexed((index, obj) => FlSpot(index.toDouble(), obj.diskW!))
            .toList();

    double maxDiskR = 250;
    double maxDiskW = 250;

    for (var data in diskR) {
      if (maxDiskR < data.y) {
        maxDiskR = data.y;
      }
    }

    for (var data in diskW) {
      if (maxDiskW < data.y) {
        maxDiskW = data.y;
      }
    }

    //Network R/T
    var rx =
        data
            .mapIndexed((index, obj) => FlSpot(index.toDouble(), obj.rxBytes!))
            .toList();
    var tx =
        data
            .mapIndexed((index, obj) => FlSpot(index.toDouble(), obj.txBytes!))
            .toList();

    double maxrx = 20000;
    double maxtx = 20000;

    for (var data in rx) {
      if (maxrx < data.y) {
        maxrx = data.y;
      }
    }

    for (var data in tx) {
      if (maxtx < data.y) {
        maxtx = data.y;
      }
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(width: 500, child: Row(
                children: [
                  Text("Time(s): "),
                  DropdownButton<int>(
                    value: timeStress,
                    items: [
                      DropdownMenuItem(value: 5, child: Text("5")),
                      DropdownMenuItem(value: 10, child: Text("10")),
                      DropdownMenuItem(value: 20, child: Text("20")),
                      DropdownMenuItem(value: 30, child: Text("30")),
                      DropdownMenuItem(value: 60, child: Text("60")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        timeStress = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: selectedTest,
                    items: [
                      DropdownMenuItem(value: 0, child: Text("matrix")),
                      DropdownMenuItem(value: 1, child: Text("vm")),
                      DropdownMenuItem(value: 2, child: Text("swap")),
                      DropdownMenuItem(value: 3, child: Text("hdd")),
                      DropdownMenuItem(value: 4, child: Text("netdev")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTest = value!;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if(_api != null){
                        await _api!.stressngPost(body: StressParam(duration: timeStress, type: selectedTest));
                      }
                    },
                    child: Text("Start Stress-ng"),
                  ),
                ],
              ),
              ),
            ),
            //CPU usage chart
            Text(
              "Cpu Usage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text(
                            "$label%",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          data
                              .mapIndexed(
                                (index, obj) =>
                                    FlSpot(index.toDouble(), obj.cpuUsage!),
                              )
                              .toList(),
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            //Mem usage chart
            Text(
              "Memory Usage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text(
                            "$label%",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),

                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          data
                              .mapIndexed(
                                (index, obj) => FlSpot(
                                  index.toDouble(),
                                  (obj.usedMem! / (obj.totalMem!)) * 100,
                                ),
                              )
                              .toList(),
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 600, child: Row(children: [Text("Total Memory: ${data.last.totalMem!}   Used Memory: ${data.last.usedMem!}   Free Memory: ${data.last.freeMem!}")],),),
            //Swap usage
            Text(
              "Swap Usage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text(
                            "$label%",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),

                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          data
                              .mapIndexed(
                                (index, obj) => FlSpot(
                                  index.toDouble(),
                                  obj.usedSwap! / obj.totalSwap! * 100,
                                ),
                              )
                              .toList(),
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 600, child: Row(children: [Text("Total Swap: ${data.last.totalSwap!}   Used Swap: ${data.last.usedSwap!}   Free Swap: ${data.last.freeSwap!}")],),),
            //Disk usage
            Text(
              "Disk Write",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: maxDiskW,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: (maxDiskW * 0.25),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text("$label", style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),

                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: diskW,
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            Text(
              "Disk Read",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: maxDiskR,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: (maxDiskR * 0.25),
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text("$label", style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),

                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: diskR,
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            //Network
            Text(
              "Network Receiving",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: maxrx,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: maxrx * 0.25,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text("$label", style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),

                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: rx,
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),

            Text(
              "Network Sending",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 1000,
              height: 250,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: maxtx,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: maxtx * 0.25,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = ((value)).toInt();
                          return Text("$label", style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int label = (30 - (value)).toInt();
                          return Text(
                            "${label}s",
                            style: TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),

                  //borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: tx,
                      isCurved: false,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
