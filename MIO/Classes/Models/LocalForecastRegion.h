//
//  LocalForecastRegion.h
//  MIO
//
//  Created by Alonso Vega on 6/25/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import <Realm/Realm.h>

extern NSString *const LocalForecastDataArrived;
extern NSString *const LocalForecastDataRetrievalTimestampKey;

@class LocalForecast;
@class APIClient;
@class APIResponse;

NS_ASSUME_NONNULL_BEGIN

@interface LocalForecastRegion : RLMObject
@property NSString *comment;
@property NSString *englishName;
@property NSNumber<RLMInt> *identifier;
@property NSString *largeIcon;
@property NSString *largeMapURL;
@property NSString *mediumIcon;
@property NSString *mediumMapURL;
@property NSString *name;
@property NSNumber<RLMInt> *order;
@property NSNumber<RLMInt> *regionId;
@property NSString *saltiness;
@property NSString *temperature;
@property NSString *wind;
@property NSString *swell;

@property (nonatomic) BOOL isPerformingFetch;

+ (void)apiClient:(APIClient *)apiClient localForecastRegionsWithCallback:(void (^)(APIResponse *response))callback;
- (void)apiClient:(APIClient *)apiClient localForecastWithCallback:(void (^)(APIResponse *response))callback;
+ (void)saveLocalForecastRegionsDictionaryRepresentationToStorage:(NSArray *)data;
+ (void)saveLocalForecastsDictionaryRepresentationToStorage:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END

//#import "LocalForecastRegion+CoreDataProperties.h"
