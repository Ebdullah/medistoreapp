document.addEventListener("turbolinks:load", function() {
  const loginForm = document.getElementById('login-form');

  if (loginForm) {
    loginForm.addEventListener('ajax:error', function(event) {
      const [data, status, xhr] = event.detail;
      const response = JSON.parse(xhr.responseText);

      // Clear previous errors
      clearErrors();

      // Display validation errors
      if (response.errors) {
        handleErrors(response.errors);
      }
    });
  }

  function handleErrors(errors) {
    // If there is an error for email or password, show it
    if (errors.includes("Invalid email or password")) {
      const emailField = document.getElementById('email-input');
      const passwordField = document.getElementById('password-input');

      emailField.classList.add('is-invalid');
      passwordField.classList.add('is-invalid');

      const emailError = document.getElementById('email-error');
      const passwordError = document.getElementById('password-error');

      emailError.textContent = "Invalid email or password";
      passwordError.textContent = "Invalid email or password";
    }
  }

  function clearErrors() {
    const emailField = document.getElementById('email-input');
    const passwordField = document.getElementById('password-input');

    const emailError = document.getElementById('email-error');
    const passwordError = document.getElementById('password-error');

    emailField.classList.remove('is-invalid');
    passwordField.classList.remove('is-invalid');

    emailError.textContent = '';
    passwordError.textContent = '';
  }
});
