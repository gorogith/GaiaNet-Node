const fs = require('fs');
const axios = require('axios');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const user_messages = fs.readFileSync('message.txt', 'utf-8')
    .split('\n')
    .filter(msg => msg.trim());

function getTimestamp() {
    return new Date().toLocaleTimeString();
}

function logMessage(type, message, details = null) {
    const timestamp = getTimestamp();
    switch(type) {
        case 'info':
            console.log(`\n[${timestamp}] ℹ️ ${message}`);
            break;
        case 'error':
            console.log(`\n[${timestamp}] ❌ ${message}`);
            break;
        case 'success':
            console.log(`\n[${timestamp}] ✅ ${message}`);
            break;
        case 'response':
            console.log(`\n[${timestamp}] 📨 Message: "${details.userMessage}"`);
            console.log(`   💬 Response: "${details.aiResponse}"`);
            break;
    }
}

async function getUserInput(prompt) {
    return new Promise((resolve) => {
        rl.question(prompt, (answer) => {
            resolve(answer.trim());
        });
    });
}

function getRandomDelay() {
    return Math.floor(Math.random() * (30000 - 15000 + 1) + 15000); // 15000-30000 ms
}

async function sendRequest(message, config) {
    const headers = {
        'Authorization': `Bearer ${config.apiKey}`,
        'accept': 'application/json',
        'Content-Type': 'application/json'
    };

    const data = {
        messages: [
            { role: "system", content: "You are a helpful assistant." },
            { role: "user", content: message }
        ]
    };

    while (true) {
        try {
            const response = await axios.post(config.apiUrl, data, { headers });
            
            const aiResponse = response.data.choices[0].message.content;
            
            logMessage('response', null, {
                userMessage: message,
                aiResponse: aiResponse
            });
            break;
        } catch (error) {
            const errorMessage = error.response ? 
                `Error ${error.response.status}: ${error.response.statusText}` : 
                `Connection error: ${error.message}`;
            logMessage('error', `${errorMessage}. Retrying in 5 seconds...`);
            await new Promise(resolve => setTimeout(resolve, 5000));
        }
    }
}

async function startThread(messages, config) {
    while (true) {
        const randomMessage = messages[Math.floor(Math.random() * messages.length)];
        await sendRequest(randomMessage, config);
        
        const delay = getRandomDelay();
        const seconds = Math.floor(delay / 1000);
        logMessage('info', `Waiting ${seconds} seconds before next message...`);
        await new Promise(resolve => setTimeout(resolve, delay));
    }
}

async function main() {
    const api_key = await getUserInput("Enter your API key: ");
    const api_url = await getUserInput("Enter the API URL: ");
    
    console.log("Starting Chatbot...");
    
    try {
        await startThread(user_messages, { apiKey: api_key, apiUrl: api_url });
    } catch (error) {
        console.error("Error occurred:", error);
    } finally {
        rl.close();
    }
}

main().catch(console.error);
