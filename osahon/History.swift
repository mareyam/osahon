//
//  History.swift
//  osahon
//
//  Created by mav on 21/01/2025.
//

import SwiftUI

struct ChatHistoryView: View {
    @State var searchText = ""
    @Binding var showHistory: Bool
    @Binding var menuItems: [(model: String, title: String, firstMessage: String)]

    var filteredMenuItems: [(model: String, title: String, firstMessage: String)] {
        print("Menu Items: \(menuItems)")
        return menuItems
    }
    
    
//    var filteredMenuItems: [(model: String, title: String, firstMessage: String)] {
//        print(menuItems)
//           if searchText.isEmpty {
//               return menuItems
//           } else {
//               return menuItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
//           }
//       }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .stroke(Color(red: 65/225, green: 127/225, blue: 224/225), lineWidth: 2)
                        )
                }
                Spacer()
                Text("History")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHistory = false // ✅ Close Chat History
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                        .frame(width: 30, height: 30)
                    
                }
            }
            .padding(.top, 16)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .foregroundColor(.white)
            }
            .padding(.horizontal,20)
            .padding(.vertical,12)
            .background(Color(red: 24 / 255, green: 21 / 255, blue: 26 / 255))
            .cornerRadius(12)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .foregroundColor(Color(red: 117 / 255, green: 117 / 255, blue: 121 / 255))
                    ForEach(filteredMenuItems, id: \.title) { item in
                                           ChatHistoryItemView(item: item, showHistory: $showHistory)
                                       }
                    
                }
            }
            .padding(.top)
            
            Spacer()
            
        }
        .padding(.horizontal,20)
        .background(Color.black.ignoresSafeArea())
        
    }
}

// MARK: - Chat History Item View
struct ChatHistoryItemView: View {
    let item: (model: String, title: String, firstMessage: String)
    @Binding var showHistory: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing:12) {
            Image(systemName: "bonjour")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.9))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing:2) {
                Text(item.model)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(item.firstMessage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
            }) {
                Image(systemName: "chevron.right")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray.opacity(0.8))
            }
            
            
            
            
        }
        .padding()
        .background(Color(red: 24 / 255, green: 21 / 255, blue: 26 / 255))
        .cornerRadius(12)
        .onTapGesture { // ✅ Close history when tapping anywhere on HStack
            withAnimation(.easeInOut(duration: 0.3)) {
                showHistory = false
            }
        }
    }
}

struct NavigationIcon: View {
    let icon: String
    var isActive: Bool = false
    
    var body: some View {
        Image(systemName: icon)
            .foregroundColor(isActive ? .purple : .gray)
            .font(.title2)
            .frame(maxWidth: .infinity)
    }
}

struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        @State var showHistory = false
        @State var menuItems = [
                   (model: "GPT-4o", title: "Greeting Exchange", firstMessage: "Hello! How can I assist?"),
                   (model: "GPT-4o", title: "Work Discussion", firstMessage: "Let's discuss our project!")
               ]
        
        ChatHistoryView(showHistory: $showHistory, menuItems: $menuItems)
    }
}
