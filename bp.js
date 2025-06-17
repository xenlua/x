// ==UserScript==
// @name         Enhanced LuArmor Bypass
// @namespace    http://tampermonkey.net/
// @version      2.9
// @description  Advanced LuArmor bypass with improved accuracy, reliability, and modern UI with running timer
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
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
          opacity: 0;
          transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1);
          padding: 1rem;
          box-sizing: border-box;
          overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          backdrop-filter: blur(10px);
          background: rgba(0, 0, 0, 0.3);
      }

      .bolt-container {
          background: linear-gradient(135deg, rgb(17, 24, 39) 0%, rgb(31, 41, 55) 100%);
          border-radius: 24px;
          padding: 2rem;
          width: 100%;
          max-width: 520px;
          box-shadow:
              0 25px 50px -12px rgba(0, 0, 0, 0.5),
              0 0 0 1px rgba(255, 255, 255, 0.05),
              inset 0 1px 0 rgba(255, 255, 255, 0.1);
          transform: translateY(20px) scale(0.95);
          transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
          animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1) forwards;
          position: relative;
          overflow: visible;
          margin: 1rem auto;
          border: 1px solid rgba(255, 255, 255, 0.1);
      }

      @keyframes slideIn {
          from {
              opacity: 0;
              transform: translateY(30px) scale(0.95);
          }
          to {
              opacity: 1;
              transform: translateY(0) scale(1);
          }
      }

      @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.7; }
      }

      @keyframes shimmer {
          0% { transform: translateX(-100%); }
          100% { transform: translateX(100%); }
      }

      @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
      }

      @keyframes glow {
          0%, 100% { box-shadow: 0 0 5px rgba(59, 130, 246, 0.5); }
          50% { box-shadow: 0 0 20px rgba(59, 130, 246, 0.8), 0 0 30px rgba(59, 130, 246, 0.6); }
      }

      @media (max-width: 480px) {
          .bolt-overlay {
              padding: 0;
              align-items: flex-start;
          }

          .bolt-container {
              padding: 1.5rem;
              border-radius: 0;
              margin: 0;
              min-height: 100vh;
              max-width: none;
          }

          .bolt-title {
              font-size: 1.5rem !important;
              margin-bottom: 2rem !important;
          }

          .bolt-button {
              padding: 1rem !important;
              font-size: 1rem !important;
              margin-top: 1rem !important;
              height: auto !important;
              border-radius: 12px !important;
          }

          .bolt-key-item {
              padding: 1.5rem;
              margin-bottom: 1rem;
              background: rgba(255, 255, 255, 0.08);
              border-radius: 16px;
          }

          .bolt-key-text {
              font-size: 0.875rem !important;
              margin-bottom: 1rem;
          }

          .bolt-key-actions {
              flex-direction: column;
              gap: 0.75rem;
          }

          .bolt-copy-btn, .bolt-renew-btn {
              width: 100%;
              justify-content: center;
          }
      }

      .bolt-button {
          background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
          color: white;
          border: none;
          padding: 1rem 2rem;
          border-radius: 16px;
          font-size: 1rem;
          font-weight: 600;
          cursor: pointer;
          width: 100%;
          margin-top: 1rem;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          -webkit-tap-highlight-color: transparent;
          height: 3.5rem;
          display: flex;
          align-items: center;
          justify-content: center;
          position: relative;
          overflow: hidden;
          box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
      }

      .bolt-button::before {
          content: '';
          position: absolute;
          top: 0;
          left: -100%;
          width: 100%;
          height: 100%;
          background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
          transition: left 0.5s;
      }

      .bolt-button:hover::before {
          left: 100%;
      }

      .bolt-button:hover {
          background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(59, 130, 246, 0.4);
      }

      .bolt-button:active {
          transform: translateY(0) scale(0.98);
      }

      .bolt-button:disabled {
          background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
          cursor: not-allowed;
          opacity: 0.7;
          transform: none;
          box-shadow: none;
      }

      .bolt-button.secondary {
          background: linear-gradient(135deg, #4b5563 0%, #374151 100%);
          margin-top: 0.75rem;
          box-shadow: 0 4px 15px rgba(75, 85, 99, 0.3);
      }

      .bolt-button.secondary:hover {
          background: linear-gradient(135deg, #374151 0%, #1f2937 100%);
          box-shadow: 0 8px 25px rgba(75, 85, 99, 0.4);
      }

      .bolt-container.minimized {
          width: auto;
          padding: 1.5rem;
          cursor: pointer;
          transform: translateY(0);
          position: fixed;
          bottom: 2rem;
          right: 2rem;
          max-width: 300px;
          margin: 0;
          backdrop-filter: blur(20px);
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
          font-size: 1.125rem;
      }

      .bolt-container.minimized .bolt-title::after {
          display: none;
      }

      .bolt-toggle {
          position: absolute;
          top: 1rem;
          right: 1rem;
          background: rgba(255, 255, 255, 0.1);
          border: none;
          color: #e5e7eb;
          cursor: pointer;
          padding: 0.75rem;
          border-radius: 12px;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          display: flex;
          align-items: center;
          justify-content: center;
          width: 40px;
          height: 40px;
          -webkit-tap-highlight-color: transparent;
          z-index: 10;
          backdrop-filter: blur(10px);
          border: 1px solid rgba(255, 255, 255, 0.1);
      }

      .bolt-toggle:hover {
          background: rgba(255, 255, 255, 0.2);
          color: white;
          transform: scale(1.05);
      }

      .bolt-toggle:active {
          transform: scale(0.95);
      }

      .bolt-progress-text {
          color: #f3f4f6;
          font-size: 1rem;
          margin: 1.5rem 0;
          text-align: center;
          word-break: break-word;
          font-weight: 500;
      }

      .bolt-timer-display {
          background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(29, 78, 216, 0.15) 100%);
          border: 1px solid rgba(59, 130, 246, 0.3);
          color: #93c5fd;
          padding: 1rem 1.5rem;
          border-radius: 16px;
          margin: 1rem 0;
          font-size: 1.1rem;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 0.75rem;
          font-weight: 600;
          font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
          animation: glow 2s infinite;
      }

      .bolt-timer-icon {
          font-size: 1.2rem;
          animation: pulse 2s infinite;
      }

      .bolt-keys {
          margin-top: 1.5rem;
          background: rgba(0, 0, 0, 0.2);
          border-radius: 20px;
          padding: 1.5rem;
          max-height: 400px;
          overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          border: 1px solid rgba(255, 255, 255, 0.1);
          backdrop-filter: blur(10px);
      }

      .bolt-keys::-webkit-scrollbar {
          width: 6px;
      }

      .bolt-keys::-webkit-scrollbar-track {
          background: rgba(255, 255, 255, 0.1);
          border-radius: 3px;
      }

      .bolt-keys::-webkit-scrollbar-thumb {
          background: rgba(255, 255, 255, 0.3);
          border-radius: 3px;
      }

      .bolt-keys::-webkit-scrollbar-thumb:hover {
          background: rgba(255, 255, 255, 0.5);
      }

      .bolt-key-item {
          display: flex;
          flex-direction: column;
          padding: 1.5rem;
          border: 1px solid rgba(255, 255, 255, 0.1);
          color: #f3f4f6;
          background: linear-gradient(135deg, rgba(255, 255, 255, 0.05) 0%, rgba(255, 255, 255, 0.02) 100%);
          border-radius: 16px;
          margin-bottom: 1rem;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          position: relative;
          overflow: hidden;
      }

      .bolt-key-item::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 2px;
          background: linear-gradient(90deg, #3b82f6, #8b5cf6, #06b6d4);
          opacity: 0;
          transition: opacity 0.3s ease;
      }

      .bolt-key-item:hover {
          background: linear-gradient(135deg, rgba(255, 255, 255, 0.08) 0%, rgba(255, 255, 255, 0.04) 100%);
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
      }

      .bolt-key-item:hover::before {
          opacity: 1;
      }

      .bolt-key-item:last-child {
          margin-bottom: 0;
      }

      .bolt-key-header {
          display: flex;
          align-items: center;
          gap: 1rem;
          margin-bottom: 1rem;
      }

      .bolt-key-icon {
          width: 40px;
          height: 40px;
          background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 1.25rem;
          flex-shrink: 0;
      }

      .bolt-key-info {
          flex: 1;
          min-width: 0;
      }

      .bolt-key-text {
          font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
          font-size: 0.875rem;
          word-break: break-all;
          margin-bottom: 0.5rem;
          padding: 0.75rem;
          background: rgba(0, 0, 0, 0.3);
          border-radius: 8px;
          border: 1px solid rgba(255, 255, 255, 0.1);
          color: #e5e7eb;
          position: relative;
      }

      .bolt-key-meta {
          display: flex;
          align-items: center;
          gap: 0.75rem;
          font-size: 0.875rem;
          color: #9ca3af;
      }

      .bolt-key-status {
          font-size: 0.75rem;
          padding: 0.375rem 0.75rem;
          border-radius: 20px;
          white-space: nowrap;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.05em;
      }

      .bolt-key-status.expired {
          background: linear-gradient(135deg, rgba(239, 68, 68, 0.2) 0%, rgba(220, 38, 38, 0.2) 100%);
          color: #fca5a5;
          border: 1px solid rgba(239, 68, 68, 0.3);
      }

      .bolt-key-status.active {
          background: linear-gradient(135deg, rgba(16, 185, 129, 0.2) 0%, rgba(5, 150, 105, 0.2) 100%);
          color: #6ee7b7;
          border: 1px solid rgba(16, 185, 129, 0.3);
      }

      .bolt-key-actions {
          display: flex;
          gap: 0.75rem;
          margin-top: 1rem;
          align-items: center;
      }

      .bolt-copy-btn, .bolt-renew-btn {
          padding: 0.75rem 1.5rem;
          border: none;
          border-radius: 12px;
          font-size: 0.875rem;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          display: flex;
          align-items: center;
          gap: 0.5rem;
          -webkit-tap-highlight-color: transparent;
          position: relative;
          overflow: hidden;
      }

      .bolt-copy-btn {
          background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
          color: white;
          flex: 1;
          justify-content: center;
          box-shadow: 0 4px 15px rgba(6, 182, 212, 0.3);
      }

      .bolt-copy-btn:hover {
          background: linear-gradient(135deg, #0891b2 0%, #0e7490 100%);
          transform: translateY(-1px);
          box-shadow: 0 6px 20px rgba(6, 182, 212, 0.4);
      }

      .bolt-copy-btn.copied {
          background: linear-gradient(135deg, #10b981 0%, #059669 100%);
          box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
      }

      .bolt-renew-btn {
          background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
          color: white;
          box-shadow: 0 4px 15px rgba(245, 158, 11, 0.3);
      }

      .bolt-renew-btn:hover {
          background: linear-gradient(135deg, #d97706 0%, #b45309 100%);
          transform: translateY(-1px);
          box-shadow: 0 6px 20px rgba(245, 158, 11, 0.4);
      }

      .bolt-copy-btn:active, .bolt-renew-btn:active {
          transform: scale(0.95);
      }

      .bolt-checkpoints {
          margin-top: 2rem;
          display: flex;
          flex-direction: column;
          gap: 1rem;
          display: none;
      }

      .bolt-checkpoint {
          display: flex;
          align-items: center;
          gap: 1rem;
          color: #9ca3af;
          font-size: 1rem;
          padding: 1rem;
          border-radius: 16px;
          background: rgba(255, 255, 255, 0.03);
          transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
          border: 1px solid rgba(255, 255, 255, 0.05);
      }

      .bolt-checkpoint.active {
          color: white;
          background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(29, 78, 216, 0.15) 100%);
          border: 1px solid rgba(59, 130, 246, 0.3);
          transform: scale(1.02);
      }

      .bolt-checkpoint.completed {
          color: #6ee7b7;
          background: linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(5, 150, 105, 0.15) 100%);
          border: 1px solid rgba(16, 185, 129, 0.3);
      }

      .bolt-checkpoint-icon {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 16px;
          flex-shrink: 0;
          background: rgba(255, 255, 255, 0.1);
          transition: all 0.3s ease;
      }

      .bolt-checkpoint.active .bolt-checkpoint-icon {
          background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
          color: white;
          animation: pulse 2s infinite;
      }

      .bolt-checkpoint.completed .bolt-checkpoint-icon {
          background: linear-gradient(135deg, #10b981 0%, #059669 100%);
          color: white;
      }

      .bolt-progress-container {
          margin-top: 2rem;
          display: none;
      }

      .bolt-progress-bar {
          height: 8px;
          background: rgba(59, 130, 246, 0.1);
          border-radius: 4px;
          overflow: hidden;
          margin: 1.5rem 0;
          position: relative;
          border: 1px solid rgba(59, 130, 246, 0.2);
      }

      .bolt-progress-fill {
          height: 100%;
          width: 0%;
          background: linear-gradient(90deg, #3b82f6, #60a5fa, #3b82f6);
          background-size: 200% 100%;
          border-radius: 4px;
          transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
          position: relative;
          overflow: hidden;
          animation: shimmer 2s infinite;
      }

      .bolt-status {
          color: #f3f4f6;
          font-size: 1rem;
          margin-bottom: 0.75rem;
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-weight: 600;
      }

      .bolt-detail {
          color: #9ca3af;
          font-size: 0.875rem;
          margin-top: 1rem;
          line-height: 1.5;
          word-break: break-word;
      }

      .bolt-title {
          color: white;
          font-size: 1.75rem;
          font-weight: 700;
          margin-bottom: 1.5rem;
          display: flex;
          align-items: center;
          gap: 1rem;
          position: relative;
          padding-right: 3rem;
          background: linear-gradient(135deg, #ffffff 0%, #e5e7eb 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
      }

      .bolt-title::after {
          content: '';
          position: absolute;
          bottom: -0.75rem;
          left: 0;
          width: 3rem;
          height: 3px;
          background: linear-gradient(90deg, #3b82f6, #8b5cf6);
          border-radius: 2px;
      }

      .bolt-success {
          background: linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(5, 150, 105, 0.15) 100%);
          border: 1px solid rgba(16, 185, 129, 0.3);
          color: #6ee7b7;
          padding: 1.5rem;
          border-radius: 16px;
          margin-top: 1.5rem;
          font-size: 1rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          word-break: break-word;
          font-weight: 500;
      }

      .bolt-error {
          background: linear-gradient(135deg, rgba(239, 68, 68, 0.15) 0%, rgba(220, 38, 38, 0.15) 100%);
          border: 1px solid rgba(239, 68, 68, 0.3);
          color: #fca5a5;
          padding: 1.5rem;
          border-radius: 16px;
          margin-top: 1.5rem;
          font-size: 1rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          word-break: break-word;
          font-weight: 500;
      }

      * {
          -webkit-tap-highlight-color: transparent;
          touch-action: manipulation;
      }

      .bolt-key-count {
          color: #e5e7eb;
          font-size: 1rem;
          margin-bottom: 1.5rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          font-weight: 600;
          padding: 1rem;
          background: rgba(255, 255, 255, 0.05);
          border-radius: 12px;
          border: 1px solid rgba(255, 255, 255, 0.1);
      }

      .bolt-new-key-btn {
          background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
          color: white;
          border: none;
          padding: 1rem 2rem;
          border-radius: 16px;
          font-size: 1rem;
          font-weight: 600;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          margin-bottom: 1.5rem;
          width: 100%;
          justify-content: center;
          box-shadow: 0 4px 15px rgba(6, 182, 212, 0.3);
      }

      .bolt-new-key-btn:hover {
          background: linear-gradient(135deg, #0891b2 0%, #0e7490 100%);
          transform: translateY(-2px);
          box-shadow: 0 8px 25px rgba(6, 182, 212, 0.4);
      }

      .bolt-new-key-btn:active {
          transform: translateY(0) scale(0.98);
      }

      .bolt-loading {
          display: inline-block;
          width: 16px;
          height: 16px;
          border: 2px solid rgba(255, 255, 255, 0.3);
          border-radius: 50%;
          border-top-color: #ffffff;
          animation: spin 1s ease-in-out infinite;
      }

      .bolt-redirect-status {
          background: linear-gradient(135deg, rgba(59, 130, 246, 0.15) 0%, rgba(29, 78, 216, 0.15) 100%);
          border: 1px solid rgba(59, 130, 246, 0.3);
          color: #93c5fd;
          padding: 1.5rem;
          border-radius: 16px;
          margin-top: 1.5rem;
          font-size: 1rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          word-break: break-word;
          font-weight: 500;
      }

      .bolt-processing-status {
          background: linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(217, 119, 6, 0.15) 100%);
          border: 1px solid rgba(245, 158, 11, 0.3);
          color: #fbbf24;
          padding: 1.5rem;
          border-radius: 16px;
          margin-top: 1.5rem;
          font-size: 1rem;
          display: flex;
          align-items: center;
          gap: 0.75rem;
          word-break: break-word;
          font-weight: 500;
      }
  `);

  let ui = null;

  class BypassUI {
      constructor() {
          this.overlay = document.createElement('div');
          this.overlay.className = 'bolt-overlay';
          this.startTime = Date.now();
          this.redirectStartTime = null;
          this.isWaitingForRedirect = false;
          this.isProcessing = false;
          this.processingStartTime = null;
          this.timerInterval = null;
          this.checkpoints = [
              { id: 'init', text: 'Initialize Bypass', status: 'pending' },
              { id: 'cloudflare', text: 'Cloudflare Check', status: 'pending' },
              { id: 'captcha', text: 'Captcha Verification', status: 'pending' },
              { id: 'request', text: 'API Request', status: 'pending' },
              { id: 'redirect', text: 'Waiting for Redirect', status: 'pending' }
          ];

          this.overlay.innerHTML = `
              <div class="bolt-container">
                  <button class="bolt-toggle" title="Toggle container">−</button>
                  <div class="bolt-title">
                      <span>🚀 LuArmor Bypass</span>
                  </div>
                  <div class="bolt-progress-text" id="adProgress">Ready to start bypass process...</div>
                  <div class="bolt-timer-display" id="timerDisplay" style="display: none;">
                      <span class="bolt-timer-icon">⏱️</span>
                      <span id="timerText">00:00</span>
                  </div>
                  <div class="bolt-buttons">
                      <button class="bolt-button" id="startBypass">
                          <span>Start Bypass</span>
                      </button>
                      <button class="bolt-button secondary" id="renewKey">
                          <span>🔑 Manage Keys</span>
                      </button>
                  </div>
                  <div class="bolt-keys" id="boltKeys">
                      <div class="bolt-key-count" id="boltKeyCount">
                          <span>🔑</span>
                          <span>Loading keys...</span>
                      </div>
                      <button class="bolt-new-key-btn" id="boltNewKey">
                          <span>➕</span>
                          <span>Get New Key</span>
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
                          <span id="bolt-status-text">Initializing...</span>
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
              const nextBtn = document.querySelector('#nextbtn');
              if (nextBtn) {
                  if (nextBtn.style.cursor === 'not-allowed') {
                      const cooldownText = nextBtn.textContent.trim();
                      if (cooldownText.includes(':')) {
                          this.showError(`⏱️ Cooldown active: ${cooldownText}`);
                          return;
                      }
                  }

                  if (nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                      this.showError('✅ Checkpoints completed. Please wait for reset...');
                      return;
                  }
              }

              this.overlay.querySelector('.bolt-buttons').style.display = 'none';
              keysContainer.style.display = 'none';
              checkpoints.style.display = 'flex';
              progressContainer.style.display = 'block';
              this.startTimer();
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
              }
          });

          keysContainer.style.display = 'none';
          this.monitorProgress();
          this.monitorKeyCount();

          requestAnimationFrame(() => {
              this.overlay.style.opacity = '1';
          });
      }

      startTimer() {
          const timerDisplay = this.overlay.querySelector('#timerDisplay');
          const timerText = this.overlay.querySelector('#timerText');
          
          if (timerDisplay) {
              timerDisplay.style.display = 'flex';
          }

          this.timerInterval = setInterval(() => {
              let elapsedTime;
              if (this.isProcessing && this.processingStartTime) {
                  elapsedTime = Math.floor((Date.now() - this.processingStartTime) / 1000);
              } else if (this.isWaitingForRedirect && this.redirectStartTime) {
                  elapsedTime = Math.floor((Date.now() - this.redirectStartTime) / 1000);
              } else {
                  elapsedTime = Math.floor((Date.now() - this.startTime) / 1000);
              }

              const minutes = Math.floor(elapsedTime / 60);
              const seconds = elapsedTime % 60;
              const timeString = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
              
              if (timerText) {
                  timerText.textContent = timeString;
              }
          }, 1000);
      }

      stopTimer() {
          if (this.timerInterval) {
              clearInterval(this.timerInterval);
              this.timerInterval = null;
          }
      }

      async copyToClipboard(text) {
          try {
              if (navigator.clipboard && window.isSecureContext) {
                  await navigator.clipboard.writeText(text);
              } else {
                  // Fallback for older browsers
                  const textArea = document.createElement('textarea');
                  textArea.value = text;
                  textArea.style.position = 'fixed';
                  textArea.style.left = '-999999px';
                  textArea.style.top = '-999999px';
                  document.body.appendChild(textArea);
                  textArea.focus();
                  textArea.select();
                  document.execCommand('copy');
                  textArea.remove();
              }
              return true;
          } catch (err) {
              console.error('Failed to copy text: ', err);
              return false;
          }
      }

      monitorKeyCount() {
          const updateCount = () => {
              const keyCountTitle = document.querySelector('#keysrowtitle');
              const keyCountElement = document.querySelector('#boltKeyCount');

              if (keyCountTitle && keyCountElement) {
                  const countMatch = keyCountTitle.textContent.match(/\((\d+)\/(\d+)\)/);
                  if (countMatch) {
                      const [current, total] = countMatch.slice(1);
                      keyCountElement.innerHTML = `
                          <span>🔑</span>
                          <span>Keys: ${current}/${total}</span>
                      `;
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
                  keyCountElement.innerHTML = `
                      <span>🔑</span>
                      <span>Keys: ${current}/${total}</span>
                  `;
              }
          }

          if (!tableBody) {
              keysContainer.innerHTML = `
                  <div class="bolt-key-count" id="boltKeyCount">
                      <span>🔑</span>
                      <span>Keys: 0/0</span>
                  </div>
                  <button class="bolt-new-key-btn" id="boltNewKey">
                      <span>➕</span>
                      <span>Get New Key</span>
                  </button>
                  <div class="bolt-key-item">
                      <div class="bolt-key-header">
                          <div class="bolt-key-icon">❌</div>
                          <div class="bolt-key-info">
                              <div style="color: #9ca3af; font-size: 1rem;">No keys found</div>
                          </div>
                      </div>
                  </div>
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

          const keyListHtml = keys.map((key, index) => `
              <div class="bolt-key-item">
                  <div class="bolt-key-header">
                      <div class="bolt-key-icon">${key.status === 'active' ? '🔑' : '🔒'}</div>
                      <div class="bolt-key-info">
                          <div class="bolt-key-meta">
                              <span class="bolt-key-status ${key.status}">${key.status}</span>
                              <span>⏱️ ${key.timeLeft}</span>
                          </div>
                      </div>
                  </div>
                  <div class="bolt-key-text">${key.key}</div>
                  <div class="bolt-key-actions">
                      <button class="bolt-copy-btn" data-key="${key.key}" data-index="${index}">
                          <span>📋</span>
                          <span>Copy Key</span>
                      </button>
                      ${key.status === 'expired' && key.keyId ?
                          `<button class="bolt-renew-btn" onclick="renewKey('${key.keyId}')">
                              <span>🔄</span>
                              <span>Renew</span>
                          </button>` :
                          ''
                      }
                  </div>
              </div>
          `).join('');

          keysContainer.innerHTML = `
              <div class="bolt-key-count" id="boltKeyCount">
                  <span>🔑</span>
                  <span>Loading...</span>
              </div>
              <button class="bolt-new-key-btn" id="boltNewKey">
                  <span>➕</span>
                  <span>Get New Key</span>
              </button>
              ${keyListHtml || `
                  <div class="bolt-key-item">
                      <div class="bolt-key-header">
                          <div class="bolt-key-icon">❌</div>
                          <div class="bolt-key-info">
                              <div style="color: #9ca3af; font-size: 1rem;">No keys found</div>
                          </div>
                      </div>
                  </div>
              `}
          `;

          // Reattach event listeners
          const newKeyBtn = keysContainer.querySelector('#boltNewKey');
          if (newKeyBtn) {
              newKeyBtn.addEventListener('click', () => {
                  const originalNewKeyBtn = document.querySelector('#newkeybtn');
                  if (originalNewKeyBtn) {
                      originalNewKeyBtn.click();
                  }
              });
          }

          // Add copy functionality to all copy buttons
          keysContainer.querySelectorAll('.bolt-copy-btn').forEach(btn => {
              btn.addEventListener('click', async (e) => {
                  const keyText = btn.getAttribute('data-key');
                  const index = btn.getAttribute('data-index');
                  const success = await this.copyToClipboard(keyText);

                  if (success) {
                      const originalContent = btn.innerHTML;
                      btn.classList.add('copied');
                      btn.innerHTML = `
                          <span>✅</span>
                          <span>Copied!</span>
                      `;

                      setTimeout(() => {
                          btn.classList.remove('copied');
                          btn.innerHTML = originalContent;
                      }, 2000);
                  } else {
                      const originalContent = btn.innerHTML;
                      btn.innerHTML = `
                          <span>❌</span>
                          <span>Failed</span>
                      `;

                      setTimeout(() => {
                          btn.innerHTML = originalContent;
                      }, 2000);
                  }
              });
          });
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
                              document.getElementById('adProgress').innerHTML = `⏱️ Cooldown: <strong>${cooldownText}</strong>`;
                              if (startBtn) {
                                  startBtn.disabled = true;
                                  startBtn.innerHTML = `
                                      <span class="bolt-loading"></span>
                                      <span>Cooldown: ${cooldownText}</span>
                                  `;
                              }
                              return;
                          }
                      }

                      // Check for "Done" state
                      if (nextBtn && nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                          document.getElementById('adProgress').innerHTML = '✅ Checkpoints completed! <strong>Please wait for reset...</strong>';
                          if (startBtn) {
                              startBtn.disabled = true;
                              startBtn.innerHTML = `
                                  <span>⏳</span>
                                  <span>Waiting for reset...</span>
                              `;
                          }
                          return;
                      }

                      // Update progress display
                      document.getElementById('adProgress').innerHTML = `📊 Progress: <strong>${progressText}</strong> (${percentage.toFixed(0)}%)`;

                      // Reset button state when progress resets
                      if (current === 0 && total === 2) {
                          if (startBtn) {
                              startBtn.disabled = false;
                              startBtn.innerHTML = '<span>🚀 Start Bypass</span>';
                          }
                      }
                  } else {
                      document.getElementById('adProgress').innerHTML = `📊 ${progressText}`;
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
              icon.innerHTML = '✅';
          } else if (status === 'active') {
              icon.innerHTML = '⚡';
          }
      }

      async startBypass() {
          try {
              // Check for "Done" state or cooldown before starting
              const nextBtn = document.querySelector('#nextbtn');
              if (nextBtn) {
                  if (nextBtn.style.cursor === 'not-allowed') {
                      const cooldownText = nextBtn.textContent.trim();
                      if (cooldownText.includes(':')) {
                          throw new Error(`Cooldown active: ${cooldownText}`);
                      }
                  }

                  if (nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                      throw new Error('Checkpoints completed. Please wait for reset...');
                  }
              }

              this.updateCheckpoint('init', 'active');
              await this.sleep(800);
              this.updateProgress('🔧 Initializing bypass system...', 20);
              this.updateCheckpoint('init', 'completed');

              this.updateCheckpoint('cloudflare', 'active');
              await this.sleep(1000);
              this.updateProgress('☁️ Bypassing Cloudflare protection...', 40);
              this.updateCheckpoint('cloudflare', 'completed');

              this.updateCheckpoint('captcha', 'active');
              await this.sleep(800);
              this.updateProgress('🤖 Solving captcha verification...', 60);
              this.updateCheckpoint('captcha', 'completed');

              this.updateCheckpoint('request', 'active');
              await this.sleep(1200);
              this.updateProgress('🌐 Processing API request...', 80);
              this.updateCheckpoint('request', 'completed');

              this.updateCheckpoint('redirect', 'active');
              this.updateProgress('🔄 Preparing redirect...', 90);

              // Start redirect monitoring
              this.isWaitingForRedirect = true;
              this.redirectStartTime = Date.now();
              this.showRedirectStatus('⏳ Waiting for redirect link...');

              await this.sleep(500);
              init();
          } catch (error) {
              this.showError(`❌ Bypass failed: ${error.message}`);
              this.stopTimer();
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

          if (statusText) statusText.innerHTML = status;
          if (percentageText) percentageText.textContent = `${Math.round(percentage)}%`;
          if (progressBar) progressBar.style.width = `${percentage}%`;
          if (detailText && detail) {
              detailText.innerHTML = detail;
          }
      }

      showSuccess(message) {
          const container = this.overlay.querySelector('.bolt-container');
          const success = document.createElement('div');
          success.className = 'bolt-success';
          success.innerHTML = `✅ ${message}`;
          container.appendChild(success);

          // Complete the redirect checkpoint
          this.updateCheckpoint('redirect', 'completed');
          this.updateProgress('✅ Redirect successful!', 100);
          this.isWaitingForRedirect = false;
          this.stopTimer();
      }

      showError(message) {
          const container = this.overlay.querySelector('.bolt-container');
          const error = document.createElement('div');
          error.className = 'bolt-error';
          error.innerHTML = `❌ ${message}`;
          container.appendChild(error);
          this.isWaitingForRedirect = false;
          this.isProcessing = false;
          this.stopTimer();
      }

      showRedirectStatus(message) {
          const container = this.overlay.querySelector('.bolt-container');
          let redirectStatus = container.querySelector('.bolt-redirect-status');

          if (!redirectStatus) {
              redirectStatus = document.createElement('div');
              redirectStatus.className = 'bolt-redirect-status';
              container.appendChild(redirectStatus);
          }

          redirectStatus.innerHTML = `
              <span class="bolt-loading"></span>
              <span>${message}</span>
          `;
      }

      showProcessingStatus(message) {
          const container = this.overlay.querySelector('.bolt-container');
          let processingStatus = container.querySelector('.bolt-processing-status');

          if (!processingStatus) {
              processingStatus = document.createElement('div');
              processingStatus.className = 'bolt-processing-status';
              container.appendChild(processingStatus);
          }

          processingStatus.innerHTML = `
              <span class="bolt-loading"></span>
              <span>${message}</span>
          `;
      }
  }

  const requestApi = async (url) => {
      try {
          const apiUrl = new URL('https://api.solar-x.top/premium/refresh');
          apiUrl.searchParams.append('url', url);

          // Show processing status
          if (ui) {
              ui.isProcessing = true;
              ui.processingStartTime = Date.now();
              ui.showProcessingStatus('🔄 Processing bypass request, this may take a while...');
          }

          const response = await new Promise((resolve, reject) => {
              GM_xmlhttpRequest({
                  url: apiUrl.toString(),
                  method: 'GET',
                  headers: {
                      'Accept': 'application/json',
                      'x-api-key': 'SLR-B5200ABD432E841AADD262AC526E63FF17B26A1F70930F21C9D3BA08DDCFAC6700A3F42F95B8A1F2FF0CDE89FD7ECB960274363A69E900B1EDEF82149FA49101-Xenon'
                  },
                  timeout: 120000, // Increased to 2 minutes
                  onload: resolve,
                  onerror: reject,
                  ontimeout: () => {
                      console.log('API request timed out, but continuing...');
                      // Don't reject on timeout, let it continue
                      resolve({ status: 408, responseText: '{"processing": true}' });
                  }
              });
          });

          // Handle timeout gracefully
          if (response.status === 408) {
              if (ui) {
                  ui.showProcessingStatus('⏳ Request is still processing, please wait...');
              }
              // Wait a bit more and try to continue
              await new Promise(resolve => setTimeout(resolve, 5000));
              return null; // Return null to indicate we should retry or wait
          }

          if (response.status === 202) {
              if (ui) {
                  ui.showProcessingStatus('⚙️ API is processing your request, please be patient...');
              }
              // Wait and retry for 202 status
              await new Promise(resolve => setTimeout(resolve, 3000));
              return await requestApi(url); // Retry
          }

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

          // Clear processing status
          if (ui) {
              ui.isProcessing = false;
              const processingStatus = ui.overlay.querySelector('.bolt-processing-status');
              if (processingStatus) {
                  processingStatus.remove();
              }
          }

          return result.result;
      } catch (error) {
          console.error('requestApi error:', error);
          
          // Clear processing status
          if (ui) {
              ui.isProcessing = false;
              const processingStatus = ui.overlay.querySelector('.bolt-processing-status');
              if (processingStatus) {
                  processingStatus.remove();
              }
          }
          
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
      }
  };

  const init = async () => {
      try {
          if (document.querySelector('#challenge-running')) {
              bypassCloudflare();
              return;
          }

          if (window.location.hostname.includes('captcha')) {
              bypassCaptcha();
              return;
          }

          if (window.location.hostname === 'ads.luarmor.net') {
              try {
                  await new Promise(resolve => {
                      if (document.readyState === 'complete') resolve();
                      else window.addEventListener('load', resolve);
                  });

                  const nextBtn = document.querySelector('#nextbtn');
                  const newKeyBtn = document.querySelector('#newkeybtn');

                  // Check for cooldown state
                  if (nextBtn && nextBtn.style.cursor === 'not-allowed') {
                      const cooldownText = nextBtn.textContent.trim();
                      if (cooldownText.includes(':')) {
                          console.log('Cooldown active:', cooldownText);
                          return;
                      }
                  }

                  // Check for "Done" state
                  if (nextBtn && nextBtn.innerHTML.includes('done') && nextBtn.innerHTML.includes('Done')) {
                      console.log('Checkpoint completed, waiting for reset...');
                      return;
                  }

                  if (nextBtn) {
                      nextBtn.click();
                      GM_setValue('BOLT_BYPASS_ACTIVE', true);
                  } else if (newKeyBtn) {
                      newKeyBtn.click();
                  }
              } catch (error) {
                  console.error('LuArmor interaction error:', error);
              }
          } else if (GM_getValue('BOLT_BYPASS_ACTIVE', false)) {
              GM_setValue('BOLT_BYPASS_ACTIVE', false);

              // Show that we're getting the redirect link
              if (ui) {
                  ui.showRedirectStatus('🔗 Getting redirect link...');
              }

              const result = await requestApi(window.location.href);

              if (result) {
                  // Show success and redirect
                  if (ui) {
                      ui.showSuccess('🎉 Bypass successful! Redirecting...');
                  }

                  // Small delay to show success message
                  await new Promise(resolve => setTimeout(resolve, 1000));
                  window.location.href = result;
              } else {
                  // Handle case where API is still processing
                  if (ui) {
                      ui.showProcessingStatus('⏳ Still processing, please wait a moment...');
                  }
                  
                  // Retry after a delay
                  setTimeout(() => {
                      init();
                  }, 5000);
              }
          }
      } catch (error) {
          console.error('Bypass error:', error);
          if (ui && !error.message.includes('timeout')) {
              ui.showError(`Bypass failed: ${error.message}`);
          }
      }
  };

  if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
          if (!ui) ui = new BypassUI();
      });
  } else if (!ui) {
      ui = new BypassUI();
  }

  unsafeWindow.ui = ui;
})();
