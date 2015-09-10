//
//  Bridge.h
//  waittimes-ios
//
//  Created by Victor Fernandez on 9/7/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Bridge : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * bridge_number;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * tracking;
@property (nonatomic, retain) NSSet *fences;
@end

@interface Bridge (CoreDataGeneratedAccessors)

- (void)addFencesObject:(NSManagedObject *)value;
- (void)removeFencesObject:(NSManagedObject *)value;
- (void)addFences:(NSSet *)values;
- (void)removeFences:(NSSet *)values;

@end
