#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
[Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

$script:Root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $script:Root) { $script:Root = (Get-Location).Path }
$script:AdbPath = Join-Path $script:Root "adb.exe"
$script:CfgPath = Join-Path $script:Root "quest-adb-config.json"
$script:Serial = ""
$script:Busy = $false
$script:DevState = ""
$script:LampMode = "none"
$script:RemotePath = "/sdcard"
$script:Lang = "fa"
$script:InfoTimer = $null

$Y = [Drawing.Color]::FromArgb(180, 130, 0)
$Yd = [Drawing.Color]::FromArgb(140, 100, 0)
$Bg = [Drawing.Color]::FromArgb(255, 255, 255)
$Bg2 = [Drawing.Color]::FromArgb(250, 250, 250)
$Bg3 = [Drawing.Color]::FromArgb(245, 245, 245)
$Tx = [Drawing.Color]::FromArgb(15, 15, 15)
$Muted = [Drawing.Color]::FromArgb(60, 60, 60)
$ErrC = [Drawing.Color]::FromArgb(160, 0, 0)
$OkC = [Drawing.Color]::FromArgb(0, 110, 40)
$CmdC = [Drawing.Color]::FromArgb(80, 80, 80)

$I18N = @{
fa = @{
app="LTC Quest Helper"; lang="زبان"; device="دستگاه‌ها"; refresh="بروزرسانی"
ready="آماده"; noadb="adb.exe کنار برنامه نیست"; nodev="دستگاهی پیدا نشد"
busy="یک کار در حال اجرا است"; ok="انجام شد"; err="خطا"; confirm="تأیید"
cancel="انصراف"; tabDev="دستگاه"; tabApps="برنامه‌ها"; tabFiles="فایل‌ها"; tabTools="ابزار"
infoTitle="وضعیت دستگاه"; battery="باتری"; wifi="وای‌فای"; storage="حافظه"
model="مدل"; android="اندروید"; serial="سریال"; usb="USB"; ip="IP"
connected="وصل"; disconnected="قطع"; charging="در حال شارژ"; unknown="نامشخص"
used="پر شده"; free="خالی"; total="کل"; refreshInfo="خواندن وضعیت"
wake="بیدار کردن دستگاه"; stayOn="روشن‌ماندن هنگام شارژ"
installApk="نصب APK"; installObb="نصب APK + کپی OBB"; copyData="کپی پوشه Data"
copyObb="کپی پوشه OBB"; listApps="لیست برنامه‌های کاربر"; extractApp="استخراج برنامه"
backupApp="بکاپ APK + OBB + Data"; uninstall="حذف برنامه"; launch="اجرای برنامه"
openSettings="باز کردن Settings اندروید"; openDate="تنظیمات تاریخ و ساعت"
openDev="تنظیمات توسعه‌دهنده"; setTime="ست کردن ساعت از رایانه"
fmTitle="مدیر فایل ADB"; up="پوشه بالاتر"; go="رفتن"; mkdir="پوشه جدید"
pushFile="ارسال فایل"; pushFolder="ارسال پوشه"; pullSel="دانلود انتخاب‌شده"
delSel="حذف انتخاب‌شده"; path="مسیر"; name="نام"; type="نوع"; folder="پوشه"; file="فایل"
mtp="وصل به‌صورت حافظه (MTP)"; adbReset="ریست ADB روی رایانه"
revokeKeys="حذف کلیدهای ADB رایانه"; tryDeviceKeys="تلاش برای حذف کلید روی دستگاه"
wifiAdb="ADB روی وای‌فای :5555"; connect="اتصال بی‌سیم"; disconnect="قطع بی‌سیم"
reboot="ریستارت دستگاه"; recovery="رفتن به Recovery"; shot="اسکرین‌شات"
custom="دستور سفارشی"; log="خروجی"; clear="پاک کردن خروجی"
pickApk="فایل APK را انتخاب کنید"; pickFolder="پوشه را انتخاب کنید"
pkgPrompt="نام بسته را بنویسید مثل com.company.app"
pkgInvalid="نام بسته درست نیست"
askInstall="نصب شود؟"; askUninstall="حذف شود؟"; askDel="حذف شود؟ این کار برگشت ندارد."
askReboot="دستگاه ریستارت شود؟"; askRec="رفتن به Recovery فقط اگر می‌دانید چیست."
askKeys="کلیدهای ADB همین رایانه پاک شود؟ بعد باید دوباره روی دستگاه Allow بزنید."
askMtp="حالت MTP روشن شود؟ ممکن است اتصال ADB تا یک لحظه قطع شود."
askTime="ساعت دستگاه با ساعت همین رایانه یکی شود؟"
copied="کپی شد"; saved="ذخیره شد"; enterName="نام را بنویسید"
noSel="چیزی انتخاب نشده"; doneInfo="وضعیت به‌روز شد"
hintDev="Developer Mode و USB Debugging باید روشن باشد. دستگاه را بیدار کنید و اجازه دیباگ را تأیید کنید."
hintFiles="جابجایی فایل با خود ADB است تا به MTP خراب وابسته نباشد."
hintApps="OBB باید به Android/obb/نام‌بسته و Data به Android/data/نام‌بسته برود."
hintTools="حذف کلید روی خود دستگاه بدون ریشه معمولاً ناموفق است؛ کلید رایانه پاک می‌شود."
wifiOn="وای‌فای روشن / وصل"; wifiOff="وای‌فای قطع یا بدون IP"
company="Lumen Technologies Co."
site="LT-C.iddns.ir"
appMgr="برنامه‌های دستگاه"
loadNames="خواندن نام نمایشی"
doUninstall="حذف انتخاب‌شده"
doExtract="استخراج APK"
doBackup="بکاپ"
doLaunch="اجرا"
doData="کپی Data روی این بسته"
doObb="کپی OBB روی این بسته"
close="بستن"
selPkg="یک برنامه را از لیست انتخاب کنید"
paths="مسیر استاندارد Meta: /sdcard/Android/obb/PACKAGE و /sdcard/Android/data/PACKAGE"
connNo="متصل نیست"
connAuth="نیاز به تایید مجوز"
connOk="متصل"
connWifi="متصل (وای‌فای)"
installHere="نصب روی دستگاه"
legend="راهنمای رنگ"
lgDir="پوشه"
lgApk="APK"
lgObb="OBB"
lgZip="فشرده zip/rar/7z"
lgImg="عکس"
lgVid="ویدیو"
lgAud="صدا"
lgTxt="متن / لاگ"
lgOther="سایر فایل‌ها"
grpInstall="نصب و داده"
grpManage="مدیریت برنامه‌ها"
grpSettings="تنظیمات اندروید"
grpConn="اتصال و ADB"
grpPower="دستگاه"
tabHelp="راهنما"
helpTitle="چطور کار می‌کند"
helpBody="۱) دستگاه را با کابل بزنید و USB Debugging را روشن کنید.\r\n۲) در لیست بالا دستگاه را انتخاب کنید. چراغ سبز یعنی وصل است.\r\n۳) نارنجی یعنی روی دستگاه Allow را بزنید.\r\n۴) تب برنامه‌ها فقط نصب و کپی فایل است. مدیریت حذف و بکاپ داخل پنجره لیست برنامه‌هاست.\r\n۵) اگر پنجره‌ای را ببندید یا Cancel بزنید، هیچ کاری انجام نمی‌شود.\r\n۶) فایل‌منیجر فقط بعد از انتخاب دستگاه فایل نشان می‌دهد.\r\n۷) بکاپ یک فایل APK می‌دهد. اگر OBB یا Data باشد کنارش یک پوشه ساخته می‌شود."
pickTitle="انتخاب برنامه"
pickHint="یک مورد را انتخاب کنید، بعد تأیید. بستن پنجره یعنی لغو."
cancelAction="لغو شد"
exitApp="خروج کامل"
tipRef="لیست دستگاه را دوباره بخوان"
tipDiag="خروجی خام ADB برای عیب‌یابی"
tipForce="بستن adb و شروع دوباره"
tipInfo="مدل، باتری، وای‌فای و حافظه"
tipWake="بیدار کردن صفحه دستگاه"
tipApk="نصب یک فایل APK از رایانه"
tipApkObb="نصب APK و کپی OBB در مسیر استاندارد"
tipData="فرستادن پوشه Data از رایانه به دستگاه"
tipObb="فرستادن پوشه OBB از رایانه به دستگاه"
tipList="لیست برنامه‌ها برای بکاپ کامل، حذف یا اجرا"
tipGo="رفتن به این مسیر"
tipUp="پوشه بالاتر"
tipMk="ساختن پوشه روی دستگاه"
tipPushF="فرستادن فایل از رایانه"
tipPushD="فرستادن پوشه از رایانه"
tipPull="دانلود مورد انتخاب‌شده"
tipRm="حذف مورد انتخاب‌شده از دستگاه"
tipInstApk="نصب همین APK که روی دستگاه است"
tipSet="Settings اصلی اندروید"
tipDate="صفحه تاریخ و ساعت"
tipDevSet="گزینه‌های توسعه‌دهنده"
tipTime="ساعت دستگاه = ساعت رایانه"
tipMtp="دستگاه به‌صورت حافظه"
tipAdbR="ریست سرور ADB روی رایانه"
tipKeys="پاک کردن کلید ADB همین رایانه"
tipDevKeys="تلاش برای پاک کردن کلید روی دستگاه"
tipTcp="ADB روی پورت 5555 وای‌فای"
tipConn="اتصال بی‌سیم با IP:PORT"
tipDisc="قطع اتصال بی‌سیم"
tipReboot="ریستارت دستگاه"
tipRec="رفتن به Recovery"
tipShot="عکس از صفحه دستگاه"
tipCustom="یک دستور ADB سفارشی"
tipListDev="دستگاه فعال را از این لیست انتخاب کنید"
tipLang="زبان برنامه"

scrcpy="پخش زنده (scrcpy)"
cropMode="برش تصویر"
cropFull="تمام‌صفحه (گوشی)"
cropLeft="چشم چپ"
cropRight="چشم راست"
cropLand="مستطیل افقی"
cropSq="مربع"
noScrcpy="scrcpy.exe کنار برنامه یا در PATH پیدا نشد"
diag="عیب‌یابی اتصال"
force="کشن همه ADB و اتصال دوباره"
unauthorized="دستگاه در لیست است ولی مجوز ندارد. روی دستگاه Allow بزن."
offline="دستگاه offline است. کابل یا خواب رفتن را چک کن."
rawOut="خروجی خام adb"
} 
en = @{
app="LTC Quest Helper"; lang="Language"; device="Devices"; refresh="Refresh"
ready="Ready"; noadb="adb.exe not found next to this app"; nodev="No device found"
busy="A task is still running"; ok="Done"; err="Error"; confirm="OK"
cancel="Cancel"; tabDev="Device"; tabApps="Apps"; tabFiles="Files"; tabTools="Tools"
infoTitle="Device status"; battery="Battery"; wifi="Wi-Fi"; storage="Storage"
model="Model"; android="Android"; serial="Serial"; usb="USB"; ip="IP"
connected="Connected"; disconnected="Disconnected"; charging="Charging"; unknown="Unknown"
used="Used"; free="Free"; total="Total"; refreshInfo="Read status"
wake="Wake device"; stayOn="Stay awake while charging"
installApk="Install APK"; installObb="Install APK + copy OBB"; copyData="Copy Data folder"
copyObb="Copy OBB folder"; listApps="List user apps"; extractApp="Extract app APK"
backupApp="Backup APK + OBB + Data"; uninstall="Uninstall app"; launch="Launch app"
openSettings="Open Android Settings"; openDate="Date and time settings"
openDev="Developer settings"; setTime="Set time from this PC"
fmTitle="ADB file manager"; up="Up"; go="Go"; mkdir="New folder"
pushFile="Push file"; pushFolder="Push folder"; pullSel="Pull selected"
delSel="Delete selected"; path="Path"; name="Name"; type="Type"; folder="Folder"; file="File"
mtp="Mount as drive (MTP)"; adbReset="Reset ADB on PC"
revokeKeys="Delete PC ADB keys"; tryDeviceKeys="Try deleting keys on device"
wifiAdb="Wi-Fi ADB :5555"; connect="Wireless connect"; disconnect="Disconnect wireless"
reboot="Reboot device"; recovery="Reboot Recovery"; shot="Screenshot"
custom="Custom command"; log="Output"; clear="Clear output"
pickApk="Choose an APK file"; pickFolder="Choose a folder"
pkgPrompt="Enter package name, for example com.company.app"
pkgInvalid="Invalid package name"
askInstall="Install this file?"; askUninstall="Uninstall this package?"
askDel="Delete this? It cannot be undone."; askReboot="Reboot the device now?"
askRec="Recovery is only for users who know that screen."
askKeys="Delete ADB keys of this PC? You must tap Allow on the device again."
askMtp="Enable MTP? ADB may drop for a moment."
askTime="Set device clock from this computer?"
copied="Copied"; saved="Saved"; enterName="Enter a name"
noSel="Nothing selected"; doneInfo="Status updated"
hintDev="Turn on Developer Mode and USB Debugging. Wake the device and accept the USB debug prompt."
hintFiles="Transfers use ADB so a broken MTP file manager is not required."
hintApps="OBB goes to Android/obb/package and Data goes to Android/data/package."
hintTools="Deleting keys on the device usually needs root. This mainly clears PC keys."
wifiOn="Wi-Fi on / has IP"; wifiOff="Wi-Fi off or no IP"
company="Lumen Technologies Co."
site="LT-C.iddns.ir"
appMgr="Device apps"
loadNames="Load display names"
doUninstall="Uninstall selected"
doExtract="Extract APK"
doBackup="Backup"
doLaunch="Launch"
doData="Copy Data into this package"
doObb="Copy OBB into this package"
close="Close"
selPkg="Select an app from the list"
paths="Meta standard paths: /sdcard/Android/obb/PACKAGE and /sdcard/Android/data/PACKAGE"
connNo="Not connected"
connAuth="Needs authorization"
connOk="Connected"
connWifi="Connected (Wi-Fi)"
installHere="Install on device"
legend="Color guide"
lgDir="Folder"
lgApk="APK"
lgObb="OBB"
lgZip="Archive zip/rar/7z"
lgImg="Image"
lgVid="Video"
lgAud="Audio"
lgTxt="Text / log"
lgOther="Other files"
grpInstall="Install and data"
grpManage="App manager"
grpSettings="Android settings"
grpConn="Connection and ADB"
grpPower="Device"
tabHelp="Help"
helpTitle="How it works"
helpBody="1) Plug the device in and turn on USB Debugging.\r\n2) Select it in the list. Green means connected.\r\n3) Orange means tap Allow on the device.\r\n4) The Apps tab is for install and copy. Uninstall and backup live in the app list window.\r\n5) Closing a window or pressing Cancel stops the action.\r\n6) The file manager lists files only after a device is selected.\r\n7) Backup saves one APK. OBB/Data go into a folder next to it."
pickTitle="Select an app"
pickHint="Select one item, then confirm. Closing the window cancels."
cancelAction="Cancelled"
exitApp="Exit all"
tipRef="Refresh the device list"
tipDiag="Raw ADB output for troubleshooting"
tipForce="Kill adb and start it again"
tipInfo="Read model, battery, Wi-Fi and storage"
tipWake="Wake the device screen"
tipApk="Install one APK from this PC"
tipApkObb="Install APK and copy OBB to the standard path"
tipData="Copy a Data folder from this PC to the device"
tipObb="Copy an OBB folder from this PC to the device"
tipList="Open the app list for backup, uninstall or launch"
tipGo="Open this path"
tipUp="Go to the parent folder"
tipMk="Create a folder on the device"
tipPushF="Send a file from this PC"
tipPushD="Send a folder from this PC"
tipPull="Download the selected item"
tipRm="Delete the selected item on the device"
tipInstApk="Install this APK that is already on the device"
tipSet="Open Android Settings"
tipDate="Open date and time settings"
tipDevSet="Open developer options"
tipTime="Set device clock from this PC"
tipMtp="Expose the device as storage"
tipAdbR="Reset the ADB server on this PC"
tipKeys="Delete ADB keys of this PC"
tipDevKeys="Try to delete keys on the device"
tipTcp="Enable ADB on Wi-Fi port 5555"
tipConn="Connect wirelessly with IP:PORT"
tipDisc="Disconnect wireless ADB"
tipReboot="Reboot the device"
tipRec="Reboot to Recovery"
tipShot="Take a screenshot"
tipCustom="Run a custom ADB command"
tipListDev="Select the active device here"
tipLang="Program language"

scrcpy="Live view (scrcpy)"
cropMode="Crop"
cropFull="Full screen (phone)"
cropLeft="Left eye"
cropRight="Right eye"
cropLand="Landscape rectangle"
cropSq="Square"
noScrcpy="scrcpy.exe not found next to the app or in PATH"
diag="Connection diagnose"
force="Kill all ADB and reconnect"
unauthorized="Device is listed but not authorized. Tap Allow on the device."
offline="Device is offline. Check cable or wake the device."
rawOut="Raw adb output"
}
ru = @{
app="LTC Quest Helper"; lang="Язык"; device="Устройства"; refresh="Обновить"
ready="Готово"; noadb="adb.exe не найден рядом с программой"; nodev="Устройство не найдено"
busy="Уже выполняется задача"; ok="Готово"; err="Ошибка"; confirm="ОК"
cancel="Отмена"; tabDev="Устройство"; tabApps="Приложения"; tabFiles="Файлы"; tabTools="Инструменты"
infoTitle="Состояние устройства"; battery="Батарея"; wifi="Wi-Fi"; storage="Память"
model="Модель"; android="Android"; serial="Серийный"; usb="USB"; ip="IP"
connected="Подключено"; disconnected="Нет связи"; charging="Зарядка"; unknown="Неизвестно"
used="Занято"; free="Свободно"; total="Всего"; refreshInfo="Считать статус"
wake="Разбудить гарнитуру"; stayOn="Не засыпать на зарядке"
installApk="Установить APK"; installObb="APK + копировать OBB"; copyData="Копировать Data"
copyObb="Копировать OBB"; listApps="Список пользовательских приложений"; extractApp="Извлечь APK"
backupApp="Бэкап APK + OBB + Data"; uninstall="Удалить приложение"; launch="Запустить"
openSettings="Открыть Android Settings"; openDate="Дата и время"
openDev="Для разработчиков"; setTime="Поставить время с ПК"
fmTitle="Файловый менеджер ADB"; up="Вверх"; go="Перейти"; mkdir="Новая папка"
pushFile="Отправить файл"; pushFolder="Отправить папку"; pullSel="Скачать выбранное"
delSel="Удалить выбранное"; path="Путь"; name="Имя"; type="Тип"; folder="Папка"; file="Файл"
mtp="Подключить как диск (MTP)"; adbReset="Сброс ADB на ПК"
revokeKeys="Удалить ключи ADB на ПК"; tryDeviceKeys="Попробовать удалить ключи на гарнитуре"
wifiAdb="Wi-Fi ADB :5555"; connect="Беспроводное подключение"; disconnect="Отключить Wi-Fi ADB"
reboot="Перезагрузить"; recovery="Recovery"; shot="Снимок экрана"
custom="Своя команда"; log="Вывод"; clear="Очистить вывод"
pickApk="Выберите APK"; pickFolder="Выберите папку"
pkgPrompt="Имя пакета, например com.company.app"
pkgInvalid="Неверное имя пакета"
askInstall="Установить этот файл?"; askUninstall="Удалить пакет?"
askDel="Удалить? Это нельзя отменить."; askReboot="Перезагрузить гарнитуру?"
askRec="Recovery только если вы понимаете этот режим."
askKeys="Удалить ключи ADB этого ПК? На гарнитуре снова нужно нажать Allow."
askMtp="Включить MTP? ADB может на секунду пропасть."
askTime="Поставить часы гарнитуры по этому компьютеру?"
copied="Скопировано"; saved="Сохранено"; enterName="Введите имя"
noSel="Ничего не выбрано"; doneInfo="Статус обновлен"
hintDev="Включите Developer Mode и USB Debugging. Наденьте гарнитуру, чтобы подтвердить отладку."
hintFiles="Файлы идут через ADB, без сломанного MTP."
hintApps="OBB: Android/obb/пакет. Data: Android/data/пакет."
hintTools="Удаление ключей на гарнитуре без root обычно не выходит. Чистятся ключи ПК."
wifiOn="Wi-Fi включен / есть IP"; wifiOff="Wi-Fi выключен или нет IP"
company="Lumen Technologies Co."
site="LT-C.iddns.ir"
appMgr="Приложения устройства"
loadNames="Загрузить имена"
doUninstall="Удалить выбранное"
doExtract="Извлечь APK"
doBackup="Бэкап"
doLaunch="Запуск"
doData="Копировать Data в этот пакет"
doObb="Копировать OBB в этот пакет"
close="Закрыть"
selPkg="Сначала выберите приложение"
paths="Стандарт Meta: /sdcard/Android/obb/PACKAGE и /sdcard/Android/data/PACKAGE"
connNo="Нет подключения"
connAuth="Нужно разрешение"
connOk="Подключено"
connWifi="Подключено (Wi-Fi)"
installHere="Установить на гарнитуру"
legend="Цвета"
lgDir="Папка"
lgApk="APK"
lgObb="OBB"
lgZip="Архив zip/rar/7z"
lgImg="Фото"
lgVid="Видео"
lgAud="Аудио"
lgTxt="Текст / лог"
lgOther="Другие файлы"
grpInstall="Установка и данные"
grpManage="Приложения"
grpSettings="Настройки Android"
grpConn="Подключение и ADB"
grpPower="Устройство"
tabHelp="Справка"
helpTitle="Как это работает"
helpBody="1) Подключите устройство и включите USB Debugging.\r\n2) Выберите его в списке. Зелёный — подключено.\r\n3) Оранжевый — нажмите Allow на устройстве.\r\n4) Вкладка приложений только для установки и копирования. Удаление и бэкап — в окне списка.\r\n5) Закрытие окна или Отмена останавливает действие.\r\n6) Файловый менеджер показывает файлы после выбора устройства.\r\n7) Бэкап даёт один APK. OBB/Data сохраняются в папку рядом."
pickTitle="Выбор приложения"
pickHint="Выберите пункт и подтвердите. Закрытие окна — отмена."
cancelAction="Отменено"
exitApp="Полный выход"
tipRef="Обновить список устройств"
tipDiag="Сырой вывод ADB"
tipForce="Перезапустить ADB"
tipInfo="Модель, батарея, Wi-Fi и память"
tipWake="Разбудить экран"
tipApk="Установить APK с ПК"
tipApkObb="Установить APK и скопировать OBB"
tipData="Копировать Data с ПК"
tipObb="Копировать OBB с ПК"
tipList="Список приложений: бэкап, удаление, запуск"
tipGo="Перейти по пути"
tipUp="Папка выше"
tipMk="Создать папку"
tipPushF="Отправить файл"
tipPushD="Отправить папку"
tipPull="Скачать выбранное"
tipRm="Удалить выбранное"
tipInstApk="Установить этот APK с устройства"
tipSet="Настройки Android"
tipDate="Дата и время"
tipDevSet="Для разработчиков"
tipTime="Часы с компьютера"
tipMtp="Устройство как накопитель"
tipAdbR="Сброс ADB на ПК"
tipKeys="Удалить ключи ADB ПК"
tipDevKeys="Удалить ключи на устройстве"
tipTcp="ADB по Wi-Fi :5555"
tipConn="Подключить IP:PORT"
tipDisc="Отключить Wi-Fi ADB"
tipReboot="Перезагрузка"
tipRec="Recovery"
tipShot="Снимок экрана"
tipCustom="Своя команда ADB"
tipListDev="Выберите устройство в списке"
tipLang="Язык программы"

scrcpy="Трансляция (scrcpy)"
cropMode="Обрезка"
cropFull="Весь экран (телефон)"
cropLeft="Левый глаз"
cropRight="Правый глаз"
cropLand="Горизонтальный прямоугольник"
cropSq="Квадрат"
noScrcpy="scrcpy.exe не найден рядом с программой или в PATH"
diag="Диагностика"
force="Убить все ADB и подключить снова"
unauthorized="Гарнитура в списке, но без разрешения. Нажмите Allow на гарнитуре."
offline="Гарнитура offline. Проверьте кабель или разбудите её."
rawOut="Сырой вывод adb"
}
}

