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
@property (nonatomic, strong) NSIndexPath *indexPathForDeviceOrientation;
@property (nonatomic, strong) UIImageView *fullScreenImageView;
@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic) NSUInteger pageNumber;
@property (nonatomic, strong) NSURL *nextURL;
@property (nonatomic, strong) DRAPIUtility *instagramApi;

@end
//TODO: Make it accessible

@implementation DRCollectionViewController

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
    
    self.title = @"Jet.com Challenge";
    
    [self setupLongGesture];
    
    self.instagramApi = [[DRAPIUtility alloc] init];
    self.images = [[NSMutableDictionary alloc] init];
    
    [self setupDataForCollectionView];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.pageNumber = 0;
    self.nextURL = [[NSURL alloc] init];


}

-(void)setupDataForCollectionView {
    


    [self.instagramApi getImagesPage:self.pageNumber instagramURL:self.nextURL imageBlock:^(UIImage *image, NSIndexPath *indexPath) {
        [self.images setObject:image forKey:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } completionBlock:^(NSURL *url) {
        self.nextURL=url;
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gestures & Actions
-(void)setupLongGesture{
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
  //  [longPressGesture setDelegate:self.collectionView];//?
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
    self.originalImageView = cell.imageView;
    self.fullScreenImageView = [[UIImageView alloc] init];
    [self.fullScreenImageView setContentMode:UIViewContentModeScaleAspectFit];
    self.fullScreenImageView.image = [self.originalImageView image];
}

-(void)handleTapToZoom:(UITapGestureRecognizer* )gesture{
//TODO: refactor into this method
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 33;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DRPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];

    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
//TODO: swap self.images for reorder
    
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

    
    CGRect tempPoint = CGRectMake(self.originalImageView.center.x, self.originalImageView.center.y, 0, 0);
    
    //may not be necessary but probably good practice to make starting point from view
    //instead of from cell
    CGRect startingPoint = [self.view convertRect:tempPoint fromView:[self.collectionView cellForItemAtIndexPath:indexPath]];
    [self.fullScreenImageView setFrame:startingPoint];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.effectView setAlpha:0.0f];
    [self.effectView setFrame:self.view.frame];
    
    [self.view addSubview:self.effectView];
    
    [self.view addSubview:self.fullScreenImageView];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.fullScreenImageView setFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.bounds.size.width,
                                                                  self.view.bounds.size.height)];
                         [self.effectView setAlpha:1.0f];

                     }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.fullScreenImageView addGestureRecognizer:singleTap];
    [self.fullScreenImageView setUserInteractionEnabled:YES];
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
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    //must find insets in order for width to be accurate and not cause layout warnings
    CGFloat frameWidth = self.collectionView.frame.size.width;
    CGFloat sectionInsetWidth = flowLayout.sectionInset.right +flowLayout.sectionInset.left;
    CGFloat contentSectionWidth = self.collectionView.contentInset.left + self.collectionView.contentInset.right;
    
    if (indexPath.row % 3 == 0) {
        CGFloat width = frameWidth - sectionInsetWidth - contentSectionWidth;
        return CGSizeMake(width, width);
    }
    
    return CGSizeMake(frameWidth/3,frameWidth/3);
}
//-(UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    
//    return UIEdgeInsetsMake(10, 10, 10, 10);
//
//}
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

    CGFloat frameHeight =self.collectionView.bounds.size.height;
    CGFloat contentHeight = self.collectionView.contentSize.height;

    NSLog(@"content size = %f", contentHeight);

    float contentOffsetWhenFullyScrolledBottom = contentHeight-2*frameHeight;
    NSLog(@"***contentOffsetWhen bottom = %f", contentOffsetWhenFullyScrolledBottom);
    NSLog(@"scollview.contentOffset.y = %f", scrollView.contentOffset.y);
    if (self.collectionView.contentSize.height>2000 && scrollView.contentOffset.y >= contentOffsetWhenFullyScrolledBottom) {
        self.pageNumber ++;
        [self setupDataForCollectionView];
        [self.collectionView reloadData];

        /****Code for infinite circular scroll***
         
        // user is scrolling to the bottom from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the top of the collection view
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];

         ***************************************/
              NSLog(@"triggered scroll to top from bottom");
    }
//    else if (scrollView.contentOffset.y == -60.0)  {
//        
//        // user is scrolling to the top from the first item to the fake 'item N'.
//        // reposition offset to show the 'real' item N at the bottom end of the collection view
//        
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:18 inSection:0];
//        
//        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//        NSLog(@"triggered scroll to bottom from top");
//        
//    }

}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
//    
//
//}

#pragma mark - Tap To Zoom
- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    
    CGRect point=[self.view convertRect:self.originalImageView.bounds fromView:self.originalImageView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [(UIImageView *)gestureRecognizer.view setFrame:point];
                         [self.effectView setAlpha:0.0f];
                     }];
    [self performSelector:@selector(animationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
    
}

-(void)animationDone:(UIView  *)view
{
    [self.fullScreenImageView removeFromSuperview];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
    self.fullScreenImageView = nil;
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

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    DRPictureCell *drCell = (DRPictureCell *)cell;
    
    
    UIImage *newImage = [UIImage new];
    drCell.imageView.image = newImage;
    
    
}
@end
