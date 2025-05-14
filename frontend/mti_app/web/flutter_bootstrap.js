// Bootstrap script for Flutter web debugging
(function() {
  // Debug connection variables
  let debugSocketStatus = 'none';
  let wsCheckIntervalId = null;
  
  // Check if main.dart.js is loaded
  const checkMainDartLoaded = function() {
    return window.dart_library !== undefined;
  };
  
  // We'll use this to notify the parent if we detect connection issues
  const notifyConnectionStatus = function(status) {
    if (debugSocketStatus !== status) {
      debugSocketStatus = status;
      console.log('[Flutter Bootstrap] Debug connection status: ' + status);
      
      if (status === 'disconnected' && window.parent && window.parent.postMessage) {
        // Try to notify parent about broken connection
        try {
          window.parent.postMessage({
            type: 'flutter-connection-lost',
            timestamp: Date.now()
          }, '*');
        } catch (e) {
          console.error('[Flutter Bootstrap] Error posting message to parent', e);
        }
      }
    }
  };
  
  // Start monitoring debug connection status
  const startDebugMonitoring = function() {
    if (wsCheckIntervalId) {
      clearInterval(wsCheckIntervalId);
    }
    
    wsCheckIntervalId = setInterval(function() {
      // If dart library is loaded, check websocket status
      if (checkMainDartLoaded()) {
        // Find active WebSocket connections
        const hasActiveConnection = Array.from(document.querySelectorAll('iframe'))
          .some(iframe => {
            try {
              // Check if the iframe contains DWDS debug tools
              return iframe.contentWindow && 
                    iframe.contentWindow.document && 
                    iframe.contentWindow.document.title && 
                    iframe.contentWindow.document.title.includes('Dart Debug');
            } catch (e) {
              // Cross-origin iframe access will throw an error, ignore those
              return false;
            }
          });
          
        if (hasActiveConnection) {
          notifyConnectionStatus('connected');
        } else {
          notifyConnectionStatus('disconnected');
        }
      }
    }, 3000);
  };
  
  // Set up a custom error handler to catch and retry broken connections
  const origConsoleError = console.error;
  console.error = function(...args) {
    // Call original first
    origConsoleError.apply(console, args);
    
    // Look for debug service connection errors and try to recover
    if (args.length > 0 && typeof args[0] === 'string') {
      const errorMsg = args[0];
      if (errorMsg.includes('Error loading script') || 
          errorMsg.includes('WebSocket connection') ||
          errorMsg.includes('DWDS connection')) {
        console.log('[Flutter Bootstrap] Detected possible debug connection error');
        notifyConnectionStatus('error');
        
        // If app is already loaded, try to hot restart
        if (checkMainDartLoaded() && window.dart_library._debugger) {
          try {
            setTimeout(function() {
              console.log('[Flutter Bootstrap] Attempting recovery through debugger');
              window.dart_library._debugger.hotRestart();
            }, 2000);
          } catch (e) {
            console.error('[Flutter Bootstrap] Error during recovery', e);
          }
        }
      }
    }
  };
  
  // Start monitoring for connection issues
  startDebugMonitoring();
  
  // Make this accessible to the parent
  window._flutter_bootstrap = {
    checkConnections: startDebugMonitoring,
    forceRefresh: function() {
      location.reload(true);
    }
  };
  
  console.log('[Flutter Bootstrap] Debug helper initialized');
})(); 