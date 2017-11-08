//
//  CALayer+UIColor.m
//  landExamination
//
//  Created by xianglong on 2017/9/22.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "CALayer+UIColor.h"


@implementation CALayer (UIColor)
- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}
@end