function T([string]$k) {
    try {
        $d = $I18N[$script:Lang]
        if ($d -is [hashtable] -and $d.ContainsKey($k)) { return [string]$d[$k] }
        if ($I18N["en"].ContainsKey($k)) { return [string]$I18N["en"][$k] }
    } catch {}
    return $k
}

function Load-Cfg {
    if (Test-Path -LiteralPath $script:CfgPath) {
        try {
            $j = Get-Content -LiteralPath $script:CfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($j.lang -in @("fa","en","ru")) { $script:Lang = [string]$j.lang }
        } catch {}
    }
}
function Save-Cfg {
    @{ lang = $script:Lang } | ConvertTo-Json | Set-Content -LiteralPath $script:CfgPath -Encoding UTF8
}

function Style-Form([Windows.Forms.Control]$c) {
    $c.BackColor = $Bg
    $c.ForeColor = $Tx
}
function New-Btn([string]$text, [int]$w=210, [int]$h=32) {
    $b = New-Object Windows.Forms.Button
    $b.Text = $text
    $b.Width = $w; $b.Height = $h
    $b.FlatStyle = "Flat"
    $b.FlatAppearance.BorderColor = $Y
    $b.FlatAppearance.BorderSize = 1
    $b.FlatAppearance.MouseOverBackColor = [Drawing.Color]::FromArgb(230,230,230)
    $b.FlatAppearance.MouseDownBackColor = [Drawing.Color]::FromArgb(210,210,210)
    $b.BackColor = [Drawing.Color]::White
    $b.ForeColor = [Drawing.Color]::Black
    $b.UseVisualStyleBackColor = $false
    $b.Cursor = [Windows.Forms.Cursors]::Hand
    $b.Add_MouseEnter({
        param($s,$e)
        $s.ForeColor = [Drawing.Color]::Black
        $s.BackColor = [Drawing.Color]::FromArgb(230,230,230)
        $s.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(180,130,0)
    })
    $b.Add_MouseLeave({
        param($s,$e)
        $s.ForeColor = [Drawing.Color]::Black
        $s.BackColor = [Drawing.Color]::White
        $s.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(180,130,0)
    })
    return $b
}
function New-Lbl([string]$text, [int]$w=200, [int]$h=22) {
    $l = New-Object Windows.Forms.Label
    $l.Text = $text; $l.Width=$w; $l.Height=$h
    $l.ForeColor = $Tx; $l.BackColor = [Drawing.Color]::Transparent
    return $l
}
function Alert([string]$m, [string]$t="", [Windows.Forms.MessageBoxIcon]$i=[Windows.Forms.MessageBoxIcon]::Information) {
    if (-not $t) { $t = T app }
    [Windows.Forms.MessageBox]::Show($m, $t, "OK", $i) | Out-Null
}
function Ask([string]$m) {
    $r = [Windows.Forms.MessageBox]::Show($m, (T confirm), "YesNo", "Question")
    return ($r -eq [Windows.Forms.DialogResult]::Yes)
}
function Write-Log([string]$t, [string]$k="info") {
    if (-not $script:Log) { return }
    $script:Log.SelectionStart = $script:Log.TextLength
    $script:Log.SelectionLength = 0
    $logOk = [Drawing.Color]::FromArgb(120, 220, 140)
    $logErr = [Drawing.Color]::FromArgb(255, 120, 120)
    $logCmd = [Drawing.Color]::FromArgb(255, 214, 80)
    $logInfo = [Drawing.Color]::FromArgb(240, 240, 240)
    $script:Log.SelectionColor = @{ ok=$logOk; err=$logErr; cmd=$logCmd; info=$logInfo }[$k]
    if (-not $script:Log.SelectionColor) { $script:Log.SelectionColor = $logInfo }
    $script:Log.AppendText( ("{0} {1}`r`n" -f (Get-Date -Format "HH:mm:ss"), $t) )
    $script:Log.ScrollToCaret()
}
function Set-Status([string]$t) { if ($script:Status) { $script:Status.Text = $t } }

function Invoke-Adb {
    param(
        [Parameter(Mandatory=$true)][string[]]$AdbArgs,
        [int]$TimeoutMs = 180000
    )
    if (-not (Test-Path -LiteralPath $script:AdbPath)) {
        return [pscustomobject]@{ Code=-1; Text=(T noadb) }
    }
    $id = [guid]::NewGuid().ToString("N")
    $outFile = Join-Path $env:TEMP ("qadb-out-" + $id + ".txt")
    $errFile = Join-Path $env:TEMP ("qadb-err-" + $id + ".txt")
    $code = -3
    try {
        $p = Start-Process -FilePath $script:AdbPath -ArgumentList $AdbArgs -WorkingDirectory $script:Root -PassThru -WindowStyle Hidden -RedirectStandardOutput $outFile -RedirectStandardError $errFile
        if (-not $p.WaitForExit($TimeoutMs)) {
            try { $p.Kill() } catch {}
            $code = -9
        } else {
            $code = $p.ExitCode
        }
    } catch {
        return [pscustomobject]@{ Code=-3; Text=$_.Exception.Message }
    }
    $out = ""
    $err = ""
    if (Test-Path -LiteralPath $outFile) {
        try { $out = [IO.File]::ReadAllText($outFile) } catch {}
        Remove-Item -LiteralPath $outFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $errFile) {
        try { $err = [IO.File]::ReadAllText($errFile) } catch {}
        Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue
    }
    $text = (($out + "`n" + $err) -replace "`0", "").Trim()
    return [pscustomobject]@{ Code=$code; Text=$text }
}

function TA([string[]]$rest) {
    $a = @()
    if ($script:Serial) { $a += @("-s", $script:Serial) }
    $a += $rest
    return ,$a
}
function AdbX([string[]]$a, [int]$ms=180000) {
    Write-Log ("adb " + ($a -join " ")) "cmd"
    Set-Status ($a -join " ")
    [Windows.Forms.Application]::DoEvents()
    $r = Invoke-Adb -AdbArgs $a -TimeoutMs $ms
    if ($r.Code -eq 0) {
        if ($r.Text) { Write-Log $r.Text "ok" } else { Write-Log (T ok) "ok" }
        Set-Status (T ready)
    } else {
        $m = $(if ($r.Text) { $r.Text } else { "$(T err) $($r.Code)" })
        Write-Log $m "err"
        Set-Status (T err)
    }
    return $r
}
function Guard {
    if ($script:Busy) { Alert (T busy); return $true }
    return $false
}
function Work([scriptblock]$job) {
    if (Guard) { return }
    $script:Busy = $true
    try { & $job } catch { Write-Log $_.Exception.Message "err"; Alert $_.Exception.Message (T err) Error; Set-Status (T err) }
    finally { $script:Busy = $false }
}

