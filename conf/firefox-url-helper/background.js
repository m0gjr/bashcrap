let port = null;


function connect() {
    if (port !== null) {
        return;
    }

    try {
        port = browser.runtime.connectNative("firefox_url_helper");

        port.onDisconnect.addListener(() => {
            port = null;
        });

    } catch (error) {
        console.error("Failed to connect to native host:", error);
        port = null;
    }
}


function sendUrl(url) {
    if (!url) {
        return;
    }

    connect();

    if (port === null) {
        return;
    }

    try {
        port.postMessage({
            url: url
        });
    } catch (error) {
        console.error("Failed to send URL:", error);
        port = null;
    }
}


async function updateCurrentUrl() {
    try {
        const tabs = await browser.tabs.query({
            active: true,
            currentWindow: true
        });

        if (tabs.length > 0) {
            sendUrl(tabs[0].url);
        }
    } catch (error) {
        console.error("Failed to get active tab:", error);
    }
}


browser.tabs.onActivated.addListener(() => {
    updateCurrentUrl();
});


browser.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
    if (changeInfo.url !== undefined) {
        updateCurrentUrl();
    }
});


browser.windows.onFocusChanged.addListener(() => {
    updateCurrentUrl();
});


browser.runtime.onStartup.addListener(() => {
    connect();
    updateCurrentUrl();
});


connect();
updateCurrentUrl();
