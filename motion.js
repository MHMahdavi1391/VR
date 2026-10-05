(function () {
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  document.querySelectorAll('.topbar, .intro, .card, footer, .footer-social a').forEach(function (el, i) {
    el.setAttribute('data-aos', 'fade-up');
    el.setAttribute('data-aos-delay', String((i % 6) * 60));
  });
  if (window.AOS) AOS.init({ duration: 700, once: true, offset: 30, easing: 'ease-out-cubic' });
  if (window.gsap) gsap.from('.brand img, .intro h1', { y: 16, opacity: 0, duration: 0.8, stagger: 0.1, ease: 'power3.out' });
  var grid = document.getElementById('grid');
  if (grid && window.MutationObserver) {
    new MutationObserver(function () {
      grid.querySelectorAll('.card').forEach(function (el, i) {
        el.classList.add('animate__animated', 'animate__fadeInUp');
        el.setAttribute('data-aos', 'fade-up');
        el.setAttribute('data-aos-delay', String(i * 60));
      });
      if (window.AOS) AOS.refresh();
    }).observe(grid, { childList: true });
  }
})();
