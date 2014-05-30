//
//  MPMTopoViewController.m
//  HikingMaps
//
//  Created by Morgan McCoy on 3/10/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMTopoViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#define METRIC_CONVERSION 0.00062137

@interface MPMTopoViewController ()

@end

@implementation MPMTopoViewController{
    BOOL firstLocationUpdate_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a camera position centered on the starting lat/long of the Trail object passed
    double lat = [self.trail.startLatitude doubleValue];
    double lon = [self.trail.startLongitude doubleValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:10];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    
    self.mapView.settings.myLocationButton = YES;
    self.mapView.mapType = kGMSTypeTerrain;
    self.mapView.myLocationEnabled = YES;
    
    // Create the GMSMapView with the trail map camera position.
    
    [self.view addSubview:self.mapView];
    
    self.title = self.trail.name;
    
    CLLocation * loca = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    CLLocationCoordinate2D coordi = loca.coordinate;
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordi];
    marker.title = self.trail.name;
    float miles = [self.trail.length floatValue] * METRIC_CONVERSION;
    marker.snippet = [NSString stringWithFormat:@"Length: %.2f Miles", miles];
    
    marker.map = self.mapView;
    GMSMutablePath *path = [GMSMutablePath path];
    for(id array in self.trail.coordinates)
    {
        double latitude = [array[1] doubleValue] ;
        double longitude = [array[0] doubleValue];
        [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    }
    
    GMSPolyline *trailPath = [GMSPolyline polylineWithPath:path];
    trailPath.map = self.mapView;
    self.mapView.delegate = self;
    
    // add observer to listen for location services updates
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];
    
    // enable my location services after view has been added to the UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;  // reset the map frame upon device re-orientation
}

 // remove observer for location services updates
- (void)dealloc
{
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    //if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
       // firstLocationUpdate_ = YES;
       // CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
       // self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                       //  zoom:14];
   // }
}

// method to handle a long button press on the map to launch the google maps app with directions to the coordinate
// if google maps is not installed on the device, an alert will prompt the user to the app store to download it
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *latitude = [[NSNumber numberWithDouble:coordinate.latitude] stringValue];
    NSString *longitude = [[NSNumber numberWithDouble:coordinate.longitude] stringValue];
    NSString *googleURL = [NSString stringWithFormat:@"comgooglemaps-x-callback://?daddr=%@,%@&x-success=westminster://?resume=true&x-source=Hiking-Maps",latitude,longitude];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps-x-callback://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleURL]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Google Maps App is required to calculate directions to this coordinate" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"App Store..", nil];
        alert.delegate = self;
        [alert show];
    }
}

// method to handle the app store button on the alert window. Redirects to Google Maps app in the app store.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView firstOtherButtonIndex])
    {
        NSString *appStoreLink = @"https://itunes.apple.com/us/app/google-maps/id585027354?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
    }
}

@end
