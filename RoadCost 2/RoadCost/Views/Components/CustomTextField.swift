import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor
    var textColor: UIColor
    var fontSize: CGFloat
    var fontWeight: UIFont.Weight
    var keyboardType: UIKeyboardType
    var textAlignment: NSTextAlignment
    
    init(
        text: Binding<String>,
        placeholder: String,
        placeholderColor: UIColor = .systemGray,
        textColor: UIColor = .white,
        fontSize: CGFloat = 17,
        fontWeight: UIFont.Weight = .regular,
        keyboardType: UIKeyboardType = .default,
        textAlignment: NSTextAlignment = .left
    ) {
        self._text = text
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.textColor = textColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.keyboardType = keyboardType
        self.textAlignment = textAlignment
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.textAlignment = textAlignment
        textField.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        textField.textColor = textColor
        
        // Set placeholder color
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // If keyboard is numeric, validate input
            if textField.keyboardType == .decimalPad || textField.keyboardType == .numberPad {
                // Allow backspace
                if string.isEmpty {
                    let currentText = textField.text ?? ""
                    guard let stringRange = Range(range, in: currentText) else { return false }
                    let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                    DispatchQueue.main.async {
                        self.parent.text = updatedText
                    }
                    return true
                }
                
                // Allow digits, single decimal point/comma
                let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
                let characterSet = CharacterSet(charactersIn: string)
                
                if !allowedCharacters.isSuperset(of: characterSet) {
                    return false
                }
                
                // Check for multiple decimal separators
                let currentText = textField.text ?? ""
                if (string == "." || string == ",") && (currentText.contains(".") || currentText.contains(",")) {
                    return false
                }
            }
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            DispatchQueue.main.async {
                self.parent.text = updatedText
            }
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
            }
        }
    }
}
