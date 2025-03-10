//
//  ContentView.swift
//  API Calling (Cats)
//
//  Created by Carson Payne on 3/8/25.
//
import SwiftUI
struct ContentView: View {
    @State private var facts = [String]()
    @State private var photoURL = ""
    @State private var photowidth = 300
    @State private var photoheight = 300
    @State private var showingAlert = false
    var body: some View {
        NavigationView {
            List(facts, id: \.self) { fact in
                AsyncImage(url: URL (string: photoURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    case .failure:
                        Image(systemName: "xmark.octagon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
                Text(fact)
            }
            .navigationTitle("Cat Facts and Photos")
            .toolbar {
                Button {
                    Task {
                        await loadFacts ()
                        await loadPhoto()
                    }
                    } label: {
                        Image (systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadFacts()
            }
                    .alert(isPresented: $showingAlert, content: {
                        Alert(title: Text("Loading Error"), message: Text("There was a problem loading Cat Facts"))
                    })
    .task {
        await loadPhoto()
    }
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text("Loading Error"), message: Text("There was a problem loading Cat Photos"))
            })
    }
            func loadFacts () async {
                if let url = URL(string: "https://meowfacts.herokuapp.com/?count=1") {
                    if let (data, _) = try? await URLSession.shared.data (from: url) {
                        if let decodedResponse = try? JSONDecoder().decode(Facts.self, from: data) {
                            facts = decodedResponse.facts
                            return
                        }
                    }
                }
                showingAlert = true
            }
    func loadPhoto () async {
        if let url = URL(string: "https://api.thecatapi.com/v1/images/search?limit=1") {
            if let (data, _) = try? await URLSession.shared.data (from: url) {
                if let decodedResponse = try? JSONDecoder().decode([Photos].self, from: data) {
                    photoURL = decodedResponse.first?.photourl ?? ""
                    photoheight = decodedResponse.first?.height ?? 300
                    photowidth = decodedResponse.first?.width ?? 300
                    return
                }
            }
        }
        showingAlert = true
    }
        }
        #Preview {
            ContentView()
        }
        struct Facts: Identifiable, Codable {
            var id = UUID()
            var facts: [String]
            enum CodingKeys: String, CodingKey {
                case facts = "data"
            }
        }
struct Photos: Identifiable, Codable {
    var id = UUID()
    var api_id: String
    var width: Int
    var height: Int
    var photourl: String
    enum CodingKeys: String, CodingKey {
        case api_id = "id"
        case width
        case height
        case photourl = "url"
    }
}


