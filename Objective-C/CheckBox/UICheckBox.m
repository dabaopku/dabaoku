//
//  UICheckBox.m
//  Sayhibox
//
//  Created by dabao on 12-3-18.
//  Copyright 2012年 比邻时空. All rights reserved.
//

#import "UICheckBox.h"


@implementation UICheckBox

-(void) create
{
    [self setBackgroundImage:[UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self create];
    }
    return self;
}

-(void) awakeFromNib
{
    [self create];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected=!self.selected;
    [super touchesEnded:touches withEvent:event];
}

@end
