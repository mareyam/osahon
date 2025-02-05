import SwiftUI

struct ChatGPTSidebar: View {
    @Binding var menuItems: [String]
    @Binding var isSidebarVisible: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Icons at the top
            HStack(spacing: 20) {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSidebarVisible.toggle()
                        }
                    }

                Spacer()

                HStack(spacing: 16) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.white)

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 70)

            // Menu items list
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(menuItems, id: \ .self) { item in
                        Button(action: {
                            print("\(item) tapped")
                        }) {
                            Text(item)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cornerRadius(8)
                        }
                    }
                    if menuItems == [] {
                        Text("No history yet")
                           .foregroundColor(.white)
                           .frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.leading)
                           .font(.system(size: 20, weight: .regular))
                           .padding(.leading, 10)
                    }
                }
                .padding(.horizontal, 70)
            }

            // Profile section
            ChatGPTProfile()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 23 / 255, green: 23 / 255, blue: 23 / 255))
        .offset(x: isSidebarVisible ? 0 : -300)
        .animation(.easeInOut, value: isSidebarVisible)
    }
}

struct ChatGPTSidebar_Preview: PreviewProvider {
    @State static var isSidebarVisible = true
    @State static var menuItems: [String] = []

    static var previews: some View {
        ChatGPTSidebar(menuItems:$menuItems, isSidebarVisible: $isSidebarVisible)
            .background(Color.black)
    }
}

struct ChatGPTProfile: View {
            var body: some View {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 55, height: 55)
                        Text("M")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("Maryam Naveed")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 70)
                
            }
        }
