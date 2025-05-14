// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LocalForecastRegion.h instead.

#import <CoreData/CoreData.h>

extern const struct LocalForecastRegionAttributes {
	__unsafe_unretained NSString *iconUrl;
	__unsafe_unretained NSString *mapUrl;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *regionId;
} LocalForecastRegionAttributes;

@interface LocalForecastRegionID : NSManagedObjectID {}
@end

@interface _LocalForecastRegion : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) LocalForecastRegionID* objectID;

@property (nonatomic, strong) NSString* iconUrl;

//- (BOOL)validateIconUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mapUrl;

//- (BOOL)validateMapUrl:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* regionId;

@property (atomic) int32_t regionIdValue;
- (int32_t)regionIdValue;
- (void)setRegionIdValue:(int32_t)value_;

//- (BOOL)validateRegionId:(id*)value_ error:(NSError**)error_;

@end

@interface _LocalForecastRegion (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveIconUrl;
- (void)setPrimitiveIconUrl:(NSString*)value;

- (NSString*)primitiveMapUrl;
- (void)setPrimitiveMapUrl:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveRegionId;
- (void)setPrimitiveRegionId:(NSNumber*)value;

- (int32_t)primitiveRegionIdValue;
- (void)setPrimitiveRegionIdValue:(int32_t)value_;

@end