function Ask-Text([string]$title, [string]$prompt, [string]$def="") {
    $f = New-Object Windows.Forms.Form
    $f.Text = $title; $f.Size = [Drawing.Size]::new(520,170)
    $f.StartPosition = "CenterParent"; $f.FormBorderStyle="FixedDialog"
    $f.MaximizeBox=$false; $f.MinimizeBox=$false
    Style-Form $f
    if ($script:Lang -eq "fa") { $f.RightToLeft="Yes"; $f.RightToLeftLayout=$true }
    $l = New-Lbl $prompt 480 36; $l.Location = [Drawing.Point]::new(12,10)
    $t = New-Object Windows.Forms.TextBox
    $t.Text=$def; $t.Width=480; $t.Location=[Drawing.Point]::new(12,50)
    $t.BackColor=$Bg3; $t.ForeColor=$Tx; $t.BorderStyle="FixedSingle"
    $ok = New-Btn (T confirm) 100 28; $ok.Location=[Drawing.Point]::new(280,95); $ok.DialogResult="OK"
    $c = New-Btn (T cancel) 100 28; $c.Location=[Drawing.Point]::new(390,95); $c.DialogResult="Cancel"
    $f.Controls.AddRange(@($l,$t,$ok,$c)); $f.AcceptButton=$ok; $f.CancelButton=$c
    if ($f.ShowDialog() -eq "OK") { return $t.Text.Trim() }
    return $null
}
function Test-Pkg([string]$p) { return [bool]($p -match '^[A-Za-z0-9._]+$') }

function Get-AdbDeviceLines {
    $r = Invoke-Adb -AdbArgs @("devices","-l") -TimeoutMs 12000
    $all = $r.Text
    Write-Log ((T rawOut) + " / adb devices -l`r`n" + $all) "info"
    $items = @()
    foreach ($line in ($all -split "`r?`n")) {
        $s = $line.Trim()
        if (-not $s) { continue }
        if ($s -match '^List of devices') { continue }
        if ($s -match '^\* daemon') { continue }
        if ($s -match '^adb:') { continue }
        if ($s -match '^(?i)(error|failed)') { continue }
        if ($s -match '^(\S+)\s+(\S+)(.*)$') {
            $id = $Matches[1]
            $st = $Matches[2]
            $rest = $Matches[3].Trim()
            if ($st -notmatch '^(device|recovery|sideload|unauthorized|offline|host)$' -and $st -notmatch 'permissions') { continue }
            $label = ("{0}  [{1}] {2}" -f $id, $st, $rest).Trim()
            if (-not ($items | Where-Object { $_.Id -eq $id })) {
                $items += [pscustomobject]@{ Id=$id; State=$st; Label=$label }
            }
        }
    }
    return $items
}

function Test-WifiId([string]$Id) {
    if ([string]::IsNullOrWhiteSpace($Id)) { return $false }
    if ($Id -match 'adb-tls-connect') { return $true }
    if ($Id -match '^\d{1,3}(\.\d{1,3}){3}:\d+$') { return $true }
    if ($Id -match '^[\w\.\-]+:\d{2,5}$') { return $true }
    return $false
}
function Update-ConnLamp {
    param([string]$Id, [string]$State)
    $mode = "none"
    $txt = T connNo
    if ($State -match 'unauthorized') { $mode = "auth"; $txt = T connAuth }
    elseif ($State -match 'offline|permissions') { $mode = "auth"; $txt = T offline }
    elseif ($State -match 'device|recovery|sideload') {
        if (Test-WifiId $Id) { $mode = "wifi"; $txt = T connWifi }
        else { $mode = "ok"; $txt = T connOk }
    }
    $script:LampMode = $mode
    if ($script:LblConn) {
        $script:LblConn.Text = $txt
        $script:LblConn.Visible = $true
        $script:LblConn.BringToFront()
    }
    if ($script:Lamp) {
        $script:Lamp.Visible = $true
        $script:Lamp.BringToFront()
        $script:Lamp.Invalidate()
    }
}

function Update-Devices {
    $script:UpdatingDev = $true
    try {
        $items = @(Get-AdbDeviceLines)
        if ($script:LstDev) { $script:LstDev.Items.Clear() }
        if ($items.Count -eq 0) {
            $script:Serial = ""
            $script:DevState = ""
            Update-ConnLamp -Id "" -State ""
            Set-Status (T nodev)
            Write-Log (T nodev) "err"
            return
        }
        $pickIndex = 0
        for ($i=0; $i -lt $items.Count; $i++) {
            $lab = $items[$i].Label
            if (Test-WifiId $items[$i].Id) { $lab = $lab + "  Wi-Fi" }
            [void]$script:LstDev.Items.Add($lab)
            if ($script:Serial -and $items[$i].Id -eq $script:Serial) { $pickIndex = $i }
        }
        if ($pickIndex -ge $script:LstDev.Items.Count) { $pickIndex = 0 }
        $script:LstDev.SelectedIndex = $pickIndex
        $script:Serial = $items[$pickIndex].Id
        $script:DevState = $items[$pickIndex].State
        Update-ConnLamp -Id $script:Serial -State $script:DevState
        if ($script:DevState -match 'unauthorized') { Set-Status (T unauthorized); Write-Log (T unauthorized) "err" }
        elseif ($script:DevState -match 'offline') { Set-Status (T offline); Write-Log (T offline) "err" }
        elseif (Test-WifiId $script:Serial) { Set-Status ((T connWifi) + ": " + $script:Serial) }
        else { Set-Status ("{0}: {1}" -f (T connected), $script:Serial) }
    } finally {
        $script:UpdatingDev = $false
    }
}

function Reset-AdbStack {
    Write-Log "taskkill adb.exe" "cmd"
    try { Start-Process -FilePath "taskkill.exe" -ArgumentList @("/F","/IM","adb.exe") -WindowStyle Hidden -Wait } catch {}
    Start-Sleep -Milliseconds 700
    $r = Invoke-Adb @("start-server")
    Write-Log $r.Text "info"
    Start-Sleep -Milliseconds 500
    Update-Devices
}

function Show-Diag {
    $lines = @()
    $lines += "adb path: $($script:AdbPath)"
    $lines += "exists: " + (Test-Path -LiteralPath $script:AdbPath)
    $lines += "folder: $($script:Root)"
    $ver = Invoke-Adb @("version")
    $lines += "---- adb version ----"
    $lines += $ver.Text
    $d1 = Invoke-Adb @("devices","-l")
    $lines += "---- adb devices -l ----"
    $lines += $d1.Text
    $d2 = Invoke-Adb @("devices")
    $lines += "---- adb devices ----"
    $lines += $d2.Text
    $lines += "---- USB / PnP (Quest/Oculus/ADB) ----"
    try {
        $devs = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object {
            $_.InstanceId -match 'VID_2833|VID_18D1' -or
            $_.FriendlyName -match 'Oculus|Quest|ADB|Android'
        }
        if ($devs) {
            foreach ($d in $devs) {
                $lines += ("{0} | {1} | {2}" -f $d.Status, $d.FriendlyName, $d.InstanceId)
            }
        } else {
            $lines += "Windows did not list an Oculus/Quest/ADB USB device (VID_2833)."
        }
    } catch {
        $lines += $_.Exception.Message
    }
    $msg = ($lines -join "`r`n")
    Write-Log $msg "info"
    Show-ScrollText -Title (T diag) -Body $msg
}

function Parse-Battery([string]$t) {
    $lvl = "?"; $st = T unknown; $pl = ""
    if ($t -match 'level:\s*(\d+)') { $lvl = $Matches[1] + "%" }
    if ($t -match 'status:\s*(\d+)') {
        switch ($Matches[1]) {
            "2" { $st = T charging }
            "5" { $st = T charging }
            "3" { $st = "OK" }
            default { $st = $Matches[1] }
        }
    }
    if ($t -match 'plugged:\s*(\d+)' -and $Matches[1] -ne "0") { $pl = "USB/AC" }
    return "$lvl  $st  $pl"
}
function Parse-Wifi {
    $ip = ""
    $r = Invoke-Adb (TA @("shell","ip","-o","-4","addr","show","wlan0"))
    if ($r.Text -match 'inet\s+(\d+\.\d+\.\d+\.\d+)') { $ip = $Matches[1] }
    if (-not $ip) {
        $r2 = Invoke-Adb (TA @("shell","getprop","dhcp.wlan0.ipaddress"))
        if ($r2.Text -match '\d+\.\d+\.\d+\.\d+') { $ip = $r2.Text.Trim() }
    }
    $on = Invoke-Adb (TA @("shell","settings","get","global","wifi_on"))
    $enabled = ($on.Text.Trim() -eq "1")
    if ($ip) { return @{ Text = "$(T wifiOn)  $ip"; Ip=$ip; On=$true } }
    if ($enabled) { return @{ Text = "$(T wifiOn)"; Ip=""; On=$true } }
    return @{ Text = (T wifiOff); Ip=""; On=$false }
}
function Parse-Storage {
    $r = Invoke-Adb (TA @("shell","df"))
    $line = ($r.Text -split "`r?`n" | Where-Object { $_ -match '/storage/emulated/0$|/sdcard$|/data$' } | Select-Object -Last 1)
    if (-not $line) { $line = ($r.Text -split "`r?`n" | Where-Object { $_ -match '/data$' } | Select-Object -Last 1) }
    if (-not $line) { return $r.Text }
    $p = $line -split "\s+"
    if ($p.Count -ge 4) {
        $toMB = {
            param($raw)
            $s = [string]$raw
            if ($s -match '^[0-9.]+$') {
                return ("{0:N2} MB" -f ([double]$s / 1024.0))
            }
            return $s
        }
        $tot = & $toMB $p[1]
        $usd = & $toMB $p[2]
        $fre = & $toMB $p[3]
        return ("{0}: {1}   {2}: {3}   {4}: {5}" -f (T total), $tot, (T used), $usd, (T free), $fre)
    }
    return $line
}

function Refresh-Info {
    if (-not $script:Serial) { return }
    $blob = Invoke-Adb (TA @("shell","sh","-c","echo __MODEL__;getprop ro.product.model;echo __MAN__;getprop ro.product.manufacturer;echo __NAME__;getprop ro.product.name;echo __VER__;getprop ro.build.version.release;echo __USB__;getprop sys.usb.state;echo __IP__;ip -o -4 addr show wlan0 2>/dev/null;echo __DIP__;getprop dhcp.wlan0.ipaddress;echo __WFS__;settings get global wifi_on;echo __BAT__;dumpsys battery;echo __DF__;df")) 25000
    $txt = $blob.Text
    $grab = {
        param($key,$next)
        if ($txt -match "(?s)$key\r?\n(.*?)(?=$next|\z)") { return $Matches[1].Trim() }
        return ""
    }
    $model = & $grab "__MODEL__" "__MAN__"
    $man = & $grab "__MAN__" "__NAME__"
    $oc = & $grab "__NAME__" "__VER__"
    $ver = & $grab "__VER__" "__USB__"
    $usb = & $grab "__USB__" "__IP__"
    $ipraw = & $grab "__IP__" "__DIP__"
    $dip = & $grab "__DIP__" "__WFS__"
    $wfs = & $grab "__WFS__" "__BAT__"
    $bat = & $grab "__BAT__" "__DF__"
    $df = ""
    if ($txt -match "(?s)__DF__\r?\n(.*)$") { $df = $Matches[1] }
    $ip = ""
    if ($ipraw -match "inet\s+(\d+\.\d+\.\d+\.\d+)") { $ip = $Matches[1] }
    if (-not $ip -and $dip -match "\d+\.\d+\.\d+\.\d+") { $ip = $dip.Trim() }
    $wifiTxt = if ($ip) { "{0} / {1}" -f (T wifiOn), $ip } elseif ($wfs -eq "1") { T wifiOn } else { T wifiOff }
    $script:LblModelV.Text = ("{0} {1} ({2})" -f $man, $model, $oc)
    $script:LblAndV.Text = $ver
    $script:LblSerV.Text = $script:Serial
    $script:LblBatV.Text = Parse-Battery $bat
    $script:LblWifiV.Text = $wifiTxt
    $script:LblStoV.Text = (Parse-StorageText $df)
    $script:LblUsbV.Text = $usb
    $script:LastIp = $ip
    Set-Status (T doneInfo)
}
function Parse-StorageText([string]$raw) {
    $line = ($raw -split "`r?`n" | Where-Object { $_ -match "/storage/emulated/0$|/sdcard$|/data$" } | Select-Object -Last 1)
    if (-not $line) { return $raw }
    $p = $line -split "\s+"
    if ($p.Count -ge 4 -and $p[1] -match "^[0-9.]+$") {
        $fmt = { param($n) ("{0:N2} MB" -f ([double]$n / 1024.0)) }
        return ("{0}: {1}   {2}: {3}   {4}: {5}" -f (T total), (& $fmt $p[1]), (T used), (& $fmt $p[2]), (T free), (& $fmt $p[3]))
    }
    return $line
}

