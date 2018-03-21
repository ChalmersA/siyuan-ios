//
//  DCOptionItem.m
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCOptionItem.h"

@implementation DCOptionItem

@end

@implementation DCOptionList

+ (instancetype)listWithItems:(NSArray *)items {
    DCOptionList *list = [[self alloc] init];
    list.items = items;
    return list;
}

+ (instancetype)loadPaySelection {
    NSArray *options = [DCOptionItem loadArrayFromPlist:@"paySelection"];
    DCOptionList *list = [[self alloc] init];
    list.items = [options copy];
    return list;
}

- (void)singleChooseIndex:(NSInteger)index {
    for (DCOptionItem *item in self.items) {
        item.chosen = NO;
        if ([self.items indexOfObject:item] == index) {
            item.chosen = YES;
        }
    }
}

- (void)singleChooseNo {
    for (DCOptionItem *item in self.items) {
        item.chosen = NO;
    }
}

- (DCOptionItem*)chosenItem {
    for (DCOptionItem *item in self.items) {
        if(item.chosen){
            return item;
        }
    }
    return nil;
}

- (NSInteger)chosenIndex {
    for (DCOptionItem *item in self.items) {
        if (item.chosen) {
            return [self.items indexOfObject:item];
        }
    }
    return NSNotFound;
}

@end

@implementation DCOptionCell (DCOptionItem)

- (void)configureForItem:(DCOptionItem *)item {
    self.optionLabel.text = item.text;
    self.optionImage.image = item.imageName?[UIImage imageNamed:item.imageName]:nil;
    self.markView.hidden = !item.chosen;
}

- (void)configureForPayItem:(DCOptionItem *)item {
    self.optionLabel.text = item.text;
    self.optionImage.image = item.imageName?[UIImage imageNamed:item.imageName]:nil;
    self.markView.hidden = YES;
    self.markButton.selected = item.chosen;
    self.descriptionLabel.text = item.describe_text;
}

@end
