//
//  UIImageView+AFNetworkingWithCropAndCache.m
//  Utilities
//
//  Created by Hirohisa Kawasaki on 12/08/06.
//  Copyright (c) 2012年 Hirohisa Kawasaki. All rights reserved.
//

#import "UIImageView+AFNetworkingWithCropAndCache.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImage (Crop)
- (UIImage *)croppedWithSize:(CGSize)size
{
    return [self croppedWithSize:size alignment:ImageCropAlignmentCener];
}

- (UIImage *)croppedWithSize:(CGSize)size alignment:(ImageCropAlignment)alignment
{
    CGFloat offsetX = 0, offsetY = 0;
    switch (alignment) {
        case ImageCropAlignmentCener: {
            offsetX = [self _centerWithLength:size.width max:self.size.width];
            offsetY = [self _centerWithLength:size.height max:self.size.height];
        }
            break;
        case ImageCropAlignmentTop: {
            offsetX = [self _centerWithLength:size.width max:self.size.width];
        }
            break;
        case ImageCropAlignmentBottom: {
            offsetX = [self _centerWithLength:size.width max:self.size.width];
            offsetY = self.size.height - size.height;
        }
            break;
        case ImageCropAlignmentLeft:  {
            offsetY = [self _centerWithLength:size.height max:self.size.height];
        }
            break;
        case ImageCropAlignmentRight: {
            offsetX = self.size.width - size.width;
            offsetY = [self _centerWithLength:size.height max:self.size.height];
        }
            break;
        default:
            break;
    }

    return [self _croppedWithSize:size offset:CGPointMake(offsetX, offsetY)];
}

- (UIImage *)_croppedWithSize:(CGSize)size offset:(CGPoint)offset
{
    CGRect croppingRect = CGRectMake(offset.x, offset.y, size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, croppingRect);
    UIImage *resultImage =[UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return resultImage;
}

- (CGFloat)_centerWithLength:(CGFloat)length max:(CGFloat)max
{
    return (max-length)/2;
}
@end

@implementation UIImageView (AFNetworkingWithCropAndCache)

#pragma mark - public
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cached:(BOOL)cached finished:(void (^)(BOOL))finished
{
    __block_weak UIImageView *blockSelf = self;
    [self requestImageWithURL:url placeholderImage:placeholderImage cached:cached response:^(UIImage *image){
        if (image != nil) {
            blockSelf.image = image;
        }
        finished(YES);
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
                   crop:(CGSize)size type:(ImageViewCropType)type finished:(void (^)(BOOL))finished
{
    [self setImageWithURL:url placeholderImage:placeholderImage crop:size type:type cached:YES finished:finished];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
                   crop:(CGSize)size  type:(ImageViewCropType)type
                 cached:(BOOL)cached finished:(void (^)(BOOL))finished
{
    __block_weak UIImageView *blockSelf = self;
    [self requestImageWithURL:url placeholderImage:placeholderImage cached:cached response:^(UIImage *image){
        if (image) {
            blockSelf.image = [blockSelf crop:image size:size type:type];
        }
        finished(YES);
    }];
}

#pragma mark - private
#pragma mark - request
- (void)requestImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cached:(BOOL)cached response:(void (^)(UIImage *))response
{
    NSURLRequestCachePolicy cachePolicy = cached?NSURLRequestUseProtocolCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:30.0];
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *res, UIImage *image){
        response(image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *res, NSError *error){
        response(nil);
    }];
}

#pragma mark - crop
-(UIImage*)crop:(UIImage*)image size:(CGSize)size type:(ImageViewCropType)type
{
    return [self trim:image size:[self trimSize:image size:size type:(ImageViewCropType)type]];
}

- (UIImage*)trim:(UIImage*)image size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawAtPoint:CGPointMake(0, 0)];
    
    UIImage *trimmedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return trimmedImage;
}

- (CGSize)trimSize:(UIImage*)image size:(CGSize)size type:(ImageViewCropType)type
{
    CGFloat widthRatio  = image.size.width/size.width;
    CGFloat heightRatio = image.size.height/size.height;
    CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
    if (type == ImageViewCropTypeAdjustWidth) {
        ratio = widthRatio;
    } else if (type == ImageViewCropTypeAdjustHeight) {
        ratio = heightRatio;
    }
    return CGSizeMake(size.width * ratio, size.height * ratio);
}
@end
