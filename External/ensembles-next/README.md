Core Data Ensembles
===

_Author:_ Drew McCormack<br>
_Created:_ 29th September, 2013<br>
_Last Updated:_ 1st June, 2015

Ensembles extends Apple's Core Data framework to add peer-to-peer synchronization for Mac OS and iOS. Multiple SQLite persistent stores can be coupled together via file synchronization platforms like iCloud, CloudKit, Dropbox, and even direct peer-to-peer connections. The framework can be readily extended to support any service capable of moving files between devices, including custom servers.

*There is a [Google Group](https://groups.google.com/forum/#!forum/ensembles) for discussing best practices with other developers.*

#### Ensembles 2
=======
Ensembles is an Objective-C framework &mdash; with Swift support &mdash; that extends Apple's Core Data framework to add peer-to-peer synchronization for Mac OS and iOS. Multiple SQLite persistent stores can be coupled together via a file synchronization platform like iCloud or Dropbox. The framework can be readily extended to support any service capable of moving files between devices, including custom servers.

Ensembles 2 is a drop-in replacement for the open source Ensembles project. Ensembles 2 is proprietary software, and cannot be used or distributed other than under the terms of the accompanying license.

Ensembles 2 includes a number of improvements over Ensembles v1.x.

 * Much improved performance
 * Significantly reduced memory utilization
 * Humanly-readable transaction logs (JSON)
 * Option to compress cloud data (zip)
 * Compressed-JSON reduces cloud storage up to 50 times
 * Memory usage can be carefully controlled by controlling data traversals
 * Progress notifications are available for long processes like merging
 * Property to monitor current activity
 * Backends for CloudKit, Dropbox Sync API, and WebDAV
 
In conclusion, Ensembles 2 is preferred to Ensembles 1.x, especially for large data sets or complex data models.

#### Downloading Ensembles 2

If you have access to the Ensembles 2 Git repository, you can clone Ensembles to your local drive, using the command

	git clone https://github.com/mentalfaculty/ensembles-next.git ensembles

Ensembles makes use of Git submodules. To retrieve these, change to the `ensembles` root directory

	cd ensembles

and issue this command

	git submodule update --init

#### Installing Ensembles with CocoaPods

##### iOS

First, you need to add the private repository of The Mental Faculty to your Cocoapods installation.

        pod repo add mentalfaculty https://github.com/mentalfaculty/Specs.git

Then, you can include Ensembles in your Podfile.

        platform :ios, '7.0'
        pod "Ensembles", "~> 2.0"

##### OS X

Add the private repository of The Mental Faculty to your Cocoapods installation.

        pod repo add mentalfaculty https://github.com/mentalfaculty/Specs.git

Now add the following to your Podfile 

		platform :osx, '10.9'
		pod "Ensembles", "~> 2.0"

#### Installing Ensembles Manually

##### iOS

To manually add Ensembles to your App's Xcode Project...

1. In Finder, drag the `Ensembles iOS.xcodeproj` project from the `Framework` directory into your Xcode project.
2. Select your App's project root in the source list on the left, and then select the App's target.
3. In the General tab, click the + button in the _Linked Frameworks and Libraries_ section.
4. Choose the `libensembles.a` library and add it.
5. Select the _Build Settings_ tab. Locate the _Other Linker Flags_ setting, and add the flag `-ObjC`.
6. Select the _Build Phases_ tab. Open _Target Dependencies_, and click the + button.
7. Locate the `Ensembles Resources iOS` product, and add that as a dependency.
8. Open the `Ensembles iOS.xcodeproj` project in the source list, and open the Products group.
9. Drag the `Ensembles.bundle` product into the _Copy Bundle Resources_ build phase of your app.
10. Add the following import in your precompiled header file, or in any files using Ensembles.

        #import <Ensembles/Ensembles.h>

##### OS X

To add Ensembles to your App's Xcode Project...

1. In Finder, drag the `Ensembles Mac.xcodeproj` project from the `Framework` directory into your Xcode project.
2. Select your App's project root in the source list on the left, and then select the App's target.
3. In the General tab, click the + button in the _Linked Frameworks and Libraries_ section.
4. Choose `Ensembles.framework` and add it.
5. Create a new build phase to copy frameworks into your app bundle (if you don’t already have one). To do this...
 * Select the project root in the source list, then select your app’s target.
 * Open the *Build Phases* tab.
 * Click the + button at the top of the list.
 * Choose *New Copy Files Build Phase* from the popup menu.
 * Disclose the contents of the new *Copy Files* phase, and choose *Frameworks* from the *Destination* popup button.
 * Click the + button at the bottom of the *Copy Files* phase section, choose *Ensembles.framework*, and click *Add*.
6. Locate the _Runpath Search Path_ build setting, and add `@loader_path/../Frameworks`.
7. Add the following import in your precompiled header file, or in any files using Ensembles.

        #import <Ensembles/Ensembles.h>

#### Including Optional Cloud Services

By default, Ensembles only includes support for iCloud. To use other cloud services, such as Dropbox, you may need to add a few steps to the procedure above. 

If you are using Cocoapods, add the optional subspec to the Podfile. For example, to include Dropbox, include

		pod "Ensembles/Dropbox", "~> 2.0"

If you are installing Ensembles manually, rather than with Cocoapods, you need to locate the source files and frameworks relevant to the service you want to support. You can find frameworks in the `Vendor` folder, and source files in `Framework/Extensions`.

By way of example, if you want to support Dropbox, you need to add the DropboxSDK Xcode project as a dependency, link to the appropriate product library, and include the files `CDEDropboxCloudFileSystem.h` and `CDEDropboxCloudFileSystem.m` in your project.

#### Available Backends

Ensembles 2 currently supports the following backends (Cocoapods subspecs are shown in parentheses):

 * Local File System (Core)
 * iCloud (Core)
 * CloudKit (CloudKit)
 * Dropbox Core (Dropbox) 
 * Dropbox Sync (DropboxSync)
 * WebDAV (WebDAV)
 * Multipeer Connectivity (Multipeer)
 * Zip Compression (Zip)
 * Encryption (Encrypt)
 * Ensembles Node.js Server (Node)
 
The local file system backend is mostly for testing purposes. 

The Zip Compression backend is not actually for data transfer, but can be used to wrap any of the other backends in order to compress files before transporting them.

The Encryption backend is similar to the Zip backend in that it is a wrapper for other backends. It encrypts the data using a supplied pass phrase before it is stored in the cloud.

The Ensembles Node.js Server is a custom server that is provided to purchasers of the Priority Support Package. It can be deployed on Heroku, and utilizes Amazon S3 for cloud storage.

#### Idiomatic  App

Idiomatic is a relatively simple example app which incorporates Ensembles and works with iCloud, Dropbox Sync, Multipeer, and Ensembles Server to sync across devices. The app allows you to record your ideas, include a photo, and add tags to group them. The Core Data model of the app has three entities, including a many-to-many relationship.

The Idiomatic project is a good way to get acquainted with Ensembles, and how it is integrated in a Core Data app. Idiomatic can be downloaded from the App Store if you want to see how it works. If you want to build and run it yourself, you need to follow a few preparatory steps.

1. Select the Idiomatic Project in the source list of the Xcode project, and then select the Idiomatic target.
2. Select the _Capabilities_ section, turn on the iCloud switch.
3. Build and install on devices and simulators that are logged into the same iCloud account.
 
Add notes, and tag them as desired. The app will sync when it becomes active, but you can force a sync by tapping the button under the Groups table.

Dropbox sync should work via The Mental Faculty account, but if you want to use your own developer account, you need to do the following:

1. Sign up for a Dropbox developer account at developer.dropbox.com
2. In the App Console, click the Create app button.
3. Choose the Dropbox API app type.
4. Choose to store 'Files and Datastores'
5. Choose 'Yes &mdash; My app only needs access to files it creates'
6. Name the app (eg Idiomatic)
7. Click on Create app 
8. At the top of the `IDMSyncManager` class, locate this code, and replace the values with the strings you just created on the Dropbox site.

		NSString * const IDMDropboxAppKey = @"xxxxxxxxxxxxxxx";
		NSString * const IDMDropboxAppSecret = @"xxxxxxxxxxxxxxx";
	
9. Select the Idiomatic project in Xcode, and then the Idiomatic iOS target.
10. Select the Info tab.
11. Open the URL Types section, and change the URL Schemes entry to 

		db-<Your Dropbox App Key>

Idiomatic includes one more sync service: IdioSync. This is a custom service based on a Node.js server, and Amazon S3 storage. The source code for the server is provided to those purchasing a Priority Support Package at [ensembles.io](http://ensembles.io).

#### Getting to Know Ensembles

Before using Ensembles in any file, you should import the framework header, either in your precompiled header file, or in individual source code files.

    #import <Ensembles/Ensembles.h>

The most important class in the Ensembles framework is `CDEPersistentStoreEnsemble`. You create one instance of this class for each `NSPersistentStore` that you want to sync. This class monitors saves to your SQLite store, and merges in changes from other devices as they arrive.

You typically initialize a `CDEPersistentStoreEnsemble` around the same point in your code that your Core Data stack is initialized. It is important that the ensemble is initialized before data is saved.

There is one other family of classes that you need to be familiar with. These are classes that conform to the `CDECloudFileSystem` protocol. Any class conforming to this protocol can serve as the file syncing backend of an ensemble, allowing data to be transferred between devices. You can use one of the existing classes (_eg_ `CDEICloudFileSystem`), or develop your own.

The initialization of an ensemble is typically only a few lines long.

	// Setup Ensemble
	cloudFileSystem = [[CDEICloudFileSystem alloc] 
		initWithUbiquityContainerIdentifier:@"P7BXV6PHLD.com.mentalfaculty.idiomatic"];
	ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"MainStore" 
		persistentStorePath:storeURL.path 
		managedObjectModelURL:modelURL
		cloudFileSystem:cloudFileSystem];
	ensemble.delegate = self;

After the cloud file system is initialized, it is passed to the `CDEPersistentStoreEnsemble` initializer, together with the URL of a file containing the `NSManagedObjectModel`, and the path to the `NSPersistentStore`. An ensemble identifier is used to match stores across devices. It is important that this be the same for each store in the ensemble.

Once a `CDEPersistentStoreEnsemble` has been initialized, it can be _leeched_. This step typically only needs to take place once, to setup the ensemble and perform an initial import of data in the local persistent store. Once an ensemble has been leeched, it remains leeched even after a relaunch. The ensemble only gets _deleeched_ if you explicitly request it, or if a serious problem arises in the cloud file system, such as an account switch.

You can query an ensemble for whether it is already leeched using the `isLeeched` property, and initiate the leeching process with `leechPersistentStoreWithCompletion:`. (Attempting to leech an ensemble that is already leeched will cause an error.)

	if (!ensemble.isLeeched) {
	    [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
	        if (error) NSLog(@"Could not leech to ensemble: %@", error);
	    }];
	}

