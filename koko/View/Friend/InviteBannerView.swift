import UIKit

final class InviteBannerView: UIView {

    var onHeightChange: ((CGFloat) -> Void)?
    var onToggle: ((Bool) -> Void)? // 點擊卡片事件

    var collapsedHeight: CGFloat = 120
    var maxExpandedHeight: CGFloat = 240
    var horizontalInset: CGFloat = 16
    var cardHeight: CGFloat = 84 // 卡片高度

    private var isExpanded = false // 是反展開
    private var invites: [Friend] = []

    private let peek = UIView() // 假底卡

    // MARK: Real content
    private let contentShadowHost = UIView()  // 陰影
    private let scrollView = UIScrollView() // 包住stack
    private let stack = UIStackView()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame); 
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder); 
        setup()
    }

    // MARK: Setup
    private func setup() {
        backgroundColor = .white
        clipsToBounds = false
        layer.masksToBounds = false

        // 假底卡
        peek.backgroundColor = .white
        peek.layer.cornerRadius = 16
        peek.layer.shadowColor = UIColor.black.cgColor
        peek.layer.shadowOpacity = 0.08
        peek.layer.shadowRadius = 16
        peek.layer.shadowOffset = CGSize(width: 0, height: 8)
        peek.layer.shouldRasterize = true
        peek.layer.rasterizationScale = UIScreen.main.scale
        peek.isUserInteractionEnabled = false
        addSubview(peek)

        // 主卡陰影
        addSubview(contentShadowHost)
        contentShadowHost.layer.shouldRasterize = true
        contentShadowHost.layer.rasterizationScale = UIScreen.main.scale
        contentShadowHost.translatesAutoresizingMaskIntoConstraints = false
        contentShadowHost.layer.cornerRadius = 16
        contentShadowHost.layer.shadowColor = UIColor.black.cgColor
        contentShadowHost.layer.shadowOpacity = 0.08
        contentShadowHost.layer.shadowRadius = 16
        contentShadowHost.layer.shadowOffset = CGSize(width: 0, height: 8)

        // 先存起來，調低 vertical 的優先度，再 activate
        let hostLeading = contentShadowHost.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalInset)
        let hostTrailing = contentShadowHost.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalInset)
        let hostTop = contentShadowHost.topAnchor.constraint(equalTo: topAnchor, constant: 6)
        let hostBottom = contentShadowHost.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)

        // 降低優先度
        hostTop.priority = .defaultHigh          // 750
        hostBottom.priority = .defaultHigh       // 750
        
        NSLayoutConstraint.activate([hostLeading, hostTrailing, hostTop, hostBottom])
        
        // scrollView + stack
        contentShadowHost.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentShadowHost.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentShadowHost.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentShadowHost.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentShadowHost.bottomAnchor)
        ])

        scrollView.addSubview(stack)
        
        // 直向stack
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // content size
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // 避免水平滾動
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // 設置點擊手勢
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        addGestureRecognizer(tap)
    }

    func configure(invites: [Friend], expanded: Bool) {
        self.invites = invites
        self.isExpanded = expanded
        isHidden = invites.isEmpty
        rebuildCards()
        applyPeekVisibility(animated: false)
        requestHeightUpdate(animated: false)
        setNeedsLayout()
    }

    // MARK: Build cards
    private func rebuildCards() {
        for v in stack.arrangedSubviews {
            stack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        guard !invites.isEmpty else { return }

        let show = isExpanded ? invites : Array(invites.prefix(1))
        for f in show {
            let card = CardView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: cardHeight).isActive = true
            card.setContentHuggingPriority(.required, for: .vertical)
            card.setContentCompressionResistancePriority(.required, for: .vertical)
            card.configure(with: f)
            stack.addArrangedSubview(card)
        }
    }

    // MARK: Height
    private func desiredHeight() -> CGFloat {
        guard !invites.isEmpty else { return 0 }
        
        let width = scrollView.bounds.width > 0 ? scrollView.bounds.width : bounds.width - horizontalInset * 2
        let targetSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let contentH = stack.systemLayoutSizeFitting(targetSize,
                                                             withHorizontalFittingPriority: .required,
                                                             verticalFittingPriority: .fittingSizeLevel).height

        if isExpanded {
            // 展開：高度上限為maxExpandedHeight，超過就讓 scrollView 捲
            let h = min(max(contentH, collapsedHeight), maxExpandedHeight)
            scrollView.isScrollEnabled = (contentH > maxExpandedHeight)
            return h
        } else {
            // 收合：固定 collapsedHeight，不允許捲動
            scrollView.isScrollEnabled = false
            return collapsedHeight
        }
    }

    // 高度更新
    private func requestHeightUpdate(animated: Bool) {
        onHeightChange?(desiredHeight())
    }

    // 假底卡(僅在收合以及invites.count>1時可視)
    private func applyPeekVisibility(animated: Bool) {
        let shouldShowPeek = !isExpanded && invites.count > 1
        let block = { self.peek.alpha = shouldShowPeek ? 1 : 0 }
        animated ? UIView.animate(withDuration: 0.2, animations: block) : block()
    }

    // MARK: 點擊事件
    @objc private func toggle() {
        guard !invites.isEmpty else { return }
        isExpanded.toggle()
        rebuildCards()
        applyPeekVisibility(animated: true)
        requestHeightUpdate(animated: true)
        onToggle?(isExpanded)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 陰影 path（效能）
        contentShadowHost.layer.shadowPath = UIBezierPath(
            roundedRect: contentShadowHost.bounds,
            cornerRadius: 16
        ).cgPath
        peek.layer.shadowPath = UIBezierPath(
                    roundedRect: peek.bounds,
                    cornerRadius: 16
                ).cgPath

        // 用主卡當基準；讓 peek 往下錯位露出一點
        var f = contentShadowHost.frame.insetBy(dx: 10, dy: 10)
        f.origin.y += 10 // 往下位移露出
        peek.frame = f
        peek.layer.cornerRadius = 16
    }
}
