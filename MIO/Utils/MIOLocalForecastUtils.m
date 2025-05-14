//
//  MIOLocalForecastUtils.m
//  MIO
//
//  Created by Alonso Vega on 7/8/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOLocalForecastUtils.h"

@implementation MIOLocalForecastUtils

+ (NSString *)imageNameForWaveWithHeight: (NSNumber*)heigth {
    if (heigth.doubleValue < 1){
        return @"ola-verde";
    }
    if (heigth.doubleValue >= 1 && heigth.doubleValue < 2){
        return @"ola-amarillo";
    }
    if (heigth.doubleValue >= 2 && heigth.doubleValue < 3){
        return @"ola-naranja";
    }
    if (heigth.doubleValue >= 3){
        return @"ola-rojo";
    }
    return nil;
}

+ (NSString *)imageNameForWindWithSpeed:(NSNumber *)speed {
    if (speed.doubleValue < 22) {
        return @"viento-verde";
    }
    if (speed.doubleValue >= 22 && speed.doubleValue < 30) {
        return @"viento-amarillo";
    }
    if (speed.doubleValue >= 30 && speed.doubleValue < 40) {
        return @"viento-naranja";
    }
    if (speed.doubleValue >= 40) {
        return @"viento-rojo";
    }
    return nil;
}

@end
