const OWNER = "MHMahdavi1391";
const REPO = "VR";
const FILES_API = "https://api.github.com/repos/MHMahdavi1391/VR/contents/files";
const RAW = "https://raw.githubusercontent.com/MHMahdavi1391/VR/main/files/";

const I18N = {
  en: {
    title: "VR Hub",
    company: "Lumen Technologies Co.",
    lead: "VR files and services. Choose a package from the list and download it.",
    services: "VR services",
    s1t: "LTC Quest Helper",
    s1b: "Windows helper for Meta Quest and Android devices. ADB tools, file manager, backup and install.",
    s2t: "VR packages",
    s2b: "Zip files placed in the files folder of this repository appear in the download list.",
    files: "Downloads",
    hint: "Everything inside the files folder is listed here.",
    loading: "Loading file list...",
    empty: "No files yet. Add zip files to the files folder in this repository.",
    error: "Could not read the files folder.",
    download: "Download",
    size: "Size"
  },
  ru: {
    title: "VR Hub",
    company: "Lumen Technologies Co.",
    lead: "VR-файлы и сервисы. Выберите пакет из списка и скачайте его.",
    services: "VR-сервисы",
    s1t: "LTC Quest Helper",
    s1b: "Помощник Windows для Meta Quest и Android. ADB, файлы, резервные копии и установка.",
    s2t: "VR-пакеты",
    s2b: "Zip-файлы из папки files этого репозитория появляются в списке загрузок.",
    files: "Загрузки",
    hint: "Все файлы из папки files показаны здесь.",
    loading: "Загрузка списка...",
    empty: "Пока нет файлов. Добавьте zip в папку files.",
    error: "Не удалось прочитать папку files.",
    download: "Скачать",
    size: "Размер"
  },
  fa: {
    title: "مرکز VR",
    company: "Lumen Technologies Co.",
    lead: "فایل‌ها و خدمات واقعیت مجازی. از لیست انتخاب کنید و دانلود کنید.",
    services: "خدمات VR",
    s1t: "LTC Quest Helper",
    s1b: "برنامه ویندوز برای هدست Meta Quest و دستگاه‌های اندروید. ابزار ADB، فایل‌منیجر، بکاپ و نصب.",
    s2t: "بسته‌های VR",
    s2b: "فایل‌های زیپ داخل پوشه files همین ریپو در لیست دانلود دیده می‌شوند.",
    files: "دانلودها",
    hint: "هر فایلی که در پوشه files باشد اینجا نمایش داده می‌شود.",
    loading: "در حال خواندن لیست...",
    empty: "هنوز فایلی نیست. زیپ‌ها را در پوشه files ریپو بگذارید.",
    error: "خواندن پوشه files ممکن نشد.",
    download: "دانلود",
    size: "حجم"
  }
};

function t(lang) { return I18N[lang] || I18N.en; }
function applyLang(lang) {
  const d = t(lang);
  document.documentElement.lang = lang;
  document.documentElement.dir = lang === "fa" ? "rtl" : "ltr";
  document.getElementById("t-title").textContent = d.title;
  document.getElementById("t-company").textContent = d.company;
  document.getElementById("t-lead").textContent = d.lead;
  document.getElementById("t-services").textContent = d.services;
  document.getElementById("t-s1-title").textContent = d.s1t;
  document.getElementById("t-s1-body").textContent = d.s1b;
  document.getElementById("t-s2-title").textContent = d.s2t;
  document.getElementById("t-s2-body").textContent = d.s2b;
  document.getElementById("t-files").textContent = d.files;
  document.getElementById("t-files-hint").textContent = d.hint;
  document.querySelectorAll(".langs button").forEach(function(b) {
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
function renderFiles(items, lang) {
  const box = document.getElementById("file-list");
  const d = t(lang);
  const files = (items || []).filter(function(x) {
    return x.type === "file" && x.name !== "README.txt" && x.name !== ".gitkeep";
  });
  if (!files.length) {
    box.innerHTML = "<div class=\"empty\">" + d.empty + "</div>";
    return;
  }
  box.innerHTML = files.map(function(f) {
    const href = f.download_url || (RAW + encodeURIComponent(f.name));
    return "<div class=\"row\"><div><div class=\"name\">" + f.name + "</div><div class=\"meta\">" + d.size + ": " + fmtSize(f.size) + "</div></div><a class=\"dl\" href=\"" + href + "\" download>" + d.download + "</a></div>";
  }).join("");
}
async function loadFiles() {
  const lang = localStorage.getItem("ltc-lang") || "en";
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
document.querySelectorAll(".langs button").forEach(function(b) {
  b.addEventListener("click", function() { applyLang(b.dataset.lang); });
});
applyLang(localStorage.getItem("ltc-lang") || "en");
loadFiles();
