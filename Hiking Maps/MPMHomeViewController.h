//
//  MPMHomeViewController.h
//  Hiking Maps
//
//  Created by Morgan McCoy on 3/10/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MPMHomeViewController : UIViewController <CLLocationManagerDelegate , GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;

@end
