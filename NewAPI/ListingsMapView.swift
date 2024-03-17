//
//  SwiftUIView.swift
//  NewAPI
//
//  Created by Alex Beattie on 3/16/24.
//

import SwiftUI
import MapKit

struct ListingsMapView: View {
    let listing: Value
    
    @State private var region: MKCoordinateRegion
    
    init(listing: Value) {
        self.listing = listing
        
        // Set the initial region of the map based on the listing's coordinates
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: listing.Latitude ?? 0, longitude: listing.Longitude ?? 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [listing]) { listing in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: listing.Latitude ?? 0, longitude: listing.Longitude ?? 0)) {
                // Customize the appearance of the annotation
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
    }
}
struct ListingsMapView_Previews: PreviewProvider {
    static var previews: some View {
        ListingsMapView(listing: Value.sampleMap())
    }
}
extension Value {
    static func sampleMap() -> Value {
        return Value(
            AssociationAmenities: ["Pool", "Gym", "Tennis Court"],
            CommunityFeatures: ["Park", "Playground", "Walking Trails"],
            Disclosures: ["Seller's Disclosure", "HOA Disclosure"],
            LotFeatures: ["Fenced Yard", "Patio", "Garden"],
            ConstructionMaterials: [],
            BuyerAgentEmail: "buyer@example.com",
            ClosePrice: 350000,
            CoListAgentFullName: "Jane Doe",
            ListAgentFullName: "John Smith",
            Latitude: 34.434266,
            Longitude: -119.189006,
            ListPrice: 375000,
            BedroomsTotal: 3,
            LotSizeAcres: 0.25,
            MlsStatus: "Active",
            OffMarketDate: nil,
            OnMarketDate: "33",
            PendingTimestamp: nil,
            Media: [
//                Media(MediaKey: "1", MediaURL:                 KFImage(URL(string: "(media.MediaURL ?? ""), MediaCategory: "Photo"),
//                Media(MediaKey: "2", MediaURL: "https://example.com/image2.jpg", MediaCategory: "Photo")
            ],
            ListingKey: "ABC123",
            UnparsedAddress: "123 Main St, Anytown, CA 12345",
            PostalCode: "12345",
            StateOrProvince: "CA",
            City: "Anytown",
            BathroomsTotalInteger: 2,
            Model: "Modern",
            BuyerOfficeAOR: "Local AOR",
            VirtualTourURLUnbranded: "https://example.com/virtualtour",
            PublicRemarks: "This is a sample public remarks text.",
            BuyerAgentURL: "https://example.com/buyeragent",
            ListAgentURL: "https://example.com/listagent",
            BuildingAreaTotal: 1800,
            BuilderName: "Acme Homes",
            BuyerAgentMlsId: "12345",
            BuyerOfficePhone: "555-1234",
            CloseDate: nil,
            ListingContractDate: Date(),
            ListingId: "XYZ789",
            LivingArea: 1500,
            StreetNumber: "123",
            StreetSuffix: "St",
            StreetName: "Main",
            MemberKey: "ABCD1234"
        )
    }
}
