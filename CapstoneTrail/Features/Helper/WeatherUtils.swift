//
// Created by Joohyung Ryu on 2017. 3. 15..
// Copyright (c) 2017 MSD. All rights reserved.
//

import Alamofire
import SwiftyJSON


class WeatherUtils {

    // Fetch weather data
    class func getWeather(coordinate: [Double], success: @escaping (JSON) -> ()) {

        // Find Weather API key
        let weatherAPIKey = getAPIKeys(keyName: "APIXU")
        // Weather URL for fetching forecast
        let weatherURL = "https://api.apixu.com/v1/forecast.json?key=\(weatherAPIKey)&q=\(coordinate[1]),\(coordinate[0])&days=10"

        // Fetch HTTP response
        Alamofire.request(weatherURL)
                 .validate()
                 .responseJSON(completionHandler: {
                     response in

                     switch response.result {
                         case .success:
                             // Assign response as JSON
                             let responseJSON = JSON(response.result.value!)
                             print("Weather fetch succeed")
                             success(responseJSON)
                             return
                         case .failure(let error):
                             print("Fetch failed: \(error)")
                     }
                 })
    }

    // Find forecast at the hour
    class func findForecast(scheduleEpoch: UInt32, weatherData: JSON) -> JSON {

        // Make a list pairwise
        func pairwise<T>(d: [T]) -> [(T, T)] {

            switch d.count {
                case 0: return []
                case 1: return []
                case let n:
                    let r = [(d[0], d[1])]
                    return r + pairwise(d: Array(d[1 ..< n]))
            }
        }

        // Make epoch time range
        func makeRange(_ epochList: [UInt32]) -> [CountableRange<Swift.UInt32>] {

            var ranges = [CountableRange<Swift.UInt32>]()

            for x in pairwise(d: epochList) {
                ranges.append(x.0 ..< x.1)
            }

            return ranges
        }

        // Find index number
        func findIndex(searchType: String, searchEpoch: UInt32, dateIndex: Int?) -> Int {

            var epochList = [UInt32]()
            var targetJSON: [JSON]
            var targetKey: String
            var targetAdjust: UInt32

            guard let indexType = SearchIndexType(rawValue: searchType) else { fatalError() }

            // Set variables
            switch indexType {
                case .Date:
                    targetJSON = weatherData["forecast"]["forecastday"].arrayValue
                    targetKey = "date_epoch"
                    targetAdjust = 864000
                case .Hour:
                    targetJSON = weatherData["forecast"]["forecastday"][dateIndex!]["hour"].arrayValue
                    targetKey = "time_epoch"
                    targetAdjust = 3600
            }

            // Create a list of epoch time
            for target in targetJSON {
                epochList.append(target[targetKey].uInt32Value)
            }
            epochList.append(epochList.last! + targetAdjust)

            // Range list
            let rangeList = makeRange(epochList)
            // Return index number
            for (index, range) in rangeList.enumerated() {
                if range.contains(searchEpoch) {
                    return index
                }
            }

            // Non-matching return value
            return -1
        }
        // End internal functions

        // Find indices
        let dateIndex = findIndex(searchType: "date", searchEpoch: scheduleEpoch, dateIndex: nil)
        let hourIndex = findIndex(searchType: "hour", searchEpoch: scheduleEpoch, dateIndex: dateIndex)

        // Return forecast data at the hour
        return weatherData["forecast"]["forecastday"][dateIndex]["hour"][hourIndex]
    }

    // Calculate weather index point
    class func calcWeatherIndex(hourWeather: JSON) -> Int {

        // Point based on weather condition
        func calcWeatherPoint() -> Double {

            // Weather code from APIXU
            let deduct_0: [Int] = [1000, 1003, 1006, 1009]
            let deduct_3: [Int] = [1030, 1135]
            let deduct_4: [Int] = [1063, 1066, 1069, 1150, 1153, 1180, 1183, 1204, 1210, 1213, 1240, 1249, 1225, 1261]
            let deduct_7: [Int] = [1072, 1186, 1189, 1216, 1219]

            let wetherCode: Int = hourWeather["condition"]["code"].intValue

            // Determine point
            if deduct_0.contains(wetherCode) {
                return 0
            } else if deduct_3.contains(wetherCode) {
                return 3
            } else if deduct_4.contains(wetherCode) {
                return 4
            } else if deduct_7.contains(wetherCode) {
                return 7
            } else {
                return 9
            }
        }

        // Point based on feels like temperature
        func calcTemperaturePoint() -> Double {

            // Temperature in farenheit
            let temperature_f: Double = hourWeather["feelslike_f"].doubleValue
            let reference_temperature_f: Double = 84
            let difference: Double = temperature_f - reference_temperature_f

            // Determine point
            if difference > 0 {
                return difference * 0.013
            } else if difference < 0 {
                // To return positive value
                return abs(difference * 0.035)
            } else {
                return 0
            }
        }

        // Point based on precipitation
        func calcPrecipitationPoint() -> Double {

            // Precipitation in mm
            let precipitation_mm: Double = hourWeather["precip_mm"].doubleValue

            // Determine point
            return precipitation_mm * 0.092
        }

        // Point based on wind strength
        func calcWindPoint() -> Double {

            // Wind strength in mile per hour
            let wind_mph = hourWeather["wind_mph"].doubleValue
            let reference_strength: Double = 18.2
            let difference: Double = wind_mph - reference_strength

            // Determine point
            if difference < 0 {
                return 0
            } else {
                return difference * 0.006
            }
        }
        // End internal functions

        // Index Point
        let maxPoint: Int = 10
        let deductPoint: Double = calcWeatherPoint() + calcTemperaturePoint() + calcPrecipitationPoint() + calcWindPoint()
        let weatherPoint: Int = maxPoint - Int(round(deductPoint))

        // Determine final index point
        if weatherPoint < 1 {
            return 1
        } else {
            return weatherPoint
        }
    }

    // Check the schedule is within 10 days
    class func isWithin10Days(scheduleEpoch: UInt32) -> Bool {

        let now: UInt32 = UInt32(Date().timeIntervalSince1970)
        let tenDaysLater = now + UInt32(24 * 60 * 60 * 10)

        if (now ..< tenDaysLater).contains(scheduleEpoch) {
            return true
        } else {
            return false
        }
    }
}


enum SearchIndexType: String {
    case Date = "date"
    case Hour = "hour"
}
