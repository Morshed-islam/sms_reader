class Utils{

  static String getOperator(String phoneNumber) {
    if (phoneNumber.startsWith("+88016")) {
      return "Airtel";
    } else if (phoneNumber.startsWith("+88018")) {
      return "Robi";
    } else if (phoneNumber.startsWith("+88017")) {
      return "Grameenphone (GP)";
    } else if (phoneNumber.startsWith("+88014")) {
      return "Grameenphone (GP)";
    }else if (phoneNumber.startsWith("+88013")) {
      return "Grameenphone (Skitto)";
    }else if (phoneNumber.startsWith("+88019")) {
      return "Banglalink";
    }else if (phoneNumber.startsWith("+88015")) {
      return "Teletalk";
    }else {
      return "Unknown operator";
    }
  }

}