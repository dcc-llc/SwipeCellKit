//
//  SwipeActionButton.swift
//
//  Created by Jeremy Koch.
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import UIKit

open class SwipeActionButton: UIButton {
    public var spacing: CGFloat = 8
    public var shouldHighlight = true
    public var highlightedBackgroundColor: UIColor?

    public var maximumImageHeight: CGFloat = 0
    public var verticalAlignment: SwipeVerticalAlignment = .centerFirstBaseline
    public var alignment: SwipeActionContentAlignment {
        return .vertical
    }

    public var currentSpacing: CGFloat {
        return (currentTitle?.isEmpty == false && imageHeight > 0) ? spacing : 0
    }

    var alignmentRect: CGRect {
        let contentRect = self.contentRect(forBounds: bounds)
        let titleHeight = titleBoundingRect(with: verticalAlignment == .centerFirstBaseline ? CGRect.infinite.size : contentRect.size).integral.height
        let totalHeight = imageHeight + titleHeight + currentSpacing

        return contentRect.center(size: CGSize(width: contentRect.width, height: totalHeight))
    }

    private var imageHeight: CGFloat {
        get {
            return currentImage == nil ? 0 : maximumImageHeight
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentEdgeInsets.top + alignmentRect.height + contentEdgeInsets.bottom)
    }

    public required init(action: SwipeAction) {
        super.init(frame: .zero)

        contentHorizontalAlignment = .center

        tintColor = action.textColor ?? .white
        let highlightedTextColor = action.highlightedTextColor ?? tintColor
        highlightedBackgroundColor = action.highlightedBackgroundColor ?? UIColor.black.withAlphaComponent(0.1)

        titleLabel?.font = action.font ?? UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 0

        accessibilityLabel = action.accessibilityLabel

        setTitle(action.title, for: .normal)
        setTitleColor(tintColor, for: .normal)
        setTitleColor(highlightedTextColor, for: .highlighted)
        setImage(action.image, for: .normal)
        setImage(action.highlightedImage ?? action.image, for: .highlighted)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var isHighlighted: Bool {
        didSet {
            guard shouldHighlight else { return }

            backgroundColor = isHighlighted ? highlightedBackgroundColor : .clear
        }
    }

    func preferredWidth(maximum: CGFloat) -> CGFloat {
        let width = maximum > 0 ? maximum : CGFloat.greatestFiniteMagnitude
        let textWidth = titleBoundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).width
        let imageWidth = currentImage?.size.width ?? 0

        let contentWidth: CGFloat
        switch alignment {
            case .horizontal:
                contentWidth = textWidth + imageWidth
            case .vertical:
                contentWidth = max(textWidth, imageWidth)
        }

        return min(width, contentWidth + contentEdgeInsets.left + contentEdgeInsets.right)
    }

    func titleBoundingRect(with size: CGSize) -> CGRect {
        guard let title = currentTitle, let font = titleLabel?.font else { return .zero }

        return title.boundingRect(with: size,
                                  options: [.usesLineFragmentOrigin],
                                  attributes: [NSAttributedString.Key.font: font],
                                  context: nil).integral
    }

    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        switch alignment {
            case .horizontal:
                return super.titleRect(forContentRect: contentRect)
            case .vertical:
                var rect = contentRect.center(size: titleBoundingRect(with: contentRect.size).size)
                rect.origin.y = alignmentRect.minY + imageHeight + currentSpacing
                return rect.integral
        }

    }

    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        switch alignment {
            case .horizontal:
                return super.imageRect(forContentRect: contentRect)
            case .vertical:
                var rect = contentRect.center(size: currentImage?.size ?? .zero)
                rect.origin.y = alignmentRect.minY + (imageHeight - rect.height) / 2
                return rect
        }
    }
}

extension CGRect {
    func center(size: CGSize) -> CGRect {
        let dx = width - size.width
        let dy = height - size.height
        return CGRect(x: origin.x + dx * 0.5, y: origin.y + dy * 0.5, width: size.width, height: size.height)
    }
}
