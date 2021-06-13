//
//  ViewController.swift
//  DownloadImageExampleApp
//
//  Created by Avi Levin on 13/06/2021.
//

import UIKit

enum NetworkImageDownloadError: Error {
    case urlNotCorrect
    case responseError
}

class ViewController: UIViewController {
    
    var secondFlower: UIImage? {
        get async {
            do {
                let flowerURL = "https://cdn.britannica.com/45/5645-050-B9EC0205/head-treasure-flower-disk-flowers-inflorescence-ray.jpg"
                let data = try await self.downloadImage(stringURL: flowerURL)
                return UIImage(data: data!)
            } catch {
                return nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let firstFlower = "https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510_960_720.jpg"
        downloadImageWithClosures(stringURL: firstFlower) { data, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async() { [weak self] in
                let image = UIImage(data: data)
                let uiImage = UIImageView(image: image)
                uiImage.frame = CGRect(x: 100, y: 150, width: 200, height: 200)
                self?.view.addSubview(uiImage)
            }
        }
        
        async {
            let secondFlowerImage = await secondFlower
            let uiImage = UIImageView(image: secondFlowerImage)
            uiImage.frame = CGRect(x: 100, y: 400, width: 200, height: 200)
            self.view.addSubview(uiImage)
        }
    }
    
    typealias CompletionHandler = ( _ data:Data?, _ error:Error?) -> Void
    
    func downloadImageWithClosures(stringURL: String, completionHandler:@escaping CompletionHandler) {
        guard let url = URL(string: stringURL) else {
            completionHandler(nil, NetworkImageDownloadError.urlNotCorrect)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
            else {
                completionHandler(nil,error)
                return
            }
            
            completionHandler(data,nil)
        }.resume()
    }
    
    func downloadImage(stringURL: String) async throws -> Data?{
        guard let url = URL(string: stringURL) else {
            throw NetworkImageDownloadError.urlNotCorrect
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkImageDownloadError.responseError
        }
        
        return data
    }

}

