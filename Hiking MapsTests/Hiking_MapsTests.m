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

@property (nonatomic, strong) NSArray *data;

@end

@implementation Hiking_MapsTests

- (void)setUp
{
    [super setUp];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.data = @[@"arch",@"bryce",@"dino",@"zion",@"grand",@"moab",@"ashley",@"dixie",@"fishlake",@"manti",@"uwf"];
}

- (void)tearDown
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super tearDown];
}

// tests every dataset to ensure that Trail object creation doesn't produce trails with duplicate names
- (void)testForDuplicateTrails
{
    NSLog(@"%s doing work...", __PRETTY_FUNCTION__);
    for (NSString *s in self.data){
        NSMutableArray *trails;
        NSString *path = [[NSBundle mainBundle] pathForResource:s
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
        for (int j = 0; j < [trails count]; j++) {
            
            Trail *test = [trails objectAtIndex:j];
            for (int i = 0; i < [trails count]; i++){
                Trail *t = [trails objectAtIndex:i];
                if (j != i)
                    XCTAssertNotEqual(test.name, t.name);
            }
        }
    }
}

// Test to ensure that object creation doesn't create null objects
- (void)testForNils
{
    NSLog(@"%s doing work...", __PRETTY_FUNCTION__);
    for (NSString *s in self.data){
        NSMutableArray *trails;
        NSString *path = [[NSBundle mainBundle] pathForResource:s
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
        
        for (int i = 0; i < [trails count]; i++){
            Trail *t = [trails objectAtIndex:i];
            XCTAssertNotEqual(t, (Trail *) [NSNull null]);
        }
    }
}

@end
