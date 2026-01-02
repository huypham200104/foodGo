class FormatHelper {
  static String formatCurrency(double amount) {
    String amountStr = amount.toStringAsFixed(0);
    String result = '';
    int count = 0;
    
    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = '${amountStr[i]}$result';
      count++;
    }
    
    return '$resultđ';
  }
}
