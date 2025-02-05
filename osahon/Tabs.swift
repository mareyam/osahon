import SwiftUI

struct Tabs: View {
    @State private var selectedTab: Tab = .chat

    enum Tab: CaseIterable {
        case explore, images, chat, settings

        var icon: String {
            switch self {
            case .explore: return "globe"
            case .images: return "wand.and.sparkles"
            case .chat: return "bubble.left.and.bubble.right.fill"
            case .settings: return "gearshape"
            }
        }

        var title: String {
            switch self {
            case .explore: return "Explore"
            case .images: return "Transcribe"
            case .chat: return "Chat"
            case .settings: return "Settings"
            }
        }
    }

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                ExploreView(selectedTab: $selectedTab)
                    .tag(Tab.explore)
                    .background(Color.black.ignoresSafeArea())
                
//                AutomationList()
                PythonIntegrationView()
                    .tag(Tab.images)
                    .background(Color.black.ignoresSafeArea())
                
                ChatGPT()
                    .tag(Tab.chat)
                    .background(Color.black.ignoresSafeArea())
                
                SettingsView()
                    .tag(Tab.settings)
                    .background(Color.black.ignoresSafeArea())
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(Color.black.ignoresSafeArea())
            
            HStack {
                ForEach(Tab.allCases, id: \ .self) { tab in
                    TabButton(tab: tab, selectedTab: $selectedTab)
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.black.ignoresSafeArea(edges: .bottom))
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct TabButton: View {
    let tab: Tabs.Tab
    @Binding var selectedTab: Tabs.Tab

    var body: some View {
        VStack {
            Image(systemName: tab.icon)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? Color(red: 65/225, green: 127/225, blue: 224/225) : .gray)

            Text(tab.title)
                .font(.caption)
                .foregroundColor(selectedTab == tab ? Color(red: 65/225, green: 127/225, blue: 224/225) : .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .onTapGesture {
            withAnimation { selectedTab = tab }
        }
    }
}








#Preview {
    Tabs()
}
