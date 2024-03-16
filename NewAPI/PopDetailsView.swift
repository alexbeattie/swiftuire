import SwiftUI
import MapKit
import Kingfisher

struct PopDetailsView: View {
    let value: Value
    @State private var selectedAnnotation: MKAnnotation?
//    @State private var presentAlert = false
    @State private var directionsMapItem: MKMapItem?
    @State private var showDirections = false
    @State private var region: MKCoordinateRegion

//    @Environment(\.dismiss) var dismiss
    @State private var isFullScreen = false
    

    init(value: Value) {
        self.value = value
        self._region = State(initialValue: MKCoordinateRegion(center: .init(latitude: value.Latitude ?? 0, longitude: value.Longitude ?? 0), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ImageCarouselView(media: value.Media ?? [])
                    .frame(height: 320)
                
                PropertyDetailsView(value: value)
                    .padding(.horizontal)
                
                Spacer()
                
                WebsiteLinkView(value: value)
                
                PropertyDescriptionView(value: value)
                    .padding()
                
                Divider()
                
//                FullScreenMapToggle(isFullScreen: $isFullScreen)
//                    .padding()
                MapView(value: value, selectedAnnotation: $selectedAnnotation, directionsMapItem: $directionsMapItem)
                    .frame(height: isFullScreen ? UIScreen.main.bounds.height : 200)
                    .edgesIgnoringSafeArea(isFullScreen ? .all : [])

            }
            .ignoresSafeArea()
        }
        .transition(.slide)
    }


}

struct ImageCarouselView: View {
    let media: [Value.Media]
    
    var body: some View {
        TabView {
            ForEach(media, id: \.MediaKey) { media in
                KFImage(URL(string: media.MediaURL ?? ""))
                    .resizable()
                    .scaledToFill()
            }
        }
        .tabViewStyle(.page)
//        .overlay(alignment: .topLeading) {
//            DismissButton()
//                .padding(62)
//        }
    }
}



struct PropertyDetailsView: View {
    let value: Value
    
