// ==UserScript==
// @name         kxBypass LootLabs Universal
// @namespace    https://discord.gg/pqEBSTqdxV
// @version      v3.0
// @description  Universal Bypass for Lootlinks - Works on ALL Devices (PC, Mobile, Tablet)
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
// @grant        GM_xmlhttpRequest
// @grant        GM_addStyle
// @grant        unsafeWindow
// @connect      *
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';

    // Configuration
    const CONFIG = {
        WEBSOCKET_TIMEOUT: 10000,
        HEARTBEAT_INTERVAL: 500,
        UI_DELAY: 300,
        MAX_RETRIES: 3,
        CHECK_INTERVAL: 100
    };

    // State management
    const state = {
        active: false,
        startTime: 0,
        progress: 0,
        retryCount: 0,
        deviceType: getDeviceType()
    };

    // Detect device type
    function getDeviceType() {
        const ua = navigator.userAgent;
        const width = window.innerWidth;
        
        if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua)) {
            return 'mobile';
        }
        if (width <= 768) {
            return 'mobile';
        }
        if (width <= 1024) {
            return 'tablet';
        }
        return 'desktop';
    }

    // Logging helper
    function log(msg, type = 'info') {
        const prefix = '[kxBypass]';
        const styles = {
            info: 'color: #4ade80',
            error: 'color: #ef4444',
            warn: 'color: #fbbf24'
        };
        console.log(`%c${prefix} ${msg}`, styles[type] || styles.info);
    }

    // Progress simulator
    function simulateProgress() {
        const interval = setInterval(() => {
            if (state.progress < 85) {
                state.progress += Math.random() * 10 + 5;
                updateProgress();
            } else {
                clearInterval(interval);
            }
        }, 300);
    }

    function updateProgress() {
        const bar = document.querySelector('.kx-progress-bar');
        const text = document.querySelector('.kx-progress-text');
        if (bar && text) {
            bar.style.width = Math.min(state.progress, 100) + '%';
            text.textContent = Math.round(state.progress) + '%';
        }
    }

    // Main bypass handler
    function initBypass() {
        if (state.active) return;
        
        state.active = true;
        state.startTime = Date.now();
        
        log('Initializing bypass...', 'info');

        // Intercept fetch
        const originalFetch = unsafeWindow.fetch || window.fetch;
        const fetchHandler = function(...args) {
            const url = typeof args[0] === 'string' ? args[0] : args[0].url;
            
            if (url && url.includes('/tc')) {
                log('Intercepted /tc request', 'info');
                return handleBypassRequest(originalFetch, args);
            }
            
            return originalFetch.apply(this, args);
        };

        unsafeWindow.fetch = fetchHandler;
        window.fetch = fetchHandler;

        // Block popups
        unsafeWindow.open = function() { log('Blocked popup', 'warn'); return null; };
        window.open = function() { log('Blocked popup', 'warn'); return null; };

        // Block redirects
        const preventRedirect = function() {
            log('Blocked redirect', 'warn');
            return false;
        };
        
        Object.defineProperty(unsafeWindow.location, 'href', {
            set: preventRedirect
        });
        Object.defineProperty(unsafeWindow.location, 'replace', {
            value: preventRedirect
        });

        // Show UI
        setTimeout(() => {
            createUI();
            simulateProgress();
        }, CONFIG.UI_DELAY);
    }

    // Handle bypass request
    async function handleBypassRequest(originalFetch, args) {
        try {
            log('Processing bypass request...', 'info');
            
            const response = await originalFetch.apply(unsafeWindow, args);
            const clone = response.clone();
            const data = await clone.json();

            log('Response received', 'info');

            if (Array.isArray(data) && data.length > 0) {
                processData(data[0]);
            } else {
                throw new Error('Invalid response data');
            }

            return response;
        } catch (error) {
            log('Request error: ' + error.message, 'error');
            
            if (state.retryCount < CONFIG.MAX_RETRIES) {
                state.retryCount++;
                updateRetryDisplay();
                await new Promise(r => setTimeout(r, 1000));
                return originalFetch.apply(unsafeWindow, args);
            }
            
            showError('Bypass failed after multiple attempts');
            throw error;
        }
    }

    // Process bypass data
    function processData(data) {
        log('Processing data...', 'info');
        
        const { urid, task_id, action_pixel_url, session_id } = data;

        if (!urid || !task_id) {
            log('Missing required parameters', 'error');
            showError('Missing required data');
            return;
        }

        // Get WebSocket shard
        const shard = parseInt(urid.slice(-5)) % 3;
        
        // Try to get required globals
        let INCENTIVE_SERVER_DOMAIN, KEY, TID, INCENTIVE_SYNCER_DOMAIN;
        
        try {
            INCENTIVE_SERVER_DOMAIN = unsafeWindow.INCENTIVE_SERVER_DOMAIN || window.INCENTIVE_SERVER_DOMAIN || 'llgateway.lootlabs.gg';
            KEY = unsafeWindow.KEY || window.KEY || '';
            TID = unsafeWindow.TID || window.TID || '';
            INCENTIVE_SYNCER_DOMAIN = unsafeWindow.INCENTIVE_SYNCER_DOMAIN || window.INCENTIVE_SYNCER_DOMAIN || 'lootlabs.gg';
        } catch (e) {
            log('Could not access globals: ' + e.message, 'warn');
        }

        const wsUrl = `wss://${shard}.${INCENTIVE_SERVER_DOMAIN}/c?uid=${urid}&cat=${task_id}&key=${KEY}&session_id=${session_id}&is_loot=1&tid=${TID}`;
        
        log('Connecting to WebSocket...', 'info');
        
        const ws = new WebSocket(wsUrl);
        let heartbeat;
        let timeout = setTimeout(() => {
            ws.close();
            log('WebSocket timeout', 'error');
            showError('Connection timeout');
        }, CONFIG.WEBSOCKET_TIMEOUT);

        ws.onopen = function() {
            clearTimeout(timeout);
            log('WebSocket connected', 'info');
            state.progress = 65;
            updateProgress();

            heartbeat = setInterval(() => {
                if (ws.readyState === WebSocket.OPEN) {
                    ws.send('0');
                }
            }, CONFIG.HEARTBEAT_INTERVAL);

            // Send tracking beacons
            try {
                navigator.sendBeacon(`https://${shard}.${INCENTIVE_SERVER_DOMAIN}/st?uid=${urid}&cat=${task_id}`);
                
                if (action_pixel_url) {
                    fetch('https:' + action_pixel_url).catch(() => {});
                }
                
                fetch(`https://${INCENTIVE_SYNCER_DOMAIN}/td?ac=auto_complete&urid=${urid}&cat=${task_id}&tid=${TID}`).catch(() => {});
            } catch (e) {
                log('Tracking error: ' + e.message, 'warn');
            }
        };

        ws.onmessage = function(event) {
            log('Message received', 'info');
            
            if (event.data.startsWith('r:')) {
                clearInterval(heartbeat);
                state.progress = 100;
                updateProgress();

                const encoded = event.data.slice(2);
                try {
                    const url = decodeDestination(encoded);
                    log('Destination decoded: ' + url, 'info');
                    setTimeout(() => showSuccess(url), 500);
                } catch (error) {
                    log('Decode error: ' + error.message, 'error');
                    showError('Failed to decode destination');
                }
            }
        };

        ws.onerror = function(error) {
            clearInterval(heartbeat);
            clearTimeout(timeout);
            log('WebSocket error', 'error');
            showError('Connection error');
        };

        ws.onclose = function() {
            clearInterval(heartbeat);
            log('WebSocket closed', 'warn');
        };
    }

    // Decode destination URL
    function decodeDestination(encoded, prefixLen = 5) {
        try {
            let decoded = '';
            const b64 = atob(encoded);
            const prefix = b64.substring(0, prefixLen);
            const data = b64.substring(prefixLen);

            for (let i = 0; i < data.length; i++) {
                const dataChar = data.charCodeAt(i);
                const prefixChar = prefix.charCodeAt(i % prefix.length);
                const decodedChar = dataChar ^ prefixChar;
                decoded += String.fromCharCode(decodedChar);
            }

            return decoded;
        } catch (error) {
            throw new Error('Decoding failed');
        }
    }

    // Create UI
    function createUI() {
        // Clear page
        document.documentElement.innerHTML = '';
        
        // Add viewport for mobile
        const meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        document.head.appendChild(meta);

        // Add styles
        const style = document.createElement('style');
        style.textContent = getStyles();
        document.head.appendChild(style);

        // Create UI
        const isMobile = state.deviceType === 'mobile';
        const elapsed = Math.round((Date.now() - state.startTime) / 1000);

        document.body.innerHTML = `
            <div class="kx-overlay">
                <div class="kx-container">
                    <div class="kx-logo">🚀</div>
                    <div class="kx-title">kxBypass</div>
                    <div class="kx-version">v3.0 Universal</div>
                    
                    <div class="kx-status">Bypassing in progress...</div>
                    
                    <div class="kx-progress">
                        <div class="kx-progress-bar"></div>
                    </div>
                    <div class="kx-progress-text">0%</div>
                    
                    <div class="kx-stats">
                        <div class="kx-stat">
                            <div class="kx-stat-label">Time</div>
                            <div class="kx-stat-value" id="kx-time">${elapsed}s</div>
                        </div>
                        <div class="kx-stat">
                            <div class="kx-stat-label">Status</div>
                            <div class="kx-stat-value">Active</div>
                        </div>
                        <div class="kx-stat">
                            <div class="kx-stat-label">Device</div>
                            <div class="kx-stat-value">${state.deviceType}</div>
                        </div>
                    </div>
                    
                    <div class="kx-spinner"></div>
                    
                    <div class="kx-footer">Working on all devices</div>
                </div>
            </div>
        `;

        // Update timer
        setInterval(() => {
            const el = document.getElementById('kx-time');
            if (el) {
                const t = Math.round((Date.now() - state.startTime) / 1000);
                el.textContent = t + 's';
            }
        }, 100);
    }

    // Show success
    function showSuccess(url) {
        const elapsed = Math.round((Date.now() - state.startTime) / 1000);
        
        const container = document.querySelector('.kx-container');
        if (container) {
            container.innerHTML = `
                <div class="kx-logo" style="font-size: 60px;">✅</div>
                <div class="kx-title" style="color: #4ade80;">Success!</div>
                <div class="kx-status">Bypass completed in ${elapsed} seconds</div>
                
                <div class="kx-stats">
                    <div class="kx-stat">
                        <div class="kx-stat-label">Status</div>
                        <div class="kx-stat-value" style="color: #4ade80;">Complete</div>
                    </div>
                    <div class="kx-stat">
                        <div class="kx-stat-label">Time</div>
                        <div class="kx-stat-value">${elapsed}s</div>
                    </div>
                </div>
                
                <div class="kx-url">${url}</div>
                
                <button class="kx-button" onclick="window.location.href='${url}'">
                    Continue →
                </button>
                
                <div class="kx-footer">Click button to continue</div>
            `;
        }
    }

    // Show error
    function showError(message) {
        const elapsed = Math.round((Date.now() - state.startTime) / 1000);
        
        const container = document.querySelector('.kx-container');
        if (container) {
            container.innerHTML = `
                <div class="kx-logo" style="font-size: 60px; color: #ef4444;">❌</div>
                <div class="kx-title" style="color: #ef4444;">Failed</div>
                <div class="kx-status">${message}</div>
                
                <div class="kx-stats">
                    <div class="kx-stat">
                        <div class="kx-stat-label">Status</div>
                        <div class="kx-stat-value" style="color: #ef4444;">Error</div>
                    </div>
                    <div class="kx-stat">
                        <div class="kx-stat-label">Time</div>
                        <div class="kx-stat-value">${elapsed}s</div>
                    </div>
                </div>
                
                <button class="kx-button" style="background: linear-gradient(45deg, #ef4444, #dc2626);" onclick="window.location.reload()">
                    🔄 Retry
                </button>
                
                <div class="kx-footer">Try refreshing the page</div>
            `;
        }
    }

    // Update retry display
    function updateRetryDisplay() {
        const stats = document.querySelectorAll('.kx-stat-value');
        if (stats[1]) {
            stats[1].textContent = `Retry ${state.retryCount}`;
        }
    }

    // Get styles
    function getStyles() {
        const isMobile = state.deviceType === 'mobile';
        
        return `
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                -webkit-tap-highlight-color: transparent;
            }
            
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                overflow: hidden;
                position: fixed;
                width: 100%;
                height: 100%;
            }
            
            .kx-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100vw;
                height: 100vh;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                padding: ${isMobile ? '20px' : '40px'};
            }
            
            .kx-container {
                background: rgba(255, 255, 255, 0.95);
                border-radius: ${isMobile ? '20px' : '30px'};
                padding: ${isMobile ? '30px 20px' : '50px 40px'};
                max-width: ${isMobile ? '100%' : '500px'};
                width: 100%;
                text-align: center;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                animation: slideUp 0.5s ease;
            }
            
            @keyframes slideUp {
                from { opacity: 0; transform: translateY(30px); }
                to { opacity: 1; transform: translateY(0); }
            }
            
            .kx-logo {
                font-size: ${isMobile ? '48px' : '64px'};
                margin-bottom: ${isMobile ? '15px' : '20px'};
                animation: pulse 2s infinite;
            }
            
            @keyframes pulse {
                0%, 100% { transform: scale(1); }
                50% { transform: scale(1.1); }
            }
            
            .kx-title {
                font-size: ${isMobile ? '28px' : '36px'};
                font-weight: 800;
                color: #1f2937;
                margin-bottom: ${isMobile ? '8px' : '10px'};
            }
            
            .kx-version {
                display: inline-block;
                background: linear-gradient(45deg, #4ade80, #22c55e);
                color: white;
                padding: ${isMobile ? '4px 12px' : '6px 16px'};
                border-radius: 20px;
                font-size: ${isMobile ? '11px' : '13px'};
                font-weight: 600;
                margin-bottom: ${isMobile ? '20px' : '30px'};
            }
            
            .kx-status {
                font-size: ${isMobile ? '15px' : '18px'};
                color: #4b5563;
                margin-bottom: ${isMobile ? '20px' : '30px'};
            }
            
            .kx-progress {
                width: 100%;
                height: ${isMobile ? '8px' : '10px'};
                background: #e5e7eb;
                border-radius: 10px;
                overflow: hidden;
                margin-bottom: ${isMobile ? '10px' : '15px'};
            }
            
            .kx-progress-bar {
                height: 100%;
                background: linear-gradient(90deg, #4ade80, #22c55e);
                width: 0%;
                transition: width 0.3s ease;
            }
            
            .kx-progress-text {
                font-size: ${isMobile ? '14px' : '16px'};
                font-weight: 700;
                color: #1f2937;
                margin-bottom: ${isMobile ? '20px' : '30px'};
            }
            
            .kx-stats {
                display: flex;
                justify-content: space-around;
                margin-bottom: ${isMobile ? '20px' : '30px'};
                gap: ${isMobile ? '10px' : '20px'};
            }
            
            .kx-stat {
                flex: 1;
            }
            
            .kx-stat-label {
                font-size: ${isMobile ? '11px' : '12px'};
                color: #6b7280;
                margin-bottom: 5px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            
            .kx-stat-value {
                font-size: ${isMobile ? '16px' : '18px'};
                font-weight: 700;
                color: #1f2937;
            }
            
            .kx-spinner {
                width: ${isMobile ? '40px' : '50px'};
                height: ${isMobile ? '40px' : '50px'};
                border: 4px solid #e5e7eb;
                border-top-color: #4ade80;
                border-radius: 50%;
                animation: spin 1s linear infinite;
                margin: 0 auto ${isMobile ? '20px' : '30px'};
            }
            
            @keyframes spin {
                to { transform: rotate(360deg); }
            }
            
            .kx-url {
                background: #f3f4f6;
                padding: ${isMobile ? '12px' : '15px'};
                border-radius: ${isMobile ? '10px' : '12px'};
                font-size: ${isMobile ? '12px' : '13px'};
                color: #1f2937;
                word-break: break-all;
                margin-bottom: ${isMobile ? '20px' : '25px'};
                max-height: ${isMobile ? '80px' : '100px'};
                overflow-y: auto;
            }
            
            .kx-button {
                width: 100%;
                padding: ${isMobile ? '14px' : '16px'};
                background: linear-gradient(45deg, #4ade80, #22c55e);
                color: white;
                border: none;
                border-radius: ${isMobile ? '10px' : '12px'};
                font-size: ${isMobile ? '15px' : '16px'};
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s;
                margin-bottom: ${isMobile ? '15px' : '20px'};
            }
            
            .kx-button:active {
                transform: scale(0.98);
            }
            
            .kx-footer {
                font-size: ${isMobile ? '12px' : '13px'};
                color: #9ca3af;
            }
            
            @media (max-height: 600px) {
                .kx-container {
                    padding: 20px;
                }
                .kx-logo {
                    font-size: 36px;
                    margin-bottom: 10px;
                }
                .kx-title {
                    font-size: 24px;
                }
                .kx-stats {
                    margin-bottom: 15px;
                }
            }
        `;
    }

    // Initialize
    function init() {
        log('Script loaded', 'info');
        
        // Check if on loot site
        if (!window.location.href.includes('loot')) {
            log('Not a loot site, exiting', 'warn');
            return;
        }

        // Wait for page load
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initBypass);
        } else {
            initBypass();
        }
    }

    // Start
    init();
})();
