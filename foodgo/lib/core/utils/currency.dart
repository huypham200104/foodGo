String formatVnd(num value) {
  final s = value.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i - 1;
    buf.write(s[i]);
    if (posFromEnd > 0 && posFromEnd % 3 == 0) buf.write('.');
  }
  return '${buf.toString()} đ';
}


