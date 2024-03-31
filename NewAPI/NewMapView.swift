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
    let itemsPerPage = 10
    var listAgentKey = "20160917171119703445000000"
    var otherAgentKey = "20160917171113923841000000"
    var fenton = "20220924045922314237000000"
    var teamnickandkaren = "20160917171150811658000000"
    var vp = "20220622184809040862000000"
    var ha = "20220414171808273913000000"
    var pm = "20160917171201610393000000"
    func fetchSoldListings() {
        isLoading = true
        
        let queryItems = [
            URLQueryItem(name: "$filter", value: "ListAgentKey eq '\(pm)' and StandardStatus eq 'Closed' and StandardStatus ne 'Expired' and StandardStatus ne 'Canceled'"),
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
    let isSelected: Bool
    let onTap: () -> Void
    
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
        .onTapGesture {
            onTap()
        }
    }
}

struct SoldLocationsCarousel: View {
    @Binding var selectedItem: SoldListingsAnno?
    @Binding var scrollToSelectedItem: Bool // Add this line

    var items: [SoldListingsAnno]
    let onItemSelected: (SoldListingsAnno) -> Void
//    let onZoomToItem: (SoldListingsAnno, Bool) -> Void // Updated closure parameter
    
    private let itemWidth: CGFloat = 300
    private let itemSpacing: CGFloat = 12
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: itemSpacing) {
                    ForEach(items) { item in
                        SoldLocationCell(
                            item: item,
                            isSelected: selectedItem?.id == item.id,
                            onTap: {
                                selectedItem = item
                                onItemSelected(item)
//                                onZoomToItem(item, true) // Pass true for animated zoom
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(item.id, anchor: .center)
                                }
                            }
                        )
                        .frame(width: itemWidth)
                        .id(item.id)
                    }
                }
                .padding(.horizontal, itemSpacing)
            }
            .onChange(of: selectedItem) { newValue in
                if let selectedItem = newValue {
                    onItemSelected(selectedItem)
//                    onZoomToItem(selectedItem, true) // Pass true for animated zoom
                }
            }
            .onChange(of: scrollToSelectedItem) { shouldScroll in // Add this block
                           if shouldScroll {
                               withAnimation {
                                   proxy.scrollTo(selectedItem?.id, anchor: .center)
                               }
                           }
                       }
        }
        .frame(height: 150)
        // Removed the onAppear that attempted to use `proxy` outside its closure
    }
}






struct MapOfSoldListings: View {
    @StateObject private var viewModel = SoldListingsViewModel()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 34.144404, longitude: -118.872124), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var isAnimating = false
    @State private var scrollToSelectedItem = false

    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region, annotationItems: viewModel.soldListings) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        Image(systemName: viewModel.selectedItem?.id == item.id ? "mappin.circle.fill" : "mappin")
                            .foregroundColor(viewModel.selectedItem?.id == item.id ? .red : .blue)
                            .onTapGesture {
                                viewModel.selectedItem = item
                                withAnimation {
                                    isAnimating = true
                                    scrollToSelectedItem = true // Add this line

                                }
                            }
                    }
                }
                
                SoldLocationsCarousel(
                    selectedItem: $viewModel.selectedItem,
                    scrollToSelectedItem: $scrollToSelectedItem, // Pass the binding

                    items: viewModel.soldListings,
                    onItemSelected: { selectedItem in
                        viewModel.selectedItem = selectedItem
                        withAnimation {
                            isAnimating = true
                        }
                    }
                )
            }
            .onAppear {
                viewModel.fetchSoldListings()
            }
            .navigationTitle("Map of Previously Sold")
            .onChange(of: isAnimating) { newValue in
                if newValue {
                    zoomToSelectedItem()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isAnimating = false
                            scrollToSelectedItem = false // Add this line

                        }
                    }
                }
            }
        }
    }
    
    private func zoomToSelectedItem() {
        guard let selectedItem = viewModel.selectedItem else { return }
        
        let zoomRegion = MKCoordinateRegion(center: selectedItem.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        withAnimation(.easeInOut(duration: 0.5)) {
            region = zoomRegion
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
