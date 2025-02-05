import SwiftUI

struct Practice: View {
    @State private var brand: String = ""
    @State private var action: String = ""
    @State private var responseText: String = "Response will appear here"
    
    let webhookBaseURL = "https://maryamn8n.app.n8n.cloud/webhook-test/my-webhook"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftUI Webhook Messenger")
                .font(.title)
                .padding()
            
            TextField("Enter brand", text: $brand)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter action (subscribe/unsubscribe)", text: $action)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: sendRequest) {
                Text("Send Request")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Text(responseText)
                .padding()
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
    
    func sendRequest() {
        guard !brand.isEmpty, !action.isEmpty else {
            responseText = "Brand and Action cannot be empty"
            return
        }
        
        sendGETRequest(brand: brand, action: action) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    responseText = "Success: \(response)"
                    

                    if action.lowercased() == "subscribe" {
                        if let url = URL(string: "https://workfloows.com/") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                case .failure(let error):
                    responseText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}


func sendGETRequest(brand: String, action: String, completion: @escaping (Result<String, Error>) -> Void) {
    guard var components = URLComponents(string: "https://maryamn8n.app.n8n.cloud/webhook-test/my-webhook") else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    components.queryItems = [
        URLQueryItem(name: "brand", value: brand),
        URLQueryItem(name: "action", value: action)
    ]
    
    guard let finalURL = components.url else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URL"])))
        return
    }
    
    var request = URLRequest(url: finalURL)
    request.httpMethod = "GET" 

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            completion(.success(responseString))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
        }
    }.resume()
}

#Preview {
    Practice()
}

