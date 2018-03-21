//
//  HSSYPeriodSpliterViewController.m
//  CollectionViewTest
//
//  Created by  Blade on 4/24/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCPeriodSpliterView.h"
#import "DCPeriodSpliteCollectionViewCell.h"
#import "FilterHeaderView.h"
#import "DCSharePeriod.h"

const static float kHSSYPeriodSpliterViewHeaderHeight  = 30;
const static float kHSSYPeriodSpliterViewEdgeTop  = 0;
const static float kHSSYPeriodSpliterViewEdgeLeft  = 0;
const static float kHSSYPeriodSpliterViewEdgeBottom  = 0;
const static float kHSSYPeriodSpliterViewEdgeRight  = 0;
const static float kHSSYPeriodSpliterViewInterItemSpacing  = 1;
const static float kHSSYPeriodSpliterViewLineSpacing  = 1;

const static float kHSSYPeriodSpliterViewColumnCount  = 2;
const static float kHSSYPeriodSpliterViewCellHeight  = 50;
const static NSInteger COUNT_VALID_PARTIAL = 2; //显示数量


static NSString * const kHeaderViewCellIdentifier = @"HeaderViewCellIdentifier";

@interface DCPeriodSpliterView ()
@property (nonatomic, retain) DCShareDate* shareDate;
@property (nonatomic, retain) NSArray* allSpliteData;
@property (nonatomic, retain) NSMutableArray* validSpliteDataIndexPathArr; // 有效时间
@property (nonatomic, retain) NSArray* showedDataArr; // 用于展示的数组
@property (nonatomic, retain) NSArray* choosenDateArr;
@end

@implementation DCPeriodSpliterView
#pragma mark - Init

