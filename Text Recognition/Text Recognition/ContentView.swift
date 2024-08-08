//
//  ContentView.swift
//  Text Recognition
//
//  Created by Ansh D on 6/28/24.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    @State private var image_taken: UIImage?  // stores image
    @State private var recognized_texts = [String]()
    @State private var is_loading = false
    
    func recognize_card_text() {
        let request_handler = VNImageRequestHandler(cgImage: self.image_taken!.cgImage!)
        
        let recognize_text_request = VNRecognizeTextRequest {(request, error) in
            
            // Parse results
            guard let observations = request.results as? [VNRecognizedTextObservation] else {return}
            
            // Extract data
            for observation in observations {
                let recognized_text = observation.topCandidates(1).first!.string
                self.recognized_texts.append(recognized_text)
            }
        }
        recognize_text_request.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try request_handler.perform([recognize_text_request])
                self.is_loading = false
            }
            
            catch {
                print(error)
            }
        }
    }
    
    var picture_taken_view: some View {
        VStack {
            Image(uiImage: self.image_taken!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            Button(action: {
                self.image_taken = nil
                self.recognized_texts = [String]()
            },label: {
                HStack {
                    Image(systemName: "camera")
                    Text("Re-take Picture")
                }
            })
            
            List {
                ForEach(self.recognized_texts, id: \.self) {
                    Text("\($0)")
                }
            }
            
        }
    }
    
    var body: some View {
        VStack {
            if (self.image_taken == nil) {
                CameraView(image: self.$image_taken)
            }
            else {
                if (!self.is_loading) {
                    self.picture_taken_view.onAppear {
                        self.recognize_card_text()
                    }
                }
                else {
                    ProgressView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
