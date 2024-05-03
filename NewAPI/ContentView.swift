import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var vm = ListingPublisherViewModel()
    @State private var showingSheets: [String: Bool] = [:]
    @State private var destinationSearchView = false
    
    var body: some View {
//        MainTabView()

        VStack(alignment: .leading, spacing: 8.0) {
            NavigationView {
                GeometryReader { geometry in
                    
                    ScrollView {
                        VStack {
                            
                            ForEach(Array(vm.results).sorted(by: { $0.ListPrice ?? 0 > $1.ListPrice ?? 0 }), id: \.ListingKey) { listing in
                                NavigationLink {
                                    NavigationLazyView(PopDetailsView(value: listing))
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            
                                            AsyncImage(url: URL(string: listing.Media?.first?.MediaURL ?? "")) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .clipped()
                                                        .ignoresSafeArea()
                                                        .overlay(alignment: .bottom) {
                                                            ImageOverlayView(listing: listing)
                                                        }
                                                case .failure(_):
                                                    ProgressView()
                                                        .frame(width: 50, height: 50)
                                                        .progressViewStyle(CircularProgressViewStyle())
                                                        .onAppear {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                                // Retry loading the image after a 1-second delay
                                                                // You can adjust the delay as needed
                                                                vm.objectWillChange.send()
                                                            }
                                                        }
                                                    
                                                case .empty:
                                                    ZStack {
                                                        Color.black
                                                        
                                                        ProgressView()
                                                            .frame(width: 50, height: 50)
                                                            .progressViewStyle(CircularProgressViewStyle())
                                                    }
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }
                                        
                                        HStack(alignment: .center) {
                                            ListingDetailsView(listing: listing)
                                        }
                                    }
                                }
                                
                                .padding(.bottom)
                            }
                            
                            if vm.isLoading {
                                ProgressView()
                            } else if vm.hasMoreData {
                                
                                HStack {
                                    Button(action: {
                                        Task {
                                            await vm.fetchNextPage(mlsServiceKey: vm.mlsClaw)
                                        }
                                        
                                    }) {
                                        Label("Load More", systemImage: "arrow.forward")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.gray)
                                        
                                        //                                    Text("Load More")
                                        //                                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                    }
                                }
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 100, trailing: 10))
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                                    .ignoresSafeArea()
                }
                .preferredColorScheme(.dark)
            }
        }
        .task {
            await vm.fetchAllMlsServices()

//            await vm.fetchProducts()
        }
    }
}

 

struct ImageOverlayView: View {
    let listing: Value
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("$\(listing.ListPrice ?? 0)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                }
                Spacer()
                
                VStack {
                    Text("\(listing.Model ?? "")")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(.gray))
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                }
                .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                Spacer()
                
                MlsStatusView(listing: listing)
                    .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                Spacer()
            }
        }
        .background(Color.black.opacity(0.5))
    }
}

struct MlsStatusView: View {
    let listing: Value
    
    var body: some View {
        VStack {
            if listing.MlsStatus == "Active" {
                Text(listing.MlsStatus ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
            } else if listing.MlsStatus == "Pending" || listing.MlsStatus == "Active Under Contract" {
                Text(listing.MlsStatus ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.red)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
            } else {
                Text(listing.MlsStatus ?? "Unknown Status")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.gray)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
            }
        }
    }
}

struct ListingDetailsView: View {
    let listing: Value
    @State private var showingSheet = false

//    @Binding var showingSheet: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                ListingRowView(listing: listing)
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .center)
            }
            Text(listing.ListAgentFullName ?? "")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
            Text(listing.CoListAgentFullName ?? "")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)

            Button("VIEW DETAILS") {
                showingSheet.toggle()
                    
                    
            }
            .foregroundColor(.primary)
            .sheet(isPresented: $showingSheet) {
                PopDetailsView(value: listing)
            }
            .foregroundColor(.primary)


            .padding(.horizontal)
        }
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
