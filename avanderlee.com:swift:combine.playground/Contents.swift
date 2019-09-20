import Combine
import Foundation
import UIKit

extension Notification.Name {
    static let newBlogPost = Notification.Name("new_blog_post")
}

struct BlogPost {
    let title: String
    let url: URL
}

// Create Publisher.
let blogPostPublisher = NotificationCenter.Publisher(center: .default, name: .newBlogPost)
    .print()
    .map { notification -> String? in
        let blogPost = notification.object as? BlogPost
        return blogPost?.title
}

// Create Subscriber.
let lastPostLabel = UILabel()
let lastPostSubscriber = Subscribers.Assign(object: lastPostLabel, keyPath: \.text)

// Subscribe to publisher.
blogPostPublisher.subscribe(lastPostSubscriber)

// Test
let blogPost = BlogPost(title: "Getting started with the Combine framework in Swift",
                        url: URL(string: "https://www.avanderlee.com/swift/combine/")!)
NotificationCenter.default.post(name: .newBlogPost, object: blogPost)
print("Last post is: \(lastPostLabel.text!)")

let blogPost2 = BlogPost(title: "Hello World",
                         url: URL(string: "https://www.avanderlee.com/swift/combine/")!)
NotificationCenter.default.post(name: .newBlogPost, object: blogPost2)
print("Last post is: \(lastPostLabel.text!)")

// MARK: -

class FormViewModel {
    // Make property to be publisher.
    @Published var isSubmitAllowed = false
}

final class FormViewController: UIViewController {

    var formVM = FormViewModel()
    private var isSubmitAllowedSubscriber: AnyCancellable?

    let submitButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.isEnabled = false
        
        // Subscribe submitButton to publisher.
        isSubmitAllowedSubscriber = formVM.$isSubmitAllowed
            .print()
            .receive(on: DispatchQueue.main).assign(to: \.isEnabled, on: submitButton)
    }

    deinit {
        // Cancel subscription (Maybe no need to add this line because isSubmitAllowedSubscriber is attached with
        // viewcontroller life cycle). So it will call cancel() automatically when viewcontroller is released.
        isSubmitAllowedSubscriber?.cancel()
    }

}

// Test
let formVC = FormViewController()
formVC.loadView()
formVC.viewDidLoad()

print("submitButton status: \(formVC.submitButton.isEnabled)")
formVC.formVM.isSubmitAllowed.toggle()
print("submitButton status: \(formVC.submitButton.isEnabled)")
