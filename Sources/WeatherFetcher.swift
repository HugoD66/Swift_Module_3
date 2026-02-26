import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// HELPER: Wrapper cross-platform pour URLSession (fourni)
// Cette fonction fonctionne sur macOS, Linux et Windows
@available(macOS 10.15, *)
func fetchData(from url: URL) async throws -> (Data, URLResponse) {
#if os(macOS)
    if #available(macOS 12.0, *) {
        return try await URLSession.shared.data(from: url)
    }
#endif
    
    return try await withCheckedThrowingContinuation { continuation in
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            guard let data = data, let response = response else {
                continuation.resume(throwing: URLError(.badServerResponse))
                return
            }
            continuation.resume(returning: (data, response))
        }
        task.resume()
    }
}

// 4. FETCH FUNCTIONS (8 pts)

// TODO 4.1: Fonction buildWeatherURL(latitude:longitude:) -> URL? (1 pt)
// URL: https://api.open-meteo.com/v1/forecast?latitude=XX&longitude=YY&current_weather=true



func buildWeatherURL(latitude: Double, longitude: Double) -> URL? {
    let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
    return URL(string: urlString)
}



func fetchWeather(for city: City) async throws -> CurrentWeather {
    guard let url = buildWeatherURL(latitude: city.latitude, longitude: city.longitude) else {
        throw WeatherError.invalidURL
    }

    do {
        let result = try await fetchData(from: url)
        let data = result.0
        let response = result.1

        guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
            throw WeatherError.networkError("Réponse HTTP invalide")
        }

        if httpResponse.statusCode < 200 || httpResponse.statusCode > 299 {
            throw WeatherError.networkError("Code HTTP \(httpResponse.statusCode)")
        }

        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return weatherResponse.currentWeather
        } catch {
            throw WeatherError.decodingError("Décodage JSON impossible: \(error.localizedDescription)")
        }
    } catch let weatherError as WeatherError {
        throw weatherError
    } catch {
        throw WeatherError.networkError("Erreur réseau: \(error.localizedDescription)")
    }
}

func fetchMultipleCities(_ cities: [City], cache: WeatherCache) async -> [(City, Result<CurrentWeather, Error>)] {
    await withTaskGroup(of: (City, Result<CurrentWeather, Error>).self) { group in

        for city in cities {
            group.addTask {

                if let cachedWeather = await cache.get(city.name) {
                    return (city, .success(cachedWeather))
                }

                do {
                    let weather = try await fetchWeather(for: city)
                    await cache.set(weather, for: city.name)
                    return (city, .success(weather))
                } catch {
                    return (city, .failure(error))
                }
            }
        }

        var allResults: [(City, Result<CurrentWeather, Error>)] = []

        for await item in group {
            allResults.append(item)
        }

        return allResults
    }
}