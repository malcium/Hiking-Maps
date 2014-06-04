//
//  Hiking_MapsTests.m
//  Hiking MapsTests
//
//  Created by Morgan McCoy on 5/19/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Trail.h"

@interface Hiking_MapsTests : XCTestCase

@end

@implementation Hiking_MapsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testForDuplicateTrails
{
    NSMutableArray *trails;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"arch"
                                                     ofType:@"geojson"];
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
    
    Trail *test = [trails objectAtIndex:0];
    for (int i = 1; i < [trails count]; i++){
        Trail *t = [trails objectAtIndex:i];
        XCTAssertNotEqual(test, t);
    }
}

@end
