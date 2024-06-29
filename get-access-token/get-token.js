const { GoogleAuth } = require('google-auth-library');
const path = require('path');

async function getAccessToken() {
    try {
        const keyFilePath = path.join(__dirname, 'service-account-file.json'); // Path to your service account JSON file
        const auth = new GoogleAuth({
            keyFile: keyFilePath,
            scopes: ['https://www.googleapis.com/auth/cloud-platform'],
        });

        const client = await auth.getClient();
        const tokenResponse = await client.getAccessToken();
        const accessToken = tokenResponse.token;
        console.log('Access token:', accessToken);
        return accessToken;
    } catch (err) {
        console.error('Error getting access token:', err.message);
        throw err;
    }
}

getAccessToken().catch(err => {
    console.error('Top level error:', err);
});
