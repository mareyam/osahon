import SwiftUI

struct ServerView: View {
    @State private var serverResponse: String = "Press the button to execute functions"
    @State private var logs: [String] = []
    
    @State private var baseURL = "http://192.168.1.106:8000"

    var body: some View {
        VStack(spacing: 20) {
            Text(serverResponse)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                Task {
                    await executeABCD()
                }
            }) {
                Text("Execute A, B, C, D")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                Task {
                    await fetchLogs()
                }
            }) {
                Text("Fetch Logs")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            List(logs, id: \.self) { log in
                Text(log)
                    .foregroundColor(.white)
            }
            .frame(height: 200)
            .background(Color.black)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    func executeABCD() async {
        let endpoint = "\(baseURL)/execute-abcd"
        print("🔵 Sending request to: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async {
                print("❌ Invalid URL: \(endpoint)")
                serverResponse = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("❌ No HTTP Response")
                    serverResponse = "❌ No HTTP Response"
                }
                return
            }
            
            print("🔵 HTTP Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                let responseString = String(data: data, encoding: .utf8) ?? "No Response"
                DispatchQueue.main.async {
                    print("✅ Executed Successfully: \(responseString)")
                    serverResponse = "✅ Executed: \(responseString)"
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ Server Error - Status Code: \(httpResponse.statusCode)")
                    serverResponse = "❌ Server Error: \(httpResponse.statusCode)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("❌ Request Failed: \(error.localizedDescription)")
                serverResponse = "❌ Request Failed: \(error.localizedDescription)"
            }
        }
    }

    func fetchLogs() async {
        let endpoint = "\(baseURL)/logs"
        print("🔵 Fetching logs from: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async {
                print("❌ Invalid URL: \(endpoint)")
                serverResponse = "Invalid URL"
            }
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("❌ No HTTP Response")
                    serverResponse = "❌ No HTTP Response"
                }
                return
            }
            
            print("🔵 HTTP Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                if let decodedResponse = try? JSONDecoder().decode([String: [String]].self, from: data),
                   let fetchedLogs = decodedResponse["logs"] {
                    DispatchQueue.main.async {
                        logs = fetchedLogs
                        print("✅ Logs Fetched Successfully: \(fetchedLogs)")
                        serverResponse = "✅ Logs Fetched"
                    }
                } else {
                    DispatchQueue.main.async {
                        print("❌ Failed to parse logs")
                        serverResponse = "❌ Failed to parse logs"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ Server Error - Status Code: \(httpResponse.statusCode)")
                    serverResponse = "❌ Server Error: \(httpResponse.statusCode)"
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("❌ Request Failed: \(error.localizedDescription)")
                serverResponse = "❌ Request Failed: \(error.localizedDescription)"
            }
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView()
    }
}
