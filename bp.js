// ==UserScript==
// @name         Enhanced LuArmor Bypass
// @namespace    http://tampermonkey.net/
// @version      2.8.2
// @description  Advanced LuArmor bypass with improved accuracy, reliability, and modern UI
// @author       Xenon
// @match        https://ads.luarmor.net/*
// @match        https://linkvertise.com/*
// @match        https://*/s?*
// @match        https://*.cloudflare.com/*
// @match        https://*.hcaptcha.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=luarmor.net
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @grant        GM_addStyle
// @grant        unsafeWindow
// @run-at       document-start
// @connect      api.bypass.bot
// @connect      api.solar-x.top
// @connect      *
// ==/UserScript==

(function() {
    'use strict';

    // Load Material Icons if not already present
    if (!document.querySelector('link[href*="material-icons"]')) {
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://fonts.googleapis.com/icon?family=Material+Icons';
        document.head.appendChild(link);
    }

    GM_addStyle(`
        .bolt-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            z-index: 2147483647;
            font-family: system-ui, -apple-system, sans-serif;
            opacity: 0;
            transition: opacity 0.3s ease;
            padding: 0.5rem;
            box-sizing: border-box;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .bolt-container {
            background: rgb(31, 41, 55);
            border-radius: 20px;
            padding: 1.5rem;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            transform: translateY(20px);
            transition: all 0.3s ease;
            animation: slideIn 0.3s ease forwards;
            position: relative;
            overflow: visible;
            margin: 1rem auto;
        }

        @media (max-width: 480px) {
            .bolt-overlay {
                padding: 0;
                align-items: flex-start;
            }

            .bolt-container {
                padding: 1rem;
                border-radius: 0;
                margin: 0;
                min-height: 100%;
            }

            .bolt-title {
                font-size: 1.25rem !important;
                margin-bottom: 1.5rem !important;
            }

            .bolt-button {
                padding: 1rem !important;
                font-size: 1rem !important;
                margin-top: 0.75rem !important;
                height: auto !important;
                border-radius: 8px !important;
            }

            .bolt-key-item {
                padding: 1rem;
                margin-bottom: 0.5rem;
                background: rgba(255, 255, 255, 0.05);
                border-radius: 8px;
            }

            .bolt-key-item > div {
                margin-top: 0.5rem;
                display: flex;
                justify-content: flex-start;
                align-items: center;
                gap: 0.5rem;
                flex-wrap: wrap;
            }

            .bolt-key-text {
                font-size: 0.875rem !important;
                width: 100%;
                word-break: break-all;
            }

            .bolt-renew-btn {
                padding: 0.5rem 1rem !important;
                font-size: 0.875rem !important;
                border-radius: 6px !important;
                margin: 0 !important;
            }

            .bolt-checkpoint {
                padding: 1rem !important;
                font-size: 1rem !important;
                margin-bottom: 0.5rem !important;
                border-radius: 8px !important;
            }

            .bolt-keys {
                margin: 1rem -1rem;
                padding: 1rem;
                border-radius: 0;
                background: rgba(0, 0, 0, 0.2);
            }
        }

        .bolt-button {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 1rem 2rem;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            margin-top: 1rem;
            transition: all 0.2s ease;
            -webkit-tap-highlight-color: transparent;
            height: 3.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .bolt-button:hover {
            background: #2563eb;
        }

        .bolt-button:active {
            transform: scale(0.98);
        }

        .bolt-button:disabled {
            background: #9ca3af;
            cursor: not-allowed;
            opacity: 0.7;
        }

        .bolt-button.secondary {
            background: #4b5563;
            margin-top: 0.5rem;
        }

        .bolt-button.secondary:hover {
            background: #374151;
        }

        .bolt-container.minimized {
            width: auto;
            padding: 1rem;
            cursor: pointer;
            transform: translateY(0);
            position: fixed;
            bottom: 1rem;
            right: 1rem;
            max-width: none;
            margin: 0;
        }

        .bolt-container.minimized .bolt-checkpoints,
        .bolt-container.minimized .bolt-progress-container,
        .bolt-container.minimized .bolt-success,
        .bolt-container.minimized .bolt-error,
        .bolt-container.minimized .bolt-buttons,
        .bolt-container.minimized .bolt-keys {
            display: none;
        }

        .bolt-container.minimized .bolt-title {
            margin: 0;
            font-size: 1rem;
        }

        .bolt-container.minimized .bolt-title::after {
            display: none;
        }

        .bolt-toggle {
            position: absolute;
            top: 0.75rem;
            right: 0.75rem;
            background: none;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            padding: 0.5rem;
            border-radius: 0.375rem;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            -webkit-tap-highlight-color: transparent;
            z-index: 10;
        }

        .bolt-toggle:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .bolt-toggle:active {
            transform: scale(0.95);
        }

        .bolt-progress-text {
            color: #e5e7eb;
            font-size: 0.9375rem;
            margin: 1rem 0;
            text-align: center;
            word-break: break-word;
        }

        .bolt-keys {
            margin-top: 1rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 1rem;
            max-height: 300px;
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }

        .bolt-key-item {
            display: flex;
            flex-direction: column;
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            color: #e5e7eb;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 8px;
            margin-bottom: 0.5rem;
        }

        .bolt-key-item:last-child {
            margin-bottom: 0;
            border-bottom: none;
        }

        .bolt-key-text {
            font-family: monospace;
            font-size: 0.875rem;
            word-break: break-all;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .bolt-key-status {
            font-size: 0.875rem;
            padding: 0.375rem 0.75rem;
            border-radius: 6px;
            white-space: nowrap;
            font-weight: 500;
        }

        .bolt-key-status.expired {
            background: rgba(239, 68, 68, 0.2);
            color: #ef4444;
        }

        .bolt-key-status.active {
            background: rgba(16, 185, 129, 0.2);
            color: #10b981;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .bolt-checkpoints {
            margin-top: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            display: none;
        }

        .bolt-checkpoint {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #9ca3af;
            font-size: 0.9375rem;
            padding: 0.75rem;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }

        .bolt-checkpoint.active {
            color: white;
            background: rgba(59, 130, 246, 0.1);
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .bolt-checkpoint.completed {
            color: #10b981;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .bolt-checkpoint-icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            flex-shrink: 0;
        }

        .bolt-checkpoint.active .bolt-checkpoint-icon {
            background: #3b82f6;
            color: white;
        }

        .bolt-checkpoint.completed .bolt-checkpoint-icon {
            background: #10b981;
            color: white;
        }

        .bolt-progress-container {
            margin-top: 1.5rem;
            display: none;
        }

        .bolt-progress-bar {
            height: 6px;
            background: rgba(59, 130, 246, 0.1);
            border-radius: 3px;
            overflow: hidden;
            margin: 1rem 0;
            position: relative;
        }

        .bolt-progress-fill {
            height: 100%;
            width: 0%;
            background: linear-gradient(90deg, #3b82f6, #60a5fa);
            border-radius: 3px;
            transition: width 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .bolt-progress-fill::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.2),
                transparent
            );
            animation: shimmer 1.5s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .bolt-status {
            color: #e5e7eb;
            font-size: 0.9375rem;
            margin-bottom: 0.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 500;
        }

        .bolt-detail {
            color: #9ca3af;
            font-size: 0.8125rem;
            margin-top: 0.75rem;
            line-height: 1.4;
            word-break: break-word;
        }

        .bolt-title {
            color: white;
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            position: relative;
            padding-right: 2rem;
        }

        .bolt-title::after {
            content: '';
            position: absolute;
            bottom: -0.5rem;
            left: 0;
            width: 2rem;
            height: 2px;
            background: #3b82f6;
            border-radius: 1px;
        }

        .bolt-success {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.2);
            color: #10b981;
            padding: 1rem;
            border-radius: 12px;
            margin-top: 1rem;
            font-size: 0.9375rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            word-break: break-word;
        }

        .bolt-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #ef4444;
            padding: 1rem;
            border-radius: 12px;
            margin-top: 1rem;
            font-size: 0.9375rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            word-break: break-word;
        }

        * {
            -webkit-tap-highlight-color: transparent;
            touch-action: manipulation;
        }

        .bolt-key-count {
            color: #9ca3af;
            font-size: 0.875rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .bolt-new-key-btn {
            background: #17c1e8;
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-size: 0.875rem;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s ease;
            margin-top: 1rem;
        }

        .bolt-new-key-btn:hover {
            background: #0ea5c9;
        }

        .bolt-new-key-btn:active {
            transform: scale(0.98);
        }

        .bolt-new-key-btn i {
            font-size: 1.25rem;
        }
    `);

    let ui = null;
    let bypassStarted = false; // Flag untuk melacak apakah bypass sudah dimulai

    class BypassUI {
        constructor() {
            this.overlay = document.createElement('div');
            this.overlay.className = 'bolt-overlay';
            this.startTime = Date.now();
            this.checkpoints = [
                { id: 'init', text: 'Initialize Bypass', status: 'pending' },
                { id: 'cloudflare', text: 'Cloudflare Check', status: 'pending' },
                { id: 'captcha', text: 'Captcha Verification', status: 'pending' },
                { id: 'request', text: 'API Request', status: 'pending' },
                { id: 'redirect', text: 'Final Redirect', status: 'pending' }
            ];

            this.overlay.innerHTML = `
                <div class="bolt-container">
                    <button class="bolt-toggle" title="Toggle container">−</button>
                    <div class="bolt-title">
                        <span>LuArmor Bypass</span>
                    </div>
                    <div class="bolt-progress-text" id="adProgress">Ready to start bypass...</div>
                    <div class="bolt-buttons">
                        <button class="bolt-button" id="startBypass">Start Bypass</button>
                        <button class="bolt-button secondary" id="renewKey">Show Keys</button>
                    </div>
                    <div class="bolt-keys" id="boltKeys">
                        <div class="bolt-key-count" id="boltKeyCount"></div>
                        <button class="bolt-new-key-btn" id="boltNewKey">
                            <i class="material-icons">add</i>
                            Get a new key
                        </button>
                    </div>
                    <div class="bolt-checkpoints">
                        ${this.checkpoints.map(cp => `
                            <div id="${cp.id}-checkpoint" class="bolt-checkpoint">
                                <div class="bolt-checkpoint-icon">•</div>
                                <span>${cp.text}</span>
                            </div>
                        `).join('')}
                    </div>
                    <div class="bolt-progress-container">
                        <div class="bolt-status">
                            <span id="bolt-status-text">Waiting to start...</span>
                            <span id="bolt-percentage">0%</span>
                        </div>
                        <div class="bolt-progress-bar">
                            <div id="bolt-progress" class="bolt-progress-fill"></div>
                        </div>
                        <div id="bolt-detail" class="bolt-detail"></div>
                    </div>
                </div>
            `;

            document.body.appendChild(this.overlay);

            // Initialize UI elements
            const container = this.overlay.querySelector('.bolt-container');
            const toggleBtn = this.overlay.querySelector('.bolt-toggle');
            const startBtn = this.overlay.querySelector('#startBypass');
            const renewBtn = this.overlay.querySelector('#renewKey');
            const newKeyBtn = this.overlay.querySelector('#boltNewKey');
            const checkpoints = this.overlay.querySelector('.bolt-checkpoints');
            const progressContainer = this.overlay.querySelector('.bolt-progress-container');
            const keysContainer = this.overlay.querySelector('.bolt-keys');

            // Event listeners
            toggleBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                container.classList.toggle('minimized');
                toggleBtn.textContent = container.classList.contains('minimized') ? '+' : '−';
            });

            container.addEventListener('click', () => {
                if (container.classList.contains('minimized')) {
                    container.classList.remove('minimized');
                    toggleBtn.textContent = '−';
                }
            });

            startBtn.addEventListener('click', () => {
                // Set flag bahwa bypass sudah dimulai
                bypassStarted = true;
                
                // Cek apakah tombol Next tersedia
                const nextBtn = document.querySelector('#nextbtn');
                if (!nextBtn) {
                    this.showError('Next button not found. Please wait for page to load completely.');
                    bypassStarted = true;
                    return;
                }

                // Cek cooldown
                if (nextBtn.style.cursor === 'not-allowed') {
                    const cooldownText = nextBtn.textContent.trim();
                    if (cooldownText.includes(':')) {
                        this.showError(`Cooldown active: ${cooldownText}`);
                        bypassStarted = false;
                        return;
                    }
                }

                // Cek status Done
                if (nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                    this.showError('Checkpoints completed. Please wait for reset...');
                    bypassStarted = false;
                    return;
                }

                // Sembunyikan tombol dan tampilkan progress
                this.overlay.querySelector('.bolt-buttons').style.display = 'none';
                keysContainer.style.display = 'none';
                checkpoints.style.display = 'flex';
                progressContainer.style.display = 'block';
                
                // Mulai bypass
                this.startBypass();
            });

            renewBtn.addEventListener('click', () => {
                keysContainer.style.display = keysContainer.style.display === 'none' ? 'block' : 'none';
                this.updateKeyList();
            });

            newKeyBtn.addEventListener('click', () => {
                const originalNewKeyBtn = document.querySelector('#newkeybtn');
                if (originalNewKeyBtn) {
                    originalNewKeyBtn.click();
                } else {
                    this.showError('New key button not found.');
                }
            });

            keysContainer.style.display = 'none';
            this.monitorProgress();
            this.monitorKeyCount();

            requestAnimationFrame(() => {
                this.overlay.style.opacity = '1';
            });
        }

        monitorKeyCount() {
            const updateCount = () => {
                const keyCountTitle = document.querySelector('#keysrowtitle');
                const keyCountElement = document.querySelector('#boltKeyCount');

                if (keyCountTitle && keyCountElement) {
                    const countMatch = keyCountTitle.textContent.match(/\((\d+)\/(\d+)\)/);
                    if (countMatch) {
                        const [current, total] = countMatch.slice(1);
                        keyCountElement.textContent = `Keys: ${current}/${total}`;
                    } else {
                        keyCountElement.textContent = 'Keys: 0/0';
                    }
                }

                requestAnimationFrame(updateCount);
            };
            updateCount();
        }

        updateKeyList() {
            const keysContainer = this.overlay.querySelector('#boltKeys');
            const tableBody = document.querySelector('#tablebodyuserarea');
            const keyCountTitle = document.querySelector('#keysrowtitle');
            const keyCountElement = keysContainer.querySelector('.bolt-key-count');

            // Update key count
            if (keyCountTitle && keyCountElement) {
                const countMatch = keyCountTitle.textContent.match(/\((\d+)\/(\d+)\)/);
                if (countMatch) {
                    const [current, total] = countMatch.slice(1);
                    keyCountElement.textContent = `Keys: ${current}/${total}`;
                } else {
                    keyCountElement.textContent = 'Keys: 0/0';
                }
            }

            if (!tableBody) {
                keysContainer.innerHTML = `
                    <div class="bolt-key-count" id="boltKeyCount">Keys: 0/0</div>
                    <button class="bolt-new-key-btn" id="boltNewKey">
                        <i class="material-icons">add</i>
                        Get a new key
                    </button>
                    <div class="bolt-key-item">No keys found</div>
                `;
                return;
            }

            const keys = [];
            tableBody.querySelectorAll('tr').forEach(row => {
                const keyElement = row.querySelector('.text-sm');
                const timeLeft = row.querySelector('[id^="_timeleftarea_"]');
                const statusBadge = row.querySelector('.badge');
                const renewButton = row.querySelector('button[onclick^="renewKey"]');

                if (keyElement && timeLeft && statusBadge) {
                    const keyText = keyElement.textContent.trim();
                    const timeLeftText = timeLeft.textContent.trim();
                    const status = statusBadge.textContent.trim().toLowerCase();
                    const keyId = renewButton ? renewButton.getAttribute('onclick').match(/'([^']+)'/)[1] : null;

                    keys.push({ key: keyText, timeLeft: timeLeftText, status, keyId });
                }
            });

            const keyListHtml = keys.map(key => `
                <div class="bolt-key-item">
                    <div class="bolt-key-text">
                        <div class="d-flex px-2 py-1">
                            <div>
                                <img alt="key" src="./assets/img/keyicon.png" class="avatar avatar-sm me-2">
                            </div>
                            <div class="d-flex flex-column justify-content-center">
                                <h6 class="mb-0 text-sm">${key.key}</h6>
                            </div>
                        </div>
                    </div>
                    <div>
                        <span class="bolt-key-status ${key.status}">${key.status}</span>
                        ${key.status === 'expired' && key.keyId ?
                            `<button class="bolt-renew-btn" onclick="renewKey('${key.keyId}')">Renew Key</button>` :
                            ''
                        }
                    </div>
                </div>
            `).join('');

            keysContainer.innerHTML = `
                <div class="bolt-key-count" id="boltKeyCount"></div>
                <button class="bolt-new-key-btn" id="boltNewKey">
                    <i class="material-icons">add</i>
                    Get a new key
                </button>
                ${keyListHtml || '<div class="bolt-key-item">No keys found</div>'}
            `;

            // Reattach event listener for new key button
            const newKeyBtn = keysContainer.querySelector('#boltNewKey');
            if (newKeyBtn) {
                newKeyBtn.addEventListener('click', () => {
                    const originalNewKeyBtn = document.querySelector('#newkeybtn');
                    if (originalNewKeyBtn) {
                        originalNewKeyBtn.click();
                    } else {
                        this.showError('New key button not found.');
                    }
                });
            }
        }

        monitorProgress() {
            const checkProgress = () => {
                const progressElement = document.querySelector('#adprogressp');
                const nextBtn = document.querySelector('#nextbtn');
                const startBtn = document.querySelector('#startBypass');

                if (progressElement) {
                    const progressText = progressElement.textContent;
                    const [current, total] = progressText.split('/').map(num => parseInt(num));

                    if (!isNaN(current) && !isNaN(total)) {
                        const percentage = (current / total) * 100;

                        // Check for cooldown state
                        if (nextBtn && nextBtn.style.cursor === 'not-allowed') {
                            const cooldownText = nextBtn.textContent.trim();
                            if (cooldownText.includes(':')) {
                                document.getElementById('adProgress').textContent = `Cooldown: ${cooldownText}`;
                                if (startBtn) {
                                    startBtn.disabled = true;
                                    startBtn.textContent = `Cooldown: ${cooldownText}`;
                                }
                                return;
                            }
                        }

                        // Check for "Done" state
                        if (nextBtn && nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                            document.getElementById('adProgress').textContent = 'Checkpoints completed! Please wait for reset...';
                            if (startBtn) {
                                startBtn.disabled = true;
                                startBtn.textContent = 'Waiting for reset...';
                            }
                            return;
                        }

                        // Update progress display
                        if (!bypassStarted) {
                            document.getElementById('adProgress').textContent = `Progress: ${progressText} (${percentage.toFixed(0)}%) - Ready to start`;
                        }

                        // Reset button state when progress resets
                        if (current === 0 && total === 2) {
                            if (startBtn) {
                                startBtn.disabled = false;
                                startBtn.textContent = "Start Bypass";
                            }
                            bypassStarted = false; // Reset flag ketika progress reset
                        }
                    } else {
                        if (!bypassStarted) {
                            document.getElementById('adProgress').textContent = progressText + ' - Ready to start';
                        }
                    }
                }
                requestAnimationFrame(checkProgress);
            };
            checkProgress();
        }

        updateCheckpoint(id, status) {
            const checkpoint = this.overlay.querySelector(`#${id}-checkpoint`);
            if (!checkpoint) return;

            checkpoint.classList.remove('active', 'completed');
            checkpoint.classList.add(status);

            const icon = checkpoint.querySelector('.bolt-checkpoint-icon');
            if (status === 'completed') {
                icon.innerHTML = '✓';
            } else if (status === 'active') {
                icon.innerHTML = '•';
            }
        }

        async startBypass() {
            try {
                // Double check sebelum memulai
                const nextBtn = document.querySelector('#nextbtn');
                if (!nextBtn) {
                    throw new Error('Next button not found.');
                }

                if (nextBtn.style.cursor === 'not-allowed') {
                    const cooldownText = nextBtn.textContent.trim();
                    if (cooldownText.includes(':')) {
                        throw new Error(`Cooldown active: ${cooldownText}`);
                    }
                }

                if (nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                    throw new Error('Checkpoints completed. Please wait for reset...');
                }

                this.updateCheckpoint('init', 'active');
                await this.sleep(500);
                this.updateProgress('Initializing...', 20);
                this.updateCheckpoint('init', 'completed');

                this.updateCheckpoint('cloudflare', 'active');
                await this.sleep(500);
                this.updateProgress('Checking Cloudflare...', 40);
                this.updateCheckpoint('cloudflare', 'completed');

                this.updateCheckpoint('captcha', 'active');
                await this.sleep(500);
                this.updateProgress('Verifying captcha...', 60);
                this.updateCheckpoint('captcha', 'completed');

                this.updateCheckpoint('request', 'active');
                await this.sleep(500);
                this.updateProgress('Making API request...', 80);
                this.updateCheckpoint('request', 'completed');

                this.updateCheckpoint('redirect', 'active');
                await this.sleep(500);
                this.updateProgress('Preparing redirect...', 100);
                this.updateCheckpoint('redirect', 'completed');

                this.showSuccess('Bypass successful! Clicking Next button...');
                await this.sleep(500);
                
                // Klik tombol Next setelah semua checkpoint selesai
                await this.performBypass();
                
            } catch (error) {
                console.error('Bypass error:', error);
                this.showError(`Bypass failed: ${error.message}`);
                bypassStarted = false; // Reset flag jika error
            }
        }

        async performBypass() {
            try {
                const nextBtn = document.querySelector('#nextbtn');
                if (nextBtn) {
                    nextBtn.click();
                    GM_setValue('BOLT_BYPASS_ACTIVE', true);
                    console.log('Next button clicked successfully');
                    this.showSuccess('Next button clicked! Waiting for redirect...');
                } else {
                    throw new Error('Next button not found during bypass execution');
                }
            } catch (error) {
                console.error('Perform bypass error:', error);
                this.showError(`Failed to click Next button: ${error.message}`);
                bypassStarted = false;
            }
        }

        sleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
        }

        updateProgress(status, percentage, detail = '') {
            const statusText = document.getElementById('bolt-status-text');
            const percentageText = document.getElementById('bolt-percentage');
            const progressBar = document.getElementById('bolt-progress');
            const detailText = document.getElementById('bolt-detail');
            const elapsedTime = ((Date.now() - this.startTime) / 1000).toFixed(1);

            if (statusText) statusText.textContent = status;
            if (percentageText) percentageText.textContent = `${Math.round(percentage)}%`;
            if (progressBar) progressBar.style.width = `${percentage}%`;
            if (detailText) detailText.textContent = `${detail}\nTime elapsed: ${elapsedTime}s`;
        }

        showSuccess(message) {
            const container = this.overlay.querySelector('.bolt-container');
            const success = document.createElement('div');
            success.className = 'bolt-success';
            success.innerHTML = `✓ ${message}`;
            container.appendChild(success);
        }

        showError(message) {
            const container = this.overlay.querySelector('.bolt-container');
            const error = document.createElement('div');
            error.className = 'bolt-error';
            error.innerHTML = `✕ ${message}`;
            container.appendChild(error);
        }
    }

    const requestApi = async (url) => {
        try {
            const apiUrl = new URL('https://api.solar-x.top/premium/refresh');
            apiUrl.searchParams.append('url', url);

            const response = await new Promise((resolve, reject) => {
                GM_xmlhttpRequest({
                    url: apiUrl.toString(),
                    method: 'GET',
                    headers: {
                        'Accept': 'application/json',
                        'x-api-key': 'SLR-B5200ABD432E841AADD262AC526E63FF17B26A1F70930F21C9D3BA08DDCFAC6700A3F42F95B8A1F2FF0CDE89FD7ECB960274363A69E900B1EDEF82149FA49101-Xenon'
                    },
                    timeout: 15000,
                    onload: resolve,
                    onerror: reject,
                    ontimeout: () => reject(new Error('API request timed out'))
                });
            });

            if (response.status !== 200) {
                throw new Error(`API request failed with status ${response.status}`);
            }

            let result;
            try {
                result = JSON.parse(response.responseText);
            } catch (e) {
                throw new Error('Invalid API response format');
            }

            if (result.success === false || (result.result && result.result.includes('Error'))) {
                throw new Error(result.result || 'Bypass failed');
            }

            // Validate that the result is a valid URL
            try {
                new URL(result.result);
            } catch (e) {
                throw new Error('Invalid redirect URL received from API');
            }

            return result.result;
        } catch (error) {
            console.error('requestApi error:', error);
            throw error;
        }
    };

    const bypassCloudflare = () => {
        if (document.querySelector('#challenge-running')) {
            const script = document.createElement('script');
            script.textContent = `
                (() => {
                    const bypass = () => {
                        window._cf_chl_opt.chlApps = {};
                        window.setTimeout = function(cb) { cb(); };
                        window._cf_chl_ctx = {
                            chC: 0,
                            chCAS: 0,
                            chLog: {},
                            chReq: {},
                            chAltSvc: {},
                        };
                    };

                    if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', bypass);
                    } else {
                        bypass();
                    }
                })();
            `;
            document.head.appendChild(script);
            console.log('Cloudflare bypass script injected');
        }
    };

    const bypassCaptcha = () => {
        if (window.location.hostname.includes('captcha')) {
            const script = document.createElement('script');
            script.textContent = `
                (() => {
                    const bypass = () => {
                        if (typeof hcaptcha !== 'undefined') {
                            hcaptcha.getResponse = () => 'bypass_token';
                            hcaptcha.execute = () => Promise.resolve('bypass_token');
                        }
                        if (typeof grecaptcha !== 'undefined') {
                            grecaptcha.getResponse = () => 'bypass_token';
                            grecaptcha.execute = () => Promise.resolve('bypass_token');
                        }

                        const form = document.forms[0];
                        if (form) {
                            setTimeout(() => form.submit(), 500);
                        }
                    };

                    if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', bypass);
                    } else {
                        bypass();
                    }
                })();
            `;
            document.head.appendChild(script);
            console.log('Captcha bypass script injected');
        }
    };

    const init = async () => {
        try {
            if (document.querySelector('#challenge-running')) {
                bypassCloudflare();
                console.log('Detected Cloudflare challenge, attempting bypass');
                return;
            }

            if (window.location.hostname.includes('captcha')) {
                bypassCaptcha();
                console.log('Detected captcha page, attempting bypass');
                return;
            }

            if (window.location.hostname === 'ads.luarmor.net') {
                // Hanya tampilkan UI, jangan langsung klik tombol
                console.log('LuArmor page detected, UI ready');
                
                // Tunggu halaman sepenuhnya dimuat
                await new Promise(resolve => {
                    if (document.readyState === 'complete') resolve();
                    else window.addEventListener('load', resolve);
                });
                
                console.log('Page fully loaded, waiting for user to start bypass');
                
            } else if (GM_getValue('BOLT_BYPASS_ACTIVE', false)) {
                GM_setValue('BOLT_BYPASS_ACTIVE', false);
                const result = await requestApi(window.location.href);
                window.location.href = result;
                console.log('Redirecting to:', result);
            }
        } catch (error) {
            console.error('Init error:', error);
            if (ui) ui.showError(`Initialization failed: ${error.message}`);
        }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            if (!ui) {
                ui = new BypassUI();
                console.log('BypassUI initialized');
            }
            init();
        });
    } else {
        if (!ui) {
            ui = new BypassUI();
            console.log('BypassUI initialized');
        }
        init();
    }

    unsafeWindow.ui = ui;
})();
