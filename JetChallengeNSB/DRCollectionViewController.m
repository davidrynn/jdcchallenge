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
@property (strong, nonatomic) NSIndexPath *indexPathForDeviceOrientation;


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
    self = [super initWithCollectionViewLayout:layout];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView setAccessibilityIdentifier:@"Image List"];
    [self.collectionView setAccessibilityLabel:@"Image List"];
    [self setAccessibilityLabel:@"Image List Controller"];
  

    [self.collectionView registerClass:[DRPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    

    self.images = [[NSMutableDictionary alloc] init];

    self.title = @"Jet.com Challenge";
    
    [self setupLongGesture];
    
//temporary for testing pix until api is setup
    [self setupDataForCollectionView];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.pagingEnabled = YES;



}
-(void)setupDataForCollectionView {
    
    // Create the original set of data
    NSArray *originalArray = @[
                          [UIImage imageNamed:@"alg-woodlawn-subway-jpg"],
                          [UIImage imageNamed:@"albumCover"],
                          [UIImage imageNamed:@"albumCover2"],
                          [UIImage imageNamed:@"images-albums-Plushgoolash_-_Chin25_Soup_Tennis_-_20110716151050790.w_290.h_290.m_crop.a_center.v_top"],
                          [UIImage imageNamed:@"my gravatar"],
                          [UIImage imageNamed:@"Screen Shot 2015-07-01 at 10.08.11 AM"],
                          [UIImage imageNamed:@"waze"],
                          [UIImage imageNamed:@"bedefordsubway"],
                          [UIImage imageNamed:@"machine_2"],
                          [UIImage imageNamed:@"subwayEntrance"],
                          [UIImage imageNamed:@"subwayEntrace2"],
                          [UIImage imageNamed:@"alg-woodlawn-subway-jpg"],
                          [UIImage imageNamed:@"albumCover"],
                          [UIImage imageNamed:@"albumCover2"],
                          [UIImage imageNamed:@"images-albums-Plushgoolash_-_Chin25_Soup_Tennis_-_20110716151050790.w_290.h_290.m_crop.a_center.v_top"],
                          [UIImage imageNamed:@"my gravatar"],
                          [UIImage imageNamed:@"Screen Shot 2015-07-01 at 10.08.11 AM"],
                          [UIImage imageNamed:@"waze"],
                          [UIImage imageNamed:@"bedefordsubway"],
                          [UIImage imageNamed:@"machine_2"],
                          [UIImage imageNamed:@"subwayEntrance"],
                          [UIImage imageNamed:@"subwayEntrace2"]
                          ];
    
    // Grab references to the first and last items
    UIImage *firstItem = originalArray[0];
    UIImage *lastItem = [originalArray lastObject];
    
    NSMutableArray *workingArray = [originalArray mutableCopy];
    
    // Add the copy of the last item to the beginning
    [workingArray insertObject:lastItem atIndex:0];
    
    // Add the copy of the first item to the end
    [workingArray addObject:firstItem];
    
    // Update the collection view's data source property
    self.pictureArray = [NSArray arrayWithArray:workingArray];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gestures & Actions
-(void)setupLongGesture{
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [longPressGesture setDelegate:self.collectionView];//?
    [self.collectionView addGestureRecognizer:longPressGesture];

}
-(void)handleLongPress:(UIGestureRecognizer *) gesture {
    CGPoint p = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint: p];
    
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
-(void)setupTapForCell:(DRPictureCell *) cell {
    originalImageView = cell.imageView;
    fullScreenImageView = [[UIImageView alloc] init];
    [fullScreenImageView setContentMode:UIViewContentModeScaleAspectFit];
    fullScreenImageView.image = [originalImageView image];
}
-(void)handleTapToZoom:(UITapGestureRecognizer* )gesture{
//TODO: refactor into this method
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
    cell.imageView.image = self.pictureArray[indexPath.row];

//    [self configureCell:cell forIndexPath:indexPath];

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

    DRPictureCell *cell = (DRPictureCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self setupTapForCell:cell];

    
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



- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 30.0;
}
-(CGSize)collectionView:(UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    CGFloat frameWidth = self.collectionView.frame.size.width;
    if (indexPath.row % 3 == 0) {
        return CGSizeMake(frameWidth/3, frameWidth/3);
    }
    
    return CGSizeMake(frameWidth/5, frameWidth/5);
}
-(UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);

}
#pragma mark - UIInterfaceOrientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _indexPathForDeviceOrientation = [[self.collectionView indexPathsForVisibleItems] firstObject];
    [[self.collectionView collectionViewLayout] invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView scrollToItemAtIndexPath:_indexPathForDeviceOrientation atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}


#pragma mark - ScrollView Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // Calculate where the collection view should be at the bottom end item
    //take number of 300x300 cells plus 100x100 cells minus one screen length
    //11 pix 3big, 8 small = 900 + 800
    
    NSUInteger numberOfBigPix = (self.pictureArray.count-1)/3;

    NSLog(@"number of big pix = %lu", (unsigned long)numberOfBigPix);
    NSLog(@"collectionviewitemsizeheight = %f", self.collectionViewLayout.collectionViewContentSize.height);
    
    float contentOffsetWhenFullyScrolledBottom = (self.collectionView.frame.size.width/3 + self.collectionView.layoutMargins.top)*numberOfBigPix-self.collectionView.frame.size.height;
    NSLog(@"contentOffsetWhen bottom = %f", contentOffsetWhenFullyScrolledBottom);
    NSLog(@"scollview.contentOffset.y = %f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y >= contentOffsetWhenFullyScrolledBottom) {
        
        // user is scrolling to the bottom from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the top of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        NSLog(@"triggered scroll in equal contentoffset");
        
    } else if (scrollView.contentOffset.y == 0)  {
        
        // user is scrolling to the top from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the bottom end of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.pictureArray count] -2) inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        NSLog(@"triggered scroll in equal 0");
        
    }

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
    

}

#pragma mark - Tap To Zoom
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