function Get-FileKind([string]$name, [bool]$isDir) {
    if ($isDir) { return "dir" }
    $ext = [IO.Path]::GetExtension($name.TrimEnd("/")).ToLowerInvariant()
    switch ($ext) {
        ".apk" { return "apk" }
        ".xapk" { return "apk" }
        ".apks" { return "apk" }
        ".obb" { return "obb" }
        ".zip" { return "zip" }
        ".rar" { return "zip" }
        ".7z" { return "zip" }
        ".gz" { return "zip" }
        ".png" { return "img" }
        ".jpg" { return "img" }
        ".jpeg" { return "img" }
        ".webp" { return "img" }
        ".gif" { return "img" }
        ".bmp" { return "img" }
        ".mp4" { return "vid" }
        ".mkv" { return "vid" }
        ".webm" { return "vid" }
        ".mov" { return "vid" }
        ".mp3" { return "aud" }
        ".ogg" { return "aud" }
        ".wav" { return "aud" }
        ".m4a" { return "aud" }
        ".txt" { return "txt" }
        ".log" { return "txt" }
        ".json" { return "txt" }
        ".xml" { return "txt" }
        ".csv" { return "txt" }
        default { return "other" }
    }
}
function Get-KindColor([string]$kind) {
    switch ($kind) {
        "dir" { return [Drawing.Color]::FromArgb(255, 214, 64) }
        "apk" { return [Drawing.Color]::FromArgb(110, 255, 120) }
        "obb" { return [Drawing.Color]::FromArgb(255, 176, 40) }
        "zip" { return [Drawing.Color]::FromArgb(255, 130, 220) }
        "img" { return [Drawing.Color]::FromArgb(120, 230, 255) }
        "vid" { return [Drawing.Color]::FromArgb(210, 170, 255) }
        "aud" { return [Drawing.Color]::FromArgb(120, 255, 210) }
        "txt" { return [Drawing.Color]::FromArgb(255, 255, 255) }
        default { return [Drawing.Color]::FromArgb(220, 220, 220) }
    }
}
function Get-KindLabel([string]$kind) {
    switch ($kind) {
        "dir" { return T lgDir }
        "apk" { return T lgApk }
        "obb" { return T lgObb }
        "zip" { return T lgZip }
        "img" { return T lgImg }
        "vid" { return T lgVid }
        "aud" { return T lgAud }
        "txt" { return T lgTxt }
        default { return T lgOther }
    }
}
function Add-FileRow([string]$disp, [bool]$isDir) {
    if (-not $disp -or $disp -eq "." -or $disp -eq "..") { return }
    $kind = Get-FileKind $disp $isDir
    $it = New-Object Windows.Forms.ListViewItem $disp
    [void]$it.SubItems.Add((Get-KindLabel $kind))
    $stored = $disp
    if ($isDir) { $stored = $disp.TrimEnd("/") + "/" }
    $it.Tag = @{ Name=$stored; Dir=$isDir; Kind=$kind }
    $it.ForeColor = Get-KindColor $kind
    [void]$script:Lv.Items.Add($it)
}
function List-RemoteNames([string]$path) {
    $names = New-Object System.Collections.Generic.List[string]
    $r = Invoke-Adb -AdbArgs (TA @("shell","ls",$path)) -TimeoutMs 20000
    Write-Log $r.Text "info"
    foreach ($raw in ($r.Text -split "`r?`n")) {
        $n = $raw.Trim().TrimEnd("/")
        if (-not $n) { continue }
        if ($n -match '^(ls:|Permission denied|No such file|Unknown option|error:|total\s)') { continue }
        if ($n -match 'more than one device') { continue }
        [void]$names.Add($n)
    }
    return $names
}
function List-RemoteDirs([string]$path) {
    $dirs = @{}
    $p = $path.TrimEnd("/") + "/"
    $r = Invoke-Adb -AdbArgs (TA @("shell","ls","-d",$p)) -TimeoutMs 15000
    foreach ($raw in ($r.Text -split "`r?`n")) {
        $n = $raw.Trim().TrimEnd("/")
        if (-not $n) { continue }
        if ($n -match '^(ls:|Permission denied|No such file|Unknown option|error:)') { continue }
        $leaf = Split-Path $n -Leaf
        if ($leaf) { $dirs[$leaf] = $true }
    }
    $r2 = Invoke-Adb -AdbArgs (TA @("shell","ls","-d",($p + "*/"))) -TimeoutMs 15000
    foreach ($raw in ($r2.Text -split "`r?`n")) {
        $n = $raw.Trim().TrimEnd("/")
        if (-not $n) { continue }
        if ($n -match '^(ls:|Permission denied|No such file|Unknown option|error:)') { continue }
        $leaf = Split-Path $n -Leaf
        if ($leaf) { $dirs[$leaf] = $true }
    }
    return $dirs
}
function Refresh-Files {
    if (-not $script:Lv) { return }
    $script:Lv.BeginUpdate()
    try {
        $script:Lv.Items.Clear()
        if ($script:BtnInstApk) { $script:BtnInstApk.Visible = $false }
        if ([string]::IsNullOrWhiteSpace($script:RemotePath)) { $script:RemotePath = "/sdcard" }
        $script:TxtPath.Text = $script:RemotePath
        if (-not $script:Serial) { Update-Devices }
        $path = $script:RemotePath
        $names = @(List-RemoteNames $path)
        if ($names.Count -eq 0 -and $path -eq "/sdcard") {
            $script:RemotePath = "/storage/emulated/0"
            $path = $script:RemotePath
            $script:TxtPath.Text = $path
            $names = @(List-RemoteNames $path)
        }
        $dirMap = List-RemoteDirs $path
        foreach ($n in $names) {
            $isDir = $false
            if ($dirMap.ContainsKey($n)) { $isDir = $true }
            Add-FileRow $n $isDir
        }
        Set-Status (("{0}  ({1})" -f $path, $script:Lv.Items.Count))
    } finally {
        $script:Lv.EndUpdate()
    }
}

function Join-Remote([string]$base, [string]$name) {
    $b = $base.TrimEnd("/")
    $n = $name.Trim("/")
    if ($b -eq "") { return "/" + $n }
    return "$b/$n"
}

function Get-UserPkgs {
    $r = Invoke-Adb (TA @("shell","pm","list","packages","-3"))
    $pkgs = @()
    foreach ($l in ($r.Text -split "`r?`n")) {
        if ($l -match '^package:(.+)$') { $pkgs += $Matches[1].Trim() }
    }
    return $pkgs
}

function Remote-Exists([string]$path) {
    $r = Invoke-Adb (TA @("shell","sh","-c",("if [ -e '{0}' ]; then echo YES; fi" -f $path)))
    return ($r.Text -match 'YES')
}
function Get-MainApkPath([string]$pkg) {
    $r = Invoke-Adb (TA @("shell","pm","path",$pkg))
    $paths = @()
    foreach ($l in ($r.Text -split "`r?`n")) {
        if ($l -match 'package:(/.+)$') { $paths += $Matches[1] }
    }
    if ($paths.Count -eq 0) { return $null }
    $base = $paths | Where-Object { $_ -match '/base\.apk$' } | Select-Object -First 1
    if ($base) { return $base }
    return $paths[0]
}
function Backup-AppTo([string]$pkg, [string]$folder) {
    if (-not (Test-Pkg $pkg)) { Alert (T pkgInvalid); return }
    $apkRemote = Get-MainApkPath $pkg
    if (-not $apkRemote) { Alert (T err); return }
    $apkLocal = Join-Path $folder ($pkg + ".apk")
    [void](AdbX (TA @("pull",$apkRemote,$apkLocal)) 300000)
    $obb = "/sdcard/Android/obb/$pkg"
    $data = "/sdcard/Android/data/$pkg"
    $hasObb = Remote-Exists $obb
    $hasData = Remote-Exists $data
    if ($hasObb -or $hasData) {
        $extra = Join-Path $folder $pkg
        New-Item -ItemType Directory -Force -Path $extra | Out-Null
        if ($hasObb) { [void](AdbX (TA @("pull",$obb,(Join-Path $extra "obb"))) 300000) }
        if ($hasData) { [void](AdbX (TA @("pull",$data,(Join-Path $extra "data"))) 300000) }
        Alert ((T saved) + "`r`n" + $apkLocal + "`r`n" + $extra)
    } else {
        Alert ((T saved) + "`r`n" + $apkLocal)
    }
}

function Pick-Pkg {
    $pkgs = @(Get-UserPkgs)
    $f = New-Object Windows.Forms.Form
    $f.Text = T pickTitle
    $f.Size = [Drawing.Size]::new(520, 460)
    $f.StartPosition = "CenterParent"
    $f.BackColor = $Bg
    $f.ForeColor = $Tx
    $f.MinimizeBox = $false
    $f.MaximizeBox = $false
    $hint = New-Lbl (T pickHint) 480 36
    $hint.Location = [Drawing.Point]::new(12,8)
    $hint.ForeColor = $Muted
    $lb = New-Object Windows.Forms.ListBox
    $lb.Location = [Drawing.Point]::new(12,48)
    $lb.Size = [Drawing.Size]::new(480, 310)
    $lb.BackColor = [Drawing.Color]::FromArgb(16,16,16)
    $lb.ForeColor = $Y
    foreach ($pkg in $pkgs) { [void]$lb.Items.Add($pkg) }
    $ok = New-Btn (T confirm) 140 30
    $ok.Location = [Drawing.Point]::new(200,370)
    $ok.DialogResult = [Windows.Forms.DialogResult]::OK
    $cancel = New-Btn (T cancel) 140 30
    $cancel.Location = [Drawing.Point]::new(352,370)
    $cancel.DialogResult = [Windows.Forms.DialogResult]::Cancel
    $f.AcceptButton = $ok
    $f.CancelButton = $cancel
    $lb.Add_DoubleClick({ if ($lb.SelectedItem) { $f.DialogResult = [Windows.Forms.DialogResult]::OK; $f.Close() } })
    $f.Controls.AddRange(@($hint,$lb,$ok,$cancel))
    $res = $f.ShowDialog()
    if ($res -ne [Windows.Forms.DialogResult]::OK) { Set-Status (T cancelAction); return $null }
    if (-not $lb.SelectedItem) { Set-Status (T cancelAction); return $null }
    return (Get-SelectedPkgFromList $lb)
}



function Infer-PkgFromObb([string]$folder) {
    $hits = Get-ChildItem -LiteralPath $folder -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^(main|patch)\.\d+\.(.+)\.obb$' }
    if ($hits) {
        if ($hits[0].Name -match '^(main|patch)\.\d+\.(.+)\.obb$') { return $Matches[2] }
    }
    return (Split-Path $folder -Leaf)
}


function Get-HelpText {
    if ($script:Lang -eq "fa") {
        return @"
دستگاه
• لیست بالا دستگاه‌های وصل‌شده است. یکی را انتخاب کنید.
• چراغ قرمز: وصل نیست. نارنجی: روی دستگاه Allow بزنید. سبز: وصل. سبز با سیگنال: وصل با وای‌فای.
• بروزرسانی فقط همین لیست را تازه می‌کند.

برنامه‌ها — نصب روی دستگاه
• نصب APK: یک فایل apk از رایانه روی دستگاه نصب می‌شود.
• نصب APK + کپی OBB: اول apk نصب می‌شود، بعد پوشه OBB به مسیر استاندارد می‌رود.
• کپی Data / کپی OBB: فایل را از رایانه به پوشه همان برنامه روی دستگاه می‌فرستد.
حذف و بکاپ این‌جا نیست.

برنامه‌ها — مدیریت
• فقط یک دکمه «لیست برنامه‌ها» هست.
• داخل آن پنجره: بکاپ کامل، حذف، اجرا، خواندن نام.
• بکاپ یعنی یک فایل APK درست + اگر Data یا OBB باشد همان‌جا پوشه‌اش کنار APK.
• بستن پنجره یعنی لغو. کار اضافه اجرا نمی‌شود.

فایل‌ها
• فایل‌های داخل دستگاه. رنگ‌ها در پایین همان تب معنی دارند.
• اگر فایل apk را انتخاب کنید، دکمه نصب روی دستگاه می‌آید.

ابزارها
• تنظیمات اندروید: Settings، تاریخ، توسعه‌دهنده، ست کردن ساعت.
• اتصال: MTP، ریست ADB، کلیدها، وای‌فای ADB.
• دستگاه: ریستارت، Recovery، اسکرین‌شات، دستور سفارشی.
هر کار فقط در همان گروه است.

اگر Cancel بزنید یا پنجره را ببندید، هیچ دستوری پشت صحنه نمی‌ماند.
"@
    }
    if ($script:Lang -eq "ru") {
        return @"
Устройство
• Список сверху — подключенные устройства. Выберите одно.
• Красный: нет связи. Оранжевый: нажмите Allow. Зелёный: подключено. Знак сигнала: Wi-Fi.

Приложения — установка
• APK ставит пакет с компьютера.
• APK + OBB ставит пакет и копирует OBB в стандартную папку.
• Data / OBB копируют папки на устройство.
Удаление и бэкап здесь не делаются.

Приложения — управление
• Одна кнопка списка. В окне: полный бэкап, удаление, запуск.
• Бэкап = один APK и папка Data/OBB рядом, если они есть.
• Закрытие окна = отмена.

Файлы
• Файлы на устройстве. Цвета подписаны внизу вкладки.

Инструменты
• Настройки Android, соединение/ADB и питание устройства разделены.
Отмена закрывает действие полностью.
"@
    }
    return @"
Device
• The top list is connected devices. Select one.
• Red: not connected. Orange: tap Allow on the device. Green: connected. Signal icon: Wi-Fi.

Apps — install to the device
• Install APK puts one package from the PC onto the device.
• APK + OBB installs the package and copies OBB to the standard folder.
• Copy Data / Copy OBB send folders from the PC to the device.
Uninstall and backup are not on this row.

Apps — manage
• There is only one button: the app list.
• Inside that window: full backup, uninstall, launch, load names.
• Backup means one correct APK plus a side folder if Data or OBB exists.
• Closing the window cancels. Nothing else runs after that.

Files
• Files on the device. The color guide is under the list.
• Select an APK on the device to see Install.

Tools
• Android settings, connection/ADB, and device power are separate groups.
Cancel or close means stop.
"@
}


function Apply-Tips {
    if (-not $script:Tips) {
        $script:Tips = New-Object Windows.Forms.ToolTip
        $script:Tips.AutoPopDelay = 14000
        $script:Tips.InitialDelay = 350
        $script:Tips.ShowAlways = $true
    }
    $pairs = @(
        @($script:BtnRef, (T tipRef)), @($script:BtnDiag, (T tipDiag)), @($script:BtnForce, (T tipForce)), @($script:BtnExit, (T exitApp)),
        @($script:BtnInfo, (T tipInfo)), @($script:BtnWake, (T tipWake)),
        @($script:BtnApk, (T tipApk)), @($script:BtnApkObb, (T tipApkObb)), @($script:BtnData, (T tipData)), @($script:BtnObb, (T tipObb)), @($script:BtnList, (T tipList)),
        @($script:BtnGo, (T tipGo)), @($script:BtnUp, (T tipUp)), @($script:BtnMk, (T tipMk)), @($script:BtnPushF, (T tipPushF)), @($script:BtnPushD, (T tipPushD)),
        @($script:BtnPull, (T tipPull)), @($script:BtnRm, (T tipRm)), @($script:BtnInstApk, (T tipInstApk)),
        @($script:BtnSet, (T tipSet)), @($script:BtnDate, (T tipDate)), @($script:BtnDevSet, (T tipDevSet)), @($script:BtnTime, (T tipTime)),
        @($script:BtnMtp, (T tipMtp)), @($script:BtnAdbR, (T tipAdbR)), @($script:BtnKeys, (T tipKeys)), @($script:BtnDevKeys, (T tipDevKeys)),
        @($script:BtnTcp, (T tipTcp)), @($script:BtnConn, (T tipConn)), @($script:BtnDisc, (T tipDisc)),
        @($script:BtnReboot, (T tipReboot)), @($script:BtnRec, (T tipRec)), @($script:BtnShot, (T tipShot)), @($script:BtnCustom, (T tipCustom)),
        @($script:LstDev, (T tipListDev)), @($script:CmbLang, (T tipLang))
    )
    foreach ($pair in $pairs) {
        if ($pair[0]) { $script:Tips.SetToolTip($pair[0], $pair[1]) }
    }
}

