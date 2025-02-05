import SwiftUI
import UniformTypeIdentifiers

struct Chat: View {
    @State private var isExpanded: Bool = false
    @Binding var messages: [Message]
    @Binding var showMessages: Bool
    @Binding var userInput: String
    @Binding var isLoading: Bool
    @Binding var aiTyping: Bool
    let onSendMessage: () -> Void
    let onStopResponse: () -> Void
    @State var isVisible = false
    @Binding var selectedFileURL: URL?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack {
                if let fileURL = selectedFileURL {
                HStack() {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray.opacity(0.5))
                           
                        Text(fileURL.lastPathComponent)
                        .foregroundColor(.white)
                            Spacer()
                            
                            Button(action: {
                                self.selectedFileURL = nil
                                
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                    
                }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .opacity(aiTyping ? 0 : 1)
                    .frame(maxWidth:.infinity, alignment: .leading)
                }

                
                HStack {
                    Button(action: {
                        withAnimation {
                            isVisible.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                            .padding(8)
                            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
                            .clipShape(Circle())
                    }

                    ZStack(alignment: .leading) {
                        if userInput.isEmpty {
                            Text("Type in your message")
                                .foregroundColor(Color.gray.opacity(0.5))
                        }

                        TextField("", text: $userInput)
                    }
                    .padding(6)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)

                    if aiTyping {
                        Button(action: {
                            onStopResponse()
                        }) {
                            Image(systemName: "square.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color(red: 65/225, green: 127/225, blue: 224/225))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                    } else {
                        Button(action: {
                            guard !userInput.isEmpty else { return }
                            showMessages = true
                            onSendMessage()
                        }) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(userInput.isEmpty ? Color.gray : Color(red: 65/225, green: 127/225, blue: 224/225))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                        .opacity(userInput.isEmpty ? 0 : 1)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(Color(red: 15 / 255, green: 14 / 255, blue: 17 / 255))
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(red: 35 / 255, green: 35 / 255, blue: 35 / 255), lineWidth: 2)
                )

                // Show selected file icon inside chat box

            }
            .padding(.horizontal)

            if isVisible {
                FileUploadMenu(isVisible: $isVisible, selectedFileURL: $selectedFileURL)
                    .offset(x: 10, y: -50)
                    .zIndex(10)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct FileUploadMenu: View {
    @Binding var isVisible: Bool
    @Binding var selectedFileURL: URL?

    @State private var isPickerPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            VStack(spacing: 0) {
                Button(action: {
                    isPickerPresented.toggle()
                }) {
                    HStack {
                        Text("Upload File")
                        Spacer()
                        Image(systemName: "doc.text.fill")
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                .sheet(isPresented: $isPickerPresented) {
                    DocumentPicker(selectedFileURL: $selectedFileURL,isVisible: $isVisible)
                }
            }
        }
        .frame(width: 200)
        .background(Color.black.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 5)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut, value: isVisible)
        .zIndex(100)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFileURL: URL?
    @Binding var isVisible: Bool

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedFileURL = urls.first
            if let fileURL = urls.first {
                print("Selected File: \(fileURL.lastPathComponent)")
            }
            parent.isVisible = false
           
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Picker was cancelled")
            parent.isVisible = false
        }
    }
}

// MARK: - Preview
#Preview {
    struct ChatPreviewWrapper: View {
        @State private var showMessages = false
        @State private var isLoading = false
        @State private var aiTyping = false
        @State private var messages: [Message] = [
            Message(id: UUID(), content: "Hello, how can I help you?", isUser: false, fileURL: nil)
        ]
        @State private var userInput = ""
        @State private var selectedFileURL: URL? = nil

        var body: some View {
            Chat(
                messages: $messages,
                showMessages: $showMessages,
                userInput: $userInput,
                isLoading: $isLoading,
                aiTyping: $aiTyping,
                onSendMessage: {
                    messages.append(Message(id: UUID(), content: userInput, isUser: true, fileURL: selectedFileURL))
                    userInput = ""
                    selectedFileURL = nil
                },
                onStopResponse: {
                    isLoading = false
                },
                selectedFileURL:$selectedFileURL
            )
        }
    }

    return ChatPreviewWrapper()
}

//import SwiftUI
//import UniformTypeIdentifiers
//
//struct Chat: View {
//    @State private var isExpanded: Bool = false
//    @Binding var messages: [Message]
//    @Binding var showMessages: Bool
//    @Binding var userInput: String
//    @Binding var isLoading: Bool
//    @Binding var aiTyping: Bool
//    let onSendMessage: () -> Void
//    let onStopResponse: () -> Void
//    @State var isVisible = false
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            VStack {
//                HStack {
//                    Button(action: {
//                        withAnimation {
//                            isVisible.toggle()
//                        }
//                    }) {
//                        Image(systemName: "plus")
//                            .foregroundColor(.gray)
//                            .font(.system(size: 18))
//                            .padding(8)
//                            .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
//                            .clipShape(Circle())
//                    }
//
//                    ZStack(alignment: .leading) {
//                        if userInput.isEmpty {
//                            Text("Type in your message")
//                                .foregroundColor(Color.gray.opacity(0.5))
//                        }
//
//                        TextField("", text: $userInput)
//                    }
//                    .padding(6)
//                    .foregroundColor(.white)
//                    .cornerRadius(20)
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal, 10)
//
//                    if aiTyping {
//                        Button(action: {
//                            onStopResponse()
//                        }) {
//                            Image(systemName: "square.fill")
//                                .foregroundColor(.white)
//                                .padding(8)
//                                .background(Color(red: 123 / 255, green: 79 / 255, blue: 234 / 255))
//                                .clipShape(Circle())
//                        }
//                        .padding(.trailing, 8)
//                    } else {
//                        Button(action: {
//                            guard !userInput.isEmpty else { return }
//                            showMessages = true
//                            onSendMessage()
//                        }) {
//                            Image(systemName: "arrow.up")
//                                .foregroundColor(.white)
//                                .padding(8)
//                                .background(userInput.isEmpty ? Color.gray : Color(red: 123 / 255, green: 79 / 255, blue: 234 / 255))
//                                .clipShape(Circle())
//                        }
//                        .padding(.trailing, 8)
//                        .opacity(userInput.isEmpty ? 0 : 1)
//                    }
//                }
//                .padding(.vertical, 6)
//                .padding(.horizontal, 8)
//                .background(Color(red: 15 / 255, green: 14 / 255, blue: 17 / 255))
//                .cornerRadius(30)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 30)
//                        .stroke(Color(red: 35 / 255, green: 35 / 255, blue: 35 / 255), lineWidth: 2)
//                )
//            }
//            .padding(.horizontal)
//
//            if isVisible {
//                FileUploadMenu(isVisible: $isVisible)
//                    .offset(x: 10, y: -50)
//                    .zIndex(10)
//            }
//        }
//        .background(Color.black.edgesIgnoringSafeArea(.all))
//    }
//}
//
//struct FileUploadMenu: View {
//    @Binding var isVisible: Bool
//    @State private var isPickerPresented = false
//    @State private var selectedFileURL: URL?
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//                VStack(spacing: 0) {
//                    Button(action: {
//                        isPickerPresented.toggle()
//                    }) {
//                        HStack {
//                            Text("Upload File")
//                            Spacer()
//                            Image(systemName: "doc.text.fill")
//                        }
//                        .foregroundColor(.white)
//                        .padding()
//                    }
//                    .sheet(isPresented: $isPickerPresented) {
//                        DocumentPicker(selectedFileURL: $selectedFileURL, allowedTypes: [UTType.pdf])
//                    }
//
//            }
//        }
//        .frame(width: 200)
//        .background(Color.black.opacity(0.9))
//        .cornerRadius(10)
//        .shadow(radius: 5)
//        .opacity(isVisible ? 1 : 0)
//        .animation(.easeInOut, value: isVisible)
//        .zIndex(100)
//    }
//}
//
//struct DocumentPicker: UIViewControllerRepresentable {
//    @Binding var selectedFileURL: URL?
//    var allowedTypes: [UTType]
//
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let parent: DocumentPicker
//
//        init(_ parent: DocumentPicker) {
//            self.parent = parent
//        }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            parent.selectedFileURL = urls.first
//        }
//
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            print("Picker was cancelled")
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    struct ChatPreviewWrapper: View {
//        @State private var showMessages = false
//        @State private var isLoading = false
//        @State private var aiTyping = false
//        @State private var messages: [Message] = [
//            Message(id: UUID(), content: "Hello, how can I help you?", isUser: false)
//        ]
//        @State private var userInput = ""
//
//        var body: some View {
//            Chat(
//                messages: $messages,
//                showMessages: $showMessages,
//                userInput: $userInput,
//                isLoading: $isLoading,
//                aiTyping: $aiTyping,
//                onSendMessage: {
//                    messages.append(Message(id: UUID(), content: userInput, isUser: true))
//                    userInput = ""
//                },
//                onStopResponse: {
//                    isLoading = false
//                }
//            )
//        }
//    }
//
//    return ChatPreviewWrapper()
//}

//
//
//import SwiftUI
//
//struct Chat: View {
//    @State private var isExpanded: Bool = false
//    @Binding var messages: [Message]
//    @Binding var showMessages: Bool
//    @Binding var userInput: String
//    @Binding var isLoading: Bool
//    @Binding var aiTyping: Bool
//    let onSendMessage: () -> Void
//    let onStopResponse: () -> Void
//
//    var body: some View {
//        VStack {
//            if isExpanded {
//                VStack {
//                    Button(action: {
//                        print("Attachment clicked")
//                    }) {
//                        HStack {
//                            Image(systemName: "photo")
//                            Text("Attach Photo")
//                        }
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color(red: 18 / 255, green: 17 / 255, blue: 21 / 255))
//                        .cornerRadius(10)
//                    }
//                    .padding(.bottom, 5)
//
//                    Button(action: {
//                        print("Document clicked")
//                    }) {
//                        HStack {
//                            Image(systemName: "doc")
//                            Text("Attach Document")
//                        }
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color(red: 18 / 255, green: 17 / 255, blue: 21 / 255))
//                        .cornerRadius(10)
//                    }
//                }
//                .padding()
//                .background(Color.black.opacity(0.9))
//                .cornerRadius(15)
//                .padding(.horizontal)
//            }
//
//
//            HStack {
//                // Expand Button
//                Button(action: {
//                    withAnimation {
//                        isExpanded.toggle()
//                    }
//                }) {
//                    Image(systemName: "plus")
//                        .foregroundColor(.gray)
//                        .font(.system(size: 18))
//                        .padding(8)
//                        .background(Color(red: 40 / 255, green: 40 / 255, blue: 40 / 255))
//                        .clipShape(Circle())
//                }
//
//      
//                
//                // Message Input Field
//                TextField("Type in your message", text: $userInput)
//                    .padding(10)
//                    .foregroundColor(.white)
//                   
//                    .cornerRadius(20)
//                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal, 10)
//                
//                if aiTyping {
//                    Button(action: {
//                        onStopResponse()
//                    }) {
//                        Image(systemName: "square.fill") // Pause icon
//                            .foregroundColor(.white)
//                            .padding(8)
//                        background(Color(red: 123 / 255, green: 79 / 255, blue:234 / 255))
//                        
//                        
//                            .clipShape(Circle())
//                    }
//                    .padding(.trailing, 8)
//                } else {
//                    Button(action: {
//                        guard !userInput.isEmpty else { return }
//                        showMessages = true
//                        onSendMessage()
//                    }) {
//                        Image(systemName: "arrow.up")
//                            .foregroundColor(.white)
//                            .padding(8)
//                            .background(userInput.isEmpty ? Color.gray : Color(red: 123 / 255, green: 79 / 255, blue:234 / 255)
//                            )
//                            .clipShape(Circle())
//                            .animation(.easeInOut(duration: 0.2), value: userInput)
//                            .opacity(userInput.isEmpty ? 0 : 1)
//                            
//                    }
//                    .padding(.trailing, 8)
//                }
//            }
//            .padding(.vertical, 6)
//            .padding(.horizontal, 8)
//            .background(Color(red: 15 / 255, green: 14 / 255, blue: 17 / 255))
//            .cornerRadius(30)
//            .overlay(
//                RoundedRectangle(cornerRadius: 30)
//                    .stroke(Color(red: 35 / 255, green: 35 / 255, blue: 35 / 255), lineWidth: 2)
//                )
//            
//
//        }
//        .background(Color.black.edgesIgnoringSafeArea(.all))
//    }
//}
//
//#Preview {
//    struct ChatPreviewWrapper: View {
//        @State private var showMessages = false
//        @State private var isLoading = false
//        @State private var aiTyping = false
//        @State private var messages: [Message] = [
//            Message(id: UUID(), content: "Hello, how can I help you?", isUser: false)
//        ]
//        @State private var userInput = ""
//
//        var body: some View {
//            Chat(
//                messages: $messages,
//                showMessages: $showMessages,
//                userInput: $userInput,
//                isLoading: $isLoading,
//                aiTyping:$aiTyping,
//                onSendMessage: {
//                    messages.append(Message(id: UUID(), content: userInput, isUser: true))
//                    userInput = ""
//                },
//                onStopResponse: {
//                    isLoading = false
//                }
//            )
//        }
//    }
//
//    return ChatPreviewWrapper()
//}

////import SwiftUI
////
////struct Chat: View {
////    @State private var isExpanded: Bool = false
////    @Binding var messages: [Message]
////    @Binding var showMessages: Bool
////    @Binding var userInput: String
////    @Binding var isLoading: Bool
////    let onSendMessage: () -> Void
////
////    var body: some View {
////        VStack {
////            if isExpanded {
////                VStack {
////                    Button(action: {
////                        print("Attachment clicked")
////                    }) {
////                        HStack {
////                            Image(systemName: "photo")
////                            Text("Attach Photo")
////                        }
////                        .foregroundColor(.white)
////                        .padding()
////                        .frame(maxWidth: .infinity)
////                        .background(Color(red: 18 / 255, green: 17 / 255, blue: 21 / 255))
////                        .cornerRadius(10)
////                    }
////                    .padding(.bottom, 5)
////
////                    Button(action: {
////                        print("Document clicked")
////                    }) {
////                        HStack {
////                            Image(systemName: "doc")
////                            Text("Attach Document")
////                        }
////                        .foregroundColor(.white)
////                        .padding()
////                        .frame(maxWidth: .infinity)
////                        .background(Color(red: 18 / 255, green: 17 / 255, blue: 21 / 255))
////                        .cornerRadius(10)
////                    }
////                }
////                .padding()
////                .background(Color.black.opacity(0.9))
////                .cornerRadius(15)
////                .padding(.horizontal)
////            }
////
////            HStack {
////                Button(action: {
////                    withAnimation {
////                        isExpanded.toggle()
////                    }
////                }) {
////                    Image(systemName: "plus")
////                        .foregroundColor(.gray)
////                        .font(.system(size: 18))
////                        .padding(8)
////                        .background(Color(red: 36 / 255, green: 36 / 255, blue: 36 / 255))
////                        .clipShape(Circle())
////                }
////
////                ZStack(alignment: .leading) {
////                    if userInput.isEmpty {
////                        Text("Type in your message")
////                            .foregroundColor(.gray)
////                            .padding(.leading, 15)
////                    }
////
////                    TextField("", text: $userInput)
////                        .padding(10)
////                        .foregroundColor(.white)
////                        
////                        .cornerRadius(20)
////                }
////                .frame(maxWidth: .infinity) // Ensures proper alignment
////                .padding(.horizontal, 10)
////
////                Button(action: {
////                    guard !userInput.isEmpty else { return }
////                    showMessages = true
////                    onSendMessage()
////                }) {
////                    Image(systemName: "arrow.up")
////                        .foregroundColor(.white)
////                        .padding(8)
////                        .background(userInput.isEmpty ? Color.gray : Color.purple)
////                        .clipShape(Circle())
////                }
////                .padding(.trailing, 8)
//////                .disabled(userInput.isEmpty)
////            }
////            .padding(.vertical, 6)
////            .padding(.horizontal,8)
////            .background(Color(red: 24 / 255, green: 24 / 255, blue: 24 / 255))
////            .cornerRadius(30)
////            .padding(.horizontal)
////        }
////        .background(Color.black.edgesIgnoringSafeArea(.all))
////    }
////}
////
////#Preview {
////    @State var showMessages = false
////    @State var isLoading = false
////    @State var messages: [Message] = [
////        Message(id: UUID(), content: "Hello, how can I help you?", isUser: false)
////    ]
////    @State var userInput = ""
////
////    return Chat(
////        messages: $messages,
////        showMessages: $showMessages,
////        userInput: $userInput,
////        isLoading: $isLoading,
////        onSendMessage: {
////            messages.append(Message(id: UUID(), content: userInput, isUser: true))
////            userInput = ""
////        }
////    )
////}
////
