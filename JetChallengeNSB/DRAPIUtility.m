//
//  DRAPIUtility.m
//  JetChallengeNSB
//
//  Created by David Rynn on 10/22/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import "DRAPIUtility.h"
#import <AFNetworking.h>

#import "DRKeys.h"

@implementation DRAPIUtility
- (void)getImagesCount:(NSNumber*)count
            imageBlock:(void (^)(UIImage *, NSIndexPath *))imageBlock completionBlock:(void (^)())completion
{
    

//    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
//    queue.maxConcurrentOperationCount = 10;
//    __block NSInteger returnedCount=0;
//    
//    NSOperationQueue* imageQueue = [[NSOperationQueue alloc] init];
//    imageQueue.maxConcurrentOperationCount = 10;
//    NSURL* instagramImagesURL =
//    [NSURL URLWithString:@"instagram://tag?name=jetdotcom"];
//    
//    //instagram example url
////  https://api.instagram.com/v1/tags/nofilter/media/recent?client_id=CLIENT-ID
//    
//        NSURLRequest* request = [NSURLRequest requestWithURL:instagramImagesURL];
//        AFHTTPRequestOperation* op =
//        [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        
//        op.responseSerializer = [AFJSONResponseSerializer serializer];
//        
//        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation,
//                                            id responseObject) {
//            NSDictionary* responseDictionary = (NSDictionary*)responseObject;
//            
//            [imageQueue addOperationWithBlock:^{
//
//                NSLog(@"%@",responseDictionary[@"image"]);
//                NSData* imageData =
//                [NSData dataWithContentsOfURL:
//                 [NSURL URLWithString:responseDictionary[@"image"]]];
//                UIImage* imageImage = [UIImage imageWithData:imageData];
//                if (!imageImage) {
//                    imageImage = [UIImage imageNamed:@"placeholder"];
//                }
//                NSOperation *imageOp = [NSBlockOperation blockOperationWithBlock:^{
//                    imageBlock(imageImage);
//                }];
//                NSOperation *checkCompleteOp = [NSBlockOperation blockOperationWithBlock:^{
//                    returnedCount++;
//                    if (returnedCount==10) {
//                        if (completion) {
//                            completion();
//                        }
//                    }
//                }];
//                [checkCompleteOp addDependency:imageOp];
//                [[NSOperationQueue mainQueue] addOperation:imageOp];
//                [[NSOperationQueue mainQueue] addOperation:checkCompleteOp];
//            }];
//            
//        }
//                                  failure:nil];
//        
//        [queue addOperation:op];
//    }
}
@end
