//
//  TouristInfoFooter.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouristInfoFooter : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *ictInformation;
@property (weak, nonatomic) IBOutlet UILabel *ictWebsite;
@property (strong, nonatomic) IBOutlet UIView *content;

@end
