//
//  LocalForecastRegion+CoreDataProperties.h
//  MIO
//
//  Created by Ronny Libardo on 8/31/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LocalForecastRegion.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalForecastRegion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *regionId;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *englishName;
@property (nullable, nonatomic, retain) NSString *largeIcon;
@property (nullable, nonatomic, retain) NSString *mediumIcon;
@property (nullable, nonatomic, retain) NSString *mediumMapURL;
@property (nullable, nonatomic, retain) NSString *largeMapURL;
@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSNumber *identifier;

@end

NS_ASSUME_NONNULL_END