//import SwiftUI
//
//struct ResStruct:Identifiable {
//    var id=UUID()
//    var name:String
//}
//
//
//struct Practive: View {
//    var restaurant: ResStruct
//    
//    var body: some View {
//        VStack {
//            Text("come eat at \(restaurant.name)")
//        }
//        .padding()
//    }
//}
//
//struct Result: View {
//    var body: some View {
//        let f = Practive(name:"a")
//        let s = Practive(name:"b")
//        let t = Practive(name:"c")
//        return List()
//    }
//}
//
//#Preview {
//    Practive()
//}
//
////
////struct ExploreView: View {
////    @State var searchText = ""
////
////    var body: some View {
////        VStack {
////            ScrollView(.vertical, showsIndicators: true) {
////                AssistantsList()
////                    .padding(.horizontal)
////            }
////        }
////        .padding(.horizontal, 20)
////        .frame(maxWidth: .infinity, maxHeight: .infinity)
////        .background(Color.black.ignoresSafeArea())
////    }
////}
////
////struct AssistantsList: View {
////    @State private var selectedAssistant: String = "Health"
////
////    var body: some View {
////        VStack(spacing: 10) {
////            ForEach(assistantItems, id: \.title) { item in
////                Button(action: {
////                    selectedAssistant = item.title
////                }) {
////                    HStack(spacing: 15) {
////                        // Rounded Icon Background
////                        ZStack {
////                            Circle()
////                                .fill(Color.gray.opacity(0.2))
////                                .frame(width: 50, height: 50)
////
////                            Image(systemName: item.icon)
////                                .resizable()
////                                .scaledToFit()
////                                .frame(width: 22, height: 22)
////                                .foregroundColor(.white)
////                        }
////
////                        VStack(alignment: .leading, spacing: 8) {
////                            Text(item.title)
////                                .font(.system(size: 17))
////                                .fixedSize(horizontal: false, vertical: true)
////                                .foregroundColor(.white)
////                                .multilineTextAlignment(.leading) // ✅ Ensures left alignment
////                                .border(.red)
////
////                            Text(item.description)
////                                .font(.system(size: 17))
////                                .frame(maxWidth: .infinity, alignment: .leading) // ✅ Ensures full width
////                                .foregroundColor(.white)
////                                .multilineTextAlignment(.leading) // ✅ Ensures left alignment
////                                .border(.red)
////                        }
////                        .frame(maxWidth: .infinity, alignment: .leading) // ✅
////                        .border(.blue)
////
////                        Spacer()
////                    }
////                    .padding()
////                    .background(selectedAssistant == item.title ? Color.white.opacity(0.08) : Color.clear)
////                    .cornerRadius(12)
////                }
////            }
////        }
////        .background(Color.black)
////    }
////}
////
////struct AssistantItem {
////    let category: String
////    let title: String
////    let icon: String
////    let description: String
////}
////
////let assistantItems: [AssistantItem] = [
////    AssistantItem(category: "Health", title: "Meditation", icon: "heart.fill", description: "Guided meditation for stress relief."),
////    AssistantItem(category: "Entertainment", title: "Movie Suggestions", icon: "film.fill", description: "Get recommendations for trending movies."),
////    AssistantItem(category: "Food", title: "Healthy Recipes", icon: "fork.knife", description: "Discover delicious and nutritious recipes.")
////]
////
////#Preview {
////    ExploreView()
////}
//
//
//
//////////////////maybe useful
/////
////import SwiftUI
////
////struct ExploreView: View {
////    @State var searchText = ""
////
////    var body: some View {
////        VStack {
////            Text("Explore Assistants")
////                .font(.title)
////                .foregroundColor(.white)
////                .bold()
////                .padding()
////
////            HStack {
////                Image(systemName: "magnifyingglass")
////                    .foregroundColor(.gray)
////                TextField("Search", text: $searchText)
////                    .foregroundColor(.white)
////            }
////            .padding(.horizontal, 20)
////            .padding(.vertical, 14)
////            .background(Color(red: 24 / 255, green: 21 / 255, blue: 26 / 255))
////            .cornerRadius(12)
////
////            // Scrollable Menu Tabs Below Search Bar
////            ScrollView(.horizontal, showsIndicators: false) {
////                MenuTabs()
////                    .padding(.horizontal)
////            }
////            .padding(.top, 10)
////
////
////            ScrollView(.vertical, showsIndicators:true) {
////                AssistantsList()
////                    .padding(.horizontal)
////                    .cornerRadius(20)
////                    .padding(.top,20)
////            }
////            .cornerRadius(20)
////
////            Spacer()
////        }
////        .padding(.horizontal, 20)
////        .frame(maxWidth: .infinity, maxHeight: .infinity)
////        .background(Color.black.ignoresSafeArea())
////    }
////}
////
////// MARK: - Menu Tabs Component with Scrollable HStack
////struct MenuTabs: View {
////    @State private var selectedTab: String = "Health"
////
////    var body: some View {
////        HStack(spacing: 15) {
////            ForEach(menuItems, id: \.title) { item in
////                Button(action: {
////                    selectedTab = item.title
////                }) {
////                    HStack {
////                        Image(systemName: item.icon)
////                            .resizable()
////                            .frame(width: 20, height: 20)
////                            .foregroundColor(selectedTab == item.title ? .blue : .gray)
////
////                        Text(item.title)
////                            .font(.headline)
////                            .foregroundColor(selectedTab == item.title ? .blue : .white)
////                    }
////                    .padding(.horizontal, 20)
////                    .padding(.vertical, 10)
////                    .background(Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
////                    .cornerRadius(25)
////                    .overlay(
////                        RoundedRectangle(cornerRadius: 25)
////                            .stroke(selectedTab == item.title ? Color.blue : Color.clear, lineWidth: 2)
////                    )
////                }
////            }
////        }
////    }
////}
////
////struct AssistantsList: View {
////    @State private var selectedAssistant: String = "Health"
////
////    var body: some View {
////        VStack(spacing: 0) { // No extra spacing
////            ForEach(assistantItems, id: \.title) { item in
////                VStack(spacing: 0) {
////                    Button(action: {
////                        selectedAssistant = item.title
////                    }) {
////                        HStack(spacing: 15) {
////                            // Rounded Icon Background
////                            ZStack {
////                                Circle()
////                                    .fill(Color.gray.opacity(0.2)) // Light background
////                                    .frame(width: 50, height: 50)
////
////                                Image(systemName: item.icon)
////                                    .resizable()
////                                    .scaledToFit()
////                                    .frame(width: 22, height: 22)
////                                    .foregroundColor(.white)
////                            }
////
////                            VStack(alignment: .leading, spacing: 8) {
////                                Text(item.title)
////                                    .font(.system(size: 17))
////                                    .foregroundColor(.white)
////                                    .multilineTextAlignment(.leading)
////
////                                Text(item.description)
////                                    .font(.system(size: 17))
////                                    .frame(maxWidth: .infinity, alignment: .leading)
////                                    .foregroundColor(.white)
////                                    .multilineTextAlignment(.leading)
////                                if item.title != assistantItems.last?.title {
////                                    Divider()
////                                        .background(Color.gray.opacity(0.9))
////                                        .padding(.vertical, 4)
////
////                                }
////                            }
////                            .frame(maxWidth: .infinity, alignment: .leading)
////
////                            Spacer()
////                        }
////                        .padding(.horizontal, 12)
////                        .padding(.vertical, 12)
////                        .background(Color.white.opacity(0.08))
////                        .cornerRadius(0)
////
////                    }
////
////                    // Horizontal line between items (Except the last one)
////
////                }
////            }
////        }
////        .background(Color.black)
////    }
////}
////
////// MARK: - Menu Items
////struct MenuItem {
////    let title: String
////    let icon: String
////}
////
////struct AssistantItem {
////    let category:String
////    let title: String
////    let icon: String
////    let description: String
////}
////
////let assistantItems: [AssistantItem] = [
////    AssistantItem(category: "Health", title: "Meditation", icon: "heart.fill", description: "Guided meditation for stress relief."),
////    AssistantItem(category: "Entertainment", title: "Movie Suggestions", icon: "film.fill", description: "Get recommendations for trending movies."),
////    AssistantItem(category: "Food", title: "Healthy Recipes", icon: "fork.knife", description: "Discover delicious and nutritious recipes."),
////    AssistantItem(category: "Productivity", title: "Task Manager", icon: "checkmark.circle.fill", description: "Organize your tasks efficiently."),
////    AssistantItem(category: "Sports", title: "Workout Plans", icon: "sportscourt.fill", description: "Personalized exercise routines."),
////    AssistantItem(category: "Music", title: "Playlists", icon: "music.note", description: "Find curated playlists for every mood."),
////    AssistantItem(category: "Travel", title: "Destination Guide", icon: "airplane", description: "Explore travel destinations worldwide."),
////    AssistantItem(category: "Books", title: "Book Recommendations", icon: "book.fill", description: "Find the best books to read."),
////    AssistantItem(category: "Finance", title: "Budget Planner", icon: "dollarsign.circle.fill", description: "Manage your expenses and savings."),
////    AssistantItem(category: "Technology", title: "Tech News", icon: "desktopcomputer", description: "Stay updated with the latest in tech."),
////]
////
////
////let menuItems: [MenuItem] = [
////    MenuItem(title: "Health", icon: "heart.fill"),
////    MenuItem(title: "Entertainment", icon: "play.rectangle.fill"),
////    MenuItem(title: "Food", icon: "fork.knife"),
////    MenuItem(title: "Productivity", icon: "chart.bar.fill"),
////    MenuItem(title: "Sports", icon: "sportscourt.fill"),
////    MenuItem(title: "Music", icon: "music.note"),
////    MenuItem(title: "Travel", icon: "airplane"),
////    MenuItem(title: "Books", icon: "book.fill")
////]
////
////#Preview {
////    ExploreView()
////}
//
