//
//  RegionalForecastType+CoreDataClass.h
//  MIO
//
//  Created by Ronny Libardo on 10/5/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "RegionalForecastTypeSlide.h"
extern NSString * const RegionalForecastDataArrived;

NS_ASSUME_NONNULL_BEGIN

@class APIClient;
@class APIResponse;
@class RegionalForecastTypeSlide;

extern NSString *const RegionalForecastsDataRetrievalTimestampKey;

@interface RegionalForecastType : RLMObject

@property (nullable, nonatomic, copy) NSString *animation;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *dateString;
@property (nullable, nonatomic, copy) NSString *englishName;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *identifier;
@property (nullable, nonatomic, copy) NSString *largeIcon;
@property (nullable, nonatomic, copy) NSString *mediumIcon;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *order;
@property (nullable, nonatomic, copy) NSString *scaleBar;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *spanishText;
@property (nullable, nonatomic, copy) NSString *englishText;
@property (nullable) RLMArray<RegionalForecastTypeSlide *><RegionalForecastTypeSlide> *slides;

+ (void)apiClient:(APIClient *)apiClient regionalForecastTypesWithCallback:(void (^)(APIResponse *response))callback;
+ (void)apiClient:(APIClient *)apiClient regionalForecastSlidesFor:(RegionalForecastType *)forecast with: (void (^)(APIResponse * _Nonnull))callback;
+ (void)saveRegionalForecastTypesDictionaryRepresentationToStorage:(NSArray *)regionalForecastTypes;
+ (void)saveRegionalForecastSlidesDictionaryRepresentationToStorage:(NSArray *)regionalForecastSlides with: (void (^) (NSArray *slides))completion;
@end

NS_ASSUME_NONNULL_END

#import "RegionalForecastType.h"
