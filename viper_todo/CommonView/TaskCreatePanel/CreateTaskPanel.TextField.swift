
import UIKit

extension TaskCreatePanel {
    class TextField: BaseTextFeild {

        private let leftImageView: UIImageView = {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 0, weight: .medium, scale: .large)
            
            $0.image = UIImage.init(systemName: "plus", withConfiguration: symbolConfig)?
                .withRenderingMode(.alwaysTemplate)

            $0.frame = .init(origin: .zero, size: .init(width: 40, height: 40))
            $0.contentMode = .scaleAspectFill
            return $0
        }(UIImageView())

        // MARK: - Init

        convenience init() {
            self.init(frame: .zero)
            setupControl()
        }

        // MARK: - Update view

        func updateAppearanceFor(state: TaskCreatePanel.State) {
            switch state {
            case .base:
                leftImageView.tintColor = .white
                placeholderAttributes = [
                    .foregroundColor: UIColor.white
                ]
            case .editable:
                leftImageView.tintColor = .isDoneButtonBorder
                placeholderAttributes = [
                    .foregroundColor: UIColor.textGray
                ]
            }
        }
    }
}

private extension TaskCreatePanel.TextField {

    // MARK: - Setup

    func setupControl() {
        font = .systemFont(ofSize: 17)
        textColor = .textBlack

        let imageInsets: UIEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 16)
        setImageViewToLeftView(imageView: leftImageView, insets: imageInsets)
        leftViewMode = .always
    }

}
