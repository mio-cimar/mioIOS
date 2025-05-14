//
//  NSObject+MFInformation.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "MFInformation.h"

@implementation MFInformation
- (id)initWith:(FIRDocumentSnapshot *)snapshot {
    self = [super init];
    if (self) {
            self.key = snapshot.documentID;
        NSDictionary *data = snapshot.data;
        MIOSettingsLanguages selectedLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
        if(selectedLanguage == MIOSettingsLanguageSpanish) {
            self.title = data[@"titleES"];
            self.descriptionText = data[@"descriptionTextES"];
        } else {
            self.title = data[@"titleEN"];
            self.descriptionText = data[@"descriptionTextEN"];
        }
        self.isActive = data[@"isActive"];
        self.link = data[@"link"];
        self.order = data[@"order"];
        FIRDocumentReference *imageData = data[@"images"];

        if(imageData != nil && [imageData isKindOfClass:[FIRDocumentReference class]] == YES ) {
            self.image = imageData.documentID;
        } else {
            self.image = @"";
        }
        self.mfImage = nil;
    }
    return self;
}
@end
