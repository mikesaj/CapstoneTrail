//
// Created by Joohyung Ryu on 2017. 3. 5..
// Copyright (c) 2017 MSD. All rights reserved.
//

import UIKit
import MapKit


extension TrailMapViewController {

    // Find nearest trail
    func tappedAction(tapRecoginzer: UIGestureRecognizer) {

        print("tapped!")

        // Convert tapped CGPoint to coordinates
        let tapPoint = tapRecoginzer.location(in: trailMapView)
        print(tapPoint)
        let tapCoordinate = trailMapView.convert(tapPoint, toCoordinateFrom: trailMapView)
        print(tapCoordinate)
        let tapMapPoint = MKMapPointForCoordinate(tapCoordinate)
        print(tapMapPoint)

        // Find tapped polyline data
        var nearestTrailDistanceFromTapPoint: Double = 50
        let minimumTrailDistance: Double = 50
        var nearestTrailPolylineFromTapPoint = TrailPolyline()
        // Compare them
        for polyline in trailMapView.overlays {
            let distance: Double = getDistance(tapMapPoint: tapMapPoint, polyline: polyline as! TrailPolyline)
            if(distance < nearestTrailDistanceFromTapPoint) {
                nearestTrailDistanceFromTapPoint = distance
                nearestTrailPolylineFromTapPoint = polyline as! TrailPolyline
            }
        }

        if(nearestTrailDistanceFromTapPoint < minimumTrailDistance) {
            print(nearestTrailDistanceFromTapPoint)
            print(nearestTrailPolylineFromTapPoint.trail?.pathType)
        } else {
            print("Nothing")
        }
    }

    // Get distance from tapped point and trail coordinate
    func getDistance(tapMapPoint: MKMapPoint, polyline: TrailPolyline) -> Double {

        var distance: Double = 100
        var linePoints: Array<MKMapPoint> = []

        for point in UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount) {
            linePoints.append(point)
        }

        for n in 0 ... linePoints.count - 2 {
            let ptA = linePoints[n]
            let ptB = linePoints[n + 1]
            let xDelta = ptB.x - ptA.x
            let yDelta = ptB.y - ptA.y
            if(xDelta == 0.0 && yDelta == 0.0) {
                // Points must not be equal
                continue
            }
            let u: Double = ((tapMapPoint.x - ptA.x) * xDelta + (tapMapPoint.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest = MKMapPoint()
            if(u < 0.0) {
                ptClosest = ptA
            } else if(u > 1.0) {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
            }
            distance = min(distance, MKMetersBetweenMapPoints(ptClosest, tapMapPoint))
        }

        return distance
    }
}