Because many tasks in Ensembles can involve networking or long operations, most methods are asynchronous and include a block callback which is called on completion of the task with an error parameter. If the error is `nil`, the task completed successfully. Methods should only be initiated on the main thread, and completion callbacks are sent to the main queue.

With the ensemble leeched, sync operations can be initiated using the `mergeWithCompletion:` method.

	[ensemble mergeWithCompletion:^(NSError *error) {
	    if (error) NSLog(@"Error merging: %@", error);
	}];	

A merge involves retrieving new changes for other devices from the cloud file system, integrating them in a background `NSManagedObjectContext`, merging with new local changes, and saving the result to the `NSPersistentStore`.

When a merge occurs, it is important to merge the changes into your main `NSManagedObjectContext`. You can do this in the `persistentStoreEnsemble:didSaveMergeChangesWithNotification:` delegate method. 

	- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification
	{
	    [managedObjectContext performBlock:^{
	        [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	    }];
	}

Note that this is invoked on the thread of the background context used for merging the changes. You need to make sure the `mergeChangesFromContextDidSaveNotification:` method is invoked on the thread corresponding to the main context.

There is one other delegate method that you will probably want to implement, in order to provide global identifiers for managed objects. 

	- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble 
		globalIdentifiersForManagedObjects:(NSArray *)objects
	{
	    return [objects valueForKeyPath:@"uniqueIdentifier"];
	} 

This method is also invoked on a background thread. Care should be taken to only access the objects passed on this thread.

It is not compulsory to provide global identifiers, but if you do, the framework will automatically ensure that no objects get duplicated due to multiple imports on different devices. If you don't provide global identifiers, the framework has no way to identify a new object, and will assign it a new unique identifier.

If you do decide to provide global identifiers, it is up to you how you generate them, and where you store them. A common choice is to add an extra attribute to entities in your data model, and set that to a uuid on insertion into the store.

#### Unit Tests

Unit tests are included for the Ensembles framework on each platform. To run the tests, open the Xcode workspace, choose the Ensembles Mac or Ensembles iOS target in the toolbar at the top, and select the menu item `Product > Test`.