function Apply-Lang {
    try {
    if (-not $script:Form) { return }
    $script:Form.Text = T app
    $script:LblLang.Text = "زبان / Language / Язык"
    $script:LblDev.Text = T device
    $script:BtnRef.Text = T refresh
    $script:Tabs.TabPages[0].Text = T tabDev
    $script:Tabs.TabPages[1].Text = T tabApps
    $script:Tabs.TabPages[2].Text = T tabFiles
    $script:Tabs.TabPages[3].Text = T tabTools
    if ($script:Tabs.TabPages.Count -gt 4) { $script:Tabs.TabPages[4].Text = T tabHelp }
    if ($script:LblHelp) { $script:LblHelp.Text = T helpTitle }
    if ($script:TxtHelp) { $script:TxtHelp.Text = Get-HelpText }
    $script:LblInfo.Text = T infoTitle
    $script:LblModel.Text = T model
    $script:LblAnd.Text = T android
    $script:LblSer.Text = T serial
    $script:LblBat.Text = T battery
    $script:LblWifi.Text = T wifi
    $script:LblSto.Text = T storage
    $script:LblUsb.Text = T usb
    $script:BtnInfo.Text = T refreshInfo
    $script:BtnWake.Text = T wake
        $script:HintDev.Text = T hintDev
    $script:BtnApk.Text = T installApk
    $script:BtnApkObb.Text = T installObb
    $script:BtnData.Text = T copyData
    $script:BtnObb.Text = T copyObb
    $script:BtnList.Text = T listApps
    if ($script:BtnExtract) { $script:BtnExtract.Text = T extractApp }
    if ($script:BtnBackup) { $script:BtnBackup.Text = T backupApp }
    if ($script:BtnUn) { $script:BtnUn.Text = T uninstall }
    if ($script:BtnLaunch) { $script:BtnLaunch.Text = T launch }
    $script:HintApps.Text = T hintApps
    $script:LblFm.Text = T fmTitle
    $script:BtnUp.Text = T up
    $script:BtnGo.Text = T go
    $script:BtnMk.Text = T mkdir
    $script:BtnPushF.Text = T pushFile
    $script:BtnPushD.Text = T pushFolder
    $script:BtnPull.Text = T pullSel
    $script:BtnRm.Text = T delSel
    $script:HintFiles.Text = T hintFiles
    if ($script:Lv -and $script:Lv.Columns.Count -gt 0) { $script:Lv.Columns[0].Text = T name }
    if ($script:Lv -and $script:Lv.Columns.Count -gt 1) { $script:Lv.Columns[1].Text = T type }
    $script:BtnSet.Text = T openSettings
    $script:BtnDate.Text = T openDate
    $script:BtnDevSet.Text = T openDev
    $script:BtnTime.Text = T setTime
    $script:BtnMtp.Text = T mtp
    $script:BtnAdbR.Text = T adbReset
    $script:BtnKeys.Text = T revokeKeys
    $script:BtnDevKeys.Text = T tryDeviceKeys
    $script:BtnTcp.Text = T wifiAdb
    $script:BtnConn.Text = T connect
    $script:BtnDisc.Text = T disconnect
    $script:BtnReboot.Text = T reboot
    $script:BtnRec.Text = T recovery
    $script:BtnShot.Text = T shot
    $script:BtnCustom.Text = T custom
    $script:HintTools.Text = T hintTools
    $script:LblLog.Text = T log
    $script:BtnClear.Text = T clear
    $script:Form.RightToLeft = "No"
    $script:Form.RightToLeftLayout = $false
    if ($script:BtnDiag) { $script:BtnDiag.Text = T diag }
    if ($script:BtnForce) { $script:BtnForce.Text = T force }
    if ($script:BtnExit) { $script:BtnExit.Text = T exitApp }
    if ($script:BtnInstApk) { $script:BtnInstApk.Text = T installHere }
    if ($script:LblLegend) { $script:LblLegend.Text = T legend }
    if ($script:LblConn) { Update-ConnLamp -Id $script:Serial -State $script:DevState }
    if ($script:GrpInstall) { $script:GrpInstall.Text = T grpInstall }
    if ($script:GrpManage) { $script:GrpManage.Text = T grpManage }
    if ($script:GrpSettings) { $script:GrpSettings.Text = T grpSettings }
    if ($script:GrpConnBox) { $script:GrpConnBox.Text = T grpConn }
    if ($script:GrpPower) { $script:GrpPower.Text = T grpPower }
    Build-Legend
    Apply-Tips
    } catch { }
}


function Show-ScrollText {
    param([string]$Title, [string]$Body)
    $f = New-Object Windows.Forms.Form
    $f.Text = $Title
    $f.Size = [Drawing.Size]::new(780, 520)
    $f.StartPosition = "CenterParent"
    $f.BackColor = $Bg
    $f.ForeColor = $Tx
    $tb = New-Object Windows.Forms.TextBox
    $tb.Multiline = $true
    $tb.ScrollBars = "Both"
    $tb.ReadOnly = $true
    $tb.Dock = "Fill"
    $tb.BackColor = $Bg2
    $tb.ForeColor = $Tx
    $tb.Font = New-Object Drawing.Font("Consolas", 9)
    $tb.WordWrap = $false
    $tb.Text = $Body
    $f.Controls.Add($tb)
    [void]$f.ShowDialog()
}

function Get-AppLabel([string]$pkg) {
    $r = Invoke-Adb (TA @("shell","dumpsys","package",$pkg)) 25000
    $txt = $r.Text
    $cands = @()
    foreach ($pat in @(
        "application-label-en:'([^']+)'",
        "application-label:'([^']+)'",
        "application-label-[A-Za-z0-9]+?:'([^']+)'",
        "(?m)^\s*nonLocalizedLabel=(.+)$",
        "(?m)^\s*applicationLabel=(.+)$",
        "Application Label(?: Name)?:\s*(.+)$"
    )) {
        $m = [regex]::Match($txt, $pat)
        if ($m.Success) {
            $v = $m.Groups[1].Value.Trim().Trim("'").Trim('"')
            if ($v -and $v -ne "null" -and $v -ne $pkg) { $cands += $v }
        }
    }
    if ($cands.Count -gt 0) { return $cands[0] }
    $g = Invoke-Adb (TA @("shell","sh","-c",("dumpsys package {0} | grep -i label" -f $pkg))) 20000
    $mg = [regex]::Match($g.Text, "application-label(?:-[^:]+)?:'([^']+)'")
    if ($mg.Success -and $mg.Groups[1].Value -ne $pkg) { return $mg.Groups[1].Value }
    $apk = Get-MainApkPath $pkg
    if ($apk) {
        $aaptDev = Invoke-Adb (TA @("shell","sh","-c",("aapt dump badging '{0}' 2>/dev/null | grep application-label" -f $apk))) 20000
        $ma = [regex]::Match($aaptDev.Text, "application-label(?:-en)?:'([^']+)'")
        if ($ma.Success -and $ma.Groups[1].Value -ne $pkg) { return $ma.Groups[1].Value }
        $aapt = Join-Path $script:Root "aapt.exe"
        if (Test-Path -LiteralPath $aapt) {
            $tmp = Join-Path $env:TEMP ("ltc-" + $pkg + ".apk")
            [void](AdbX (TA @("pull",$apk,$tmp)) 120000)
            if (Test-Path -LiteralPath $tmp) {
                $out = & $aapt dump badging $tmp 2>$null | Out-String
                Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
                $mb = [regex]::Match($out, "application-label(?:-en)?:'([^']+)'")
                if ($mb.Success) { return $mb.Groups[1].Value }
            }
        }
    }
    return $pkg
}

function Get-SelectedPkgFromList([Windows.Forms.ListBox]$lb) {
    if (-not $lb.SelectedItem) { return $null }
    $s = [string]$lb.SelectedItem
    if ($s -match '\(([^)]+)\)\s*$') { return $Matches[1] }
    return $s.Trim()
}

function Copy-ToStdPath {
    param([string]$Kind, [string]$Pkg, [string]$LocalPath)
    $name = $Pkg
    if ([string]::IsNullOrWhiteSpace($name)) { $name = Split-Path $LocalPath -Leaf }
    if ($Kind -eq "obb") { $parent = "/sdcard/Android/obb" }
    else { $parent = "/sdcard/Android/data" }
    $dest = "$parent/$name"
    [void](AdbX (TA @("shell","rm","-rf",$dest)))
    [void](AdbX (TA @("shell","mkdir","-p",$parent)))
    [void](AdbX (TA @("push",$LocalPath,$parent)) 300000)
}

function Show-AppManager {
    $f = New-Object Windows.Forms.Form
    $f.Text = T appMgr
    $f.Size = [Drawing.Size]::new(720, 560)
    $f.StartPosition = "CenterParent"
    $f.BackColor = $Bg
    $f.ForeColor = $Tx
    $hint = New-Lbl (T paths) 680 36
    $hint.Location = [Drawing.Point]::new(12,8)
    $hint.ForeColor = $Muted
    $lb = New-Object Windows.Forms.ListBox
    $lb.Location = [Drawing.Point]::new(12,48)
    $lb.Size = [Drawing.Size]::new(680, 330)
    $lb.BackColor = [Drawing.Color]::White
    $lb.ForeColor = [Drawing.Color]::Black
    $lb.Font = New-Object Drawing.Font("Tahoma", 9)
    $pkgs = @(Get-UserPkgs)
    foreach ($pkg in $pkgs) { [void]$lb.Items.Add($pkg) }
    $y = 390
    $b1 = New-Btn (T loadNames) 160 30; $b1.Location=[Drawing.Point]::new(12,$y); $b1.Visible=$false
    $b2 = New-Btn (T doUninstall) 160 30; $b2.Location=[Drawing.Point]::new(184,$y)
    $b3 = New-Btn (T doExtract) 160 30; $b3.Location=[Drawing.Point]::new(356,$y); $b3.Visible=$false
    $b4 = New-Btn (T doBackup) 160 30; $b4.Location=[Drawing.Point]::new(528,$y)
    $y2 = 428
    $b5 = New-Btn (T doLaunch) 160 30; $b5.Location=[Drawing.Point]::new(12,$y2)
    $b6 = New-Btn (T doData) 160 30; $b6.Location=[Drawing.Point]::new(184,$y2); $b6.Visible=$false
    $b7 = New-Btn (T doObb) 160 30; $b7.Location=[Drawing.Point]::new(356,$y2); $b7.Visible=$false
    $b8 = New-Btn (T close) 160 30; $b8.Location=[Drawing.Point]::new(528,$y2)
    $b8.Add_Click({ $f.Close() })
    $b1.Add_Click({
        $b1.Enabled = $false
        $old = @()
        foreach ($it in $lb.Items) { $old += [string]$it }
        $lb.Items.Clear()
        foreach ($item in $old) {
            $pkg = $item
            if ($item -match '\(([^)]+)\)\s*$') { $pkg = $Matches[1] }
            Set-Status ("{0}: {1}" -f (T loadNames), $pkg)
            [Windows.Forms.Application]::DoEvents()
            $lab = Get-AppLabel $pkg
            [void]$lb.Items.Add(("{0}   ({1})" -f $lab, $pkg))
        }
        Set-Status (T ready)
        $b1.Enabled = $true
    })
    $b2.Add_Click({
        $pkg = Get-SelectedPkgFromList $lb
        if (-not $pkg) { Alert (T selPkg); return }
        if (-not (Ask ((T askUninstall) + "`r`n" + $pkg))) { return }
        [void](AdbX (TA @("uninstall",$pkg)))
        $lb.Items.Remove($lb.SelectedItem)
    })
    $b3.Add_Click({
        $pkg = Get-SelectedPkgFromList $lb
        if (-not $pkg) { Alert (T selPkg); return }
        $fb = New-Object Windows.Forms.FolderBrowserDialog
        if ($fb.ShowDialog() -ne "OK") { return }
        $remote = Get-MainApkPath $pkg
        if ($remote) { [void](AdbX (TA @("pull",$remote,(Join-Path $fb.SelectedPath ($pkg + ".apk")))) 300000) }
    })
    $b4.Add_Click({
        $pkg = Get-SelectedPkgFromList $lb
        if (-not $pkg) { Alert (T selPkg); return }
        $fb = New-Object Windows.Forms.FolderBrowserDialog
        if ($fb.ShowDialog() -ne "OK") { return }
        Backup-AppTo $pkg $fb.SelectedPath
    })
    $b5.Add_Click({
        $pkg = Get-SelectedPkgFromList $lb
        if (-not $pkg) { Alert (T selPkg); return }
        [void](AdbX (TA @("shell","monkey","-p",$pkg,"-c","android.intent.category.LAUNCHER","1")))
    })
    $b6.Add_Click({
        $pkg = Get-SelectedPkgFromList $lb
        if (-not $pkg) { Alert (T selPkg); return }
        $fb = New-Object Windows.Forms.FolderBrowserDialog
        if ($fb.ShowDialog() -ne "OK") { return }
        Copy-ToStdPath -Kind "data" -Pkg $pkg -LocalPath $fb.SelectedPath
    })
    $b7.Add_Click({
        $pkg = Get-SelectedPkgFromList $lb
        if (-not $pkg) { Alert (T selPkg); return }
        $fb = New-Object Windows.Forms.FolderBrowserDialog
        if ($fb.ShowDialog() -ne "OK") { return }
        Copy-ToStdPath -Kind "obb" -Pkg $pkg -LocalPath $fb.SelectedPath
    })
    $f.Controls.AddRange(@($hint,$lb,$b1,$b2,$b3,$b4,$b5,$b6,$b7,$b8))
    $f.CancelButton = $b8
    $b8.DialogResult = [Windows.Forms.DialogResult]::Cancel
    [void]$f.ShowDialog()
    return $null
}


function Find-LogoFile {
    $names = @("logo.ico","logo.png","logo.jpg","logo.jpeg","logo.bmp","logo.webp","Logo.ico","Logo.png","LOGO.png","logo.PNG")
    foreach ($n in $names) {
        $f = Join-Path $script:Root $n
        if (Test-Path -LiteralPath $f) { return $f }
    }
    return $null
}
function Apply-Logo {
    $f = Find-LogoFile
    if (-not $f) { return }
    try {
        if ([IO.Path]::GetExtension($f).ToLowerInvariant() -eq ".ico") {
            $ico = New-Object Drawing.Icon $f
            if ($script:Form) { $script:Form.Icon = $ico }
            if ($script:PicLogo) {
                $script:PicLogo.Image = $ico.ToBitmap()
                $script:PicLogo.Visible = $true
            }
            return
        }
        $img = [Drawing.Image]::FromFile($f)
        if ($script:PicLogo) {
            $script:PicLogo.Image = $img
            $script:PicLogo.SizeMode = "Zoom"
            $script:PicLogo.Visible = $true
        }
        $square = New-Object Drawing.Bitmap 32, 32
        $g = [Drawing.Graphics]::FromImage($square)
        $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.Clear([Drawing.Color]::Transparent)
        $g.DrawImage($img, 0, 0, 32, 32)
        $hicon = $square.GetHicon()
        if ($script:Form) { $script:Form.Icon = [Drawing.Icon]::FromHandle($hicon) }
        $g.Dispose()
    } catch {
        Write-Log $_.Exception.Message "err"
    }
}


