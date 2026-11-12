#!/bin/bash
cd "$(dirname "$0")" || exit 1
echo "Notch Media Island — Kur ve aç / Install and open"
echo "İlk hazırlık birkaç dakika sürebilir / First build may take a few minutes."
echo ""
bash scripts/check-requirements.sh
CHECK_RESULT=$?
if [[ "$CHECK_RESULT" == 2 ]]; then
  read -r -p "Apple araçları için kurulum penceresi açılsın mı? / Open Apple tools installer? [y/N] " ANSWER
  if [[ "$ANSWER" == y || "$ANSWER" == Y ]]; then
    xcode-select --install
  fi
  echo "Apple kurulumu bittikten sonra bu dosyayı tekrar açın / Reopen this file after Apple installation finishes."
  read -r -p "Kapatmak için Enter / Press Return to close... " _
  exit 2
elif [[ "$CHECK_RESULT" != 0 ]]; then
  read -r -p "Kapatmak için Enter / Press Return to close... " _
  exit "$CHECK_RESULT"
fi
if bash scripts/install.sh; then
  echo "Hazır! Çentiğin üzerine gelin / Ready! Hover over the notch."
  echo "Bundan sonra Finder > Ev > Applications içinden açabilirsiniz."
  echo "Next time, open Notch Media Island from your home folder's Applications folder."
else
  echo "Kurulum tamamlanamadı. Yukarıdaki mesajı ve docs/GETTING_STARTED.tr.md dosyasını kontrol edin."
  echo "Setup failed. Check the message above and docs/GETTING_STARTED.md."
  read -r -p "Kapatmak için Enter / Press Return to close... " _
  exit 1
fi
read -r -p "Bu pencereyi kapatabilirsiniz / Press Return to close this window... " _
