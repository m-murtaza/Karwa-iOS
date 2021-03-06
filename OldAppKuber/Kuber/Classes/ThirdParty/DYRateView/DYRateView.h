/*
Copyright (C) 2012 Derek Yang. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
* Neither the name of the author nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

IB_DESIGNABLE

typedef NS_ENUM(NSUInteger, RateViewAlignment) {
    RateViewAlignmentLeft = 1,
    RateViewAlignmentCenter,
    RateViewAlignmentRight
};

@protocol DYRateViewDelegate;


@interface DYRateView : UIView {

    CGPoint _origin;
    NSInteger _numOfStars;
}

@property(nonatomic) CGFloat rate;
@property(nonatomic) CGFloat padding;

@property(nonatomic) IBInspectable BOOL editable;

@property(nonatomic) IBInspectable RateViewAlignment alignment;
@property(nonatomic, strong) IBInspectable UIImage *fullStarImage;
@property(nonatomic, strong) IBInspectable UIImage *emptyStarImage;

@property(nonatomic, weak) NSObject<DYRateViewDelegate> *delegate;

- (DYRateView *)initWithFrame:(CGRect)frame;
- (DYRateView *)initWithFrame:(CGRect)rect fullStar:(UIImage *)fullStarImage emptyStar:(UIImage *)emptyStarImage;

@end

@protocol DYRateViewDelegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate;

@end
