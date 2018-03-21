//
//  DCClusterPopoverVIew.m
//  Charging
//
//  Created by  Blade on 6/18/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCClusterPopoverVIew.h"
#import "ArrayDataSource.h"
#import "DCClusterPopTableViewCell.h"

static NSString *kCellIdentifier = @"DCClusterPopTableViewCell";
#define  Arror_height 7
@interface DCClusterPopoverVIew () <UITableViewDelegate> {
    BOOL testHits;
}
@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (retain, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CGFloat viewMaxHeight;
@property (strong, nonatomic) UIImageView *bgImageView;
@end

@implementation DCClusterPopoverVIew

-(instancetype)initWithPoles:(NSArray*)poles andFrame:(CGRect)frame itemSelectBlock:(ClusterItemSelctedBlcok)block{
    self = [super initWithFrame:frame];
    if(self){
        self.pileArr = poles;
        
        self.tableView = [[UITableView alloc] init];
        [self.tableView registerNib:[UINib nibWithNibName:@"DCClusterPopTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
        
        self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker-frame"]];
        
        [self addSubview:self.bgImageView];
        [self addSubview:self.tableView];
        self.dataSource = [ArrayDataSource dataSourceWithItems:self.pileArr
                                                cellIdentifier:kCellIdentifier
                                            configureCellBlock:^(DCClusterPopTableViewCell* cell, id item) {
                                                // TODO:Add necessary code here
                                                DCStation* station = (DCStation*)item;
                                                
                                                [cell.labelPoleName setText:station.stationName];
                                            }];
        
        self.tableView.dataSource = self.dataSource;
        self.tableView.delegate = self;
        
        [self adjustViewMaxHeight:frame.size.height];
        
        self.itemSelectedBlock = block;
//        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return self;
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
        
    [self drawInContext:UIGraphicsGetCurrentContext()];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
//    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowOpacity = 1.0;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

-(void)drawInContext:(CGContextRef)context {
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context {
    CGRect rrect = self.bounds;
    CGFloat radius = 0.0;
    
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    // midy = CGRectGetMidY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;
    CGContextMoveToPoint(context, midx+Arror_height, maxy);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    id item = self.dataSource.items[indexPath.row];
    if (item && self.itemSelectedBlock) {
        self.itemSelectedBlock(item);
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

#pragma mark - 
- (DCStation*)selectStation:(DCStation *)station {
    if (self.pileArr && [self.pileArr containsObject:station]) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.pileArr indexOfObject:station] inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath  animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        return station;
    }
    return nil;
}

- (CGFloat)adjustViewMaxHeight:(CGFloat)height {
    CGRect frame = self.frame;
    if (self.viewMaxHeight != height) {
        self.viewMaxHeight = height;
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
        
        CGFloat tableViewRowHeight = 0;
        if (self.pileArr && [self.pileArr count]>0) {
            // 下面的rowIndex是控制聚合点展开后展示出来的桩群数
            for (int rowIndex=0; rowIndex < 2; rowIndex++) {
                tableViewRowHeight += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
                if (tableViewRowHeight > self.viewMaxHeight - Arror_height) {
                    tableViewRowHeight = self.viewMaxHeight - Arror_height;
                    break;
                }
            }
        }
        [self.tableView setFrame:CGRectMake(5, 5, CGRectGetWidth(frame) - 10, tableViewRowHeight)];
        frame.size.height = tableViewRowHeight + Arror_height + 10;
        [self.bgImageView setFrame:frame];
        [self setFrame:frame];
    }
    return frame.size.height;
}
@end
