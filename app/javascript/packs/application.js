// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()

import $ from "jquery";
import "bootstrap";
import "@fortawesome/fontawesome-free/js/all";
import "@coreui/coreui";
import "select2";
import moment from "moment";

import "controllers"
import "../components/direct_upload"

import "../stylesheets/application";

document.addEventListener("turbolinks:load", function() {
  $('[data-behavior~=select2-input]').select2({
    theme: 'bootstrap4'
  })

  $('time[data-behavior~=local-time]').each(function() {
    $(this).text(
      moment($(this).text()).format("lll (Z)")
    )
  })
});

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
