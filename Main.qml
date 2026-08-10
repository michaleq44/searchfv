import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

Window {
    width: 800
    height: 600
    visible: true
    title: "FVSearch"
    color: sysPal.window

    SystemPalette { id: sysPal }

    MessageDialog {
        id: infoDialog
        title: "Information"
        text: "Information missing!"
        buttons: MessageDialog.Ok
    }

    Connections {
        target: controller
        function onShowDialog(message) {
            infoDialog.text = message
            infoDialog.open()
        }
    }

    function addKeyword() {
        const text = keywordInput.text.trim()
        if (text !== "") {
            keywordModel.appendString(text)
            keywordInput.text = ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            rows: 2
            columns: 2
            rowSpacing: 10
            columnSpacing: 10

            // files input
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: sysPal.mid
                border.width: 1
                color: sysPal.window

                DropArea {
                    anchors.fill: parent
                    onEntered: parent.color = sysPal.light
                    onExited: parent.color = sysPal.window
                    onDropped: {
                        parent.color = sysPal.window
                        let urls = drop.urls
                        for (let i = 0; i < urls.length; ++i) {
                            let path = urls[i].toString()
                            if (path.startsWith("file://")) {
                                path = path.substring(7)
                                path = decodeURIComponent(path)
                            }

                            if (path.toLowerCase().endsWith(".xml")) {
                                fileModel.appendString(path)
                                fileModel.parseLastAndAddToInvoices()
                            } else {
                                console.log("Skipping non-XML: ", path)
                            }
                        }
                        drop.accept(Qt.CopyAction)
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6

                    Label {
                        text: "Pliki XML (drag & drop)"
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: fileListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: fileModel
                            delegate: ItemDelegate {
                                text: model.display
                                width: parent.width
                                onClicked: fileListView.currentIndex = index
                                background: Rectangle {
                                    color: parent.highlighted ? sysPal.highlight : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.highlighted ? sysPal.highlightedText : sysPal.windowText
                                    elide: Text.ElideRight
                                }
                            }
                            highlight: Rectangle {
                                color: sysPal.highlight; radius: 2
                            }
                            focus: true
                            clip: true
                        }

                        Column {
                            spacing: 6
                            Button {
                                text: "Usuń"
                                onClicked: {
                                    if (fileListView.currentIndex >= 0)
                                        fileModel.removeAt(fileListView.currentIndex)
                                }
                            }
                            Button {
                                text: "Wyczyść"
                                onClicked: {
                                    fileModel.clear()
                                }
                            }
                        }
                    }
                }
            }

            // keywords input
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: sysPal.mid
                border.width: 1
                color: sysPal.window

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6

                    Label {
                        text: "Wyszukiwane fragmenty"
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: keywordInput
                            placeholderText: "Wprowadź nowy fragment"
                            Layout.fillWidth: true
                            onAccepted: addKeyword()
                        }
                        Button {
                            text: "Dodaj"
                            onClicked: addKeyword()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: keywordListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: keywordModel
                            delegate: ItemDelegate {
                                text: model.display
                                width: parent.width
                                onClicked: keywordListView.currentIndex = index
                                background: Rectangle {
                                    color: parent.highlighted ? sysPal.highlight : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.highlighted ? sysPal.highlightedText : sysPal.windowText
                                    elide: Text.ElideRight
                                }
                            }
                            highlight: Rectangle {
                                color: sysPal.highlight; radius: 2
                            }
                            focus: true
                            clip: true
                        }

                        Column {
                            spacing: 6
                            Button {
                                text: "Usuń"
                                onClicked: {
                                    if (keywordListView.currentIndex >= 0)
                                        keywordModel.removeAt(keywordListView.currentIndex)
                                }
                            }
                            Button {
                                text: "Wyczyść"
                                onClicked: {
                                    keywordModel.clear()
                                }
                            }
                        }
                    }
                }
            }

            // files output
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: sysPal.mid
                border.width: 1
                color: sysPal.window

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6

                    Label {
                        text: "Pliki zawierające co najmniej jedno ze słów kluczowych"
                        font.bold: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: outputListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: outputModel
                            delegate: ItemDelegate {
                                text: model.display
                                width: parent.width
                                onClicked: {
                                    outputModel.clickedItem(index)
                                    outputListView.currentIndex = index
                                }
                                background: Rectangle {
                                    color: parent.highlighted ? sysPal.highlight : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.highlighted ? sysPal.highlightedText : sysPal.windowText
                                    elide: Text.ElideRight
                                }
                            }
                            highlight: Rectangle {
                                color: sysPal.highlight; radius: 2
                            }
                            focus: true
                            clip: true
                        }
                    }
                }
            }

            // data preview
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: sysPal.mid
                border.width: 1
                color: sysPal.window
                Text {
                    anchors.fill: parent
                    anchors.margins: 10
                    text: detailsProvider.detailsText
                    color: sysPal.windowText
                    wrapMode: Text.WordWrap
                }
            }
        }

        // search button
        Button {
            id: searchButton
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            text: "Wyszukaj"
            font.pointSize: 16
            font.bold: true

            onClicked: {
                controller.scanAll()
            }
        }
    }
}
