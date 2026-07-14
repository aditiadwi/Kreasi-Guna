/**
 * CONCEPTUAL EXAMPLE: Node.js Backend with Midtrans
 * 
 * To run this for real, you would need:
 * 1. Node.js installed
 * 2. `npm install midtrans-client express`
 * 3. A Midtrans Sandbox account
 */

const midtransClient = require('midtrans-client');
const express = require('express');
const app = express();
app.use(express.json());

// 1. Initialize Midtrans Client
// NEVER put these keys in your frontend (app.js)!
let snap = new midtransClient.Snap({
    isProduction : false,
    serverKey : 'YOUR_MIDTRANS_SERVER_KEY',
    clientKey : 'YOUR_MIDTRANS_CLIENT_KEY'
});

/**
 * Endpoint to create a payment
 * Your frontend (app.js) would call this when the user clicks "Checkout"
 */
app.post('/create-payment', async (req, res) => {
    try {
        const { orderId, totalAmount, customerDetails } = req.body;

        // 2. Create Transaction Parameters
        let parameter = {
            "transaction_details": {
                "order_id": orderId,
                "gross_amount": totalAmount
            },
            "credit_card":{
                "secure" : true
            },
            "customer_details": customerDetails
        };

        // 3. Get Snap Token/URL from Midtrans
        // This creates a secure "Locked" payment session
        const transaction = await snap.createTransaction(parameter);
        
        // This URL contains the QRIS, GoPay, etc. with the automated total
        res.json({
            paymentUrl: transaction.redirect_url,
            token: transaction.token
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

/**
 * 4. THE WEBHOOK (Automation Magic)
 * Midtrans calls this automatically when the user pays!
 */
app.post('/payment-notification', (req, res) => {
    let notificationJson = req.body;

    snap.transaction.notification(notificationJson)
        .then((statusResponse) => {
            let orderId = statusResponse.order_id;
            let transactionStatus = statusResponse.transaction_status;
            let fraudStatus = statusResponse.fraud_status;

            console.log(`Transaction notification received. Order ID: ${orderId}. Status: ${transactionStatus}. Fraud: ${fraudStatus}`);

            if (transactionStatus == 'capture' || transactionStatus == 'settlement'){
                // AUTOMATION: Update your database here! 
                // Set order to "PAID" and reduce stock automatically.
                console.log("Payment SUCCESS! Automating order fulfillment...");
            }
            
            res.status(200).send('OK');
        });
});

app.listen(3000, () => console.log('Server running on port 3000'));
