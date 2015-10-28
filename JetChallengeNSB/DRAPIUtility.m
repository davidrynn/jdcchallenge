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

- (void)getImagesPage:(NSUInteger)pageNumber instagramURL: (NSURL *) url
            imageBlock:(void (^)(UIImage *, NSIndexPath *))imageBlock
       completionBlock:(void (^)(NSURL*))completion
{
    __block UIImage *placeholderImage = [UIImage imageNamed:@"jdc1.jpeg"];
    __block NSURL *instagramImagesURL = [[NSURL alloc] init];
    __block NSInteger returnedCount=0;
    
    //20 images at a time from api
    for (NSInteger i = 0; i < 33; i++) {
        
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 10;

        NSOperationQueue* imageQueue = [[NSOperationQueue alloc] init];
        imageQueue.maxConcurrentOperationCount = 10;
        
        if (pageNumber == 0) {
                   instagramImagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/jetdotcom/media/recent?client_id=%@&count=55", CLIENT_ID]];
        }


        NSURLRequest* request = [NSURLRequest requestWithURL:instagramImagesURL];
        AFHTTPRequestOperation* operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation,
                                                   id responseObject) {
            
            NSDictionary* responseDictionary = (NSDictionary*)responseObject;
            

            [imageQueue addOperationWithBlock:^{
                
                NSIndexPath* indexpath = [NSIndexPath indexPathForRow:pageNumber*20+i inSection:0];
                NSArray *dataArray =responseDictionary[@"data"];
                NSData* imageData = [NSData dataWithContentsOfURL:
                                     [NSURL URLWithString:dataArray[i][@"images"][@"low_resolution"][@"url"]]];
                
 
                UIImage* instagramImage = [UIImage imageWithData:imageData];
                if (!instagramImage) {
                    instagramImage = placeholderImage;
                }
                NSOperation *imageOp = [NSBlockOperation blockOperationWithBlock:^{
                    imageBlock(instagramImage, indexpath);
                }];
                NSOperation *checkCompleteOp = [NSBlockOperation blockOperationWithBlock:^{
                    returnedCount++;
                    if (returnedCount==20) {

                            completion([NSURL URLWithString:responseDictionary[@"pagination"][@"next_url"]]);

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
