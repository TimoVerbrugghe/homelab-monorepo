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
        # default Windows 10 apps
        "Microsoft.OneDriveSync"
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
        "Microsoft.windowscommunicationsapps"  
        "Microsoft.WindowsMaps"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.ZuneVideo"
        "Microsoft.YourPhone"
        "Microsoft.MSPaint"
        "Microsoft.ZuneMusic"
        "Microsoft.3DBuilder"
        "Microsoft.549981C3F5F10"
        "Microsoft.Appconnector"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingTravel"
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MixedReality.Portal"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.Todos"
        "Microsoft.Whiteboard"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        #"Microsoft.MicrosoftEdge"
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsCamera"
        "Microsoft.ScreenSketch"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.Windows.Photos"

        # Default Windows 11 apps
        "Clipchamp.Clipchamp"
        "MicrosoftWindows.Client.WebExperience"
        "MicrosoftTeams*"
        "Microsoft.PowerAutomateDesktop"

        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"
        "Microsoft.Paint*"
        "MicrosoftCorporationII.QuickAssist*"

        # 3rd party Apps
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"
        "*Amazon.com.Amazon*"
        "*Asphalt8Airborne*"
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"
        "*EclipseManager*"
        "*Facebook*"
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"
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
        "*Plex*"
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"
        "*Shazam*"
        "*Sidia.LiveWallpaper*"
        "*SlingTV*"
        "*Speed Test*"
        "*Sway*"
        "*TuneInRadio*"
        "*Twitter*"
        "*Viber*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
        "*Netflix*"
        "*Spotify*"
        "*Amazon*"

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
        
        # Xbox Apps
        # "Microsoft.Xbox.TCUI"
        # "Microsoft.XboxApp"
        # "Microsoft.XboxGameOverlay"
        # "Microsoft.XboxGamingOverlay"
        # "Microsoft.XboxIdentityProvider"
        # "Microsoft.XboxSpeechToTextOverlay"
    )

    Remove-UWPAppx -AppxPackages $Apps

}

function Test-RegistryValue {

    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]$Path,
    
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]$Setting
    )
    
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Setting -ErrorAction Stop | Out-Null
        return $true
    }
    
    catch {
        return $false
    }
    
}
    
function Set-Registry-Setting {
    param (
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Setting,
        [Parameter(Mandatory)] [int] $Value
    )

    # Check if the Path in the Registry exists
    if (Test-Path $Path) {

        if (Test-RegistryValue $Path $Setting) {
            # If the setting exists, set its value
            Set-ItemProperty -Path $Path -Name $Setting -Value $Value -Force
        }
        Else {
            # If the setting doesn't exist, create it
            New-ItemProperty -Path $Path -Name $Setting -Value $Value -Force
        }
    }
    Else {
        # If the Path doesn't exist, then the setting also doesn't exist, so create both (using Force to create any subpaths as well) 
        New-Item -Path $Path -Force
        New-ItemProperty -Path $Path -Name $Setting -Value $Value -Force
    }

}

function Disable-ContentDeliveryManager() {
    $ContentDeliveryManagerSettings= @(
        "SubscribedContent-310093Enabled"
        "SubscribedContent-314559Enabled"
        "SubscribedContent-314563Enabled"
        "SubscribedContent-338387Enabled"
        "SubscribedContent-338388Enabled"
        "SubscribedContent-338389Enabled"
        "SubscribedContent-338393Enabled"
        "SubscribedContent-353698Enabled"
        "RotatingLockScreenOverlayEnabled"
        "RotatingLockScreenEnabled"

        # Prevents Apps from re-installing
        "ContentDeliveryAllowed"
        "FeatureManagementEnabled"
        "OemPreInstalledAppsEnabled"
        "PreInstalledAppsEnabled"
        "PreInstalledAppsEverEnabled"
        "RemediationRequired"
        "SilentInstalledAppsEnabled"
        "SoftLandingEnabled"
        "SubscribedContentEnabled"
        "SystemPaneSuggestionsEnabled"
    )

    $Path="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $Value=0

    ForEach ($Setting in $ContentDeliveryManagerSettings) {
        Write-Host "Disabling $Setting"
        Set-Registry-Setting $Path $Setting $Value
    }    
}

function Disable-CloudContent() {
    $CloudContentSettings= @(
        "DisableWindowsConsumerFeatures"
        "DisableConsumerAccountStateContent"
        "DisableSoftLanding"
        "DisableCloudOptimizedContent"
    )

    $Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $Value=1

    ForEach ($Setting in $CloudContentSettings) {
        Write-Host "Enabling $Setting"
        Set-Registry-Setting $Path $Setting $Value
    }
    
    $CloudContentSettingsUser = @(
        "DisableWindowsSpotlightWindowsWelcomeExperience"
        "DisableWindowsSpotlightOnSettings"
        "DisableWindowsSpotlightOnActionCenter"
        "DisableThirdPartySuggestions"
        "DisableSpotlightCollectionOnDesktop"
        "DisableTailoredExperiencesWithDiagnosticData"
        "DisableWindowsSpotlightFeatures"
    )
    $Path="HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $Value=1

    ForEach ($Setting in $CloudContentSettingsUser) {
        Set-Registry-Setting $Path $Setting $Value
    }

    $Setting="ConfigureWindowsSpotlight"
    $Value=2
    Set-Registry-Setting $Path $Setting $Value

    $Setting="IncludeEnterpriseSpotlight"
    $Value=0
    Set-Registry-Setting $Path $Setting $Value
}

Write-Host "Removing Bloatware Apps"
Remove-BloatwareAppsList

Write-Host "Disabling Cloud Content"
Disable-CloudContent

Write-Host "Disabling Content Delivery Manager"
Disable-ContentDeliveryManager