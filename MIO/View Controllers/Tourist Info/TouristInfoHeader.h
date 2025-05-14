//
//  TouristInfoHeader.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFInformation.h"
@protocol InfoHeaderSelectionDelegate
-(void) itemSelected:(MFInformation *) information;
@end

@interface TouristInfoHeader : UITableViewHeaderFooterView
@property (strong, nonatomic) IBOutlet UIView *content;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak) id <InfoHeaderSelectionDelegate> delegate;
-(void) populateWith:(NSArray<MFInformation *> *) information;
@end