- (void)initView
{
    [self.collectionView registerClass:[FilterHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier];
    [self.collectionView setAllowsMultipleSelection:NO];
//    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    collectionViewLayout.headerReferenceSize = CGSizeMake(375, 50);
//    
//    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20,0,0,0);
    
    if (!self.validSpliteDataIndexPathArr) {
        self.validSpliteDataIndexPathArr = [NSMutableArray array];
    }
    
    [self.btnMore addTarget:self action:@selector(btnMoreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageViewMore setImage:[UIImage imageNamed:@"pdetail_btn_more_arrow"]];
    UIColor *COL = [UIColor paletteFontBlack];
    COL = [UIColor paletteOrangeColor];
    [self setDisplayMode:HSSYSplitePeriodDisplayModeValidPartial];
}

#pragma mark - Action
-(void)btnMoreClick:(id)sender {
    [self setDisplayMode:(self.displayMode == HSSYSplitePeriodDisplayModeValidAll ? HSSYSplitePeriodDisplayModeValidPartial : HSSYSplitePeriodDisplayModeValidAll)];
}

- (void) setDisplayMode:(HSSYSplitePeriodDisplayMode)displayMode {
    _displayMode = displayMode;
//    if (self.displayMode == HSSYSplitePeriodDisplayModeAll) {
//        self.showedDataArr = self.allSpliteData;
//    }
//    else if (self.displayMode == HSSYSplitePeriodDisplayModeValid) {
//        self.showedDataArr = self.validSpliteDataArr;
//    }
    
    [self updateCollectionView];
    [self updateMoreBtnView];
}


- (void) setupPeriodSpliterViewWithData:(DCShareDate*) shareDate{
    [self.labelHint setHidden:(shareDate!=nil)];
    self.shareDate = shareDate;
    self.allSpliteData = self.shareDate.sharePeriodObjArr;
    self.choosenDateArr = nil;
    
//    // Find out all available time and insert them into a HSSYSharePeriod object
//    HSSYSharePeriod *allValidSharePeriod = [[HSSYSharePeriod alloc] initWithDict:nil dateOfShareDay:self.shareDate.dateOfShare];
//    for (HSSYSharePeriod *aSharePeriod in self.shareDate.sharePeriodObjArr) {
//        for (NSDate* time in aSharePeriod.arrFreeSplitedPeriod) {
//            if(allValidSharePeriod.arrAllSplitedPeriod.count < 4) {
//                [allValidSharePeriod.arrFreeSplitedPeriod addObject:time];
//                [allValidSharePeriod.arrAllSplitedPeriod addObject:time];
//            }
//        }
//    }
//    self.validSpliteDataArr = [NSArray arrayWithObject:allValidSharePeriod];
//    
//    // Find out all available time and insert them into a HSSYSharePeriod object
//    NSMutableArray *periodArr = [NSMutableArray array];
//    NSInteger showCount = 0;
//    for (HSSYSharePeriod *aSharePeriod in self.shareDate.sharePeriodObjArr) {
//            HSSYSharePeriod *allValidSharePeriod = [[HSSYSharePeriod alloc] initWithDict:nil dateOfShareDay:self.shareDate.dateOfShare];
//            if(showCount < 4) {
//                showCount++;
//                [periodArr addObject:allValidSharePeriod];
//            }
//    }
//    
//    self.validSpliteDataArr = [periodArr copy];
//    
//    self.showedDataArr = self.allSpliteData;
//    
//    if (HSSYSplitePeriodDisplayModeAll == self.displayMode) {
//        self.showedDataArr = self.allSpliteData;
//    }
//    else if (HSSYSplitePeriodDisplayModeValid == self.displayMode) {
//        self.showedDataArr = self.validSpliteDataArr;
//    }
    
    self.showedDataArr = self.allSpliteData;
    
    [self.validSpliteDataIndexPathArr removeAllObjects];
    
    DCSharePeriod *aSharePeriod = nil;
    for (int section=0; section <  [self.showedDataArr count]; section++) {
        aSharePeriod = [self.showedDataArr objectAtIndex:section];
        for (int row=0; (row <  [aSharePeriod.arrAllSplitedPeriod count]); row++) {
            if ([aSharePeriod.arrFreeSplitedPeriod containsObject:[aSharePeriod.arrAllSplitedPeriod objectAtIndex:row]]) {
                [self.validSpliteDataIndexPathArr addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
    }
    
    
    [self updateCollectionView];
}

- (void)updateCollectionView {
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded]; // force reload finish
    
    // update constaints of height
    self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height;
    
    // animate
//    [UIView animateWithDuration:0.1
//                     animations:^{
//                         [self.superview layoutIfNeeded];
//                     } completion:^(BOOL finished){
//                         //
//                     }];
    [self.superview setNeedsUpdateConstraints];
    [self.superview layoutIfNeeded];
    
    [self selectItemByDefault];
}

// 更改“更多按钮”
- (void)updateMoreBtnView {
    if (self.imageViewMore.image) {
        if (self.displayMode == HSSYSplitePeriodDisplayModeValidPartial) {
            [self.labelMore setText:@"显示更多时段"];
            self.imageViewMore.transform = CGAffineTransformMakeRotation(0);
        }
        else if (self.displayMode == HSSYSplitePeriodDisplayModeValidAll) {
            [self.labelMore setText:@"收起"];
            self.imageViewMore.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
}

// 选中可选的
- (void)selectItemByDefault {
    if (HSSYSplitePeriodDisplayModeValidPartial == self.displayMode || HSSYSplitePeriodDisplayModeValidAll == self.displayMode) {
        NSIndexPath *indexPath = nil;
        // 1.优先选择曾经选择过的时间段
        if (self.choosenDateArr && [self.choosenDateArr count] == 2) {
            NSDate *startTime = [self.choosenDateArr objectAtIndex:0];
            for(int cellIndex = 0; cellIndex < [self.validSpliteDataIndexPathArr count]; cellIndex ++) {
                NSIndexPath *specifyIndexpath = [self.validSpliteDataIndexPathArr objectAtIndex:cellIndex];
                DCSharePeriod *aPeriod = self.showedDataArr[specifyIndexpath.section];
                NSDate* start = [aPeriod.arrAllSplitedPeriod objectAtIndex:specifyIndexpath.row];
                if ([start isEqualToDate:startTime] ) {
                    indexPath = [NSIndexPath indexPathForItem:cellIndex inSection:0];
                    break;
                }
            }
        }
        //默认选中第一个
        if (indexPath == nil) {
            indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        }
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
        return;
    }
    else {
        // 1.优先选择曾经选择过的时间段
        if (self.choosenDateArr && [self.choosenDateArr count] == 2) {
            NSDate *startTime = [self.choosenDateArr objectAtIndex:0];
            for (int section = 0; section < [self.showedDataArr count]; section ++) {
                DCSharePeriod *aPeriod = self.showedDataArr[section];
                if (aPeriod.arrAllSplitedPeriod && [aPeriod.arrAllSplitedPeriod count] > 0 ) {
                    for (int itemIndex = 0; itemIndex < [aPeriod.arrAllSplitedPeriod count]; itemIndex++) {
                        if ([aPeriod.arrAllSplitedPeriod objectAtIndex:itemIndex] == startTime) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:section];
                            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
                            return;
                        }
                    }
                }
            }
        }
        // 2 找到一个可选的
        for (int section = 0; section < [self.showedDataArr count]; section ++) {
            DCSharePeriod *aPeriod = self.showedDataArr[section];
            if (aPeriod.arrAllSplitedPeriod && [aPeriod.arrAllSplitedPeriod count] > 0 ) {
                for (int itemIndex = 0; itemIndex < [aPeriod.arrAllSplitedPeriod count]; itemIndex++) {
                    if ([aPeriod canSelected:itemIndex]) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:section];
                        [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                        [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
                        return;
                    }
                }
            }
        }
    }
    
    
}


#pragma mark - UICollectionViewDataSource delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (HSSYSplitePeriodDisplayModeValidPartial == self.displayMode || HSSYSplitePeriodDisplayModeValidAll == self.displayMode) {
        return 1;
    }
    return [self.showedDataArr count];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.showedDataArr && [self.showedDataArr objectAtIndex:section] != nil) {
        if (HSSYSplitePeriodDisplayModeValidPartial == self.displayMode) {
            return [self.validSpliteDataIndexPathArr count] > COUNT_VALID_PARTIAL ? COUNT_VALID_PARTIAL : [self.validSpliteDataIndexPathArr count];
        }
        else if (HSSYSplitePeriodDisplayModeValidAll == self.displayMode){
            return [self.validSpliteDataIndexPathArr count];
        }
        else {
            DCSharePeriod* sharePeriod =  self.showedDataArr[section];
            return [sharePeriod.arrAllSplitedPeriod count];
        }
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HSSYSplitePeriodCell";
    
    NSIndexPath *specifyIndexPath = indexPath;
    if (HSSYSplitePeriodDisplayModeValidPartial == self.displayMode || HSSYSplitePeriodDisplayModeValidAll == self.displayMode) {
        specifyIndexPath = [self.validSpliteDataIndexPathArr objectAtIndex:indexPath.row];
    }
    
    DCSharePeriod* sharePeriod = nil;
    if (self.showedDataArr && [self.showedDataArr objectAtIndex:specifyIndexPath.section] != nil) {
        sharePeriod =  self.showedDataArr[specifyIndexPath.section];
    }
    
    DCPeriodSpliteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setupPeriod:sharePeriod withIndex:specifyIndexPath.row];//[NSString stringWithFormat:@"%@[%ld:%ld]", periodStr ,indexPath.section, indexPath.row];
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        if (self.displayMode == HSSYSplitePeriodDisplayModeAll) {
            FilterHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderViewCellIdentifier forIndexPath:indexPath];
            DCSharePeriod* sharePeriod = nil;
            if (self.shareDate && self.shareDate.sharePeriodObjArr && [self.shareDate.sharePeriodObjArr objectAtIndex:indexPath.section] != nil) {
                sharePeriod =  self.shareDate.sharePeriodObjArr[indexPath.section];
                NSString *title = [sharePeriod sharePeriodStr];
                headerView.sectionLabel.text = title;
                reusableview = headerView;
            }
        }
    }
    return reusableview;
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DCPeriodSpliteCollectionViewCell *cell = (DCPeriodSpliteCollectionViewCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
    self.choosenDateArr = [cell datesForBooking];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDates:)]) {
        [self.delegate didSelectDates:self.choosenDateArr];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.frame.size.width - kHSSYPeriodSpliterViewEdgeLeft - kHSSYPeriodSpliterViewEdgeRight - kHSSYPeriodSpliterViewInterItemSpacing * (kHSSYPeriodSpliterViewColumnCount-1)) / kHSSYPeriodSpliterViewColumnCount,
                      kHSSYPeriodSpliterViewCellHeight);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kHSSYPeriodSpliterViewEdgeTop,
                            kHSSYPeriodSpliterViewEdgeLeft,
                            self.displayMode == HSSYSplitePeriodDisplayModeAll ? kHSSYPeriodSpliterViewEdgeBottom : 0,
                            kHSSYPeriodSpliterViewEdgeRight);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kHSSYPeriodSpliterViewLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kHSSYPeriodSpliterViewInterItemSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.frame.size.width, self.displayMode == HSSYSplitePeriodDisplayModeAll ? kHSSYPeriodSpliterViewHeaderHeight : 0);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end
