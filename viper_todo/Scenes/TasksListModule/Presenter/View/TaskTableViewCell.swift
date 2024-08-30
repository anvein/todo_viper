
import UIKit
import SnapKit

final class TaskTableViewCell: UITableViewCell {

    // MARK: - Services

    weak var delegate: TaskTableViewCellDelegate?

    // MARK: - Settings

    private static let isDoneButtonSize: CGFloat = 24

    // MARK: - Subviews

    private lazy var isDoneButton: SwitchableButton = {
        let checkmarkConfig = UIImage.SymbolConfiguration(pointSize: 0, weight: .heavy, scale: .medium)
        let checkmarkImage = UIImage(systemName: "checkmark", withConfiguration: checkmarkConfig)?
            .withTintColor(.white)

        var configForIsOn = UIButton.Configuration.filled()
        configForIsOn.background.backgroundColor = .isDoneButtonCompletedBg
        configForIsOn.background.cornerRadius = TaskTableViewCell.isDoneButtonSize / 2
        configForIsOn.image = checkmarkImage
        configForIsOn.cornerStyle = .fixed
        $0.configurationForIsOn = configForIsOn

        var configForIsOff = UIButton.Configuration.filled()
        configForIsOff.background.backgroundColor = .clear
        configForIsOff.background.strokeWidth = 2
        configForIsOff.background.strokeColor = .isDoneButtonBorder
        configForIsOff.background.cornerRadius = TaskTableViewCell.isDoneButtonSize / 2
        configForIsOff.cornerStyle = .fixed
        $0.configurationForIsOff = configForIsOff

        $0.tintAdjustmentMode = .normal
        $0.delegate = self

        return $0
    }(SwitchableButton())

    private let titleLabel: UILabel = {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .textBlack
        $0.numberOfLines = 0
        $0.textAlignment = .left
        return $0
    }(UILabel())

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: .init(top: 0, left: 0, bottom: 2, right: 0))
        selectedBackgroundView?.frame = contentView.frame
        backgroundView?.frame = contentView.frame
    }

    // MARK: - Update view

    func fillFrom(cellDto: TaskCellDto) {
        isDoneButton.isOn = cellDto.isCompleted
        titleLabel.text = cellDto.title
    }

}

private extension TaskTableViewCell {
    // MARK: - Setup

    func setup() {
        selectionStyle = .none
        backgroundColor = nil
        backgroundView = buildBackgroundView()
    }

    func setupSubviews() {
        contentView.addSubviews(isDoneButton, titleLabel)

        isDoneButton.snp.makeConstraints {
            $0.size.equalTo(Self.isDoneButtonSize)
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(isDoneButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)

        }
    }

    func buildBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }

}

// MARK: - HighlightableCell

extension TaskTableViewCell: HighlightableCell {
    func setCellHighlighted(_ highlighted: Bool) {
        backgroundView?.backgroundColor = highlighted ? .taskCellHighlighted : .white
    }
}

// MARK: - SwitchableButtonDelegate

extension TaskTableViewCell: SwitchableButtonDelegate {
    func switchableButtonDidTap(button: SwitchableButton) {
        guard let tableView = self.superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else { return }

        delegate?.taskTableViewCellDidTapIsDoneButton(indexPath: indexPath)
    }
}
