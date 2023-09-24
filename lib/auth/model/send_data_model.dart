class SendDataModel {
  final String sender;
  final String content;
  final String recivedSimNumber;
  final String simReceivedTimestamp;
  final String simName;

  SendDataModel({
    required this.sender,
    required this.content,
    required this.recivedSimNumber,
    required this.simReceivedTimestamp,
    required this.simName,
  });

  // Convert the model to a Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      "sender": sender,
      "content": content,
      "recivedSimNumber": recivedSimNumber,
      "simReceivedTimestamp": simReceivedTimestamp,
      "simName": simName,
    };
  }
}