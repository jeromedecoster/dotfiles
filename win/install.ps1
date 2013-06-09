
# write in yellow has a special behavior, will try to reduce path
# from C:\Users\JER\.dotfiles to ~\.dotfiles
Function Yellow() {
    Param( [String] $path )
    If ( $path.StartsWith($Home) ) {
        Write-Host "~$(($path).Substring($Home.Length))" -f Yellow
    }
    Else {
        Write-Host "$path" -f Yellow
    }
}

Function Ok() { Write-Host 'OK' -f Green }
Function NotOk() { Write-Host 'KO' -f Red }

# check if a folder is empty
# if yes, return True, otherwise return False
Function Empty() {
    Param( [String] $folder )
    If ( $folder.Length -Eq 0 -Or
         ! (Test-Path $folder -PathType Container) ) {
        Write-Host "Runtime error: Empty require 1 valid path"
        Exit 1
    }
    $cnt = 0
    $files = Get-ChildItem $folder
    ForEach ($f in $files) {
        If ( $f.Name.Length ) {
            $cnt += 1
        }
    }
    return ($cnt -Eq 0)
}

Function Browser() {
    Param( [String] $url )
    If ( Test-Path $HOME\AppData\Local\Google\Chrome\Application\chrome.exe -PathType Leaf ) {
        Start-Process "chrome.exe" $url
    }
    ElseIf ( Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe" -PathType Leaf ) {
        Start-Process "firefox.exe" $url
    }
    ElseIf ( Test-Path "${env:ProgramFiles}\Internet Explorer\iexplore.exe" -PathType Leaf ) {
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
if ( ! (Get-Command 'ruby' 2> $null) -Or
     $(ruby -e "puts RUBY_VERSION >= '1.9.3'") -Eq 'false' ) {
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
}
Else {
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

Function CopyFiles() {
    Param( [String] $from, [String] $to, [String] $backup )
    If ( $from.Length -Eq 0 -Or
         ! (Test-Path $from -PathType Container) -Or
         $to.Length -Eq 0 -Or
         ! (Test-Path $to -PathType Container) -Or
         $backup.Length -Eq 0 -Or
         ! (Test-Path $backup -PathType Container) ) {
        Write-Host "Runtime error: CopyFiles require 3 valid paths"
        Exit 1
    }
    $files = Get-ChildItem $from | Select-Object Name,Fullname
    ForEach ($f in $files) {
        $dest = "$to\$($f.Name)"
        If ( Test-Path $dest -PathType Leaf ) {
            Move-Item $dest $backup -Force
            Copy-Item $f.Fullname $to
            Write-Host "Backup then overwrite " -NoNewline
            Yellow $dest
        }
        Else {
            Copy-Item $f.Fullname $to
            Write-Host "Add " -NoNewline
            Yellow $dest
        }
    }
}

# copy files from ~\.dotfiles\win\user folder to ~ and
# backup already existing files to the backup folder
CopyFiles $Home\.dotfiles\win\user\ $Home $backup

# removes some folders if stayed empty
If ( Empty $backup ) {
    Write-Host "Delete empty folder " -NoNewline
    Yellow $backup
    Remove-Item -Recurse -Force $backup
}
If ( Empty $HOME\.dotfiles\.backup ) {
    Write-Host "Delete empty folder " -NoNewline
    Yellow $HOME\.dotfiles\.backup
    Remove-Item -Recurse -Force $HOME\.dotfiles\.backup
}