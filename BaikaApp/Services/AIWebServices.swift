import Foundation
import FirebaseAILogic

// İleride test yazabilmek (Mocking) için Protocol kullanmak en iyi pratiktir
protocol StoryServiceProtocol {
    func generateStory(parameters: StoryParameters) async throws -> String
}


    class StoryService: StoryServiceProtocol {
        
        func generateStory(parameters: StoryParameters) async throws -> String {
            let ai = FirebaseAI.firebaseAI(backend: .vertexAI())
            let model = ai.templateGenerativeModel()
            let templateID = "createstory" // Kendi şablon adın
            // API çağrısı
            let response = try await model.generateContent(
                templateID: templateID,
                inputs: parameters.toDictionary
            )
            
            guard let text = response.text else {
                // Özel bir hata fırlatabiliriz
                throw NSError(domain: "StoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Yapay zeka boş yanıt döndürdü."])
            }
            
            return text
        }
    }
