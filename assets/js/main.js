document.addEventListener("DOMContentLoaded", function () {
  var navTrigger = document.getElementById('nav-trigger');
  var trigger = document.getElementById('trigger');
  trigger.addEventListener('click', function () {
    navTrigger.checked = false;
  });
});
