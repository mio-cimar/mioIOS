// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LocalForecastRegion.m instead.

#import "_LocalForecastRegion.h"

const struct LocalForecastRegionAttributes LocalForecastRegionAttributes = {
	.iconUrl = @"iconUrl",
	.mapUrl = @"mapUrl",
	.name = @"name",
	.regionId = @"regionId",
};

@implementation LocalForecastRegionID
@end

@implementation _LocalForecastRegion

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LocalForecastRegion" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LocalForecastRegion";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LocalForecastRegion" inManagedObjectContext:moc_];
}

- (LocalForecastRegionID*)objectID {
	return (LocalForecastRegionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"regionIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"regionId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic iconUrl;

@dynamic mapUrl;

@dynamic name;

@dynamic regionId;

- (int32_t)regionIdValue {
	NSNumber *result = [self regionId];
	return [result intValue];
}

- (void)setRegionIdValue:(int32_t)value_ {
	[self setRegionId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveRegionIdValue {
	NSNumber *result = [self primitiveRegionId];
	return [result intValue];
}

- (void)setPrimitiveRegionIdValue:(int32_t)value_ {
	[self setPrimitiveRegionId:[NSNumber numberWithInt:value_]];
}

@end

