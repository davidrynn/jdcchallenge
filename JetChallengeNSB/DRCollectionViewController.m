//
//  DRCollectionViewController.m
//  JetChallengeNSB
//
//  Created by David Rynn on 10/22/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import "DRCollectionViewController.h"
#import "DRPictureCell.h"
#import "DRAPIUtility.h"

@interface DRCollectionViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *pictureArray;
@property (nonatomic, strong) NSMutableDictionary *images;

@end
//TODO: Make it accessible

@implementation DRCollectionViewController
{
    UIImageView *fullScreenImageView;
    UIImageView *originalImageView;
    
}

static NSString * const reuseIdentifier = @"Cell";


-(instancetype) init{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize =CGSizeMake(106.0, 106.0);
    self = [super initWithCollectionViewLayout:layout];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //accessibility
    [self.collectionView setAccessibilityIdentifier:@"Image List"];
    [self.collectionView setAccessibilityLabel:@"Image List"];
    [self setAccessibilityLabel:@"Image List Controller"];
    
    //setup long gesture for reordering
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [longPressGesture setDelegate:self.collectionView];//?
    [self.collectionView addGestureRecognizer:longPressGesture];

    
    // Register cell classes
    [self.collectionView registerClass:[DRPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    self.images = [[NSMutableDictionary alloc] init];
    DRAPIUtility *pugapi = [[DRAPIUtility alloc] init];
    
    [pugapi getImagesCount:@100 imageBlock:^(UIImage *image, NSIndexPath *ip) {
        [self.images setObject:image forKey:ip];
        [self.collectionView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    } completionBlock:nil];
    self.title = @"Jet.com Challenge";
//    self.pictureArray = @[
//                          [UIImage imageNamed:@"albumCover"],
//                          [UIImage imageNamed:@"albumCover2"],
//                          [UIImage imageNamed:@"images-albums-Plushgoolash_-_Chin25_Soup_Tennis_-_20110716151050790.w_290.h_290.m_crop.a_center.v_top"],
//                          [UIImage imageNamed:@"my gravatar"],
//                          [UIImage imageNamed:@"Screen Shot 2015-07-01 at 10.08.11 AM"],
//                          [UIImage imageNamed:@"waze"]];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}


-(void)handleLongPress:(UIGestureRecognizer *) gesture {
    CGPoint p = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint: p];
    //TODO: create swap if in different section otherwise below
    //so that if it's in thesame section just reorder, if it's in different section
    //then swap.
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (selectedIndexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:gesture.view]];
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
            
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pictureArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DRPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //TODO: Select item -> tap to zoom
    
    
    DRPictureCell *cell = (DRPictureCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    originalImageView = cell.imageView;
    fullScreenImageView = [[UIImageView alloc] init];
    [fullScreenImageView setContentMode:UIViewContentModeScaleAspectFit];
    fullScreenImageView.image = [originalImageView image];
    
    CGRect tempPoint = CGRectMake(originalImageView.center.x, originalImageView.center.y, 0, 0);
    
    //may not be necessary but probably good practice to make starting point from view
    //instead of from cell
    CGRect startingPoint = [self.view convertRect:tempPoint fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
    [fullScreenImageView setFrame:startingPoint];
    
    [self.view addSubview:fullScreenImageView];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [fullScreenImageView setFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.bounds.size.width,
                                                                  self.view.bounds.size.height)];
                     }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [fullScreenImageView addGestureRecognizer:singleTap];
    [fullScreenImageView setUserInteractionEnabled:YES];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //TODO: DeselectItem
}

#pragma mark - UICollectionViewDelegateFlowLayout

//-(BOOL)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    
//}
-(CGSize)collectionView:(UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{

    if (indexPath.row % 3 == 0) {
        return CGSizeMake(300, 300);
    }
    
    return CGSizeMake(100, 100);
}
-(UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 20, 20, 10);
////    CGFloat itemWidth =332.0;
////    //((UICollectionViewFlowLayout * )collectionViewLayout).itemSize.width;
////    
////    NSInteger numberOfCells = self.view.frame.size.width / itemWidth;
////    NSInteger edgeInsets = (self.view.frame.size.width - (numberOfCells * itemWidth)) / (numberOfCells + 1);
////    
////    return UIEdgeInsetsMake(10, edgeInsets, 10, edgeInsets);
////    NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:section];
////    if( cellCount >0 )
////    {
////        CGFloat cellWidth = ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize.width+((UICollectionViewFlowLayout*)collectionViewLayout).minimumInteritemSpacing;
////        CGFloat totalCellWidth = cellWidth*cellCount;
////        CGFloat contentWidth = collectionView.frame.size.width-collectionView.contentInset.left-collectionView.contentInset.right;
////        if( totalCellWidth<contentWidth )
////        {
////            CGFloat padding = (contentWidth - totalCellWidth) / 2.0;
////            return UIEdgeInsetsMake(0, padding, 0, padding);
////        }
////    }
////    return UIEdgeInsetsZero;
////    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
////    NSInteger numberOfItems = [collectionView numberOfItemsInSection:0];
////    CGFloat combinedItemWidth = (numberOfItems * flowLayout.itemSize.width) + ((numberOfItems - 1) * flowLayout.minimumInteritemSpacing);
////    CGFloat padding = (collectionView.frame.size.width - combinedItemWidth) / 2;
////    
////    return UIEdgeInsetsMake(0, padding, 0, padding);
//    
//
}

#pragma mark - ScrollView Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
    
    // Calculate where the collection view should be at the right-hand end item
    float contentOffsetWhenFullyScrolledRight = self.collectionView.frame.size.width * ([self.pictureArray count] -1);
    
    if (scrollview.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
        
        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    } else if (scrollview.contentOffset.x == 0)  {
        
        // user is scrolling to the left from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the right end end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.pictureArray count] -2) inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        
    }
}

#pragma mark - Miscellaneous
- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    
    CGRect point=[self.view convertRect:originalImageView.bounds fromView:originalImageView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [(UIImageView *)gestureRecognizer.view setFrame:point];
                     }];
    [self performSelector:@selector(animationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
    
}

-(void)animationDone:(UIView  *)view
{
    [fullScreenImageView removeFromSuperview];
    fullScreenImageView = nil;
}
- (void)configureCell:(DRPictureCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        if (self.images[indexPath])
        {
            cell.imageView.image = self.images[indexPath];
        }
    }];
}
@end
