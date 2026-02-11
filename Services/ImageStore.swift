import Foundation
import UIKit

class ImageStore {
    static func saveImage(imageData: Data, with identifier: String) -> URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("\(identifier).jpg")
        do {
            try imageData.write(to: url)
            return url
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    static func loadImage(with identifier: String) -> UIImage? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("\(identifier).jpg")
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
}
