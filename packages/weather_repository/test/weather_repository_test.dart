import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
  implements open_meteo_api.OpenMeteoApiClient {}
class MockLocation extends Mock implements open_meteo_api.Location {}
class MockWeather extends Mock implements open_meteo_api.Weather {}
void main() {
  group('WeatherRepository', () {
      late open_meteo_api.OpenMeteoApiClient weatherApiClient;
      late WeatherRepository weatherRepository;
      setUp(() {
        weatherApiClient = MockOpenMeteoApiClient();
        weatherRepository = WeatherRepository(weatherApiClient: weatherApiClient);
      });

  group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
          expect(WeatherRepository(), isNotNull);
      });
  });
  group('getWeather', () {
      const city = 'chicago';
      const latitude = 41.85003;
      const longitude = -87.65005;
      test('calls locationsearch with correnct city', () async {
         try {
           await weatherRepository.getWeather(city);
         } catch(_) {}
         verify( () => weatherApiClient.locationSearch(city)).called(1) ;
      });
      test('throws when locationSearch fails', () async {
          final exception = Exception('oops');
          when(() => weatherApiClient.locationSearch(any())).thenThrow(exception);
          expect(
            () async => weatherRepository.getWeather(city),
            throwsA(exception),
          );
      });
      test('calls getWeather with correct latitude/longitude', () async {
          final location = MockLocation();
          when(() => location.latitude).thenReturn(latitude);
          when(() => location.longitude).thenReturn(longitude);
          when(() => weatherApiClient.locationSearch(any())).thenAnswer((_) async => location);
          try {
            await weatherRepository.getWeather(city);
          } catch (_) {}
          verify(
            () => weatherApiClient.getWeather(latitude: latitude, longitude: longitude),
          ).called(1);
      });
      test ('throws when getWeather fails', () {
          final exception = Exception('oops');
          final location = MockLocation();
          when(() =>location.latitude).thenReturn(latitude);
          when(() => location.longitude).thenReturn(longitude);
          when(() => weatherApiClient.locationSearch(any())).thenAnswer((_) async => location);
          when(() => weatherApiClient.getWeather(latitude: latitude, longitude: longitude)).thenThrow(exception);
          expect(
            () async => weatherRepository.getWeather(city),
            throwsA(exception),
          );
      });
    });
  });
}
