//
//  MKMapView+KSExtensions.h
//  Kuber
//
//  Created by Asif Kamboh on 10/13/15.
//  Copyright (c) 2015 Karwa Solutions. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (KSExtensions)

-(void)ij_setVisibleRectToFitAllLoadedAnnotationsAnimated:(BOOL)animated;
-(void)ij_setVisibleRectToFitAnnotations:(NSArray *)annotations animated:(BOOL)animated;

@end
