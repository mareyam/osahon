import SwiftUI

struct ExploreView: View {
    @State var searchText = ""
    @State private var selectedCategory: String? = "Health"
    @Namespace private var scrollNamespace
    @Binding var selectedTab: Tabs.Tab

    
    var filteredCategoryGroups: [String: [AssistantItem]] {
            guard !searchText.isEmpty else { return categoryGroups }
            var filteredGroups: [String: [AssistantItem]] = [:]
            for (category, items) in categoryGroups {
                let filteredItems = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                if !filteredItems.isEmpty {
                    filteredGroups[category] = filteredItems
                }
            }
            return filteredGroups
        }
        
    
    var body: some View {
        VStack {
            Text("Explore Assistants")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .bold()
                .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("Search")
                            .foregroundColor(Color.gray.opacity(0.5))
                    }

                    TextField("", text: $searchText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(red: 24 / 255, green: 21 / 255, blue: 26 / 255))
            .cornerRadius(12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                MenuTabs(selectedCategory: $selectedCategory)
                    .padding(.horizontal)
            }
            .padding(.top, 10)
            
            ScrollViewReader { proxy in
                CreateAssistant(selectedTab: $selectedTab)
                    .padding(.horizontal, 12)
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 20) {
                            if filteredCategoryGroups.isEmpty {
                                Text("None Found")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                               
                                
                                ForEach(filteredCategoryGroups.keys.sorted(), id: \.self) { category in
                                    VStack(alignment: .leading) {
                                        Text(category)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .id(category)
                                            .onAppear {
                                                selectedCategory = category
                                            }
                                        
                                        AssistantsList(category: filteredCategoryGroups[category] ?? [])
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .onChange(of: selectedCategory) { newCategory in
                            if let category = newCategory {
                                withAnimation {
                                    proxy.scrollTo(category, anchor: .top)
                                }
                            }
                        }
                    }
                    .cornerRadius(20)
               
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Menu Tabs Component
struct MenuTabs: View {
    @Binding var selectedCategory: String?
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(menuItems, id: \.title) { item in
                Button(action: {
                    selectedCategory = item.title
                }) {
                    HStack {
                        Text(item.icon)
                        
                            .frame(width: 20, height: 12)
                            .foregroundColor(selectedCategory == item.title ? .blue : .gray)
                        Text(item.title)
                            .font(.system(size: 12))
                            .foregroundColor(selectedCategory == item.title ? .blue : .white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(selectedCategory == item.title ? Color.blue : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
    }
}

struct CreateAssistant:View {
    @Binding var selectedTab: Tabs.Tab
    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = .chat 
            }
        }) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Create Assistant")
                        .font(.system(size: 16))
                        .bold()
                        .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                    
                    Text("Create your custom AI Assistant")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                
                Button(action: {
                    withAnimation {
                                       selectedTab = .chat
                                   }
                }) {
                    Text("Pro")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 65/225, green: 127/225, blue: 224/225), Color(red: 65/225, green: 127/225, blue: 224/225).opacity(0.5)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.8
                                )
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 65/225, green: 127/225, blue: 224/225), Color(red: 65/225, green: 127/225, blue: 224/225).opacity(0.5)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text("Pro")
                                    .font(.system(size: 12, weight: .medium))
                            )
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(red: 16 / 255, green: 15 / 255, blue: 20 / 255))
            .cornerRadius(15)
            
        }
    }
}
struct AssistantsList: View {
    let category: [AssistantItem]
    
    var body: some View {
        VStack(spacing: 0) {
            Section {
                
            
            ForEach(category, id: \.title) { item in
                VStack(spacing: 0) {
                    Button(action: {}) {
                        
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 50, height: 50)
                                    
                                    Text(item.icon)
                                        .frame(width: 22, height: 22)
                                        .foregroundColor(.white)

                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 14))
                                        .bold()
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text(item.description)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color(red:16/255, green: 15/255, blue: 20/255))
                            
                        }
                    }
                    
                    
                    if item.title != category.last?.title {
                        Divider()
                            .background(Color.gray.opacity(0.9))
                            .padding(.vertical, 4)
                    }
                }
            
        }
        }
        .cornerRadius(8)
        .background(Color.black)
    }
}

// MARK: - Data Models
struct MenuItem {
    let title: String
    let icon: String
}

struct AssistantItem {
    let category: String
    let title: String
    let icon: String
    let description: String
}


