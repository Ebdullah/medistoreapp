$(document).ready(function() {
    $('.purchase-record').on('click', function() {
        var branchId = $(this).data('branch-id');
        var recordId = $(this).data('record-id');
        
        // Set the refund button's onclick to point to the correct path
        $('#refundButton').off('click').on('click', function() {
            location.href = '/branches/' + branchId + '/refunds/new?record_id=' + recordId; // Adjust path as necessary
        });

        var customerName = $(this).data('customer-name');
        var customerPhone = $(this).data('customer-phone');
        var medicineName = $(this).data('medicine-name');
        var quantity = $(this).data('quantity');
        var price = $(this).data('price');
        var recordId = $(this).data('record-id');
        var total = $(this).data('total'); // Get the total amount
        

        // Populate the modal with the data
        var content = `
            <h3>ID: ${recordId}</h3>
            <h3>${customerName}</h3>
            <p><strong>Contact:</strong> ${customerPhone}</p>
            <h4>Items:</h4>
            <table class="table">
                <thead>
                    <tr>
                        <th>Medicine</th>
                        <th>Quantity</th>
                        <th>Price</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>${medicineName}</td>
                        <td>${quantity}</td>
                        <td>${number_to_currency(price)}</td>
                        <td>${total}</td>
                    </tr>
                </tbody>
            </table>
            <input type="hidden" id="recordId" value="${recordId}" /> <!-- Store record ID in hidden input -->
            <button id="downloadReceipt" class="btn btn-success">Download Receipt</button>
        `;

        $('#billing-details-content').html(content);
        $('#billingDetailsModal').modal('show');

        // Set the refund amount in the refund modal
        $('#refundAmount').val(total.replace('$', '').trim()); // Remove the dollar sign for input
    });

    $('#refundButton').on('click', function() {
        // No need for any additional logic here as the amount is set when the billing modal is clicked
    });

    $('#pdf-download').on('click', function(){

    });

    $('.close, .btn-secondary').on('click', function() {
        $('#billingDetailsModal').modal('hide');
    });
});

function number_to_currency(value) {
    return (value).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
}
