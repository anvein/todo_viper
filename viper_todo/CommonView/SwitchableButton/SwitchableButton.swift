
import UIKit

class SwitchableButton: UIButton {

    // MARK: - Services

    weak var delegate: SwitchableButtonDelegate?

    // MARK: - Settings

    var configurationForIsOn: UIButton.Configuration? {
        didSet { updateAppearanceForValue(isOn) }
    }

    var configurationForIsOff: UIButton.Configuration? {
        didSet { updateAppearanceForValue(isOn) }
    }

    // MARK: - State

    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else { return }
            updateAppearanceForValue(isOn)
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension SwitchableButton {

    // MARK: - Setup

    private func setupButton() {
        addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        updateAppearanceForValue(isOn)
    }

    private func updateAppearanceForValue(_ isOn: Bool) {
        configuration = isOn ? configurationForIsOn : configurationForIsOff
    }

    // MARK: - Actions handlers

    @objc private func buttonTouchUpInside() {
        delegate?.switchableButtonDidTap(button: self)
    }
}
