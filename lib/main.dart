import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psytest_web/divination_logic.dart'; // For date formatting

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '周易起卦', // Changed title
      theme: ThemeData(
        // Define a custom color scheme for a "New Chinese Style" aesthetic
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(
            0xFF6A0505, // A deep, rich red, often associated with traditional Chinese aesthetics
            <int, Color>{
              50: Color(0xFFFFF5F5),
              100: Color(0xFFFEDCDC),
              200: Color(0xFFFDBABA),
              300: Color(0xFFFC9696),
              400: Color(0xFFFB7D7D),
              500: Color(0xFF6A0505), // Primary red
              600: Color(0xFF610404),
              700: Color(0xFF560303),
              800: Color(0xFF4C0202),
              900: Color(0xFF3B0101),
            },
          ),
        ).copyWith(
          secondary: Color(0xFFD4AF37), // A golden yellow, symbolizing prosperity and royalty
          surface: Color(0xFFF5F5DC), // A light beige/cream, like traditional paper or silk
          error: Color(0xFFB00020),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,

          onError: Colors.white,
        ),
        useMaterial3: true,
        // Optionally, define a custom text theme with a font that evokes Chinese calligraphy
        // You would need to import a custom font for this (e.g., via Google Fonts)
        // textTheme: GoogleFonts.notoSerifSCTextTheme(Theme.of(context).textTheme),
      ),
      home: const DivinationPage(title: '周易自动起卦'), // Changed home widget
    );
  }
}

class DivinationPage extends StatefulWidget {
  const DivinationPage({super.key, required this.title});

  final String title;

  @override
  State<DivinationPage> createState() => _DivinationPageState();
}

class _DivinationPageState extends State<DivinationPage> {
  DateTime? _selectedDate; // For birth date
  String? _selectedGender; // For gender
  String _currentTime = ''; // For current time
  String _divinationResult = '解卦结果将显示在此处'; // For divination result

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    // Update time every second
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   _updateCurrentTime();
    // });
  }

  void _updateCurrentTime() {
    setState(() {
      _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _performDivination() {
    if (_selectedDate == null || _selectedGender == null) {
      setState(() {
        _divinationResult = '请选择出生日期和性别！';
      });
      return;
    }

    setState(() {
      _divinationResult = '正在为您起卦...';
    });

    // 每次点击都使用新的随机种子
    DateTime now = DateTime.now();
    
    // 调用起卦逻辑
    String hexagramInfo = generateHexagram(
      birthDate: _selectedDate!,
      gender: _selectedGender!,
      currentTime: now,

    );

    // 从返回的字符串中解析卦名和动爻
    // 假设格式为 "卦名：[卦名]\n...动爻：第 [数字] 爻..."
    String hexagramName = '未知卦';
    int changingYao = 0;

    // interpretHexagram 函数现在直接使用 generateHexagram 的完整输出
    // 或者，如果 interpretHexagram 仍然需要卦名和动爻，则需要从 hexagramInfo 中提取
    // 由于 generateHexagram 已经返回了完整的解卦信息，这里直接使用 hexagramInfo
    // 如果 interpretHexagram 仍然需要单独的卦名和动爻，请确保上面的解析逻辑正确
    // 这里我们假设 interpretHexagram 接受完整的 hexagramInfo 字符串
    // 如果 interpretHexagram 仍然需要卦名和动爻，那么需要根据实际情况调整
    // 为了保持逻辑一致性，我们假设 interpretHexagram 仍然需要卦名和动爻
    RegExp nameRegExp = RegExp(r'卦名：([^\n]+)');
    Match? nameMatch = nameRegExp.firstMatch(hexagramInfo);
    if (nameMatch != null) {
      hexagramName = nameMatch.group(1)!;
    }

    RegExp yaoRegExp = RegExp(r'动爻：第 (\d+) 爻');
    Match? yaoMatch = yaoRegExp.firstMatch(hexagramInfo);
    if (yaoMatch != null) {
      changingYao = int.parse(yaoMatch.group(1)!);
    }

    String interpretation = interpretHexagram(hexagramName, changingYao);

    setState(() {
      _divinationResult = interpretation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color from theme
         elevation: 0, // Remove shadow
         title: Text(widget.title, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)), // Use onPrimary color for text
         centerTitle: true,
       ),
       body: Container(
         decoration: BoxDecoration(
           color: Theme.of(context).colorScheme.surface, // Use surface color from theme
         ),
         child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Birth Date Input
            ListTile(
              title: Text(
                _selectedDate == null
                    ? '选择出生日期'
                    : '出生日期: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Adjusted text color
              ),
              trailing: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface), // Adjusted icon color
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),

            // Gender Selection
            const Text('选择性别:', style: TextStyle(fontSize: 16, color: Colors.white70)), // Lighter text color
            Row(
              children: <Widget>[
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('男', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), // Adjusted text color
                    value: 'male',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('女', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)), // Adjusted text color
                    value: 'female',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current Time Display
            Text(
              '当前时间: $_currentTime',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface), // Adjusted text color
            ),
            const SizedBox(height: 30),

            // Divination Button
            Center(
              child: ElevatedButton(
                onPressed: _performDivination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color for button background
                  foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use onPrimary color for button text
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Slightly rounded corners for a more traditional feel
                  ),
                  elevation: 4, // Add some elevation for depth
                ),
                child: const Text('自动起卦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Larger and bolder text
              ),
            ),
            const SizedBox(height: 30),

            // Divination Result Display
            Expanded(
              child: Card(
                elevation: 8, // Increased elevation for more shadow
                color: Theme.of(context).colorScheme.surface, // Use surface color for card background
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners for card
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _divinationResult,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16), // Use onSurface color for text
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
