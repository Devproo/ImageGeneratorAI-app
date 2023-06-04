//
//  ContentView.swift
//  ImageGeneratorAI-app
//
//  Created by ipeerless on 04/06/2023.
//

import OpenAIKit
import SwiftUI
import UIKit

final class ViewModel: ObservableObject {
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(Configuration(organizationId: "personal", apiKey: "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"))
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                } else {
                    Text("Type prompt to generate image")
                }
                Spacer()
                
                TextField("Type prompt here", text: $text)
                    .padding()
                
                Button("Generate") {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        Task {
                            let result = await viewModel.generateImage(prompt: text)
                            if result == nil {
                                print("failed")
                            }
                            self.image = result
                        }
                    }
                }
            }
            .navigationTitle("DALL-E Image Generator")
            .padding()
        }
        .onAppear {
            viewModel.setup()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

