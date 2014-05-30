//
//  Trail.m
//  HikingMaps
//
//  Created by Morgan McCoy on 3/11/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "Trail.h"
#import <CoreLocation/CoreLocation.h>

@implementation Trail

- (id)initWithProperties:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(!self) return nil;
    
    //custom init to create trail objects
    NSDictionary *properties = dictionary[@"properties"];
    NSDictionary *geometry = dictionary[@"geometry"];
    
    if (properties[@"NAME"] != [NSNull null])
    {
        _name = [properties[@"NAME"] capitalizedString];
        _length = properties[@"Shape_Leng"];
    }
    
    if (geometry != (NSDictionary *)[NSNull null])
    {
        if ([geometry[@"type"] isEqual: @"LineString"])
        {
            _coordinates = geometry[@"coordinates"];
            NSArray *coordinate = [_coordinates firstObject];
            _startLatitude = coordinate[1];
            _startLongitude = coordinate[0];
           // NSLog(@"%@, %@", coordinate[0], coordinate[1]);
        }
        if ([geometry[@"type"] isEqual: @"MultiLineString"])
        {
            _coordinates = geometry[@"coordinates"][0];
            NSArray *coordinate = [_coordinates firstObject];
            _startLatitude = coordinate[1];
            _startLongitude = coordinate[0];
            //NSLog(@"%@, %@", coordinate[0], coordinate[1]);
        }
    }
    
    return self;
}

@end
