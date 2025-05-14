//
//  TouristInfoHeader.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "TouristInfoHeader.h"
#import "TouristInfoCollectionViewCell.h"
#import "PBDCarouselCollectionViewLayout.h"
#import <Haneke/Haneke.h>

@interface TouristInfoHeader() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray<MFInformation *> *touristInfo;
@end

@implementation TouristInfoHeader

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TouristInfoHeader class]) owner:self options:nil];
        CGRect frame = self.frame;
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TouristInfoHeader class]) owner:self options:nil];
        CGRect frame = self.frame;
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
        [self setup];
    }
    return self;
}

-(void) setup {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([TouristInfoCollectionViewCell class]) bundle:nil];
    self.touristInfo = [[NSArray alloc] init];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"TouristInfoCell"];
    PBDCarouselCollectionViewLayout *layout = [[PBDCarouselCollectionViewLayout alloc] init];
    layout.itemSize = CGSizeMake(335, 319);
    layout.interItemSpace = 10;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.collectionViewLayout = layout;
     self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.layer.masksToBounds = NO;
    self.layer.masksToBounds = NO;
    self.content.layer.masksToBounds = NO;
}

-(void) populateWith:(NSArray<MFInformation *> *) information {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order"
                                                 ascending:YES];
    self.touristInfo = [information sortedArrayUsingDescriptors:@[sortDescriptor]];
    PBDCarouselCollectionViewLayout *layout = (PBDCarouselCollectionViewLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.frame.size.width -32 , 319);
    [layout invalidateLayout];
    [self.collectionView reloadData];
    [layout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.touristInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MFInformation *info = self.touristInfo[indexPath.item];
    TouristInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TouristInfoCell" forIndexPath:indexPath];
    cell.title.text = info.title;
    if(info.link && [info.link length] != 0) {
        NSURL *youtubeUrl = [NSURL URLWithString:info.link];
        NSURLComponents *components = [NSURLComponents componentsWithString:info.link];
        if(youtubeUrl) {
            NSString *thumbnailUrl = [NSString stringWithFormat: @"%@/%@/%@",@"https://img.youtube.com/vi", components.queryItems.firstObject.value , @"mqdefault.jpg"];
            [cell.imageView hnk_setImageFromURL:[NSURL URLWithString:thumbnailUrl]];
        }
    }else if(info.mfImage) {
        [cell.imageView hnk_setImageFromURL:[NSURL URLWithString:info.mfImage.url]];
    }
    cell.contentView.layer.masksToBounds = NO;
    cell.contentView.layer.cornerRadius = 14;
    cell.contentView.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    cell.contentView.layer.shadowOffset = CGSizeMake(0, 16);
    cell.contentView.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.16] CGColor];
    cell.contentView.layer.shadowOpacity = 1;
    cell.contentView.layer.shadowRadius = 16;
    cell.layer.masksToBounds = NO;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MFInformation *info = self.touristInfo[indexPath.item];
    [self.delegate itemSelected:info];
}

@end
