// app/javascript/packs/application.js
import $ from 'jquery';
window.$ = $;
import Rails from "@rails/ujs"
Rails.start()
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import 'bootstrap';
import "@fortawesome/fontawesome-free/js/all";
import intlTelInput from 'intl-tel-input';
import 'intl-tel-input/build/css/intlTelInput.css';

$(document).ready(function() {
    $('.your-select-class').select2();
  });



Rails.start()
Turbolinks.start()
ActiveStorage.start()



