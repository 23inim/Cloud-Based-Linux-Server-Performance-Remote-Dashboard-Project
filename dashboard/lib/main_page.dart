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
  var cpuThreshold = 100.0;
  var memThreshold = 100.0;
  var swapThreshold = 100.0;
  var cpuAlarm = false;
  var memAlarm = false;
  var swapAlarm = false;

  V1? _api;
  List<Status> data = [
    Status(
      totalMem: 1,
      usedMem: 1,
      freeMem: 1,
      totalSwap: 1,
      usedSwap: 1,
      freeSwap: 1,
      cpuUsage: 0,
      diskW: 0,
      diskR: 0,
      rxBytes: 0,
      txBytes: 0,
    ),
  ];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _api = V1.create(baseUrl: Uri.parse('http://35.224.235.45:5000'));
    timer = Timer.periodic(Duration(milliseconds: 100), (t) async {
      await updateData();
    });
  }

  Future updateData() async {
    if (_api == null) {
      return;
    }

    try{
      var result = await _api!.stressngGetHistoryGet();

      if (result.isSuccessful && mounted) {
        data = result.body!;
        cpuAlarm = false;
        memAlarm = false;
        swapAlarm = false;
        for (var value in data) {
          if (cpuThreshold <= (value.cpuUsage ?? 0)) {
            cpuAlarm = true;
          }
          if (memThreshold <=
              (value.usedMem ?? 0) / (value.totalMem ?? 1) * 100.0) {
            memAlarm = true;
          }
          if (swapThreshold <=
              (value.usedSwap ?? 0) / (value.totalSwap ?? 1) * 100.0) {
            swapAlarm = true;
          }
        }

        setState(() {});
      }
    } catch (e) {
      return;
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

    double maxDiskR = 0.1;
    double maxDiskW = 0.1;

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

    var totalSwap = (data.first.totalSwap ?? 1);
    if(totalSwap == 0){
      totalSwap = 1;
    }

    return Center(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 500,
              child: Row(
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
                      if (_api != null) {
                        print("attempting to run stress-ng");
                        var result = await _api!.stressngPost(
                          body: StressParam(
                            duration: timeStress,
                            type: selectedTest,
                          ),
                        );
                        print(result);
                      }
                    },
                    child: Text("Start Stress-ng"),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 800, height: 20),

          SizedBox(
            width: 800,
            height: 200,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Set Thresholds for Alerts:",
                      style: (TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "(alerts if usage surpassed the threshold in last 30s)",
                      style: (TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text("CPU Threshold (%used): "),
                    ),
                    Slider(
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      value: cpuThreshold,
                      onChanged: (value) {
                        setState(() {
                          cpuThreshold = value;
                        });
                      },
                    ),
                    Text("${cpuThreshold.toStringAsFixed(1)} %   "),
                    if (cpuAlarm)
                      Text(
                        "High CPU Usage!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text("Mem Threshold (%used): "),
                    ),
                    Slider(
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      value: memThreshold,
                      onChanged: (value) {
                        setState(() {
                          memThreshold = value;
                        });
                      },
                    ),
                    Text("${memThreshold.toStringAsFixed(1)} %   "),
                    if (memAlarm)
                      Text(
                        "High Memory Usage!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text("Swap Threshold (%used): "),
                    ),
                    Slider(
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      value: swapThreshold,
                      onChanged: (value) {
                        setState(() {
                          swapThreshold = value;
                        });
                      },
                    ),
                    Text("${swapThreshold.toStringAsFixed(1)} %   "),
                    if (swapAlarm)
                      Text(
                        "High Swap Usage!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: 800, height: 20),

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
                                      (index, obj) => FlSpot(
                                        index.toDouble(),
                                        obj.cpuUsage!,
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
                  SizedBox(
                    width: 600,
                    child: Row(
                      children: [
                        Text(
                          "Total Memory: ${data.last.totalMem ?? 0} (MB)  Used Memory: ${data.last.usedMem ?? 0} (MB)  Free Memory: ${data.last.freeMem ?? 0} (MB)",
                        ),
                      ],
                    ),
                  ),
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
                                        obj.usedSwap! / totalSwap * 100,
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
                  SizedBox(
                    width: 600,
                    child: Row(
                      children: [
                        Text(
                          "Total Swap: ${data.last.totalSwap ?? 0} (MB)  Used Swap: ${data.last.usedSwap ?? 0} (MB)  Free Swap: ${data.last.freeSwap ?? 0} (MB)",
                        ),
                      ],
                    ),
                  ),
                  //Disk usage
                  Text(
                    "Disk Write (MB/s)",
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
                                return Text(
                                  "$label",
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
                    "Disk Read (MB/s)",
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
                                return Text(
                                  "$label",
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
                    "Network Receiving (Bytes)",
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
                                return Text(
                                  "$label",
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
                    "Network Sending (Bytes)",
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
                                return Text(
                                  "$label",
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
          ),
        ],
      ),
      /*Column( children: [

        SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                width: 800,
                height: 20
            ),
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

            SizedBox(
                width: 800,
                height: 20
            ),

            SizedBox(
              width: 800,
              height: 200,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Set Thresholds for Alerts:", style: (TextStyle(fontSize: 20)) ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("(alerts if usage surpassed the threshold in last 30s)", style: (TextStyle(fontSize: 14)) ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 200, child:
                      Text("CPU Threshold (%used): "),
                      ),
                      Slider(
                        min: 0.0,
                        max: 100.0,
                        divisions: 20,
                        value: cpuThreshold,
                        onChanged: (value) {
                          setState(() {
                            cpuThreshold = value;
                          });
                        },
                      ),
                      Text("${cpuThreshold.toStringAsFixed(1)} %   "),
                      if (cpuAlarm)
                        Text("High CPU Usage!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red,),)
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 200, child:
                      Text("Mem Threshold (%used): "),
                      ),
                      Slider(
                        min: 0.0,
                        max: 100.0,
                        divisions: 20,
                        value: memThreshold,
                        onChanged: (value) {
                          setState(() {
                            memThreshold = value;
                          });
                        },
                      ),
                      Text("${memThreshold.toStringAsFixed(1)} %   "),
                      if (memAlarm)
                        Text("High Memory Usage!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red,),)
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 200, child:
                      Text("Swap Threshold (%used): "),
                      ),
                      Slider(
                        min: 0.0,
                        max: 100.0,
                        divisions: 20,
                        value: swapThreshold,
                        onChanged: (value) {
                          setState(() {
                            swapThreshold = value;
                          });
                        },
                      ),
                      Text("${swapThreshold.toStringAsFixed(1)} %   "),
                      if (swapAlarm)
                        Text("High Swap Usage!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red,),)
                    ],
                  ),

                ],
              ),
            ),

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
            SizedBox(width: 600, child: Row(children: [Text("Total Memory: ${data.last.totalMem ?? 0} (MB)  Used Memory: ${data.last.usedMem ?? 0} (MB)  Free Memory: ${data.last.freeMem ?? 0} (MB)")],),),
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
            SizedBox(width: 600, child: Row(children: [Text("Total Swap: ${data.last.totalSwap ?? 0} (MB)  Used Swap: ${data.last.usedSwap ?? 0} (MB)  Free Swap: ${data.last.freeSwap ?? 0} (MB)")],),),
            //Disk usage
            Text(
              "Disk Write (MB/s)",
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
              "Disk Read (MB/s)",
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
              "Network Receiving (Bytes)",
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
              "Network Sending (Bytes)",
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
      )
    ])*/
    );
  }
}
