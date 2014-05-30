//
//  MPMHomeViewController.m
//  Hiking Maps
//
//  Created by Morgan McCoy on 5/20/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "MPMHomeViewController.h"
#import "MPMTrailViewController.h"
#import "Trail.h"


@interface MPMHomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *forestsArray;

@property (nonatomic, strong) NSArray *forestTrailsArray;

@end

@implementation MPMHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    self.title = @"Utah Hiking Maps";
    
    self.forestsArray = @[@"Ashley National Forest",@"Dixie National Forest",@"Fishlake National Forest",@"Manti-LaSal National Forest",@"Uinta-Wasatch-Cache National Forest"];
    
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
    self.tableView.backgroundColor = [UIColor brownColor];
    
    // calls to drawTrail to populate the map on the home screen
    [self drawTrail:@"test"];
    [self drawTrail:@"dixie_trails"];
    [self drawTrail:@"fishlake_trails"];
    [self drawTrail:@"manti_trails"];
    [self drawTrail:@"uwf_trails"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;
    self.mapView.frame = CGRectMake(0,self.view.bounds.size.height/2,self.view.bounds.size.width,self.view.bounds.size.height/2);
    
    self.tableView.frame = self.view.bounds;
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
    self.tableView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
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

// method to handle user selection on the home screen's table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSString *forestName = self.forestsArray[index];
    NSString *path;
    NSArray *trailsArray;
    
    if(index == 0)
    {
        path = [[NSBundle mainBundle] pathForResource:@"test"
                                               ofType:@"geojson"];
    }
    if(index == 1)
    {
        path = [[NSBundle mainBundle] pathForResource:@"dixie_trails"
                                               ofType:@"geojson"];
    }
    if(index == 2)
    {
        path = [[NSBundle mainBundle] pathForResource:@"fishlake_trails"
                                               ofType:@"geojson"];
    }
    if(index == 3)
    {
        path = [[NSBundle mainBundle] pathForResource:@"manti_trails"
                                               ofType:@"geojson"];
    }
    if(index == 4)
    {
        path = [[NSBundle mainBundle] pathForResource:@"uwf_trails"
                                               ofType:@"geojson"];
    }
    
    trailsArray = [self trailArray:path];
    
    MPMTrailViewController *viewController = [[MPMTrailViewController alloc] init];
    viewController.forest = forestName;
    viewController.trails = trailsArray;
    [self.navigationController pushViewController:viewController animated:YES];
}

// method to create a sorted array of trails to populate the trail view controller's table view from geojson data.
- (NSArray *)trailArray:(NSString *)path
{
    NSMutableArray *trails;
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *trailsArray = jsonDictionary[@"features"];
    
    trails = [NSMutableArray new];
    
    for(NSDictionary *trailProperties in trailsArray)
    {
        Trail *t = [[Trail alloc] initWithProperties:trailProperties];
        if(t.name != nil)
            [trails addObject:t];
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
}

@end
