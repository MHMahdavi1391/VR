# LTC VR

**Publisher:** Lumen Technologies Co.  
**Author:** Mohammad Hosein Mahdavi ([@MHMahdavi1391](https://github.com/MHMahdavi1391))  
**License:** MIT — see [LICENSE](LICENSE)  
**Company site:** [https://LT-C.iddns.ir](https://LT-C.iddns.ir)  
**Hub shortcut:** [https://LT-C.iddns.ir/VR](https://LT-C.iddns.ir/VR)  
**This website:** [https://mhmahdavi1391.github.io/VR/](https://mhmahdavi1391.github.io/VR/)

---

## English

Public home for Lumen Technologies Co. VR files, VR services, and the **LTC Quest Helper** Windows tool.

### What this repository is
- A GitHub Pages site (black / yellow company theme, English / Russian / Persian).
- A download list. Anything you upload into `files/` appears on the site automatically.
- A place for source code. Put program code in `src/`.

### Live links
| What | URL |
| --- | --- |
| Company hub | https://LT-C.iddns.ir |
| VR shortcut on the hub | https://LT-C.iddns.ir/VR |
| VR site (this repo) | https://mhmahdavi1391.github.io/VR/ |
| Company site | https://LT-C.iddns.ir |

`LT-C.iddns.ir/VR` is a short page in the `center` hub. It opens this GitHub Pages site in a new tab.

### Folder layout
```
VR/
  index.html          site page
  styles.css          site theme
  app.js              language switch + file list
  files/              zip / rar packages for download
  src/                source code of tools (add your code here)
  LICENSE             MIT license
  CREDITS.md          third-party credits
  README.md           this file
```

### How to publish a download
1. Upload a `.zip` or `.rar` into `files/`.
2. Wait a few seconds.
3. The homepage lists the name, size, and a Download button.
4. `files/README.txt` is hidden from the public list on purpose.

### LTC Quest Helper
Windows helper for **Meta Quest** and other **Android / ADB** devices. No Python install. Run:

```
START-LTC-Quest-Helper.bat
```

Put the program files next to official Google `adb.exe` (platform-tools).

Optional `logo.png` or `logo.ico` in the same folder is used on the splash screen and the Windows taskbar.

Main features:
- device list, USB and Wi-Fi ADB
- status lamp (disconnected / need permission / connected / Wi-Fi)
- battery, storage (MB), model, Android version
- install APK, copy OBB / Data to standard Android paths
- backup: one correct `.apk` plus a side folder for OBB/Data when they exist
- ADB file manager
- Android Settings, date/time, MTP, ADB reset, key revoke
- UI languages: Persian, English, Russian

Need:
- USB debugging on the device
- official [platform-tools](https://developer.android.com/tools/releases/platform-tools)
- a working cable or wireless ADB

### Enable GitHub Pages
Repository Settings → Pages → Deploy from a branch → `main` → `/ (root)`.

### License and credits
Code and site files in this repository are released under the **MIT License**.  
Copyright © 2026 Lumen Technologies Co.

Android Debug Bridge belongs to Google. Windows and PowerShell belong to Microsoft. Meta Quest is a trademark of Meta. See [CREDITS.md](CREDITS.md).

This project is not affiliated with Google or Meta.

---

## فارسی

خانه‌ی عمومی فایل‌ها و خدمات VR شرکت **Lumen Technologies Co.** و ابزار ویندوز **LTC Quest Helper**.

### این ریپو چیست
- سایت GitHub Pages با تم مشکی و زرد شرکت، سه‌زبانه.
- لیست دانلود. هر فایلی که در `files/` بگذارید روی سایت نمایش داده می‌شود.
- جای کد منبع. کدها را در `src/` بگذارید.

### لینک‌ها
| مورد | آدرس |
| --- | --- |
| هاب شرکت | https://LT-C.iddns.ir |
| مسیر کوتاه VR | https://LT-C.iddns.ir/VR |
| سایت همین ریپو | https://mhmahdavi1391.github.io/VR/ |

`LT-C.iddns.ir/VR` صفحه کوتاه ریپوی `center` است و این سایت را در تب جدید باز می‌کند.

### چیدمان پوشه‌ها
```
VR/
  index.html          صفحه سایت
  styles.css          تم
  app.js              زبان و لیست فایل
  files/              بسته‌های قابل دانلود
  src/                کد منبع ابزارها
  LICENSE             مجوز MIT
  CREDITS.md          اعتبارها
  README.md           همین فایل
```

### منتشر فایل برای دانلود
1. فایل `.zip` یا `.rar` را در `files/` بگذارید.
2. چند ثانیه صبر کنید.
3. سایت اسم، حجم و دکمه دانلود را نشان می‌دهد.

### LTC Quest Helper
برنامه ویندوز برای هدست **Meta Quest** و سایر دستگاه‌های اندروید / ADB. پایتون نمی‌خواهد. فایل اجرا:

```
START-LTC-Quest-Helper.bat
```

فایل‌ها را کنار `adb.exe` رسمی گوگل بگذارید.

### مجوز و اعتبار
کد و فایل‌های سایت تحت **مجوز MIT** هستند.  
حق نشر © ۲۰۲۶ Lumen Technologies Co.

ADB مال گوگل است. Windows و PowerShell مال مایکروسافتند. Meta Quest علامت تجاری Meta است. جزئیات: [CREDITS.md](CREDITS.md).

این پروژه وابسته به گوگل یا Meta نیست.

---

## Русский

Публичный репозиторий VR-файлов и сервисов **Lumen Technologies Co.** и инструмента Windows **LTC Quest Helper**.

### Что это
- Сайт GitHub Pages (чёрно-жёлтая тема компании, EN / RU / FA).
- Список загрузок. Файлы из `files/` появляются на сайте.
- Исходный код кладите в `src/`.

### Ссылки
| Назначение | URL |
| --- | --- |
| Хаб компании | https://LT-C.iddns.ir |
| Короткий вход VR | https://LT-C.iddns.ir/VR |
| Сайт этого репозитория | https://mhmahdavi1391.github.io/VR/ |

### Лицензия
Код и файлы сайта — **MIT**.  
Copyright © 2026 Lumen Technologies Co.

ADB — Google. Windows / PowerShell — Microsoft. Meta Quest — товарный знак Meta. Подробнее: [CREDITS.md](CREDITS.md).

Проект не связан с Google или Meta.
