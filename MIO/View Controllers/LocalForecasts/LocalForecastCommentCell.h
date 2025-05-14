//
//  LocalForecastCommentCell.h
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 16/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentsSlider;

@interface LocalForecastCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CommentsSlider *morningCommentsSlider;
@property (weak, nonatomic) IBOutlet CommentsSlider *afternoonCommentsSlider;
@property (weak, nonatomic) IBOutlet UILabel *morningDisclaimer;
@property (weak, nonatomic) IBOutlet UILabel *afternoonDisclaimer;

@end
