// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import '@fortawesome/fontawesome-free/js/all'
import * as bootstrap from "bootstrap"
import '@coreui/coreui';
require("@rails/activestorage").start()


import jquery from 'jquery'
window.jQuery = jquery
window.$ = jquery

import "./controllers"

var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})

var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
popoverTriggerList.map(function (popoverTriggerEl) {
  return new bootstrap.Popover(popoverTriggerEl)
})

$('[data-behavior~=select2-input]').select2({
  theme: 'bootstrap4',
})

// This is useful when attempting to render Select2 correctly inside of modals and other small containers.
// https://select2.org/dropdown#dropdown-placement

$('[data-behavior~=select2-filter-input]').select2({
  theme: 'bootstrap4',
  dropdownParent: $("#filters")
})

$('time[data-behavior~=local-time]').each(function() {
  $(this).text(
    moment($(this).text()).format("lll (Z)")
  )
})
