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
        title: "Info"
        text: "Brakuje informacji!"
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
                radius: 6

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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: sysPal.window
                            border.color: sysPal.mid
                            border.width: 1
                            radius: 2

                            ListView {
                                id: fileListView
                                anchors.fill: parent

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
                                highlight: Item {
                                    Rectangle {
                                        color: sysPal.highlight
                                        radius: 2
                                        anchors.fill: parent
                                        anchors.margins: 4
                                    }
                                }
                                focus: true
                                clip: true
                            }

                            DropArea {
                                anchors.fill: parent
                                onEntered: parent.color = sysPal.light
                                onExited: parent.color = sysPal.window
                                onDropped: {
                                    parent.color = sysPal.window
                                    let urls = drop.urls
                                    for (let i = 0; i < urls.length; ++i) {
                                        let path = urls[i].toString().replace(/^file:\/*/, "")
                                        path = decodeURIComponent(path)
                                        if (Qt.platform.os === "windows") {
                                            path = path.replace(/\//g, "\\")
                                        } else if (!path.startsWith("/") && path.length > 0) {
                                            path = "/" + path
                                        }
                                        console.log("loading ", path)

                                        if (path.toLowerCase().endsWith(".xml")) {
                                            let added = fileModel.appendString(path)
                                            if (added) {
                                                fileModel.parseLastAndAddToInvoices()
                                            }
                                        } else {
                                            console.log("Skipping non-XML: ", path)
                                        }
                                    }
                                    drop.accept(Qt.CopyAction)
                                }
                            }
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

            // files output
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: sysPal.mid
                border.width: 1
                color: sysPal.window
                radius: 6

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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: sysPal.window
                            radius: 2
                            border.color: sysPal.mid
                            border.width: 1
                            ListView {
                                id: outputListView
                                anchors.fill: parent
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
                                highlight: Item {
                                    Rectangle {
                                        color: sysPal.highlight
                                        radius: 2
                                        anchors.fill: parent
                                        anchors.margins: 4
                                    }
                                }
                                focus: true
                                clip: true
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
                radius: 6

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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: sysPal.window
                            border.color: sysPal.mid
                            border.width: 1
                            radius: 2

                            ListView {
                                id: keywordListView
                                anchors.fill: parent
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
                                highlight: Item {
                                    Rectangle {
                                        color: sysPal.highlight
                                        radius: 2
                                        anchors.fill: parent
                                        anchors.margins: 4
                                    }
                                }
                                focus: true
                                clip: true
                            }
                        }

                        Column {
                            spacing: 6
                            Button {
                                text: "Usuń"
                                onClicked: {
                                    if (keywordListView.currentIndex >= 0) {
                                        keywordModel.removeAt(keywordListView.currentIndex)
                                    }
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

            // data preview
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: sysPal.mid
                border.width: 1
                color: sysPal.window
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6

                    Label {
                        Layout.fillWidth: true
                        text: "Podgląd"
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: detailsProvider.detailsText
                        color: sysPal.windowText
                        wrapMode: Text.WordWrap
                    }
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
