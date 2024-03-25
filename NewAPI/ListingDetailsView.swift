//
//  SwiftUIView.swift
//  NewAPI
//
//  Created by Alex Beattie on 3/25/24.
//

import SwiftUI

struct ListingDetailView: View {
    var listing: SoldListingsAnno

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: listing.imageURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()

                VStack(alignment: .leading) {
                    Text(listing.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(listing.address)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("Price: \(listing.formattedPrice)")
                        .font(.headline)
                }
                .padding()
            }
        }
        .navigationBarTitle("Details", displayMode: .inline)
    }
}
