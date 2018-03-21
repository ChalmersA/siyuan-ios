//
//  HSSYClusterPopTableViewCell.h
//  Charging
//
//  Created by  Blade on 6/18/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCClusterPopTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelPoleName;

+ (NSString *)identifierForItem:(id)item;
@end
