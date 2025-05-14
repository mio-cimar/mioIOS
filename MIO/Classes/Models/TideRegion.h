//
//  TideRegion+CoreDataClass.h
//  MIO
//
//  Created by Ronny Libardo on 9/29/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@class APIClient;
@class APIResponse;

extern NSString *const TideEntryDataArrived;
extern NSString *const TideRegionsDataRetrievalTimestampKey;

@interface TideRegion : RLMObject

@property (nullable, nonatomic, copy) NSString *englishName;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *identifier;
@property (nullable, nonatomic, copy) NSString *largeIcon;
@property (nullable, nonatomic, copy) NSString *mediumIcon;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *order;
@property (nullable, nonatomic, copy) NSString *smallIcon;
@property (nonatomic) BOOL isPerformingFetch;

+ (void)apiClient:(APIClient *)apiClient tideRegionsWithCallback:(void (^)(APIResponse *response))callback;
- (void)apiClient:(APIClient *)apiClient tideEntriesFromDate:(NSDate *)from toDate:(NSDate *)to withCallback:(void (^)(APIResponse *response))callback;
+ (void)saveTideRegionsDictionaryRepresentationToStorage:(NSArray *)data;
+ (void)saveTideEntriesDictionaryRepresentationToStorage:(NSArray *)data;
+ (void)saveTideEntriesSearchResultsDictionaryRepresentationToStorage:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END

#import "TideRegion.h"
