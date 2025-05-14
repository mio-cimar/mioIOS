//
//  RegionalForecastTypeSlide+CoreDataClass.h
//  
//
//  Created by Ronny Libardo Bustos Jiménez on 7/9/17.
//
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
//#import "RegionalForecastType+CoreDataClass.h"
@class RegionalForecastType;

NS_ASSUME_NONNULL_BEGIN

@interface RegionalForecastTypeSlide : RLMObject

@property (nullable, nonatomic, copy) NSString *image;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *identifier;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *order;
@property (nullable, nonatomic, retain) RegionalForecastType *regionalForecastType;

@end

RLM_ARRAY_TYPE(RegionalForecastTypeSlide)
NS_ASSUME_NONNULL_END

//#import "RegionalForecastTypeSlide+CoreDataProperties.h"
