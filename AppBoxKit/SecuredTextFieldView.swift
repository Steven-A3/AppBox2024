//
//  SecuredTextFieldView.swift
//  SecuredTextFiled
//
//  Created by Chinthaka Perera on 1/20/23.
//

import SwiftUI
/*
/// The identity of the TextField and the SecureField.
enum Field: Hashable {
    case showPasswordField
    case hidePasswordField
}

/// This view supports for have a secured filed with show / hide functionality.
///
/// We have managed show / hide functionality by using
/// A SecureField for hide the text, and
/// A TextField for show the text.
///
/// Please note that,
/// hide -> show -> hide senario with reset the text by the new input value.
/// It's common even in the other apps. eg: LinkedIn, MoneyGram
struct SecuredTextFieldView: View {
    @EnvironmentObject var passwordViewContext: PasswordViewContext

    /// Options for opacity of the fields.
    enum Opacity: Double {

        case hide = 0.0
        case show = 1.0

        /// Toggle the field opacity.
        mutating func toggle() {
            switch self {
            case .hide:
                self = .show
            case .show:
                self = .hide
            }
        }
    }

    var placeHolderText: String = ""
    var submitLabel: SubmitLabel = .return
    var onKeyboardSubmit: () -> Void = {}
    
    /// The property wrapper type that can read and write a value that
    /// SwiftUI updates as the placement of focus.
    @FocusState private var focusedField: Field?

    /// The show / hide state of the text.
    @State private var isSecured: Bool = true

    /// The opacity of the SecureField.
    @State private var hidePasswordFieldOpacity = Opacity.show

    /// The opacity of the TextField.
    @State private var showPasswordFieldOpacity = Opacity.hide

    /// The text value of the SecureFiled and TextField which can be
    /// binded with the @State property of the parent view of SecuredTextFieldView.
    @Binding var text: String
    let themeColor:Color = Color(A3UserDefaults.standard().themeColor())
    
    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                securedTextField

                Button(
                    action: {
                        performToggle()
                    },
                    label: {
                        Image(systemName: self.isSecured ? "eye.slash" : "eye")
                            .accentColor(themeColor)
                    }
                )
                .padding(.trailing, 10)
            }
        }
        .onAppear {
            passwordViewContext.hideKeyboard = hideKeyboard
        }
    }

    /// Secured field with the show / hide capability.
    var securedTextField: some View {
        Group {
            SecureField(placeHolderText, text: $text)
                .frame(height: 50)
                .padding(.leading, 20)
                .modifier(TextFieldClearButton(text: $text))
                .textContentType(.newPassword)
                .textInputAutocapitalization(.never)
                .keyboardType(.asciiCapable) // This avoids suggestions bar on the keyboard.
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .hidePasswordField)
                .opacity(hidePasswordFieldOpacity.rawValue)
                .submitLabel(submitLabel)
                .onSubmit {
                    self.onKeyboardSubmit()
                }

            TextField(placeHolderText, text: $text)
                .frame(height: 50)
                .padding(.leading, 20)
                .modifier(TextFieldClearButton(text: $text))
                .textInputAutocapitalization(.never)
                .textContentType(.newPassword)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled(true)
                .focused($focusedField, equals: .showPasswordField)
                .opacity(showPasswordFieldOpacity.rawValue)
                .submitLabel(submitLabel)
                .onSubmit {
                    self.onKeyboardSubmit()
                }
        }
        .padding(.trailing, 32)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.focusedField = .hidePasswordField
            }
        }
    }
    
    /// This supports the parent view to perform hide the keyboard.
    func hideKeyboard() {
        self.focusedField = nil
    }
    
    /// Perform the show / hide toggle by changing the properties.
    private func performToggle() {
        isSecured.toggle()

        if isSecured {
            focusedField = .hidePasswordField
        } else {
            focusedField = .showPasswordField
        }

        hidePasswordFieldOpacity.toggle()
        showPasswordFieldOpacity.toggle()
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button(
                    action: { self.text = "" },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                            .padding(.trailing, 15)
                    }
                )
            }
        }
    }
}
*/
