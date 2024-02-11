//
//  ContentView.swift
//  MapApp
//
//  Created by Alisa Serhiienko on 11.02.2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.region)
    @State private var search = ""
    @State private var results = [MKMapItem]()
    
    @State private var mapSelection: MKMapItem?
    @State private var info = false
    
    @State private var route: MKRoute?
    @State private var mapDestination: MKMapItem?
    @State private var routeDisplay = false
    
    @State private var seekDirections = false
    
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection) {
                        
            Annotation("Me", coordinate: .location) {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(Color.systemPurple1.opacity(0.3))
                    
                    Circle()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color.systemPurple1)
                }
            }
            
            ForEach(results, id: \.self) { item in
                if routeDisplay {
                    if item == mapDestination {
                        let placemark = item.placemark
                        Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
                } else {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.indigo, lineWidth: 6)
            }
        }
        .overlay(alignment: .top) {
            TextField("Find the location", text: $search)
                .font(.system(size: 16))
                .frame(width: 300)
                .padding(10)
                .background(.white)
                .padding()
                .shadow(radius: 8)
        }
        
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()

        }
       
        .onSubmit(of: .text) {
            Task { await search() }
        }
        .onChange(of: seekDirections, { oldValue, newValue in
            if newValue {
                fetchRoute()
            }
        })
        .onChange(of: mapSelection) { oldValue, newValue in
            info = newValue != nil
        }
       
    
            
        .sheet(isPresented: $info, content: {
            LocationView(mapSelection: $mapSelection, present: $info, seekDirections: $seekDirections)
                .presentationDetents([.height(380)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(380)))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        })
    }
}

extension ContentView {
    func search() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        request.region = .region
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: .location))
            request.destination = mapSelection
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                mapDestination = mapSelection
                
                withAnimation(.spring) {
                    routeDisplay = true
                    info = false
                    
                    if let rect = route?.polyline.boundingMapRect, routeDisplay {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}

extension CLLocationCoordinate2D {
    static var location: CLLocationCoordinate2D {
        return .init(latitude: 43.64161207774052, longitude: -79.38569460148615)
    }
}

extension MKCoordinateRegion {
    static var region: MKCoordinateRegion {
        return .init(center: .location, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}
