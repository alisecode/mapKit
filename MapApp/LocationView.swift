//
//  LocationView.swift
//  MapApp
//
//  Created by Alisa Serhiienko on 12.02.2024.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var present: Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var seekDirections: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(mapSelection?.placemark.name ?? "")
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.bottom, 3)
                
                Spacer()
                
                Button {
                    present.toggle()
                    mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
            }
           

            Text(mapSelection?.placemark.title ?? "")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.gray)
                .lineLimit(2)
                .padding(.bottom, 6)
            
  
            

        }
        .padding(.horizontal)
        .onAppear {
            fetchPreview()
            
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            fetchPreview()
        }
        
        if let scene = lookAroundScene {
            LookAroundPreview(initialScene: scene)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
        } else {
            ContentUnavailableView("No preview found", systemImage: "eye.slash")
        }
        
        HStack(spacing: 8) {
                Button {
                    if let mapSelection {
                        mapSelection.openInMaps()
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 170, height: 40)
                        .background(.black)
                        .clipShape(Capsule())
                        
                }
                
                Button {
                    seekDirections = true
                    present = false
                } label: {
                    Text("Show Direction")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 170, height: 40)
                        .background(Color.systemPurple1)
                        .clipShape(Capsule())

                }

        }
    }
}

extension Color {
    static var systemPurple1: Color {
        Color(UIColor(red: 103/255, green: 82/255, blue: 240/255, alpha: 1))
    }
}

extension LocationView {
    func fetchPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}

#Preview {
    LocationView(mapSelection: .constant(nil), present: .constant(false), seekDirections: .constant(false))
}
