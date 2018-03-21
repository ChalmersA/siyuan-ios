//
//  HSSYUICollectionViewPeriodSpliterLayout.m
//  CollectionViewTest
//
//  Created by  Blade on 4/27/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCUICollectionViewPeriodSpliterLayout.h"


@interface UICollectionViewLayoutAttributes (LeftAligned)

- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset;

@end

@implementation UICollectionViewLayoutAttributes (LeftAligned)

- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset
{
    CGRect frame = self.frame;
    frame.origin.x = sectionInset.left;
    self.frame = frame;
}

@end


static NSInteger kHSSYPeriodSpliterColloctionLayoutRows = 2;
static NSInteger kHSSYPeriodSpliterColloctionLayoutCellGap = 10;
static NSInteger kHSSYPeriodSpliterColloctionLayoutHeaderHeight = 15;
static NSInteger kHSSYPeriodSpliterColloctionLayoutFooterHeight = 15;

@interface DCUICollectionViewPeriodSpliterLayout() {
    
}
@property (assign, nonatomic) NSInteger cellCount;
@property (assign, nonatomic) CGPoint center;
@property (assign, nonatomic) float radius;
@property (assign, nonatomic) CGFloat contentHeight;
@property (assign, nonatomic) NSArray *cellIndexArray;


@end


@implementation DCUICollectionViewPeriodSpliterLayout


#pragma mark - UICollectionViewLayout

-(void)prepareLayout
{   //和init相似，必须call super的prepareLayout以保证初始化正确
    [super prepareLayout];
    
    CGSize size = self.collectionView.frame.size;
    NSInteger sectionCount = self.collectionView.numberOfSections;
    _cellCount = 0;
    for (int i = 0; i < sectionCount; i++) {
        _cellCount += [[self collectionView] numberOfItemsInSection:i];
    }
    _center = CGPointMake(size.width / 2.0, size.height / 2.0);
    _radius = MIN(size.width, size.height) / 2.5;
    
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x
                                           , self.collectionView.frame.origin.y
                                           , self.collectionView.frame.size.width
                                           , self.collectionView.frame.size.height + 300);
    
}

//-(CGSize)collectionViewContentSize
//{
//    return CGSizeMake([self collectionView].frame.size.width, 200);
//}


//用来在一开始给出一套UICollectionViewLayoutAttributes
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* attributesToReturn = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes* attributes in attributesToReturn) {
        if (nil == attributes.representedElementKind) {
            NSIndexPath* indexPath = attributes.indexPath;
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return attributesToReturn;
}

//通过所在的indexPath确定位置。
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:path]; //生成空白的attributes对象，其中只记录了类型是cell以及对应的位置是indexPath
//    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
//    CGSize cellSize = CGSizeMake(collectionViewWidth / 2 - 2* kHSSYPeriodSpliterColloctionLayoutCellGap, 60);
//    
//    attributes.size = CGSizeMake(100 , 50);
//    attributes.frame = CGRectMake((path.row % kHSSYPeriodSpliterColloctionLayoutRows) * collectionViewWidth / 2 + kHSSYPeriodSpliterColloctionLayoutCellGap,
//                                  attributes.frame.origin.y + (path.row / kHSSYPeriodSpliterColloctionLayoutRows) * (cellSize.height + kHSSYPeriodSpliterColloctionLayoutCellGap),
//                                  cellSize.width,
//                                  cellSize.height);
    return attributes;
}




#pragma mark - Utility Funcions



@end
