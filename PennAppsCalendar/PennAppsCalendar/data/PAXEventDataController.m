//
//  PAXEventDataController.m
//  PennAppsCalendar
//
//  Created by Benjamin Y Chan on 9/13/14.
//  Copyright (c) 2014 PAX. All rights reserved.
//

#import "PAXEventDataController.h"
#import <CoreData/CoreData.h>
#import "AFHTTPRequestOperationManager.h"
#import "PAXEvent.h"

// Hard coded for now... Don't change between sessions
// Also not really infinite... yet.
// Other issues: currently re-fetches every time, among other things.
#define BATCH_SIZE 250

#define DEBUG_MODE 1

@interface PAXEventDataController () <NSFetchedResultsControllerDelegate>
{
    // keep track of changes, and batch them together
    NSMutableArray *_batchContentChanges;
    // We keep google's sort order, and cache the "next" index here
    NSUInteger _currentSortIndex;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, strong, nonatomic) NSArray *pendingChanges;

@end

@implementation PAXEventDataController

+ (id)sharedEventDataController
{
    static PAXEventDataController *sharedEventDataController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEventDataController = [[self alloc] init];
    });
    return sharedEventDataController;
}

- (id)init
{
    self = [super init];
    if (self) {
        _authPin = 0;
        // TEMP
        [self reset];
    }
    return self;
}

#pragma mark - Event Access

/**
 * Ask the data controller to fetch the next set of events.
 * This will update the core data stack when a successful fetch occurs.
 */
- (void)fetchMoreEventsWithCallback:(void (^)(void))callback
{
    [self saveEventsAfterDate:[NSDate date] fetchCount:BATCH_SIZE onCompletion:callback];
}

/**
 * Update all events in the core data stack from the server.
 */
- (void)refreshAllEventsWithCallback:(void (^)(void))callback
{
    [self saveEventsAfterDate:[NSDate date] fetchCount:BATCH_SIZE onCompletion:callback];
}

- (void)reset
{
    NSError *error;
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"PAXEvents.sqlite"];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
}




#pragma mark - Core Data Integration

@synthesize fetchedResultsController = _fetchedResultsController;

/** 
 * Get the fetchedResultsController, which acts as the data source for the collection view. This
 * mirrors EXACTLY what is shown.
 **/
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PAXEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:100];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"googleSort" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"PAXCache"];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

// Should be called on the main thread
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_batchContentChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Now, we fire off content change
    self.pendingChanges = [_batchContentChanges copy];
    [_batchContentChanges removeAllObjects];
}

#pragma mark - External Sources

/**
 * Update an event object with new information
 */
- (void)updateEvent:(PAXEvent *)event withJSONEvent:(NSDictionary *)JSONEvent
{
    // Don't reinstantiate every time (TODO)
    NSDateFormatter *dateConverter = [[NSDateFormatter alloc] init];
    [dateConverter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    event.name = JSONEvent[@"summary"];
    event.notes = JSONEvent[@"description"];
    event.location = JSONEvent[@"location"];
    NSString *endDateString = JSONEvent[@"end"][@"dateTime"];
    if (endDateString) {
        event.endDate = [dateConverter dateFromString:endDateString];
    }
    NSString *startDateString = JSONEvent[@"start"][@"dateTime"];
    if (startDateString) {
        NSDate *convertedStartDate = [dateConverter dateFromString:startDateString];
        NSLog(@"Converted date: %@", convertedStartDate);
        event.startDate = convertedStartDate;
    }
    else {
        NSString *startDateString = JSONEvent[@"start"][@"date"];
        [dateConverter setDateFormat:@"yyyy-MM-dd"];
        event.startDate = [dateConverter dateFromString:startDateString];
    }
    event.uid = JSONEvent[@"id"];
    event.googleSort = @(_currentSortIndex);
    _currentSortIndex++;
}

/**
 * Fetch and save events into the local managed object context.
 ** TODODODODODO DELETE (which doesn't work)
 */
- (void)saveEventsAfterDate:(NSDate *)date fetchCount:(NSUInteger)count onCompletion:(void (^)(void))callback
{
    [self processEventsAfterDate:date fetchCount:count withHandler:^(NSArray *events) {
        _currentSortIndex = 0;
        for (NSDictionary *JSONEvent in events) {
            // stick into the core data stack, if not in there already
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PAXEvent"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid = %@", JSONEvent[@"id"]];
            NSError *error = nil;
            NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            NSLog(@"existing id: %@", JSONEvent[@"id"]);
            if (error) {
                NSLog(@"error: %@", error.localizedDescription);
            }
            if (result.lastObject && [[result.lastObject entity].name isEqualToString:@"PAXEvent"]) {
                // update the object
                NSLog(@"Updating existing object");
                [self updateEvent:result.lastObject withJSONEvent:JSONEvent];
                continue;
            }
            // Insert new object, since it doesn't exist already
            NSEntityDescription *employeeEntity = [NSEntityDescription
                                                   entityForName:@"PAXEvent"
                                                   inManagedObjectContext:self.managedObjectContext];
            PAXEvent *newLocalEvent = [[PAXEvent alloc] initWithEntity:employeeEntity insertIntoManagedObjectContext:self.managedObjectContext];
            [self updateEvent:newLocalEvent withJSONEvent:JSONEvent];
            
        }
        // Persist all changes
        [self saveContext];
        // call completion handler
        callback();
    }];
}

/**
 * Start fetching events, processing using the given event Handler.
 * Handle fetched JSON events by passing in an eventsHandler
 */
- (void)processEventsAfterDate:(NSDate *)date fetchCount:(NSUInteger)count withHandler:(void(^)(NSArray *events))eventsHandler
{
    // Fetch JSON from service
#if DEBUG_MODE
    NSLog(@"a;sdlkfj %d", self.authPin);
    if (self.authPin == 0) {
        self.authPin = 7023;
    }
#endif
    NSString *urlString = [NSString stringWithFormat:@"https://pennappsx-web.herokuapp.com/user/%lu/calendar/events/%d", (unsigned long)self.authPin, BATCH_SIZE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // for event in responseObject,
        // call event handler
        NSDictionary *parsedJSONDictionary = (NSDictionary *)responseObject;
        if (parsedJSONDictionary[@"error"]) {
            NSLog(@"ERROR: %@", parsedJSONDictionary[@"message"]);
        }
        // todo reduce hard coding
        NSArray *eventsArray = parsedJSONDictionary[@"events"];
        eventsHandler(eventsArray);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@", error);
    }];
}

#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// Save the core data stack
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PAXEvents" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PAXEvents.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
