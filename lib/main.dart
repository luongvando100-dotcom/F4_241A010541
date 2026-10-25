import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F4 Danh bạ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0468D7)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ContactListPage(),
      routes: {AboutPage.routeName: (context) => const AboutPage()},
    );
  }
}

class Contact {
  final int id;
  final String hoTen;
  final String dienThoai;
  final String email;

  const Contact({
    required this.id,
    required this.hoTen,
    required this.dienThoai,
    this.email = '',
  });

  Contact copyWith({String? hoTen, String? dienThoai, String? email}) {
    return Contact(
      id: id,
      hoTen: hoTen ?? this.hoTen,
      dienThoai: dienThoai ?? this.dienThoai,
      email: email ?? this.email,
    );
  }
}

enum DetailAction { updated, deleted }

class DetailResult {
  final DetailAction action;
  final Contact? contact;

  const DetailResult(this.action, [this.contact]);
}

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final List<Contact> _danhBa = [
    const Contact(
      id: 1,
      hoTen: 'Nguyễn Văn A',
      dienThoai: '0901234567',
      email: 'a@vhu.edu.vn',
    ),
    const Contact(
      id: 2,
      hoTen: 'Trần Thị B',
      dienThoai: '0912345678',
      email: 'b@vhu.edu.vn',
    ),
    const Contact(id: 3, hoTen: 'Lê Văn C', dienThoai: '0987654321'),
  ];
  Future<void> _moChiTiet(Contact contact) async {
    final result = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute<DetailResult>(
        builder: (context) => ContactDetailPage(contact: contact),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      final index = _danhBa.indexWhere((item) => item.id == contact.id);
      if (index == -1) return;
      if (result.action == DetailAction.deleted) {
        _danhBa.removeAt(index);
      } else if (result.contact != null) {
        _danhBa[index] = result.contact!;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.action == DetailAction.deleted
              ? 'Đã xóa liên hệ'
              : 'Đã cập nhật',
        ),
      ),
    );
  }

  Future<void> _themMoi() async {
    final contact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute<Contact>(builder: (context) => const ContactEditPage()),
    );
    if (contact == null || !mounted) return;
    setState(() => _danhBa.add(contact.copyWith()));
  }

  Future<void> _timKiem() async {
    final contact = await Navigator.push<Contact>(
      context,
      MaterialPageRoute<Contact>(
        builder: (context) => ContactSearchPage(contacts: List.of(_danhBa)),
      ),
    );
    if (contact == null || !mounted) return;
    await _moChiTiet(contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ mini'),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
            icon: const Icon(Icons.search),
            onPressed: _timKiem,
          ),
          IconButton(
            tooltip: 'Giới thiệu',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, AboutPage.routeName),
          ),
        ],
      ),
      body: _danhBa.isEmpty
          ? const Center(child: Text('Danh bạ trống'))
          : ListView.separated(
              itemCount: _danhBa.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contact = _danhBa[index];
                return ListTile(
                  leading: Hero(
                    tag: 'contact-${contact.id}',
                    child: _ContactAvatar(contact: contact),
                  ),
                  title: Text(contact.hoTen),
                  subtitle: Text(contact.dienThoai),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _moChiTiet(contact),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm liên hệ',
        onPressed: _themMoi,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.hoTen)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Hero(
                tag: 'contact-${contact.id}',
                child: _ContactAvatar(contact: contact, radius: 48),
              ),
            ),
            const SizedBox(height: 20),
            _ContactRow(
              icon: Icons.person_outline,
              label: 'Họ và tên',
              value: contact.hoTen,
            ),
            _ContactRow(
              icon: Icons.phone_outlined,
              label: 'Điện thoại',
              value: contact.dienThoai,
            ),
            _ContactRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: contact.email.isEmpty ? '(chưa có)' : contact.email,
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Sửa liên hệ'),
              onPressed: () async {
                final updated = await Navigator.push<Contact>(
                  context,
                  MaterialPageRoute<Contact>(
                    builder: (context) => ContactEditPage(banDau: contact),
                  ),
                );
                if (updated == null || !context.mounted) return;
                Navigator.pop(
                  context,
                  DetailResult(DetailAction.updated, updated),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xóa liên hệ'),
              onPressed: () => Navigator.pop(
                context,
                const DetailResult(DetailAction.deleted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactEditPage extends StatefulWidget {
  final Contact? banDau;

  const ContactEditPage({super.key, this.banDau});

  @override
  State<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ten;
  late final TextEditingController _sdt;
  late final TextEditingController _email;
  bool _daSua = false;

  @override
  void initState() {
    super.initState();
    _ten = TextEditingController(text: widget.banDau?.hoTen ?? '');
    _sdt = TextEditingController(text: widget.banDau?.dienThoai ?? '');
    _email = TextEditingController(text: widget.banDau?.email ?? '');
    _ten.addListener(_capNhatTrangThaiThayDoi);
    _sdt.addListener(_capNhatTrangThaiThayDoi);
    _email.addListener(_capNhatTrangThaiThayDoi);
  }

  void _capNhatTrangThaiThayDoi() {
    final original = widget.banDau;
    final hasChanges = original == null
        ? _ten.text.isNotEmpty || _sdt.text.isNotEmpty || _email.text.isNotEmpty
        : _ten.text != original.hoTen ||
              _sdt.text != original.dienThoai ||
              _email.text != original.email;
    if (_daSua != hasChanges) setState(() => _daSua = hasChanges);
  }

  @override
  void dispose() {
    _ten.removeListener(_capNhatTrangThaiThayDoi);
    _sdt.removeListener(_capNhatTrangThaiThayDoi);
    _email.removeListener(_capNhatTrangThaiThayDoi);
    _ten.dispose();
    _sdt.dispose();
    _email.dispose();
    super.dispose();
  }

  void _luu() {
    if (!_formKey.currentState!.validate()) return;
    final original = widget.banDau;
    Navigator.pop(
      context,
      Contact(
        id: original?.id ?? DateTime.now().microsecondsSinceEpoch,
        hoTen: _ten.text.trim(),
        dienThoai: _sdt.text.trim(),
        email: _email.text.trim(),
      ),
    );
  }

  Future<void> _xacNhanThoat() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bỏ thay đổi?'),
        content: const Text('Dữ liệu bạn vừa nhập sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Contact>(
      canPop: !_daSua,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _daSua) _xacNhanThoat();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.banDau == null ? 'Thêm liên hệ' : 'Sửa liên hệ'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _ten,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sdt,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  prefixIcon: Icon(Icons.phone_outlined),
                  helperText: 'Nhập từ 9 đến 11 chữ số',
                ),
                validator: (value) {
                  final phone = value?.trim() ?? '';
                  if (!RegExp(r'^\d{9,11}$').hasMatch(phone)) {
                    return 'Số điện thoại phải có từ 9 đến 11 chữ số';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email (không bắt buộc)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isNotEmpty &&
                      !RegExp(
                        r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$',
                      ).hasMatch(email)) {
                    return 'Email không đúng định dạng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _luu,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactSearchPage extends StatefulWidget {
  final List<Contact> contacts;

  const ContactSearchPage({super.key, required this.contacts});

  @override
  State<ContactSearchPage> createState() => _ContactSearchPageState();
}

class _ContactSearchPageState extends State<ContactSearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final matches = widget.contacts.where((contact) {
      return contact.hoTen.toLowerCase().contains(query) ||
          contact.dienThoai.contains(query) ||
          contact.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm liên hệ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên, số điện thoại hoặc email',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? const Center(child: Text('Không tìm thấy liên hệ'))
                : ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final contact = matches[index];
                      return ListTile(
                        leading: _ContactAvatar(contact: contact),
                        title: Text(contact.hoTen),
                        subtitle: Text(contact.dienThoai),
                        onTap: () => Navigator.pop(context, contact),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Lab F4 – Điều hướng đa màn hình trong Flutter\n'
            'Danh bạ mini: Navigator, truyền dữ liệu, nhận kết quả, '
            'named route, PopScope, Search và Hero.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double radius;

  const _ContactAvatar({required this.contact, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final initials = contact.hoTen.trim().isEmpty
        ? '?'
        : contact.hoTen.trim().characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      child: Text(
        initials,
        style: TextStyle(fontSize: radius * 0.75, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
