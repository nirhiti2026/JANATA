class JanataUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'citizen' or 'politician'
  final String? bio;
  final String? education;
  final String? works;
  final String? phone;
  final String? gender;
  final String? province;

  JanataUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.bio,
    this.education,
    this.works,
    this.phone,
    this.gender,
    this.province,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role,
        'bio': bio,
        'education': education,
        'works': works,
        'phone': phone,
        'gender': gender,
        'province': province,
      };

  static JanataUser fromMap(Map<String, dynamic> map) => JanataUser(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'citizen',
        bio: map['bio'],
        education: map['education'],
        works: map['works'],
        phone: map['phone'],
        gender: map['gender'],
        province: map['province'],
      );
}
