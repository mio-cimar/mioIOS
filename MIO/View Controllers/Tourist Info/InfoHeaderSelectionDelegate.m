//
//  InfoHeaderSelectionDelegate.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/12/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFInformation.h"

@protocol InfoHeaderSelectionDelegate
-(void) itemSelected:(MFInformation *) information;
@end
