//
//  TSQuadTree.m
//  Civitates
//
//  Created by Sheriff III, Jack B on 2/3/14.
//  Copyright (c) 2014 Sheriff III, Jack B. All rights reserved.
//

#import "TSQuadTree.h"

// Free functions
BOOL LocationInRegion(CLLocationCoordinate2D location, MKCoordinateRegion region)
{
    // Note that this does not correctly handle regions that cross from +180 degrees longitude to -180 degrees longitude
    
    CLLocationDegrees maxLatitude = region.center.latitude  + (region.span.latitudeDelta  / 2.0);
    CLLocationDegrees minLatitude = region.center.latitude  - (region.span.latitudeDelta  / 2.0);
    CLLocationDegrees maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0);
    CLLocationDegrees minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0);
    
    if (location.latitude  <= maxLatitude && location.latitude  >= minLatitude && location.longitude <= maxLongitude && location.longitude >= minLongitude) {
        return YES;
    }
    else {
        return NO;
    }
}

BOOL RegionsIntersect(MKCoordinateRegion region1, MKCoordinateRegion region2)
{
    CLLocationDegrees maxLatitude1 = region1.center.latitude  + (region1.span.latitudeDelta  / 2.0);
    CLLocationDegrees minLatitude1 = region1.center.latitude  - (region1.span.latitudeDelta  / 2.0);
    CLLocationDegrees maxLongitude1 = region1.center.longitude + (region1.span.longitudeDelta / 2.0);
    CLLocationDegrees minLongitude1 = region1.center.longitude - (region1.span.longitudeDelta / 2.0);

    CLLocationDegrees maxLatitude2 = region2.center.latitude  + (region2.span.latitudeDelta  / 2.0);
    CLLocationDegrees minLatitude2 = region2.center.latitude  - (region2.span.latitudeDelta  / 2.0);
    CLLocationDegrees maxLongitude2 = region2.center.longitude + (region2.span.longitudeDelta / 2.0);
    CLLocationDegrees minLongitude2 = region2.center.longitude - (region2.span.longitudeDelta / 2.0);
    
    // Test for overlap in latitude, then test for overlap in longitude
    if ((maxLatitude1 > minLatitude2 && minLatitude1 < maxLatitude2) || (maxLatitude2 > minLatitude1 && minLatitude2 < maxLatitude1)) {
        if ((maxLongitude1 > minLongitude2 && minLongitude1 < maxLongitude2) || (maxLongitude2 > minLongitude1 && minLongitude2 < maxLongitude1)) {
            return YES;
        }
    }
    
    return NO;
}

@interface TSQuadTreeData : NSObject

@property id object;
@property CLLocationCoordinate2D location;

+ (TSQuadTreeData *)quadTreeDataWithObject:(id)object atLocation:(CLLocationCoordinate2D)location;

@end

@implementation TSQuadTreeData

+ (TSQuadTreeData *)quadTreeDataWithObject:(id)object atLocation:(CLLocationCoordinate2D)location
{
    TSQuadTreeData *data = [[TSQuadTreeData alloc] init];
    data.object = object;
    data.location = location;

    return data;
}

@end

@interface TSQuadTreeNode : NSObject

@property TSQuadTreeNode *northWestNode;
@property TSQuadTreeNode *northEastNode;
@property TSQuadTreeNode *southWestNode;
@property TSQuadTreeNode *southEastNode;
@property MKCoordinateRegion boundingBox;
@property NSMutableArray *data;
@property int bucketSize;

+ (TSQuadTreeNode *)quadTreeNodeWithBoundingBox:(MKCoordinateRegion)boundingBox bucketSize:(int)bucketSize;

- (BOOL)insertData:(TSQuadTreeData *)data;
- (void)subdivideNode;
- (NSSet *)objectsInBoundingBox:(MKCoordinateRegion)boundingBox;

@end

@implementation TSQuadTreeNode

+ (TSQuadTreeNode *)quadTreeNodeWithBoundingBox:(MKCoordinateRegion)boundingBox bucketSize:(int)bucketSize
{
    TSQuadTreeNode *node = [[TSQuadTreeNode alloc] init];
    node.boundingBox = boundingBox;
    node.data = [[NSMutableArray alloc] init];
    node.bucketSize = bucketSize;
    
    return node;
}

