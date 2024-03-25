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
                    let address = anno.UnparsedAddress // Extract the address value
                    let listPrice = anno.ListPrice // Extract the list price value
                    let lat = anno.Latitude
                    let lon = anno.Longitude
                    let subTitle = anno.ListPrice
                    let imageURL = URL(string: anno.Media?.first?.MediaURL ?? "")
                    let coordinate = CLLocationCoordinate2D(latitude: lat ?? 0, longitude: lon ?? 0)
                    
                    return SoldListingsAnno(title: title ?? "", coordinate: coordinate, subtitle: subTitle ?? 0, imageURL: imageURL, address: address ?? "", listPrice: listPrice ?? 0)
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
            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    
                    .lineLimit(1)
                    .foregroundColor(.black)

                
                Text(item.formattedPrice)
                    .font(.system(size: 14))
                    .foregroundColor(.black)

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
    var items: [SoldListingsAnno]
    let onItemSelected: (SoldListingsAnno) -> Void

    private let itemWidth: CGFloat = 300
    private let itemSpacing: CGFloat = 12

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(items) { item in
                        SoldLocationCell(item: item)
                            .frame(width: itemWidth)
                            .id(item.id)
                            .onTapGesture {
                                selectedItem = item
                                onItemSelected(item)
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(item.id, anchor: .center)
                                }
                            }
                    }
                }
                .padding(.horizontal, itemSpacing)
            }
            .onChange(of: selectedItem) { _ in
                if let selectedItem = selectedItem {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(selectedItem.id, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 150)
        // Removed the onAppear that attempted to use `proxy` outside its closure
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
//    @State private var showingDetailSheet = false // State for showing the detail sheet/modal
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Inside MapOfSoldListings
                Map(coordinateRegion: $region, annotationItems: viewModel.soldListings) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        Image(systemName: viewModel.selectedItem?.id == item.id ? "mappin.circle.fill" : "mappin")
                            .foregroundColor(viewModel.selectedItem?.id == item.id ? .red : .blue)
                            .onTapGesture {
                                viewModel.selectedItem = item
                                zoomToSelectedItem() // Ensure this correctly zooms into the selected item's location.
                            }
                    }
                }




                SoldLocationsCarousel(selectedItem: $viewModel.selectedItem, items: viewModel.soldListings) { selectedItem in
                    // Here, the selectedItem state is updated, which can trigger UI updates or actions.
//                    showingDetailSheet = true
                }
//                .sheet(isPresented: $showingDetailSheet) {
//                    // Present the detail view for the selected item.
//                    if let selectedItem = viewModel.selectedItem {
//                        ListingDetailView(listing: selectedItem)
//                    }
//                }
            }
            .onAppear {
                viewModel.fetchSoldListings()
            }
            .navigationTitle("Map of Previously Sold")
        }
    }
    private func zoomToSelectedItem() {
        guard let selectedItem = viewModel.selectedItem else { return }
        
        let selectedRegion = MKCoordinateRegion(center: selectedItem.coordinate, latitudinalMeters: 500, longitudinalMeters: 500) // Adjust the zoom level as needed
        
        withAnimation(.easeOut(duration: 0.5)) {
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
    let address: String
    let listPrice: Int
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: listPrice)) ?? ""
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: Int, imageURL: URL?, address: String, listPrice: Int) {
        self.title = title.localizedCapitalized
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.address = address
        self.listPrice = listPrice
    }
    
    static func == (lhs: SoldListingsAnno, rhs: SoldListingsAnno) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
