//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "09be87d2bc45989e1d4e7b9e5cca4add"
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String : String]) {
        
        // use Alamofire to make a request to get the weather data
        // the url lets you use the open weather api
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            
            // once the response comes back, you try to use it
            if response.result.isSuccess {
            
                // print to console
                print ("Success! Got the weather data")
                
                // create a variable to save the result
                let weatherJSON : JSON = JSON(response.result.value!)
                
                // print the json
                print (weatherJSON)
                
                // call update weathe data to use the result
                self.updateWeatherData(json : weatherJSON)
                
            }
            else {
                print ("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        
        // store the temperature in a variable
        let tempResult = json["main"]["temp"].doubleValue
        
        // use your weatherDataModel object to store all the data

        // temp
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        // city
        weatherDataModel.city = json["name"].stringValue
        
        // condition - using this var to find the weather icon name in the next line
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        // icon name
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        // then udpate the UI using all this info
        updateUIWithWeatherData()
    }

    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
    
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)

    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get the location
        let location = locations[locations.count - 1]
        
        // if accuracy is bigger than zero
        if (location.horizontalAccuracy > 0) {
            
            // stop updating
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.latitude), latitude = \(location.coordinate.longitude)")
            
            // set the variables
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            // set the dict
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            // pass this over to get weather data
            getWeatherData(url: WEATHER_URL, parameters: params)            
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName (city : String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
}
