//
//  InputView.swift
//  GeSwift
//
//  Created by my on 2021/1/26.
//  Copyright © 2021 my. All rights reserved.
//
#if canImport(UIKit)
import UIKit

public enum BorderStyle {
    case underline
    case box
    case none
}

public protocol InputFieldStyleProtocol {
    var cellSize: CGSize { get }
    var spacing: CGFloat { get }
    var inset: UIEdgeInsets { get }
    var borderColor: UIColor { get }
    var borderWidth: CGFloat { get }
    var borderRadius: CGFloat { get }
    var cursorColor: UIColor { get }
    var borderStyle: BorderStyle { get }
    var cellBackgroundColor: UIColor? { get }
}

public extension InputFieldStyleProtocol {
    var cellSize: CGSize {
        CGSize(width: 40, height: 40)
    }
    
    var spacing: CGFloat {
        10
    }
    
    var inset: UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    var borderColor: UIColor {
        .black
    }
    
    var borderWidth: CGFloat {
        1
    }
    
    var borderRadius: CGFloat {
        0
    }
    
    var cursorColor: UIColor {
        .red
    }
    
    var borderStyle: BorderStyle {
        .box
    }
    
    var cellBackgroundColor: UIColor? {
        .clear
    }
}

public class DefaultInputFieldStyle: InputFieldStyleProtocol {}

public protocol InputFieldDelegate: NSObjectProtocol {
    func inputField(_ inputField: InputField, textDidChange text: String?)
    
    func inputField(_ inputField: InputField, editingDidEndOnExit text: String?)
}

extension InputFieldDelegate {
    func inputField(_ inputField: InputField, editingDidEndOnExit text: String?) {}
    
    func inputField(_ inputField: InputField, textDidChange text: String?) {}
}

public final class InputField: UIView {
    private lazy var _textField: UITextField = {
        $0.text = self.text
        $0.textColor = UIColor.clear
        $0.tintColor = UIColor.clear
        $0.returnKeyType = self.returnKeyType
        $0.keyboardType = self.keyboardType
        $0.delegate = self
        $0.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        $0.addTarget(self, action: #selector(textDidEndEditingOnExit(_:)), for: .editingDidEndOnExit)
        self.addSubview($0)
        return $0
    }(UITextField())
    
    private lazy var _collectionView: UICollectionView = {
        $0.backgroundColor = UIColor.clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(InputViewCell.self, forCellWithReuseIdentifier: "InputViewCell")
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        self.addSubview($0)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: {
        $0.scrollDirection = .horizontal
        return $0
    }(UICollectionViewFlowLayout())))
    
    private lazy var _cursor: Cursor = {
        $0.backgroundColor = style.cursorColor
        $0.layer.opacity = 0
        $0.isHidden = true
        $0.bounds = CGRect(x: 0, y: 0, width: 3, height: style.cellSize.height - 18)
        self.addSubview($0)
        return $0
    }(Cursor())
    
    /// 默认size 17
    public var font = UIFont.systemFont(ofSize: 17)
    
    /// 默认为black
    public var textColor = UIColor.black

    /// text
    public var text: String? {
        didSet {
            _textField.text = text
        }
    }
    
    /// 默认为false
    public var isSecureTextEntry: Bool = false
    
    public weak var delegate: InputFieldDelegate?
    
    /// 默认为4
    public var limitCount: Int = 4
    
    /// 当text到达指定限制字数时，自动调用delegate的editingDidEndOnExit方法
    public var invokeDelegateWhenTextArrivedLimitCount: Bool = true
    
    /// 默认 default
    public var keyboardType: UIKeyboardType = .default {
        didSet {
            _textField.keyboardType = keyboardType
        }
    }
    
    /// 默认 default
    public var returnKeyType: UIReturnKeyType = .default {
        didSet {
            _textField.returnKeyType = returnKeyType
        }
    }
    
    /// 是否显示光标, 默认true
    public var isShowCursor: Bool = true
    
    public var style: InputFieldStyleProtocol = DefaultInputFieldStyle() {
        didSet {
            reloadData()
        }
    }
    
    override public var canBecomeFirstResponder: Bool {
        return _textField.canBecomeFirstResponder
    }
    
    override public func becomeFirstResponder() -> Bool {
        if limitCount > 0, let _text = _textField.text, _text.count < limitCount {
            showCursorWithAnimation()
            updateCursorLocationAtIndex(_text.count)
        }
        return _textField.becomeFirstResponder()
    }
    
    override public func resignFirstResponder() -> Bool {
        hideCursor()
        return _textField.resignFirstResponder()
    }
    
