const FILES_API = "https://api.github.com/repos/MHMahdavi1391/VR/contents/files";
const RAW = "https://raw.githubusercontent.com/MHMahdavi1391/VR/main/files/";
const CATALOG = {
  "LTC Central Chat over wifi.apk": {
    en: { name: "LTC Central Chat", desc: "Local Wi-Fi messenger for teams and rooms." },
    fa: { name: "چت مرکزی LTC", desc: "پیام‌رسان محلی روی وای‌فای برای تیم و اتاق‌ها." },
    ru: { name: "LTC Central Chat", desc: "Локальный Wi-Fi мессенджер для команд." }
  },
  "LTC NAS Host.apk": {
    en: { name: "LTC NAS Host", desc: "Turn an Android device into a simple file host." },
    fa: { name: "میزبان NAS ال‌تی‌سی", desc: "دستگاه اندروید را به میزبان فایل ساده تبدیل می‌کند." },
    ru: { name: "LTC NAS Host", desc: "Простой файловый хост на Android." }
  },
  "LTC Quest Helper V2.rar": {
    en: { name: "LTC Quest Helper V2", desc: "Helper pack for Meta Quest setup and ADB tools." },
    fa: { name: "کمک‌یار Quest نسخه ۲", desc: "بسته کمکی برای راه‌اندازی Meta Quest و ابزار ADB." },
    ru: { name: "LTC Quest Helper V2", desc: "Набор для настройки Meta Quest и ADB." }
  },
  "LTC Quest Helper v1.rar": {
    en: { name: "LTC Quest Helper V1", desc: "Earlier helper package. Prefer V2 when available." },
    fa: { name: "کمک‌یار Quest نسخه ۱", desc: "نسخه قدیمی‌تر. در صورت وجود از نسخه ۲ استفاده کنید." },
    ru: { name: "LTC Quest Helper V1", desc: "Предыдущая версия. Рекомендуется V2." }
  }
};
const I18N = {
  en: { title: "Lumen Store", lead: "Official files of Lumen Technologies Co.", hub: "LTC Hub", search: "Search files", count: "items", loading: "Loading…", empty: "No files found.", error: "The store could not be loaded.", get: "Download", size: "Size", format: "Format" },
  ru: { title: "Lumen Store", lead: "Официальные файлы Lumen Technologies Co.", hub: "LTC Hub", search: "Поиск файлов", count: "шт.", loading: "Загрузка…", empty: "Файлы не найдены.", error: "Не удалось открыть магазин.", get: "Скачать", size: "Размер", format: "Формат" },
  fa: { title: "فروشگاه لومن", lead: "فایل‌های رسمی Lumen Technologies Co.", hub: "مرکز LTC", search: "جستجوی فایل", count: "مورد", loading: "در حال بارگذاری...", empty: "فایلی پیدا نشد.", error: "فروشگاه در دسترس نیست.", get: "دانلود", size: "حجم", format: "فرمت" }
};
let STATE = { lang: "fa", q: "", files: [] };
function t() { return I18N[STATE.lang] || I18N.fa; }
function loc(meta) { return (meta && meta[STATE.lang]) || (meta && meta.en) || {}; }
function hrefOf(f) { return f.download_url || (RAW + encodeURIComponent(f.name)); }
function fmtSize(n) {
  if (!n && n !== 0) return "";
  if (n < 1024) return n + " B";
  if (n < 1048576) return (n / 1024).toFixed(1) + " KB";
  if (n < 1073741824) return (n / 1048576).toFixed(2) + " MB";
  return (n / 1073741824).toFixed(2) + " GB";
}
function extLabel(name) { return ((name.split(".").pop() || "FILE").toUpperCase()); }
function prettyFallback(name) { return name.replace(/\.[^.]+$/, "").replace(/[_-]+/g, " ").trim(); }
function enrich(f) {
  const L = loc(CATALOG[f.name] || {});
  return { name: f.name, title: L.name || prettyFallback(f.name), desc: L.desc || "", format: extLabel(f.name), size: f.size, href: hrefOf(f) };
}
function usable(x) { return x.name !== "README.txt" && x.name !== ".gitkeep" && x.size > 32; }
function matches(item) {
  const q = STATE.q.trim().toLowerCase();
  if (!q) return true;
  return (item.title + " " + item.desc + " " + item.name + " " + item.format).toLowerCase().includes(q);
}
function applyChrome() {
  const d = t();
  document.documentElement.lang = STATE.lang;
  document.documentElement.dir = STATE.lang === "fa" ? "rtl" : "ltr";
  document.title = d.title + " | Lumen Technologies Co.";
  document.getElementById("t-title").textContent = d.title;
  document.getElementById("t-lead").textContent = d.lead;
  document.getElementById("t-hub").textContent = d.hub;
  document.getElementById("search").placeholder = d.search;
  document.querySelectorAll(".langs button").forEach(function (b) { b.classList.toggle("active", b.dataset.lang === STATE.lang); });
}
function cardHTML(item) {
  const d = t();
  return '<article class="card"><div><h3>' + item.title + "</h3>" + (item.desc ? '<p class="desc">' + item.desc + "</p>" : "") + '<div class="meta"><span class="pill">' + d.format + " " + item.format + "</span><span class=\"pill\">" + d.size + " " + fmtSize(item.size) + "</span></div></div><a class=\"get\" href=\"" + item.href + "\" download>" + d.get + "</a></article>";
}
function render() {
  applyChrome();
  const d = t();
  const items = STATE.files.map(enrich).filter(usable).filter(matches);
  document.getElementById("result-count").textContent = items.length ? items.length + " " + d.count : "";
  document.getElementById("grid").innerHTML = items.length ? items.map(cardHTML).join("") : '<div class="empty">' + d.empty + "</div>";
}
async function loadFiles() {
  document.getElementById("grid").innerHTML = '<div class="empty">' + t().loading + "</div>";
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
STATE.lang = localStorage.getItem("ltc-lang") || "fa";
applyChrome();
loadFiles();
