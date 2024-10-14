import 'select2/dist/css/select2.css';
import 'select2';

document.addEventListener('DOMContentLoaded', function() {
    const medicinesContainer = document.getElementById('medicines-fields');
    const totalAmountDisplay = document.getElementById('total-amount');
    const paymentMethodSelect = document.getElementById('payment-method-select');
    const additionalPaymentInfo = document.getElementById('additional-payment-info');
    const stripeFields = document.getElementById('stripe-fields');
    let medicineIndex = 1;

    function updateTotalAmount() {
        let total = 0;
        const medicineFields = document.querySelectorAll('.medicine-fields');

        medicineFields.forEach((field) => {
            const priceField = field.querySelector('.price-field');
            const quantityField = field.querySelector('.quantity-field');

            const price = parseFloat(priceField.value) || 0; 
            const quantity = parseInt(quantityField.value) || 0; 
            total += price * quantity;
        });

        totalAmountDisplay.innerText = total.toFixed(2); 
    }

    function populateMedicineSelect(selectElement) {
        medicinesData.forEach((medicine) => {
            const option = document.createElement('option');
            option.value = medicine.id;
            option.setAttribute('data-price', medicine.price);
            option.text = medicine.name;
            selectElement.appendChild(option);
        });
        $(selectElement).select2({
            data: medicinesData.map(medicine => ({ id: medicine.id, text: medicine.name })),
            placeholder: 'Search Medicine',
            allowClear: true
        });
    }

    function updateMedicineSelectOptions() {
        const selectedMedicineIds = Array.from(document.querySelectorAll('.select2-medicine'))
            .map(select => select.value)
            .filter(id => id); // Get all selected medicine IDs
    
        // Iterate over each medicine select
        document.querySelectorAll('.select2-medicine').forEach(select => {
            const currentSelect = select; // Store the reference to the current select element
            $(currentSelect).find('option').each(function() {
                const optionValue = $(this).val();
                if (selectedMedicineIds.includes(optionValue) && optionValue !== $(currentSelect).val()) {
                    // Disable options only in other select elements, not in the current one
                    $(this).prop('disabled', true); 
                } else {
                    $(this).prop('disabled', false); 
                }
            });
            $(currentSelect).select2(); // Refresh select2 to apply changes
        });
    }
    

    function bindMedicineChange(medicineSelect) {
        $(medicineSelect).on('select2:select', function (e) {
            const selectedOption = e.params.data;
            const selectedMedicine = medicinesData.find(medicine => medicine.id == selectedOption.id);
            const priceField = $(medicineSelect).closest('.medicine-fields').find('.price-field');
            const quantityValue = $(medicineSelect).closest('.medicine-fields').find('.available-quantity');

            if (selectedMedicine) {
                priceField.val(selectedMedicine.price || 0);
                quantityValue.text(`Available: ${selectedMedicine.stock_quantity || 0}`);
            } else {
                priceField.val(0);
                quantityValue.text('');
            }

            updateTotalAmount();
            updateMedicineSelectOptions(); // Update the select options
        });
    }

    // Initialize Select2 for the initial medicine select
    const initialMedicineSelect = $('.select2-medicine');
    if (initialMedicineSelect) {
        initialMedicineSelect.select2({
            data: medicinesData.map(medicine => ({ id: medicine.id, text: medicine.name })),
            placeholder: 'Search Medicine',
            allowClear: true
        });
        bindMedicineChange(initialMedicineSelect);
        updateMedicineSelectOptions(); // Call this initially to set correct options
    }

    paymentMethodSelect.addEventListener('change', function() {
        const selectedMethod = paymentMethodSelect.value;
        additionalPaymentInfo.style.display = 'block'; 

        if (selectedMethod === 'cash') {
            stripeFields.style.display = 'none';
        } else if (selectedMethod === 'card') {
            stripeFields.style.display = 'block'; 
        }
    });

    document.getElementById('add-medicine').addEventListener('click', function(e) {
        e.preventDefault();
        let template = `
        <div class="medicine-fields row mb-3">
            <div class="col-md-6">
                <label for="record_items_attributes_${medicineIndex}_medicine_id" class="form-label">Select Medicine</label>
                <select name="record[record_items_attributes][${medicineIndex}][medicine_id]" class="form-select select2-medicine">
                </select>
                <div class="available-quantity mt-1" style="font-weight: bold;"></div>
            </div>
    
            <div class="col-md-3">
                <label for="record_items_attributes_${medicineIndex}_quantity" class="form-label">Quantity</label>
                <input type="number" name="record[record_items_attributes][${medicineIndex}][quantity]" class="form-control quantity-field" min="0">
            </div>
    
            <div class="col-md-3">
                <label for="record_items_attributes_${medicineIndex}_price" class="form-label">Price</label>
                <input type="number" name="record[record_items_attributes][${medicineIndex}][price]" class="form-control price-field" readonly>
            </div>
    
            <div class="col-md-12 mt-2">
                <button type="button" class="btn btn-outline-dark remove-medicine">Remove</button>
            </div>
        </div>
    `;
    
        medicinesContainer.insertAdjacentHTML('beforeend', template);
    
        const newMedicineSelect = medicinesContainer.querySelector(`select[name="record[record_items_attributes][${medicineIndex}][medicine_id]"]`);    
        populateMedicineSelect(newMedicineSelect); 
        bindMedicineChange(newMedicineSelect); 

        medicineIndex++;
        updateTotalAmount();
        updateMedicineSelectOptions(); // Update options after adding new medicine
    });
    
    medicinesContainer.addEventListener('click', function(e) {
        if (e.target.classList.contains('remove-medicine')) {
            e.target.closest('.medicine-fields').remove();
            updateTotalAmount();
            updateMedicineSelectOptions(); // Update the select options after removing
        }
    });

    medicinesContainer.addEventListener('input', function(e) {
        if (e.target.classList.contains('quantity-field')) {
            const quantityField = e.target;
            if (quantityField.value < 0) {
                quantityField.value = 0; 
            }
            updateTotalAmount();
        }
    });

    medicinesContainer.addEventListener('input', function(e) {
        if (e.target.classList.contains('quantity-field')) {
            const quantityField = e.target;

            // Remove any non-numeric characters (except for digits)
            quantityField.value = quantityField.value.replace(/[^0-9]/g, '');

            const selectedMedicineId = $(quantityField).closest('.medicine-fields').find('.select2-medicine').val();
            const selectedMedicine = medicinesData.find(medicine => medicine.id == selectedMedicineId);
            const maxQuantity = selectedMedicine ? selectedMedicine.stock_quantity : 0;


            if (parseInt(quantityField.value, 10) > maxQuantity) {
                quantityField.value = maxQuantity;

                quantityField.classList.add('is-invalid'); 

                let errorMessage = $(quantityField).siblings('.invalid-feedback');
                if (errorMessage.length === 0) {
                    errorMessage = $('<div class="invalid-feedback"></div>');
                    $(quantityField).after(errorMessage);
                }
                errorMessage.text(`You cannot order more than ${maxQuantity} units of this medicine.`);
            } else {
                quantityField.classList.remove('is-invalid');
                $(quantityField).siblings('.invalid-feedback').remove();
            }

            updateTotalAmount();
        }
    });

    medicinesContainer.addEventListener('input', function(e) {
        if (e.target.classList.contains('quantity-field') || e.target.classList.contains('price-field')) {
            updateTotalAmount();
        }
    });
});
