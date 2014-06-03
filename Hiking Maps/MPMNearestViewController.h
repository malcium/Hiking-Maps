//
//  MPMNearestViewController.h
//  Hiking Maps
//
//  Created by Morgan McCoy on 5/29/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Trail.h"

@interface MPMNearestViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) NSArray *trails;

@property (nonatomic, strong) NSString *forest;

@end
