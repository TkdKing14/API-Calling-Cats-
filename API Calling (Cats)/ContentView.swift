//
//  ContentView.swift
//  API Calling (Cats)
//
//  Created by Carson Payne on 3/8/25.
//
import SwiftUI
struct ContentView: View {
    @State private var facts = [String]()                                               //allows facts to have an interchangable variuable
    @State private var photoURL = ""
    @State private var photowidth = 300
    @State private var photoheight = 300
    @State private var showingAlert = false
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            NavigationView {
                List(facts, id: \.self) { fact in                                       //displays data in a scrollable list and states that facts can be identified by itself
                    AsyncImage(url: URL (string: photoURL)) { phase in                  //displays the image through the given url
                        switch phase {
                        case .empty:                                                    //placeholder
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .border(Color.black, width: 10)
                        case .failure:
                            Image(systemName: "cat")                                    //this image / case is displayed if the image in not generated. a gray cat will be shown in the top left before a picture is displayed incase of falurie in display.
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        @unknown default:                                               //if something that is "Unknown" happens with the api, the view will be left empty
                            EmptyView()
                        }
                    }
                    Text(fact)
                        .foregroundStyle(Color.blue)
                        .background(Color.gray.opacity(0.4))
                        .border(Color.orange, width: 2)
                        .cornerRadius(5)
                }
                .navigationTitle("Cat Facts and Photos")
                .toolbar {
                    Button {
                        Task {
                            await loadFacts()
                            await loadPhoto()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .scrollContentBackground(.hidden)                                    //changes visability of the backkground when scrrolling
                .background(Color.white)
            }
        }
        Image("Paw")
            .resizable()
            .frame(width: 500, height: 175)
            .task {
                await loadFacts()                                                    //simplifies  programming and makes the code look cleaner
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
    func loadFacts() async {
        if let url = URL(string: "https://meowfacts.herokuapp.com/?count=1") {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                if let decodedResponse = try? JSONDecoder().decode(Facts.self, from: data) {
                    facts = decodedResponse.facts
                    return
                }
            }
        }
        showingAlert = true
    }
    func loadPhoto() async {
        if let url = URL(string: "https://api.thecatapi.com/v1/images/search?limit=1") {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
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
struct Facts: Identifiable, Codable {                                                   //the cases, enums and vars all represent the functions of the api. the api for photos as an exampke displays an image containing info on the width, height, id, and photo url. this all has to be passed through so the picture can be displayed.
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
