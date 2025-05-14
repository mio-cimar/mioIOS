//
//  IntroPageViewcontroller.m
//  MIO
//
//  Created by Ronny Libardo on 10/13/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "IntroPageViewcontroller.h"

@interface IntroPageViewcontroller ()

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation IntroPageViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text        = self.titleContent;
    self.descriptionLabel.text  = self.descriptionContent;
    self.image.image            = [UIImage imageNamed:self.imageIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