let assistantItems: [AssistantItem] = [
    AssistantItem(category: "Health", title: "Meditation", icon: "♥️", description: "Guided meditation for stress relief."),
    AssistantItem(category: "Health", title: "Meditation", icon: "♥️", description: "Guided meditation for stress relief."),
    AssistantItem(category: "Health", title: "Meditation", icon: "♥️", description: "Guided meditation for stress relief."),
    AssistantItem(category: "Entertainment", title: "Movie Suggestions", icon: "🎬", description: "Get recommendations for trending movies."),
    AssistantItem(category: "Entertainment", title: "Movie Suggestions", icon: "🎬", description: "Get recommendations for trending movies."),
    AssistantItem(category: "Entertainment", title: "Movie Suggestions", icon: "🎬", description: "Get recommendations for trending movies."),
    AssistantItem(category: "Food", title: "Healthy Recipes", icon: "🔪", description: "Discover delicious and nutritious recipes."),
    AssistantItem(category: "Food", title: "Healthy Recipes", icon: "🔪", description: "Discover delicious and nutritious recipes."),
    AssistantItem(category: "Productivity", title: "Task Manager", icon: "📄", description: "Organize your tasks efficiently."),
    AssistantItem(category: "Productivity", title: "Task Manager", icon: "📄", description: "Organize your tasks efficiently."),
    AssistantItem(category: "Productivity", title: "Task Manager", icon: "📄", description: "Organize your tasks efficiently."),
    AssistantItem(category: "Productivity", title: "Task Manager", icon: "📄", description: "Organize your tasks efficiently."),
    AssistantItem(category: "Sports", title: "Workout Plans", icon: "⚽️", description: "Personalized exercise routines."),
    AssistantItem(category: "Music", title: "Playlists", icon: "🎧", description: "Find curated playlists for every mood."),
    AssistantItem(category: "Travel", title: "Destination Guide", icon: "✈️", description: "Explore travel destinations worldwide."),
    AssistantItem(category: "Travel", title: "Destination Guide", icon: "✈️", description: "Explore travel destinations worldwide."),
    AssistantItem(category: "Books", title: "Book Recommendations", icon: "📕", description: "Find the best books to read."),
    AssistantItem(category: "Finance", title: "Budget Planner", icon: "💵", description: "Manage your expenses and savings."),
    AssistantItem(category: "Finance", title: "Budget Planner", icon: "💵", description: "Manage your expenses and savings."),
    AssistantItem(category: "Technology", title: "Tech News", icon: "🖥️", description: "Stay updated with the latest in tech."),
]

let menuItems: [MenuItem] = [
    MenuItem(title: "Health", icon: "♥️"),
    MenuItem(title: "Entertainment", icon: "🎬"),
    MenuItem(title: "Food", icon: "🔪"),
    MenuItem(title: "Productivity", icon: "📈"),
    MenuItem(title: "Sports", icon: "⚽️"),
    MenuItem(title: "Music", icon: "🎧"),
    MenuItem(title: "Travel", icon: "✈️"),
    MenuItem(title: "Books", icon: "📕")
]

let categoryGroups: [String: [AssistantItem]] = Dictionary(grouping: assistantItems, by: \.category)

#Preview {
    @State var selectedTab: Tabs.Tab = .explore
    return ExploreView(selectedTab: $selectedTab)
}


