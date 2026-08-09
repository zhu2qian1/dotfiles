# nvim
if (-not (Get-Command "nvim" -ErrorAction SilentlyContinue)) {
    return;
}

$env:NVIM_PROFILE='lite';
Set-Alias v nvim

function Set-Nvim-Profile($Mode, [switch] $NoOutput) {
    if ($Mode -imatch '^i.{0,2}$') {
        $env:NVIM_PROFILE='ide';
    } elseif ($Mode -imatch '^l.{0,3}$') {
        $env:NVIM_PROFILE='lite';
    } else {
        Write-Warning "Accepted values: '^i.{0,2}$',  '^l.{0,3}$'";
    }

    if (-not $NoOutput) {
        Write-Host "env:NVIM_PROFILE=$env:NVIM_PROFILE";
    }

    return;
}
Set-Alias snp Set-Nvim-Profile

function Start-Nvim-Ide  { Set-Nvim-Profile ide -NoOutput;  nvim $Args }
Set-Alias vide Start-Nvim-Ide

function Start-Nvim-Lite { Set-Nvim-Profile lite -NoOutput; nvim $Args }
Set-Alias vli Start-Nvim-Lite
