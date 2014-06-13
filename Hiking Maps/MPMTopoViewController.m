//
//  MPMTopoViewController.m
//  HikingMaps
//
//  Created by Morgan McCoy on 2/28/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMTopoViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#define METRIC_CONVERSION 0.00062137

@interface MPMTopoViewController ()

@end

@implementation MPMTopoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a camera position centered on the starting lat/long of the Trail object passed
    double lat = [self.trail.startLatitude doubleValue];
    double lon = [self.trail.startLongitude doubleValue];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:10];
    // Create the GMSMapView with the trail map camera position.
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.settings.myLocationButton = YES;
    self.mapView.mapType = kGMSTypeTerrain;
    self.mapView.myLocationEnabled = YES;
    
    [self.view addSubview:self.mapView];
    
    self.title = self.trail.name;
    
    // grab the starting coordinate from self.trail
    CLLocation * loca = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    CLLocationCoordinate2D coordi = loca.coordinate;
    
    // make a marker out of that coordinate, format it's popover window with the trail details
    // and place the marker on the map
    GMSMarker *marker = [GMSMarker markerWithPosition:coordi];
    marker.title = self.trail.name;
    float miles = [self.trail.length floatValue] * METRIC_CONVERSION;
    marker.snippet = [NSString stringWithFormat:@"Jurisdiction: %@\nLength: %.2f Miles", self.trail.jurisdiction, miles];
    marker.map = self.mapView;
    
    // make a polyline out of self.trail's coordinates array, and place it on the map
    GMSMutablePath *path = [GMSMutablePath path];
    for(id array in self.trail.coordinates)
    {
        double latitude = [array[1] doubleValue] ;
        double longitude = [array[0] doubleValue];
        [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
    }
    
    GMSPolyline *trailPath = [GMSPolyline polylineWithPath:path];
    trailPath.map = self.mapView;
    
    // set the mapView's delegate to self (this)
    self.mapView.delegate = self;
}

// sets the right button on the navigation controller
- (void)viewWillAppear:(BOOL)animated{
    [self setNavigationBarRightButton];
}

// Used to layout the map according to view.bounds
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;  // reset the map frame upon device re-orientation
}

// Method to set the title and action of the button on the upper right-hand side of the navigation bar
-(void)setNavigationBarRightButton
{
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Satellite" style:UIBarButtonItemStyleDone target:self action:@selector(onClickrighttButton:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}

// method to handle map type switching on button push in nav bar
- (void)onClickrighttButton:(id)sender
{
    if (self.mapView.mapType == kGMSTypeTerrain)
    {
        self.mapView.mapType = kGMSTypeSatellite;
        self.navigationItem.rightBarButtonItem.title = @"Normal";
    }
    else if (self.mapView.mapType == kGMSTypeSatellite)
    {
        self.mapView.mapType = kGMSTypeNormal;
        self.navigationItem.rightBarButtonItem.title = @"Hybrid";
    }
    else if (self.mapView.mapType == kGMSTypeNormal)
    {
        self.mapView.mapType = kGMSTypeHybrid;
        self.navigationItem.rightBarButtonItem.title = @"Terrain";
    }
    else if (self.mapView.mapType == kGMSTypeHybrid)
    {
        self.mapView.mapType = kGMSTypeTerrain;
        self.navigationItem.rightBarButtonItem.title = @"Satellite";
    }
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
