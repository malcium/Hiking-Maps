//
//  MPMHomeViewController.m
//  Hiking Maps
//
//  Created by Morgan McCoy on 3/10/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMHomeViewController.h"
#import "MPMTrailViewController.h"
#import "Trail.h"
#import "UIPopoverController+iPhone.h"
#define METRIC_CONVERSION 0.00062137

@interface MPMHomeViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *forestsArray;

@property (nonatomic, strong) NSArray *forestTrailsArray;

@property (nonatomic, strong) UIPopoverController *contactPopover;

@property (nonatomic, strong) NSArray *styles;

@property (nonatomic, strong) NSArray *lengths;

@end

@implementation MPMHomeViewController
{
    UIImage *img;
    BOOL mapExpand;
}

- (id)init
{
    self = [super init];
    
    if(!self) return nil;
    
    self.styles = @[[GMSStrokeStyle solidColor:[UIColor yellowColor]],[GMSStrokeStyle solidColor:[UIColor blackColor]]];
    
    self.lengths = @[@750, @500];
    
    mapExpand = YES;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    img = img = [UIImage imageNamed:@"red-dot-2px.png"];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"Utah Hiking Maps";
    
    self.forestsArray = @[@"Arches National Park",@"Ashley National Forest",@"Dinosaur National Monument",@"Dixie National Forest",@"Fishlake National Forest",@"Grand Staircase Escalante National Monument",@"Manti-LaSal National Forest",@"Moab BLM",@"Uinta-Wasatch-Cache National Forest", @"Zion National Park"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.4997605 longitude:-111.547028 zoom:5.5];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    self.mapView.mapType = kGMSTypeTerrain;
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.mapView.delegate = self;
    
    // calls to drawTrail to populate the map on the home screen
    [self drawTrail:@"arch"];
    [self drawTrail:@"ashley"];
    [self drawTrail:@"dino"];
    [self drawTrail:@"dixie"];
    [self drawTrail:@"fishlake"];
    [self drawTrail:@"grand"];
    [self drawTrail:@"manti"];
    [self drawTrail:@"moab"];
    [self drawTrail:@"uwf"];
    [self drawTrail:@"zion"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setNavigationBarRightButton];
    mapExpand = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// method to set the navigation bar button on home screen or when map is minimized
-(void)setNavigationBarRightButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Credits" style:UIBarButtonItemStyleDone target:self action:@selector(onClickrighttButton:)];
    self.navigationItem.rightBarButtonItem = button;
}

// method to set the navigation bar button on home screen when map is expanded
-(void)setNavigationBarButtonOnExpand
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Satellite" style:UIBarButtonItemStyleDone target:self action:@selector(onClickrighttMapButton:)];
    self.navigationItem.rightBarButtonItem = button;
}

// method to handle right navigation bar button when the map is minimized, launches UIPopover with map data credits.
- (void)onClickrighttButton:(id)sender
{
    UIViewController *popoverContent = [[UIViewController alloc]init];
    
    UIView *popoverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 175, 100)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont fontWithName:@"Helvetica" size:10];

    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Map base layers provided by Google. Trail data provided by the US Forest Service, National Park Service, and Bureau of Land Management."];
    label.attributedText = string;
    
    [popoverView addSubview:label];
    popoverContent.view = popoverView;
    popoverContent.preferredContentSize = CGSizeMake(200, 100);
    
    self.contactPopover =[[UIPopoverController alloc] initWithContentViewController:popoverContent];
    [self.contactPopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionLeft animated:YES];
    [self.contactPopover setDelegate:self];
}

// method to handle right navigation bar button when map has been expanded, changes map type
- (void)onClickrighttMapButton:(id)sender
{
    if (self.mapView.mapType == kGMSTypeTerrain)
    {
        self.mapView.mapType = kGMSTypeSatellite;
        self.navigationItem.rightBarButtonItem.title = @"Normal";
    }
    
    else if (self.mapView.mapType == kGMSTypeSatellite)
    {
        self.mapView.mapType = kGMSTypeNormal;
        self.navigationItem.rightBarButtonItem.title = @"Terrain";
    }
    
    else if (self.mapView.mapType == kGMSTypeNormal)
    {
        self.mapView.mapType = kGMSTypeTerrain;
        self.navigationItem.rightBarButtonItem.title = @"Satellite";
    }
}

// lays out subviews initially, and on device rotation
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    mapExpand = YES;
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
    self.tableView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
    self.mapView.frame = CGRectMake(0,self.view.bounds.size.height/2,self.view.bounds.size.width,self.view.bounds.size.height/2);
}

// method to create the table view size, same as the number of trail areas (forest)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.forestsArray count];
}

// method to populate the table view on the home screen with trail area names (forest)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForestIdentifier"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ForestIdentifier"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.forestsArray[indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.superview.backgroundColor = [UIColor colorWithRed:0.937 green:0.871 blue:0.804 alpha:1.0];
}

// method to handle user selection on the home screen's table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSString *forestName = self.forestsArray[index];
    NSString *path;
    NSArray *trailsArray;
    
    if(index == 0)
    {
        path = @"arch";
    }
    else if(index == 1)
    {
        path = @"ashley";
    }
    else if(index == 2)
    {
        path = @"dino";
    }
    else if(index == 3)
    {
        path = @"dixie";
    }
    else if(index == 4)
    {
        path = @"fishlake";
    }
    else if(index == 5)
    {
        path = @"grand";
    }
    else if(index == 6)
    {
        path = @"manti";
    }
    else if(index == 7)
    {
        path = @"moab";
    }
    else if(index == 8)
    {
        path = @"uwf";
    }
    else if(index == 9)
    {
        path = @"zion";
    }
    
    trailsArray = [self trailArray:path];
    Trail *nearest = [[Trail alloc] init];
    nearest.name = @"Nearest Trails...";
    trailsArray = [@[nearest] arrayByAddingObjectsFromArray:trailsArray];
    
    MPMTrailViewController *viewController = [[MPMTrailViewController alloc] init];
    viewController.forest = forestName;
    viewController.trails = trailsArray;
    [self.navigationController pushViewController:viewController animated:YES];
}

