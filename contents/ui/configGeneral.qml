import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes

KCM.SimpleKCM {
    id: page

    // Align content with the dialog's page title, which is inset ~1 gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit
    topPadding: Kirigami.Units.largeSpacing
    bottomPadding: Kirigami.Units.largeSpacing

    // Absorb the cfg_<key>Default initial properties the config dialog sets
    property string cfg_iconDefault: ""
    property int cfg_iconSizeDefault: 0

    property alias cfg_icon: iconField.text

    // The size combo is editable: presets fill the popup, but any number can
    // be typed. 0 / non-numeric text means "Fit panel".
    property int cfg_iconSize
    onCfg_iconSizeChanged: syncIconSizeCombo()

    function syncIconSizeCombo() {
        if (cfg_iconSize === 0) {
            iconSizeCombo.currentIndex = 0;
            return;
        }
        const i = iconSizeCombo.find(String(cfg_iconSize));
        if (i >= 0) {
            iconSizeCombo.currentIndex = i;
        } else {
            iconSizeCombo.currentIndex = -1;
            iconSizeCombo.editText = String(cfg_iconSize);
        }
    }

    // Reset every option to its main.xml default
    function restoreDefaults() {
        cfg_icon = cfg_iconDefault;
        cfg_iconSize = cfg_iconSizeDefault;
    }

    // The hint spans the full width below the form instead of sitting in the
    // form's field column with a dead label column on the left.
    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            QQC2.Button {
                icon.name: "document-revert"
                text: i18n("Restore defaults")
                onClicked: page.restoreDefaults()
            }
        }

        // Plain two-column grid instead of Kirigami.FormLayout: the form hugs
        // the left edge rather than centering in the page (which left a large
        // dead zone on the left).
        GridLayout {
            columns: 2
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignLeft

            QQC2.Label {
                text: i18n("Icon:")
                Layout.alignment: Qt.AlignRight
            }
            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Button {
                    icon.name: iconField.text
                    text: i18n("Choose…")
                    onClicked: iconDialog.open()

                    KIconThemes.IconDialog {
                        id: iconDialog
                        onIconNameChanged: iconField.text = iconName
                    }
                }
                QQC2.TextField {
                    id: iconField
                }
            }

            QQC2.Label {
                text: i18n("Icon size (px):")
                Layout.alignment: Qt.AlignRight
            }
            QQC2.ComboBox {
                id: iconSizeCombo
                editable: true
                model: [i18n("Fit panel"), "16", "22", "24", "32", "48", "64", "96", "128"]

                function commit(text, index) {
                    const n = parseInt(text);
                    page.cfg_iconSize = (index === 0 || isNaN(n) || n <= 0) ? 0 : Math.min(n, 256);
                }
                onActivated: index => commit(textAt(index), index)
                onAccepted: commit(editText, find(editText) === 0 ? 0 : -1)
                Component.onCompleted: page.syncIconSizeCombo()
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Choose… browses theme icons and, via its Browse button, arbitrary image files (PNG/SVG). The field also accepts a typed icon name or file path.")
            font: Kirigami.Theme.smallFont
            wrapMode: Text.WordWrap
        }
    }
}
