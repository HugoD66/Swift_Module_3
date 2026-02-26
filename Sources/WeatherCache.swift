import Foundation

actor WeatherCache {

    private var cache: [String: CurrentWeather] = [:]
    private var hits = 0
    private var misses = 0

    func get(_ cityName: String) -> CurrentWeather? {

        if let weather = cache[cityName] {
            hits += 1
            return weather
        }

        misses += 1
        return nil
    }

    func set(_ weather: CurrentWeather, for cityName: String) {
        cache[cityName] = weather
    }

    func getStats() -> (hits: Int, misses: Int, total: Int) {

        let total = hits + misses
        return (hits, misses, total)
    }
}