function Find-Scrcpy {
    $hits = @()
    foreach ($dir in @($script:Root, (Join-Path $script:Root "scrcpy"), (Split-Path $script:AdbPath -Parent))) {
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        $direct = Join-Path $dir "scrcpy.exe"
        if (Test-Path -LiteralPath $direct) { return $direct }
        try {
            $found = Get-ChildItem -LiteralPath $dir -Filter "scrcpy.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 3
            foreach ($f in $found) { $hits += $f.FullName }
        } catch {}
    }
    if ($hits.Count -gt 0) { return $hits[0] }
    $cmd = Get-Command "scrcpy.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}
function Fill-CropCombo {
    if (-not $script:CmbCrop) { return }
    $idx = 0
    if ($script:CmbCrop.Items.Count -gt 0) { $idx = [Math]::Max(0, $script:CmbCrop.SelectedIndex) }
    $script:CmbCrop.Items.Clear()
    [void]$script:CmbCrop.Items.Add((T cropFull))
    [void]$script:CmbCrop.Items.Add((T cropLeft))
    [void]$script:CmbCrop.Items.Add((T cropRight))
    [void]$script:CmbCrop.Items.Add((T cropLand))
    [void]$script:CmbCrop.Items.Add((T cropSq))
    if ($idx -lt $script:CmbCrop.Items.Count) { $script:CmbCrop.SelectedIndex = $idx } else { $script:CmbCrop.SelectedIndex = 0 }
}
function Start-ScrcpyLive {
    $exe = Find-Scrcpy
    if (-not $exe) { Alert (T noScrcpy); Write-Log (T noScrcpy) "err"; return }
    if (-not $script:Serial) { Alert (T nodev); return }
    $sz = Invoke-Adb (TA @("shell","wm","size"))
    $W = 0; $H = 0
    if ($sz.Text -match '(\d+)x(\d+)') { $W = [int]$Matches[1]; $H = [int]$Matches[2] }
    $mode = 0
    if ($script:CmbCrop -and $script:CmbCrop.SelectedIndex -ge 0) { $mode = [int]$script:CmbCrop.SelectedIndex }
    $scArgs = New-Object System.Collections.Generic.List[string]
    [void]$scArgs.Add("-s"); [void]$scArgs.Add($script:Serial)
    [void]$scArgs.Add("--adb=$($script:AdbPath)")
    [void]$scArgs.Add("--window-title=LTC Quest Helper")
    [void]$scArgs.Add("--stay-awake")
    if ($W -gt 0 -and $H -gt 0 -and $mode -gt 0) {
        $eyeW = [int][Math]::Floor($W / 2)
        if ($eyeW -lt 1) { $eyeW = $W }
        if ($W -le $H) { $eyeW = $W }
        $crop = $null
        switch ($mode) {
            1 { $crop = "{0}:{1}:0:0" -f $eyeW, $H }
            2 { $crop = "{0}:{1}:{2}:0" -f $eyeW, $H, ([int][Math]::Max(0, $W - $eyeW)) }
            3 {
                $hh = [int][Math]::Max(200, [Math]::Floor($H * 0.58))
                $yy = [int][Math]::Max(0, [Math]::Floor(($H - $hh) / 2))
                $crop = "{0}:{1}:0:{2}" -f $eyeW, $hh, $yy
            }
            4 {
                $side = [Math]::Min($eyeW, $H)
                if ($side -lt 1) { $side = [Math]::Min($W, $H) }
                $yy = [int][Math]::Max(0, [Math]::Floor(($H - $side) / 2))
                $crop = "{0}:{1}:0:{2}" -f $side, $side, $yy
            }
        }
        if ($crop) { [void]$scArgs.Add("--crop=$crop") }
    }
    $wd = Split-Path -Parent $exe
    $oldPath = $env:PATH
    $env:PATH = ($wd + ";" + $script:Root + ";" + $oldPath)
    $line = "`"$exe`" " + (($scArgs | ForEach-Object { if ($_ -match "\s") { "`"$_`"" } else { $_ } }) -join " ")
    Write-Log $line "cmd"
    try {
        $p = Start-Process -FilePath $exe -ArgumentList $scArgs.ToArray() -WorkingDirectory $wd -PassThru
        if (-not $p) { Alert ("scrcpy start failed`r`n" + $exe); return }
        Start-Sleep -Milliseconds 900
        if ($p.HasExited) {
            $msg = "scrcpy closed immediately. Exit $($p.ExitCode)`r`n$exe`r`n$line"
            Write-Log $msg "err"
            Alert $msg (T err)
        } else {
            Write-Log ("scrcpy pid " + $p.Id) "ok"
        }
    } catch {
        Write-Log $_.Exception.Message "err"
        Alert ($exe + "`r`n" + $_.Exception.Message) (T err)
    } finally {
        $env:PATH = $oldPath
    }
}


function Stop-LtcAll {
    try { [void](Invoke-Adb -AdbArgs @("kill-server") -TimeoutMs 8000) } catch {}
    Get-Process -Name "adb" -ErrorAction SilentlyContinue | ForEach-Object {
        try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch {}
    }
    $root = $script:Root
    Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            if ($_.Path -and $root -and $_.Path.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
                if ($_.Id -ne $PID) { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
            }
        } catch {}
    }
    try { if ($script:Form) { $script:Form.Close() } } catch {}
    [Environment]::Exit(0)
}
function Show-Splash {
    $sp = New-Object Windows.Forms.Form
    $sp.FormBorderStyle = "None"
    $sp.StartPosition = "CenterScreen"
    $sp.Size = [Drawing.Size]::new(520, 340)
    $sp.BackColor = [Drawing.Color]::White
    $sp.TopMost = $true
    $sp.ShowInTaskbar = $false
    $pic = New-Object Windows.Forms.PictureBox
    $pic.Size = [Drawing.Size]::new(180,180)
    $pic.Location = [Drawing.Point]::new(170,50)
    $pic.SizeMode = "Zoom"
    $pic.BackColor = [Drawing.Color]::White
    $logo = Find-LogoFile
    if ($logo) {
        try {
            if ([IO.Path]::GetExtension($logo).ToLowerInvariant() -eq ".ico") {
                $ico = New-Object Drawing.Icon $logo
                $pic.Image = $ico.ToBitmap()
            } else {
                $img = [Drawing.Image]::FromFile($logo)
                $bmp = New-Object Drawing.Bitmap $img
                $img.Dispose()
                $pic.Image = $bmp
            }
        } catch {}
    }
    $lab = New-Object Windows.Forms.Label
    $lab.Text = "LTC Quest Helper"
    $lab.TextAlign = "MiddleCenter"
    $lab.ForeColor = [Drawing.Color]::FromArgb(30,30,30)
    $lab.Font = New-Object Drawing.Font("Tahoma", 14, [Drawing.FontStyle]::Bold)
    $lab.Size = [Drawing.Size]::new(500,36)
    $lab.Location = [Drawing.Point]::new(10,250)
    $sp.Controls.Add($pic)
    $sp.Controls.Add($lab)
    $sp.Show()
    [Windows.Forms.Application]::DoEvents()
    return $sp
}

# ---------------- UI ----------------
Load-Cfg
$script:Splash = Show-Splash
$font = New-Object Drawing.Font("Tahoma", 9)
$form = New-Object Windows.Forms.Form
$script:Form = $form
$form.Size = [Drawing.Size]::new(1140, 800)
$form.MinimumSize = [Drawing.Size]::new(980, 640)
$form.StartPosition = "CenterScreen"
$form.Font = $font
$form.BackColor = $Bg
$form.ForeColor = $Tx

$script:LampMode = "none"
$top = New-Object Windows.Forms.Panel
$top.Dock="Top"; $top.Height=100; $top.BackColor=$Bg2
$script:Lamp = New-Object Windows.Forms.Panel
$script:Lamp.Size = [Drawing.Size]::new(28,28)
$script:Lamp.Location = [Drawing.Point]::new(66,12)
$script:Lamp.BackColor = $Bg2
$script:Lamp.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $c = switch ($script:LampMode) {
        "ok" { [Drawing.Color]::FromArgb(46, 210, 90) }
        "wifi" { [Drawing.Color]::FromArgb(46, 210, 90) }
        "auth" { [Drawing.Color]::FromArgb(255, 168, 36) }
        default { [Drawing.Color]::FromArgb(230, 64, 64) }
    }
    $br = New-Object Drawing.SolidBrush $c
    $g.FillEllipse($br, 1, 1, 26, 26)
    $br.Dispose()
    $ring = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(20,20,20), 1)
    $g.DrawEllipse($ring, 1, 1, 26, 26)
    $ring.Dispose()
    if ($script:LampMode -eq "wifi") {
        $pen = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(10,10,10), 2.1)
        $pen.StartCap = [Drawing.Drawing2D.LineCap]::Round
        $pen.EndCap = [Drawing.Drawing2D.LineCap]::Round
        $cx = 14; $cy = 22
        $g.DrawArc($pen, ($cx-12), ($cy-12), 24, 24, 218, 104)
        $g.DrawArc($pen, ($cx-8), ($cy-8), 16, 16, 218, 104)
        $g.DrawArc($pen, ($cx-5), ($cy-5), 10, 10, 218, 104)
        $dot = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(10,10,10))
        $g.FillEllipse($dot, ($cx-3), ($cy-2), 6, 6)
        $dot.Dispose()
        $pen.Dispose()
    }
})
$script:LblConn = New-Lbl "" 170 22
$script:LblConn.Location = [Drawing.Point]::new(98,16)
$script:LblConn.ForeColor = $Y
$script:PicLogo = New-Object Windows.Forms.PictureBox
$script:PicLogo.Size = [Drawing.Size]::new(48,48)
$script:PicLogo.Location = [Drawing.Point]::new(10,10)
$script:PicLogo.SizeMode = "Zoom"
$script:PicLogo.BackColor = $Bg2
$script:PicLogo.Visible = $false
$script:LblLang = New-Lbl "زبان / Language / Язык" 168 36
$script:LblLang.Location=[Drawing.Point]::new(10,58)
$script:LblLang.Height = 36
$script:LblLang.Font = New-Object Drawing.Font("Tahoma", 7.5)
$script:CmbLang = New-Object Windows.Forms.ComboBox
$script:CmbLang.DropDownStyle="DropDownList"; $script:CmbLang.Width=90
$script:CmbLang.Location=[Drawing.Point]::new(178,64)
$script:CmbLang.BackColor=[Drawing.Color]::White; $script:CmbLang.ForeColor=[Drawing.Color]::Black
[void]$script:CmbLang.Items.AddRange(@("fa","en","ru"))
$script:CmbLang.SelectedItem = $script:Lang
$script:CmbLang.Add_SelectedIndexChanged({
    $script:Lang = [string]$script:CmbLang.SelectedItem
    Save-Cfg
    Apply-Lang
Build-Legend
Update-ConnLamp -Id '' -State ''
    Update-ConnLamp -Id $script:Serial -State $script:DevState
})
$script:LblDev = New-Lbl "" 200 18; $script:LblDev.Location=[Drawing.Point]::new(280,4)
$script:LstDev = New-Object Windows.Forms.ListBox
$script:LstDev.Location=[Drawing.Point]::new(280,24)
$script:LstDev.Size=[Drawing.Size]::new(490,68)
$script:LstDev.BackColor=[Drawing.Color]::FromArgb(16,16,16)
$script:LstDev.ForeColor=[Drawing.Color]::White
$script:LstDev.DrawMode = "OwnerDrawFixed"
$script:LstDev.ItemHeight = 16
$script:LstDev.Add_DrawItem({
    param($s,$e)
    if ($e.Index -lt 0) { return }
    $selected = (($e.State -band [Windows.Forms.DrawItemState]::Selected) -ne 0)
    $bg = [Drawing.Color]::FromArgb(16,16,16)
    $fg = if ($selected) { [Drawing.Color]::FromArgb(120, 255, 140) } else { [Drawing.Color]::White }
    $brBg = New-Object Drawing.SolidBrush $bg
    $brFg = New-Object Drawing.SolidBrush $fg
    $e.Graphics.FillRectangle($brBg, $e.Bounds)
    $e.Graphics.DrawString([string]$s.Items[$e.Index], $s.Font, $brFg, [float]$e.Bounds.X, [float]$e.Bounds.Y)
    $brBg.Dispose(); $brFg.Dispose()
})
$script:LstDev.BorderStyle="FixedSingle"
$script:LstDev.Add_SelectedIndexChanged({
    if ($script:UpdatingDev) { return }
    if ($script:LstDev.SelectedItem) {
        $script:Serial = (($script:LstDev.SelectedItem.ToString()) -split "\s+")[0]
        $st = "device"
        if ($script:LstDev.SelectedItem.ToString() -match '\[([^\]]+)\]') { $st = $Matches[1] }
        $script:DevState = $st
        Update-ConnLamp -Id $script:Serial -State $st
        if (Test-WifiId $script:Serial) { Set-Status ((T connWifi) + ": " + $script:Serial) }
        else { Set-Status ("{0}: {1}" -f (T device), $script:Serial) }
    }
})
$script:BtnRef = New-Btn "" 150 28; $script:BtnRef.Location=[Drawing.Point]::new(790,8)
$script:BtnRef.Add_Click({ Work { Update-Devices; Refresh-Info } })
$script:BtnDiag = New-Btn "" 150 28; $script:BtnDiag.Location=[Drawing.Point]::new(790,42)
$script:BtnDiag.Add_Click({ Work { Show-Diag } })
$script:BtnForce = New-Btn "" 150 28; $script:BtnForce.Location=[Drawing.Point]::new(950,8)
$script:BtnExit = New-Btn "" 150 28; $script:BtnExit.Location=[Drawing.Point]::new(950,40)
$script:BtnExit.Add_Click({ Stop-LtcAll })
$script:BtnForce.Add_Click({ Work { Reset-AdbStack; Refresh-Info } })
$top.Controls.AddRange(@($script:PicLogo,$script:Lamp,$script:LblConn,$script:LblLang,$script:CmbLang,$script:LblDev,$script:LstDev,$script:BtnRef,$script:BtnDiag,$script:BtnForce,$script:BtnExit))

$script:Tabs = New-Object Windows.Forms.TabControl
$script:Tabs.Dock="Top"; $script:Tabs.Height=430
$script:Tabs.Add_SelectedIndexChanged({
    if ($script:Tabs.SelectedIndex -eq 2) { Refresh-Files }
})
$script:Tabs.SizeMode="Fixed"; $script:Tabs.ItemSize=[Drawing.Size]::new(140,26)
$p0 = New-Object Windows.Forms.TabPage
$p1 = New-Object Windows.Forms.TabPage
$p2 = New-Object Windows.Forms.TabPage
$p3 = New-Object Windows.Forms.TabPage
$p4 = New-Object Windows.Forms.TabPage
foreach ($p in @($p0,$p1,$p2,$p3,$p4)) { $p.BackColor=$Bg; $p.ForeColor=$Tx }
[void]$script:Tabs.TabPages.AddRange(@($p0,$p1,$p2,$p3,$p4))
$script:Tabs.ItemSize=[Drawing.Size]::new(110,26)

