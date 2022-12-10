// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import LangModelAssembly
import NotifierUI
import SSPreferences
import UpdateSputnik

extension Bool {
  fileprivate var state: NSControl.StateValue {
    self ? .on : .off
  }
}

// MARK: - IME Menu Manager

// 因為選單部分的內容又臭又長，所以就單獨拉到一個檔案內管理了。

extension SessionCtl {
  var optionKeyPressed: Bool { NSEvent.modifierFlags.contains(.option) }

  override public func menu() -> NSMenu! {
    let menu = NSMenu(title: "Input Method Menu")

    let useSCPCTypingModeItem = menu.addItem(
      withTitle: "Per-Char Select Mode".localized,
      action: #selector(toggleSCPCTypingMode(_:)), keyEquivalent: PrefMgr.shared.usingHotKeySCPC ? "P" : ""
    )
    useSCPCTypingModeItem.keyEquivalentModifierMask = [.command, .control]
    useSCPCTypingModeItem.state = PrefMgr.shared.useSCPCTypingMode.state

    let userAssociatedPhrasesItem = menu.addItem(
      withTitle: "Per-Char Associated Phrases".localized,
      action: #selector(toggleAssociatedPhrasesEnabled(_:)),
      keyEquivalent: PrefMgr.shared.usingHotKeyAssociates ? "O" : ""
    )
    userAssociatedPhrasesItem.keyEquivalentModifierMask = [.command, .control]
    userAssociatedPhrasesItem.state = PrefMgr.shared.associatedPhrasesEnabled.state

    let cassetteModeItem = menu.addItem(
      withTitle: "CIN Cassette Mode".localized,
      action: #selector(toggleCassetteMode(_:)),
      keyEquivalent: PrefMgr.shared.usingHotKeyCassette ? "I" : ""
    )
    cassetteModeItem.keyEquivalentModifierMask = [.command, .control]
    cassetteModeItem.state = PrefMgr.shared.cassetteEnabled.state

    let useCNS11643SupportItem = menu.addItem(
      withTitle: "CNS11643 Mode".localized,
      action: #selector(toggleCNS11643Enabled(_:)), keyEquivalent: PrefMgr.shared.usingHotKeyCNS ? "L" : ""
    )
    useCNS11643SupportItem.keyEquivalentModifierMask = [.command, .control]
    useCNS11643SupportItem.state = PrefMgr.shared.cns11643Enabled.state

    if IMEApp.currentInputMode == .imeModeCHT {
      let chineseConversionItem = menu.addItem(
        withTitle: "Force KangXi Writing".localized,
        action: #selector(toggleChineseConverter(_:)), keyEquivalent: PrefMgr.shared.usingHotKeyKangXi ? "K" : ""
      )
      chineseConversionItem.keyEquivalentModifierMask = [.command, .control]
      chineseConversionItem.state = PrefMgr.shared.chineseConversionEnabled.state
      let shiftJISConversionItem = menu.addItem(
        withTitle: "JIS Shinjitai Output".localized,
        action: #selector(toggleShiftJISShinjitaiOutput(_:)), keyEquivalent: PrefMgr.shared.usingHotKeyJIS ? "J" : ""
      )
      shiftJISConversionItem.keyEquivalentModifierMask = [.command, .control]
      shiftJISConversionItem.state = PrefMgr.shared.shiftJISShinjitaiOutputEnabled.state
    }

    let currencyNumeralsItem = menu.addItem(
      withTitle: "Currency Numeral Output".localized,
      action: #selector(toggleCurrencyNumerals(_:)),
      keyEquivalent: PrefMgr.shared.usingHotKeyCurrencyNumerals ? "M" : ""
    )
    currencyNumeralsItem.keyEquivalentModifierMask = [.command, .control]
    currencyNumeralsItem.state = PrefMgr.shared.currencyNumeralsEnabled.state

    let halfWidthPunctuationItem = menu.addItem(
      withTitle: "Half-Width Punctuation Mode".localized,
      action: #selector(toggleHalfWidthPunctuation(_:)),
      keyEquivalent: PrefMgr.shared.usingHotKeyHalfWidthASCII ? "H" : ""
    )
    halfWidthPunctuationItem.keyEquivalentModifierMask = [.command, .control]
    halfWidthPunctuationItem.state = PrefMgr.shared.halfWidthPunctuationEnabled.state

    if optionKeyPressed || PrefMgr.shared.phraseReplacementEnabled {
      let phaseReplacementItem = menu.addItem(
        withTitle: "Use Phrase Replacement".localized,
        action: #selector(togglePhraseReplacement(_:)), keyEquivalent: ""
      )
      phaseReplacementItem.state = PrefMgr.shared.phraseReplacementEnabled.state
    }

    if optionKeyPressed {
      let toggleSymbolInputItem = menu.addItem(
        withTitle: "Symbol & Emoji Input".localized,
        action: #selector(toggleSymbolEnabled(_:)), keyEquivalent: ""
      )
      toggleSymbolInputItem.state = PrefMgr.shared.symbolInputEnabled.state
    }

    menu.addItem(NSMenuItem.separator())  // ---------------------

    menu.addItem(
      withTitle: "Open User Dictionary Folder".localized,
      action: #selector(openUserDataFolder(_:)), keyEquivalent: ""
    )
    menu.addItem(
      withTitle: "Edit vChewing User Phrases…".localized,
      action: #selector(openUserPhrases(_:)), keyEquivalent: ""
    )
    menu.addItem(
      withTitle: "Edit Excluded Phrases…".localized,
      action: #selector(openExcludedPhrases(_:)), keyEquivalent: ""
    )

    if optionKeyPressed || PrefMgr.shared.associatedPhrasesEnabled {
      menu.addItem(
        withTitle: "Edit Associated Phrases…".localized,
        action: #selector(openAssociatedPhrases(_:)), keyEquivalent: ""
      )
    }

    if optionKeyPressed {
      menu.addItem(
        withTitle: "Edit Phrase Replacement Table…".localized,
        action: #selector(openPhraseReplacement(_:)), keyEquivalent: ""
      )
      menu.addItem(
        withTitle: "Edit User Symbol & Emoji Data…".localized,
        action: #selector(openUserSymbols(_:)), keyEquivalent: ""
      )
    }

    if optionKeyPressed || !PrefMgr.shared.shouldAutoReloadUserDataFiles {
      menu.addItem(
        withTitle: "Reload User Phrases".localized,
        action: #selector(reloadUserPhrasesData(_:)), keyEquivalent: ""
      )
    }

    menu.addItem(NSMenuItem.separator())  // ---------------------

    menu.addItem(
      withTitle: "Optimize Memorized Phrases".localized,
      action: #selector(removeUnigramsFromUOM(_:)), keyEquivalent: ""
    )
    menu.addItem(
      withTitle: "Clear Memorized Phrases".localized,
      action: #selector(clearUOM(_:)), keyEquivalent: ""
    )

    menu.addItem(NSMenuItem.separator())  // ---------------------

    menu.addItem(
      withTitle: "vChewing Preferences…".localized,
      action: #selector(showPreferences(_:)), keyEquivalent: ""
    )
    menu.addItem(
      withTitle: "Client Manager".localized.withEllipsis,
      action: #selector(showClientListMgr(_:)), keyEquivalent: ""
    )
    if !optionKeyPressed {
      menu.addItem(
        withTitle: "Check for Updates…".localized,
        action: #selector(checkForUpdate(_:)), keyEquivalent: ""
      )
    }
    menu.addItem(
      withTitle: "Reboot vChewing…".localized,
      action: #selector(selfTerminate(_:)), keyEquivalent: ""
    )
    menu.addItem(
      withTitle: "About vChewing…".localized,
      action: #selector(showAbout(_:)), keyEquivalent: ""
    )
    menu.addItem(
      withTitle: "CheatSheet".localized.withEllipsis,
      action: #selector(showCheatSheet(_:)), keyEquivalent: ""
    )
    if optionKeyPressed {
      menu.addItem(
        withTitle: "Uninstall vChewing…".localized,
        action: #selector(selfUninstall(_:)), keyEquivalent: ""
      )
    }

    return menu
  }
}

