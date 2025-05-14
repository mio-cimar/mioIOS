//
//  NSObject+MFImage.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;

@interface MFImage : NSObject

@property(nonatomic) NSString *key;
@property(nonatomic) NSNumber *alternativeText;
@property(nonatomic) NSString *name;
@property(nonatomic) NSString *url;

-(id) initWith:(FIRDocumentSnapshot *) snapshot;

@end
