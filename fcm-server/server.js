const express = require('express');
const bodyParser = require('body-parser');
var admin = require('firebase-admin');
const path = require('path');

const app = express();
app.use(bodyParser.json());

// Đảm bảo rằng đường dẫn đến file JSON là chính xác
const serviceAccount = require('./firebase-adminsdk.json'); // Đường dẫn tới file serviceAccount.json

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

app.post('/send-notification', async (req, res) => {
  const { tokens, title, body } = req.body;

  const payload = {
    notification: {
      title: title,
      body: body,
    },
  };

  try {
    const response = await admin.messaging().sendToDevice(tokens, payload);
    console.log('Successfully sent message:', response);
    res.status(200).json(response);
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
