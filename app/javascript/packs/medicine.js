document.addEventListener('DOMContentLoaded', function() {
    const stockQuantityField = document.getElementById('stockQuantity');
  
    stockQuantityField.addEventListener('input', function(e) {
      // Replace any non-numeric characters (except digits) with an empty string
      this.value = this.value.replace(/[^0-9]/g, '');
  
      // Check if the input is zero or less
      if (parseInt(this.value, 10) <= 0) {
        this.classList.add('is-invalid');  // Add 'is-invalid' class
        let errorMessage = document.getElementById('stockQuantityError');
        errorMessage.innerText = "Quantity must be greater than zero.";
      } else {
        this.classList.remove('is-invalid');  // Remove 'is-invalid' class
        let errorMessage = document.getElementById('stockQuantityError');
        errorMessage.innerText = '';  // Clear error message
      }
    });
  });
  