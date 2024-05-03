import SwiftUI
import MapKit
import Kingfisher

struct PopDetailsView: View {
    let value: Value
    @State private var selectedAnnotation: MKAnnotation?
    @State private var directionsMapItem: MKMapItem?
    @State private var showDirections = false
    @State private var region: MKCoordinateRegion
    @State private var isFullScreen = false
    
    init(value: Value) {
        self.value = value
        self._region = State(initialValue: MKCoordinateRegion(center: .init(latitude: value.Latitude ?? 0, longitude: value.Longitude ?? 0), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    ImageCarouselView(media: value.Media ?? [])
                        .frame(height: 320)
                    
                    PropertyDetailsView(value: value)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    PropertyDescriptionView(value: value)
                        .padding()
                    
                    Divider()
                    
                    MapView(value: value, selectedAnnotation: $selectedAnnotation, directionsMapItem: $directionsMapItem)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
            .edgesIgnoringSafeArea(.all)

        }
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
struct WebsiteLinkView: View {
    let value: Value
    
    var body: some View {
        HStack {
            if let documentMedia = value.Media?.first(where: { $0.MediaCategory == "Document" }),
               let mediaURL = documentMedia.MediaURL {
                Link(destination: URL(string: mediaURL)!) {
                    Label("Download Document", systemImage: "arrow.down.doc")
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



struct FeatureSection: View {
    let title: String
    let features: [String]
    @State private var expanded = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            lowercaseSmallCaps(title)
                .font(.system(size: 14, weight: .semibold))
            Divider()
            ForEach(expanded ? features : Array(features.prefix(3)), id: \.self) { feature in
                Text(feature)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if features.count > 3 {
                Button(action: {
                    expanded.toggle()
                }) {
                    Text(expanded ? "Show Less" : "Show More")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
        }
        .background(ignoresSafeAreaEdges: .all)
//        .foregroundColor(.orange)
        .frame(width: 200)
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
    
    var body: some View {
        VStack(alignment: .leading) {
            lowercaseSmallCaps(value.MlsStatus ?? "")
                .font(.system(size: 14, weight: .heavy))
            
            
            VStack {
                Text(value.PublicRemarks ?? "")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                .multilineTextAlignment(.leading)
            }
            .padding(.vertical)
            VStack {
                WebsiteLinkView(value: value)
            }
            .padding(.vertical)


            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    if let amenities = value.AssociationAmenities, !amenities.isEmpty {
                        FeatureSection(title: "Association Amenities", features: amenities)
                    }
                    
                    if let communityFeatures = value.CommunityFeatures, !communityFeatures.isEmpty {
                        FeatureSection(title: "Community Features", features: communityFeatures)
                    }
                    
                    if let lotFeatures = value.LotFeatures, !lotFeatures.isEmpty {
                        FeatureSection(title: "Lot Features", features: lotFeatures)
                    }
                    
                    if let lotDisclosures = value.Disclosures, !lotDisclosures.isEmpty {
                        FeatureSection(title: "Disclosures", features: lotDisclosures)
                    }
                    if let constructionMaterials = value.ConstructionMaterials, !constructionMaterials.isEmpty {
                        FeatureSection(title: "Materials", features: constructionMaterials)
                    }
                    if let coolingSystem = value.Cooling, !coolingSystem.isEmpty {
                        FeatureSection(title: "Cooling", features: coolingSystem)
                    }
                    if let heatingSystem = value.Heating, !heatingSystem.isEmpty {
                        FeatureSection(title: "Heating", features: heatingSystem)
                    }
                    if let interiorFeatures = value.InteriorFeatures, !interiorFeatures.isEmpty {
                        FeatureSection(title: "Interior", features: interiorFeatures)
                    }
                    if let viewFeatures = value.View, !viewFeatures.isEmpty {
                        FeatureSection(title: "View Features", features: viewFeatures)
                    }
                    if let windowFeatures = value.WindowFeatures, !windowFeatures.isEmpty {
                        FeatureSection(title: "Window Features", features: windowFeatures)
                    }
                    if let applianceFeatures = value.Appliances, !applianceFeatures.isEmpty {
                        FeatureSection(title: "Appliances", features: applianceFeatures)
                    }
                }
                .padding(.leading, 0) // Remove the leading padding
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
    @Binding var selectedAnnotation: MKAnnotation?
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
            let annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier, mediaURL: parent.value.Media?.first?.MediaURL)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }
    }
}

class CustomAnnotationView: MKAnnotationView {
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, mediaURL: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        addSubview(imageView)
        
        if let mediaURL = mediaURL, let url = URL(string: mediaURL) {
            KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.imageView.image = value.image
                case .failure(_):
                    self?.imageView.image = UIImage(named: "placeholder")
                }
            }
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            Cooling: [],
            Heating: [],
            Electric: [],
            Flooring: [],
            InteriorFeatures: [],
            View: [],
            WindowFeatures:[],
            Appliances: [],
            ConstructionMaterials: [],
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
//            ListingContractDate: Date(),
            ListingId: "XYZ789",
            LivingArea: 1500,
            StreetNumber: "123",
            StreetSuffix: "St",
            StreetName: "Main",
            MemberKey: "ABCD1234"
        )
    }
}
