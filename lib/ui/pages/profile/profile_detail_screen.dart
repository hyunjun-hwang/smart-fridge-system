import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fridge_system/constants/app_colors.dart'; // ⭐️ AppColors import
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:smart_fridge_system/providers/user_provider.dart';
import 'package:uuid/uuid.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  // 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 상태 변수
  late List<bool> _genderSelection;
  bool _isLoading = false;
  String? _initialProfileImagePath;
  File? _imageFile;

  // ⭐️ [수정] 스타일 정의에서 AppColors 사용
  TextStyle get _headerStyle => const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary);
  TextStyle get _labelStyle => const TextStyle(color: AppColors.primary);
  InputBorder get _underlineBorder => const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary));
  InputBorder get _disabledBorder => UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300));
  // ⭐️ [삭제] 로컬 색상 변수는 더 이상 필요 없음
  // static const Color _textColor = Color(0xFF003508);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFieldsFromProvider();
    });
  }

  void _initializeFieldsFromProvider() {
    final userProvider = context.read<UserProvider>();
    _nameController.text = userProvider.name;
    _emailController.text = userProvider.email;
    _heightController.text = userProvider.height?.toString() ?? '';
    _weightController.text = userProvider.weight?.toString() ?? '';
    _dobController.text = userProvider.dob ?? '';
    _genderSelection = [userProvider.gender == '남성', userProvider.gender == '여성'];
    _initialProfileImagePath = userProvider.profileImagePath;
    setState(() {});
  }


  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);

    try {
      // ... (저장 로직은 이전과 동일)
      String? imagePathToSave;
      String? oldImagePath;
      if (_initialProfileImagePath != null && _initialProfileImagePath!.isNotEmpty && _imageFile != null) {
        oldImagePath = _initialProfileImagePath;
      }
      if (_imageFile != null) {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final fileName = const Uuid().v4();
        final fileExtension = path.extension(_imageFile!.path);
        final newPath = path.join(documentsDirectory.path, '$fileName$fileExtension');
        await File(_imageFile!.path).copy(newPath);
        imagePathToSave = newPath;
      } else {
        imagePathToSave = _initialProfileImagePath;
      }
      final dataToUpdate = {
        'id': _nameController.text,
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'dob': _dobController.text,
        'gender': _genderSelection[0] ? '남성' : '여성',
        'profileImagePath': imagePathToSave ?? '',
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(dataToUpdate);

      if (mounted) {
        context.read<UserProvider>().updateUser(
          newName: _nameController.text,
          newHeight: int.tryParse(_heightController.text),
          newWeight: int.tryParse(_weightController.text),
          newDob: _dobController.text,
          newGender: _genderSelection[0] ? '남성' : '여성',
          newImagePath: imagePathToSave,
        );
      }
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("프로필 저장 에러: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // ... (이미지 선택 로직은 이전과 동일)
    try {
      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('이미지 선택 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 가져오는데 실패했습니다.')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    // ... (이미지 선택 옵션 로직은 이전과 동일)
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('갤러리에서 선택'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          // ⭐️ [수정] DatePicker 테마에 AppColors 적용
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    bool showLoading = _isLoading || userProvider.isLoading;

    return Scaffold(
      // ⭐️ [수정] AppColors 적용
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text('프로필'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('저장하기', style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
      body: showLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImagePicker(),
            const SizedBox(height: 24),
            Text('내 정보', style: _headerStyle),
            const SizedBox(height: 16),
            _buildTextField(label: '이메일', controller: _emailController, enabled: false),
            _buildTextField(label: '사용자 이름', controller: _nameController, enabled: false),
            _buildTextField(
              label: '신장/키 (cm)',
              controller: _heightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextField(
              label: '체중(kg)',
              controller: _weightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildDatePickerField(),
            _buildGenderToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    ImageProvider<Object> profileImage;
    if (_imageFile != null) {
      profileImage = FileImage(_imageFile!);
    } else if (_initialProfileImagePath != null && _initialProfileImagePath!.isNotEmpty) {
      profileImage = FileImage(File(_initialProfileImagePath!));
    } else {
      profileImage = const AssetImage('assets/placeholder.png'); // 기본 이미지
    }

    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: profileImage,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          // ⭐️ [수정] AppColors 적용
          Text('프로필 사진 변경', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            // ⭐️ [수정] AppColors 적용
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              focusedBorder: _underlineBorder,
              disabledBorder: _disabledBorder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('생년월일', style: _labelStyle),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_month_outlined, color: Colors.grey.shade600),
              focusedBorder: _underlineBorder,
            ),
            onTap: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderToggle() {
    if (!mounted || !(_genderSelection.length == 2)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('성별', style: _labelStyle.copyWith(fontSize: 16)),
          ToggleButtons(
            isSelected: _genderSelection,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < _genderSelection.length; i++) {
                  _genderSelection[i] = i == index;
                }
              });
            },
            borderRadius: BorderRadius.circular(30.0),
            // ⭐️ [수정] AppColors 적용
            selectedColor: AppColors.white,
            color: AppColors.textSecondary,
            fillColor: AppColors.textSecondary,
            splashColor: AppColors.primary.withOpacity(0.12),
            constraints: const BoxConstraints(minHeight: 40.0, minWidth: 50.0),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('남성')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('여성')),
            ],
          ),
        ],
      ),
    );
  }
}