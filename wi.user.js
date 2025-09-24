// ==UserScript==
// @name         Enhanced work.ink Bypass
// @namespace    http://tampermonkey.net/
// @version      2025-01-15-v2
// @description  Ultra-fast enhanced bypass for work.ink shortened links with premium UI
// @author       Enhanced by AI
// @match        https://work.ink/*
// @match        https://*.work.ink/*
// @run-at       document-start
// @icon         https://www.google.com/s2/favicons?sz=64&domain=work.ink
// @grant        GM_addStyle
// @grant        GM_setValue
// @grant        GM_getValue
// @grant        GM_notification
// @downloadURL  https://github.com/xenlua/x/raw/refs/heads/main/wi.user.js
// @updateURL    https://github.com/xenlua/x/raw/refs/heads/main/wi.user.js
// ==/UserScript==

(function() {
    "use strict";

    const DEBUG = GM_getValue('debug_mode', false);
    const FAST_MODE = true;
    const MIN_WAIT_TIME = 3; // Reduced from 15 seconds
    const MAX_WAIT_TIME = 8; // Reduced from 45 seconds

    // Enhanced logging with timestamps and better formatting
    const oldLog = unsafeWindow.console.log;
    const oldWarn = unsafeWindow.console.warn;
    const oldError = unsafeWindow.console.error;

    function log(...args) {
        if (DEBUG) oldLog(`[${new Date().toLocaleTimeString()}] [UnShortener]`, ...args);
    }
    function warn(...args) {
        if (DEBUG) oldWarn(`[${new Date().toLocaleTimeString()}] [UnShortener]`, ...args);
    }
    function error(...args) {
        if (DEBUG) oldError(`[${new Date().toLocaleTimeString()}] [UnShortener]`, ...args);
    }

    // Prevent console clearing in debug mode
    if (DEBUG) unsafeWindow.console.clear = function() {};

    // Enhanced UI Styles
    GM_addStyle(`
        .bypass-container {
            position: fixed !important;
            top: 20px !important;
            right: 20px !important;
            z-index: 999999 !important;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
            max-width: 350px !important;
            min-width: 280px !important;
        }

        .bypass-card {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%) !important;
            border-radius: 12px !important;
            padding: 16px 20px !important;
            box-shadow: 0 12px 40px rgba(255, 107, 107, 0.4) !important;
            backdrop-filter: blur(10px) !important;
            border: 1px solid rgba(255, 255, 255, 0.2) !important;
            color: white !important;
            font-size: 14px !important;
            line-height: 1.4 !important;
            animation: slideIn 0.3s ease-out !important;
        }

        @keyframes slideIn {
            from {
                transform: translateX(100%) !important;
                opacity: 0 !important;
            }
            to {
                transform: translateX(0) !important;
                opacity: 1 !important;
            }
        }

        .bypass-header {
            display: flex !important;
            align-items: center !important;
            margin-bottom: 12px !important;
            font-weight: 600 !important;
            font-size: 16px !important;
        }

        .bypass-icon {
            margin-right: 8px !important;
            font-size: 18px !important;
        }

        .bypass-status {
            margin-bottom: 8px !important;
            opacity: 0.9 !important;
        }

        .bypass-progress {
            width: 100% !important;
            height: 4px !important;
            background: rgba(255, 255, 255, 0.2) !important;
            border-radius: 2px !important;
            overflow: hidden !important;
            margin-top: 8px !important;
        }

        .bypass-progress-bar {
            height: 100% !important;
            background: linear-gradient(90deg, #00ff88, #00cc6a) !important;
            border-radius: 2px !important;
            transition: width 0.3s ease !important;
            width: 0% !important;
        }

        .bypass-countdown {
            text-align: center !important;
            font-size: 18px !important;
            font-weight: bold !important;
            margin: 8px 0 !important;
            color: #00ff88 !important;
            text-shadow: 0 0 10px rgba(0, 255, 136, 0.5) !important;
        }

        .bypass-url {
            background: rgba(0, 0, 0, 0.2) !important;
            padding: 8px 12px !important;
            border-radius: 6px !important;
            font-family: 'Courier New', monospace !important;
            font-size: 12px !important;
            word-break: break-all !important;
            margin-top: 8px !important;
            border-left: 3px solid #00ff88 !important;
        }

        .bypass-speed-indicator {
            display: inline-block !important;
            background: rgba(0, 255, 136, 0.2) !important;
            color: #00ff88 !important;
            padding: 2px 6px !important;
            border-radius: 4px !important;
            font-size: 10px !important;
            font-weight: bold !important;
            margin-left: 8px !important;
            animation: pulse 1.5s infinite !important;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
        }

        .bypass-close {
            position: absolute !important;
            top: 8px !important;
            right: 12px !important;
            background: none !important;
            border: none !important;
            color: rgba(255, 255, 255, 0.7) !important;
            font-size: 18px !important;
            cursor: pointer !important;
            padding: 0 !important;
            width: 20px !important;
            height: 20px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
        }

        .bypass-close:hover {
            color: white !important;
            background: rgba(255, 255, 255, 0.1) !important;
            border-radius: 50% !important;
        }

        .bypass-debug {
            position: fixed !important;
            bottom: 20px !important;
            left: 20px !important;
            background: rgba(0, 0, 0, 0.8) !important;
            color: #00ff00 !important;
            padding: 8px 12px !important;
            border-radius: 6px !important;
            font-family: 'Courier New', monospace !important;
            font-size: 11px !important;
            z-index: 999998 !important;
            max-width: 300px !important;
            word-break: break-word !important;
        }
    `);

    // Enhanced UI Manager
    class BypassUI {
        constructor() {
            this.container = null;
            this.card = null;
            this.statusElement = null;
            this.progressBar = null;
            this.countdownElement = null;
            this.urlElement = null;
            this.debugElement = null;
            this.isVisible = false;
            this.init();
        }

        init() {
            // Create main container
            this.container = document.createElement("div");
            this.container.className = "bypass-container";

            // Create card
            this.card = document.createElement("div");
            this.card.className = "bypass-card";

            // Header
            const header = document.createElement("div");
            header.className = "bypass-header";
            header.innerHTML = `
                <span class="bypass-icon">⚡</span>
                work.ink Ultra Bypass
                <span class="bypass-speed-indicator">FAST MODE</span>
                <button class="bypass-close" onclick="this.closest('.bypass-container').style.display='none'">×</button>
            `;

            // Status
            this.statusElement = document.createElement("div");
            this.statusElement.className = "bypass-status";

            // Progress bar
            const progressContainer = document.createElement("div");
            progressContainer.className = "bypass-progress";
            this.progressBar = document.createElement("div");
            this.progressBar.className = "bypass-progress-bar";
            progressContainer.appendChild(this.progressBar);

            // Countdown
            this.countdownElement = document.createElement("div");
            this.countdownElement.className = "bypass-countdown";
            this.countdownElement.style.display = "none";

            // URL display
            this.urlElement = document.createElement("div");
            this.urlElement.className = "bypass-url";
            this.urlElement.style.display = "none";

            // Assemble card
            this.card.appendChild(header);
            this.card.appendChild(this.statusElement);
            this.card.appendChild(progressContainer);
            this.card.appendChild(this.countdownElement);
            this.card.appendChild(this.urlElement);

            this.container.appendChild(this.card);

            // Debug panel
            if (DEBUG) {
                this.debugElement = document.createElement("div");
                this.debugElement.className = "bypass-debug";
                document.documentElement.appendChild(this.debugElement);
            }

            // Attach to shadow DOM for better isolation
            const shadow = this.container.attachShadow({ mode: "closed" });
            shadow.appendChild(this.card);

            document.documentElement.appendChild(this.container);
            this.isVisible = true;
        }

        updateStatus(message, icon = "🔄", progress = 0) {
            if (!this.statusElement) return;

            this.statusElement.innerHTML = `<span class="bypass-icon">${icon}</span> ${message}`;
            this.progressBar.style.width = `${Math.min(100, Math.max(0, progress))}%`;

            // Add speed indicator for fast operations
            if (progress > 50) {
                this.statusElement.innerHTML += ` <span class="bypass-speed-indicator">TURBO</span>`;
            }

            log("Status updated:", message, `${progress}%`);
        }

        showCountdown(seconds, url = null) {
            if (!this.countdownElement) return;

            this.countdownElement.style.display = "block";
            this.countdownElement.textContent = `${seconds}s`;

            if (url && this.urlElement) {
                this.urlElement.style.display = "block";
                this.urlElement.textContent = `Destination: ${url}`;
            }
        }

        hideCountdown() {
            if (this.countdownElement) this.countdownElement.style.display = "none";
            if (this.urlElement) this.urlElement.style.display = "none";
        }

        updateDebug(message) {
            if (DEBUG && this.debugElement) {
                this.debugElement.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
            }
        }

        hide() {
            if (this.container) {
                this.container.style.display = "none";
                this.isVisible = false;
            }
        }

        show() {
            if (this.container) {
                this.container.style.display = "block";
                this.isVisible = true;
            }
        }
    }

    // Initialize UI
    const ui = new BypassUI();
    ui.updateStatus("Initializing ultra-fast bypass...", "⚡", 10);

    // Enhanced name mapping with more variations
    const NAME_MAP = {
        sendMessage: ["sendMessage", "sendMsg", "writeMessage", "writeMsg", "send", "emit"],
        onLinkInfo: ["onLinkInfo", "linkInfo", "handleLinkInfo"],
        onLinkDestination: ["onLinkDestination", "linkDestination", "handleDestination", "onDestination"]
    };

    function resolveName(obj, candidates) {
        for (let i = 0; i < candidates.length; i++) {
            const name = candidates[i];
            if (typeof obj[name] === "function") {
                return { fn: obj[name], index: i, name };
            }
        }
        return { fn: null, index: -1, name: null };
    }

    // Enhanced global state management
    let _sessionController = undefined;
    let _sendMessage = undefined;
    let _onLinkInfo = undefined;
    let _onLinkDestination = undefined;
    let _bypassStartTime = Date.now();
    let _captchaSolved = false;
    let _linkReceived = false;
    let _fastModeEnabled = FAST_MODE;

    // Enhanced packet types with more comprehensive coverage
    function getClientPacketTypes() {
        return {
            ANNOUNCE: "c_announce",
            MONETIZATION: "c_monetization",
            SOCIAL_STARTED: "c_social_started",
            RECAPTCHA_RESPONSE: "c_recaptcha_response",
            HCAPTCHA_RESPONSE: "c_hcaptcha_response",
            TURNSTILE_RESPONSE: "c_turnstile_response",
            ADBLOCKER_DETECTED: "c_adblocker_detected",
            FOCUS_LOST: "c_focus_lost",
            OFFERS_SKIPPED: "c_offers_skipped",
            FOCUS: "c_focus",
            WORKINK_PASS_AVAILABLE: "c_workink_pass_available",
            WORKINK_PASS_USE: "c_workink_pass_use",
            PING: "c_ping",
            HEARTBEAT: "c_heartbeat",
            USER_ACTIVITY: "c_user_activity"
        };
    }

    // Enhanced monetization handler with better coverage
    function handleMonetization(monetizationType, clientPacketTypes) {
        const handlers = {
            22: () => { // readArticles2
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "readArticles2",
                    payload: { event: "read" }
                });
                ui.updateDebug("Handled readArticles2 monetization");
            },
            25: () => { // operaGX
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "operaGX",
                    payload: { event: "start" }
                });
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "operaGX",
                    payload: { event: "installClicked" }
                });

                // Enhanced callback with better error handling
                fetch('https://work.ink/_api/v2/callback/operaGX', {
                    method: 'POST',
                    mode: 'no-cors',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ 'noteligible': true })
                }).catch(() => {}); // Silent fail

                ui.updateDebug("Handled operaGX monetization");
            },
            34: () => { // norton
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "norton",
                    payload: { event: "start" }
                });
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "norton",
                    payload: { event: "installClicked" }
                });
                ui.updateDebug("Handled norton monetization");
            },
            71: () => { // externalArticles
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "externalArticles",
                    payload: { event: "start" }
                });
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "externalArticles",
                    payload: { event: "installClicked" }
                });
                ui.updateDebug("Handled externalArticles monetization");
            },
            45: () => { // pdfeditor
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "pdfeditor",
                    payload: { event: "installed" }
                });
                ui.updateDebug("Handled pdfeditor monetization");
            },
            57: () => { // betterdeals
                _sendMessage.call(_sessionController, clientPacketTypes.MONETIZATION, {
                    type: "betterdeals",
                    payload: { event: "installed" }
                });
                ui.updateDebug("Handled betterdeals monetization");
            }
        };

        const handler = handlers[monetizationType];
        if (handler) {
            handler();
            return true;
        } else {
            log("Unknown monetization type:", monetizationType);
            ui.updateDebug(`Unknown monetization: ${monetizationType}`);
            return false;
        }
    }

    // Enhanced sendMessage proxy with better error handling
    function createSendMessageProxy() {
        const clientPacketTypes = getClientPacketTypes();

        return function(...args) {
            const packet_type = args[0];
            const packet_data = args[1];

            // Don't log ping packets to reduce noise
            if (packet_type !== clientPacketTypes.PING && packet_type !== clientPacketTypes.HEARTBEAT) {
                log("Sent message:", packet_type, packet_data);
            }

            // Block adblocker detection
            if (packet_type === clientPacketTypes.ADBLOCKER_DETECTED) {
                warn("Blocked adblocker detected message");
                ui.updateDebug("Blocked adblocker detection");
                return;
            }

            // Enhanced captcha response handling
            if (_sessionController.linkInfo &&
                (packet_type === clientPacketTypes.TURNSTILE_RESPONSE ||
                 packet_type === clientPacketTypes.RECAPTCHA_RESPONSE ||
                 packet_type === clientPacketTypes.HCAPTCHA_RESPONSE)) {

                _captchaSolved = true;
                ui.updateStatus("Captcha solved! Turbo processing...", "🚀", 60);

                const ret = _sendMessage.apply(this, args);

                // Ultra-fast bypass sequence with minimal delay
                setTimeout(() => {
                    let processedCount = 0;
                    const totalTasks = (_sessionController.linkInfo.socials?.length || 0) +
                                     (_sessionController.linkInfo.monetizations?.length || 0);

                    // Process social requirements
                    if (_sessionController.linkInfo.socials) {
                        for (const social of _sessionController.linkInfo.socials) {
                            _sendMessage.call(this, clientPacketTypes.SOCIAL_STARTED, {
                                url: social.url
                            });
                            processedCount++;
                            ui.updateStatus("Turbo social processing...", "📱", 60 + (processedCount / totalTasks) * 25);
                        }
                    }

                    // Process monetization requirements
                    if (_sessionController.linkInfo.monetizations) {
                        for (const monetization of _sessionController.linkInfo.monetizations) {
                            if (handleMonetization(monetization, clientPacketTypes)) {
                                processedCount++;
                                ui.updateStatus("Turbo monetization...", "💰", 60 + (processedCount / totalTasks) * 25);
                            }
                        }
                    }

                    ui.updateStatus("Ultra bypass complete! Getting destination...", "🎯", 85);
                }, 200); // Reduced from 500ms to 200ms

                return ret;
            }

            return _sendMessage.apply(this, args);
        };
    }

    // Enhanced link info handler
    function createOnLinkInfoProxy() {
        return function(...args) {
            const linkInfo = args[0];
            log("Link info received:", linkInfo);
            ui.updateDebug(`Link info: ${JSON.stringify(linkInfo).substring(0, 100)}...`);

            // Enhanced adblocker bypass
            Object.defineProperty(linkInfo, "isAdblockEnabled", {
                get() { return false },
                set(newValue) {
                    log("Attempted to set isAdblockEnabled to:", newValue);
                    ui.updateDebug(`Blocked adblock flag: ${newValue}`);
                },
                configurable: false,
                enumerable: true
            });

            ui.updateStatus("Link info received - analyzing...", "📋", 35);
            return _onLinkInfo.apply(this, args);
        };
    }

    // Enhanced destination handler with ultra-fast countdown
    function createOnLinkDestinationProxy() {
        return function (...args) {
            const payload = args[0];
            log("Link destination received:", payload);
            _linkReceived = true;

            ui.updateStatus("Destination locked! Preparing turbo redirect...", "🎯", 95);

            // Ultra-fast wait time calculation
            const minWaitTime = MIN_WAIT_TIME;
            const maxWaitTime = MAX_WAIT_TIME;
            const elapsedTime = (Date.now() - _bypassStartTime) / 1000;

            let waitTime = Math.max(minWaitTime, maxWaitTime - elapsedTime);
            waitTime = Math.ceil(waitTime);

            // If fast mode is enabled, reduce wait time further
            if (_fastModeEnabled) {
                waitTime = Math.max(1, Math.ceil(waitTime * 0.3)); // Reduce to 30% of original time
            }

            if (waitTime <= 0) {
                redirect(payload.url);
            } else {
                startUltraFastCountdown(payload.url, waitTime);
            }

            return _onLinkDestination.apply(this, args);
        };
    }

    // Ultra-fast countdown with premium UX
    function startUltraFastCountdown(url, waitLeft) {
        ui.updateStatus("Turbo redirect initiating...", "🚀", 98);
        ui.showCountdown(waitLeft, url);

        const interval = setInterval(() => {
            waitLeft -= 1;
            ui.showCountdown(waitLeft, url);

            if (waitLeft <= 0) {
                clearInterval(interval);
                redirect(url);
            }
        }, 1000);

        // Show notification
        if (typeof GM_notification !== 'undefined') {
            GM_notification({
                text: `🚀 Ultra-fast redirect in ${waitLeft}s`,
                title: "work.ink Ultra Bypass",
                timeout: 3000
            });
        }
    }

    // Ultra-fast redirect function
    function redirect(url) {
        ui.updateStatus("🚀 TURBO REDIRECT ACTIVATED!", "⚡", 100);
        ui.hideCountdown();

        log("Redirecting to:", url);

        // Show final notification
        if (typeof GM_notification !== 'undefined') {
            GM_notification({
                text: "⚡ Ultra bypass complete! Redirecting...",
                title: "work.ink Ultra Bypass",
                timeout: 2000
            });
        }

        setTimeout(() => {
            window.location.href = url;
        }, 300); // Reduced from 1000ms to 300ms
    }

    // Enhanced session controller setup
    function setupSessionControllerProxy() {
        const sendMessage = resolveName(_sessionController, NAME_MAP.sendMessage);
        const onLinkInfo = resolveName(_sessionController, NAME_MAP.onLinkInfo);
        const onLinkDestination = resolveName(_sessionController, NAME_MAP.onLinkDestination);

        if (!sendMessage.fn || !onLinkInfo.fn || !onLinkDestination.fn) {
            error("Failed to resolve all required methods");
            ui.updateStatus("Setup failed - missing methods", "❌", 0);
            return false;
        }

        _sendMessage = sendMessage.fn;
        _onLinkInfo = onLinkInfo.fn;
        _onLinkDestination = onLinkDestination.fn;

        const sendMessageProxy = createSendMessageProxy();
        const onLinkInfoProxy = createOnLinkInfoProxy();
        const onLinkDestinationProxy = createOnLinkDestinationProxy();

        // Enhanced property patching with better error handling
        try {
            Object.defineProperty(_sessionController, sendMessage.name, {
                get() { return sendMessageProxy },
                set(newValue) { _sendMessage = newValue },
                configurable: false,
                enumerable: true
            });

            Object.defineProperty(_sessionController, onLinkInfo.name, {
                get() { return onLinkInfoProxy },
                set(newValue) { _onLinkInfo = newValue },
                configurable: false,
                enumerable: true
            });

            Object.defineProperty(_sessionController, onLinkDestination.name, {
                get() { return onLinkDestinationProxy },
                set(newValue) { _onLinkDestination = newValue },
                configurable: false,
                enumerable: true
            });

            log(`SessionController proxies installed: ${sendMessage.name}, ${onLinkInfo.name}, ${onLinkDestination.name}`);
            ui.updateStatus("Ultra bypass system armed!", "⚡", 50);
            ui.updateDebug("All proxies installed successfully");
            return true;
        } catch (e) {
            error("Failed to install proxies:", e);
            ui.updateStatus("Proxy installation failed", "❌", 0);
            return false;
        }
    }

    // Enhanced session controller detection
    function checkForSessionController(target, prop, value, receiver) {
        if (DEBUG) log("Checking property set:", prop, typeof value);

        if (value && typeof value === "object" && !_sessionController) {
            const sendMessage = resolveName(value, NAME_MAP.sendMessage);
            const onLinkInfo = resolveName(value, NAME_MAP.onLinkInfo);
            const onLinkDestination = resolveName(value, NAME_MAP.onLinkDestination);

            if (sendMessage.fn && onLinkInfo.fn && onLinkDestination.fn) {
                _sessionController = value;
                log("Intercepted session controller:", _sessionController);
                ui.updateStatus("Target acquired! Preparing ultra bypass...", "🎯", 40);

                setTimeout(() => {
                    setupSessionControllerProxy();
                }, 50); // Reduced from 100ms to 50ms
            }
        }

        return Reflect.set(target, prop, value, receiver);
    }

    // Enhanced component proxy with better detection
    function createComponentProxy(component) {
        return new Proxy(component, {
            construct(target, args) {
                const result = Reflect.construct(target, args);
                log("Intercepted SvelteKit component construction:", target.name || "Unknown");

                if (result.$$ && result.$$.ctx) {
                    result.$$.ctx = new Proxy(result.$$.ctx, {
                        set: checkForSessionController
                    });
                }

                return result;
            }
        });
    }

    // Enhanced node result proxy
    function createNodeResultProxy(result) {
        return new Proxy(result, {
            get(target, prop, receiver) {
                if (prop === "component" && target.component) {
                    return createComponentProxy(target.component);
                }
                return Reflect.get(target, prop, receiver);
            }
        });
    }

    // Enhanced node proxy
    function createNodeProxy(oldNode) {
        return async (...args) => {
            const result = await oldNode(...args);
            log("Intercepted SvelteKit node result");
            return createNodeResultProxy(result);
        };
    }

    // Enhanced kit proxy with better error handling
    function createKitProxy(kit) {
        if (typeof kit !== "object" || !kit) return [false, kit];

        const originalStart = kit.start;
        if (typeof originalStart !== "function") return [false, kit];

        const kitProxy = new Proxy(kit, {
            get(target, prop, receiver) {
                if (prop === "start") {
                    return function(...args) {
                        try {
                            const appModule = args[0];
                            const options = args[2];

                            if (appModule?.nodes && options?.node_ids && options.node_ids[1]) {
                                const oldNode = appModule.nodes[options.node_ids[1]];
                                if (oldNode) {
                                    appModule.nodes[options.node_ids[1]] = createNodeProxy(oldNode);
                                    ui.updateStatus("SvelteKit hijacked! Ultra mode active!", "⚡", 25);
                                }
                            }

                            log("kit.start intercepted successfully");
                            return originalStart.apply(this, args);
                        } catch (e) {
                            error("Error in kit.start interception:", e);
                            ui.updateStatus("Interception error", "⚠️", 0);
                            return originalStart.apply(this, args);
                        }
                    };
                }
                return Reflect.get(target, prop, receiver);
            }
        });

        return [true, kitProxy];
    }

    // Enhanced SvelteKit interception with better timing
    function setupSvelteKitInterception() {
        const originalPromiseAll = unsafeWindow.Promise.all;
        let intercepted = false;

        unsafeWindow.Promise.all = async function(promises) {
            const result = originalPromiseAll.call(this, promises);

            if (!intercepted) {
                intercepted = true;

                return await new Promise((resolve) => {
                    result.then(([kit, app, ...args]) => {
                        log("SvelteKit modules loaded");
                        ui.updateDebug("SvelteKit modules detected");

                        const [success, wrappedKit] = createKitProxy(kit);
                        if (success) {
                            unsafeWindow.Promise.all = originalPromiseAll;
                            log("Kit proxy installed successfully");
                        } else {
                            warn("Failed to create kit proxy");
                            ui.updateStatus("Kit proxy failed", "⚠️", 0);
                        }

                        resolve([wrappedKit, app, ...args]);
                    }).catch((e) => {
                        error("Error in Promise.all interception:", e);
                        ui.updateStatus("Module loading error", "❌", 0);
                        resolve([kit, app, ...args]);
                    });
                });
            }

            return await result;
        };
    }

    // Enhanced ad removal with better detection
    function setupAdRemoval() {
        const observer = new MutationObserver((mutations) => {
            for (const m of mutations) {
                for (const node of m.addedNodes) {
                    if (node.nodeType === 1) {
                        // Enhanced ad detection patterns
                        const adSelectors = [
                            ".adsbygoogle",
                            "[data-ad-client]",
                            ".ad-container",
                            ".advertisement",
                            "[id*='google_ads']",
                            "[class*='google-ad']"
                        ];

                        // Direct match
                        for (const selector of adSelectors) {
                            if (node.matches && node.matches(selector)) {
                                node.remove();
                                log("Removed injected ad:", node);
                                ui.updateDebug("Ad blocked");
                                break;
                            }
                        }

                        // Children match
                        for (const selector of adSelectors) {
                            node.querySelectorAll?.(selector).forEach((el) => {
                                el.remove();
                                log("Removed nested ad:", el);
                                ui.updateDebug("Nested ad blocked");
                            });
                        }
                    }
                }
            }
        });

        observer.observe(document.documentElement, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['class', 'id']
        });

        log("Enhanced ad removal system initialized");
    }

    // Enhanced initialization
    function initialize() {
        log("Ultra-fast work.ink bypass initializing...");

        // Setup captcha detection
        ui.updateStatus("Solve captcha to activate turbo mode", "🔒", 5);

        // Initialize systems
        setupSvelteKitInterception();
        setupAdRemoval();

        // Monitor for captcha completion
        const captchaMonitor = setInterval(() => {
            if (_captchaSolved && !_linkReceived) {
                ui.updateStatus("Captcha solved! Turbo engaged...", "🚀", 75);
            }
        }, 1000);

        // Cleanup monitor after 5 minutes
        setTimeout(() => clearInterval(captchaMonitor), 300000);

        log("Ultra-fast bypass system initialized");
    }

    // Start the ultra-fast bypass
    initialize();

    // Ultra keyboard shortcuts for debugging
    if (DEBUG) {
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey && e.shiftKey) {
                switch(e.key) {
                    case 'D':
                        e.preventDefault();
                        ui.isVisible ? ui.hide() : ui.show();
                        break;
                    case 'R':
                        e.preventDefault();
                        location.reload();
                        break;
                    case 'L':
                        e.preventDefault();
                        console.log('Session Controller:', _sessionController);
                        break;
                    case 'F':
                        e.preventDefault();
                        _fastModeEnabled = !_fastModeEnabled;
                        ui.updateDebug(`Fast mode: ${_fastModeEnabled ? 'ON' : 'OFF'}`);
                        break;
                }
            }
        });
    }

})();
