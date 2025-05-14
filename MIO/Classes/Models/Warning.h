//
//  Warning.h
//  MIO
//
//  Created by Ronny Libardo on 9/14/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Realm/Realm.h>
@class APIClient;
@class APIResponse;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kNotificationArrivedNotification;
extern NSString *const WarningsDataRetrievalTimestampKey;

@interface Warning : RLMObject

@property (nullable, nonatomic, retain) NSNumber<RLMInt> *identifier;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *subtitle;
@property (nullable, nonatomic, retain) NSNumber<RLMInt> *level;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSNumber<RLMInt> *order;

+ (void)apiClient:(APIClient *)apiClient warningsWithCallback:(void (^)(APIResponse *response))callback;
+ (void)saveWarningsDictionaryRepresentationToStorage:(NSArray *)data ;

@end

NS_ASSUME_NONNULL_END

//#import "Warning+CoreDataProperties.h"
