import SwiftUI

struct RichTextView: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView
        var textView: UITextView?

        init(_ parent: RichTextView) {
            self.parent = parent
            super.init()

            NotificationCenter.default.addObserver(self, selector: #selector(applyBold), name: .applyBold, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applyItalic), name: .applyItalic, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applyUnderline), name: .applyUnderline, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applyHighlight), name: .applyHighlight, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applyTextColor), name: .applyTextColor, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applyLarger), name: .applyLarger, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applySmaller), name: .applySmaller, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applyTitle), name: .applyTitle, object: nil)
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }

        @objc func applyBold() {
            toggleTrait(.traitBold)
        }

        @objc func applyItalic() {
            toggleTrait(.traitItalic)
        }

        @objc func applyUnderline() {
            toggleUnderline()
        }

        @objc func applyHighlight() {
            toggleAttribute(.backgroundColor, toggleValue: UIColor.yellow)
        }

        @objc func applyTextColor() {
            toggleAttribute(.foregroundColor, toggleValue: UIColor.red)
        }

        @objc func applyLarger() {
            applyFontSize(delta: 4)
        }

        @objc func applySmaller() {
            applyFontSize(delta: -4)
        }

        @objc func applyTitle() {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, _ in
                let newFont = UIFont.boldSystemFont(ofSize: 24)
                mutable.addAttribute(.font, value: newFont, range: range)
            }
            textView.attributedText = mutable
            textView.selectedRange = selectedRange
            parent.attributedText = mutable
        }

        private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)

            mutable.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, _ in
                if let font = value as? UIFont {
                    var traits = font.fontDescriptor.symbolicTraits
                    if traits.contains(trait) {
                        traits.remove(trait)
                    } else {
                        traits.insert(trait)
                    }
                    if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                        let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                        mutable.addAttribute(.font, value: newFont, range: range)
                    }
                }
            }

            textView.attributedText = mutable
            textView.selectedRange = selectedRange
            parent.attributedText = mutable
        }

        private func toggleUnderline() {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)

            mutable.enumerateAttribute(.underlineStyle, in: selectedRange, options: []) { value, range, _ in
                let current = value as? Int ?? 0
                if current == NSUnderlineStyle.single.rawValue {
                    mutable.removeAttribute(.underlineStyle, range: range)
                } else {
                    mutable.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                }
            }

            textView.attributedText = mutable
            textView.selectedRange = selectedRange
            parent.attributedText = mutable
        }

        private func toggleAttribute(_ attr: NSAttributedString.Key, toggleValue: Any) {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)

            mutable.enumerateAttribute(attr, in: selectedRange, options: []) { value, range, _ in
                if let val = value, "\(val)" == "\(toggleValue)" {
                    mutable.removeAttribute(attr, range: range)
                } else {
                    mutable.addAttribute(attr, value: toggleValue, range: range)
                }
            }

            textView.attributedText = mutable
            textView.selectedRange = selectedRange
            parent.attributedText = mutable
        }

        private func applyFontSize(delta: CGFloat) {
            guard let textView = textView else { return }
            let selectedRange = textView.selectedRange
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, _ in
                if let font = value as? UIFont {
                    let newFont = font.withSize(max(8, font.pointSize + delta))
                    mutable.addAttribute(.font, value: newFont, range: range)
                }
            }
            textView.attributedText = mutable
            textView.selectedRange = selectedRange
            parent.attributedText = mutable
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.clear
        context.coordinator.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.attributedText != attributedText {
            uiView.attributedText = attributedText
        }
    }
}

extension Notification.Name {
    static let applyBold = Notification.Name("applyBold")
    static let applyItalic = Notification.Name("applyItalic")
    static let applyUnderline = Notification.Name("applyUnderline")
    static let applyHighlight = Notification.Name("applyHighlight")
    static let applyTextColor = Notification.Name("applyTextColor")
    static let applyLarger = Notification.Name("applyLarger")
    static let applySmaller = Notification.Name("applySmaller")
    static let applyTitle = Notification.Name("applyTitle")
}

