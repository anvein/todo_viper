
import UIKit
import SnapKit

final class TaskDetailDescriptionTextView: UITextView {

    weak var externalDelegate: UITextViewDelegate?

    // MARK: - Subviews

    private lazy var placeholderLabel: UILabel = { label in
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .textGray
        return label
    }(UILabel())

    // MARK: - State

    var placeholder: String {
        get { placeholderLabel.text ?? "" }
        set { placeholderLabel.text = newValue }
    }

    override var text: String! {
        didSet { updateViewPlaceholder(for: text) }
    }

    override var attributedText: NSAttributedString! {
        didSet { updateViewPlaceholder(for: attributedText.string) }
    }

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)
        setup()
        setupSuviews()
    }
}

private extension TaskDetailDescriptionTextView {

    // MARK: - Setup

    func setup() {
        let font: UIFont = .systemFont(ofSize: 18, weight: .regular)
        self.font = font

        self.typingAttributes = [
            .font: font,
        ]
        self.showsVerticalScrollIndicator = true
        self.textAlignment = .left

        self.tintColor = .textBlack
        self.textColor = .textBlack
        self.backgroundColor = .white


        self.delegate = self
    }

    func setupSuviews() {
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(5)
            $0.bottom.greaterThanOrEqualToSuperview().inset(10)
        }
    }

    // MARK: - Update view

    func updateViewPlaceholder(for text: String) {
        placeholderLabel.isHidden = !text.isEmpty
    }
}

// MARK: - UITextViewDelegate

extension TaskDetailDescriptionTextView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        externalDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        externalDelegate?.textViewShouldEndEditing?(textView) ?? true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        externalDelegate?.textViewDidBeginEditing?(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        externalDelegate?.textViewDidEndEditing?(textView)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let externalDelegateResult = externalDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true

        guard let currentText = textView.text,
              let textRange = Range(range, in: currentText)
        else { return externalDelegateResult }

        let updatedText = currentText.replacingCharacters(in: textRange, with: text)

        updateViewPlaceholder(for: updatedText)

        return externalDelegateResult
    }
}
