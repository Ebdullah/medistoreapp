document.addEventListener('DOMContentLoaded', function() {
    const phoneInput = document.querySelector("#phone");
    const countryCodeInput = document.querySelector("#country_code");
  
    if (phoneInput) {
      const iti = intlTelInput(phoneInput, {
        initialCountry: "pk",
        geoIpLookup: function(callback) {
          fetch('https://ipinfo.io/json')
            .then(response => response.json())
            .then(data => {
              callback(data.country);
            })
            .catch(() => {
              callback("pk");
            });
        },
        utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js"
      });
  
      phoneInput.addEventListener('countrychange', function() {
        const countryData = iti.getSelectedCountryData();
        countryCodeInput.value = countryData.dialCode;
      });
  
      phoneInput.addEventListener('blur', function() {
        if (!iti.isValidNumber()) {
          phoneInput.classList.add('is-invalid');
        } else {
          phoneInput.classList.remove('is-invalid');
        }
      });
    }
  });
  