ARG WINDOWS_VERSION=ltsc2022
FROM mcr.microsoft.com/windows/servercore:${WINDOWS_VERSION}

COPY .ci/msys2.exe C:/diagnostics/msys2.exe
COPY .ci/diagnose-home.ps1 .ci/home-probe.sh C:/diagnostics/

RUN powershell -NoProfile -ExecutionPolicy Bypass -File C:/diagnostics/diagnose-home.ps1
