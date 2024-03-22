import SwiftUI
import MapKit
struct NewMapView: View {
    let listings: [Value] // Assuming the listings are of type `Value`
    
    var body: some View {
        MapOfSoldListings()
    }
}
class SoldListingsViewModel: ObservableObject {
    @Published var soldListings: [SoldListingsAnno] = []
    @Published var selectedItem: SoldListingsAnno?
    @Published var hasMoreData = true
    @Published var isLoading = false
    
    private let baseURL = "https://replication.sparkapi.com/Reso/OData/Property"
    private let token = TOKEN
    private var currentPage = 0
    let itemsPerPage = 25
    var listAgentKey = "20160917171119703445000000"
    
    func fetchSoldListings() {
        isLoading = true
        
        let queryItems = [
            URLQueryItem(name: "$filter", value: "ListAgentKey eq '\(listAgentKey)' and StandardStatus eq 'Closed' and StandardStatus ne 'Expired' and StandardStatus ne 'Canceled'"),
            URLQueryItem(name: "$orderby", value: "ListPrice desc"),
            URLQueryItem(name: "$top", value: "\(itemsPerPage)"),
            URLQueryItem(name: "$skip", value: "\(currentPage * itemsPerPage)"),
            URLQueryItem(name: "$expand", value: "Media"),
        ]
        
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching sold listings: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust the date format if needed
//                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let fetchedData = try decoder.decode(Listing.self, from: data)
                let annotations = fetchedData.value?.compactMap { anno -> SoldListingsAnno? in
                    let title = anno.UnparsedAddress
//                    let listingContractDate = anno.ListingContractDate // Treat ListingContractDate as String

                    let lat = anno.Latitude
                    let lon = anno.Longitude
                    let subTitle = anno.ListPrice
                    let imageURL = URL(string: anno.Media?.first?.MediaURL ?? "")
                    let coordinate = CLLocationCoordinate2D(latitude: lat ?? 0, longitude: lon ?? 0)
                    
                    return SoldListingsAnno(title: title ?? "", coordinate: coordinate, subtitle: subTitle ?? 0, imageURL: imageURL)
                }
                
                DispatchQueue.main.async {
                    self.soldListings.append(contentsOf: annotations ?? [])
                    self.hasMoreData = fetchedData.odataNextLink != nil
                    self.isLoading = false
                }
            } catch {
                print("Error decoding sold listings: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
//    func fetchNextPage() {
//        guard !isLoading else { return }
//        
//        currentPage += 1
//        fetchSoldListings()
//    }
}
struct SoldLocationCell: View {
    let item: SoldListingsAnno
    
    var body: some View {
        HStack {
            AsyncImage(url: item.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 100)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                
                Text(item.formattedPrice)
                    .font(.system(size: 14))
            }
            .padding(.all, 16)
        }
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
    }
}

struct SoldLocationsCarousel: View {
    @Binding var selectedItem: SoldListingsAnno?
    let items: [SoldListingsAnno]
    let onItemSelected: (SoldListingsAnno) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items, id: \.self) { item in
                            SoldLocationCell(item: item)
                                .id(item.id)
                                .frame(width: geometry.size.width - 64)
                                .onTapGesture {
                                    selectedItem = item
                                    onItemSelected(item)
                                    withAnimation {
                                        proxy.scrollTo(item.id, anchor: .center)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .onChange(of: selectedItem) { newValue in
                    if let selectedItem = newValue {
                        withAnimation {
                            proxy.scrollTo(selectedItem.id, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(height: 150)
    }
}

//class SoldListingsViewModel: ObservableObject {
//    @Published var soldListings: [SoldListingsAnno] = []
//    @Published var selectedItem: SoldListingsAnno?
//    
//    func fetchSoldListings() {
//        SoldListings.fetchListing { [weak self] listing in
//            guard let self = self else { return }
//            let annotations = listing.D.Results.compactMap { anno -> SoldListingsAnno? in
//                let title = anno.StandardFields.UnparsedFirstLineAddress
//                let lat = anno.StandardFields.Latitude
//                let lon = anno.StandardFields.Longitude
//                let subTitle = anno.StandardFields.ListPrice
//                let imageURL = URL(string: anno.StandardFields.Photos?[0].Uri640 ?? "")
//                let coordinate = CLLocationCoordinate2D(latitude: lat ?? 0, longitude: lon ?? 0)
//                
//                return SoldListingsAnno(title: title ?? "", coordinate: coordinate, subTitle: subTitle ?? 0, imageURL: imageURL)
//            }
//            DispatchQueue.main.async {
//                self.soldListings = annotations
//            }
//        }
//    }
//}

struct MapOfSoldListings: View {
    @StateObject private var viewModel = SoldListingsViewModel()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.144404, longitude: -118.872124), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: viewModel.soldListings) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    SoldCustomListingAnno(item: item, isSelected: item.id == viewModel.selectedItem?.id) {
                        viewModel.selectedItem = item
                        zoomToSelectedItem()
                    }
                }
            }
            
            SoldLocationsCarousel(selectedItem: $viewModel.selectedItem, items: viewModel.soldListings) { selectedItem in
                zoomToSelectedItem()
            }
        }
        .onAppear {
            viewModel.fetchSoldListings()
        }
        .navigationTitle("Map of Previously Sold")
    }
    
    private func zoomToSelectedItem() {
        guard let selectedItem = viewModel.selectedItem else { return }
        
        let selectedRegion = MKCoordinateRegion(center: selectedItem.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        withAnimation {
            region = selectedRegion
        }
    }
}

struct SoldCustomListingAnno: View {
    let item: SoldListingsAnno
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .foregroundColor(isSelected ? .red : .blue)
            .scaleEffect(isSelected ? 1.5 : 1.0)
            .onTapGesture {
                onTap()
            }
    }
}
struct SoldListingsAnno: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let coordinate: CLLocationCoordinate2D
    let subtitle: Int
    let imageURL: URL?
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: subtitle)) ?? ""
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: Int, imageURL: URL?) {
        self.title = title.localizedCapitalized
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
    
    static func == (lhs: SoldListingsAnno, rhs: SoldListingsAnno) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
