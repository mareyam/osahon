
import SwiftUI
import Foundation
import PDFKit

struct Message: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let fileURL: URL?
}

struct ChatSession: Identifiable {
    let id: UUID
    var title: String
    var messages: [Message]
}


struct ChatGPT: View {
    @State private var messages: [Message] = [
        Message(id: UUID(), content: "", isUser: false, fileURL: nil)
    ]
    @State private var userInput: String = ""
    @State private var bearerKey: String = "55a55844f9b6181042548cd77ea41e0a7b5d4d24aff8d5b05896c774e18e8058"
    @State private var currentBotMessage: String = ""
    @State private var timer: Timer? = nil
    @State private var showModelPicker: Bool = false
    @State private var availableModels: [String] = []
    @State private var selectedModel: String = "openai/gpt-4o-2024-11-20"
    @State private var showMessages: Bool = false
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var menuItems: [(model: String, title: String, firstMessage: String)] = []
    @State private var isModalPresented: Bool = false
    @State private var isSidebarVisible = false
    @State private var chats: [ChatSession] = []
    @State private var aiTyping: Bool = false
    @State private var showHistory: Bool = false
    @State private var selectedFileURL: URL?
    
    
    var latestTitle: String {
            menuItems.last?.title ?? "New Chat" // Default to "New Chat" if no previous context exists
        }
    
