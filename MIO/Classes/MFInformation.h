//
//  NSObject+MFInformation.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFImage.h"
@import Firebase;

@interface MFInformation : NSObject

@property(nonatomic) NSString *key;
@property(nonatomic) NSNumber *isActive;
@property(nonatomic) NSNumber *order;
@property(nonatomic) NSString *descriptionText;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *link;
@property(nonatomic) NSString *image;
@property(nonatomic) MFImage *mfImage;

-(id) initWith:(FIRDocumentSnapshot *) snapshot;
-(void) setMfImage:(MFImage *)mfImages;
@end
