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

//custom init to create trail objects
- (id)initWithProperties:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(!self) return nil;
    
    NSDictionary *properties = dictionary[@"properties"];  // dictionary for the properties field in the JSON
    NSDictionary *geometry = dictionary[@"geometry"];      // dictionary for the geometry field in the JSON
    
    // if the trail has a name that isn't null, set the basic properties
    if (properties[@"NAME"] != [NSNull null])
    {
        _name = [properties[@"NAME"] capitalizedString];
        _jurisdiction = nil;
        _length = properties[@"Length"];
    
    }
    
    // if the geometry portion of a trail exists (some trails in the data have none)
    // then store the coordinates in the coordinates property of a trail, and grab
    // the first two coordinates and set those properties as well
    if (geometry != (NSDictionary *)[NSNull null])
    {
        if ([geometry[@"type"] isEqual: @"LineString"])
        {
            _coordinates = geometry[@"coordinates"];
            NSArray *coordinate = [_coordinates firstObject];
            _startLatitude = coordinate[1];
            _startLongitude = coordinate[0];
        }
        if ([geometry[@"type"] isEqual: @"MultiLineString"])
        {
            _coordinates = geometry[@"coordinates"][0];
            NSArray *coordinate = [_coordinates firstObject];
            _startLatitude = coordinate[1];
            _startLongitude = coordinate[0];
        }
    }
    
    return self;
}

@end
