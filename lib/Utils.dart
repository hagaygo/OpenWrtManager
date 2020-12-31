import 'dart:math';

class Utils
{
  static const String NoSpeedCalculationText = "-----";
  static const bool ReleaseMode = bool.fromEnvironment('dart.vm.product', defaultValue: false);

  static String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(' ');
  }

  static String formatBytes(int bytes, {int decimals = 0}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "Kb", "Mb", "Gb", "Tb", "Pb"];
    var i = (log(bytes) / log(1024)).floor();
    var number = (bytes / pow(1024, i));
    return (number).toStringAsFixed(number.truncateToDouble() == number ? 0 : decimals) +
        ' ' +
        suffixes[i];
  }
}