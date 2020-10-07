//
//  ViewController.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 07/10/2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var urlEntry: UITextField!
    let token = "c798d97ad43267d09a2eab588a954fc52c0f84a4"
    let apiURL = URL(string: "https://api-ssl.bitly.com/v4/shorten")!
    var shortLink: String?
    @IBOutlet var shortLinkView: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "URL shortener"
        submitButton.layer.cornerRadius = 10
        
        
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        guard let longURL = urlEntry.text else { return }
        let json: [String: Any] = ["long_url": longURL, "domain": "bit.ly"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                self?.showError(title: "Error", message: error?.localizedDescription)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let link = responseJSON["link"] as? String {
                    self?.shortLink = link
                    DispatchQueue.main.async {
                        self?.shortLinkView.text = self?.shortLink
                        self?.reloadInputViews()
                    }
                } else {
                    if let error = responseJSON["message"] as? String, let description = responseJSON["description"] as? String  {
                        DispatchQueue.main.async {
                            self?.showError(title: error, message: description)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func showError(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

