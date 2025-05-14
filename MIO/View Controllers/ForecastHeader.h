//
//  ForecastHeader.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/8/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastHeader : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *divider;

@end
