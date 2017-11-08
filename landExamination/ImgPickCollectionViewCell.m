//
//  ImgPickCollectionViewCell.m
//  landExamination
//
//  Created by das on 2017/1/3.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "ImgPickCollectionViewCell.h"
#import "UIView+Layout.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController/TZImagePickerController.h"

@implementation ImgPickCollectionViewCell


- (void)drawUI{
    self.backgroundColor = [UIColor whiteColor];
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:_imageView];
    self.clipsToBounds = YES;
    
    _videoImageView = [[UIImageView alloc] init];
    _videoImageView.image = [UIImage imageNamedFromMyBundle:@"MMVideoPreviewPlay"];
    _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    _videoImageView.hidden = YES;
    [self addSubview:_videoImageView];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
    
    _deleteBtn.frame = CGRectMake(self.tz_width - 48, 0, 48, 48);
    _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -10);
    _deleteBtn.alpha = 0.6;
    [self addSubview:_deleteBtn];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    CGFloat width = self.tz_width / 3.0;
    _videoImageView.frame = CGRectMake(width, width, width, width);
    
    
}

- (void)setVideoPath:(NSString *)videoPath{
    _videoPath = videoPath;
    _videoImageView.hidden = NO;
    
}

- (void)setRow:(NSInteger)row {
    _row = row;
    _deleteBtn.tag = row;
}

@end
