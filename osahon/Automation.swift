import SwiftUI

struct AutomationIdentifiable: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let description: String
}

let listAutomation: [AutomationIdentifiable] = [
    AutomationIdentifiable(title: "Automation 1", icon: "⚙️", description: "Automate repetitive tasks."),
    AutomationIdentifiable(title: "Automation 2", icon: "🔄", description: "Schedule and automate workflows."),
    AutomationIdentifiable(title: "Automation 3", icon: "🤖", description: "AI-powered automation for efficiency."),
    AutomationIdentifiable(title: "Automation 4", icon: "📲", description: "Automate app interactions."),
    AutomationIdentifiable(title: "Automation 5", icon: "💡", description: "Smart home automation solutions."),
]

struct AutomationList: View {
    @State private var searchText = ""
    
    var filteredList: [AutomationIdentifiable] {
        if searchText.isEmpty {
            return listAutomation
        } else {
            return listAutomation.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Text("Explore Assistants")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .bold()
                    .padding(.top)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 24 / 255, green: 21 / 255, blue: 26 / 255))
                .cornerRadius(12)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(filteredList) { item in
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 50, height: 50)
                                    
                                    Text(item.icon)
                                        .font(.system(size: 22))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                    
                                    Text(item.description)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color(red: 16 / 255, green: 15 / 255, blue: 20 / 255))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Makes the ScrollView take full space
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Full height and width
            .background(Color.black.ignoresSafeArea())
            
        }
    }
}

#Preview {
    AutomationList()
}
