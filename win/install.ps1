
Function Ok() { Write-Host 'OK' -f Green }
Function NotOk() { Write-Host 'kO' -f Red }

Function Browser() {
    Param( [String] $url )
    If ( Test-Path $HOME\AppData\Local\Google\Chrome\Application\chrome.exe -PathType Leaf ) {
        Start-Process "chrome.exe" $url
    } ElseIf ( Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe" -PathType Leaf ) {
        Start-Process "firefox.exe" $url
    } ElseIf ( Test-Path "${env:ProgramFiles}\Internet Explorer\iexplore.exe" -PathType Leaf ) {
        Start-Process "iexplore.exe" $url
    }
}

# check Git
Write-Host 'Check git...' -NoNewline
if ( ! (Get-Command 'git' 2> $null) ) {
    NotOk
    Write-Host 'Aborted: Git must be installed'
    Sleep 1
    Browser 'http://code.google.com/p/msysgit/downloads/list'
    Exit 1
}
Ok