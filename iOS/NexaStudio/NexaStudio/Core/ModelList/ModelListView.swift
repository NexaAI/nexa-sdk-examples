import SwiftUI

struct ModelListView: View {

    @Environment(\.dismiss) var dismiss

    @State var vm: ModelListViewModel

    @State var errorToast: AnyToast?

    var body: some View {
        ZStack {
            if vm.isLoading {
                LoadingView()
            } else if let status = vm.status {
                StatusView(status: status)
            } else {
                modelListView
            }
        }
        .defaultBackButton()
        .customNavigationBarTitle("Models")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Background.primary)
        .onFirstAppear {
            vm.appendDownloadItems()
            Task {
                await vm.loadModel()
            }
        }
        .animation(.smooth, value: vm.expandSection.count)
        .toast($errorToast)
    }

    private var modelListView: some View {
        List {
            if !vm.anyModels.isEmpty {
                section(type: .any, models: vm.anyModels)
            }
            
            if !vm.multiModels.isEmpty {
                section(type: .imageToText, models: vm.multiModels)
            }
            if !vm.chatModels.isEmpty {
                section(type: .chat, models: vm.chatModels)
            }
        }
        .listStyle(.plain)
        .listBackground(Color.Background.primary)
    }

    private func section(type: ModelType, models: [ModelInfo]) -> some View {
        Section {
            ModelSectionHeaderView(modelType: type) {
                vm.toggleExpandSection(type)
            }
            .removeListRowFormatting(.init(top: 16, leading: 16, bottom: 0, trailing: 16))

            if vm.isSectionExpand(type) {
                ForEach(models, id: \.id) { modelInfo in
                    let item = vm.downloadItem(of: modelInfo)
                    ModelCardView(model: modelInfo, item: item, currentRunModel: vm.currentRunModel) {
                        dismiss()
                    } onRemoveButtonPressed: {
                        if modelInfo.id == vm.modelManager.currentModelInfo?.id {
                            vm.modelManager.currentModelInfo = nil
                        }
                    } onDownloadError: { desc in
                        errorToast = .error(desc)
                    }
                }
                .removeListRowFormatting(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ModelListView(vm: .init(downloadManager: DevPreview.share.modelDownloadManager, modelManager: DevPreview.share.modelManager))
            .previewEnvironment()
    }
}