# tab device
$script:LblInfo = New-Lbl "" 400 22; $script:LblInfo.Location=[Drawing.Point]::new(16,12); $script:LblInfo.ForeColor=$Y
function AddKV([Windows.Forms.Control]$parent, [int]$y, [ref]$lk, [ref]$lv, [int]$lw=90) {
    $a = New-Lbl "" $lw 20; $a.Location=[Drawing.Point]::new(16,$y); $a.ForeColor=$Muted
    $b = New-Lbl "" 700 20; $b.Location=[Drawing.Point]::new(16+$lw+8,$y)
    $parent.Controls.AddRange(@($a,$b))
    $lk.Value=$a; $lv.Value=$b
}
$k=$null;$v=$null
AddKV $p0 44 ([ref]$k) ([ref]$v); $script:LblModel=$k; $script:LblModelV=$v
AddKV $p0 68 ([ref]$k) ([ref]$v); $script:LblAnd=$k; $script:LblAndV=$v
AddKV $p0 92 ([ref]$k) ([ref]$v); $script:LblSer=$k; $script:LblSerV=$v
AddKV $p0 116 ([ref]$k) ([ref]$v); $script:LblBat=$k; $script:LblBatV=$v
AddKV $p0 140 ([ref]$k) ([ref]$v); $script:LblWifi=$k; $script:LblWifiV=$v
AddKV $p0 164 ([ref]$k) ([ref]$v) 90; $script:LblSto=$k; $script:LblStoV=$v
AddKV $p0 188 ([ref]$k) ([ref]$v); $script:LblUsb=$k; $script:LblUsbV=$v
$script:BtnInfo = New-Btn "" 200 32; $script:BtnInfo.Location=[Drawing.Point]::new(16,230)
$script:BtnWake = New-Btn "" 200 32; $script:BtnWake.Location=[Drawing.Point]::new(230,230)
$script:HintDev = New-Lbl "" 980 50; $script:HintDev.Location=[Drawing.Point]::new(16,275); $script:HintDev.ForeColor=$Muted
$script:BtnInfo.Add_Click({ Work { Refresh-Info } })
$script:BtnWake.Add_Click({ Work { [void](AdbX (TA @("shell","input","keyevent","KEYCODE_WAKEUP"))) } })
$p0.Controls.AddRange(@($script:LblInfo,$script:BtnInfo,$script:BtnWake,$script:HintDev))

# tab apps
$script:BtnApk = New-Btn "" 244 32
$script:BtnApkObb = New-Btn "" 244 32
$script:BtnData = New-Btn "" 244 32
$script:BtnObb = New-Btn "" 244 32
$script:BtnList = New-Btn "" 320 36
$script:BtnExtract = New-Btn "" 10 10
$script:BtnBackup = New-Btn "" 10 10
$script:BtnUn = New-Btn "" 10 10
$script:BtnLaunch = New-Btn "" 10 10
$script:BtnExtract.Visible = $false
$script:BtnBackup.Visible = $false
$script:BtnUn.Visible = $false
$script:BtnLaunch.Visible = $false
$script:GrpInstall = New-Object Windows.Forms.GroupBox
$script:GrpInstall.ForeColor = $Y; $script:GrpInstall.BackColor = $Bg
$script:GrpInstall.Location = [Drawing.Point]::new(16,10)
$script:GrpInstall.Size = [Drawing.Size]::new(1060,100)
$script:BtnApk.Location=[Drawing.Point]::new(16,36)
$script:BtnApkObb.Location=[Drawing.Point]::new(276,36)
$script:BtnData.Location=[Drawing.Point]::new(536,36)
$script:BtnObb.Location=[Drawing.Point]::new(796,36)
$script:GrpInstall.Controls.AddRange(@($script:BtnApk,$script:BtnApkObb,$script:BtnData,$script:BtnObb))
$script:GrpManage = New-Object Windows.Forms.GroupBox
$script:GrpManage.ForeColor = $Y; $script:GrpManage.BackColor = $Bg
$script:GrpManage.Location = [Drawing.Point]::new(16,122)
$script:GrpManage.Size = [Drawing.Size]::new(1060,90)
$script:BtnList.Location=[Drawing.Point]::new(16,32)
$script:GrpManage.Controls.Add($script:BtnList)
$script:HintApps = New-Lbl "" 1060 48; $script:HintApps.Location=[Drawing.Point]::new(16,224); $script:HintApps.ForeColor=[Drawing.Color]::FromArgb(210,210,210)
$p1.Controls.AddRange(@($script:GrpInstall,$script:GrpManage,$script:HintApps))

$script:BtnApk.Add_Click({ Work {
    $d = New-Object Windows.Forms.OpenFileDialog
    $d.Filter="APK (*.apk)|*.apk"; $d.Title=(T pickApk)
    if ($d.ShowDialog() -ne "OK") { return }
    if (-not (Ask ((T askInstall) + "`r`n" + $d.FileName))) { return }
    [void](AdbX (TA @("install","-r","-g",$d.FileName)) 300000)
}})
$script:BtnApkObb.Add_Click({ Work {
    $d = New-Object Windows.Forms.OpenFileDialog
    $d.Filter="APK (*.apk)|*.apk"; $d.Title=(T pickApk)
    if ($d.ShowDialog() -ne "OK") { return }
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    $fb.Description = T pickFolder
    if ($fb.ShowDialog() -ne "OK") { return }
    $pkg = Infer-PkgFromObb $fb.SelectedPath
    $pkg2 = Ask-Text (T copyObb) (T pkgPrompt) $pkg
    if (-not $pkg2 -or -not (Test-Pkg $pkg2)) { Alert (T pkgInvalid); return }
    if (-not (Ask (T askInstall))) { return }
    $r = AdbX (TA @("install","-r","-g",$d.FileName)) 300000
    if ($r.Code -ne 0) { return }
    Copy-ToStdPath -Kind "obb" -Pkg $pkg2 -LocalPath $fb.SelectedPath
}})
$script:BtnData.Add_Click({ Work {
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne "OK") { return }
    $pkg = Infer-PkgFromObb $fb.SelectedPath
    if (-not $pkg) { $pkg = Split-Path $fb.SelectedPath -Leaf }
    Copy-ToStdPath -Kind "data" -Pkg $pkg -LocalPath $fb.SelectedPath
}})
$script:BtnObb.Add_Click({ Work {
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne "OK") { return }
    $pkg = Infer-PkgFromObb $fb.SelectedPath
    if (-not $pkg) { $pkg = Split-Path $fb.SelectedPath -Leaf }
    Copy-ToStdPath -Kind "obb" -Pkg $pkg -LocalPath $fb.SelectedPath
}})
$script:BtnList.Add_Click({ Work { [void](Show-AppManager) } })
$script:BtnExtract.Add_Click({ Work {
    $pkg = Pick-Pkg
    if (-not $pkg) { return }
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne "OK") { return }
    $r = Invoke-Adb (TA @("shell","pm","path",$pkg))
    $n=0
    foreach ($l in ($r.Text -split "`r?`n")) {
        if ($l -match 'package:(/.+)$') {
            $remote = $Matches[1]
            $leaf = Split-Path $remote -Leaf
            $local = Join-Path $fb.SelectedPath ("{0}-{1}" -f $pkg,$leaf)
            [void](AdbX (TA @("pull",$remote,$local)) 300000)
            $n++
        }
    }
    if ($n -eq 0) { Write-Log $r.Text "err" } else { Alert (T saved) }
}})
$script:BtnBackup.Add_Click({ Work {
    $pkg = Pick-Pkg
    if (-not $pkg) { return }
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne "OK") { return }
    Backup-AppTo $pkg $fb.SelectedPath
}})
$script:BtnUn.Add_Click({ Work {
    $pkg = Pick-Pkg
    if (-not $pkg) { return }
    if (-not (Test-Pkg $pkg)) { return }
    if (-not (Ask ((T askUninstall) + "`r`n" + $pkg))) { return }
    [void](AdbX (TA @("uninstall",$pkg)))
}})
$script:BtnLaunch.Add_Click({ Work {
    $pkg = Pick-Pkg
    if (-not $pkg) { return }
    [void](AdbX (TA @("shell","monkey","-p",$pkg,"-c","android.intent.category.LAUNCHER","1")))
}})

# tab files
$script:LblFm = New-Lbl "" 300 20; $script:LblFm.Location=[Drawing.Point]::new(12,8); $script:LblFm.ForeColor=$Y
$script:TxtPath = New-Object Windows.Forms.TextBox
$script:TxtPath.Width=520; $script:TxtPath.Location=[Drawing.Point]::new(12,32)
$script:TxtPath.BackColor=$Bg3; $script:TxtPath.ForeColor=$Tx; $script:TxtPath.BorderStyle="FixedSingle"
$script:TxtPath.Text=$script:RemotePath
$script:BtnGo = New-Btn "" 70 24; $script:BtnGo.Location=[Drawing.Point]::new(540,31)
$script:BtnUp = New-Btn "" 80 24; $script:BtnUp.Location=[Drawing.Point]::new(616,31)
$script:Lv = New-Object Windows.Forms.ListView
$script:Lv.View="Details"; $script:Lv.FullRowSelect=$true; $script:Lv.HideSelection=$false
$script:Lv.BackColor=[Drawing.Color]::FromArgb(12,12,12); $script:Lv.ForeColor=[Drawing.Color]::FromArgb(240,240,240)
$script:Lv.Location=[Drawing.Point]::new(12,64); $script:Lv.Size=[Drawing.Size]::new(700,200)
[void]$script:Lv.Columns.Add("Name", 480)
[void]$script:Lv.Columns.Add("Type", 180)
$script:Lv.Add_DoubleClick({
    if ($script:Lv.SelectedItems.Count -lt 1) { return }
    $tag = $script:Lv.SelectedItems[0].Tag
    if ($tag.Dir) {
        $script:RemotePath = Join-Remote $script:RemotePath $tag.Name
        Refresh-Files
    }
})
$script:Lv.Add_SelectedIndexChanged({
    $vis = $false
    if ($script:Lv.SelectedItems.Count -gt 0) {
        $tag = $script:Lv.SelectedItems[0].Tag
        if ($tag -and (-not $tag.Dir) -and ([string]$tag.Kind -eq "apk")) { $vis = $true }
    }
    if ($script:BtnInstApk) { $script:BtnInstApk.Visible = $vis }
})
$script:BtnMk = New-Btn "" 150 28; $script:BtnMk.Location=[Drawing.Point]::new(730,64)
$script:BtnPushF = New-Btn "" 150 28; $script:BtnPushF.Location=[Drawing.Point]::new(730,100)
$script:BtnPushD = New-Btn "" 150 28; $script:BtnPushD.Location=[Drawing.Point]::new(730,136)
$script:BtnPull = New-Btn "" 150 28; $script:BtnPull.Location=[Drawing.Point]::new(730,172)
$script:BtnRm = New-Btn "" 150 28; $script:BtnRm.Location=[Drawing.Point]::new(730,208)
$script:BtnInstApk = New-Btn "" 150 28; $script:BtnInstApk.Location=[Drawing.Point]::new(730,244)
$script:BtnInstApk.Visible = $false
$script:LblLegend = New-Lbl "" 120 18; $script:LblLegend.Location=[Drawing.Point]::new(12,268); $script:LblLegend.ForeColor=$Y
$script:LegendHost = New-Object Windows.Forms.FlowLayoutPanel
$script:LegendHost.Location=[Drawing.Point]::new(12,288)
$script:LegendHost.Size=[Drawing.Size]::new(880,36)
$script:LegendHost.BackColor=$Bg
$script:LegendHost.WrapContents = $false
$script:HintFiles = New-Lbl "" 980 18; $script:HintFiles.Location=[Drawing.Point]::new(12,326); $script:HintFiles.ForeColor=$Muted
$script:BtnGo.Add_Click({ Work { $script:RemotePath = $script:TxtPath.Text.Trim(); if (-not $script:RemotePath) { $script:RemotePath="/sdcard" }; Refresh-Files } })
$script:BtnUp.Add_Click({ Work {
    if ($script:RemotePath -eq "/" -or $script:RemotePath -eq "") { return }
    $parent = Split-Path $script:RemotePath -Parent
    if ([string]::IsNullOrWhiteSpace($parent)) { $parent = "/" }
    $script:RemotePath = ($parent -replace '\\','/')
    Refresh-Files
}})
$script:BtnMk.Add_Click({ Work {
    $n = Ask-Text (T mkdir) (T enterName)
    if (-not $n) { return }
    $n = ($n -replace '[\\/:*?"<>|]', '_')
    [void](AdbX (TA @("shell","mkdir","-p",(Join-Remote $script:RemotePath $n))))
    Refresh-Files
}})
$script:BtnPushF.Add_Click({ Work {
    $d = New-Object Windows.Forms.OpenFileDialog; $d.Filter="All (*.*)|*.*"
    if ($d.ShowDialog() -ne "OK") { return }
    [void](AdbX (TA @("push",$d.FileName,$script:RemotePath)) 300000)
    Refresh-Files
}})
$script:BtnPushD.Add_Click({ Work {
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne "OK") { return }
    [void](AdbX (TA @("push",$fb.SelectedPath,$script:RemotePath)) 300000)
    Refresh-Files
}})
$script:BtnPull.Add_Click({ Work {
    if ($script:Lv.SelectedItems.Count -lt 1) { Alert (T noSel); return }
    $fb = New-Object Windows.Forms.FolderBrowserDialog
    if ($fb.ShowDialog() -ne "OK") { return }
    $name = [string]$script:Lv.SelectedItems[0].Tag.Name
    $remote = Join-Remote $script:RemotePath $name
    [void](AdbX (TA @("pull",$remote,$fb.SelectedPath)) 300000)
}})
$script:BtnRm.Add_Click({ Work {
    if ($script:Lv.SelectedItems.Count -lt 1) { Alert (T noSel); return }
    $name = [string]$script:Lv.SelectedItems[0].Tag.Name
    $remote = Join-Remote $script:RemotePath $name
    if (-not (Ask ((T askDel) + "`r`n" + $remote))) { return }
    if ($script:Lv.SelectedItems[0].Tag.Dir) {
        [void](AdbX (TA @("shell","rm","-rf",$remote)))
    } else {
        [void](AdbX (TA @("shell","rm","-f",$remote)))
    }
    Refresh-Files
}})
$script:BtnInstApk.Add_Click({ Work {
    if ($script:Lv.SelectedItems.Count -lt 1) { Alert (T noSel); return }
    $tag = $script:Lv.SelectedItems[0].Tag
    if (-not $tag -or $tag.Dir -or $tag.Kind -ne "apk") { return }
    $remote = Join-Remote $script:RemotePath $tag.Name
    if (-not (Ask ((T askInstall) + "`r`n" + $remote))) { return }
    $r = AdbX (TA @("shell","pm","install","-r","-g",$remote)) 300000
    if ($r.Code -ne 0 -or ($r.Text -match '(?i)error|fail|denied')) {
        $tmp = Join-Path $env:TEMP ("ltc-install-" + [guid]::NewGuid().ToString("N") + ".apk")
        $p2r = AdbX (TA @("pull",$remote,$tmp)) 300000
        if ($p2r.Code -eq 0) {
            [void](AdbX (TA @("install","-r","-g",$tmp)) 300000)
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        }
    }
}})
function Build-Legend {
    if (-not $script:LegendHost) { return }
    $script:LegendHost.Controls.Clear()
    $pairs = @(
        @("dir", (T lgDir)),
        @("apk", (T lgApk)),
        @("obb", (T lgObb)),
        @("zip", (T lgZip)),
        @("img", (T lgImg)),
        @("vid", (T lgVid)),
        @("aud", (T lgAud)),
        @("txt", (T lgTxt)),
        @("other", (T lgOther))
    )
    foreach ($pair in $pairs) {
        $dot = New-Object Windows.Forms.Panel
        $dot.Size = [Drawing.Size]::new(12,12)
        $dot.Margin = New-Object Windows.Forms.Padding(8,6,4,0)
        $dot.BackColor = Get-KindColor $pair[0]
        $lab = New-Lbl $pair[1] 90 18
        $lab.ForeColor = Get-KindColor $pair[0]
        $lab.AutoSize = $true
        $lab.Margin = New-Object Windows.Forms.Padding(0,2,6,0)
        [void]$script:LegendHost.Controls.Add($dot)
        [void]$script:LegendHost.Controls.Add($lab)
    }
}
$p2.Controls.AddRange(@($script:LblFm,$script:TxtPath,$script:BtnGo,$script:BtnUp,$script:Lv,$script:BtnMk,$script:BtnPushF,$script:BtnPushD,$script:BtnPull,$script:BtnRm,$script:BtnInstApk,$script:LblLegend,$script:LegendHost,$script:HintFiles))

