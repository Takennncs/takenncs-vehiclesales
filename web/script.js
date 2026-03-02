  $(document).ready(function() {
        let offerData = null;

        window.addEventListener('message', function(event) {
            if (event.data.action === 'showPurchaseOffer') {
                offerData = event.data;
                $('#model').text(event.data.model);
                $('#plate').text(event.data.plate);
                $('#seller').text(event.data.sellerName);
                $('#price').text('$' + event.data.price);
                $('#offerContainer').fadeIn(200);
            }
        });

        $('#acceptBtn').click(function() {
            if (offerData) {
                $.post('https://takenncs-vehiclesales/offerAction', JSON.stringify({
                    action: 'accept',
                    data: offerData
                }));
                $('#offerContainer').fadeOut(150);
            }
        });

        $('#declineBtn').click(function() {
            if (offerData) {
                $.post('https://takenncs-vehiclesales/offerAction', JSON.stringify({
                    action: 'decline',
                    sellerId: offerData.sellerId
                }));
                $('#offerContainer').fadeOut(150);
            }
        });

        $('#closeBtn').click(function() {
            $.post('https://takenncs-vehiclesales/offerAction', JSON.stringify({
                action: 'close'
            }));
            $('#offerContainer').fadeOut(150);
        });

        $(document).keyup(function(e) {
            if (e.key === "Escape") {
                $.post('https://takenncs-vehiclesales/offerAction', JSON.stringify({
                    action: 'close'
                }));
                $('#offerContainer').fadeOut(150);
            }
        });
    });