    override public func layoutSubviews() {
        _textField.frame = bounds
        _collectionView.frame = bounds
    }
    
    public func reloadData() {
        _collectionView.reloadData()
        _collectionView.layoutIfNeeded()
        sendSubviewToBack(_textField)
        bringSubviewToFront(_cursor)
        DispatchQueue.main.async {
            if self.limitCount > 0 {
                self._collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .bottom)
            }
        }
    }
}

extension InputField {
    private func updateCursorLocationAtIndex(_ index: Int) {
        guard let _cell = _collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? InputViewCell else { return }
        
        let _currentCellCenter = _collectionView.convert(_cell.center, to: self)
        _cursor.center = CGPoint(x: _currentCellCenter.x, y: _cell.center.y)
        
        _cell.borderColor = style.cursorColor
//        _cell.reloadBorder()
    }
    
    private func showCursorWithAnimation() {
        guard _cursor.isHidden else { return }
        _cursor.isHidden = false
        _cursor.layer.opacity = 1
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = NSNumber(value: 1)
        animation.toValue = NSNumber(value: 0)
        animation.repeatCount = MAXFLOAT
        animation.duration = 1
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        _cursor.layer.add(animation, forKey: nil)
    }
    
    private func hideCursor() {
        _cursor.layer.removeAllAnimations()
        _cursor.isHidden = true
        _cursor.layer.opacity = 0
    }
}

extension InputField: UITextFieldDelegate {
    @objc func textDidChange(_ textField: UITextField) {
        guard let _text = textField.text else { return }
        var _limitText = _text
        
        if _limitText.count > limitCount {
            _limitText = String(_limitText.prefix(limitCount))
            text = _limitText
            return
        }
        
        let _originTextCount = text?.count ?? 0
        text = _limitText
        if _limitText.count > _originTextCount, _limitText.count < limitCount {
            _collectionView.reloadItems(at: [IndexPath(item: _limitText.count, section: 0), IndexPath(item: _limitText.count - 1, section: 0)])
        } else if _limitText.count > _originTextCount && _limitText.count == limitCount {
            _collectionView.reloadItems(at: [IndexPath(item: _limitText.count - 1, section: 0)])
        } else if _limitText.count <= _originTextCount && _limitText.count == limitCount - 1 {
            _collectionView.reloadItems(at: [IndexPath(item: _limitText.count, section: 0)])
        } else {
            _collectionView.reloadItems(at: [IndexPath(item: _limitText.count + 1, section: 0), IndexPath(item: _limitText.count, section: 0)])
        }
        _collectionView.layoutIfNeeded()

        if _limitText.count < limitCount || !invokeDelegateWhenTextArrivedLimitCount {
            delegate?.inputField(self, textDidChange: _limitText)
            if _limitText.count == limitCount {
                hideCursor()
            } else {
                DispatchQueue.main.async {
                    self.showCursorWithAnimation()
                    self.updateCursorLocationAtIndex(_limitText.count)
                    self._collectionView.scrollToItem(at: IndexPath(item: _limitText.count, section: 0), at: .right, animated: true)
                }
            }
        } else {
            hideCursor()
            delegate?.inputField(self, textDidChange: _limitText)
            delegate?.inputField(self, editingDidEndOnExit: _limitText)
        }
    }
    
    @objc func textDidEndEditingOnExit(_ textField: UITextField) {
        delegate?.inputField(self, editingDidEndOnExit: textField.text)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        hideCursor()
        _collectionView.reloadData()
    }
}

extension InputField: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return limitCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return style.cellSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return style.spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return style.spacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return style.inset
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputViewCell", for: indexPath) as! InputViewCell
        cell.label.textColor = textColor
        cell.label.font = font
        cell.label.text = charactorForTextAtIndex(indexPath.item)
        cell.borderColor = style.borderColor
        cell.borderWidth = style.borderWidth
        cell.borderStyle = style.borderStyle
        cell.borderRadius = style.borderRadius
//        cell.box.backgroundColor = style.cellBackgroundColor
        cell.boxBackgroundColor = style.cellBackgroundColor
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !_textField.isFirstResponder {
            _ = becomeFirstResponder()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? InputViewCell else { return }
        cell.borderColor = style.borderColor
    }
    
    private func charactorForTextAtIndex(_ index: Int) -> String? {
        guard let _text = text, index < _text.count else { return nil }
        
        if isSecureTextEntry { return "•" }
        
        let startIndex = _text.startIndex
        let endIndex = _text.index(startIndex, offsetBy: index)
        return String(_text[endIndex])
    }
}
#endif
