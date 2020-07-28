### This project is part of a larger contact monitoring solution
- [Ingestion API](https://github.com/MappedIn/contact-monitoring-ingest-api)
- [Dashboard](https://github.com/MappedIn/contact-monitoring-dashboard)
- [iOS SDK (this project)](https://github.com/MappedIn/contact-monitoring-ios-sdk)

# Contact Monitoring iOS SDK

## Requirements

1. iOS 13.0 or higher

2. Cocoapods

## Setup

Run `pod install` in the root directory

## Usage

| Note: The Office.gpx file under the Sample App provides coordinates that simulate movement in and out of the Mappedin Office. |
| --- |

``` 
    var positionManager = MiPositionManager(baseUrl: "http://localhost:8090", CMKey: "ExampleKey")
    
    override func viewDidLoad() {
        super.viewDidLoad()
	positionManager.delegate = self
	positionManager.setUserConsent(userConsent: true) 
        positionManager.startMonitoring()
	
	
	//position.stopMonitoring() to force the app to stop contact monitoring
	//position.getDevice() returns information about the users device such as id, type, hasUserConsent, isActivated
    } 
```


1. This SDK handles the position tracking of the user within a given venue. To use the SDK first create a position manager object as shown below

**MiPositionManager** <br><br>
*baseUrl*: The url to send the contact events to<br>
*CMKey*: Key used to activate the device, has limited uses
*keys*: An MVFCredentials struct containing MVFKey, MVFSecret. Alternatively, place these values in an info.plist
```		
	<key>MVFCredentials</key>
	<dict>
		<key>key</key>
		<string>ENTER MVF KEY HERE</string>
		<key>secret</key>
		<string>ENTER MVF SECRET HERE</string>
	</dict>
```
*updateInterval*: In seconds, the amount of time between sending the position updates to the server<br>

2. Pass a delegate into position manager for authorization updates and location status updates `positionManager.setDelegate(self)`

3. Ensure that the user consents to contact monitoring, this is done with `positionManager.setUserConsent(userConsent: true)` and only needs to be called once.

4. Additionally add the following to allow background location updates in your Info.plist

```
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string></string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string></string>
    	<key>UIBackgroundModes</key>
	<array>
		<string>location</string>
	</array>
```

For reference the settings in XCode are displayed below:

![Info.plist reference image](/images/info.png "Info.plist reference image")

## Demo Venue

To instantly test this out, you can set the following values for MVFCredentials in Info.plist:

```
key: 5f1f39d491b055001a68e9c6
secret: SVeYClqkEl5JblYH5cafNvkyxGTGMuHjjJGorl2j4Vn4VksA
```
Set up a venue on the [Contact Monitoring Ingest API](https://github.com/MappedIn/contact-monitoring-ingest-api/blob/master/docs/ProvisioningDevices.md) named "mappedin-demo-contact-monitoring", you should receive a response that looks like this:

```
{
    "code": "9DGDKI2T",
    "maxUses": 100,
    "venue": "mappedin-demo-contact-monitoring"
}
```

Use this code in the initializer of MiPositionManager for the CMKey parameter as seen below, replacing the baseUrl with your server url.

`var positionManager = MiPositionManager(baseUrl: "http://localhost:8090", CMKey: "9DGDKI2T")`

Next enable Location Simulation by editing the Sample App schema and toggling on Location Simulation with the Office.gpx file.

![Location Simulation reference image](/images/location.png "Location Simulation reference image")

This will display our office located in Waterloo, Ontario. You should see something that looks like the following image on your device:

![Contact Monitoring Sample App](/images/outside.png "Contact Monitoring Sample App")
