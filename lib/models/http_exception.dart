class HttpException implements Exception{
  String message;

  HttpException(this.message);

  @override
  String toString() {
    // return super.toString();
    return message;
  }
}