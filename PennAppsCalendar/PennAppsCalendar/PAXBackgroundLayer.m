//
//  PAXBackgroundLayer.m
//  PennAppsCalendar
//
//  Created by Jennifer Zhang on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXBackgroundLayer.h"

@implementation PAXBackgroundLayer


+ (CAGradientLayer*) skyGradient {
    
    UIColor *topColor = [UIColor colorWithRed:210.0/255.0 green:196.0/255.0 blue:232.0/255.0 alpha:0.75];
    UIColor *bottomColor = [UIColor colorWithRed:146.0/255.0 green:158.0/255.0 blue:210.0/255.0 alpha:0.75];
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = gradientColors;
    gradientLayer.locations = gradientLocations;
    
    return gradientLayer;
    
}

@end
