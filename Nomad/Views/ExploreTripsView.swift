//
//  ExploreTripsView.swift
//  Nomad
//
//  Created by Lingchen Xiao on 10/3/24.
//

import SwiftUI

struct ExploreTripsView: View {
    var body: some View {
        VStack (alignment: .center, spacing: 15) {
            HStack(alignment: .top, spacing: 10) {
                
                Image(systemName: "mappin.and.ellipse")
                Text("Los Angeles, CA")
                .frame(maxWidth: .infinity, alignment: .leading)

            }
            
            HStack {
                Text("Plan your next trip, John!")
                    .bold()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
            
            }
            
            Spacer()
            
            
            
        }
        
        
    }
}

#Preview {
    ExploreTripsView()
}

