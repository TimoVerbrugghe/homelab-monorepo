function Remove-UWPAppx() {
    [CmdletBinding()]
    param (
        [Array] $AppxPackages
    )

    ForEach ($AppxPackage in $AppxPackages) {
        If ((Get-AppxPackage -AllUsers -Name $AppxPackage) -or (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppxPackage)) {
            Write-Host "$AppxPackage being removed"
            Get-AppxPackage -AllUsers -Name $AppxPackage | Remove-AppxPackage # App
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppxPackage | Remove-AppxProvisionedPackage -Online -AllUsers # Payload
        } Else {
            Write-Host "$AppxPackage was already removed or not found ..."
        }
    }
}

function Remove-BloatwareAppsList() {
    $Apps = @(
        # Default Windows apps
        "Microsoft.3DBuilder"                    # 3D Builder
        "Microsoft.549981C3F5F10"                # Cortana
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"                  # Finance
        "Microsoft.BingFoodAndDrink"             # Food And Drink
        "Microsoft.BingHealthAndFitness"         # Health And Fitness
        "Microsoft.BingNews"                     # News
        "Microsoft.BingSports"                   # Sports
        "Microsoft.BingTranslator"               # Translator
        "Microsoft.BingTravel"                   # Travel
        "Microsoft.BingWeather"                  # Weather
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection" # MS Solitaire
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"               # MS Office One Note
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"                       # People
        "Microsoft.MSPaint"                      # Paint 3D
        "Microsoft.Print3D"                      # Print 3D
        "Microsoft.SkypeApp"                     # Skype (Who still uses Skype? Use Discord)
        "Microsoft.Todos"                        # Microsoft To Do
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"                   # Microsoft Whiteboard
        "Microsoft.WindowsAlarms"                # Alarms
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsMaps"                  # Maps
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"         # Windows Sound Recorder
        "Microsoft.XboxApp"                      # Xbox Console Companion (Replaced by new App)
        "Microsoft.YourPhone"                    # Your Phone
        "Microsoft.ZuneMusic"                    # Groove Music / (New) Windows Media Player
        "Microsoft.ZuneVideo"                    # Movies & TV
        "Microsoft.FreshPaint"             # Paint
        #"Microsoft.MicrosoftEdge"          # Microsoft Edge
        "Microsoft.MicrosoftStickyNotes"   # Sticky Notes
        "Microsoft.WindowsCalculator"      # Calculator
        "Microsoft.WindowsCamera"          # Camera
        "Microsoft.ScreenSketch"           # Snip and Sketch (now called Snipping tool, replaces the Win32 version in clean installs)
        "Microsoft.WindowsFeedbackHub"     # Feedback Hub
        "Microsoft.Windows.Photos"         # Photos

        # Default Windows 11 apps
        "Clipchamp.Clipchamp"				     # Clipchamp – Video Editor
        "MicrosoftWindows.Client.WebExperience"  # Taskbar Widgets
        "MicrosoftTeams*"                         # Microsoft Teams / Preview
        "Microsoft.Todos"
        "Microsoft.PowerAutomateDesktop"

        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"

        "Microsoft.Paint*"              # Because Microsoft likes to change the name of paint
        "MicrosoftCorporationII.QuickAssist*"

        # 3rd party Apps
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"                # Adobe Photoshop Express
        "*Amazon.com.Amazon*"                    # Amazon Shop
        "*Asphalt8Airborne*"                     # Asphalt 8 Airbone
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"                     # Bubble Witch 3 Saga
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"                           # Candy Crush
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"                                # Dolby Products (Like Atmos)
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"       # Duolingo
        "*EclipseManager*"
        "*Facebook*"                             # Facebook
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"                            # Flipboard
        "*HiddenCity*"
        "*Hulu*"
        "*iHeartRadio*"
        "*Keeper*"
        "*LinkedInforWindows*"
        "*MarchofEmpires*"
        "*NYTCrossword*"
        "*OneCalendar*"
        "*PandoraMediaInc*"
        "*PhototasticCollage*"
        "*PicsArt-PhotoStudio*"
        "*Plex*"                                 # Plex
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"                          # Royal Revolt
        "*Shazam*"
        "*Sidia.LiveWallpaper*"                  # Live Wallpaper
        "*SlingTV*"
        "*Speed Test*"
        "*Sway*"
        "*TuneInRadio*"
        "*Twitter*"                              # Twitter
        "*Viber*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
        "*Netflix*"                             # Netflix
        "*Spotify*"                             # Spotify
        "*Amazon*"                              # Prime Video

        # default Windows 10 apps
        "Microsoft.549981C3F5F10"               # Cortana Offline
        "Microsoft.OneDriveSync"                # Onedrive
        "Microsoft.3DBuilder"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingWeather"
        "Microsoft.FreshPaint"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MicrosoftStickyNotes"
        "Microsoft.MinecraftUWP"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"
        "Microsoft.People"
        "Microsoft.Print3D"    
        "Microsoft.WindowsAlarms"
        "Microsoft.windowscommunicationsapps"        # Mail and Calender     
        "Microsoft.WindowsMaps"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.ZuneVideo"
        "Microsoft.YourPhone"
        "Microsoft.MSPaint"          # Paint & Paint3D
        "Microsoft.ZuneMusic"        # New Media Player in Windows

        # Xbox Apps
        # "Microsoft.Xbox.TCUI"
        # "Microsoft.XboxApp"
        # "Microsoft.XboxGameOverlay"
        # "Microsoft.XboxGamingOverlay"
        # "Microsoft.XboxIdentityProvider"
        # "Microsoft.XboxSpeechToTextOverlay"

        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.WindowsReadingList"

        # Redstone 5 apps
        "Microsoft.MixedReality.Portal"
        "Microsoft.Whiteboard"

        # non-Microsoft
        "4DF9E0F8.Netflix"
        "SpotifyAB.SpotifyMusic"
        "2FE3CB00.PicsArt-PhotoStudio"
        "46928bounde.EclipseManager"
        "613EBCEA.PolarrPhotoEditorAcademicEdition"
        "6Wunderkinder.Wunderlist"
        "7EE7776C.LinkedInforWindows"
        "89006A2E.AutodeskSketchBook"
        "9E2F88E3.Twitter"
        "A278AB0D.DisneyMagicKingdoms"
        "A278AB0D.MarchofEmpires"
        "ActiproSoftwareLLC.562882FEEB491"
        "CAF9E577.Plex"
        "ClearChannelRadioDigital.iHeartRadio"
        "D52A8D61.FarmVille2CountryEscape"
        "D5EA27B7.Duolingo-LearnLanguagesforFree"
        "DB6EA5DB.CyberLinkMediaSuiteEssentials"
        "DolbyLaboratories.DolbyAccess"
        "DolbyLaboratories.DolbyAccess"
        "Drawboard.DrawboardPDF"
        "Facebook.Facebook"
        "Fitbit.FitbitCoach"
        "Flipboard.Flipboard"
        "GAMELOFTSA.Asphalt8Airborne"
        "KeeperSecurityInc.Keeper"
        "NORDCURRENT.COOKINGFEVER"
        "PandoraMediaInc.29680B314EFC2"
        "Playtika.CaesarsSlotsFreeCasino"
        "ShazamEntertainmentLtd.Shazam"
        "SlingTVLLC.SlingTV"
        "TheNewYorkTimes.NYTCrossword"
        "ThumbmunkeysLtd.PhototasticCollage"
        "TuneIn.TuneInRadio"
        "WinZipComputing.WinZipUniversal"
        "XINGAG.XING"
        "flaregamesGmbH.RoyalRevolt2"
        "king.com.*"
        "king.com.BubbleWitch3Saga"
        "king.com.CandyCrushSaga"
        "king.com.CandyCrushSodaSaga"

        # CANNOT be reinstalled
        #   "Microsoft.WindowsStore"           # Windows Store

        # Apps which cannot be removed using Remove-AppxPackage
        #   "Microsoft.BioEnrollment"
        #   "Microsoft.WindowsFeedback"        # Feedback Module
        #   "Windows.ContactSupport"
    )

    Remove-UWPAppx -AppxPackages $Apps
}

Write-Host "Removing Bloatware Apps"
Remove-BloatwareAppsList
Write-Host "Removal complete"