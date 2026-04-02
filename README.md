# Windows Server Core container with fonts

This repo contains build scripts to create a docker image from an existing Windows Server Core docker image that adds the fonts features that are normally missing.

This allows adding them to images like `mcr.microsoft.com/dotnet/framework/sdk` which then allow things like Playwright to work correctly (at least chromium does).

This is an alternative technique to that used in [CZEMacLeod/PlaywrightWindowsServerCore2022:chromium](https://github.com/CZEMacLeod/PlaywrightWindowsServerCore2022/tree/browser-chromium) 
although it is based on the same technique to download the missing server files.

Simply run `Build.ps1` making sure you have a lot of disk space ;)

The source and destination images are just shy of 8Gb (although the latter should only be about +500MB in the layer).
The WinSxS cache is ~5.8GB, and the cache source image is another ~7.6GB.
The cache is created if it does not exist, and will be updated if you pass in the -u flag to `Build.ps1`

Other parameters you can pass are

| parameter | alias | description | default |
|-----------|-------|-------------|---------|
| src_img | -si | The source image (including source repository) you want to use for the basis of the image | mcr.microsoft.com/dotnet/framework/sdk |
| src_tag | -st | The source tag you want to use | 4.8-windowsservercore-ltsc2022 |
| dest_img | -di | The destination image name (can incllude a repository name, but it won't automatically push) | dotnetframeworksdkfonts |
| dest_tag | -dt | The destination tag name | *Same as `src_tag`* |

The DISM font install approach is loosely based on the technique described in [Adding optional font packages to Windows containers](https://techcommunity.microsoft.com/t5/itops-talk-blog/adding-optional-font-packages-to-windows-containers/ba-p/3559761).
That requires that the user has admin rights to create a temp share, however this technique does not have this requirement as it uses volume mounts and does not add any additional bloat of install files and other layers.

