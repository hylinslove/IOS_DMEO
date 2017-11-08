//
//  MediaViewController.h
//  landExamination
//
//  Created by xianglong on 2017/10/12.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaViewController : UIViewController
@property (assign,nonatomic) NSInteger mediaType;
@property (strong, nonatomic) NSMutableArray *selectedMP4;//现场核查的视频
@property (strong, nonatomic) NSMutableArray *selectedPhotos;//现场核查选中照片
@property (strong, nonatomic) NSMutableArray *zzSelectedPhotos;//佐证选中照片--未使用

@end
