// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LocalForecast.h instead.

#import <CoreData/CoreData.h>

extern const struct LocalForecastAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *forecastId;
	__unsafe_unretained NSString *waveDirection;
	__unsafe_unretained NSString *waveHeight;
	__unsafe_unretained NSString *waveHeightMax;
	__unsafe_unretained NSString *wavePeriod;
	__unsafe_unretained NSString *windBurst;
	__unsafe_unretained NSString *windDirection;
	__unsafe_unretained NSString *windSpeed;
} LocalForecastAttributes;

@interface LocalForecastID : NSManagedObjectID {}
@end

@interface _LocalForecast : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) LocalForecastID* objectID;

@property (nonatomic, strong) NSDate* date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* forecastId;

@property (atomic) int32_t forecastIdValue;
- (int32_t)forecastIdValue;
- (void)setForecastIdValue:(int32_t)value_;

//- (BOOL)validateForecastId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* waveDirection;

@property (atomic) double waveDirectionValue;
- (double)waveDirectionValue;
- (void)setWaveDirectionValue:(double)value_;

//- (BOOL)validateWaveDirection:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* waveHeight;

@property (atomic) double waveHeightValue;
- (double)waveHeightValue;
- (void)setWaveHeightValue:(double)value_;

//- (BOOL)validateWaveHeight:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* waveHeightMax;

@property (atomic) BOOL waveHeightMaxValue;
- (BOOL)waveHeightMaxValue;
- (void)setWaveHeightMaxValue:(BOOL)value_;

//- (BOOL)validateWaveHeightMax:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* wavePeriod;

@property (atomic) double wavePeriodValue;
- (double)wavePeriodValue;
- (void)setWavePeriodValue:(double)value_;

//- (BOOL)validateWavePeriod:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* windBurst;

@property (atomic) double windBurstValue;
- (double)windBurstValue;
- (void)setWindBurstValue:(double)value_;

//- (BOOL)validateWindBurst:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* windDirection;

@property (atomic) double windDirectionValue;
- (double)windDirectionValue;
- (void)setWindDirectionValue:(double)value_;

//- (BOOL)validateWindDirection:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* windSpeed;

@property (atomic) double windSpeedValue;
- (double)windSpeedValue;
- (void)setWindSpeedValue:(double)value_;

//- (BOOL)validateWindSpeed:(id*)value_ error:(NSError**)error_;

@end

@interface _LocalForecast (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;

- (NSNumber*)primitiveForecastId;
- (void)setPrimitiveForecastId:(NSNumber*)value;

- (int32_t)primitiveForecastIdValue;
- (void)setPrimitiveForecastIdValue:(int32_t)value_;

- (NSNumber*)primitiveWaveDirection;
- (void)setPrimitiveWaveDirection:(NSNumber*)value;

- (double)primitiveWaveDirectionValue;
- (void)setPrimitiveWaveDirectionValue:(double)value_;

- (NSNumber*)primitiveWaveHeight;
- (void)setPrimitiveWaveHeight:(NSNumber*)value;

- (double)primitiveWaveHeightValue;
- (void)setPrimitiveWaveHeightValue:(double)value_;

- (NSNumber*)primitiveWaveHeightMax;
- (void)setPrimitiveWaveHeightMax:(NSNumber*)value;

- (BOOL)primitiveWaveHeightMaxValue;
- (void)setPrimitiveWaveHeightMaxValue:(BOOL)value_;

- (NSNumber*)primitiveWavePeriod;
- (void)setPrimitiveWavePeriod:(NSNumber*)value;

- (double)primitiveWavePeriodValue;
- (void)setPrimitiveWavePeriodValue:(double)value_;

- (NSNumber*)primitiveWindBurst;
- (void)setPrimitiveWindBurst:(NSNumber*)value;

- (double)primitiveWindBurstValue;
- (void)setPrimitiveWindBurstValue:(double)value_;

- (NSNumber*)primitiveWindDirection;
- (void)setPrimitiveWindDirection:(NSNumber*)value;

- (double)primitiveWindDirectionValue;
- (void)setPrimitiveWindDirectionValue:(double)value_;

- (NSNumber*)primitiveWindSpeed;
- (void)setPrimitiveWindSpeed:(NSNumber*)value;

- (double)primitiveWindSpeedValue;
- (void)setPrimitiveWindSpeedValue:(double)value_;

@end
