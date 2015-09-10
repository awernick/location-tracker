//
//  Geofence.h
//  waittimes-ios
//
//  Created by Victor Fernandez on 9/7/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bridge;

@interface Geofence : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * radius;
@property (nonatomic, retain) Bridge *bridge;

@end