# tab tools
$tools = @()
$script:BtnSet = New-Btn "" 250 32
$script:BtnDate = New-Btn "" 250 32
$script:BtnDevSet = New-Btn "" 250 32
$script:BtnTime = New-Btn "" 250 32
$script:BtnMtp = New-Btn "" 250 32
$script:BtnAdbR = New-Btn "" 250 32
$script:BtnKeys = New-Btn "" 250 32
$script:BtnDevKeys = New-Btn "" 250 32
$script:BtnTcp = New-Btn "" 250 32
$script:BtnConn = New-Btn "" 250 32
$script:BtnDisc = New-Btn "" 250 32
$script:BtnReboot = New-Btn "" 250 32
$script:BtnRec = New-Btn "" 250 32
$script:BtnShot = New-Btn "" 250 32
$script:BtnCustom = New-Btn "" 250 32
foreach ($b in @($script:BtnSet,$script:BtnDate,$script:BtnDevSet,$script:BtnTime,$script:BtnMtp,$script:BtnAdbR,$script:BtnKeys,$script:BtnDevKeys,$script:BtnTcp,$script:BtnConn,$script:BtnDisc,$script:BtnReboot,$script:BtnRec,$script:BtnShot,$script:BtnCustom)) {
    $b.Width = 244; $b.Height = 30
}
$script:GrpSettings = New-Object Windows.Forms.GroupBox
$script:GrpSettings.ForeColor=$Y; $script:GrpSettings.BackColor=$Bg
$script:GrpSettings.Location=[Drawing.Point]::new(16,6)
$script:GrpSettings.Size=[Drawing.Size]::new(1060,92)
$script:BtnSet.Location=[Drawing.Point]::new(16,32)
$script:BtnDate.Location=[Drawing.Point]::new(276,32)
$script:BtnDevSet.Location=[Drawing.Point]::new(536,32)
$script:BtnTime.Location=[Drawing.Point]::new(796,32)
$script:GrpSettings.Controls.AddRange(@($script:BtnSet,$script:BtnDate,$script:BtnDevSet,$script:BtnTime))
$script:GrpConnBox = New-Object Windows.Forms.GroupBox
$script:GrpConnBox.ForeColor=$Y; $script:GrpConnBox.BackColor=$Bg
$script:GrpConnBox.Location=[Drawing.Point]::new(16,104)
$script:GrpConnBox.Size=[Drawing.Size]::new(1060,128)
$script:BtnMtp.Location=[Drawing.Point]::new(16,28)
$script:BtnAdbR.Location=[Drawing.Point]::new(276,28)
$script:BtnKeys.Location=[Drawing.Point]::new(536,28)
$script:BtnDevKeys.Location=[Drawing.Point]::new(796,28)
$script:BtnTcp.Location=[Drawing.Point]::new(16,70)
$script:BtnConn.Location=[Drawing.Point]::new(276,70)
$script:BtnDisc.Location=[Drawing.Point]::new(536,70)
$script:GrpConnBox.Controls.AddRange(@($script:BtnMtp,$script:BtnAdbR,$script:BtnKeys,$script:BtnDevKeys,$script:BtnTcp,$script:BtnConn,$script:BtnDisc))
$script:GrpPower = New-Object Windows.Forms.GroupBox
$script:GrpPower.ForeColor=$Y; $script:GrpPower.BackColor=$Bg
$script:GrpPower.Location=[Drawing.Point]::new(16,238)
$script:GrpPower.Size=[Drawing.Size]::new(1060,92)
$script:BtnReboot.Location=[Drawing.Point]::new(16,32)
$script:BtnRec.Location=[Drawing.Point]::new(276,32)
$script:BtnShot.Location=[Drawing.Point]::new(536,32)
$script:BtnCustom.Location=[Drawing.Point]::new(796,32)
$script:GrpPower.Controls.AddRange(@($script:BtnReboot,$script:BtnRec,$script:BtnShot,$script:BtnCustom))
$script:HintTools = New-Lbl "" 1060 24; $script:HintTools.Location=[Drawing.Point]::new(16,338); $script:HintTools.ForeColor=$Muted
$p3.Controls.AddRange(@($script:GrpSettings,$script:GrpConnBox,$script:GrpPower,$script:HintTools))
$p4.BackColor = [Drawing.Color]::FromArgb(250,250,250)
$script:LblHelp = New-Lbl "" 1040 28
$script:LblHelp.Location = [Drawing.Point]::new(16,12)
$script:LblHelp.ForeColor = [Drawing.Color]::FromArgb(20,20,20)
$script:LblHelp.BackColor = [Drawing.Color]::FromArgb(250,250,250)
$script:LblHelp.Font = New-Object Drawing.Font("Tahoma", 12, [Drawing.FontStyle]::Bold)
$script:HelpHost = New-Object Windows.Forms.Panel
$script:HelpHost.Location = [Drawing.Point]::new(16,48)
$script:HelpHost.Size = [Drawing.Size]::new(1060,330)
$script:HelpHost.AutoScroll = $true
$script:HelpHost.BackColor = [Drawing.Color]::White
$script:HelpHost.BorderStyle = "FixedSingle"
$script:TxtHelp = New-Object Windows.Forms.Label
$script:TxtHelp.AutoSize = $true
$script:TxtHelp.MaximumSize = [Drawing.Size]::new(1020,0)
$script:TxtHelp.Location = [Drawing.Point]::new(12,12)
$script:TxtHelp.ForeColor = [Drawing.Color]::FromArgb(25,25,25)
$script:TxtHelp.BackColor = [Drawing.Color]::White
$script:TxtHelp.Font = New-Object Drawing.Font("Tahoma", 10)
$script:HelpHost.Controls.Add($script:TxtHelp)
$p4.Controls.AddRange(@($script:LblHelp,$script:HelpHost))



function Start-Activity([string[]]$extra) { [void](AdbX (TA (@("shell","am","start") + $extra))) }
$script:BtnSet.Add_Click({ Work {
    $r = AdbX (TA @("shell","am","start","-a","android.settings.SETTINGS"))
    if ($r.Code -ne 0 -or ($r.Text -match 'Error')) {
        [void](AdbX (TA @("shell","am","start","-n","com.android.settings/.Settings")))
    }
}})
$script:BtnDate.Add_Click({ Work {
    $r = AdbX (TA @("shell","am","start","-a","android.settings.DATE_SETTINGS"))
    if ($r.Code -ne 0 -or ($r.Text -match 'Error')) {
        [void](AdbX (TA @("shell","am","start","-n",'com.android.settings/.Settings$DateTimeSettings')))
    }
}})
$script:BtnDevSet.Add_Click({ Work {
    [void](AdbX (TA @("shell","am","start","-a","android.settings.APPLICATION_DEVELOPMENT_SETTINGS")))
}})
$script:BtnTime.Add_Click({ Work {
    if (-not (Ask (T askTime))) { return }
    [void](AdbX (TA @("shell","settings","put","global","auto_time","0")))
    $fmt = (Get-Date).ToString("MMddHHmmyyyy.ss")
    $r = AdbX (TA @("shell","date",$fmt))
    [void](AdbX (TA @("shell","am","broadcast","-a","android.intent.action.TIME_SET")))
    if ($r.Code -ne 0 -or $r.Text -match 'denied|Permission') {
        Alert (T openDate)
        [void](AdbX (TA @("shell","am","start","-a","android.settings.DATE_SETTINGS")))
    }
}})
$script:BtnMtp.Add_Click({ Work {
    if (-not (Ask (T askMtp))) { return }
    $r = AdbX (TA @("shell","svc","usb","setFunctions","mtp,adb"))
    if ($r.Code -ne 0) { [void](AdbX (TA @("shell","svc","usb","setFunctions","mtp"))) }
}})
$script:BtnAdbR.Add_Click({ Work {
    [void](AdbX @("kill-server"))
    Start-Sleep -Milliseconds 500
    [void](AdbX @("start-server"))
    Update-Devices
}})
$script:BtnKeys.Add_Click({ Work {
    if (-not (Ask (T askKeys))) { return }
    [void](AdbX @("kill-server"))
    $dir = Join-Path $env:USERPROFILE ".android"
    foreach ($n in @("adbkey","adbkey.pub")) {
        $f = Join-Path $dir $n
        if (Test-Path -LiteralPath $f) {
            $bak = $f + ".bak-" + (Get-Date -Format "yyyyMMdd-HHmmss")
            Move-Item -LiteralPath $f -Destination $bak -Force
            Write-Log ("moved $f -> $bak") "ok"
        }
    }
    [void](AdbX @("start-server"))
    Update-Devices
    Alert (T ok)
}})
$script:BtnDevKeys.Add_Click({ Work {
    $r1 = AdbX (TA @("shell","rm","-f","/data/misc/adb/adb_keys"))
    $r2 = AdbX (TA @("shell","rm","-f","/adb_keys"))
    Write-Log "device key delete attempted" "info"
}})
$script:BtnTcp.Add_Click({ Work { [void](AdbX (TA @("tcpip","5555"))) } })
$script:BtnConn.Add_Click({ Work {
    $def = $script:LastIp
    if ($def) { $def = "$def`:5555" }
    $addr = Ask-Text (T connect) "IP:PORT" $def
    if (-not $addr) { return }
    if ($addr -notmatch '^\d{1,3}(\.\d{1,3}){3}:\d{2,5}$') { Alert (T err); return }
    [void](AdbX @("connect",$addr))
    Update-Devices
}})
$script:BtnDisc.Add_Click({ Work { [void](AdbX @("disconnect")); Update-Devices } })
$script:BtnReboot.Add_Click({ Work { if (Ask (T askReboot)) { [void](AdbX (TA @("reboot"))) } } })
$script:BtnRec.Add_Click({ Work { if (Ask (T askRec)) { [void](AdbX (TA @("reboot","recovery"))) } } })
$script:BtnShot.Add_Click({ Work {
    $s = New-Object Windows.Forms.SaveFileDialog
    $s.Filter="PNG (*.png)|*.png"; $s.FileName=("quest-{0}.png" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
    if ($s.ShowDialog() -ne "OK") { return }
    $rem="/sdcard/quest-adb-shot.png"
    [void](AdbX (TA @("shell","screencap","-p",$rem)))
    [void](AdbX (TA @("pull",$rem,$s.FileName)))
    [void](Invoke-Adb (TA @("shell","rm","-f",$rem)))
}})
$script:BtnCustom.Add_Click({ Work {
    $cmd = Ask-Text (T custom) "shell df /sdcard"
    if (-not $cmd) { return }
    $parts=@(); $cur=""; $q=$false
    foreach ($ch in $cmd.ToCharArray()) {
        if ($ch -eq [char]34) { $q = -not $q; continue }
        if ((-not $q) -and [char]::IsWhiteSpace($ch)) { if ($cur) { $parts+=$cur; $cur="" } }
        else { $cur += $ch }
    }
    if ($cur) { $parts += $cur }
    if ($parts.Count -eq 0) { return }
    $block=@("flash","oem","sideload","remount","disable-verity")
    if ($block -contains $parts[0].ToLowerInvariant()) { Alert (T err); return }
    [void](AdbX (TA $parts) 180000)
}})

# bottom log
$mid = New-Object Windows.Forms.Panel
$mid.Dock="Fill"; $mid.BackColor=$Bg
$logHead = New-Object Windows.Forms.Panel
$logHead.Dock="Top"; $logHead.Height=32; $logHead.BackColor=$Bg2
$script:LblLog = New-Lbl "" 200 22; $script:LblLog.Location=[Drawing.Point]::new(12,6)
$script:BtnClear = New-Btn "" 140 24; $script:BtnClear.Location=[Drawing.Point]::new(220,4)
$script:BtnClear.Add_Click({ $script:Log.Clear() })
$logHead.Controls.AddRange(@($script:LblLog,$script:BtnClear))
$script:Log = New-Object Windows.Forms.RichTextBox
$script:Log.Dock="Fill"; $script:Log.ReadOnly=$true
$script:Log.BackColor=[Drawing.Color]::FromArgb(12,12,12)
$script:Log.ForeColor=[Drawing.Color]::FromArgb(240,240,240)
$script:Log.Font = New-Object Drawing.Font("Consolas", 9)
$script:Log.BorderStyle="None"
$script:Log.RightToLeft="No"
$mid.Controls.Add($script:Log)
$mid.Controls.Add($logHead)

$bottom = New-Object Windows.Forms.Panel
$bottom.Dock="Bottom"; $bottom.Height=42; $bottom.BackColor=$Bg2
$script:Status = New-Lbl "" 700 20
$script:Status.Location = [Drawing.Point]::new(8,2)
$script:LblCo = New-Lbl "Lumen Technologies Co." 260 18
$script:LblCo.ForeColor = $Y
$script:LblCo.Location = [Drawing.Point]::new(8,20)
$script:LnkSite = New-Object Windows.Forms.LinkLabel
$script:LnkSite.Text = "https://LT-C.iddns.ir"
$script:LnkSite.Location = [Drawing.Point]::new(270,20)
$script:LnkSite.AutoSize = $true
$script:LnkSite.LinkColor = $Y
$script:LnkSite.ActiveLinkColor = [Drawing.Color]::White
$script:LnkSite.VisitedLinkColor = $Y
$script:LnkSite.BackColor = $Bg2
$script:LnkSite.Add_LinkClicked({ Start-Process "https://LT-C.iddns.ir" })
$bottom.Controls.Add($script:Status)
$bottom.Controls.Add($script:LblCo)
$bottom.Controls.Add($script:LnkSite)

$form.Controls.Add($mid)
$form.Controls.Add($script:Tabs)
$form.Controls.Add($bottom)
$form.Controls.Add($top)

try {
Apply-Lang
Build-Legend
Update-ConnLamp -Id '' -State ''
} catch {
    $msg = $_.Exception.ToString()
    try { $msg | Set-Content -LiteralPath (Join-Path $script:Root "ltc-error.txt") -Encoding UTF8 } catch {}
}

$form.Add_Shown({
    try { Apply-Logo } catch {}
    if ($script:Splash) {
        try { $script:Splash.Close(); $script:Splash.Dispose() } catch {}
        $script:Splash = $null
    }
    if (-not (Test-Path -LiteralPath $script:AdbPath)) {
        Write-Log (T noadb) "err"; Set-Status (T noadb)
        Alert (T noadb) (T err) Error
    } else {
        Write-Log $script:AdbPath "ok"
        [void](Invoke-Adb -AdbArgs @("start-server") -TimeoutMs 15000)
        Update-Devices
    }
})
$form.Add_FormClosed({ if ($script:InfoTimer) { $script:InfoTimer.Stop() } })

[void][Windows.Forms.Application]::Run($form)
