import 'package:chat_bot/models/message_chat.dart';
import 'package:get/state_manager.dart';

class ChatBotController extends GetxController {
  final RxBool _isLoading = true.obs;
  List<ChatMessage> messages = [];

  RxBool checkLoading() => _isLoading;

  @override
  void onInit() {
    if (_isLoading.isTrue) {
    } else {}
    super.onInit();
  }

  // calling our weather api
  // return FetchWeatherAPI()
  //     .processData(value.latitude, value.longitude)
  //     .then((Tuple2<WeatherData?, WeatherDataV2?> result) {
  //   weatherData.value = result.item1 as WeatherData;
  //   weatherDataV2.value = result.item2 as WeatherDataV2;
  //   _isLoading.value = false;
}
