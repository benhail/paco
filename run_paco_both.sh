#!/usr/bin/env bash
set -euo pipefail

# 1) Arranca simulador iOS (si no está corriendo)
open -a Simulator || true

# 2) Arranca el emulador Android (ajusta el nombre si usas otro AVD)
emu_name="Pixel_7_API_35"
if ! pgrep -f "qemu-system" >/dev/null; then
  emulator -avd "$emu_name" >/dev/null 2>&1 &
  echo "Launching Android emulator: $emu_name"
  # Espera a que ADB lo vea como 'device'
  adb start-server >/dev/null 2>&1 || true
  printf "Waiting for Android emulator"; 
  until adb devices | grep -q "emulator-"; do
    printf "."; sleep 1;
  done
  echo ""
fi

# 3) Ejecuta Paco en TODOS los dispositivos abiertos (iOS + Android)
cd "$(dirname "$0")/paco"
flutter run -d all
