//
//  ZQTextView.m
//  landExamination
//
//  Created by das on 2017/1/21.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "ZQTextView.h"

@interface ZQTextView ()

@property (nonatomic,weak) UILabel *placeholderLabel;

@end

@implementation ZQTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//-(instancetype)initWithFrame:(CGRect)frame{
//    
//    self = [super initWithFrame:frame];
//    
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        UILabel *placeholderLabel = [[UILabel alloc]init];
//        placeholderLabel.backgroundColor = [UIColor clearColor];
//        placeholderLabel.numberOfLines = 0;
//        [self addSubview:placeholderLabel];
//        self.placeholderLabel = placeholderLabel;
//        self.myPlaceHolderColor = [UIColor lightGrayColor];
//        self.font = [UIFont systemFontOfSize:15];
//        self.placeholderLabel.text = @"内容需不低于10个字";
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
//        
//    }
//    return self;
//    
//}

- (void)awakeFromNib{
    [super awakeFromNib];
    
//    self.backgroundColor = [UIColor clearColor];
    UILabel *placeholderLabel = [[UILabel alloc]init];
    placeholderLabel.backgroundColor = [UIColor clearColor];
    placeholderLabel.numberOfLines = 0;
    [self addSubview:placeholderLabel];
    self.placeholderLabel = placeholderLabel;
    self.myPlaceHolderColor = [UIColor lightGrayColor];
    self.font = [UIFont systemFontOfSize:12];
    self.placeholderLabel.text = @"内容需不低于10个字";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
    
    
}



- (void)textDidChange{
    
    self.placeholderLabel.hidden = self.hasText;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self textDidChange];
    
    self.placeholderLabel.frame = CGRectMake(8, 5, 160, 22);
    
}

- (void)setMyPlaceholder:(NSString *)myPlaceholder{
    
    _myPlaceholder = [myPlaceholder copy];
    self.placeholderLabel.text = myPlaceholder;
    
}

- (void)setText:(NSString *)text{
    [super setText:text];
    
    [self textDidChange];
}
- (void)setMyPlaceHolderColor:(UIColor *)myPlaceHolderColor{
    _myPlaceHolderColor = myPlaceHolderColor;
    self.placeholderLabel.textColor = myPlaceHolderColor;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:UITextViewTextDidChangeNotification];
    
}

@end
