//
//  LocalForecast.h
//  MIO
//
//  Created by Alonso Vega on 6/25/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Realm/Realm.h>
NS_ASSUME_NONNULL_BEGIN

@class APIResponse;
@class APIClient;

typedef NS_ENUM(NSInteger, LocalForecastSwellAndWind) {
    LocalForecastSwellAndWindRed1,
    LocalForecastSwellAndWindRed2,
    LocalForecastSwellAndWindYellow1,
    LocalForecastSwellAndWindYellow2,
    LocalForecastSwellAndWindGreen1,
    LocalForecastSwellAndWindGreen2,
    LocalForecastSwellAndWindLightBlue1,
    LocalForecastSwellAndWindLightBlue2,
    LocalForecastSwellAndWindNone
};

typedef NS_ENUM(NSInteger, LocalForecastBathingAndPorts) {
    LocalForecastBathingAndPortsPacificRed,
    LocalForecastBathingAndPortsPacificYellow,
    LocalForecastBathingAndPortsPacificYellow1,
    LocalForecastBathingAndPortsPacificGreen,
    LocalForecastBathingAndPortsPacificLightBlue1,
    LocalForecastBathingAndPortsPacificLightBlue2,
    LocalForecastBathingAndPortsCaribbeanRed1,
    LocalForecastBathingAndPortsCaribbeanRed2,
    LocalForecastBathingAndPortsCaribbeanYellow,
    LocalForecastBathingAndPortsCaribbeanGreen,
    LocalForecastBathingAndPortsCaribbeanLightBlue,
    LocalForecastBathingAndPortsNone,
};

extern NSString * const DirectionN;
extern NSString * const DirectionNNE;
extern NSString * const DirectionNE;
extern NSString * const DirectionENE;
extern NSString * const DirectionE;
extern NSString * const DirectionESE;
extern NSString * const DirectionSE;
extern NSString * const DirectionSSE;
extern NSString * const DirectionS;
extern NSString * const DirectionSSW;
extern NSString * const DirectionSW;
extern NSString * const DirectionWSW;
extern NSString * const DirectionW;
extern NSString * const DirectionWNW;
extern NSString * const DirectionNW;
extern NSString * const DirectionNNW;

typedef NS_ENUM(NSInteger, LocalForecastBathingAndPortsCaribbean) {
    
    LocalForecastBathingAndPortsCaribbeanNone
};

extern NSString *const LocalForecastsDataRetrievalTimestampKey;

@interface LocalForecast : RLMObject

@property (nonatomic) NSInteger currentlyDisplayedPage;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber<RLMInt> *identifier;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *waveDirection;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *waveHeight;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *waveHeightMax;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *wavePeriod;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *windBurst;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *windDirection;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *windSpeed;
@property (nullable, nonatomic, retain) NSNumber<RLMDouble> *localForecast;

+ (void)apiClient:(APIClient *)apiClient localForecastForRegion:(NSNumber *)regionIdentifier withCallback:(void (^)(APIResponse *response))callback;
+ (void)saveLocalForecastsDictionaryRepresentationToStorage:(NSArray *)data;
- (LocalForecastSwellAndWind)swellAndWind;
- (LocalForecastBathingAndPorts)bathingAndPortsForRegion:(NSString *)regionx;
- (NSString *)waveDirectionText;
- (NSString *)windDirectionText;


@end

NS_ASSUME_NONNULL_END

#import "LocalForecast.h"
