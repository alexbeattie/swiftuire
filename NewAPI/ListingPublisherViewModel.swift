import Foundation

@MainActor
class ListingPublisherViewModel: ObservableObject {
    @Published var results = [Value]()
    @Published var listings = [Listing]()
    
    @Published var hasMoreData = true
    @Published var isLoading = false

    
    
    private let baseURL = "https://replication.sparkapi.com/Reso/OData/Property"
    private let token = TOKEN
    private var currentPage = 0
    let itemsPerPage = 5
    var teamnickandkaren = "20180828211801958268000000"
    var vanparys = "207092085"
    var ok = "20160917164830438874000000"
    var compass = "20180423214801878673000000"
    var crystal = "20160917170949016404000000"
    var listAgentKey = "20160917171119703445000000"
    var otherAgentKey = "20160917171113923841000000"
    var laporta = "20160917171157276685000000"
    var officeKey = "20160917164910780153000000"
    var memberKey = "20160917171040502037000000"
    var kirkman = "20200702220937059314000000"
    var kramer = "20200702220640427118000000"
    var barbara = "20160726143802546977000000"
    
    
    func fetchProducts() async {
        isLoading = true

        let queryItems = [
            
//            URLQueryItem(name: "$filter", value: "(MlsStatus ne 'Active') and ListOfficeKey eq '\(officeKey)' and StandardStatus ne 'Closed' and StandardStatus ne 'Expired' and StandardStatus ne 'Canceled'"),
            
            //van parys
            URLQueryItem(name: "$filter", value: "ListAgentKey eq '\(listAgentKey)' and StandardStatus eq 'Closed' and StandardStatus ne 'Expired' and StandardStatus ne 'Canceled'"),

//            URLQueryItem(name: "$filter", value: "MlsStatus eq 'Pending'"),
            //all past 'Sold' Sherwood listings query
//            URLQueryItem(name: "$filter", value: "ListOfficeKey eq '\(officeKey)' and StandardStatus eq 'Closed' and StandardStatus ne 'Expired' and StandardStatus ne 'Canceled'"),
            URLQueryItem(name: "$orderby", value: "ListPrice desc"),
//            URLQueryItem(name: "$filter", value: "ListAgentKey eq '\(crystal)' and StandardStatus ne 'Closed' and StandardStatus ne 'Expired' and StandardStatus ne 'Canceled'"),
            URLQueryItem(name: "$top", value: "\(itemsPerPage)"),
            URLQueryItem(name: "$skip", value: "\(currentPage * itemsPerPage)"),
            URLQueryItem(name: "$expand", value: "Media"),
//            URLQueryItem(name: "$select", value: "ListPrice,MlsStatus,BuildingAreaTotal,ArchitecturalStyle,BedroomsTotal,BathroomsTotalInteger,BuyerAgentEmail,CloseDate,ClosePrice,DaysOnMarket,DocumentsCount,GarageSpaces,Inclusions,Latitude,Longitude,ListAgentKey,ListPrice,ListingContractDate,ListingId,ListingKey,LivingArea,LotSizeAcres,OffMarketDate,OnMarketDate,OriginalListPrice,PendingTimestamp,Model,AssociationAmenities,AssociationName,ListOfficePhone,AssociationFee,BathroomsTotalDecimal,BuilderName,CoListAgentEmail,ListAgentEmail,CommunityFeatures,ConstructionMaterials,Disclosures,DocumentsAvailable,DocumentsChangeTimestamp,InteriorFeatures,Levels,LotFeatures,LotSizeAcres,LotSizeArea,MajorChangeTimestamp,Model,ModificationTimestamp,OnMarketDate,OtherStructures,ParkingFeatures,PhotosCount,SecurityFeatures,SourceSystemName,UnparsedAddress,View,YearBuilt,ListAgentFirstName,ListAgentLastName,CoListAgentFirstName,CoListAgentLastName,ListAgentStateLicense,Appliances,StreetNumberNumeric,BathroomsHalf,Listing_sp_Location_sp_and_sp_Property_sp_Info_co_List_sp_PriceSqFt,Commission_sp_Info_co_Buyer_sp_Agency_sp_Comp,Showing_sp_Information_co_Showing_sp_Contact_sp_Name,Parking_sp_SpacesInformation_co_Total_sp_Garage_sp_Spaces,PublicRemarks,StreetName,StreetSuffix,StreetNumber,City,StateOrProvince,ListAgentFullName,ConstructionMaterials,Cooling,Heating,Electric,Flooring,InteriorFeatures,View,WindowFeatures,Appliances")
        ]
        
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            try await parseData(data)
        } catch {
            await handleError(error)
        }
        isLoading = false

    }
    
    private func parseData(_ data: Data) async throws {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let fetchedData = try decoder.decode(Listing.self, from: data)
        await MainActor.run {
            self.results.append(contentsOf: fetchedData.value ?? [])
            self.listings = [fetchedData]
            self.hasMoreData = fetchedData.odataNextLink != nil

            print(listings)
        }
    }
    
    private func handleError(_ error: Error) async {
        print("Error fetching or parsing data: \(error)")
        // Display an error message to the user or update the UI as needed
        await MainActor.run {
            // Update UI to reflect the error state
        }
    }
    func fetchNextPage() async {
        guard !isLoading else { return }

        currentPage += 1
        await fetchProducts()
    }
}
