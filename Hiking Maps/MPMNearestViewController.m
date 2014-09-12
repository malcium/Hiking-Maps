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

@property (nonatomic, strong) NSArray *styles;

@property (nonatomic, strong) NSArray *lengths;

@property (nonatomic, strong) NSMutableArray *distances;

@end

@implementation MPMNearestViewController{
    
    CLLocation *location;
    BOOL firstLocationUpdate;
    UIImage *img;
    
}

// custom init to set the properties and instance variables
- (id)init
{
    self = [super init];
    
    if(!self) return nil;
    
    self.forest = [[NSString alloc] init];
    
    self.trails = [[NSArray alloc] init];
    
    img = [UIImage imageNamed:@"red-dot.png"];
    
    self.styles = @[[GMSStrokeStyle solidColor:[UIColor yellowColor]],[GMSStrokeStyle solidColor:[UIColor blackColor]]];
    
    self.lengths = @[@750, @500];
    
    self.distances = [NSMutableArray new];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.forest;
    //self.navigationController.toolbarHidden = NO;
    
    
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
    self.mapView.delegate = self;
}

// set the navigation bar button when view will appear
- (void)viewWillAppear:(BOOL)animated
{
    [self setNavigationBarRightButton];
}


// reset the map frame upon device re-orientation
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;
}

// sets the right navigation button to a particular title and assignes a method to its action
-(void)setNavigationBarRightButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Satellite" style:UIBarButtonItemStyleDone target:self action:@selector(onClickrighttButton:)];
    self.navigationItem.rightBarButtonItem = button;
}

// handles button presses on the right navigation bar button to change the map type
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

// method to calculate the nearest trails to the user's location, repquires that myLocation is enabled and first KVO
// update has occured
- (NSMutableArray *)calculateNearest
{
    NSMutableArray *trailsCopy = [self.trails mutableCopy]; // a mutable copy of the forest's trail array
    NSMutableArray *locationsArray = [NSMutableArray new];  // instantiate two more arrays used to find the nearest trails
    NSMutableArray *nearestTrails = [NSMutableArray new];
    
    for(Trail *t in trailsCopy)   // for every trail, create a CLLocation object with the starting coordinates
    {
        CLLocation *l = [[CLLocation alloc]initWithLatitude:[t.startLatitude doubleValue] longitude:[t.startLongitude doubleValue]];
        [locationsArray addObject:l];  // and add them to a new array
    }
    int x = (int)[trailsCopy count];
    int y;
    
    // If the particular jurisdiction has less trails in it than NUMBER_OF_TRAILS, then adjust the number of iterations of the following
    // for loop.
    if (x > NUMBER_OF_TRAILS)
        y = 10;
    else
        y = x;
    
    for (int i = 0; i < y; i++){  // loop to iterate through and select nearest trails
        
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
        
        [self.distances addObject:[NSNumber numberWithDouble:nearestDis]];
        
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
        
        // call to method to draw the nearest trails after first KVO update has occurred
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

// method to draw the nearest trails on the map
- (void)drawTrails
{
    // first grab an array of the nearest trails from the calculateNearest method
    NSArray *nearestTrails = [self calculateNearest];
    
    int i = 0;
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
        marker.snippet = [NSString stringWithFormat:@"Jurisdiction: %@\nLength: %.2f Miles\nDistance from me: %.2f Miles", t.jurisdiction, miles, [self.distances[i] doubleValue] * METRIC_CONVERSION];
        
        marker.map = self.mapView;
        
        GMSMutablePath *path = [GMSMutablePath path];
        for(id array in t.coordinates)
        {
            double latitude = [array[1] doubleValue] ;
            double longitude = [array[0] doubleValue];
            [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
        }
        
        GMSPolyline *trailPath = [GMSPolyline polylineWithPath:path];
        trailPath.title = [t.name stringByAppendingFormat:@"|%@|%@",t.jurisdiction,self.distances[i]];
        trailPath.tappable = YES;
        trailPath.map = self.mapView;
        i++;
    }
}

// method to handle taps on a trail's polyline
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSPolyline *)overlay
{
    GMSPolyline *polyline = overlay;
    NSString *name = polyline.title;
    GMSPath *path = polyline.path;
    float miles = [path lengthOfKind:kGMSLengthRhumb] * METRIC_CONVERSION;
    CLLocationCoordinate2D coord = [path coordinateAtIndex:0];
    GMSMarker *marker = [GMSMarker markerWithPosition:coord];
    NSArray *array = [name componentsSeparatedByString:@"|"];
    marker.title = array[0];
    
    marker.snippet = [NSString stringWithFormat:@"Jurisdiction: %@\nLength: %.2f Miles\nDistance from me: %.2f Miles",array[1], miles,[array[2] doubleValue] * METRIC_CONVERSION];
    marker.map = self.mapView;
    polyline.spans = GMSStyleSpans(polyline.path, self.styles, self.lengths, kGMSLengthRhumb);
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
