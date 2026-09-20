const FILES_API = "https://api.github.com/repos/MHMahdavi1391/VR/contents/files";
const RAW = "https://raw.githubusercontent.com/MHMahdavi1391/VR/main/files/";

const CATALOG = {
  "LTC Central Chat over wifi.apk": {
    id: "chat", icon: "CHAT", platforms: ["android"], kind: "app", rating: "4.8", age: "3+",
    en: { name: "LTC Central Chat", desc: "Local Wi-Fi messenger for teams and rooms. Works without the public internet.", news: "Stable local rooms and faster device discovery." },
    fa: { name: "چت مرکزی LTC", desc: "پیام‌رسان محلی روی وای‌فای برای تیم و اتاق‌ها. بدون نیاز به اینترنت عمومی.", news: "اتاق‌های پایدارتر و پیدا کردن سریع‌تر دستگاه‌ها." },
    ru: { name: "LTC Central Chat", desc: "Локальный Wi-Fi мессенджер для команд. Работает без интернета.", news: "Стабильные комнаты и быстрый поиск устройств." }
  },
  "LTC NAS Host.apk": {
    id: "nas", icon: "NAS", platforms: ["android"], kind: "app", rating: "4.6", age: "3+",
    en: { name: "LTC NAS Host", desc: "Turn an Android device into a simple file host for the local network.", news: "Cleaner host setup for local file sharing." },
    fa: { name: "میزبان NAS ال‌تی‌سی", desc: "دستگاه اندروید را به میزبان فایل ساده روی شبکه محلی تبدیل می‌کند.", news: "راه‌اندازی ساده‌تر برای اشتراک فایل محلی." },
    ru: { name: "LTC NAS Host", desc: "Превращает Android-устройство в простой файловый хост в локальной сети.", news: "Проще настраивать локальный обмен файлами." }
  },
  "LTC Quest Helper V2.rar": {
    id: "quest-v2", icon: "QUEST", platforms: ["windows", "quest"], kind: "app", featured: true, rating: "4.9", age: "12+",
    en: { name: "LTC Quest Helper V2", desc: "Official helper pack for Meta Quest setup, ADB tools and device checks.", news: "Version 2 is the recommended pack for Quest setup and diagnostics." },
    fa: { name: "کمک‌یار Quest نسخه ۲", desc: "بسته رسمی کمکی برای راه‌اندازی Meta Quest، ابزار ADB و بررسی دستگاه.", news: "نسخه ۲ بسته پیشنهادی برای راه‌اندازی و عیب‌یابی Quest است." },
    ru: { name: "LTC Quest Helper V2", desc: "Официальный набор для настройки Meta Quest, ADB и проверки устройства.", news: "Версия 2 рекомендуется для настройки и диагностики Quest." }
  },
  "LTC Quest Helper v1.rar": {
    id: "quest-v1", icon: "QUEST", platforms: ["windows", "quest"], kind: "app", rating: "4.1", age: "12+",
    en: { name: "LTC Quest Helper V1", desc: "Earlier Quest helper package. Prefer V2 when available.", news: "Kept for compatibility. Use V2 if you can." },
    fa: { name: "کمک‌یار Quest نسخه ۱", desc: "نسخه قدیمی‌تر بسته کمکی Quest. در صورت وجود از نسخه ۲ استفاده کنید.", news: "برای سازگاری نگه داشته شده. اگر می‌توانید از نسخه ۲ استفاده کنید." },
    ru: { name: "LTC Quest Helper V1", desc: "Предыдущая версия пакета Quest Helper. Рекомендуется V2.", news: "Оставлена для совместимости. Лучше использовать V2." }
  }
};

const I18N = {
  en: { title:"Lumen Store", kicker:"Official apps and files", lead:"The corporate store of Lumen Technologies Co. Download Android apps, Windows tools and Quest helpers from one place.", hub:"LTC Hub", search:"Search apps and files", all:"All", apps:"Apps", files:"Files", android:"Android", windows:"Windows", quest:"Quest", count:"items", loading:"Loading the store…", empty:"Nothing matches this filter.", error:"The store could not be loaded.", get:"Get", download:"Download", size:"Size", platform:"Platform", type:"Type", file:"File", featured:"Featured", close:"Close", catalog:"All products", rowApps:"Apps for your devices", rating:"Rating", age:"Age", news:"What’s new", publisher:"Publisher" },
  ru: { title:"Lumen Store", kicker:"Официальные приложения", lead:"Корпоративный магазин Lumen Technologies Co. Приложения Android, инструменты Windows и пакеты Quest.", hub:"LTC Hub", search:"Поиск приложений и файлов", all:"Все", apps:"Приложения", files:"Файлы", android:"Android", windows:"Windows", quest:"Quest", count:"шт.", loading:"Загрузка магазина…", empty:"Ничего не найдено.", error:"Не удалось открыть магазин.", get:"Скачать", download:"Скачать", size:"Размер", platform:"Платформа", type:"Тип", file:"Файл", featured:"Рекомендуем", close:"Закрыть", catalog:"Все продукты", rowApps:"Приложения для ваших устройств", rating:"Оценка", age:"Возраст", news:"Что нового", publisher:"Издатель" },
  fa: { title:"فروشگاه لومن", kicker:"برنامه‌ها و فایل‌های رسمی", lead:"فروشگاه شرکتی Lumen Technologies Co. برنامه‌های اندروید، ابزار ویندوز و کمک‌یار Quest در یک جا.", hub:"مرکز LTC", search:"جستجوی برنامه و فایل", all:"همه", apps:"برنامه‌ها", files:"فایل‌ها", android:"اندروید", windows:"ویندوز", quest:"Quest", count:"مورد", loading:"در حال بارگذاری فروشگاه...", empty:"موردی با این فیلتر پیدا نشد.", error:"فروشگاه در دسترس نیست.", get:"دریافت", download:"دانلود", size:"حجم", platform:"پلتفرم", type:"نوع", file:"فایل", featured:"ویژه", close:"بستن", catalog:"همه محصولات", rowApps:"برنامه‌های دستگاه شما", rating:"امتیاز", age:"رده سنی", news:"تازه‌ها", publisher:"ناشر" }
};

