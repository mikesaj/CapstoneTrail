//
// Created by Joohyung Ryu on 2017. 3. 5..
// Copyright (c) 2017 MSD. All rights reserved.
//

import UIKit
import MapKit


extension TrailMapViewController {

    // Find nearest trail
    func tappedAction(tapRecoginzer: UIGestureRecognizer) {

        // Convert tapped CGPoint to coordinates
        let tapPoint = tapRecoginzer.location(in: trailMapView)
        let tapCoordinate = trailMapView.convert(tapPoint, toCoordinateFrom: trailMapView)
        let tapMapPoint = MKMapPointForCoordinate(tapCoordinate)

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

        trail = nearestTrailPolylineFromTapPoint.trail

        if(nearestTrailDistanceFromTapPoint < minimumTrailDistance) {
            showTrailData(trailData: nearestTrailPolylineFromTapPoint)
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

    // Show trail information
    func showTrailData(trailData: TrailPolyline) {

        // Clear all annotations
        let allAnnotations = trailMapView.annotations
        trailMapView.removeAnnotations(allAnnotations)

        // Get trail object
        guard let trail: Trail = trailData.trail else { return }

        // Create annotation
        let trailAnnotation = MKPointAnnotation()
        trailAnnotation.coordinate = trailData.coordinate
        trailAnnotation.title = trailData.trail?.pathType
        trailAnnotation.subtitle = String(format: "%.0f m, %.0f minute by walk", trail.length, trail.travelTime)
        trailMapView.addAnnotation(trailAnnotation)
        let deadlineTime = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.trailMapView.selectAnnotation(trailAnnotation, animated: true)
        }
    }

    // Customise annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        } else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "Flag")
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true

            return annotationView
        }
    }

    // Move to trail detail view
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        guard let trailDetailViewController = UIStoryboard(name: "TrailDetail", bundle: nil).instantiateViewController(withIdentifier: "TrailDetail") as? TrailDetailViewController else { return }

        trailDetailViewController.trail = TrailUtils.searchTrail(id: trail.id, area: trail.area)

        self.present(trailDetailViewController, animated: true, completion: nil)
    }
}
