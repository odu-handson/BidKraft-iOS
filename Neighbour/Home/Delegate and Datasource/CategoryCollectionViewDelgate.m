//
//  CategoryCollectionViewDelgate.m
//  Neighbour
//
//  Created by ravi pitapurapu on 9/4/14.
//  Copyright (c) 2014 ODU_HANDSON. All rights reserved.
//

#import "CategoryCollectionViewDelgate.h"
#import "CategoryCollectionViewFlowLayout.h"
#import "CreateRequestViewController.h"

@interface CategoryCollectionViewDelgate()

 @property (nonatomic,strong) CreateRequestViewController *createRequestViewController;

@property (nonatomic,strong) NSMutableArray *labelsArray;
@property (nonatomic,strong) NSString *categoryType;
@property (nonatomic,strong) NSString *categoryId;


@end

@implementation CategoryCollectionViewDelgate

-(void) prepareLabelArray
{
    self.labelsArray = [[NSMutableArray alloc] initWithCapacity:5];
    [self.labelsArray addObject:@"Baby Sitting"];
    //[self.labelsArray addObject:@"Home Repairs"];
    //[self.labelsArray addObject:@"House Cleaning"];
    //[self.labelsArray addObject:@"Computer Repairs"];
    [self.labelsArray addObject:@"Pet Care"];
    [self.labelsArray addObject:@"Tutoring"];
    [self.labelsArray addObject:@"Books Selling"];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self prepareLabelArray];
    NSString *categoryType =[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    self.categoryType = [[NSString alloc] initWithString:categoryType];
    
    
   // [self performSegueWithIdentifier:@"CreateRequest" sender:nil];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    self.createRequestViewController = (CreateRequestViewController *) [storyBoard instantiateViewControllerWithIdentifier:@"CreateRequestViewController"];
    self.createRequestViewController.categoryType = categoryType;
    self.createRequestViewController.homeViewController = self.homeViewController;
    self.createRequestViewController.categoryId = self.categoryId;
    [self.homeViewController.navigationController pushViewController:self.createRequestViewController animated:YES];
}

- (NSString *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.section * [(CategoryCollectionViewFlowLayout *)collectionView.collectionViewLayout numberOfItemsPerSection:indexPath.section] + indexPath.item;
    NSLog(@"selected %ld",(long)index);
    NSString *selectedLabel =[self.labelsArray objectAtIndex:index];
    self.categoryId = [[NSString alloc] initWithFormat:@"%ld",((long)index+1)];
    return selectedLabel;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CreateRequest"])
    {
         CreateRequestViewController *createRequestViewController = [segue destinationViewController];
        createRequestViewController.categoryType = self.categoryType;
    }
}

@end