let STATE = { lang: "fa", filter: "all", q: "", files: [] };
function t() { return I18N[STATE.lang] || I18N.fa; }
function loc(meta) { return (meta && meta[STATE.lang]) || (meta && meta.en) || {}; }
function isAppName(name) { return /\.(apk|aab|ipa|exe|msi)$/i.test(name || "") || /quest helper/i.test(name || ""); }
function hrefOf(f) { return f.download_url || (RAW + encodeURIComponent(f.name)); }
function fmtSize(n) {
  if (!n && n !== 0) return "";
  if (n < 1024) return n + " B";
  if (n < 1048576) return (n / 1024).toFixed(1) + " KB";
  if (n < 1073741824) return (n / 1048576).toFixed(2) + " MB";
  return (n / 1073741824).toFixed(2) + " GB";
}
function extLabel(name) { return ((name.split(".").pop() || "FILE").toUpperCase()).slice(0, 5); }
function prettyFallback(name) { return name.replace(/\.(rar|zip|7z|exe|msi|apk|aab|ipa|txt)$/i, "").replace(/[_-]+/g, " ").trim(); }
function enrich(f) {
  const meta = CATALOG[f.name] || {};
  const L = loc(meta);
  const kind = meta.kind || (isAppName(f.name) ? "app" : "file");
  const platforms = meta.platforms || guessPlatforms(f.name);
  return { raw:f, name:f.name, title:L.name || prettyFallback(f.name), desc:L.desc || f.name, news:L.news || "", icon:meta.icon || extLabel(f.name), kind, platforms, featured:!!meta.featured, rating:meta.rating || "4.5", age:meta.age || "3+", size:f.size, href:hrefOf(f) };
}
function guessPlatforms(name) {
  const n = (name || "").toLowerCase();
  const out = [];
  if (n.endsWith(".apk") || n.endsWith(".aab")) out.push("android");
  if (n.endsWith(".exe") || n.endsWith(".msi")) out.push("windows");
  if (n.includes("quest")) out.push("quest", "windows");
  return out.length ? out : ["files"];
}
function matches(item) {
  const q = STATE.q.trim().toLowerCase();
  if (q) {
    const blob = (item.title + " " + item.desc + " " + item.name).toLowerCase();
    if (!blob.includes(q)) return false;
  }
  if (STATE.filter === "all") return true;
  if (STATE.filter === "apps") return item.kind === "app";
  if (STATE.filter === "files") return item.kind !== "app";
  return item.platforms.indexOf(STATE.filter) !== -1;
}
function applyChrome() {
  const d = t();
  document.documentElement.lang = STATE.lang;
  document.documentElement.dir = STATE.lang === "fa" ? "rtl" : "ltr";
  document.title = d.title + " | Lumen Technologies Co.";
  document.getElementById("t-title").textContent = d.title;
  document.getElementById("t-kicker").textContent = d.kicker;
  document.getElementById("t-lead").textContent = d.lead;
  document.getElementById("t-hub").textContent = d.hub;
  document.getElementById("search").placeholder = d.search;
  document.getElementById("catalog-title").textContent = d.catalog;
  document.getElementById("row-apps-title").textContent = d.rowApps;
  document.querySelectorAll(".langs button").forEach(function (b) { b.classList.toggle("active", b.dataset.lang === STATE.lang); });
  const chips = [["all", d.all],["apps", d.apps],["android", d.android],["windows", d.windows],["quest", d.quest],["files", d.files]];
  document.getElementById("chips").innerHTML = chips.map(function (c) {
    return '<button type="button" class="chip' + (STATE.filter === c[0] ? " active" : "") + '" data-filter="' + c[0] + '">' + c[1] + "</button>";
  }).join("");
  document.querySelectorAll("#chips .chip").forEach(function (b) {
    b.addEventListener("click", function () { STATE.filter = b.dataset.filter; render(); });
  });
}
function platformLabel(p) {
  const d = t();
  if (p === "android") return d.android;
  if (p === "windows") return d.windows;
  if (p === "quest") return d.quest;
  return d.files;
}
function cardHTML(item, featured) {
  const d = t();
  const pills = item.platforms.map(function (p) { return '<span class="pill">' + platformLabel(p) + "</span>"; }).join("");
  if (featured) {
    return '<article class="featured"><div class="icon">' + item.icon + "</div><div><span class=\"pill\">" + d.featured + "</span><h2>" + item.title + "</h2><p>" + item.desc + "</p><div class=\"meta\">" + pills + "<span class=\"pill stars\">★ " + item.rating + "</span><span class=\"pill\">" + fmtSize(item.size) + "</span></div></div><a class=\"get\" href=\"" + item.href + "\" download>" + d.get + "</a></article>";
  }
  return '<article class="card" data-name="' + encodeURIComponent(item.name) + '"><div class="card-top"><div class="icon-sm">' + item.icon + "</div><div><h3>" + item.title + "</h3><div class=\"sub\">★ " + item.rating + " · " + fmtSize(item.size) + " · " + extLabel(item.name) + "</div></div></div><p class="desc">" + item.desc + "</p><div class="card-foot"><div>" + pills + "</div><a class="get" href="' + item.href + '" download onclick="event.stopPropagation()">' + d.get + "</a></div></article>";
}
function openSheet(item) {
  const d = t();
  const pills = item.platforms.map(function (p) { return platformLabel(p); }).join(" · ");
  document.getElementById("sheet-body").innerHTML =
    '<div class="sheet-hero"><div class="icon-sm">' + item.icon + "</div><div><h2>" + item.title + "</h2><p>" + item.desc + "</p><div class=\"meta\" style=\"margin-top:8px\"><span class=\"stars\">★ " + item.rating + "</span></div></div></div>" +
    '<div class="sheet-actions"><a class="get" href="' + item.href + '" download>' + d.download + "</a><a class="ghost" href="' + item.href + '" target="_blank" rel="noopener">' + item.name + "</a></div>" +
    '<div class="facts"><div class="fact"><b>' + d.size + "</b>" + fmtSize(item.size) + "</div><div class="fact"><b>" + d.platform + "</b>" + pills + "</div><div class="fact"><b>" + d.publisher + "</b>Lumen Technologies Co.</div><div class="fact"><b>" + d.rating + "</b>★ " + item.rating + "</div><div class="fact"><b>" + d.age + "</b>" + item.age + "</div><div class="fact"><b>" + d.type + "</b>" + extLabel(item.name) + "</div></div>" +
    (item.news ? '<div class="whatsnew"><h3>' + d.news + "</h3><p>" + item.news + "</p></div>" : "");
  document.getElementById("sheet").hidden = false;
}
function closeSheet() { document.getElementById("sheet").hidden = true; }
function usable(x) { return x.name !== "README.txt" && x.name !== ".gitkeep" && x.size > 32; }
function render() {
  applyChrome();
  const d = t();
  const items = STATE.files.map(enrich).filter(usable);
  const featured = items.find(function (x) { return x.featured; }) || items[0];
  document.getElementById("featured").innerHTML = featured ? cardHTML(featured, true) : "";
  const apps = items.filter(function (x) { return x.kind === "app"; });
  const row = document.getElementById("row-apps");
  if (apps.length && STATE.filter === "all" && !STATE.q.trim()) {
    row.hidden = false;
    document.getElementById("row-apps-grid").innerHTML = apps.map(function (x) { return cardHTML(x, false); }).join("");
  } else { row.hidden = true; }
  const list = items.filter(matches);
  document.getElementById("result-count").textContent = list.length ? list.length + " " + d.count : "";
  document.getElementById("grid").innerHTML = list.length ? list.map(function (x) { return cardHTML(x, false); }).join("") : '<div class="empty">' + d.empty + "</div>";
  document.querySelectorAll(".card").forEach(function (el) {
    el.addEventListener("click", function () {
      const name = decodeURIComponent(el.dataset.name);
      const item = items.find(function (x) { return x.name === name; });
      if (item) openSheet(item);
    });
  });
}
async function loadFiles() {
  const d = t();
  document.getElementById("grid").innerHTML = '<div class="empty">' + d.loading + "</div>";
  try {
    const res = await fetch(FILES_API);
    if (!res.ok) throw new Error(String(res.status));
    const data = await res.json();
    STATE.files = (Array.isArray(data) ? data : []).filter(function (x) { return x.type === "file"; });
    render();
  } catch (e) {
    document.getElementById("grid").innerHTML = '<div class="empty">' + t().error + "</div>";
  }
}
document.querySelectorAll(".langs button").forEach(function (b) {
  b.addEventListener("click", function () { STATE.lang = b.dataset.lang; localStorage.setItem("ltc-lang", STATE.lang); render(); });
});
document.getElementById("search").addEventListener("input", function (e) { STATE.q = e.target.value || ""; render(); });
document.getElementById("sheet").addEventListener("click", function (e) { if (e.target.hasAttribute("data-close")) closeSheet(); });
document.addEventListener("keydown", function (e) { if (e.key === "Escape") closeSheet(); });
STATE.lang = localStorage.getItem("ltc-lang") || "fa";
applyChrome();
loadFiles();
