# 常見問題解答

## 問題回報後的處理

### 我提的問題或需求或者 PR，怎麼一直都沒有人處理？

1. 不是所有的問題或需求都活該得到積極響應。與上游不同，敝專案會在某些問題/需求因自身特性而無法響應之的情況下做出對應的說明、以節約雙方的時間與感情。

2. 雖然威注音專案的研發時間投入比上游高出幾個數量級，但也只是偶然。請勿將這種日常視為理所當然，誰都會有因為私事而突然變忙的時候。

3. 有時，自己的痛苦，就是源於自己的無能。自己覺得對方不去做的話，「自己學、自己做」可能還真的就是最快的方式，因為反正對方可能到死都不會去做、就是要跟你鬧情緒。「軟體與程式碼是開源的，但專案是私人的」。早一點做出最壞的預期的話，就早一點意識到：自己的情緒管理控制權應該在自己的手中、且管理的方法就是讓自己變得比對方更強。你不需要獲得對方的承認，因為你的勝利在於你比對方創造了更多被公認的有利於社會的價值。

## 使用相關

### 1. 輸入法選單內的輸入法是灰色的，無法選中。

1. macOS 系統終端機內的「加密的鍵盤輸入」選項被啟用了。請點選「終端機」選單，關閉「加密的鍵盤輸入」選項，威注音就會正常出現在輸入法選單上。英文語系的使用者可以從「Terminal -> Secure Keyboard Entry」選單關閉該選項。包括 iTerms 在內的某些副廠終端機模擬軟體也會有類似的功能，請自行排查。

2. 你可能需要重新登入，特別是你在對威注音輸入法進行升級或者降級安裝的情況下。

### 2. 輸入法選單內出現多個相同的威注音輸入法副本。

請立刻重新登入。如果問題仍舊持續存在的話，請用終端機執行：

```bash
sudo "/Library/Input Methods/vChewing.app/Contents/MacOS/vChewing" uninstall
```

這道命令可以將任何安裝到錯誤位置的威注音輸入法移除掉。在這道命令之後，請再次執行最新的威注音的安裝程式。

威注音輸入法僅該被安裝到使用者目錄內的「~/Library/Input Methods/」目錄下，這也有助於將威注音輸入法安裝到受公司資安策略管控的電腦上。

### 3. 怎樣用非常規手段安裝部署威注音？

本次以 pkg 的形式發行安裝程式，方便資安管理業者們藉由終端機進行部署。

 終端部署可以用這道指令：
```bash
installer -pkg ~/Downloads/vChewing-macOS-?.?.?-unsigned.pkg -target CurrentUserHomeDirectory
```

由於只會安裝至使用者目錄內，所以同一台電腦不同使用者需要分別安裝一遍。

下述終端命令亦可使下載來的程式從 macOS 門衛檢查隔離區內取出來：
```bash
xattr -dr com.apple.quarantine ~/Downloads/vChewing-macOS-?.?.?-unsigned.pkg
xattr -dr com.apple.quarantine ~/Downloads/vChewingInstaller.app
```
另請注意 macOS 10 & 11 的所有系統版本均有一處行為故障：pkg 安裝包指定僅裝在使用者目錄下的話，**在 macOS 10 & 11
 內執行時，仍舊會往總根目錄下安裝，除非您手動點「更改安裝位置」再將那唯一的「安裝只供我使用」再點一遍才可以**。

### 4. 有打算支援 Homebrew 等安裝途徑嗎？

這樣會增大維護成本，所以不會再考慮。

### 5. 選字窗位置不對欸。

這往往是您在敲字時使用的應用程式，並沒有正確地將正確的游標位置告知 IMK、導致輸入法無法得知相關的資訊使然。您在某個應用程式中敲字，輸入游標的位置到底在哪裡，一開始只有那個應用程式知道，然後，那個應用程式必須把正確的位置告知輸入法，輸入法才知道應該在什麼位置，顯示像是選字窗這樣的使用者介面元件。某些應用完全沒有認真處理與 macOS 的 IMK 框架有關的內容，所以就通知了輸入法一個奇怪的位置資訊，有時候座標根本就在螢幕大小之外。威注音在使用的 Voltaire MK3 與上游使用的 Voltaire MK2 的判斷方法相同：如果某個應用程式將奇怪的位置（不在任何一個螢幕的範圍內）告知給 IMK，那麼輸入法就會想辦法把選字窗擺在螢幕範圍內最接近的位置。比方說：如果是 y 軸超過了螢幕尺寸，就會改在螢幕的最上方顯示。

