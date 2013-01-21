//
//  main.m
//  AppBoxProPrepareData
//
//  Created by Byeong Kwon Kwak on 5/2/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDataUtility.h"

#define DATABASE_FILENAME   @"AppBox3"

NSString *modelFilePath() {
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
	path = [path stringByDeletingLastPathComponent];
	path = [path stringByAppendingPathComponent:DATABASE_FILENAME];
	NSLog(@"%@", path);
	return path;
}

NSString *instanceFilePath() {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByDeletingLastPathComponent];
    path = [path stringByAppendingPathComponent:@"projects/AppBox3/AppBox3/Data Management"];
	path = [path stringByAppendingPathComponent:DATABASE_FILENAME];
    NSLog(@"%@", path);
    return path;
}

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = modelFilePath();
    
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
	NSLog(@"%@", [modelURL path]);
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = instanceFilePath();
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{
    
	@autoreleasepool {
        // Find database instance at specified path and if it exist, remove it.
        NSString *path = instanceFilePath();
        path = [path stringByAppendingPathExtension:@"sqlite"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:NULL];
        }
        
        // Create the managed object context
	    NSManagedObjectContext *context = managedObjectContext();
        
	    // Custom code here...
		A3AppDataUtility *utility = [[A3AppDataUtility alloc] init];
		[utility setManagedObjectContext:context];
        [utility initializeMenu];
		[utility initCurrencyData];

		// Save the managed object context
	    NSError *error = nil;
	    if (![context save:&error]) {
	        NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
	        exit(1);
	    }
        
//		[utility makeCurrencyDataFile];
	}
    return 0;
}

