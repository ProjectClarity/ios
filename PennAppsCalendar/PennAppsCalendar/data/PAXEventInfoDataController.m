//
//  PAXEventInfoDataController.m
//  PennAppsCalendar
//
//  A helper class to facilitate retrieving auxilary infomration
//  from the service.
//
//  Created by Benjamin Y Chan on 9/14/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXEventInfoDataController.h"
#import "AFHTTPRequestOperationManager.h"

@implementation PAXEventInfoDataController


+ (id)sharedInfoDataController
{
    static PAXEventInfoDataController *sharedInfoDataController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInfoDataController = [[self alloc] init];
    });
    return sharedInfoDataController;
}

#pragma mark - Info

// Note that all locations are strings of the form @"%f,%f"
- (void)fetchDistancesToDestinations:(NSArray *)destinations
                        fromLocation:(NSString *)locationString
                        onCompletion:(void (^)(NSDictionary *))completionHandler
{
    NSString *destinationsString = [destinations componentsJoinedByString:@";"];
    NSLog(@"DESTINATIONS %@", destinationsString);
    NSString *urlString = [NSString stringWithFormat:@"http://pennappsx-web.herokuapp.com/user/distance?current_location=%@&destinations=%@", locationString, destinationsString];
    
    NSLog(@"DESINATION URL %@", urlString);
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"DESIEENATION URL %@", urlString);

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // handle error if available
        NSDictionary *parsedJSONDictionary = (NSDictionary *)responseObject;
        if (parsedJSONDictionary[@"error"]) {
            NSLog(@"ERROR: %@", parsedJSONDictionary[@"message"]);
        }
        // and since the data's simple, we're done already!
        completionHandler(parsedJSONDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
    }];

}


@end
