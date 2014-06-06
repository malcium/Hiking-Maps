//
//  UIPopoverController+iPhone.m
//  Hiking Maps
//
//  Created by Morgan McCoy on 6/4/14.
//  Copyright (c) 2014 Westminster College. All rights reserved.
//

#import "UIPopoverController+iPhone.h"

@implementation UIPopoverController (iPhone)

// This category allows a UIPopoverController to be used on an iPhone, and not just iPads
+ (BOOL)_popoversDisabled
{
    return NO;
}

@end