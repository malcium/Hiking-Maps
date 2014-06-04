//
//  MPMNearestViewController.m
//  Hiking Maps
//
//  Created by Morgan McCoy on 5/29/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMNearestViewController.h"
#define NUMBER_OF_TRAILS 10
#define METRIC_CONVERSION 0.00062137

@interface MPMNearestViewController ()

@end

@implementation MPMNearestViewController{
    
    CLLocation *location;
    BOOL firstLocationUpdate;
    UIImage *img;
    
}

- (id)init
{
    self = [super init];
    
    if(!self) return nil;
    
    self.forest = [[NSString alloc] init];
    
    self.trails = [[NSArray alloc] init];
    img = [UIImage imageNamed:@"red-dot.png"];
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.forest;
    self.mapView.delegate = self;
    self.navigationController.toolbarHidden = NO;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:5.5];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    
    self.mapView.settings.myLocationButton = YES;
    self.mapView.mapType = kGMSTypeTerrain;
    [self.view addSubview:self.mapView];
    
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

- (NSMutableArray *)calculateNearest

{
    NSMutableArray *trailsCopy = [self.trails mutableCopy]; // a mutable copy of the forest's trail array
    [trailsCopy removeObjectAtIndex:0];                     // remove the first object which is essentially just a label
    NSMutableArray *locationsArray = [NSMutableArray new];  // instantiate two more arrays used to find the nearest trails
    NSMutableArray *nearestTrails = [NSMutableArray new];
    
    for(Trail *t in trailsCopy)   // for every trail, create a CLLocation object with the starting coordinates
    {
        CLLocation *l = [[CLLocation alloc]initWithLatitude:[t.startLatitude doubleValue] longitude:[t.startLongitude doubleValue]];
        [locationsArray addObject:l];  // and add them to a new array
    }
    for (int i = 0; i < NUMBER_OF_TRAILS;i++){  // loop to iterate through and select nearest trails
        
        CLLocation *nearestLoc = nil;              // variable to store the nearest location
        CLLocationDistance nearestDis = DBL_MAX;   // variable to store the nearest distance
        
        NSInteger index = 0;                       // variable to store an index for the nearest trail
        
        
        for (CLLocation *loc in locationsArray) { // for every location in the array, find the nearest to current location
            CLLocationDistance distance = [location distanceFromLocation:loc];
            
            if (nearestDis > distance) {
                nearestLoc = loc;           // and save the details of the trail object
                nearestDis = distance;
                index = [locationsArray indexOfObject:loc];
            }
        }
        [locationsArray removeObjectAtIndex:index];  // then remove that object from the location array
        
        [nearestTrails addObject:[trailsCopy objectAtIndex:index]];  // and add the trail with the same index to the returned array
        
        [trailsCopy removeObjectAtIndex:index];  // and remove the trail from the array, so the indexes remain the same between the two
    }
    return nearestTrails;
}

// method to observe the value of myLocation
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // If the first location update has not yet been recieved, then jump to that
    if(!firstLocationUpdate){
        firstLocationUpdate = YES;
        location = [change objectForKey:NSKeyValueChangeNewKey];
        [self drawTrails];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                             zoom:5.5];
    }    
}

// remove observer for location services updates
- (void)dealloc
{
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
    
}

- (void)drawTrails
{
    NSArray *nearestTrails = [self calculateNearest];
    
    for (Trail *t in nearestTrails) {
        double lat = [t.startLatitude doubleValue];
        double lon = [t.startLongitude doubleValue];
        
        CLLocation * loca = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
        CLLocationCoordinate2D coordi = loca.coordinate;
        
        GMSMarker *marker = [GMSMarker markerWithPosition:coordi];
        marker.icon = img;
        marker.flat = NO;
        marker.title = t.name;
        float miles = [t.length floatValue] * METRIC_CONVERSION;
        marker.snippet = [NSString stringWithFormat:@"Length: %.2f Miles", miles];
        
        marker.map = self.mapView;
        
        GMSMutablePath *path = [GMSMutablePath path];
        for(id array in t.coordinates)
        {
            double latitude = [array[1] doubleValue] ;
            double longitude = [array[0] doubleValue];
            [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
        }
        
        GMSPolyline *trailPath = [GMSPolyline polylineWithPath:path];
        trailPath.map = self.mapView;
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
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
