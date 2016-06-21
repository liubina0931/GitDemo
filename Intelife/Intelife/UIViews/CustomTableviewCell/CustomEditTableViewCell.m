//
//  CustomEditTableViewCell.m
//  Intelife
//
//  Created by LiuBin on 4/25/16.
//  Copyright (c) 2016 richdataco. All rights reserved.
//

#import "CustomEditTableViewCell.h"

@implementation CustomEditTableViewCell
@synthesize labelName = _labelName, btnEdit = _btnEdit, btnDelete = _btnDelete;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
