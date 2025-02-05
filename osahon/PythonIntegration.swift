import SwiftUI
import PhotosUI

struct PythonIntegrationView: View {
    @State private var progressMessage: String = ""
    @State private var transcript: String = ""
    @State private var summary: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var originalVideoName: String = ""
    @State private var logs:String = ""
    @State private var isProcessingComplete:Bool = false

    var steps: [Int] = []
    @State private var urlbackend = "http://192.168.1.106:8000"
    //    @State private var urlbackend = "https://tame-riane-osahon-207ec1f6.koyeb.app"
    
    
    @State private var fetchedResults: String = ""
    @State private var fetchedTranscript: String = ""
    @State private var fetchedSummary: String = ""
    
    struct VideoResult: Codable {
        let transcript: String?
        let summary: String?
    }
    
    var body: some View {
        VStack {
            Text("Transcribe")
                .font(.system(size: 20))
                .padding(.bottom, 30)
                .foregroundColor(.white)
                .bold()
                .frame(maxWidth: .infinity)

            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "video.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pick a Video")
                        .font(.system(size: 16))
                        .bold()
                        .foregroundColor(Color.blue)
                    
                    Text("Select a video to process")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                PhotosPicker(selection: $selectedItem, matching: .videos) {
                    Text("Choose")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .overlay(
                            Capsule().stroke(Color.blue, lineWidth: 1.8)
                        )
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let newItem = newItem {
                            if let videoData = try? await newItem.loadTransferable(type: Data.self) {
                                let tempURL = saveVideoToTempDirectory(videoData: videoData, originalName: newItem.itemIdentifier ?? "video.mp4")
                                selectedVideoURL = tempURL
                                originalVideoName = tempURL.lastPathComponent
                                transcript = ""
                                summary = ""
                                progressMessage = "New video selected: \(originalVideoName)"
                            }
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.8))
            .cornerRadius(15)
            .padding(.horizontal)
          
            
            Button(action: {
                if let videoURL = selectedVideoURL {
                    Task {
                        await uploadVideo(videoURL: videoURL)
                        await pollProcessingStep()
                    }
                }
            }) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "text.page")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(selectedVideoURL == nil ? Color.gray : Color.blue )
                       
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upload & Process video")
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(selectedVideoURL == nil ? Color.gray : Color.blue )
                       
                        
                        Text("Transcribe & Summarize")
                            .font(.system(size: 12))
                            .foregroundColor(selectedVideoURL == nil ? .gray.opacity(0.8) : Color.blue )
                          
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
            }
            .padding(.horizontal)
            .disabled(selectedVideoURL == nil)
            
            if isLoading {
                ProgressView()
                    .padding()
                    .scaleEffect(1.5)
                    .tint(.blue)
            }
            
            Text(progressMessage)
                .foregroundColor(.blue)
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    if isProcessingComplete {
                        Text("🎤 **Transcript:**")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(fetchedTranscript)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("📝 **Summary:**")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(fetchedSummary)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !isProcessingComplete && !isLoading && !logs.isEmpty {
                        Text("📝 **Logs:**")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(logs)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)

            }
            .frame(maxHeight: 300, alignment: .leading)

        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
    
    
    func fetchResults() async {
        guard !originalVideoName.isEmpty else {
            DispatchQueue.main.async {
                isProcessingComplete = true
                progressMessage = "❌ No filename available for fetching results."
            }
            return
        }
        let result = "\(urlbackend)/results/\(originalVideoName)"
        print("result is", result)
        
        guard let url = URL(string: result) else {
            DispatchQueue.main.async {
                isProcessingComplete = true
                progressMessage = "❌ Invalid results URL"
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    isProcessingComplete = true
                    progressMessage = "❌ Failed to fetch results (Invalid response)"
                }
                return
            }
            
            let decoder = JSONDecoder()
            if let decodedResponse = try? decoder.decode(VideoResult.self, from: data) {
                DispatchQueue.main.async {
                    fetchedTranscript = decodedResponse.transcript ?? "No transcript available"
                    fetchedSummary = decodedResponse.summary ?? "No summary available"
                    print(fetchedTranscript)
                    print(fetchedSummary)
//                    progressMessage = "✅ Results fetched successfully"
                    progressMessage = ""
                    isProcessingComplete = true
                }
            } else {
                DispatchQueue.main.async {
                    progressMessage = "❌ Failed to decode JSON response"
                    isProcessingComplete = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                isProcessingComplete = true
                progressMessage = "❌ Error fetching results: \(error.localizedDescription)"
            }
        }
    }
    
    
    func saveVideoToTempDirectory(videoData: Data, originalName: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let videoURL = tempDir.appendingPathComponent(originalName)
        try? videoData.write(to: videoURL)
        return videoURL
    }
    
    func uploadVideo(videoURL: URL) async {
        logs = ""
        fetchedTranscript = ""
        fetchedSummary = ""
        isProcessingComplete = false

        progressMessage = "Uploading..."
        let url = "\(urlbackend)/process_video/"
        guard let url = URL(string: url) else {
            progressMessage = "Invalid API URL"
            isProcessingComplete = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        let filename = originalVideoName  // Keep original name
        let mimeType = "video/mp4"
        let fieldName = "file"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        
        do {
            let videoData = try Data(contentsOf: videoURL)
            body.append(videoData)
        } catch {
            isProcessingComplete = true
            progressMessage = "Error loading video data: \(error.localizedDescription)"
            return
        }
        
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        
                        progressMessage = ""
                        transcript = responseJSON["transcript"] as? String ?? "No transcript available"
                        summary = responseJSON["summary"] as? String ?? "No summary available"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    isProcessingComplete = true
                    progressMessage = "Upload failed: \(response)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                isProcessingComplete = true
                progressMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    
    func pollProcessingStep() async {
        let checkUrl = "\(urlbackend)/current_step/"
        guard let url = URL(string: checkUrl) else { return }
        
        while true {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        isProcessingComplete = true
                        progressMessage = "❌ Failed to get logs"
                    }
                    return
                }
                
                if let stepResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let logsArray = stepResponse["logs"] as? [String] {

                    let logsString = logsArray.joined(separator: "\n")
                    
                    DispatchQueue.main.async {
                        logs = logsString
                    }

                    if logsArray.contains("[Step 9] Processing complete.") {
                        DispatchQueue.main.async {
                            isProcessingComplete = true
                            progressMessage = "✅ Processing complete"
                        }
                        await fetchResults()
                        return
                    }
                        if logsArray.contains(where: { $0.contains("[Error]") }) {
                        DispatchQueue.main.async {
                            isProcessingComplete = true
                            progressMessage = ""
                        }
                        return
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        progressMessage = "⚠️ No logs available"
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    isProcessingComplete = true
                    progressMessage = "❌ Error fetching logs: \(error.localizedDescription)"
                }
                return
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    
        //igg working
//    func pollProcessingStep() async {
//        let checkUrl = "\(urlbackend)/current_step/"
//        guard let url = URL(string: checkUrl) else { return }
//        
//        while true {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    DispatchQueue.main.async {
//                        isProcessingComplete = true
//                        progressMessage = "❌ Failed to get logs"
//                    }
//                    return
//                }
//                
//                if let stepResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let logsArray = stepResponse["logs"] as? [String] {
//                    
//                    let logsString = logsArray.joined(separator: "\n") // Convert logs array to a single string
//                    
//                    DispatchQueue.main.async {
//                        logs = logsString  // Store logs in a variable
//                    }
//
//                    // ✅ Stop polling if processing is complete
//                    if logsArray.contains("[Step 9] Processing complete.") {
//                        DispatchQueue.main.async {
//                            isProcessingComplete = true
//                            progressMessage = "✅ Processing complete"
//                        }
//                        return
//                    }
//                    
//                } else {
//                    DispatchQueue.main.async {
//                        progressMessage = "⚠️ No logs available"
//                    }
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    isProcessingComplete = true
//                    progressMessage = "❌ Error fetching logs: \(error.localizedDescription)"
//                }
//                return
//            }
//            
//            try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds before polling again
//        }
//        if isProcessingComplete {
//                await fetchResults()
//            }
//    }

    
//    func pollProcessingStep() async {
//        let checkUrl = "\(urlbackend)/current_step/"
//        guard let url = URL(string: checkUrl) else { return }
//        
//        while true {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    DispatchQueue.main.async {
//                        isProcessingComplete = true
//                        progressMessage = "❌ Failed to get logs"
//                    }
//                    return
//                }
//                
//                if let stepResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let logsArray = stepResponse["logs"] as? [String] {
//
//                    let logsString = logsArray.joined(separator: "\n") // Convert logs array to a single string
//                    
//                    // Print logs
//                    print("📌 Logs Received:\n\(logsString)")
//                    
//                    DispatchQueue.main.async {
//                        logs = logsString  // Store logs in a variable
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        progressMessage = "⚠️ No logs available"
//                    }
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    isProcessingComplete = true
//                    progressMessage = "❌ Error fetching logs: \(error.localizedDescription)"
//                }
//                return
//            }
//            
//            try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds before polling again
//        }
//    }


//    func pollProcessingStep() async {
//        let checkUrl = "\(urlbackend)/current_step/"
//        guard let url = URL(string: checkUrl) else { return }
//        
//        while true {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    DispatchQueue.main.async {
//                        isProcessingComplete = true
//                        progressMessage = "❌ Failed to get processing step"
//                    }
//                    return
//                }
//                
//                if let stepResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   
//                   let step = stepResponse["step"] as? Int,
//                   let logsArray = stepResponse["logs"] as? [String] { // Fix: Extract logs as an array
//                    print(step)
//                    print(logsArray)
//                    DispatchQueue.main.async {
//                       
//                        progressMessage = "📌 Current Step: \(step)"
//                        logs = logsArray.joined(separator: "\n") // Convert array to a single string
//                    }
//                    
//                    print("Logs:\n", logs)
//                    print("Step is", step)
//                    
//                    if step == 9 {
//                        DispatchQueue.main.async {
//                            isProcessingComplete = true
//                            progressMessage = "✅ Processingggg!"
//                        }
//                        return
//                    }
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    isProcessingComplete = true
//                    progressMessage = "❌ Error polling processing step: \(error.localizedDescription)"
//                }
//                return
//            }
//            
//            try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds before polling again
//        }
//    }
    
}
    //    func pollProcessingStep() async {
    //           let checkUrl = "\(urlbackend)/current_step/"
    //           guard let url = URL(string: checkUrl) else { return }
    //
    //           while true {
    //               do {
    //                   let (data, response) = try await URLSession.shared.data(from: url)
    //                   guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    //                       DispatchQueue.main.async {
    //                           progressMessage = "❌ Failed to get processing step"
    //                       }
    //                       return
    //                   }
    //
    //                   if let stepResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
    //
    //                      let step = stepResponse["step"] as? Int {
    //                       DispatchQueue.main.async {
    //                           progressMessage = "📌 Current Step: \(step)"
    //                       }
    //                       logs = stepResponse["logs"] as? String {
    //
    //                       print("Logs:", logs)
    //
    //                       progressMessage = "📌 Current Step: \(step)"
    //                       print("step is",step)
    //
    //                       if step == 9 {
    //                           DispatchQueue.main.async {
    //                               progressMessage = "✅ Processing complete!"
    //                           }
    //                           return
    //                       }
    //                   }
    //
    //               } catch {
    //                   DispatchQueue.main.async {
    //                       progressMessage = "❌ Error polling processing step: \(error.localizedDescription)"
    //                   }
    //                   return
    //               }
    //
    //               try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds before polling again
    //           }
    //       }
    //
    //}
    
    struct PythonIntegrationView_Previews: PreviewProvider {
        static var previews: some View {
            PythonIntegrationView()
        }
    }
    
    //going to add fetched results
    //import SwiftUI
    //import PhotosUI
    //
    //struct PythonIntegrationView: View {
    //    @State private var progressMessage: String = "Upload a video"
    //    @State private var transcript: String = ""
    //    @State private var summary: String = ""
    //    @State private var isLoading: Bool = false
    //    @State private var selectedItem: PhotosPickerItem? = nil
    //    @State private var selectedVideoURL: URL? = nil
    //    @State private var originalVideoName: String = ""  // Store original filename
    //    @State private var urlbackend = "http://192.168.1.106:8000/process_video/" // Fixed URL format
    //
    //    var body: some View {
    //        VStack {
    //            Text("Transcribe")
    //                .font(.system(size: 20))
    //                .padding(.bottom, 30)
    //                .foregroundColor(.white)
    //                .bold()
    //                .frame(maxWidth: .infinity)
    //
    //            if let videoURL = selectedVideoURL {
    //                Text("Selected: \(originalVideoName)") // Show original name
    //                    .padding()
    //                    .foregroundColor(.blue)
    //            } else {
    //                Text("No video selected")
    //                    .padding()
    //            }
    //
    //            HStack(spacing: 15) {
    //                ZStack {
    //                    Circle()
    //                        .fill(Color.black)
    //                        .frame(width: 50, height: 50)
    //
    //                    Image(systemName: "video.fill")
    //                        .font(.system(size: 22, weight: .bold))
    //                        .foregroundColor(Color.blue)
    //                }
    //
    //                VStack(alignment: .leading, spacing: 2) {
    //                    Text("Pick a Video")
    //                        .font(.system(size: 16))
    //                        .bold()
    //                        .foregroundColor(Color.blue)
    //
    //                    Text("Select a video to process")
    //                        .font(.system(size: 12))
    //                        .foregroundColor(.gray.opacity(0.8))
    //                }
    //                .frame(maxWidth: .infinity, alignment: .leading)
    //
    //                PhotosPicker(selection: $selectedItem, matching: .videos) {
    //                    Text("Choose")
    //                        .font(.system(size: 12, weight: .medium))
    //                        .padding(.horizontal, 12)
    //                        .padding(.vertical, 6)
    //                        .overlay(
    //                            Capsule().stroke(Color.blue, lineWidth: 1.8)
    //                        )
    //                }
    //                .onChange(of: selectedItem) { newItem in
    //                    Task {
    //                        if let newItem = newItem {
    //                            if let videoData = try? await newItem.loadTransferable(type: Data.self) {
    //                                let tempURL = saveVideoToTempDirectory(videoData: videoData, /*originalName: newItem.itemIdentifier ?? "video.mp4")*/
    //                                originalName: newItem.itemIdentifier ?? newItem.itemIdentifier)
    //                                selectedVideoURL = tempURL
    //                                originalVideoName = tempURL.lastPathComponent
    //                                transcript = ""
    //                                summary = ""
    //                                progressMessage = "New video selected: \(originalVideoName)"
    //                            }
    //                        }
    //                    }
    //                }
    //
    //
    //
    //            }
    //            .padding()
    //            .background(Color.black.opacity(0.8))
    //            .cornerRadius(15)
    //            .padding()
    //
    //            Button(action: {
    //                if let videoURL = selectedVideoURL {
    //                    Task {
    //                        await uploadVideo(videoURL: videoURL)
    //                    }
    //                }
    //            }) {
    //                HStack(spacing: 15) {
    //                    ZStack {
    //                        Circle()
    //                            .fill(Color.black)
    //                            .frame(width: 50, height: 50)
    //
    //                        Image(systemName: "text.page")
    //                            .font(.system(size: 22, weight: .bold))
    //                            .foregroundColor(Color.blue)
    //                    }
    //
    //                    VStack(alignment: .leading, spacing: 2) {
    //                        Text("Upload & Process video")
    //                            .font(.system(size: 16))
    //                            .bold()
    //                            .foregroundColor(Color.blue)
    //
    //                        Text("Transcribe & Summarize")
    //                            .font(.system(size: 12))
    //                            .foregroundColor(.gray.opacity(0.8))
    //                    }
    //                    .frame(maxWidth: .infinity, alignment: .leading)
    //                }
    //                .padding()
    //                .background(Color.black.opacity(0.8))
    //                .cornerRadius(15)
    //            }
    //            .padding()
    //            .disabled(selectedVideoURL == nil)
    //
    //            if isLoading {
    //                ProgressView()
    //                    .padding()
    //                    .scaleEffect(1.5)
    //                    .tint(.blue)
    //            }
    //
    //            Text(progressMessage)
    //                .foregroundColor(.blue)
    //                .padding()
    //
    //            ScrollView {
    //                VStack(alignment: .leading, spacing: 10) {
    //                    if !transcript.isEmpty {
    //                        Text("🎤 **Transcript:**")
    //                            .font(.headline)
    //                            .foregroundColor(.white)
    //                        Text(transcript)
    //                            .foregroundColor(.white)
    //                    }
    //
    //                    if !summary.isEmpty {
    //                        Text("📝 **Summary:**")
    //                            .font(.headline)
    //                            .foregroundColor(.white)
    //                        Text(summary)
    //                            .foregroundColor(.white)
    //                    }
    //                }
    //                .padding()
    //            }
    //            .frame(maxHeight: 300)
    //        }
    //        .padding()
    //        .background(Color.black.ignoresSafeArea())
    //    }
    //
    //    func uploadVideo(videoURL: URL) async {
    //        progressMessage = "Uploading..."
    //        guard let url = URL(string: urlbackend) else {
    //            progressMessage = "Invalid API URL"
    //            return
    //        }
    //
    //        isLoading = true
    //        defer { isLoading = false }
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"
    //
    //        let boundary = "Boundary-\(UUID().uuidString)"
    //        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    //
    //        var body = Data()
    //
    //        let filename = originalVideoName  // Keep original name
    //        let mimeType = "video/mp4"
    //        let fieldName = "file"
    //
    //        body.append("--\(boundary)\r\n".data(using: .utf8)!)
    //        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    //        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    //
    //        do {
    //            let videoData = try Data(contentsOf: videoURL)
    //            body.append(videoData)
    //        } catch {
    //            progressMessage = "Error loading video data: \(error.localizedDescription)"
    //            return
    //        }
    //
    //        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    //        request.httpBody = body
    //
    //        do {
    //            let (data, response) = try await URLSession.shared.data(for: request)
    //            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
    //                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
    //                    DispatchQueue.main.async {
    //                        progressMessage = "✅ Processing complete!"
    //                        transcript = responseJSON["transcript"] as? String ?? "No transcript available"
    //                        summary = responseJSON["summary"] as? String ?? "No summary available"
    //                    }
    //                }
    //            } else {
    //                DispatchQueue.main.async {
    //                    progressMessage = "Upload failed: \(response)"
    //                }
    //            }
    //        } catch {
    //            DispatchQueue.main.async {
    //                progressMessage = "Error: \(error.localizedDescription)"
    //            }
    //        }
    //    }
    //
    //    func saveVideoToTempDirectory(videoData: Data, originalName: String) -> URL {
    //        let tempDir = FileManager.default.temporaryDirectory
    //        let videoURL = tempDir.appendingPathComponent(originalName) // Keep original filename
    //        try? videoData.write(to: videoURL)
    //        return videoURL
    //    }
    //}
    //
    //struct PythonIntegrationView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        PythonIntegrationView()
    //    }
    //}
    //
    //////using formatted file name
    ////import SwiftUI
    ////import PhotosUI
    ////
    ////struct PythonIntegrationView: View {
    ////    @State private var progressMessage: String = "Upload a video"
    ////    @State private var transcript: String = ""
    ////    @State private var summary: String = ""
    ////    @State private var isLoading: Bool = false
    ////    @State private var selectedItem: PhotosPickerItem? = nil
    ////    @State private var selectedVideoURL: URL? = nil
    ////    @State private var urlbackend = "http:192.168.1.106:8000/process_video/"
    //////    @State private var urlbackend = "https://tame-riane-osahon-207ec1f6.koyeb.app/process_video/"
    ////
    ////    var body: some View {
    ////        VStack {
    ////            Text("Transcribe")
    ////              .font(.system(size: 20))
    ////              .padding(.bottom,30)
    ////              .foregroundColor(.white)
    ////              .bold()
    ////              .frame(maxWidth: .infinity)
    ////
    ////            if let videoURL = selectedVideoURL {
    ////                Text("Selected: \(videoURL.lastPathComponent)")
    ////                    .padding()
    ////                    .foregroundColor(.blue)
    ////            } else {
    ////                Text("No video selected")
    ////                    .padding()
    ////            }
    ////
    ////
    ////
    ////
    ////            HStack(spacing: 15) {
    ////                            ZStack {
    ////                                Circle()
    ////                                    .fill(Color.black)
    ////                                    .frame(width: 50, height: 50)
    ////
    ////                                Image(systemName: "video.fill")
    ////                                    .font(.system(size: 22, weight: .bold))
    ////                                    .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
    ////                            }
    ////
    ////                            VStack(alignment: .leading, spacing: 2) {
    ////                                Text("Pick a Video")
    ////                                    .font(.system(size: 16))
    ////                                    .bold()
    ////                                    .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
    ////
    ////                                Text("Select a video to process")
    ////                                    .font(.system(size: 12))
    ////                                    .foregroundColor(.gray.opacity(0.8))
    ////                            }
    ////                            .frame(maxWidth: .infinity, alignment: .leading)
    ////
    ////                            PhotosPicker(selection: $selectedItem, matching: .videos) {
    ////                                Text("Choose")
    ////                                    .font(.system(size: 12, weight: .medium))
    ////                                    .padding(.horizontal, 12)
    ////                                    .padding(.vertical, 6)
    ////                                    .overlay(
    ////                                        Capsule()
    ////                                            .stroke(
    ////                                                LinearGradient(
    ////                                                    gradient: Gradient(colors: [
    ////                                                        Color(red: 65/225, green: 127/225, blue: 224/225),
    ////                                                        Color(red: 65/225, green: 127/225, blue: 224/225).opacity(0.5)
    ////                                                    ]),
    ////                                                    startPoint: .leading,
    ////                                                    endPoint: .trailing
    ////                                                ),
    ////                                                lineWidth: 1.8
    ////                                            )
    ////                                    )
    ////                            }
    ////                            .onChange(of: selectedItem) { newItem in
    ////                                Task {
    ////                                    if let newItem = newItem {
    ////                                        if let videoData = try? await newItem.loadTransferable(type: Data.self) {
    ////                                            let tempURL = saveVideoToTempDirectory(videoData: videoData)
    ////                                            selectedVideoURL = tempURL
    ////                                            transcript = ""
    ////                                            summary = ""
    ////                                            progressMessage = "New video selected, ready to upload."
    ////                                        }
    ////                                    }
    ////                                }
    ////                            }
    ////                        }
    ////                        .padding(.horizontal, 12)
    ////                        .padding(.vertical, 12)
    ////                        .background(Color(red: 16 / 255, green: 15 / 255, blue: 20 / 255))
    ////                        .cornerRadius(15)
    ////                        .padding()
    ////
    ////            Button(action: {
    ////                if let videoURL = selectedVideoURL {
    ////                    Task {
    ////                        await uploadVideo(videoURL: videoURL)
    ////                    }
    ////                }
    ////            }) {
    ////
    ////                HStack(spacing: 15) {
    ////                    ZStack {
    ////                        Circle()
    ////                            .fill(Color.black)
    ////                            .frame(width: 50, height: 50)
    ////
    ////                        Image(systemName: "text.page")
    ////                            .font(.system(size: 22, weight: .bold))
    ////                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
    ////                    }
    ////
    ////                    VStack(alignment: .leading, spacing: 2) {
    ////                        Text("Upload & Process video")
    ////                            .font(.system(size: 16))
    ////                            .bold()
    ////                            .foregroundColor(Color(red: 65/225, green: 127/225, blue: 224/225))
    ////
    ////                        Text("Transcribe & Summarize")
    ////                            .font(.system(size: 12))
    ////                            .foregroundColor(.gray.opacity(0.8))
    ////                    }
    ////                    .frame(maxWidth: .infinity, alignment: .leading)
    ////
    ////
    ////
    ////                }
    ////                .padding(.horizontal, 12)
    ////                .padding(.vertical, 12)
    ////                .background(Color(red: 16 / 255, green: 15 / 255, blue: 20 / 255))
    ////                .cornerRadius(15)
    ////
    ////            }
    ////            .padding()
    ////            .disabled(selectedVideoURL == nil)
    ////
    ////
    ////            if isLoading {
    ////                ProgressView()
    ////                    .padding()
    ////                    .scaleEffect(1.5)
    ////                    .tint(.blue)
    ////            }
    ////
    ////            Text(progressMessage)
    ////                .foregroundColor(.blue)
    ////                .padding()
    ////
    ////            ScrollView {
    ////                VStack(alignment: .leading, spacing: 10) {
    ////                    if !transcript.isEmpty {
    ////                        Text("🎤 **Transcript:**")
    ////                            .font(.headline)
    ////                            .foregroundColor(.white)
    ////                        Text(transcript)
    ////                            .foregroundColor(.white)
    ////                    }
    ////
    ////                    if !summary.isEmpty {
    ////                        Text("📝 **Summary:**")
    ////                            .font(.headline)
    ////                            .foregroundColor(.white)
    ////                        Text(summary)
    ////                            .foregroundColor(.white)
    ////                    }
    ////                }
    ////                .padding()
    ////            }
    ////            .frame(maxHeight: 300) // Scrollable content
    ////        }
    ////        .padding()
    ////        .background(Color.black)
    ////        .background(Color.black.ignoresSafeArea())
    ////    }
    ////
    ////
    ////
    //////    http:192.168.73.75:8000/process_video/
    ////
    ////    func uploadVideo(videoURL: URL) async {
    ////        progressMessage=""
    ////        guard let url = URL(string: urlbackend) else {
    ////            progressMessage = "Invalid API URL"
    ////            return
    ////        }
    ////
    ////        isLoading = true
    ////        defer { isLoading = false }
    ////
    ////        var request = URLRequest(url: url)
    ////        request.httpMethod = "POST"
    ////
    ////        let boundary = "Boundary-\(UUID().uuidString)"
    ////        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    ////
    ////        var body = Data()
    ////
    ////        let filename = videoURL.lastPathComponent
    ////        let mimeType = "video/mp4"
    ////        let fieldName = "file"
    ////
    ////        body.append("--\(boundary)\r\n".data(using: .utf8)!)
    ////        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    ////        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    ////
    ////        do {
    ////            let videoData = try Data(contentsOf: videoURL)
    ////            body.append(videoData)
    ////        } catch {
    ////            progressMessage = "Error loading video data: \(error.localizedDescription)"
    ////            return
    ////        }
    ////
    ////        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    ////
    ////        request.httpBody = body
    ////
    ////        do {
    ////            let (data, response) = try await URLSession.shared.data(for: request)
    ////            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
    ////                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
    ////                    DispatchQueue.main.async {
    ////                        progressMessage = "✅ Processing complete!"
    ////                        transcript = responseJSON["transcript"] as? String ?? "No transcript available"
    ////                        summary = responseJSON["summary"] as? String ?? "No summary available"
    ////                    }
    ////                }
    ////            } else {
    ////                DispatchQueue.main.async {
    ////                    progressMessage = "Upload failed: \(response)"
    ////                }
    ////            }
    ////        } catch {
    ////            DispatchQueue.main.async {
    ////                progressMessage = "Error: \(error.localizedDescription)"
    ////            }
    ////        }
    ////    }
    ////
    ////    func saveVideoToTempDirectory(videoData: Data) -> URL {
    ////        let tempDir = FileManager.default.temporaryDirectory
    ////        let videoURL = tempDir.appendingPathComponent("uploaded_video.mp4")
    ////        try? videoData.write(to: videoURL)
    ////        return videoURL
    ////    }
    ////}
    ////
    ////struct PythonIntegrationView_Previews: PreviewProvider {
    ////    static var previews: some View {
    ////        PythonIntegrationView()
    ////    }
    ////}
    ////
    ////
    //////
    //////import SwiftUI
    //////import PhotosUI
    //////
    //////struct PythonIntegrationView: View {
    //////    @State private var apiResponse: String = "Waiting for response..."
    //////    @State private var transcript: String = ""
    //////    @State private var summary: String = ""
    //////    @State private var isLoading: Bool = false
    //////    @State private var selectedItem: PhotosPickerItem? = nil
    //////    @State private var selectedVideoURL: URL? = nil
    //////
    //////    var body: some View {
    //////        VStack {
    //////            Text("FastAPI Video Upload")
    //////                .font(.title)
    //////                .bold()
    //////
    //////            if let videoURL = selectedVideoURL {
    //////                Text("f: \(videoURL.lastPathComponent)")
    //////                    .padding()
    //////                    .foregroundColor(.green)
    //////            } else {
    //////                Text("No video selected")
    //////                    .padding()
    //////            }
    //////
    //////            PhotosPicker(selection: $selectedItem, matching: .videos) {
    //////                Text("Pick a Video")
    //////                    .padding()
    //////                    .frame(maxWidth: .infinity)
    //////                    .background(Color.blue)
    //////                    .foregroundColor(.white)
    //////                    .cornerRadius(10)
    //////            }
    //////            .padding()
    //////            .onChange(of: selectedItem) { newItem in
    //////                Task {
    //////                    if let newItem = newItem {
    //////                        if let videoData = try? await newItem.loadTransferable(type: Data.self) {
    //////                            let tempURL = saveVideoToTempDirectory(videoData: videoData)
    //////                            selectedVideoURL = tempURL
    //////                        }
    //////                    }
    //////                }
    //////            }
    //////
    //////            Button(action: {
    //////                if let videoURL = selectedVideoURL {
    //////                    Task {
    //////                        await uploadVideo(videoURL: videoURL)
    //////                    }
    //////                }
    //////            }) {
    //////                Text("Upload & Process Video")
    //////                    .padding()
    //////                    .frame(maxWidth: .infinity)
    //////                    .background(Color.green)
    //////                    .foregroundColor(.white)
    //////                    .cornerRadius(10)
    //////            }
    //////            .padding()
    //////            .disabled(selectedVideoURL == nil)
    //////
    //////            if isLoading {
    //////                ProgressView()
    //////                    .padding()
    //////            }
    //////
    //////            // ScrollView to Display Transcript & Summary
    //////            ScrollView {
    //////                VStack(alignment: .leading, spacing: 10) {
    //////                    if !transcript.isEmpty {
    //////                        Text("🎤 **Transcript:**")
    //////                            .font(.headline)
    //////                            .foregroundColor(.black)
    //////                        Text(transcript)
    //////                            .foregroundColor(.blue)
    //////                    }
    //////
    //////                    if !summary.isEmpty {
    //////                        Text("📝 **Summary:**")
    //////                            .font(.headline)
    //////                            .foregroundColor(.black)
    //////                        Text(summary)
    //////                            .foregroundColor(.purple)
    //////                    }
    //////                }
    //////                .padding()
    //////            }
    //////            .frame(maxHeight: 300) // ScrollView height limit
    //////        }
    //////        .padding()
    //////    }
    //////
    //////    func uploadVideo(videoURL: URL) async {
    //////        transcript = ""
    //////        summary = ""
    //////        guard let url = URL(string: "http://192.168.73.75:8000/process_video/") else {
    //////            apiResponse = "Invalid API URL"
    //////            return
    //////        }
    //////
    //////        isLoading = true
    //////        defer { isLoading = false }
    //////
    //////        var request = URLRequest(url: url)
    //////        request.httpMethod = "POST"
    //////
    //////        let boundary = "Boundary-\(UUID().uuidString)"
    //////        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    //////
    //////        var body = Data()
    //////
    //////        let filename = videoURL.lastPathComponent
    //////        let mimeType = "video/mp4"
    //////        let fieldName = "file"
    //////
    //////        body.append("--\(boundary)\r\n".data(using: .utf8)!)
    //////        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    //////        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    //////
    //////        do {
    //////            let videoData = try Data(contentsOf: videoURL)
    //////            body.append(videoData)
    //////        } catch {
    //////            apiResponse = "Error loading video data: \(error.localizedDescription)"
    //////            return
    //////        }
    //////
    //////        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    //////
    //////        request.httpBody = body
    //////
    //////        do {
    //////            let (data, response) = try await URLSession.shared.data(for: request)
    //////            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
    //////                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
    //////                    DispatchQueue.main.async {
    //////                        self.apiResponse = "Processing complete!"
    //////                        self.transcript = responseJSON["transcript"] as? String ?? "No transcript available"
    //////                        self.summary = responseJSON["summary"] as? String ?? "No summary available"
    //////                    }
    //////                }
    //////            } else {
    //////                DispatchQueue.main.async {
    //////                    apiResponse = "Upload failed: \(response)"
    //////                }
    //////            }
    //////        } catch {
    //////            DispatchQueue.main.async {
    //////                apiResponse = "Error: \(error.localizedDescription)"
    //////            }
    //////        }
    //////    }
    //////
    //////    func saveVideoToTempDirectory(videoData: Data) -> URL {
    //////        let tempDir = FileManager.default.temporaryDirectory
    //////        let videoURL = tempDir.appendingPathComponent("uploaded_video.mp4")
    //////        try? videoData.write(to: videoURL)
    //////        return videoURL
    //////    }
    //////}
    //////
    //////struct PythonIntegrationView_Previews: PreviewProvider {
    //////    static var previews: some View {
    //////        PythonIntegrationView()
    //////    }
    //////}
    ////
    //////////
    //////////  PythonIntegration.swift
    //////////  osahon
    //////////
    //////////  Created by mav on 29/01/2025.
    //////////
    ////////
    ////////import SwiftUI
    ////////import PhotosUI
    ////////
    ////////struct PythonIntegrationView: View {
    ////////    @State private var apiResponse: String = "Waiting for response..."
    ////////    @State private var isLoading: Bool = false
    ////////    @State private var selectedItem: PhotosPickerItem? = nil
    ////////    @State private var selectedVideoURL: URL? = nil
    ////////
    ////////    var body: some View {
    ////////        VStack {
    ////////            Text("FastAPI Video Upload")
    ////////                .font(.title)
    ////////                .bold()
    ////////
    ////////            if let videoURL = selectedVideoURL {
    ////////                Text("f: \(videoURL.lastPathComponent)")
    ////////                    .padding()
    ////////                    .foregroundColor(.green)
    ////////            } else {
    ////////                Text("No video selected")
    ////////                    .padding()
    ////////            }
    ////////
    ////////            PhotosPicker(selection: $selectedItem, matching: .videos) {
    ////////                Text("Pick a Video")
    ////////                    .padding()
    ////////                    .frame(maxWidth: .infinity)
    ////////                    .background(Color.blue)
    ////////                    .foregroundColor(.white)
    ////////                    .cornerRadius(10)
    ////////            }
    ////////            .padding()
    ////////            .onChange(of: selectedItem) { newItem in
    ////////                Task {
    ////////                    if let newItem = newItem {
    ////////                        if let videoData = try? await newItem.loadTransferable(type: Data.self) {
    ////////                            let tempURL = saveVideoToTempDirectory(videoData: videoData)
    ////////                            selectedVideoURL = tempURL
    ////////                        }
    ////////                    }
    ////////                }
    ////////            }
    ////////
    ////////            Button(action: {
    ////////                if let videoURL = selectedVideoURL {
    ////////                    Task {
    ////////                        await uploadVideo(videoURL: videoURL)
    ////////                    }
    ////////                }
    ////////            }) {
    ////////                Text("Upload & Process Video")
    ////////                    .padding()
    ////////                    .frame(maxWidth: .infinity)
    ////////                    .background(Color.green)
    ////////                    .foregroundColor(.white)
    ////////                    .cornerRadius(10)
    ////////            }
    ////////            .padding()
    ////////            .disabled(selectedVideoURL == nil)
    ////////
    ////////            if isLoading {
    ////////                ProgressView()
    ////////                    .padding()
    ////////            } else {
    ////////                Text(apiResponse)
    ////////                    .foregroundColor(.blue)
    ////////                    .padding()
    ////////            }
    ////////        }
    ////////        .padding()
    ////////    }
    ////////
    ////////    func uploadVideo(videoURL: URL) async {
    ////////        guard let url = URL(string: "http://192.168.73.75:8000/process_video/") else {
    ////////            apiResponse = "Invalid API URL"
    ////////            return
    ////////        }
    ////////
    ////////        isLoading = true
    ////////        defer { isLoading = false } // Reset loading state after request
    ////////
    ////////        var request = URLRequest(url: url)
    ////////        request.httpMethod = "POST"
    ////////
    ////////        let boundary = "Boundary-\(UUID().uuidString)"
    ////////        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    ////////
    ////////        var body = Data()
    ////////
    ////////        let filename = videoURL.lastPathComponent
    ////////        let mimeType = "video/mp4"
    ////////        let fieldName = "file"
    ////////
    ////////        body.append("--\(boundary)\r\n".data(using: .utf8)!)
    ////////        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    ////////        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    ////////
    ////////        do {
    ////////            let videoData = try Data(contentsOf: videoURL)
    ////////            body.append(videoData)
    ////////        } catch {
    ////////            apiResponse = "Error loading video data: \(error.localizedDescription)"
    ////////            return
    ////////        }
    ////////
    ////////        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    ////////
    ////////        request.httpBody = body
    ////////
    ////////        do {
    ////////            let (data, response) = try await URLSession.shared.data(for: request)
    ////////            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
    ////////                if let responseText = String(data: data, encoding: .utf8) {
    ////////                    DispatchQueue.main.async {
    ////////                        apiResponse = responseText
    ////////                    }
    ////////                }
    ////////            } else {
    ////////                DispatchQueue.main.async {
    ////////                    apiResponse = "Upload failed: \(response)"
    ////////                }
    ////////            }
    ////////        } catch {
    ////////            DispatchQueue.main.async {
    ////////                apiResponse = "Error: \(error.localizedDescription)"
    ////////            }
    ////////        }
    ////////    }
    ////////
    ////////    func saveVideoToTempDirectory(videoData: Data) -> URL {
    ////////        let tempDir = FileManager.default.temporaryDirectory
    ////////        let videoURL = tempDir.appendingPathComponent("uploaded_video.mp4")
    ////////        try? videoData.write(to: videoURL)
    ////////        return videoURL
    ////////    }
    ////////}
    ////////
    ////////struct PythonIntegrationView_Previews: PreviewProvider {
    ////////    static var previews: some View {
    ////////        PythonIntegrationView()
    ////////    }
    ////////}

