//
//  ImgPickCollectionViewCell.h
//  landExamination
//
//  Created by das on 2017/1/3.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgPickCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) id asset;
@property (nonatomic, strong) NSString *videoPath;

//- (UIView *)snapshotView;

- (void)drawUI;

@end
