//
//  IntroPageViewcontroller.h
//  MIO
//
//  Created by Ronny Libardo on 10/13/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPageViewcontroller : UIViewController

@property (strong, nonatomic) NSString *imageIdentifier;
@property (strong, nonatomic) NSString *titleContent;
@property (strong, nonatomic) NSString *descriptionContent;
@property (assign, nonatomic) NSInteger index;

@end
