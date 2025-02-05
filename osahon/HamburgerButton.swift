import SwiftUI

struct HamburgerButton: View {
    @Binding var showSidebar: Bool

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    showSidebar.toggle()
                }
            }) {
                Image("sidebar")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 30, height: 30)
            }
            .frame(width: 40, height: 44)
            Button(action: {
                withAnimation {
                  
                }
            }) {
                Image("create")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 30, height: 30)
            }
            .frame(width: 40, height: 44)
        }
    }
}

#Preview {
    HamburgerButton(showSidebar: .constant(false))
}
