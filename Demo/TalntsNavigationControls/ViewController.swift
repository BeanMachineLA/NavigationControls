import UIKit

class ViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTap"))
    }

    func onTap()
    {
        self.navigationController?.pushViewController(PagesViewController(), animated: true)
    }
}
