//
//  FriendInfoTableViewCell.m
//  Time-Line
//
//  Created by IF on 14/12/6.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "FriendInfoTableViewCell.h"

@implementation FriendInfoTableViewCell

- (void)awakeFromNib {
	_userHead.layer.cornerRadius = _userHead.frame.size.width / 2;
	_userHead.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

@end
