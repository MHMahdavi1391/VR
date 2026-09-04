const FILES_API = "https://api.github.com/repos/MHMahdavi1391/VR/contents/files";
const RAW = "https://raw.githubusercontent.com/MHMahdavi1391/VR/main/files/";

const I18N = {
  en: {
    title: "LTC VR",
    kicker: "Lumen Technologies Co.",
    lead: "Official builds for Quest and Android.",
    cta: "Open library",
    files: "Library",
    count: "packages",
    loading: "Loading...",
    empty: "No package is published yet.",
    error: "The library could not be loaded.",
    download: "Download",
    size: "Size"
  },
  ru: {
    title: "LTC VR",
    kicker: "Lumen Technologies Co.",
    lead: "Официальные сборки для Quest и Android.",
    cta: "Библиотека",
    files: "Библиотека",
    count: "пакетов",
    loading: "Загрузка...",
    empty: "Пока нет опубликованных пакетов.",
    error: "Не удалось открыть библиотеку.",
    download: "Скачать",
    size: "Размер"
  },
  fa: {
    title: "LTC VR",
    kicker: "Lumen Technologies Co.",
    lead: "نسخه‌های رسمی برای هدست Quest و اندروید.",
    cta: "ورود به کتابخانه",
    files: "کتابخانه",
    count: "بسته",
    loading: "در حال بارگذاری...",
    empty: "هنوز بسته‌ای منتشر نشده.",
    error: "کتابخانه در دسترس نیست.",
    download: "دانلود",
    size: "حجم"
  }
};

function t(lang) { return I18N[lang] || I18N.fa; }

function applyLang(lang) {
  const d = t(lang);
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "fa" ? "rtl" : "ltr";
  document.title = d.title + " | Lumen Technologies Co.";
  document.getElementById("t-title").textContent = d.title;
  document.getElementById("t-kicker").textContent = d.kicker;
  document.getElementById("t-lead").textContent = d.lead;
  document.getElementById("t-cta").textContent = d.cta;
  document.getElementById("t-files").textContent = d.files;
  document.querySelectorAll(".langs button").forEach(function (b) {
    b.classList.toggle("active", b.dataset.lang === lang);
  });
  localStorage.setItem("ltc-lang", lang);
  renderFiles(window.__files || [], lang);
}

function fmtSize(n) {
  if (!n && n !== 0) return "";
  if (n < 1024) return n + " B";
  if (n < 1048576) return (n / 1024).toFixed(1) + " KB";
  return (n / 1048576).toFixed(2) + " MB";
}

function extLabel(name) {
  const p = (name.split(".").pop() || "").toUpperCase();
  if (["RAR", "ZIP", "7Z"].indexOf(p) >= 0) return p;
  if (p === "EXE") return "EXE";
  if (p === "APK") return "APK";
  return "FILE";
}

function prettyName(name) {
  return name.replace(/\.(rar|zip|7z|exe|apk)$/i, "").replace(/[_]+/g, " ").trim();
}

function renderFiles(items, lang) {
  const box = document.getElementById("file-list");
  const count = document.getElementById("file-count");
  const d = t(lang);
  const files = (items || []).filter(function (x) {
    return x.type === "file" && x.name !== "README.txt" && x.name !== ".gitkeep";
  });
  count.textContent = files.length ? files.length + " " + d.count : "";
  if (!files.length) {
    box.innerHTML = "<div class=\"empty\">" + d.empty + "</div>";
    return;
  }
  box.innerHTML = files.map(function (f) {
    const href = f.download_url || (RAW + encodeURIComponent(f.name));
    return (
      "<article class=\"file\">" +
        "<div class=\"kind\">" + extLabel(f.name) + "</div>" +
        "<div class=\"meta\"><div class=\"name\">" + prettyName(f.name) + "</div>" +
        "<div class=\"sub\">" + f.name + " · " + d.size + " " + fmtSize(f.size) + "</div></div>" +
        "<a class=\"dl\" href=\"" + href + "\" download>" + d.download + "</a>" +
      "</article>"
    );
  }).join("");
}

async function loadFiles() {
  const lang = localStorage.getItem("ltc-lang") || "fa";
  const box = document.getElementById("file-list");
  box.innerHTML = "<div class=\"empty\">" + t(lang).loading + "</div>";
  try {
    const res = await fetch(FILES_API);
    if (!res.ok) throw new Error(String(res.status));
    const data = await res.json();
    window.__files = Array.isArray(data) ? data : [];
    renderFiles(window.__files, lang);
  } catch (e) {
    box.innerHTML = "<div class=\"empty\">" + t(lang).error + "</div>";
  }
}

document.querySelectorAll(".langs button").forEach(function (b) {
  b.addEventListener("click", function () { applyLang(b.dataset.lang); });
});
applyLang(localStorage.getItem("ltc-lang") || "fa");
loadFiles();
