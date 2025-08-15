'use strict';

// PRELOADER
const preloader = document.querySelector("[data-preloader]");
window.addEventListener("DOMContentLoaded", function () {
  preloader.classList.add("loaded");
  document.body.classList.add("loaded");
});

// NAVIGATION - WORKING VERSION
document.addEventListener('DOMContentLoaded', function() {
  
  const navToggleBtn = document.querySelector("[data-nav-toggle-btn]");
  const navbar = document.querySelector("[data-navbar]");
  const overlay = document.querySelector("[data-overlay]");
  const navLinks = document.querySelectorAll(".navbar-link");

  // Toggle navigation
  if (navToggleBtn) {
    navToggleBtn.addEventListener('click', function(e) {
      e.preventDefault();
      console.log('Nav button clicked!'); // Debug line
      
      navbar.classList.toggle("active");
      navToggleBtn.classList.toggle("active");
      overlay.classList.toggle("active");
      document.body.classList.toggle("nav-active");
    });
  }

  // Close nav when clicking overlay
  if (overlay) {
    overlay.addEventListener('click', function() {
      navbar.classList.remove("active");
      navToggleBtn.classList.remove("active");
      overlay.classList.remove("active");
      document.body.classList.remove("nav-active");
    });
  }

  // Close nav when clicking links
  navLinks.forEach(link => {
    link.addEventListener('click', function() {
      navbar.classList.remove("active");
      navToggleBtn.classList.remove("active");
      overlay.classList.remove("active");
      document.body.classList.remove("nav-active");
    });
  });

});

// HEADER scroll effect
window.addEventListener("scroll", function () {
  const header = document.querySelector("[data-header]");
  if (window.scrollY >= 100) {
    header.classList.add("active");
  } else {
    header.classList.remove("active");
  }
});



// SLIDER functionality
const sliders = document.querySelectorAll("[data-slider]");

const initSlider = function (currentSlider) {
  const sliderContainer = currentSlider.querySelector("[data-slider-container]");
  const sliderPrevBtn = currentSlider.querySelector("[data-slider-prev]");
  const sliderNextBtn = currentSlider.querySelector("[data-slider-next]");

  if (!sliderContainer || !sliderPrevBtn || !sliderNextBtn) return;

  let totalSliderVisibleItems = Number(getComputedStyle(currentSlider).getPropertyValue("--slider-items"));
  let totalSlidableItems = sliderContainer.childElementCount - totalSliderVisibleItems;
  let currentSlidePos = 0;

  const moveSliderItem = function () {
    sliderContainer.style.transform = `translateX(-${sliderContainer.children[currentSlidePos].offsetLeft}px)`;
  }

  // NEXT SLIDE
  const slideNext = function () {
    const slideEnd = currentSlidePos >= totalSlidableItems;
    if (slideEnd) {
      currentSlidePos = 0;
    } else {
      currentSlidePos++;
    }
    moveSliderItem();
  }

  sliderNextBtn.addEventListener("click", slideNext);

  // PREVIOUS SLIDE
  const slidePrev = function () {
    if (currentSlidePos <= 0) {
      currentSlidePos = totalSlidableItems;
    } else {
      currentSlidePos--;
    }
    moveSliderItem();
  }

  sliderPrevBtn.addEventListener("click", slidePrev);

  const dontHaveExtraItem = totalSlidableItems <= 0;
  if (dontHaveExtraItem) {
    sliderNextBtn.style.display = 'none';
    sliderPrevBtn.style.display = 'none';
  }

  // slide with [shift + mouse wheel]
  currentSlider.addEventListener("wheel", function (event) {
    if (event.shiftKey && event.deltaY > 0) slideNext();
    if (event.shiftKey && event.deltaY < 0) slidePrev();
  });

  // RESPONSIVE
  window.addEventListener("resize", function () {
    totalSliderVisibleItems = Number(getComputedStyle(currentSlider).getPropertyValue("--slider-items"));
    totalSlidableItems = sliderContainer.childElementCount - totalSliderVisibleItems;
    moveSliderItem();
  });
}

for (let i = 0, len = sliders.length; i < len; i++) { 
  initSlider(sliders[i]); 
}
