import UIKit

extension UITableView {

//    var emtyBackgroundbackgroundColor: UIColor? {
//        get { return backgroundView?.backgroundColor }
//        set { backgroundView?.backgroundColor = newValue }
//    }
    func setEmptyMessage(_ message: String) {
//        backgroundColor = .red

        let emtpyView = UIView(frame: frame)
        emtpyView.backgroundColor = backgroundColor
        backgroundView = emtpyView


        let messageLabel = UILabel()
//        messageLabel.frame = CGRect(x: 0,
//                                    y: 0,
//                                    width: self.bounds.size.width,
//                                    height: self.bounds.size.height)
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;

        messageLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)

        emtpyView.addSubview(messageLabel)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.centerYAnchor.constraint(equalTo: emtpyView.centerYAnchor).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: emtpyView.centerXAnchor).isActive = true
        separatorStyle = .none
    }
    
    func restore() {
        let emtpyView = UIView(frame: frame)
        emtpyView.backgroundColor = backgroundColor
        backgroundView = emtpyView
        separatorStyle = .singleLine
    }

}