### 6. 自訂使用者語彙資料該怎麼管理？

輸入法選單內有相關的選項、允許您開啟使用者語彙資料目錄來自行備份。您也可以藉由輸入法偏好設定來修改這個目錄的位置。修改該目錄的位置的行為並不會自動遷移這些資料。

出於研發負擔與使用者體驗管理方面的疑慮，威注音輸入法不打算內建基於 git 的使用者語彙資料版本管理備份功能。如果您有相關的產品需求的話，完全可以自己寫 bash 腳本搭配系統內建的 cron 功能來使用。

## 技術相關：

### 威注音會使用多少系統資源？

此部分以威注音 v2.7.0 版來說明。

在 2018 Intel Mac Mini 以及 2020 年的末代 Intel MacBook Pro 13-inch 機種內使用 Xcode 對威注音做側寫的過程中，我們得到的測試結果是：

1. 如果僅使用簡體中文或繁體中文單個模式的原廠詞庫、且啟用「按需載入簡繁體模式的原廠辭典資料」的話，記憶體開銷大約在 70-80MB 起步。
2. 如果簡體中文與繁體中文模式的原廠詞庫都載入的話，大約會佔用 110-120 MB 左右的記憶體。
3. 值得注意的是，如果使用者語彙內容體積有所增長的話，對應的記憶體開銷也會有相應的上漲。

為什麼會比上游多出幾乎接近 10 倍呢？因為 Swift 對 string 資料的處理就是這樣不經濟。這還是在經過優化處理之後的結果。（威注音在 1.5.4 版內部測試的時候，語言模組體系剛剛 Swift 化，記憶體開銷是 700MB。）我們能得出的對 Swift 而言的最佳處理方案就是使用 plist 格式的原廠語彙資料，這樣能夠兼顧十年前的舊機種的 CPU 算力。假如只照顧最近三年以來的機種的話，還可以換用另一種算法、來將記憶體開銷縮減至 80MB 以內。

得益於威注音的純 Swift 化，平常處理每個按鍵事件都可以在毫秒級別的時間完成。

### 我想修改威注音，新增一些偏好設定。請問需要注意哪些問題？

在 PrefUI (macOS 10.15 開始的 SwiftUI 偏好設定介面) 與 PrefWindow (針對 macOS 10.14 為止的舊版偏好設定介面) 當中新增對應的介面內容之前，你需要做這些：

1. 在「vChewing_Shared」封包當中的 Shared.swift 檔案內的 UserDef 這個 Enum 當中添入新的記錄，用以規定該資料值在 UserDefaults plist 當中的名稱。
2. 在「vChewing_Shared」封包當中的 PrefMgrProtocol 當中添入對應的新資料值的規範。
3. 在 PrefMgr.swfit 當中依照 PrefMgrProtocol 的變動來添入對應的新資料值。
4. 與小麥注音不同的是，威注音給 Bool 類型引入了 toggled() 特性，會先 toggle() 再回傳操作後的資料值結果。如果您需要讓參數在行將變化、或者變化之後自動做些什麼的話，請擴充該參數的 willSet 或 didSet 特性、而不需要再另外設定函式（除非需要再傳入特定的參數）。

### 威注音 2.7.0 版好像改很兇，但又幾乎沒有新功能。究竟改了哪些內容？

威注音 2.7.0 是威注音的 Dezonblization 行動的一部分，旨在讓在此之後的研發流程更能順利進行。藉由將整個專案大卸八塊、拆成各個以 Swift Package 為單位的各種組件，以及對大中心派發技術（Grand Central Dispatch）的合理運用，威注音得以做到更快的專案建置速度、更快的辭典載入速度、更清晰且更易於維護的專案結構框架。至於放棄 macOS 10.11-10.12 的支援，則是因為 NSGridView 以及 Xcode 14 的雙雙限制使然。藉由這些改動，威注音今後在理論上就可以引入對 KeyHandler 等元件的更有效的單元測試。

$ EOF.