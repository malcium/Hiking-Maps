//
//  Trail.h
//  HikingMaps
//
//  Created by Morgan McCoy on 3/11/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trail : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *jurisdiction;
@property (nonatomic, strong) NSNumber *startLatitude;
@property (nonatomic, strong) NSNumber *startLongitude;
@property (nonatomic, strong) NSArray *coordinates;
@property (nonatomic, strong) NSNumber *length;

- (id)initWithProperties:(NSDictionary *)dictionary;

@end
