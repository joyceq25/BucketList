//
//  ContentView.swift
//  BucketList
//
//  Created by Ping Yun on 10/7/20.
//

import MapKit
import LocalAuthentication
import SwiftUI

struct ContentView: View {
    //stores current center coordinate of the map
    @State private var centerCoordinate = CLLocationCoordinate2D()
    //array that stores all the places the user wants to visit
    @State private var locations = [CodableMKPointAnnotation]()
    //stores selected place
    @State private var selectedPlace: MKPointAnnotation?
    //stores whether or not we are showing place details
    @State private var showingPlaceDetails = false
    //stores whether or not we are showing edit screen
    @State private var showingEditScreen = false
    //tracks whether app is unlocked or not
    @State private var isUnlocked = false 
    
    var body: some View {
        ZStack {
            if isUnlocked {
                MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
                    .edgesIgnoringSafeArea(.all)
                Circle()
                    .fill(Color.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        //button that lets us add place marks to the map
                        Button(action: {
                            //creates MKPointAnnotation with current value of centerCoordinate
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.title = "Example location"
                            newLocation.coordinate = self.centerCoordinate
                            //adds it to locations array
                            self.locations.append(newLocation)
                            //sets selectedPlace property so code knows which place should be edited
                            self.selectedPlace = newLocation
                            //sets showingEditScreen to true when user adds new place to map
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            } else {
                //button that triggers authenticate() method 
                Button("Unlock Places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        
        //alert that shows when showingPlaceDetails becomes true
        .alert(isPresented: $showingPlaceDetails) {
            Alert(title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing place information."), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                //sets showingEditScreen to true when user taps Edit in alert
                self.showingEditScreen = true
            })
        }
        
        //binds showingEditScreen to a sheet so EditView struct gets presented with a place mark at the right time
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        }
        .onAppear(perform: loadData)
    }
    
    //finds app's document directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        //creates URL that points to specific file in documents directory
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        
        //loads data
        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        //checks whether current device is capable of biometric authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                //if it is, starts request and provides a closure to run when it completes
                DispatchQueue.main.async {
                    //if it was successful, sets isUnlocked to true
                    if success {
                        self.isUnlocked = true
                    } else {
                        //error
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
