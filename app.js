const FILES_API = "https://api.github.com/repos/MHMahdavi1391/VR/contents/files";
const RAW = "https://raw.githubusercontent.com/MHMahdavi1391/VR/main/files/";

const I18N = {
  en: {
    title: "Lumen Library",
    kicker: "Lumen Technologies Co.",
    lead: "Official apps and files from Lumen Technologies Co.",
    cta: "Open library",
    apps: "Apps",
    files: "Files",
    count: "items",
    loading: "Loading...",
    emptyApps: "No app package is published yet.",
    emptyFiles: "No extra file is published yet.",
    error: "The library could not be loaded.",
    download: "Download",
    size: "Size"
  },
  ru: {
    title: "Lumen Library",
    kicker: "Lumen Technologies Co.",
    lead: "Официальные приложения и файлы LTC.",
    cta: "Библиотека",
    apps: "Приложения",
    files: "Файлы",
    count: "файлов",
    loading: "Загрузка...",
    emptyApps: "Пока нет приложений.",
    emptyFiles: "Пока нет дополнительных файлов.",
    error: "Не удалось открыть библиотеку.",
    download: "Скачать",
    size: "Размер"
  },
  fa: {
    title: "کتابخانه لومن",
    kicker: "Lumen Technologies Co.",
    lead: "برنامه‌ها و فایل‌های رسمی شرکت Lumen Technologies Co.",
    cta: "ورود به کتابخانه",
    apps: "برنامه‌ها",
    files: "فایل‌ها",
    count: "مورد",
    loading: "در حال بارگذاری...",
    emptyApps: "هنوز برنامه‌ای منتشر نشده.",
    emptyFiles: "هنوز فایل اضافه‌ای منتشر نشده.",
    error: "کتابخانه در دسترس نیست.",
    download: "دانلود",
    size: "حجم"
  }
};

function t(lang) { return I18N[lang] || I18N.fa; }
function isApp(name) {
  return /\.(apk|aab|ipa|exe|msi)$/i.test(name || "");
}
function applyLang(lang) {
  const d = t(lang);
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "fa" ? "rtl" : "ltr";
  document.title = d.title + " | Lumen Technologies Co.";
  document.getElementById("t-title").textContent = d.title;
  document.getElementById("t-kicker").textContent = d.kicker;
  document.getElementById("t-lead").textContent = d.lead;
  document.getElementById("t-cta").textContent = d.cta;
  document.getElementById("t-apps").textContent = d.apps;
  document.getElementById("t-files").textContent = d.files;
  document.querySelectorAll(".langs button").forEach(function (b) {
    b.classList.toggle("active", b.dataset.lang === lang);
  });
  localStorage.setItem("ltc-lang", lang);
  renderAll(window.__files || [], lang);
}
function fmtSize(n) {
  if (!n && n !== 0) return "";
  if (n < 1024) return n + " B";
  if (n < 1048576) return (n / 1024).toFixed(1) + " KB";
  return (n / 1048576).toFixed(2) + " MB";
}
function extLabel(name) {
  const p = (name.split(".").pop() || "").toUpperCase();
  return p || "FILE";
}
function prettyName(name) {
  return name.replace(/\.(rar|zip|7z|exe|msi|apk|aab|ipa|txt)$/i, "").replace(/[_-]+/g, " ").trim();
}
function card(f, d) {
  const href = f.download_url || (RAW + encodeURIComponent(f.name));
  return (
    "<article class=\"file\">" +
      "<div class=\"kind\">" + extLabel(f.name) + "</div>" +
      "<div class=\"meta\"><div class=\"name\">" + prettyName(f.name) + "</div>" +
      "<div class=\"sub\">" + f.name + " · " + d.size + " " + fmtSize(f.size) + "</div></div>" +
      "<a class=\"dl\" href=\"" + href + "\" download>" + d.download + "</a>" +
    "</article>"
  );
}
function renderAll(items, lang) {
  const d = t(lang);
  const all = (items || []).filter(function (x) {
    return x.type === "file" && x.name !== "README.txt" && x.name !== ".gitkeep";
  });
  const apps = all.filter(function (x) { return isApp(x.name); });
  const files = all.filter(function (x) { return !isApp(x.name); });
  document.getElementById("app-count").textContent = apps.length ? apps.length + " " + d.count : "";
  document.getElementById("file-count").textContent = files.length ? files.length + " " + d.count : "";
  document.getElementById("app-list").innerHTML = apps.length
    ? apps.map(function (f) { return card(f, d); }).join("")
    : "<div class=\"empty\">" + d.emptyApps + "</div>";
  document.getElementById("file-list").innerHTML = files.length
    ? files.map(function (f) { return card(f, d); }).join("")
    : "<div class=\"empty\">" + d.emptyFiles + "</div>";
}
async function loadFiles() {
  const lang = localStorage.getItem("ltc-lang") || "fa";
  document.getElementById("app-list").innerHTML = "<div class=\"empty\">" + t(lang).loading + "</div>";
  document.getElementById("file-list").innerHTML = "<div class=\"empty\">" + t(lang).loading + "</div>";
  try {
    const res = await fetch(FILES_API);
    if (!res.ok) throw new Error(String(res.status));
    const data = await res.json();
    window.__files = Array.isArray(data) ? data : [];
    renderAll(window.__files, lang);
  } catch (e) {
    const msg = "<div class=\"empty\">" + t(lang).error + "</div>";
    document.getElementById("app-list").innerHTML = msg;
    document.getElementById("file-list").innerHTML = msg;
  }
}
document.querySelectorAll(".langs button").forEach(function (b) {
  b.addEventListener("click", function () { applyLang(b.dataset.lang); });
});
applyLang(localStorage.getItem("ltc-lang") || "fa");
loadFiles();
