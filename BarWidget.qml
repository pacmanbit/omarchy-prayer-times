import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "pacmanbit.prayer-times"

  property string outputText: ""
  property string outputTooltip: ""
  property string outputState: "far"
  property string outputColor: ""

  readonly property string scriptPath: String(Qt.resolvedUrl("scripts/prayer-times")).replace(/^file:\/\//, "")
  readonly property string citySetting: String(setting("city", ""))
  readonly property string countrySetting: String(setting("country", ""))
  readonly property string methodSetting: String(setting("method", ""))
  readonly property string nowColor: String(setting("nowColor", "#50FA7B"))
  readonly property string closeColor: String(setting("closeColor", "#FAB387"))

  function buildArgs(extraArgs) {
    var args = ["python3", root.scriptPath]
    if (root.citySetting !== "") { args.push("--city"); args.push(root.citySetting) }
    if (root.countrySetting !== "") { args.push("--country"); args.push(root.countrySetting) }
    if (root.methodSetting !== "") { args.push("--method"); args.push(root.methodSetting) }
    if (extraArgs) {
      for (var i = 0; i < extraArgs.length; i++) args.push(extraArgs[i])
    }
    return args
  }

  function refresh(forceFetch) {
    if (prayerProc.running) return
    prayerProc.command = buildArgs(forceFetch ? ["--refresh"] : [])
    prayerProc.running = true
  }

  function updateFromJson(raw) {
    var data = Util.parseModuleJson(raw)
    if (data && data.text) {
      outputText = data.text
      outputTooltip = data.tooltip || ""
      outputState = String(data.class || "far")
      outputColor = String(data.color || "")
    } else {
      var trimmed = String(raw || "").trim()
      if (trimmed !== "") outputText = trimmed
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: prayerProc
    command: root.buildArgs([])
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateFromJson(text)
    }
  }

  Process {
    id: actionProc
    onExited: root.refresh(false)
  }

  Timer {
    interval: Math.max(15, Number(root.setting("interval", 60))) * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh(false)
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.vertical ? "\udb86\udc56" : (root.outputText || "\udb86\udc56 ...")
    tooltipText: root.outputTooltip || "Islamic Prayer Times"
    horizontalMargin: Number(root.setting("horizontalMargin", 7.5))
    verticalPadding: Number(root.setting("verticalPadding", 6))
    fontSize: Number(root.setting("fontSize", 12))
    foreground: {
      if (root.outputState === "now") return root.nowColor
      if (root.outputState === "close") return root.closeColor
      if (root.outputColor !== "") return root.outputColor
      return root.bar ? root.bar.barForeground : Commons.Color.foreground
    }

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.RightButton) {
        root.refresh(true)
      } else {
        if (!actionProc.running) {
          actionProc.command = root.buildArgs(["--notify"])
          actionProc.running = true
        }
      }
    }
  }
}