// method to create a sorted array of trails to populate the trail view controller's table view from geojson data.
- (NSArray *)trailArray:(NSString *)path
{
    NSString *forestName = path;
    NSMutableArray *trails;
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    
    path = [[NSBundle mainBundle] pathForResource:path ofType:@"geojson"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *trailsArray = jsonDictionary[@"features"];
    
    trails = [NSMutableArray new];
    
    for(NSDictionary *trailProperties in trailsArray)
    {
        Trail *t = [[Trail alloc] initWithProperties:trailProperties];
        if(t.name != nil){
            t.jurisdiction = [self jurisdiction:forestName];
            [trails addObject:t];
        }
    }
    
    NSArray *sortedArray = [trails sortedArrayUsingDescriptors:descriptors];
    
    return sortedArray;
}

// method to draw trail paths on mapView on the home screen
- (void)drawTrail:(NSString *)forestName
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:forestName ofType:@"geojson"]];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *trailsArray = jsonDictionary[@"features"];
    
    for(NSDictionary *trailProperties in trailsArray)
    {
        Trail *t = [[Trail alloc] initWithProperties:trailProperties];
        if(t.name != nil)
        {
            t.jurisdiction = [self jurisdiction:forestName];
            double lat = [t.startLatitude doubleValue];
            double lon = [t.startLongitude doubleValue];
            CLLocation *loca = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
            CLLocationCoordinate2D coordi = loca.coordinate;
            
            GMSMarker *marker = [GMSMarker markerWithPosition:coordi];
            marker.icon = img;
            marker.flat = NO;
            marker.title = t.name;
            float miles = [t.length floatValue] * METRIC_CONVERSION;
            marker.snippet = [NSString stringWithFormat:@"Length: %.2f Miles\nJurisdiction: %@", miles, t.jurisdiction];
            
            marker.map = self.mapView;
            
            GMSMutablePath *path = [GMSMutablePath path];
            for(id array in t.coordinates)
            {
                double latitude = [array[1] doubleValue] ;
                double longitude = [array[0] doubleValue];
                [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            }
            
            GMSPolyline *trailPath = [GMSPolyline polylineWithPath:path];
            
            trailPath.tappable = YES;
            trailPath.title = [t.name stringByAppendingFormat:@"\n Jurisdiction: %@",t.jurisdiction];

            trailPath.map = self.mapView;
        }
    }
}

// method used to set the jurisdiction property of a Trail object
- (NSString *)jurisdiction:(NSString *)forestName
{
   NSString *trailJurisdiction;
    if([forestName isEqualToString:@"arch"]){
        trailJurisdiction = @"Arches National Park";
    }
    else if([forestName isEqualToString:@"ashley"]){
        trailJurisdiction = @"Ashley National Forest";
    }
    else if([forestName isEqualToString:@"dino"]){
        trailJurisdiction = @"Dinosaur National Monument";
    }
    else if([forestName isEqualToString:@"dixie"]){
        trailJurisdiction = @"Dixie National Forest";
    }
    else if([forestName isEqualToString:@"fishlake"]){
        trailJurisdiction = @"Fishlake National Forest";
    }
    else if([forestName isEqualToString:@"grand"]){
        trailJurisdiction = @"Grand Staircase Escalante National Monument";
    }
    else if([forestName isEqualToString:@"manti"]){
        trailJurisdiction = @"Manti LaSal National Forest";
    }
    else if([forestName isEqualToString:@"moab"]){
        trailJurisdiction = @"Moab BLM";
    }
    else if([forestName isEqualToString:@"uwf"]){
        trailJurisdiction = @"Uinta-Wasatch-Cache National Forest";
    }
    else if([forestName isEqualToString:@"zion"]){
        trailJurisdiction = @"Zion National Park";
    }
    
    return trailJurisdiction;
}

// method to handle when a user taps on a specific trail segment on the mapView
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSPolyline *)overlay
{
    GMSPolyline *polyline = overlay;
    NSString *name = polyline.title;
    GMSPath *path = polyline.path;
    float miles = [path lengthOfKind:kGMSLengthRhumb] * METRIC_CONVERSION;
    CLLocationCoordinate2D coord = [path coordinateAtIndex:0];
    GMSMarker *marker = [GMSMarker markerWithPosition:coord];
    marker.title = name;
    marker.snippet = [NSString stringWithFormat:@"Length: %.2f Miles", miles];
    marker.map = self.mapView;
    polyline.spans = GMSStyleSpans(polyline.path, self.styles, self.lengths, kGMSLengthRhumb);
}

// method to handle resizing mapview when a user taps on it
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if(mapExpand == YES)
    {   [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5];
        [self.view bringSubviewToFront:self.mapView];
        self.mapView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
        [self setNavigationBarButtonOnExpand];
        [UIView commitAnimations];
        mapExpand = NO;
    }
    else if (mapExpand == NO)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5];
        [self viewWillLayoutSubviews];
        [self setNavigationBarRightButton];
        [UIView commitAnimations];
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