    var filteredModels: [String] {
        if searchText.isEmpty {
            return availableModels
        } else {
            return availableModels.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    
    func TriggerButton(title: String, iconName: String, width: CGFloat) -> some View {
        ZStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: width, height: 45, alignment: .center)
//                .foregroundColor(Color(hex: 0x434042))
                .foregroundColor(Color(red: 0.2627, green: 0.2510, blue: 0.2588))
                .multilineTextAlignment(.center)
        }
        .frame(width: width, height: 45, alignment: .center)
        .overlay(alignment: .leading) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .frame(width: 32, height: 18)
                .scaleEffect(0.64)
                .padding(2)
        }
        .background(Color.white.opacity(0))
        .clipShape(
            RoundedRectangle(cornerRadius: 64, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 64)
//                .stroke(Color(hex: 0x434042), style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                .stroke(Color(red: 0.2627, green: 0.2510, blue: 0.2588), style: StrokeStyle(lineWidth: 1, lineJoin: .round))
            
        )
    }
    
    func fetchAvailableModels() {
        guard let url = URL(string: "https://openrouter.ai/api/v1/models") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer sk-or-v1-\(bearerKey)", forHTTPHeaderField: "Authorization")
        request.addValue("Content-Type", forHTTPHeaderField: "application/json")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                //                    print("Attempting to parse JSON...")
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let models = json["data"] as? [[String: Any]] {
//                    print("Models extracted successfully.")
                    let modelIds = models.compactMap { $0["id"] as? String } // Extract "id"
                    DispatchQueue.main.async {
                        availableModels = modelIds
                        showModelPicker = true
                    }
                } else {
                    print("Failed to find 'data' key in JSON response.")
                }
            } catch {
                print("Failed to parse JSON response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let userMessage = Message(id: UUID(), content: userInput, isUser: true, fileURL: selectedFileURL)
        messages.append(userMessage)
        
        determineConversationTitle(from: userInput)
        
  
        
        if let pdfURL = selectedFileURL {
            print("PDF file found at: \(pdfURL) \(userInput)")
            let pdfPath = pdfURL.path
            fetchOpenRouterResponse(for: userInput, pdfFilePath: pdfPath)
        } else {
            print("PDF file not found, input is \(userInput)")
            fetchOpenRouterResponse(for: userInput, pdfFilePath: nil)
        }
        userInput = ""
        selectedFileURL = nil
    }

    func determineConversationTitle(from userInput: String) {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer sk-or-v1-\(bearerKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": selectedModel,
            "temperature": 0.7,
            "messages": [
                ["role": "system", "content": "Generate a very short title summarizing the conversation topic in one line. Do not include quotes around the response."],
                ["role": "user", "content": userInput]
            ]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to serialize request body: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   
                    let context = message["content"] as? String {
                    let trimmedTitle = context.trimmingCharacters(in: .whitespacesAndNewlines)
                    
//                    print("✅ json chocie mesg",json)
//                    print("✅ choice", choices)
//                    print("✅ msg ", message)
//                    print("✅ choice", context)
//                    print("✅ choice", trimmedTitle)
                    
                    DispatchQueue.main.async {
                        let firstUserMessage = self.messages.first(where: { $0.isUser })?.content ?? "No message"
                        let newMenuItem = (model: self.selectedModel, title: trimmedTitle, firstMessage: firstUserMessage)
//                        
//                        print("✅ choice", firstUserMessage)
//                        print("✅ choice", newMenuItem)
                        
                        self.menuItems.append(newMenuItem)
                        
//                        print("✅ Title determined: \(trimmedTitle)")
//                        print("✅ Model: \(self.selectedModel)")
//                        print("✅ First User Message: \(firstUserMessage)")
//                        print("✅ Updated Menu Items: \(self.menuItems)")
                    }
                }
            } catch {
                print("❌ Failed to parse JSON response: \(error)")
            }
        }.resume()
    }

    func fetchOpenRouterResponse(for userInput: String, pdfFilePath: String? = nil) {
        isLoading = true // Start loading
        aiTyping = true

        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            print("Invalid URL")
            isLoading = false
            aiTyping = false
            return
        }

        var request = URLRequest(url: url)
        print(request)
        request.httpMethod = "POST"
        request.addValue("Bearer sk-or-v1-\(bearerKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var requestBody: [String: Any] = [
            "model": selectedModel,
            "temperature": 1.2,
            "messages": [
                ["role": "user", "content": userInput]
            ]
        ]
        print(requestBody)
        
        if let pdfFilePath = pdfFilePath, let extractedText = extractTextFromPDF(pdfFilePath) {
            print("Extracted text from PDF: \(extractedText.prefix(200))...")
            if var messagesArray = requestBody["messages"] as? [[String: Any]] {
                messagesArray.append(["role": "user", "content": "Here is the extracted text from the PDF:\n\n\(extractedText)"])
                requestBody["messages"] = messagesArray
            }
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            print("req httpbody")
        } catch {
            print("Failed to serialize request body: \(error)")
            isLoading = false
            aiTyping = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.aiTyping = false
                }
                return
            }

            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.aiTyping = false
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        displayWordByWord(content: content)
                        self.isLoading = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(content.split(separator: " ").count) * 0.3)) {
                        self.aiTyping = false
                        print("✅ AI typing complete")
                    }
                }
            } catch {
                print("Failed to parse JSON response: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.aiTyping = false
                }
            }
        }.resume()
    }

    
    func extractTextFromPDF(_ filePath: String) -> String? {
        guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath)) else {
            print("❌ Failed to open PDF document")
            return nil
        }

        var extractedText = ""

        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex), let pageText = page.string {
                extractedText += pageText + "\n"
            }
        }

        return extractedText.isEmpty ? nil : extractedText
    }
 
    func displayWordByWord(content: String) {
        currentBotMessage = ""
        let words = content.split(separator: " ")
        var index = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            if index < words.count {
                currentBotMessage += (index > 0 ? " " : "") + words[index]
                let botMessage = Message(id: UUID(), content: currentBotMessage, isUser: false, fileURL: nil)
                messages[messages.count - 1] = botMessage
                index += 1
            } else {
                self.timer?.invalidate()
            }
        }
        
        let emptyBotMessage = Message(id: UUID(), content: "", isUser: false, fileURL: nil)
        messages.append(emptyBotMessage)
    }
    func saveCurrentChatAndStartNew() {

        messages = [Message(id: UUID(), content: "", isUser: false, fileURL: nil)] // Reset messages
        userInput = ""         // Clear input field
        currentBotMessage = "" // Reset bot message
        isLoading = false
        aiTyping = false// Ensure UI is not stuck in loading state
        timer?.invalidate()
    }
    
    
    func loadChat(_ chat: ChatSession) {
        messages = chat.messages
    }
    
    func stopOpenRouterResponse() {
        isLoading = false
        aiTyping = false
        timer?.invalidate()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if showHistory {
                    ChatHistoryView(showHistory:$showHistory, menuItems:$menuItems)
                }else {
                    VStack {
                        HStack {
                            Button(action: {
                                showHistory = true
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 0) {
                                //change
                                Text(latestTitle)
                                    .font(.system(size: 20))
                                    .frame(width: 250, height: 45, alignment: .center)
                                    .foregroundStyle(.white)
                                
                                HStack(spacing:4) {
                                    Text("\(selectedModel.split(separator: "/").first ?? "")/\(selectedModel.split(separator: "/").dropFirst().first?.split(separator: "-").first ?? "")")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                      
                                                                        
                                    Button(action: {
                                        showModelPicker = true
                                        fetchAvailableModels()
                                        isModalPresented = true
                                        
                                    }) {
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(.white)
                                            .frame(width: 20, height: 20)
                                            .background(Color.gray.opacity(0.5))
                                            .cornerRadius(40)
                                            .foregroundColor(.gray)
                                    }
                              
                                }
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                            .animation(.easeInOut, value: isSidebarVisible)
                            
                            .fullScreenCover(isPresented: $isModalPresented) {
                                ModelsModal(
                                    isModalPresented: $isModalPresented,
                                    showModelPicker: $showModelPicker,
                                    searchText: $searchText,
                                    selectedModel: $selectedModel,
                                    availableModels: $availableModels
                                )
                            }
                            
                            
                            Spacer()
                            
                            Button(action: {
                                // Handle settings action
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
                                    .frame(width: 30, height: 30)
                                    .background(Circle().fill(Color.clear).stroke(Color(red: 65/225, green: 127/225, blue: 224/225), lineWidth: 2))
                                
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        Spacer()
                        if !showMessages {
                            Logo()
                        }
                        
                        if showMessages {
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(messages) { message in
                                        HStack {
                                            if message.isUser {
                                                Spacer()
                                                VStack(spacing: 8) {
                                                    if let fileURL = message.fileURL {
                                                        HStack {
                                                            Image(systemName: "doc.text.fill")
                                                                .font(.system(size: 16, weight: .regular))
                                                            
                                                            Text(fileURL.lastPathComponent)
                                                                .foregroundColor(.white)
                                                        }
                                                        .padding(.vertical, 12)
                                                        .padding(.horizontal,20)
                                                        .cornerRadius(10)
                                                        .foregroundColor(.white)
                                                        .background(Color(red: 65/225, green: 127/225, blue: 224/225).opacity(0.3))
                                                        .cornerRadius(10)
                                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                                        
                                                    }
                                                    Text(message.content)
                                                        .padding(.vertical, 12)
                                                        .padding(.horizontal,20)
                                                        .cornerRadius(10)
                                                        .foregroundColor(.white)
                                                        .background(Color(red: 65/225, green: 127/225, blue: 224/225).opacity(0.3))
                                                        .cornerRadius(10)
                                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                                    
                                                }
                                            } else {
                                                Text(message.content)
                                                    .padding()
                                                
                                                    .cornerRadius(10)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Spacer()
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    
                                    if isLoading {
                                        Image("logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white.opacity(0.8))
                                            .background(
                                                Circle()
                                                    .fill(Color(red: 65/225, green: 127/225, blue: 224/225))
                                                    .frame(width: 50, height: 50)
                                                    .blur(radius: 40)
                                            )
                                            .padding(.leading,40)
                                            
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                        
                        VStack(spacing: 10) {
                            if !showMessages {
                                HelloMsg()
                            }
                            
                            Chat(
                                messages: $messages,
                                showMessages: $showMessages,
                                userInput: $userInput,
                                isLoading: $isLoading,
                                aiTyping:$aiTyping,
                                onSendMessage: sendMessage,
                                onStopResponse:stopOpenRouterResponse,
                                selectedFileURL:$selectedFileURL
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                }
            }
        }
    }
}


struct Logo: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 80, height: 80)
                )
                .frame(width: 80, height: 80)
                .foregroundColor(.white.opacity(0.8))
                .background(
                    Circle()
                        .fill(Color(red: 65/225, green: 127/225, blue: 224/225))
                        .frame(width: 120, height: 120)
                        .blur(radius: 100)
                )
          
            
            Text("Autopilot AI")
                .foregroundColor(.white)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
struct HelloMsg:View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hey!")
                .font(.title3)
                .foregroundColor(.white)
                .bold()
            
            Text("How can I assist you? Start chatting by typing in the field below.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
}
struct ModelsModal: View {
    @Binding var isModalPresented: Bool
    @Binding var showModelPicker: Bool
    @Binding var searchText: String
    @Binding var selectedModel: String
    @Binding var availableModels: [String]
    
    var filteredModels: [String] {
        if searchText.isEmpty {
            return availableModels
        } else {
            return availableModels.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Text("Select a Model")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                    
                    // Search bar with filter buttons
                    HStack {
                        ZStack(alignment: .leading) {
                            if searchText.isEmpty {
                                Text("Type here")
                                    .foregroundColor(.gray) // Placeholder color
                                    .padding(.horizontal, 30) // Match TextField padding
                            }
                            TextField("", text: $searchText)
                                .padding()
                                .foregroundColor(.gray) // Text color
                                .background(Color.gray.opacity(0.2)) // Gray background with opacity
                                .cornerRadius(8) // Rounded corners for the search bar
                                .padding(.horizontal)
                        }
                        HStack {
                            Button(action: {
                                // Sort in ascending order
                                availableModels.sort(by: <)
                            }) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Sort in descending order
                                availableModels.sort(by: >)
                            }) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Shuffle the list for random order
                                availableModels.shuffle()
                            }) {
                                Image(systemName: "shuffle")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    if(filteredModels.isEmpty && searchText.isEmpty) {
                        Text("Searching for models")
                            .foregroundColor(.white)
                            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.center)
                            .font(.system(size: 20, weight: .regular))
                            .padding(.leading, 12)
                    }
                    
                    if(filteredModels == [] && searchText != "") {
                        Text("Searched model is not found")
                            .foregroundColor(.white)
                            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.center)
                            .font(.system(size: 20, weight: .regular))
                            .padding(.leading, 12)
                    }
                    
                    
                    // Filtered list of models
                    List(filteredModels, id: \.self) { model in
                        Button(action: {
                            selectedModel = model
                            showModelPicker = false
                            isModalPresented = false
                        }) {
                            HStack {
                                Text(model)
                                    .foregroundColor(.white)
                                if model == selectedModel {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                        }
                        .listRowBackground(Color.black)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    
                    
                }
            }
            .presentationDetents([.fraction(1.0)]) // Full-screen modal
            .presentationDragIndicator(.hidden)
        }
        
        .navigationTitle("Fullscreen Modal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isModalPresented = false
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .regular))
                        Text("Back")
                            .font(.system(size: 16, weight: .regular))
                            
                        
                    }
                    .foregroundColor(.white)
                    .border(.red)
                }
            }
        }
    }
}

struct ChatGPT_Previews: PreviewProvider {
    static var previews: some View {
        ChatGPT()
            .background(Color.black)
    }
}
//
//
//
//var body: some View {
//    ZStack {
//        Color.black.ignoresSafeArea()
//        VStack {
//            HStack(alignment: .top, spacing: 0) {
//                Button(action: {
//                           isSidebarVisible.toggle()
//
//                       }) {
//                           Image(systemName: "sidebar.left")
//                               .font(.system(size: 22, weight: .regular))
//                               .foregroundStyle(.white)
//                               .frame(width: 44, height: 44)
//                       }
//                       .buttonStyle(PlainButtonStyle())
//                       .animation(.easeInOut, value: isSidebarVisible)
//                Spacer()
//                HStack(alignment: .top, spacing: 0) {
//                    Text(selectedModel)
//                        .font(.system(size: 20))
//                        .frame(width: 150, height: 45, alignment: .center)
//                        .foregroundStyle(.white)
//                        .multilineTextAlignment(.center)
//                }
//                    Button(action: {
//                        showModelPicker = true
//                        fetchAvailableModels()
//                        isModalPresented = true
//
//                           }) {
//                               Image(systemName: "chevron.down")
//                                   .font(.system(size: 15, weight: .regular))
//                                   .foregroundStyle(.white)
//                                   .frame(width: 44, height: 44)
//
//
//                           }
//                           .buttonStyle(PlainButtonStyle())
//                           .animation(.easeInOut, value: isSidebarVisible)
//
//                           .fullScreenCover(isPresented: $isModalPresented) {
//                               ModelsModal(
//                                   isModalPresented: $isModalPresented,
//                                   showModelPicker: $showModelPicker,
//                                   searchText: $searchText,
//                                   selectedModel: $selectedModel,
//                                   availableModels: $availableModels
//                               )
//                           }
//                Spacer()
//                Button(action: { saveCurrentChatAndStartNew()
//                    showMessages=false}) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 22, weight: .regular))
//                        .foregroundStyle(.white)
//                        .frame(width: 44, height: 44)
//                }
//            }
//            .frame(width: 365, alignment: .topLeading)
//            .padding(.horizontal, 64)
//            .frame(maxWidth: .infinity, alignment: .top)
//            Spacer()
//
//            ZStack {
//                if !showMessages {
//                    VStack(alignment: .leading) {
//                        Text("Hey!")
//                            .font(.title3)
//                            .foregroundColor(.white)
//                            .bold()
//
//                        Text("How can I assist you? Start chatting by typing in the field below.")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.horizontal, 40)
//                }
//                else {
//                    ScrollView {
//                        VStack(alignment: .leading, spacing: 10) {
//                            ForEach(messages) { message in
//                                HStack {
//                                    if message.isUser {
//                                        Spacer()
//                                        Text(message.content)
//                                            .padding()
//                                            .background(Color.blue)
//                                            .cornerRadius(10)
//                                            .foregroundColor(.white)
//                                            .frame(maxWidth: .infinity, alignment: .trailing)
//                                    } else {
//                                        if message.content != "" {
//                                            Text(message.content)
//                                                .padding()
//                                                .background(Color.gray)
//                                                .cornerRadius(10)
//                                                .foregroundColor(.white)
//                                                .frame(maxWidth: .infinity, alignment: .leading)
//                                        }
//                                        Spacer()
//                                    }
//                                }
//                                .padding(.horizontal, 50)
//                            }
//                            if isLoading {
//                                HStack {
//                                    Text("...")
//                                        .font(.system(size: 24))
//                                        .foregroundColor(.gray)
//                                    Spacer()
//                                }
//                                .padding(.horizontal, 50)
//                            }
//                        }
//                        .padding()
//                    }
//
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black.ignoresSafeArea())
//            Spacer()
//
//                Chat(
//                    messages: $messages,
//                    showMessages: $showMessages,
//                    userInput: $userInput,
//                    isLoading: $isLoading,
//                    onSendMessage: sendMessage
//                )
//                .frame(maxWidth: .infinity)
//                .padding(.horizontal,40)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.black)
//        if isSidebarVisible {
//            ChatGPTSidebar(menuItems:$menuItems, isSidebarVisible: $isSidebarVisible)
//        }
//    }



// func fetchOpenRouterResponse(for userInput: String, pdfFilePath: String? = nil) {
//        isLoading = true // Start loading
//        aiTyping = true
//
//        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
//            print("Invalid URL")
//            isLoading = false
//            aiTyping = false
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("Bearer sk-or-v1-\(bearerKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Base request body
//        var requestBody: [String: Any] = [
//            "model": selectedModel,
//            "temperature": 1.2,
//            "messages": [
//                ["role": "assistant", "content": ""],
//                ["role": "user", "content": userInput]
//            ]
//        ]
//
//        // If PDF file is provided, read and attach it
//        if let pdfFilePath = pdfFilePath {
//            guard let pdfData = try? Data(contentsOf: URL(fileURLWithPath: pdfFilePath)) else {
//                print("Failed to read PDF file")
//                isLoading = false
//                aiTyping = false
//                return
//            }
//
//            // Convert PDF to Base64
//            let pdfBase64 = pdfData.base64EncodedString()
//
//            if var messagesArray = requestBody["messages"] as? [[String: Any]] {
//                messagesArray.append(["role": "user", "content": "[PDF file attached]"])
//                requestBody["messages"] = messagesArray
//            }
//
////            requestBody["messages"]?.append(["role": "user", "content": "[PDF file attached]"])
////            requestBody["attachments"] = [
////                ["type": "application/pdf", "data": pdfBase64]
////            ]
//        }
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//        } catch {
//            print("Failed to serialize request body: \(error)")
//            isLoading = false
//            aiTyping = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Request error: \(error)")
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.aiTyping = false
//                }
//                return
//            }
//
//            guard let data = data else {
//                print("No data received")
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.aiTyping = false
//                }
//                return
//            }
//
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let choices = json["choices"] as? [[String: Any]],
//                   let message = choices.first?["message"] as? [String: Any],
//                   let content = message["content"] as? String {
//                    DispatchQueue.main.async {
//                        displayWordByWord(content: content)
//                        self.isLoading = false
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(content.split(separator: " ").count) * 0.3)) {
//                        self.aiTyping = false
//                        print("✅ AI typing complete")
//                    }
//                }
//            } catch {
//                print("Failed to parse JSON response: \(error)")
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.aiTyping = false
//                }
//            }
//        }.resume()
//    }
//
//
//    func fetchOpenRouterResponse(for userInput: String) {
//        isLoading = true // Start loading
//        aiTyping = true
//        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
//            print("Invalid URL")
//            isLoading = false // Stop loading on error
//            aiTyping = false
//            return
//        }
//
//        var request = URLRequest(url: url)
////        print("req is",request)
//        request.httpMethod = "POST"
//        request.addValue("Bearer sk-or-v1-\(bearerKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let requestBody: [String: Any] = [
//            "model": selectedModel,
//            "temperature": 1.2,
//            "messages": [
//                ["role": "assistant", "content": ""],
//                ["role": "user", "content": userInput]
//            ]
//        ]
////        print(requestBody)
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
//        } catch {
//            print("Failed to serialize request body: \(error)")
//            isLoading = false // Stop loading on error
//            aiTyping = false
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Request error: \(error)")
//                DispatchQueue.main.async {
//                    self.isLoading = false // Stop loading on error
//                    self.aiTyping = false
//                }
//                return
//            }
//
//            guard let data = data else {
//                print("No data received")
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.aiTyping = false
//                }
//                return
//            }
////            print("here")
//
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let choices = json["choices"] as? [[String: Any]],
//                   let message = choices.first?["message"] as? [String: Any],
//                   let content = message["content"] as? String {
//                    DispatchQueue.main.async {
//                        displayWordByWord(content: content)
//                        self.isLoading = false
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(content.split(separator: " ").count) * 0.3)) {
//                        self.aiTyping = false
////                        print("✅ AI typing complete")
//                    }
////                    print("json is")
////                    print(json)
//                }
//            } catch {
//                print("Failed to parse JSON response: \(error)")
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.aiTyping = false
//                }
//            }
//        }.resume()
//    }
//
//
