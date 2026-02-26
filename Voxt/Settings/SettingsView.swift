import SwiftUI

struct SettingsView: View {
    @ObservedObject var mlxModelManager: MLXModelManager
    @State private var selectedTab: SettingsTab = .model
    @State private var hostWindow: NSWindow?

    var body: some View {
        VStack(spacing: 0) {
            SettingsTabHeader(selectedTab: $selectedTab)

            Divider()

            ScrollView {
                Group {
                    switch selectedTab {
                    case .model:
                        ModelSettingsView(mlxModelManager: mlxModelManager)
                    case .hotkey:
                        HotkeySettingsView()
                    case .about:
                        AboutSettingsView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 22)
                .padding(.top, 10)
                .padding(.bottom, 16)
            }
        }
        .frame(minWidth: 520, minHeight: 520)
        .background(
            WindowAccessor { window in
                hostWindow = window
            }
        )
        .onAppear {
            updateWindowTitle()
        }
        .onChange(of: selectedTab) { _, _ in
            updateWindowTitle()
        }
        .onChange(of: hostWindow) { _, _ in
            updateWindowTitle()
        }
    }

    private func updateWindowTitle() {
        guard let hostWindow else { return }
        hostWindow.title = selectedTab.title
        hostWindow.titleVisibility = .visible
    }
}

private struct SettingsTabHeader: View {
    @Binding var selectedTab: SettingsTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SettingsTab.allCases) { tab in
                ZStack {
                    (tab == selectedTab ? Color.primary.opacity(0.08) : Color.clear)
                    HStack(spacing: 8) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 14, weight: .semibold))
                        Text(tab.title)
                            .font(.caption)
                    }
                    .foregroundStyle(tab == selectedTab ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = tab
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
