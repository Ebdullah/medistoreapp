document.addEventListener('DOMContentLoaded', function() {
  var stripePublicKey = document.getElementById('stripe-public-key').getAttribute('data-key');
  var stripe = Stripe(stripePublicKey);
  // const stripe = Stripe('<%= Rails.application.credentials.stripe[:publishable_key] %>');
  const elements = stripe.elements();
  const cardElement = elements.create('card');
  cardElement.mount('#card-element');
  
  document.getElementById('submitBtn').addEventListener('click', function(event) {
  event.preventDefault();
  
  var paymentMethod = document.getElementById('payment-method-select').value;
  if (paymentMethod === 'card') {
  stripe.createToken(cardElement).then(function(result) {
  if (result.error) {
  alert(result.error.message);
  } else {
  document.querySelector('input[name="record[stripe_token]"]').value = result.token.id;
  document.getElementById('payment-form').submit(); 
  }
  });
  } else {
  document.getElementById('payment-form').submit(); 
  }
  });
  
  const paymentMethodSelect = document.getElementById('payment-method-select');
  
  paymentMethodSelect.addEventListener('change', (event) => {
  if (event.target.value === 'cash') {
  stripeFields.style.display = 'none';
  } else if (selectedMethod === 'card'){
  stripeFields.style.display = 'block';
  }
  });
  
  });
  