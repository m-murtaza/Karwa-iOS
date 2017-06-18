//
//  MKMapView+KSExtensions.m
//  Kuber
//
//  Created by Asif Kamboh on 10/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import "MKMapView+KSExtensions.h"

@implementation MKMapView (KSExtensions)

/**
 *  Changes the currently visible portion of the map to a region that best fits all the currently loadded annotations on the map, and it optionally animates the change.
 *
 *  @param animated is the change should be perfomed with an animation.
 */
-(void)ij_setVisibleRectToFitAllLoadedAnnotationsAnimated:(BOOL)animated
{
    MKMapView * mapView = self;
    
    NSArray * annotations = mapView.annotations;
    
    [self ij_setVisibleRectToFitAnnotations:annotations animated:animated];
    
}


/**
 *  Changes the currently visible portion of the map to a region that best fits the provided annotations array, and it optionally animates the change.
 All elements from the array must conform to the <MKAnnotation> protocol in order to fetch the coordinates to compute the visible region of the map.
 *
 *  @param annotations an array of elements conforming to the <MKAnnotation> protocol, holding the locations for which the visible portion of the map will be set.
 *  @param animated    wether or not the change should be perfomed with an animation.
 */
-(void)ij_setVisibleRectToFitAnnotations:(NSArray *)annotations animated:(BOOL)animated
{
    MKMapView * mapView = self;
    
    MKMapRect r = MKMapRectNull;
    for (id<MKAnnotation> a in annotations) {
        /*ZAssert([a conformsToProtocol:@protocol(MKAnnotation)], @"ERROR: All elements of the array MUST conform to the MKAnnotation protocol. Element (%@) did not fulfill this requirement", a);*/
        MKMapPoint p = MKMapPointForCoordinate(a.coordinate);
        //MKMapRectUnion performs the union between 2 rects, returning a bigger rect containing both (or just one if the other is null). here we do it for rects without a size (points)
        r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, r.size.width+10000,r.size.height+10000));
    }
//    r.size.width += 10000;
//    r.size.height += 10000;
   r.origin.x -=5000;
    r.origin.y -=5000;
    [mapView setVisibleMapRect:r animated:animated];
    
    
}

@end
