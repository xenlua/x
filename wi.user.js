// ==UserScript==
// @name         kxBypass LootLabs Enhanced
// @namespace    https://discord.gg/pqEBSTqdxV
// @version      v2.0
// @description  Ultra-Fast Enhanced Bypass for Lootlinks - Premium UI & Lightning Speed
// @author       awaitlol.
// @match        https://lootlinks.co/*
// @match        https://loot-links.com/*
// @match        https://loot-link.com/*
// @match        https://linksloot.net/*
// @match        https://lootdest.com/*
// @match        https://lootlink.org/*
// @match        https://lootdest.info/*
// @match        https://lootdest.org/*
// @match        https://links-loot.com/*
// @icon         https://i.pinimg.com/736x/aa/2a/e5/aa2ae567da2c40ac6834a44abbb9e9ff.jpg
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
    "use strict";

    // Ultra-fast performance optimizations
    const CONFIG = {
        WEBSOCKET_TIMEOUT: 8000,      // Reduced from 25000
        HEARTBEAT_INTERVAL: 300,      // Reduced from 750
        UI_DELAY: 500,                // Reduced from 1500
        MAX_RETRIES: 3,
        ANIMATION_SPEED: 0.3          // Faster animations
    };

    let bypassState = {
        isActive: false,
        startTime: Date.now(),
        retryCount: 0,
        progress: 0
    };

    // Progress simulation for better UX
    function simulateProgress() {
        const progressInterval = setInterval(() => {
            if (bypassState.progress < 90) {
                bypassState.progress += Math.random() * 15;
                updateProgressBar();
            } else {
                clearInterval(progressInterval);
            }
        }, 200);
    }

    function updateProgressBar() {
        const progressBar = document.querySelector('.progress-fill');
        const progressText = document.querySelector('.progress-text');
        if (progressBar && progressText) {
            progressBar.style.width = `${Math.min(bypassState.progress, 100)}%`;
            progressText.textContent = `${Math.round(bypassState.progress)}%`;
        }
    }

    function handleLootlinks() {
        if (bypassState.isActive) return;
        bypassState.isActive = true;
        bypassState.startTime = Date.now();

        // Enhanced fetch interceptor with faster processing
        const originalFetch = window.fetch;
        window.fetch = async function (...args) {
            const [resource] = args;
            const url = typeof resource === "string" ? resource : resource.url;

            if (url.includes("/tc")) {
                return handleTcRequest(originalFetch, args);
            }

            return originalFetch(...args);
        };

        // Block popups and redirects more aggressively
        window.open = () => null;
        window.location.replace = function(url) {
            console.log('[kxBypass] Blocked redirect:', url);
        };

        // Initialize ultra-fast UI
        setTimeout(() => {
            clearPageAndCreateUI();
            simulateProgress();
        }, CONFIG.UI_DELAY);
    }

    async function handleTcRequest(originalFetch, args) {
        try {
            const response = await originalFetch(...args);
            const data = await response.clone().json();

            if (Array.isArray(data) && data.length > 0) {
                await processBypassData(data[0]);
            } else {
                throw new Error('Invalid response data');
            }

            return response;
        } catch (err) {
            console.error("Bypass error:", err);

            if (bypassState.retryCount < CONFIG.MAX_RETRIES) {
                bypassState.retryCount++;
                updateRetryUI();
                await new Promise(resolve => setTimeout(resolve, 500)); // Faster retry
                return originalFetch(...args);
            } else {
                showErrorUI("Multiple bypass attempts failed");
                throw err;
            }
        }
    }

    async function processBypassData(data) {
        const { urid, task_id, action_pixel_url, session_id } = data;

        if (!urid || !task_id) {
            throw new Error('Missing required parameters');
        }

        const shard = parseInt(urid.slice(-5)) % 3;

        return new Promise((resolve, reject) => {
            const ws = new WebSocket(
                `wss://${shard}.${INCENTIVE_SERVER_DOMAIN}/c?uid=${urid}&cat=${task_id}&key=${KEY}&session_id=${session_id}&is_loot=1&tid=${TID}`
            );

            let heartbeatInterval;
            let wsTimeout = setTimeout(() => {
                ws.close();
                reject(new Error('WebSocket timeout'));
            }, CONFIG.WEBSOCKET_TIMEOUT);

            ws.onopen = () => {
                clearTimeout(wsTimeout);
                bypassState.progress = 60;
                updateProgressBar();

                heartbeatInterval = setInterval(() => {
                    if (ws.readyState === WebSocket.OPEN) {
                        ws.send("0");
                    }
                }, CONFIG.HEARTBEAT_INTERVAL);
            };

            ws.onmessage = (e) => {
                if (e.data.startsWith("r:")) {
                    clearInterval(heartbeatInterval);
                    bypassState.progress = 100;
                    updateProgressBar();

                    const encodedString = e.data.slice(2);
                    try {
                        const destinationUrl = decodeURI(encodedString);
                        setTimeout(() => showBypassResult(destinationUrl), 300);
                        resolve(destinationUrl);
                    } catch (err) {
                        console.error("Decryption error:", err);
                        reject(err);
                    }
                }
            };

            ws.onerror = (error) => {
                clearInterval(heartbeatInterval);
                clearTimeout(wsTimeout);
                reject(error);
            };

            // Parallel tracking requests for maximum speed
            Promise.all([
                navigator.sendBeacon(`https://${shard}.${INCENTIVE_SERVER_DOMAIN}/st?uid=${urid}&cat=${task_id}`),
                fetch(`https:${action_pixel_url}`).catch(() => {}),
                fetch(`https://${INCENTIVE_SYNCER_DOMAIN}/td?ac=auto_complete&urid=${urid}&cat=${task_id}&tid=${TID}`).catch(() => {})
            ]);
        });
    }

    function clearPageAndCreateUI() {
        // Ultra-aggressive page clearing
        document.documentElement.innerHTML = '';
        document.head.innerHTML = '';
        document.body.innerHTML = '';

        // Inject premium fonts
        const font = document.createElement("link");
        font.rel = "stylesheet";
        font.href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap";
        document.head.appendChild(font);

        createPremiumUI();
    }

    function createPremiumUI() {
        const overlay = document.createElement("div");
        overlay.id = "kxBypass-overlay";
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
            background-size: 400% 400%;
            animation: gradientShift 8s ease infinite;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 2147483647;
            color: white;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            overflow: hidden;
        `;

        const elapsedTime = Math.round((Date.now() - bypassState.startTime) / 1000);

        overlay.innerHTML = `
            <!-- Animated background particles -->
            <div class="particles">
                ${Array.from({length: 50}, (_, i) => `<div class="particle" style="--delay: ${i * 0.1}s"></div>`).join('')}
            </div>

            <!-- Main content -->
            <div class="main-container">
                <div class="logo-container">
                    <div class="logo-icon">🚀</div>
                    <div class="logo-text">kxBypass</div>
                    <div class="version-badge">v2.0 Enhanced</div>
                </div>

                <div class="status-text">
                    Bypassing with <span class="highlight">lightning speed</span>...
                </div>

                <!-- Enhanced progress bar -->
                <div class="progress-container">
                    <div class="progress-bar">
                        <div class="progress-fill"></div>
                        <div class="progress-glow"></div>
                    </div>
                    <div class="progress-text">0%</div>
                </div>

                <!-- Stats container -->
                <div class="stats-container">
                    <div class="stat-item">
                        <div class="stat-label">Time</div>
                        <div class="stat-value" id="elapsed-time">${elapsedTime}s</div>
                    </div>
                    <div class="stat-divider"></div>
                    <div class="stat-item">
                        <div class="stat-label">Attempt</div>
                        <div class="stat-value">${bypassState.retryCount + 1}/${CONFIG.MAX_RETRIES + 1}</div>
                    </div>
                    <div class="stat-divider"></div>
                    <div class="stat-item">
                        <div class="stat-label">Speed</div>
                        <div class="stat-value">Ultra</div>
                    </div>
                </div>

                <!-- Loading animation -->
                <div class="loading-container">
                    <div class="spinner-modern"></div>
                </div>

                <div class="footer-text">
                    Enhanced for maximum performance & reliability
                </div>
            </div>
        `;

        document.body.appendChild(overlay);

        const style = document.createElement("style");
        style.textContent = `
            @keyframes gradientShift {
                0% { background-position: 0% 50%; }
                50% { background-position: 100% 50%; }
                100% { background-position: 0% 50%; }
            }

            @keyframes float {
                0%, 100% { transform: translateY(0px) rotate(0deg); }
                50% { transform: translateY(-20px) rotate(180deg); }
            }

            @keyframes pulse {
                0%, 100% { opacity: 0.3; transform: scale(1); }
                50% { opacity: 1; transform: scale(1.1); }
            }

            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }

            @keyframes progressGlow {
                0%, 100% { opacity: 0.5; }
                50% { opacity: 1; }
            }

            .particles {
                position: absolute;
                width: 100%;
                height: 100%;
                overflow: hidden;
                z-index: 1;
            }

            .particle {
                position: absolute;
                width: 4px;
                height: 4px;
                background: rgba(255, 255, 255, 0.6);
                border-radius: 50%;
                animation: float 6s ease-in-out infinite;
                animation-delay: var(--delay);
                left: ${Math.random() * 100}%;
                top: ${Math.random() * 100}%;
            }

            .main-container {
                text-align: center;
                max-width: 500px;
                padding: 50px 30px;
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(20px);
                border-radius: 24px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                box-shadow: 0 25px 50px rgba(0, 0, 0, 0.2);
                z-index: 2;
                position: relative;
                animation: slideUp 0.6s ease-out;
            }

            @keyframes slideUp {
                from { opacity: 0; transform: translateY(30px); }
                to { opacity: 1; transform: translateY(0); }
            }

            .logo-container {
                margin-bottom: 32px;
                position: relative;
            }

            .logo-icon {
                font-size: 48px;
                margin-bottom: 16px;
                animation: pulse 2s ease-in-out infinite;
            }

            .logo-text {
                font-size: 32px;
                font-weight: 800;
                background: linear-gradient(45deg, #fff, #f0f0f0);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
                margin-bottom: 8px;
            }

            .version-badge {
                display: inline-block;
                padding: 4px 12px;
                background: linear-gradient(45deg, #4ade80, #22c55e);
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .status-text {
                font-size: 18px;
                margin-bottom: 32px;
                opacity: 0.9;
                font-weight: 500;
            }

            .highlight {
                background: linear-gradient(45deg, #fbbf24, #f59e0b);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                background-clip: text;
                font-weight: 700;
            }

            .progress-container {
                margin-bottom: 32px;
                position: relative;
            }

            .progress-bar {
                width: 100%;
                height: 8px;
                background: rgba(255, 255, 255, 0.2);
                border-radius: 10px;
                overflow: hidden;
                position: relative;
                margin-bottom: 12px;
            }

            .progress-fill {
                height: 100%;
                background: linear-gradient(90deg, #4ade80, #22c55e, #16a34a);
                border-radius: 10px;
                width: 0%;
                transition: width 0.3s ease;
                position: relative;
            }

            .progress-glow {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
                animation: progressGlow 2s ease-in-out infinite;
            }

            .progress-text {
                font-size: 14px;
                font-weight: 600;
                font-family: 'JetBrains Mono', monospace;
                opacity: 0.8;
            }

            .stats-container {
                display: flex;
                justify-content: center;
                align-items: center;
                margin-bottom: 32px;
                padding: 16px;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 16px;
                backdrop-filter: blur(10px);
            }

            .stat-item {
                text-align: center;
                flex: 1;
            }

            .stat-label {
                font-size: 12px;
                opacity: 0.7;
                margin-bottom: 4px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .stat-value {
                font-size: 16px;
                font-weight: 700;
                font-family: 'JetBrains Mono', monospace;
            }

            .stat-divider {
                width: 1px;
                height: 30px;
                background: rgba(255, 255, 255, 0.3);
                margin: 0 16px;
            }

            .loading-container {
                margin-bottom: 24px;
            }

            .spinner-modern {
                width: 40px;
                height: 40px;
                border: 3px solid rgba(255, 255, 255, 0.2);
                border-top: 3px solid #4ade80;
                border-radius: 50%;
                animation: spin 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
                margin: 0 auto;
            }

            .footer-text {
                font-size: 13px;
                opacity: 0.6;
                font-weight: 400;
            }

            .success-container {
                animation: successPulse 0.6s ease-out;
            }

            @keyframes successPulse {
                0% { transform: scale(0.9); opacity: 0; }
                50% { transform: scale(1.05); }
                100% { transform: scale(1); opacity: 1; }
            }

            .success-icon {
                font-size: 64px;
                margin-bottom: 24px;
                animation: bounce 0.6s ease-out;
            }

            @keyframes bounce {
                0%, 20%, 53%, 80%, 100% { transform: translate3d(0,0,0); }
                40%, 43% { transform: translate3d(0,-30px,0); }
                70% { transform: translate3d(0,-15px,0); }
                90% { transform: translate3d(0,-4px,0); }
            }

            .continue-btn {
                padding: 16px 32px;
                background: linear-gradient(45deg, #4ade80, #22c55e);
                color: white;
                border: none;
                border-radius: 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                font-family: 'Inter', sans-serif;
                box-shadow: 0 10px 25px rgba(74, 222, 128, 0.3);
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .continue-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 15px 35px rgba(74, 222, 128, 0.4);
            }

            .url-display {
                background: rgba(0, 0, 0, 0.3);
                padding: 16px;
                border-radius: 12px;
                margin: 24px 0;
                word-break: break-all;
                font-family: 'JetBrains Mono', monospace;
                font-size: 13px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                max-height: 100px;
                overflow-y: auto;
            }
        `;
        document.head.appendChild(style);

        // Update timer every 100ms for smoother updates
        const timer = setInterval(() => {
            if (!document.getElementById("kxBypass-overlay")) {
                clearInterval(timer);
                return;
            }
            const elapsed = Math.round((Date.now() - bypassState.startTime) / 1000);
            const timeElement = document.getElementById('elapsed-time');
            if (timeElement) {
                timeElement.textContent = `${elapsed}s`;
            }
        }, 100);
    }

    function updateRetryUI() {
        const statValue = document.querySelector('.stat-item:nth-child(3) .stat-value');
        if (statValue) {
            statValue.textContent = `${bypassState.retryCount + 1}/${CONFIG.MAX_RETRIES + 1}`;
        }
    }

    function showBypassResult(destinationUrl) {
        let overlay = document.getElementById("kxBypass-overlay");
        if (!overlay) {
            createPremiumUI();
            overlay = document.getElementById("kxBypass-overlay");
        }

        const totalTime = Math.round((Date.now() - bypassState.startTime) / 1000);

        overlay.innerHTML = `
            <div class="particles">
                ${Array.from({length: 30}, (_, i) => `<div class="particle" style="--delay: ${i * 0.1}s"></div>`).join('')}
            </div>

            <div class="main-container success-container">
                <div class="success-icon">✅</div>

                <div class="logo-text" style="color: #4ade80; margin-bottom: 16px;">
                    Bypass Successful!
                </div>

                <div class="status-text">
                    Completed in <span class="highlight">${totalTime} seconds</span>
                </div>

                <div class="stats-container">
                    <div class="stat-item">
                        <div class="stat-label">Speed</div>
                        <div class="stat-value" style="color: #4ade80;">Ultra Fast</div>
                    </div>
                    <div class="stat-divider"></div>
                    <div class="stat-item">
                        <div class="stat-label">Status</div>
                        <div class="stat-value" style="color: #4ade80;">Success</div>
                    </div>
                    <div class="stat-divider"></div>
                    <div class="stat-item">
                        <div class="stat-label">Time</div>
                        <div class="stat-value">${totalTime}s</div>
                    </div>
                </div>

                <div class="url-display">
                    ${destinationUrl}
                </div>

                <button class="continue-btn" onclick="window.location.href='${destinationUrl}'">
                    Continue to Destination →
                </button>

                <div class="footer-text" style="margin-top: 20px;">
                    🚀 Enhanced bypass completed successfully
                </div>
            </div>
        `;
    }

    function showErrorUI(message) {
        let overlay = document.getElementById("kxBypass-overlay");
        if (!overlay) {
            createPremiumUI();
            overlay = document.getElementById("kxBypass-overlay");
        }

        const totalTime = Math.round((Date.now() - bypassState.startTime) / 1000);

        overlay.innerHTML = `
            <div class="particles">
                ${Array.from({length: 20}, (_, i) => `<div class="particle" style="--delay: ${i * 0.1}s"></div>`).join('')}
            </div>

            <div class="main-container">
                <div class="success-icon" style="color: #ef4444;">❌</div>

                <div class="logo-text" style="color: #ef4444; margin-bottom: 16px;">
                    Bypass Failed
                </div>

                <div class="status-text">
                    ${message}
                </div>

                <div class="stats-container" style="background: rgba(239, 68, 68, 0.1);">
                    <div class="stat-item">
                        <div class="stat-label">Time</div>
                        <div class="stat-value">${totalTime}s</div>
                    </div>
                    <div class="stat-divider"></div>
                    <div class="stat-item">
                        <div class="stat-label">Attempts</div>
                        <div class="stat-value">${bypassState.retryCount}/${CONFIG.MAX_RETRIES}</div>
                    </div>
                    <div class="stat-divider"></div>
                    <div class="stat-item">
                        <div class="stat-label">Status</div>
                        <div class="stat-value" style="color: #ef4444;">Failed</div>
                    </div>
                </div>

                <button class="continue-btn" onclick="window.location.reload()"
                        style="background: linear-gradient(45deg, #ef4444, #dc2626);">
                    🔄 Refresh & Retry
                </button>

                <div class="footer-text" style="margin-top: 20px;">
                    Please try refreshing the page
                </div>
            </div>
        `;
    }

    function decodeURI(encodedString, prefixLength = 5) {
        try {
            let decodedString = "";
            const base64Decoded = atob(encodedString);
            const prefix = base64Decoded.substring(0, prefixLength);
            const encodedPortion = base64Decoded.substring(prefixLength);

            for (let i = 0; i < encodedPortion.length; i++) {
                const encodedChar = encodedPortion.charCodeAt(i);
                const prefixChar = prefix.charCodeAt(i % prefix.length);
                const decodedChar = encodedChar ^ prefixChar;
                decodedString += String.fromCharCode(decodedChar);
            }

            return decodedString;
        } catch (error) {
            console.error('Decoding error:', error);
            throw new Error('Failed to decode destination URL');
        }
    }

    // Ultra-fast initialization
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            if (window.location.href.includes("loot")) {
                handleLootlinks();
            }
        });
    } else {
        if (window.location.href.includes("loot")) {
            handleLootlinks();
        }
    }
})();
