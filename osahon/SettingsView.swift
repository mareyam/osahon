import SwiftUI

struct SettingsView: View {
  @State var searchText = ""
  @State private var selectedCategory: String? = "Health"
  @Namespace private var scrollNamespace

  var body: some View {
      VStack(spacing:8){
      Text("Settings")
        .font(.system(size: 20))
        .padding(.bottom,30)
        .foregroundColor(.white)
        .bold()
        .frame(maxWidth: .infinity)
       
          ScrollView(.vertical, showsIndicators: false) {
              LazyVStack(spacing: 16) {
                  AccountSection()
                  Account()
                  AppSection()
              }
          }

    }
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment:.leading)
    .background(Color.black.ignoresSafeArea())
  }
}

struct AccountSection: View {
    var body: some View {
        Section {
            VStack(spacing: 10) {
                VStack(spacing: 8) {
                    HStack(spacing: 2) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color(red: 65/225, green: 127/225, blue: 224/225))
                                .cornerRadius(100)
                               
                            Text("Account")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                        }
                        Spacer()
                        
                        HStack {
                            Capsule()
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: 50, height: 30)
                                .overlay(
                                    HStack {
                                        Text("6")
                                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                            .font(.system(size: 12, weight: .medium))
                                        Image(systemName: "message.fill")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                    }
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 65/225, green: 127/225, blue: 224/225), lineWidth: 0.8)
                                )
                            
                            Capsule()
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: 50, height: 30)
                                .overlay(
                                    HStack {
                                        Text("4")
                                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                            .font(.system(size: 12, weight: .medium))
                                        Image(systemName: "sparkles.rectangle.stack.fill")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                    }
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 65/225, green: 127/225, blue: 224/225), lineWidth: 0.8)
                                )
                        }
                    }
                    
                    HStack {
                        Text("Daily messages")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text("6/10")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    ZStack(alignment: .leading) {
                        // Background (Gray)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)

                        // Foreground (Blue - 60% Filled)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(width: UIScreen.main.bounds.width * 0.6, height: 4) // 60% width
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9) // Set total width

                    
                    HStack {
                        Text("Renews in 13 hours")
                            .foregroundColor(Color.gray.opacity(0.5))
                            .font(.system(size: 12, weight: .medium))
                        Spacer()
                        Text("Get more")
                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225).opacity(0.9))
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .padding(20)
            }

            .background(
                Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
            .cornerRadius(20) // Apply corner radius here
        }
    }
}

struct Account: View {
    var body:some View {
        Section("Account") {
            VStack(spacing: 0) {
                // Free Plan Section
                HStack {
                    Image(systemName: "circle")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.gray.opacity(0.7))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Free Plan")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                        
                        Text("Upgrade for all features")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.system(size: 12, weight: .medium))
                    }
                    
                    Spacer()
                    
                    // Upgrade Button
                    Button(action: {
                        // Your action here
                    }) {
                        Text("Upgrade")
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
                                    Text("Upgrade")
                                        .font(.system(size: 12, weight: .medium))
                                )
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 40)
                
                // Profile Section
                HStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)
                    
                    Text("Profile")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(
                Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
            .cornerRadius(12)
            .foregroundColor(.gray.opacity(0.9))
        }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        //        .border(.red)
    }
}
        

struct AppSection: View {
    var body:some View {
        Section("App") {
            VStack(spacing: 0) {
                // Profile Section
                HStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)

                    Text("Profile")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 40)

                HStack {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)

                    Text("Help and info")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 40)

                HStack {
                    Image(systemName: "archivebox")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.white)

                    Text("Archived Chats")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(
                Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
            .cornerRadius(16) // Apply rounded corners to the background
            .foregroundColor(.gray.opacity(0.9))
            .padding(.horizontal, 4)
        }
        .font(.system(size: 12, weight: .regular))
        .foregroundColor(.gray.opacity(0.5))
        .frame(maxWidth: .infinity, alignment: .leading)

        
        Section {
            HStack {
                Image(systemName: "star")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.white)

                Text("Submit review")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 6, height: 6)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .foregroundColor(.gray.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        .background(
            Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
        .cornerRadius(15) // Add rounded corners
        .padding(.horizontal, 4)

        
        
        HStack {
            Image(systemName: "door.left.hand.open")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(.white)

            Text("Logout")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)

        .background(
            Color(red: 16 / 255, green: 15 / 255, blue: 19 / 255))
        .cornerRadius(12) // Rounded corners applied correctly

        
        
        .foregroundColor(.gray.opacity(0.5))
        .frame(maxWidth:.infinity, alignment:.leading)
        .padding(.horizontal, 4)
        .cornerRadius(20)
        
    
    }
    
    
}
#Preview {
  SettingsView()
}
