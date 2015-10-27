//
//  DRAPIUtility.m
//  JetChallengeNSB
//
//  Created by David Rynn on 10/22/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import "DRAPIUtility.h"
#import <AFNetworking.h>
#import <AFOAuth2Manager.h>

#import "DRKeys.h"

@implementation DRAPIUtility

- (void)getImagesPage:(NSNumber*)pageNumber instagramURL: (NSURL *) url
            imageBlock:(void (^)(UIImage *, NSIndexPath *, NSUInteger))imageBlock
       completionBlock:(void (^)(NSURL*))completion
{
    __block UIImage *placeholderImage = [UIImage imageNamed:@"jdc1.jpeg"];
    __block NSURL *instagramImagesURL = [[NSURL alloc] init];
    
    //20 images at a time from api
    for (NSInteger i = 0; i < 20; i++) {
        
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 10;
        __block NSInteger returnedCount=0;
        
        NSOperationQueue* imageQueue = [[NSOperationQueue alloc] init];
        imageQueue.maxConcurrentOperationCount = 10;
        
        if (pageNumber == 0) {
                   instagramImagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/jetdotcom/media/recent?client_id=%@", CLIENT_ID]];
        }


        NSURLRequest* request = [NSURLRequest requestWithURL:instagramImagesURL];
        AFHTTPRequestOperation* operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation,
                                                   id responseObject) {
            
            NSDictionary* responseDictionary = (NSDictionary*)responseObject;
            
//  DOESN"T WORK          //setup load
//            if (i>0&&(i+1)%20==0) {
//                instagramImagesURL = [NSURL URLWithString:responseDictionary[@"pagination"][@"next_url"] ];
//            }
            
            [imageQueue addOperationWithBlock:^{
                
                NSIndexPath* indexpath = [NSIndexPath indexPathForRow:[pageNumber integerValue]*20+i inSection:0];
                NSArray *dataArray =responseDictionary[@"data"];
                NSLog(@"%@",dataArray[i][@"images"][@"low_resolution"][@"url"]);

                NSData* imageData = [NSData dataWithContentsOfURL:
                                     [NSURL URLWithString:responseDictionary[@"data"][i][@"images"][@"low_resolution"][@"url"]]];
                
                //delete
                NSUInteger numberOfImages = dataArray.count;
                UIImage* instagramImage = [UIImage imageWithData:imageData];
                if (!instagramImage) {
                    instagramImage = placeholderImage;
                }
                NSOperation *imageOp = [NSBlockOperation blockOperationWithBlock:^{
                    imageBlock(instagramImage, indexpath, numberOfImages);
                }];
                NSOperation *checkCompleteOp = [NSBlockOperation blockOperationWithBlock:^{
                    returnedCount++;
                    if (returnedCount==10) {
                        if (completion) {
                            completion([NSURL URLWithString:responseDictionary[@"pagination"][@"next_url"]]);
                        }
                    }
                }];
                [checkCompleteOp addDependency:imageOp];
                [[NSOperationQueue mainQueue] addOperation:imageOp];
                [[NSOperationQueue mainQueue] addOperation:checkCompleteOp];
            }];
            
        }
                                         failure:nil];
        
        [queue addOperation:operation];
    };
}
@end
