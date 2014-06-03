//
//  MPMTopoViewController.h
//  HikingMaps
//
//  Created by Morgan McCoy on 2/28/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Trail.h"

@interface MPMTopoViewController : UIViewController <CLLocationManagerDelegate, GMSMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) Trail *trail;

@end
