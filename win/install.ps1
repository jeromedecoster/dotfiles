
Function Ok() { Write-Host 'OK' -f Green }
Function NotOk() { Write-Host 'KO' -f Red }

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

# check Ruby
Write-Host 'Check ruby...' -NoNewline
if ( ! (Get-Command 'ruby' 2> $null) -Or $(ruby -e "puts RUBY_VERSION >= '1.9.3'") -Eq 'false' ) {
    NotOk
    Write-Host 'Aborted: Ruby must be installed. Version 1.9.3 minimum'
    Sleep 1
    Browser 'http://rubyinstaller.org/'
    Exit 1
}
Ok

# update existing $HOME\.dotfiles repositoy or clone it first the first time
If ( Test-Path $HOME\.dotfiles -PathType Container ) {
    $cur = Get-Location
    Write-Host 'Update repository...' -NoNewline
    Set-Location $HOME\.dotfiles
    # capture error
    $error=$(git pull --quiet 2>&1)
    If ( $LASTEXITCODE -Ne 0 ) {
        NotOk
        Write-Host $error
        Write-Host 'Aborted: Error with git pull'
        Exit 1
    }
    Ok
} Else {
    Write-Host 'Clone repository...' -NoNewline
    # capture error
    $error=$(git clone --quiet https://github.com/jeromedecoster/dotfiles.git $HOME\.dotfiles 2>&1)
    If ( $LASTEXITCODE -Ne 0 ) {
        NotOk
        Write-Host $error
        Write-Host 'Aborted: Error with git pull'
        Exit 1
    }
    Ok
}

# create backup folder
$backup = "$HOME\.dotfiles\.backup\$(Get-Date -format yyyy-MM-dd--HH-mm-ss)"
New-Item -ItemType directory -Path $backup | Out-Null