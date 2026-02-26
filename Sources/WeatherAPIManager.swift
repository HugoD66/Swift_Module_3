import Foundation

final class WeatherAPIManager {
    static let shared: WeatherAPIManager = WeatherAPIManager()
    private init() {}

    func run() async {
        print("=== Agrégateur de données météo ===\n")

        let cities = [
            City(name: "Paris", latitude: 48.8566, longitude: 2.3522),
            City(name: "London", latitude: 51.5074, longitude: -0.1278),
            City(name: "Tokyo", latitude: 35.6762, longitude: 139.6503),
            City(name: "New York", latitude: 40.7128, longitude: -74.0060),
            City(name: "Sydney", latitude: -33.8688, longitude: 151.2093),
            City(name: "Berlin", latitude: 52.5200, longitude: 13.4050),
            City(name: "Moscow", latitude: 55.7558, longitude: 37.6173),
            City(name: "Dubai", latitude: 25.2048, longitude: 55.2708),
            City(name: "São Paulo", latitude: -23.5505, longitude: -46.6333),
            City(name: "Mumbai", latitude: 19.0760, longitude: 72.8777)
        ]

        print("Récupération des données météo pour \(cities.count) villes...\n")

        let cache = WeatherCache()
        let startDate = Date()

        let results = await fetchMultipleCities(cities, cache: cache)

        for (city, result) in results {
            switch result {
            case .success(let weather):
                let temperature = String(format: "%.1f", weather.temperature)
                let windspeed = String(format: "%.1f", weather.windspeed)
                print("✓ \(city.name) : \(temperature)°C | Vent : \(windspeed) km/h")
            case .failure(let error):
                print("✗ \(city.name) : erreur -> \(error)")
            }
        }

        let executionTime = Date().timeIntervalSince(startDate)

        let successful = results.compactMap { (city, result) -> (City, CurrentWeather)? in
            switch result {
            case .success(let weather):
                return (city, weather)
            case .failure:
                return nil
            }
        }

        let failedCount = results.count - successful.count

        print("\n=== Statistiques ===")
        print("Villes totales : \(results.count)")
        print("Succès : \(successful.count)")
        print("Échecs : \(failedCount)")

        if !successful.isEmpty {
            let temperatures = successful.map { $0.1.temperature }
            let average = temperatures.reduce(0.0, +) / Double(temperatures.count)
            let minTemp = temperatures.min() ?? 0.0
            let maxTemp = temperatures.max() ?? 0.0

            print("Température moyenne : \(String(format: "%.1f", average))°C")

            if let warmest = successful.max(by: { $0.1.temperature < $1.1.temperature }) {
                print("Plus chaud : \(warmest.0.name) (\(String(format: "%.1f", warmest.1.temperature))°C)")
            }

            if let coldest = successful.min(by: { $0.1.temperature < $1.1.temperature }) {
                print("Plus froid : \(coldest.0.name) (\(String(format: "%.1f", coldest.1.temperature))°C)")
            }

            print("Min : \(String(format: "%.1f", minTemp))°C")
            print("Max : \(String(format: "%.1f", maxTemp))°C")
        }

        let stats = await cache.getStats()
        let hitRate: Double = stats.total > 0 ? (Double(stats.hits) / Double(stats.total)) : 0.0

        print("\n=== Cache ===")
        print("Hits : \(stats.hits)")
        print("Misses : \(stats.misses)")
        print("Taux de hit : \(String(format: "%.1f", hitRate * 100))%")

        print("\nTemps d'exécution : \(String(format: "%.2f", executionTime))s")
    }
}
