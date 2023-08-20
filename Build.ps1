param (
    [Parameter(Mandatory=$false)][string][Alias("Source-Image","si")]$src_img = "mcr.microsoft.com/dotnet/framework/sdk",
    [Parameter(Mandatory=$false)][string][Alias("Source-Tag","st")]$src_tag = "4.8-windowsservercore-ltsc2022",
    [Parameter(Mandatory=$false)][string][Alias("Destination-Image","di")]$dest_img = "dotnetframeworksdkfonts",
    [Parameter(Mandatory=$false)][string][Alias("Destination-Tag","dt")]$dest_tag = $src_tag,
    [Parameter(Mandatory=$false)][switch][Alias("Update-WinSxS","u")]$update_winsxs
)

$winsxs = "${pwd}\WindowsSource\"
If (!(test-path $winsxs))
{
    mkdir $winsxs
    $update_winsxs = $true
}

If ($update_winsxs) {
    Invoke-Expression "docker run --rm -v $($winsxs):C:\WindowsSource\ mcr.microsoft.com/windows/server:ltsc2022 Robocopy C:\Windows\WinSXS\ C:\WindowsSource\ /MIR"
}

if ($dest_tag -eq $null) {
    $dest_tag = $src_tag
}

if (Test-Path ".\tmp_container.txt") {
    Remove-Item ".\tmp_container.txt"
}
Invoke-Expression "docker run --cidfile tmp_container.txt -v $($winsxs):C:\WindowsSource\:ro -v ${pwd}\Install:C:\Install:ro --entrypoint C:\Install\InstallFonts.cmd $($src_img):$($src_tag) c:\windows\system32\cmd.exe"
$tmp_container = Get-Content .\tmp_container.txt -Raw
#Invoke-Expression "docker wait `"$($tmp_container)`""
Invoke-Expression "docker commit --change `"ENTRYPOINT []`" `"$($tmp_container)`" tmp_container:temp" #`"$($dest_img)`:$($dest_tag)`""
Invoke-Expression "docker rm `"$($tmp_container)`""
Remove-Item ".\tmp_container.txt"

Invoke-Expression "docker build -t `"$($dest_img)`:$($dest_tag)`" CleanImage"
Invoke-Expression "docker image rm tmp_container:temp"