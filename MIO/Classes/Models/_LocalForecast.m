// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LocalForecast.m instead.

#import "_LocalForecast.h"

const struct LocalForecastAttributes LocalForecastAttributes = {
	.date = @"date",
	.forecastId = @"forecastId",
	.waveDirection = @"waveDirection",
	.waveHeight = @"waveHeight",
	.waveHeightMax = @"waveHeightMax",
	.wavePeriod = @"wavePeriod",
	.windBurst = @"windBurst",
	.windDirection = @"windDirection",
	.windSpeed = @"windSpeed",
};

@implementation LocalForecastID
@end

@implementation _LocalForecast

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LocalForecast" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LocalForecast";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LocalForecast" inManagedObjectContext:moc_];
}

- (LocalForecastID*)objectID {
	return (LocalForecastID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"forecastIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"forecastId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"waveDirectionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"waveDirection"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"waveHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"waveHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"waveHeightMaxValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"waveHeightMax"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"wavePeriodValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"wavePeriod"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"windBurstValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"windBurst"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"windDirectionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"windDirection"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"windSpeedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"windSpeed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic date;

@dynamic forecastId;

- (int32_t)forecastIdValue {
	NSNumber *result = [self forecastId];
	return [result intValue];
}

- (void)setForecastIdValue:(int32_t)value_ {
	[self setForecastId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveForecastIdValue {
	NSNumber *result = [self primitiveForecastId];
	return [result intValue];
}

- (void)setPrimitiveForecastIdValue:(int32_t)value_ {
	[self setPrimitiveForecastId:[NSNumber numberWithInt:value_]];
}

@dynamic waveDirection;

- (double)waveDirectionValue {
	NSNumber *result = [self waveDirection];
	return [result doubleValue];
}

- (void)setWaveDirectionValue:(double)value_ {
	[self setWaveDirection:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWaveDirectionValue {
	NSNumber *result = [self primitiveWaveDirection];
	return [result doubleValue];
}

- (void)setPrimitiveWaveDirectionValue:(double)value_ {
	[self setPrimitiveWaveDirection:[NSNumber numberWithDouble:value_]];
}

@dynamic waveHeight;

- (double)waveHeightValue {
	NSNumber *result = [self waveHeight];
	return [result doubleValue];
}

- (void)setWaveHeightValue:(double)value_ {
	[self setWaveHeight:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWaveHeightValue {
	NSNumber *result = [self primitiveWaveHeight];
	return [result doubleValue];
}

- (void)setPrimitiveWaveHeightValue:(double)value_ {
	[self setPrimitiveWaveHeight:[NSNumber numberWithDouble:value_]];
}

@dynamic waveHeightMax;

- (BOOL)waveHeightMaxValue {
	NSNumber *result = [self waveHeightMax];
	return [result boolValue];
}

- (void)setWaveHeightMaxValue:(BOOL)value_ {
	[self setWaveHeightMax:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveWaveHeightMaxValue {
	NSNumber *result = [self primitiveWaveHeightMax];
	return [result boolValue];
}

- (void)setPrimitiveWaveHeightMaxValue:(BOOL)value_ {
	[self setPrimitiveWaveHeightMax:[NSNumber numberWithBool:value_]];
}

@dynamic wavePeriod;

- (double)wavePeriodValue {
	NSNumber *result = [self wavePeriod];
	return [result doubleValue];
}

- (void)setWavePeriodValue:(double)value_ {
	[self setWavePeriod:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWavePeriodValue {
	NSNumber *result = [self primitiveWavePeriod];
	return [result doubleValue];
}

- (void)setPrimitiveWavePeriodValue:(double)value_ {
	[self setPrimitiveWavePeriod:[NSNumber numberWithDouble:value_]];
}

@dynamic windBurst;

- (double)windBurstValue {
	NSNumber *result = [self windBurst];
	return [result doubleValue];
}

- (void)setWindBurstValue:(double)value_ {
	[self setWindBurst:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWindBurstValue {
	NSNumber *result = [self primitiveWindBurst];
	return [result doubleValue];
}

- (void)setPrimitiveWindBurstValue:(double)value_ {
	[self setPrimitiveWindBurst:[NSNumber numberWithDouble:value_]];
}

@dynamic windDirection;

- (double)windDirectionValue {
	NSNumber *result = [self windDirection];
	return [result doubleValue];
}

- (void)setWindDirectionValue:(double)value_ {
	[self setWindDirection:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWindDirectionValue {
	NSNumber *result = [self primitiveWindDirection];
	return [result doubleValue];
}

- (void)setPrimitiveWindDirectionValue:(double)value_ {
	[self setPrimitiveWindDirection:[NSNumber numberWithDouble:value_]];
}

@dynamic windSpeed;

- (double)windSpeedValue {
	NSNumber *result = [self windSpeed];
	return [result doubleValue];
}

- (void)setWindSpeedValue:(double)value_ {
	[self setWindSpeed:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveWindSpeedValue {
	NSNumber *result = [self primitiveWindSpeed];
	return [result doubleValue];
}

- (void)setPrimitiveWindSpeedValue:(double)value_ {
	[self setPrimitiveWindSpeed:[NSNumber numberWithDouble:value_]];
}

@end

