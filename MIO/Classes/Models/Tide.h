//
//  Tide+CoreDataClass.h
//  MIO
//
//  Created by Ronny Libardo on 9/29/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreData/CoreData.h>
#import <Realm/Realm.h>
NS_ASSUME_NONNULL_BEGIN

@interface Tide : RLMObject

@property (nullable, nonatomic, copy) NSNumber<RLMInt> *tideRegion;
@property (nullable, nonatomic, copy) NSNumber<RLMDouble> *tideHeight;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *moon;
@property (nullable, nonatomic, copy) NSNumber<RLMBool> *isHighTide;
@property (nullable, nonatomic, copy) NSNumber<RLMInt> *identifier;
@property (nullable, nonatomic, copy) NSString *dateString;
@property (nullable, nonatomic, copy) NSDate *date;

@end

NS_ASSUME_NONNULL_END

#import "Tide.h"
