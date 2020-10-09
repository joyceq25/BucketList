//
//  MapView.swift
//  BucketList
//
//  Created by Ping Yun on 10/8/20.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    //keepts track of center coordinate
    @Binding var centerCoordinate: CLLocationCoordinate2D
    //tracks what place was actually selected
    @Binding var selectedPlace: MKPointAnnotation?
    //tracks whether we should show place details or not
    @Binding var showingPlaceDetails: Bool
    //holds locations to be passed to MapView
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    //checks whether two annotation arrays contain same number of items, if not removes existing annotations and adds them again
    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        //updates centerCoordinate property as map moves around 
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            //unique identifier for view reuse
            let identifier = "Placemark"
            
            //attemps to find a view we can recycle
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            //we didn't find one; make a new one
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                //allow this to show pop up information
                annotationView?.canShowCallout = true
                
                //attach an information button to the view
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                //we have a view to reuse, so give it the new annotation
                annotationView?.annotation = annotation
            }
            
            //whether it's a new view or recyled view, send it back
            return annotationView
        }
        
        //method called when i button for an annotation is tapped
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            //checks whether we have an MKAnnotationView
            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            
            //if so, uses it to set selectedPlace property of parent MapView, sets showingPlaceDetails to true
            parent.selectedPlace = placemark
            parent.showingPlaceDetails = true
        }
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2002 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(centerCoordinate:  .constant(MKPointAnnotation.example.coordinate), selectedPlace: .constant(MKPointAnnotation.example), showingPlaceDetails: .constant(false), annotations: [MKPointAnnotation.example])
    }
}
