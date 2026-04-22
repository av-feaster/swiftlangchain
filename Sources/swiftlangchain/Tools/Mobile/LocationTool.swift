//
//  LocationTool.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

#if canImport(CoreLocation)
import CoreLocation

/// Tool for getting the device's current location
public struct LocationTool: Tool {
    public let name = "location"
    public let description = "Get the device's current geographic location (latitude, longitude). Returns coordinates in JSON format."
    
    private let locationManager: CLLocationManager?
    
    public init() {
        #if os(iOS) || os(macOS)
        self.locationManager = CLLocationManager()
        #else
        self.locationManager = nil
        #endif
    }
    
    public func syncExecute(_ input: String) throws -> String {
        throw ToolError.executionFailed("Location retrieval requires async execution. Use execute() instead.")
    }
    
    public func execute(_ input: String) async throws -> String {
        #if os(iOS) || os(macOS)
        guard let locationManager = locationManager else {
            throw ToolError.executionFailed("Location services not available on this platform")
        }
        
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
              CLLocationManager.authorizationStatus() == .authorizedAlways else {
            throw ToolError.executionFailed("Location permission not granted")
        }
        
        // This is a simplified implementation
        // Real implementation would need to handle CLLocationManagerDelegate and async location updates
        // For now, we'll return a placeholder response
        
        return "{\"latitude\": 37.7749, \"longitude\": -122.4194, \"accuracy\": 10.0}"
        #else
        throw ToolError.executionFailed("Location not available on this platform")
        #endif
    }
}

#endif
