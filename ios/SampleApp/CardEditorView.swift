import SwiftUI

struct CardEditorView: View {
    @State private var jsonText: String = defaultCardJSON
    @State private var isValid: Bool = true
    @State private var errorMessage: String = ""
    @State private var splitView: Bool = true
    @EnvironmentObject var actionLog: ActionLogStore
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if splitView {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            // Editor pane
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("JSON Editor")
                                        .font(.headline)
                                    Spacer()
                                    if !isValid {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                TextEditor(text: $jsonText)
                                    .font(.system(.body, design: .monospaced))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: jsonText) { _, _ in
                                        validateJSON()
                                    }
                            }
                            .frame(width: geometry.size.width / 2)
                            .background(Color.gray.opacity(0.05))
                            
                            Divider()
                            
                            // Preview pane
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Live Preview")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                ScrollView {
                                    if isValid {
                                        CardPreviewPlaceholder(json: jsonText)
                                            .padding()
                                    } else {
                                        VStack(spacing: 12) {
                                            Image(systemName: "xmark.circle")
                                                .font(.largeTitle)
                                                .foregroundColor(.red)
                                            Text("Invalid JSON")
                                                .font(.headline)
                                            Text(errorMessage)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .frame(width: geometry.size.width / 2)
                        }
                    }
                } else {
                    // Single view mode
                    TabView {
                        VStack {
                            TextEditor(text: $jsonText)
                                .font(.system(.body, design: .monospaced))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .onChange(of: jsonText) { _, _ in
                                    validateJSON()
                                }
                        }
                        .tabItem {
                            Label("Editor", systemImage: "pencil")
                        }
                        
                        ScrollView {
                            if isValid {
                                CardPreviewPlaceholder(json: jsonText)
                                    .padding()
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "xmark.circle")
                                        .font(.largeTitle)
                                        .foregroundColor(.red)
                                    Text("Invalid JSON")
                                        .font(.headline)
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .tabItem {
                            Label("Preview", systemImage: "eye")
                        }
                    }
                }
            }
            .navigationTitle("Card Editor")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { splitView.toggle() }) {
                        Image(systemName: splitView ? "rectangle.split.1x2" : "rectangle.split.2x1")
                    }
                    
                    Menu {
                        Button("Load Sample...") {
                            loadSample()
                        }
                        Button("Clear") {
                            jsonText = ""
                        }
                        Button("Format JSON") {
                            formatJSON()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            validateJSON()
        }
    }
    
    private func validateJSON() {
        do {
            _ = try JSONSerialization.jsonObject(with: jsonText.data(using: .utf8) ?? Data(), options: [])
            isValid = true
            errorMessage = ""
        } catch {
            isValid = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func formatJSON() {
        guard let data = jsonText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let formatted = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let formattedString = String(data: formatted, encoding: .utf8) else {
            return
        }
        jsonText = formattedString
    }
    
    private func loadSample() {
        // Load a sample card
        jsonText = Self.defaultCardJSON
    }

    static let defaultCardJSON = """
    {
      "type": "AdaptiveCard",
      "version": "1.5",
      "body": [
        {
          "type": "TextBlock",
          "text": "Hello, World!",
          "size": "large",
          "weight": "bolder"
        },
        {
          "type": "TextBlock",
          "text": "Edit this JSON to see changes in the preview pane.",
          "wrap": true
        }
      ],
      "actions": [
        {
          "type": "Action.Submit",
          "title": "Submit"
        }
      ]
    }
    """
}

private var defaultCardJSON: String {
    CardEditorView.defaultCardJSON
}
