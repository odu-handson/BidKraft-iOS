//
//  CategoryCollectionViewFlowLayout.m
//  Neighbour
//
//  Created by ravi pitapurapu on 9/4/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "CategoryCollectionViewFlowLayout.h"

@interface CategoryCollectionViewFlowLayout ()

@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGPoint origin;

@end

@implementation CategoryCollectionViewFlowLayout

- (NSInteger)numberOfSections
{
    return 2;
}

- (NSInteger)numberOfItemsPerSection:(NSInteger)section
{
    NSInteger returnValue = 4;
        return returnValue;
}

- (NSInteger)numberOfItemsPerRow
{
    return 3;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
}

//- (CGSize)itemSizeAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize returnValue;
//    [self getCollectionViewOriginAndSize];
//    CGFloat width = [self getItemWidthAtIndexPath:indexPath];
//    CGFloat height = [self getItemHeightAtIndexPath:indexPath];
//    returnValue = CGSizeMake(width, height);
//    return returnValue;
//}

//- (void)getCollectionViewOriginAndSize
//{
//    self.size = self.collectionView.frame.size;
//    self.origin = self.collectionView.frame.origin;
//}
//
//- (CGFloat)getItemWidthAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat returnValue;
//    returnValue = self.size.width/[self numberOfItemsPerSection:indexPath.section] - self.minimumInteritemSpacing/2 - self.sectionInset.left;
//    return returnValue;
//}
//
//- (CGFloat)getItemHeightAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat returnValue;
//    CGFloat ratio = 1.0f;
//    if([self numberOfItemsPerSection:indexPath.section] > 1)
//        ratio = 190.0f/152.0f;
//    returnValue = [self getItemWidthAtIndexPath:indexPath] * ratio;
//    return returnValue;
//}


- (CGSize)itemSize
{
    CGFloat width = ([self.collectionView bounds].size.width - self.sectionInset.left - self.sectionInset.right - (self.minimumInteritemSpacing * ([self numberOfItemsPerRow] -1))) / [self numberOfItemsPerRow];
    CGFloat height = ([self.collectionView bounds].size.height- self.sectionInset.top - self.sectionInset.bottom - (([self numberOfRowsAllowedPerScreenOnCollectionView]-1)*self.minimumInteritemSpacing) )/[self numberOfRowsAllowedPerScreenOnCollectionView];

    return CGSizeMake(width, height);
}

- (NSInteger)numberOfRowsAllowedPerScreenOnCollectionView
{
    return 2;
}

@end