- (BOOL)insertData:(TSQuadTreeData *)data
{
    // Bail if our coordinate is not in the boundingBox
    if (!LocationInRegion(data.location, self.boundingBox)) {
        return NO;
    }
    
    // Add the data to the data array
    if (self.data.count < self.bucketSize) {
        [self.data addObject:data];
        return YES;
    }
    
    // This data would exceed the node's bucket size
    // Check to see if the current node is a leaf, if it is, split the node
    if (self.northWestNode == nil) {
        [self subdivideNode];
    }
    
    // Insert the data into the correct quad
    if (data.location.latitude > self.boundingBox.center.latitude && data.location.longitude > self.boundingBox.center.longitude) {
        return [self.northEastNode insertData:data];
    }
    else if (data.location.latitude > self.boundingBox.center.latitude) {
        return [self.northWestNode insertData:data];
    }
    else if (data.location.longitude > self.boundingBox.center.longitude) {
        return [self.southEastNode insertData:data];
    }
    else {
        return [self.southWestNode insertData:data];
    }
}

- (void)subdivideNode
{
    CLLocationDegrees newlatitudeDelta = self.boundingBox.span.latitudeDelta / 2.0;
    CLLocationDegrees newLongitudeDelta = self.boundingBox.span.longitudeDelta / 2.0;
    
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(newlatitudeDelta, newLongitudeDelta);
    
    CLLocationDegrees northLatitude = self.boundingBox.center.latitude + (newlatitudeDelta / 2.0);
    CLLocationDegrees southLatitude = self.boundingBox.center.latitude - (newlatitudeDelta / 2.0);
    CLLocationDegrees eastLongitude = self.boundingBox.center.longitude + (newLongitudeDelta / 2.0);
    CLLocationDegrees westLongitude = self.boundingBox.center.longitude - (newLongitudeDelta / 2.0);
    
    // Northeast node
    CLLocationCoordinate2D neCenter = CLLocationCoordinate2DMake(northLatitude, eastLongitude);
    MKCoordinateRegion neBox = MKCoordinateRegionMake(neCenter, newSpan);
    self.northEastNode = [TSQuadTreeNode quadTreeNodeWithBoundingBox:neBox bucketSize:self.bucketSize];
    
    // Northwest node
    CLLocationCoordinate2D nwCenter = CLLocationCoordinate2DMake(northLatitude, westLongitude);
    MKCoordinateRegion nwBox = MKCoordinateRegionMake(nwCenter, newSpan);
    self.northWestNode = [TSQuadTreeNode quadTreeNodeWithBoundingBox:nwBox bucketSize:self.bucketSize];
    
    // Southeast node
    CLLocationCoordinate2D seCenter = CLLocationCoordinate2DMake(southLatitude, eastLongitude);
    MKCoordinateRegion seBox = MKCoordinateRegionMake(seCenter, newSpan);
    self.southEastNode = [TSQuadTreeNode quadTreeNodeWithBoundingBox:seBox bucketSize:self.bucketSize];
    
    // Southwest node
    CLLocationCoordinate2D swCenter = CLLocationCoordinate2DMake(southLatitude, westLongitude);
    MKCoordinateRegion swBox = MKCoordinateRegionMake(swCenter, newSpan);
    self.southWestNode = [TSQuadTreeNode quadTreeNodeWithBoundingBox:swBox bucketSize:self.bucketSize];
}

- (NSSet *)objectsInBoundingBox:(MKCoordinateRegion)boundingBox
{
    NSMutableSet *tempSet = [[NSMutableSet alloc] init];
    
    if (RegionsIntersect(boundingBox, self.boundingBox)) {
        // Check data held in this node
        for (TSQuadTreeData *data in self.data) {
            if (LocationInRegion(data.location, boundingBox)) {
                [tempSet addObject:data.object];
            }
        }
        
        // Check data in child nodes
        [tempSet unionSet:[self.southEastNode objectsInBoundingBox:boundingBox]];
        [tempSet unionSet:[self.southWestNode objectsInBoundingBox:boundingBox]];
        [tempSet unionSet:[self.northEastNode objectsInBoundingBox:boundingBox]];
        [tempSet unionSet:[self.northWestNode objectsInBoundingBox:boundingBox]];
    }

    return tempSet.copy;
}


@end

@interface TSQuadTree ()

@property TSQuadTreeNode *rootNode;

@end

@implementation TSQuadTree

- (instancetype)initWithBoundingBox:(MKCoordinateRegion)boundingBox bucketSize:(int)bucketSize
{
    self = [super init];
    if (self) {
        self.rootNode = [TSQuadTreeNode quadTreeNodeWithBoundingBox:boundingBox bucketSize:bucketSize];
    }

    return self;
}

- (void)addObject:(id)object atLocation:(CLLocationCoordinate2D)location
{
    TSQuadTreeData *data = [TSQuadTreeData quadTreeDataWithObject:object atLocation:location];
    [self.rootNode insertData:data];
}

- (NSSet *)objectsWithinRegion:(MKCoordinateRegion)region
{
    NSMutableSet *tempSet = [[NSMutableSet alloc] init];
    [tempSet unionSet:[self.rootNode objectsInBoundingBox:region]];
     
    return tempSet.copy;
}

@end