// MARK: - IME Menu Items

extension SessionCtl {
  @objc public override func showPreferences(_: Any? = nil) {
    if #unavailable(macOS 10.15) {
      CtlPrefWindow.show()
    } else if NSEvent.modifierFlags.contains(.option) {
      CtlPrefWindow.show()
    } else {
      CtlPrefUI.shared.controller.show(preferencePane: SSPreferences.PaneIdentifier(rawValue: "General"))
      CtlPrefUI.shared.controller.window?.level = .statusBar
      CtlPrefUI.shared.controller.window?.setPosition(vertical: .top, horizontal: .right, padding: 20)
    }
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc public func showCheatSheet(_: Any? = nil) {
    guard let url = Bundle.main.url(forResource: "shortcuts", withExtension: "html") else { return }
    DispatchQueue.main.async {
      NSWorkspace.shared.openFile(url.path, withApplication: "Safari")
    }
  }

  @objc public func showClientListMgr(_: Any? = nil) {
    CtlClientListMgr.show()
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc public func toggleCassetteMode(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    if !PrefMgr.shared.cassetteEnabled, !LMMgr.checkCassettePathValidity(PrefMgr.shared.cassettePath) {
      DispatchQueue.main.async {
        IMEApp.buzz()
        let alert = NSAlert(error: "Path invalid or file access error.".localized)
        let informativeText = "Please reconfigure the cassette path to a valid one before enabling this mode."
        alert.informativeText = informativeText.localized
        let result = alert.runModal()
        NSApp.activate(ignoringOtherApps: true)
        if result == NSApplication.ModalResponse.alertFirstButtonReturn {
          LMMgr.resetCassettePath()
          PrefMgr.shared.cassetteEnabled = false
        }
      }
      return
    }
    Notifier.notify(
      message: "CIN Cassette Mode".localized + "\n"
        + (PrefMgr.shared.cassetteEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
    if !LMMgr.currentLM.isCassetteDataLoaded {
      LMMgr.loadCassetteData()
    }
  }

  @objc public func toggleSCPCTypingMode(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Per-Char Select Mode".localized + "\n"
        + (PrefMgr.shared.useSCPCTypingMode.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleChineseConverter(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Force KangXi Writing".localized + "\n"
        + (PrefMgr.shared.chineseConversionEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleShiftJISShinjitaiOutput(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "JIS Shinjitai Output".localized + "\n"
        + (PrefMgr.shared.shiftJISShinjitaiOutputEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleCurrencyNumerals(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Currency Numeral Output".localized + "\n"
        + (PrefMgr.shared.currencyNumeralsEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleHalfWidthPunctuation(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Half-Width Punctuation Mode".localized + "\n"
        + (PrefMgr.shared.halfWidthPunctuationEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleCNS11643Enabled(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "CNS11643 Mode".localized + "\n"
        + (PrefMgr.shared.cns11643Enabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleSymbolEnabled(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Symbol & Emoji Input".localized + "\n"
        + (PrefMgr.shared.symbolInputEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func toggleAssociatedPhrasesEnabled(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Per-Char Associated Phrases".localized + "\n"
        + (PrefMgr.shared.associatedPhrasesEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func togglePhraseReplacement(_: Any? = nil) {
    resetInputHandler(forceComposerCleanup: true)
    Notifier.notify(
      message: "Use Phrase Replacement".localized + "\n"
        + (PrefMgr.shared.phraseReplacementEnabled.toggled()
          ? "NotificationSwitchON".localized
          : "NotificationSwitchOFF".localized)
    )
  }

  @objc public func selfUninstall(_: Any? = nil) {
    (NSApp.delegate as? AppDelegate)?.selfUninstall()
  }

  @objc public func selfTerminate(_: Any? = nil) {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.terminate(nil)
  }

  @objc public func checkForUpdate(_: Any? = nil) {
    UpdateSputnik.shared.checkForUpdate(forced: true, url: kUpdateInfoSourceURL)
  }

  @objc public func openUserDataFolder(_: Any? = nil) {
    if !LMMgr.userDataFolderExists {
      return
    }
    NSWorkspace.shared.openFile(
      LMMgr.dataFolderPath(isDefaultFolder: false), withApplication: "Finder"
    )
  }

  @objc public func openUserPhrases(_: Any? = nil) {
    LMMgr.openUserDictFile(type: .thePhrases, dual: optionKeyPressed, alt: optionKeyPressed)
  }

  @objc public func openExcludedPhrases(_: Any? = nil) {
    LMMgr.openUserDictFile(type: .theFilter, dual: optionKeyPressed, alt: optionKeyPressed)
  }

  @objc public func openUserSymbols(_: Any? = nil) {
    LMMgr.openUserDictFile(type: .theSymbols, dual: optionKeyPressed, alt: optionKeyPressed)
  }

  @objc public func openPhraseReplacement(_: Any? = nil) {
    LMMgr.openUserDictFile(type: .theReplacements, dual: optionKeyPressed, alt: optionKeyPressed)
  }

  @objc public func openAssociatedPhrases(_: Any? = nil) {
    LMMgr.openUserDictFile(type: .theAssociates, dual: optionKeyPressed, alt: optionKeyPressed)
  }

  @objc public func reloadUserPhrasesData(_: Any? = nil) {
    LMMgr.initUserLangModels()
  }

  @objc public func removeUnigramsFromUOM(_: Any? = nil) {
    LMMgr.removeUnigramsFromUserOverrideModel(IMEApp.currentInputMode)
    if NSEvent.modifierFlags.contains(.option) {
      LMMgr.removeUnigramsFromUserOverrideModel(IMEApp.currentInputMode.reversed)
    }
  }

  @objc public func clearUOM(_: Any? = nil) {
    LMMgr.clearUserOverrideModelData(IMEApp.currentInputMode)
    if NSEvent.modifierFlags.contains(.option) {
      LMMgr.clearUserOverrideModelData(IMEApp.currentInputMode.reversed)
    }
  }

  @objc public func showAbout(_: Any? = nil) {
    CtlAboutWindow.show()
    NSApp.activate(ignoringOtherApps: true)
  }
}