    var body: some View {
        
        VStack {
            HStack(alignment: .bottom, spacing: 8) {
                VStack (alignment: .leading){
                    HStack {
                        Text("$\(value.ListPrice ?? 0)")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Label("\(value.BedroomsTotal ?? 0) Beds", systemImage: "bed.double")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Label("\(value.BathroomsTotalInteger ?? 0) Baths", systemImage: "bathtub")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("\(value.BuildingAreaTotal ?? 0) sqft")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
            }
        }
        
    }
    
}

struct PropertyDetailItem: View {
    let title: String
    let subtitle: String
    let imageName: String?
    
    init(title: String, subtitle: String, imageName: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            
            if let imageName = imageName {
                Label(subtitle, systemImage: imageName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            } else {
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct WebsiteLinkView: View {
    let value: Value
    
    var body: some View {
        HStack {
            if let firstMedia = value.Media?.first, firstMedia.MediaCategory == "Document", let mediaURL = firstMedia.MediaURL {
                Link("Website", destination: URL(string: mediaURL)!)
            }
        }
    }
}
func lowercaseSmallCaps(_ text: String) -> some View {
    Text(text.uppercased())
//        .font(.system(.body, design: .default))
//        .fontWeight(.regular)
//        .textCase(.lowercase)
}

struct PropertyDescriptionView: View {
    let value: Value
    @State private var expandedAmenities = false
    @State private var expandedCommunityFeatures = false
    @State private var expandedLotFeatures = false
    @State private var expandedDisclosures = false
    var body: some View {
        VStack(alignment: .leading) {
            lowercaseSmallCaps(value.MlsStatus ?? "")
                .font(.system(size: 14, weight: .heavy))
            
            Text(value.PublicRemarks ?? "")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Group {
                    HStack(alignment: .top) {
                        if let amenities = value.AssociationAmenities, !amenities.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                lowercaseSmallCaps("Association Amenities")
                                    .font(.system(size: 14, weight: .semibold))

                                ForEach(expandedAmenities ? amenities : Array(amenities.prefix(3)), id: \.self) { amenity in
                                    Text(amenity)
                                }
                                
                                if amenities.count > 3 {
                                    Button(action: {
                                        expandedAmenities.toggle()
                                    }) {
                                        Text(expandedAmenities ? "Show Less" : "Show More")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                        
                        if let communityFeatures = value.CommunityFeatures, !communityFeatures.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                lowercaseSmallCaps("Community Features")
                                    .font(.system(size: 14, weight: .semibold))

                                ForEach(expandedCommunityFeatures ? communityFeatures : Array(communityFeatures.prefix(3)), id: \.self) { feature in
                                    Text(feature)
                                }
                                
                                if communityFeatures.count > 3 {
                                    Button(action: {
                                        expandedCommunityFeatures.toggle()
                                    }) {
                                        Text(expandedCommunityFeatures ? "Show Less" : "Show More")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                        
                        if let lotFeatures = value.LotFeatures, !lotFeatures.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                lowercaseSmallCaps("Lot Features")
                                    .font(.system(size: 14, weight: .semibold))

                                ForEach(expandedLotFeatures ? lotFeatures : Array(lotFeatures.prefix(3)), id: \.self) { feature in
                                    Text(feature)
                                        .font(.subheadline)
                                }
                                
                                if lotFeatures.count > 3 {
                                    Button(action: {
                                        expandedLotFeatures.toggle()
                                    }) {
                                        Text(expandedLotFeatures ? "Show Less" : "Show More")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                        
                        if let lotDisclosures = value.Disclosures, !lotDisclosures.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                lowercaseSmallCaps("Disclosures")
                                    .font(.system(size: 14, weight: .semibold))

                                ForEach(expandedDisclosures ? lotDisclosures : Array(lotDisclosures.prefix(3)), id: \.self) { disclosure in
                                    Text(disclosure)
                                        .font(.subheadline)
                                }
                                
                                if lotDisclosures.count > 3 {
                                    Button(action: {
                                        expandedDisclosures.toggle()
                                    }) {
                                        Text(expandedDisclosures ? "Show Less" : "Show More")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                    }
                }
                .padding(.leading, -12) // Remove the leading padding
                
            }
        }
        
    }
}
       
//struct FullScreenMapToggle: View {
//    @Binding var isFullScreen: Bool
//    
//    var body: some View {
//        Toggle("Full Screen", isOn: $isFullScreen)
//    }
//}

struct MapView: UIViewRepresentable {
    let value: Value
//    let isFullScreen: Bool
    @Binding var selectedAnnotation: MKAnnotation?
//    @Binding var presentAlert: Bool
    @Binding var directionsMapItem: MKMapItem?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.mapType = .hybrid
        view.delegate = context.coordinator
        
        let coordinate = CLLocationCoordinate2D(latitude: value.Latitude ?? 0, longitude: value.Longitude ?? 0)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = value.StreetName

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        annotation.subtitle = numberFormatter.string(from: NSNumber(value: value.ListPrice ?? 0))
        
        view.addAnnotation(annotation)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            parent.selectedAnnotation = annotation
            
            let placemark = MKPlacemark(coordinate: annotation.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title ?? ""
            
//            parent.presentAlert = true
            parent.directionsMapItem = mapItem
            
                           let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                           mapItem.openInMaps(launchOptions: launchOptions)
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.selectedAnnotation = nil
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else {
                return nil
            }
            
            let annotationIdentifier = "AnnotationIdentifier"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                annotationView?.canShowCallout = true
                annotationView?.animatesWhenAdded = true
                
                let rightButton = UIButton(type: .detailDisclosure)
                rightButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                rightButton.setImage(UIImage(named: "small-pin-map-7"), for: .normal)
                annotationView?.rightCalloutAccessoryView = rightButton
//                annotationView?.isSelected = true
                
                let leftIconView = UIImageView()
                leftIconView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                leftIconView.contentMode = .scaleAspectFill
                leftIconView.clipsToBounds = true
                
                if let mediaURL = parent.value.Media?.first?.MediaURL, let url = URL(string: mediaURL) {
                    leftIconView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.2))], completionHandler: { result in
                        switch result {
                        case .success(_):
                            annotationView?.leftCalloutAccessoryView = leftIconView
                        case .failure(_):
                            leftIconView.image = UIImage(named: "placeholder")
                            annotationView?.leftCalloutAccessoryView = leftIconView
                        }
                    })
                } else {
                    leftIconView.image = UIImage(named: "placeholder")
                    annotationView?.leftCalloutAccessoryView = leftIconView
                }
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
}
struct PopDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PopDetailsView(value: Value.sample())
            .preferredColorScheme(.dark)
    }
}
extension Value {
    static func sample() -> Value {
        return Value(
            AssociationAmenities: ["Pool", "Gym", "Tennis Court"],
            CommunityFeatures: ["Park", "Playground", "Walking Trails"],
            Disclosures: ["Seller's Disclosure", "HOA Disclosure"],
            LotFeatures: ["Fenced Yard", "Patio", "Garden"],
            BuyerAgentEmail: "buyer@example.com",
            ClosePrice: 350000,
            CoListAgentFullName: "Jane Doe",
            ListAgentFullName: "John Smith",
            Latitude: 37.7749,
            Longitude: -122.4194,
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
