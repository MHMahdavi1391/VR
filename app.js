const OWNER = "MHMahdavi1391";
const REPO = "VR";
const FILES_API = `https://api.github.com/repos/${OWNER}/${REPO}/contents/files`;
const RAW = `https://raw.githubusercontent.com/${OWNER}/${REPO}/main/files/`;

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
    loading: "Loading file list…",
    empty: "No files yet. Add zip files to the files folder in this repository.",
    error: "Could not read the files folder.",
    download: "Download",
    size: "Size"
  },
  ru: {
    title: "VR Hub",
    company: "Lumen Technologies Co.",
    lead: "VR files and services. Choose a package from the list and download it.",
    services: "VR services",
    s1t: "LTC Quest Helper",
    s1b: "Windows helper for Meta Quest and Android.",
    s2t: "VR packages",
    s2b: "Zip files from the files folder appear in the download list.",
    files: "Downloads",
    hint: "All files from the files folder are shown here.",
    loading: "Loading list…",
    empty: "No files yet. Add zip files to the files folder.",
    error: "Could not read the files folder.",
    download: "Download",
    size: "Size"
  },
  fa: {
    title: "VR Hub",
    company: "Lumen Technologies Co.",
    lead: "VR files and services. Choose a package from the list and download it.",
    services: "VR services",
    s1t: "LTC Quest Helper",
    s1b: "Windows helper for Meta Quest and Android devices.",
    s2t: "VR packages",
    s2b: "Zip files in the files folder appear in the download list.",
    files: "Downloads",
    hint: "Files inside the files folder are listed here.",
    loading: "Loading list…",
    empty: "No files yet. Add zip files to the files folder.",
    error: "Could not read the files folder.",
    download: "Download",
    size: "Size"
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
  document.querySelectorAll(".langs button").forEach((b) => {
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
  const files = (items || []).filter((x) => x.type === "file" && x.name !== "README.txt" && x.name !== ".gitkeep");
  if (!files.length) {
    box.innerHTML = `<div class="empty">${d.empty}</div>`;
    return;
  }
  box.innerHTML = files.map((f) => {
    const href = f.download_url || (RAW + encodeURIComponent(f.name));
    return `<div class="row"><div><div class="name">${f.name}</div><div class="meta">${d.size}: ${fmtSize(f.size)}</div></div><a class="dl" href="${href}" download>${d.download}</a></div>`;
  }).join("");
}
async function loadFiles() {
  const lang = localStorage.getItem("ltc-lang") || "en";
  const box = document.getElementById("file-list");
  box.innerHTML = `<div class="empty">${t(lang).loading}</div>`;
  try {
    const res = await fetch(FILES_API);
    if (!res.ok) throw new Error(String(res.status));
    const data = await res.json();
    window.__files = Array.isArray(data) ? data : [];
    renderFiles(window.__files, lang);
  } catch (e) {
    box.innerHTML = `<div class="empty">${t(lang).error}</div>`;
  }
}
document.querySelectorAll(".langs button").forEach((b) => {
  b.addEventListener("click", () => applyLang(b.dataset.lang));
});
applyLang(localStorage.getItem("ltc-lang") || "en");
loadFiles();