//                ScrollView(.vertical, showsIndicators: true) {
//                    VStack(alignment: .leading, spacing: 20) {
//                        ForEach(categoryGroups.keys.sorted(), id: \.self) { category in
//                            VStack(alignment: .leading) {
//                                Text(category)
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.white)
//                                    .id(category)
//                                    .onAppear {
//                                        selectedCategory = category
//                                    }
//
//                                AssistantsList(category: categoryGroups[category] ?? [])
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                    .onChange(of: selectedCategory) { newCategory in
//                        if let category = newCategory {
//                            withAnimation {
//                                proxy.scrollTo(category, anchor: .top)
//                            }
//                        }
//                    }
//                }


//import SwiftUI
//
//struct ExploreView: View {
//    @State var searchText = ""
//    @State private var selectedCategory: String? = nil
//    @Namespace private var scrollNamespace
//    
//    var body: some View {
//        VStack {
//            Text("Explore Assistants")
//                .font(.system(size: 20))
//                .foregroundColor(.white)
//                .bold()
//                .padding()
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//                if searchText.isEmpty {
//                    Text("Search")
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                } else {
//                    TextField("", text: $searchText)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .background(Color(red: 24 / 255, green: 21 / 255, blue: 26 / 255))
//            .cornerRadius(12)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                MenuTabs(selectedCategory: $selectedCategory)
//                    .padding(.horizontal)
//            }
//            .padding(.top, 10)
//            
//            ScrollViewReader { proxy in
//                ScrollView(.vertical, showsIndicators: true) {
//                    VStack(alignment: .leading, spacing: 20) {
//                        ForEach(categoryGroups.keys.sorted(), id: \.self) { category in
//                            VStack(alignment: .leading) {
//                                Text(category)
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.white)
//                                    .id(category)
//                                
//                                AssistantsList(category: categoryGroups[category] ?? [])
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                    .onChange(of: selectedCategory) { newCategory in
//                        if let category = newCategory {
//                            withAnimation {
//                                proxy.scrollTo(category, anchor: .top)
//                            }
//                        }
//                    }
//                }
//                .cornerRadius(20)
//            }
//            
//            Spacer()
//        }
//        .padding(.horizontal, 20)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black.ignoresSafeArea())
//    }
//}
//
//// MARK: - Menu Tabs Component
//struct MenuTabs: View {
//    @Binding var selectedCategory: String?
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            ForEach(menuItems, id: \.title) { item in
//                Button(action: {
//                    selectedCategory = item.title
//                }) {
//                    HStack {
//                        Image(systemName: item.icon)
//                            .resizable()
//                            .frame(width: 14, height: 14)
//                            .foregroundColor(selectedCategory == item.title ? .blue : .gray)
//                        
//                        Text(item.title)
//                            .font(.system(size: 12))
//                            .foregroundColor(selectedCategory == item.title ? .blue : .white)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 10)
//                    .background(Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
//                    .cornerRadius(25)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 25)
//                            .stroke(selectedCategory == item.title ? Color.blue : Color.clear, lineWidth: 1)
//                    )
//                }
//            }
//        }
//    }
//}
//
//struct AssistantsList: View {
//    let category: [AssistantItem]
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            ForEach(category, id: \.title) { item in
//                VStack(spacing: 0) {
//                    Button(action: {}) {
//                        HStack(spacing: 15) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color.black)
//                                    .frame(width: 50, height: 50)
//                                
//                                Image(systemName: item.icon)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 22, height: 22)
//                                    .foregroundColor(.white)
//                            }
//                            
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text(item.title)
//                                    .font(.system(size: 14))
//                                    .bold()
//                                    .foregroundColor(.white)
//                                    .multilineTextAlignment(.leading)
//                                
//                                Text(item.description)
//                                    .font(.system(size: 12))
//                                    .foregroundColor(.gray.opacity(0.8))
//                                    .multilineTextAlignment(.leading)
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            
//                            Spacer()
//                        }
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 12)
//                        .background(Color.white.opacity(0.08))
//                    }
//                    .cornerRadius(8)
//                    
//                    if item.title != category.last?.title {
//                        Divider()
//                            .background(Color.gray.opacity(0.9))
//                            .padding(.vertical, 4)
//                    }
//                }
//            }
//        }
//        .background(Color.black)
//    }
//}
//
//// MARK: - Data Models
//struct MenuItem {
//    let title: String
//    let icon: String
//}
//
//struct AssistantItem {
//    let category: String
//    let title: String
//    let icon: String
//    let description: String
//}
//
//let assistantItems: [AssistantItem] = [
//    AssistantItem(category: "Health", title: "Meditation", icon: "heart.fill", description: "Guided meditation for stress relief."),
//    AssistantItem(category: "Entertainment", title: "Movie Suggestions", icon: "film.fill", description: "Get recommendations for trending movies."),
//    AssistantItem(category: "Food", title: "Healthy Recipes", icon: "🔪", description: "Discover delicious and nutritious recipes."),
//    AssistantItem(category: "Productivity", title: "Task Manager", icon: "📄", description: "Organize your tasks efficiently."),
//    AssistantItem(category: "Sports", title: "Workout Plans", icon: "⚽️", description: "Personalized exercise routines."),
//    AssistantItem(category: "Music", title: "Playlists", icon: "music.note", description: "Find curated playlists for every mood."),
//    AssistantItem(category: "Travel", title: "Destination Guide", icon: "airplane", description: "Explore travel destinations worldwide."),
//    AssistantItem(category: "Books", title: "Book Recommendations", icon: "book.fill", description: "Find the best books to read."),
//    AssistantItem(category: "Finance", title: "Budget Planner", icon: "dollarsign.circle.fill", description: "Manage your expenses and savings."),
//    AssistantItem(category: "Technology", title: "Tech News", icon: "desktopcomputer", description: "Stay updated with the latest in tech."),
//]
//
//let menuItems: [MenuItem] = [
//    MenuItem(title: "Health", icon: "heart.fill"),
//    MenuItem(title: "Entertainment", icon: "play.rectangle.fill"),
//    MenuItem(title: "Food", icon: "🔪"),
//    MenuItem(title: "Productivity", icon: "chart.bar.fill"),
//    MenuItem(title: "Sports", icon: "⚽️"),
//    MenuItem(title: "Music", icon: "music.note"),
//    MenuItem(title: "Travel", icon: "airplane"),
//    MenuItem(title: "Books", icon: "book.fill")
//]
//
//let categoryGroups: [String: [AssistantItem]] = Dictionary(grouping: assistantItems, by: \.category)
//
//#Preview {
//    ExploreView()
//}
