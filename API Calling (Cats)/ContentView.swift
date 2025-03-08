//
//  ContentView.swift
//  API Calling (Cats)
//
//  Created by Carson Payne on 3/8/25.
//
import SwiftUI
struct ContentView: View {
    @State private var facts = [String]()
    @State private var showingAlert = false
    var body: some View {
        NavigationView {
            List(facts, id: \.self) { fact in
                Text (fact)
            }
            .navigationTitle ("Random Cat Facts")
            .toolbar {
                Button {
                    Task {
                        await loadData ()
                    }
                } label: {
                    Image (systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await loadData()
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Loading Error"), message: Text("There was a problem loading Random Cat Facts"))
        })
    }
    func loadData() async {
        if let url = URL(string: "https://meowfacts.herokuapp.com/?count=20") {
            if let (data, _) = try? await URLSession.shared.data (from: url) {
                if let decodedResponse = try? JSONDecoder().decode (Facts.self, from:data) {
                    facts = decodedResponse.facts
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
