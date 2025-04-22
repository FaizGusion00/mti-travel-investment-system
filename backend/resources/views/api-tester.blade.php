<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MTI API Tester</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <style>
        body {
            background-color: #0f172a;
            color: #e2e8f0;
            font-family: 'Inter', sans-serif;
        }
        
        .card {
            background-color: #1e293b;
            border: 1px solid #334155;
            transition: all 0.3s ease;
        }
        
        .card:hover {
            border-color: #3b82f6;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.2);
        }
        
        .btn-primary {
            background-color: #3b82f6;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            background-color: #2563eb;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.3);
        }
        
        .endpoint-btn {
            transition: all 0.2s ease;
        }
        
        .endpoint-btn:hover {
            background-color: #334155;
        }
        
        .endpoint-btn.active {
            background-color: #3b82f6;
            color: white;
        }
        
        .json-response {
            background-color: #0f172a;
            border: 1px solid #334155;
            border-radius: 0.5rem;
            padding: 1rem;
            font-family: 'Courier New', monospace;
            white-space: pre-wrap;
            max-height: 400px;
            overflow-y: auto;
        }
        
        .json-key {
            color: #3b82f6;
        }
        
        .json-string {
            color: #10b981;
        }
        
        .json-number {
            color: #f59e0b;
        }
        
        .json-boolean {
            color: #8b5cf6;
        }
        
        .json-null {
            color: #ef4444;
        }
    </style>
</head>
<body class="min-h-screen">
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-3xl font-bold text-blue-500">MTI API Tester</h1>
            <div class="flex items-center space-x-2">
                <span id="connectionStatus" class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gray-700">
                    <span id="statusDot" class="h-2 w-2 mr-2 rounded-full bg-gray-400"></span>
                    Not Connected
                </span>
                <button onclick="checkApiConnection()" class="bg-blue-600 hover:bg-blue-700 text-white text-xs px-2 py-1 rounded-full" title="Retry Connection Check">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                    </svg>
                </button>
            </div>
        </div>
        
        <div class="card rounded-xl p-6 mb-6">
            <h2 class="text-xl font-bold text-blue-400 mb-4">How to Use This API Tester</h2>
            <ol class="list-decimal list-inside space-y-2 text-gray-300">
                <li>Click on any endpoint in the left sidebar to load it into the request panel</li>
                <li>For authenticated endpoints, first generate a token by clicking the "Get Test Token" button (this will redirect you to the token generator page)</li>
                <li>After generating a token, use the "Return to API Tester with Token" button to come back with your token automatically applied</li>
                <li>Modify the request parameters if needed</li>
                <li>Click "Send Request" to test the endpoint</li>
                <li>View the response in the right panel</li>
            </ol>
            <div class="mt-4 bg-blue-900 bg-opacity-30 border border-blue-700 rounded-lg p-4">
                <h3 class="text-lg font-bold text-blue-400 mb-2">Troubleshooting Tips</h3>
                <ul class="list-disc list-inside space-y-1 text-gray-300">
                    <li>All API endpoints should be accessed with the <code class="bg-gray-800 px-1 rounded">/api/v1/</code> prefix</li>
                    <li>If the connection indicator shows "Connection Failed", ensure your Laravel server is running</li>
                    <li>If you get a 404 error, check that the endpoint path is correct</li>
                    <li>For authentication errors, make sure your token is valid and properly formatted</li>
                    <li>Use the console (F12) to view detailed error messages</li>
                </ul>
            </div>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
            <!-- Sidebar with API Endpoints -->
            <div class="lg:col-span-1">
                <div class="card rounded-xl p-4 mb-4">
                    <h2 class="text-xl font-bold mb-4 text-blue-400">Authentication</h2>
                    <div class="space-y-2">
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/register" data-params='{"full_name":"Test User","email":"test@example.com","phonenumber":"+1234567890","date_of_birth":"1990-01-01","password":"Test1234!","password_confirmation":"Test1234!"}' data-auth="false">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Register
                        </button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/login" data-params='{"email":"test@example.com","password":"Test1234!"}' data-auth="false">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Login
                        </button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/verify-otp" data-params='{"email":"test@example.com","otp":"123456"}' data-auth="false">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Verify OTP
                        </button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/resend-otp" data-params='{"email":"test@example.com"}' data-auth="false">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Resend OTP
                        </button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/forgot-password" data-params='{"email":"test@example.com"}' data-auth="false">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Forgot Password
                        </button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/reset-password" data-params='{"email":"test@example.com","token":"your_token","password":"Test1234!","password_confirmation":"Test1234!"}' data-auth="false">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Reset Password
                        </button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded hover:bg-gray-700" data-method="POST" data-endpoint="/api/v1/logout" data-params='{}' data-auth="true">
                            <span class="inline-block w-12 text-xs font-semibold text-white bg-blue-600 rounded px-1 py-0.5 mr-2 text-center">POST</span>
                            Logout
                        </button>
                    </div>
                </div>
                
                <div class="card rounded-xl p-4 mb-4">
                    <h2 class="text-xl font-bold mb-4 text-blue-400">User & Profile</h2>
                    <div class="space-y-2">
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/user" data-auth="true">Get Current User</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/profile" data-auth="true">Get Profile</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="POST" data-endpoint="/api/v1/profile" data-auth="true" data-params='{"full_name":"Updated Name"}'>Update Profile</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="POST" data-endpoint="/api/v1/profile/change-password" data-auth="true" data-params='{"current_password":"Password123!","password":"NewPassword123!","password_confirmation":"NewPassword123!"}'>Change Password</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="POST" data-endpoint="/api/v1/profile/update-email" data-auth="true" data-params='{"email":"newemail@example.com"}'>Update Email</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="POST" data-endpoint="/api/v1/profile/update-wallet" data-auth="true" data-params='{"usdt_address":"0x1234567890abcdef"}'>Update Wallet</button>
                    </div>
                </div>
                
                <div class="card rounded-xl p-4 mb-4">
                    <h2 class="text-xl font-bold mb-4 text-blue-400">Network</h2>
                    <div class="space-y-2">
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/network" data-auth="true">Get Network</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/network/downline" data-auth="true">Get Downline</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/network/upline" data-auth="true">Get Upline</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/network/stats" data-auth="true">Get Network Stats</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/network/commissions" data-auth="true">Get Commissions</button>
                    </div>
                </div>
                
                <div class="card rounded-xl p-4">
                    <h2 class="text-xl font-bold mb-4 text-blue-400">Admin</h2>
                    <div class="space-y-2">
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/users" data-auth="true">Get All Users</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/users/1" data-auth="true">Get User by ID</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/stats/users" data-auth="true">Get User Stats</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/stats/registrations" data-auth="true">Get Registration Stats</button>
                        <button class="endpoint-btn w-full text-left px-3 py-2 rounded-lg text-sm" data-method="GET" data-endpoint="/api/v1/stats/activity" data-auth="true">Get Activity Stats</button>
                    </div>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="lg:col-span-3">
                <div class="card rounded-xl p-6 mb-6">
                    <div class="flex justify-between items-center mb-4">
                        <h2 class="text-xl font-bold text-blue-400">API Request</h2>
                        <div class="flex items-center">
                            <span id="requestMethod" class="px-2 py-1 rounded-md bg-blue-900 text-blue-300 text-sm font-medium mr-2">GET</span>
                            <span id="requestEndpoint" class="text-gray-400 text-sm">/api/v1/user</span>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <label for="tokenInput" class="block text-sm font-medium text-gray-400 mb-1">Bearer Token</label>
                        <div class="flex">
                            <input type="text" id="tokenInput" class="flex-1 bg-gray-900 border border-gray-700 rounded-l-lg px-4 py-2 text-sm focus:outline-none focus:border-blue-500" placeholder="Enter your authentication token here">
                            <button id="getTestToken" class="bg-green-600 hover:bg-green-700 text-white px-3 py-2 rounded-r-lg text-sm font-medium transition-colors duration-200">Get Test Token</button>
                        </div>
                        <p class="text-xs text-gray-500 mt-1">Click the button to generate a test token automatically</p>
                    </div>
                    
                    <div class="mb-6">
                        <label for="requestParams" class="block text-sm font-medium text-gray-400 mb-1">Request Parameters</label>
                        <textarea id="requestParams" rows="6" class="w-full bg-gray-900 border border-gray-700 rounded-lg px-4 py-2 text-sm font-mono focus:outline-none focus:border-blue-500" placeholder="{}"></textarea>
                    </div>
                    
                    <button id="sendRequest" class="btn-primary px-4 py-2 rounded-lg text-white font-medium">Send Request</button>
                </div>
                
                <div class="card rounded-xl p-6">
                    <div class="flex justify-between items-center mb-4">
                        <h2 class="text-xl font-bold text-blue-400">Response</h2>
                        <div class="flex items-center">
                            <span id="responseStatus" class="px-2 py-1 rounded-md bg-gray-800 text-gray-400 text-sm font-medium">Waiting for response...</span>
                        </div>
                    </div>
                    
                    <div id="responseTime" class="text-sm text-gray-500 mb-4">Response time: -</div>
                    
                    <div id="responseHeaders" class="mb-4 text-sm text-gray-400"></div>
                    
                    <div id="responseBody" class="json-response">
                        <div class="text-gray-500 italic">Response will appear here</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Check connection to API
            checkApiConnection();
            
            // Check for token in URL parameter
            const urlParams = new URLSearchParams(window.location.search);
            const tokenParam = urlParams.get('token');
            if (tokenParam) {
                document.getElementById('tokenInput').value = tokenParam;
                console.log('Token loaded from URL parameter');
            }
            
            // Set up endpoint buttons
            const endpointButtons = document.querySelectorAll('.endpoint-btn');
            endpointButtons.forEach(button => {
                button.addEventListener('click', function() {
                    // Update active button
                    endpointButtons.forEach(btn => btn.classList.remove('active'));
                    this.classList.add('active');
                    
                    // Update request details
                    const method = this.getAttribute('data-method');
                    const endpoint = this.getAttribute('data-endpoint');
                    const params = this.getAttribute('data-params');
                    const requiresAuth = this.getAttribute('data-auth') === 'true';
                    
                    document.getElementById('requestMethod').textContent = method;
                    document.getElementById('requestEndpoint').textContent = endpoint;
                    document.getElementById('requestParams').value = params ? formatJson(JSON.parse(params)) : '{}';
                    
                    // Highlight token input if auth is required
                    const tokenInput = document.getElementById('tokenInput');
                    if (requiresAuth) {
                        tokenInput.classList.add('border-yellow-500');
                        tokenInput.classList.add('bg-yellow-900');
                        tokenInput.classList.add('bg-opacity-20');
                    } else {
                        tokenInput.classList.remove('border-yellow-500');
                        tokenInput.classList.remove('bg-yellow-900');
                        tokenInput.classList.remove('bg-opacity-20');
                    }
                });
            });
            
            // Set up send request button
            document.getElementById('sendRequest').addEventListener('click', sendApiRequest);
            
            // Set up get test token button
            document.getElementById('getTestToken').addEventListener('click', getTestToken);
        });
        
        function checkApiConnection() {
            const statusDot = document.getElementById('statusDot');
            const connectionStatus = document.getElementById('connectionStatus');
            
            // Show checking status
            statusDot.classList.remove('bg-gray-400', 'bg-red-500', 'bg-blue-500');
            statusDot.classList.add('bg-blue-500');
            connectionStatus.classList.remove('bg-gray-700', 'bg-red-900', 'bg-green-900', 'bg-opacity-30');
            connectionStatus.classList.add('bg-blue-900', 'bg-opacity-30');
            connectionStatus.innerHTML = `
                <span id="statusDot" class="h-2 w-2 mr-2 rounded-full bg-blue-500"></span>
                Checking Connection...
            `;
            
            // Try multiple endpoint formats to find the working one
            tryEndpoint('/api/v1/test')
                .catch(error => {
                    console.log('First attempt failed, trying alternative endpoint format...');
                    return tryEndpoint('/api/test');
                })
                .catch(error => {
                    console.log('Second attempt failed, trying direct endpoint...');
                    return tryEndpoint('/test');
                })
                .catch(error => {
                    console.log('Third attempt failed, trying simple-test endpoint...');
                    return tryEndpoint('/api/v1/simple-test');
                })
                .catch(error => {
                    console.log('Fourth attempt failed, trying direct-test endpoint...');
                    return tryEndpoint('/api/v1/direct-test');
                })
                .catch(error => {
                    console.error('All API connection attempts failed');
                    
                    // Update status indicator for failure
                    statusDot.classList.remove('bg-gray-400', 'bg-green-500', 'bg-blue-500');
                    statusDot.classList.add('bg-red-500');
                    connectionStatus.classList.remove('bg-gray-700', 'bg-green-900', 'bg-blue-900', 'bg-opacity-30');
                    connectionStatus.classList.add('bg-red-900', 'bg-opacity-30');
                    connectionStatus.innerHTML = `
                        <span id="statusDot" class="h-2 w-2 mr-2 rounded-full bg-red-500"></span>
                        Connection Failed
                    `;
                    
                    // Add debugging button
                    connectionStatus.innerHTML += `
                        <button onclick="showApiDebugInfo()" class="ml-2 text-xs underline text-blue-400 hover:text-blue-300">Debug</button>
                    `;
                });
        }
        
        // Helper function to try an endpoint and return a promise
        function tryEndpoint(endpoint) {
            console.log('Attempting to connect to:', endpoint);
            return new Promise((resolve, reject) => {
                // Ensure endpoint has leading slash
                if (!endpoint.startsWith('/')) {
                    endpoint = '/' + endpoint;
                }
                
                // If endpoint doesn't start with /api and it's not just /test
                if (!endpoint.startsWith('/api/') && endpoint !== '/test') {
                    endpoint = '/api' + endpoint;
                }
                
                console.log('Final endpoint URL:', endpoint);
                
                axios.get(endpoint)
                    .then(response => {
                        console.log('API connection successful:', response.data);
                        
                        // Update status indicator for success
                        const statusDot = document.getElementById('statusDot');
                        const connectionStatus = document.getElementById('connectionStatus');
                        
                        statusDot.classList.remove('bg-gray-400', 'bg-red-500', 'bg-blue-500');
                        statusDot.classList.add('bg-green-500');
                        connectionStatus.classList.remove('bg-gray-700', 'bg-red-900', 'bg-blue-900', 'bg-opacity-30');
                        connectionStatus.classList.add('bg-green-900', 'bg-opacity-30');
                        connectionStatus.innerHTML = `
                            <span id="statusDot" class="h-2 w-2 mr-2 rounded-full bg-green-500"></span>
                            Connected via ${endpoint}
                        `;
                        
                        // Store the working endpoint for future use
                        window.workingApiEndpoint = endpoint.replace('/test', '').replace('/simple-test', '');
                        console.log('Working API base path:', window.workingApiEndpoint);
                        
                        resolve(response);
                    })
                    .catch(error => {
                        console.error(`Connection to ${endpoint} failed:`, error);
                        reject(error);
                    });
            });
        }
        
        // Show detailed API debug information
        function showApiDebugInfo() {
            // Create modal for debug info
            const modal = document.createElement('div');
            modal.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
            modal.innerHTML = `
                <div class="bg-gray-800 rounded-lg p-6 max-w-3xl w-full max-h-[80vh] overflow-y-auto">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-xl font-bold text-blue-400">API Connection Debug</h3>
                        <button class="text-gray-400 hover:text-white" onclick="this.parentNode.parentNode.parentNode.remove()">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                        </button>
                    </div>
                    <div class="space-y-4">
                        <div>
                            <h4 class="text-lg font-semibold text-blue-300 mb-2">Attempted Endpoints</h4>
                            <ul class="list-disc list-inside text-gray-300 space-y-1">
                                <li>/api/v1/test</li>
                                <li>/api/test</li>
                                <li>/test</li>
                                <li>/api/v1/simple-test</li>
                            </ul>
                        </div>
                        <div>
                            <h4 class="text-lg font-semibold text-blue-300 mb-2">Troubleshooting Steps</h4>
                            <ol class="list-decimal list-inside text-gray-300 space-y-2">
                                <li>Verify Laravel server is running with <code class="bg-gray-700 px-2 py-1 rounded">php artisan serve</code></li>
                                <li>Check that routes are registered with <code class="bg-gray-700 px-2 py-1 rounded">php artisan route:list</code></li>
                                <li>Ensure SimpleTestController.php exists and has a test() method</li>
                                <li>Check that the API routes in api.php are correctly defined</li>
                                <li>Try restarting the Laravel server</li>
                            </ol>
                        </div>
                        <div class="bg-gray-900 p-4 rounded">
                            <h4 class="text-lg font-semibold text-blue-300 mb-2">Manual Test</h4>
                            <p class="text-gray-300 mb-2">Open a new browser tab and try these URLs:</p>
                            <ul class="list-disc list-inside text-blue-400 space-y-1">
                                <li><a href="/api/v1/test" target="_blank" class="hover:underline">/api/v1/test</a></li>
                                <li><a href="/api/test" target="_blank" class="hover:underline">/api/test</a></li>
                                <li><a href="/test" target="_blank" class="hover:underline">/test</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            `;
            document.body.appendChild(modal);
        }
        
        function sendApiRequest() {
            const method = document.getElementById('requestMethod').textContent;
            let endpoint = document.getElementById('requestEndpoint').textContent;
            const params = JSON.parse(document.getElementById('requestParams').value || '{}');
            const token = document.getElementById('tokenInput').value;
            
            // Update UI
            const responseStatus = document.getElementById('responseStatus');
            const responseTime = document.getElementById('responseTime');
            const responseHeaders = document.getElementById('responseHeaders');
            const responseBody = document.getElementById('responseBody');
            
            responseStatus.textContent = 'Loading...';
            responseStatus.className = 'px-2 py-1 rounded-md bg-gray-700 text-gray-300 text-sm font-medium';
            responseTime.textContent = '';
            responseHeaders.innerHTML = '';
            responseBody.innerHTML = '<div class="text-gray-500 italic">Loading response...</div>';
            
            // Format the endpoint URL correctly
            // Make sure we have a leading slash
            if (!endpoint.startsWith('/')) {
                endpoint = '/' + endpoint;
            }
            
            // Ensure the endpoint has the correct format
            // The Laravel API routes are already prefixed with 'api'
            // So we need to make sure we're not adding it twice
            if (!endpoint.startsWith('/api/')) {
                endpoint = '/api' + endpoint;
            }
            
            console.log('Sending request to:', endpoint);
            
            // Prepare request config
            const config = {
                headers: {}
            };
            
            if (token) {
                config.headers['Authorization'] = `Bearer ${token}`;
            }
            
            // Start timer
            const startTime = new Date().getTime();
            
            // Send request
            let request;
            if (method === 'GET') {
                request = axios.get(endpoint, { ...config, params });
            } else if (method === 'POST') {
                request = axios.post(endpoint, params, config);
            } else if (method === 'PUT') {
                request = axios.put(endpoint, params, config);
            } else if (method === 'DELETE') {
                request = axios.delete(endpoint, { ...config, data: params });
            }
            
            request.then(response => {
                    // Calculate response time
                    const endTime = new Date().getTime();
                    const duration = endTime - startTime;
                    
                    // Update UI with success
                    responseStatus.textContent = `${response.status} ${response.statusText}`;
                    responseStatus.className = 'px-2 py-1 rounded-md bg-green-900 bg-opacity-30 text-green-300 text-sm font-medium';
                    responseTime.textContent = `Response time: ${duration}ms`;
                    
                    // Display headers
                    let headerText = '';
                    for (const [key, value] of Object.entries(response.headers)) {
                        headerText += `<div><span class="text-blue-400">${key}:</span> ${value}</div>`;
                    }
                    responseHeaders.innerHTML = headerText;
                    
                    // Format and display response body
                    responseBody.innerHTML = formatJsonWithHighlighting(response.data);
                })
                .catch(error => {
                    // Calculate response time
                    const endTime = new Date().getTime();
                    const duration = endTime - startTime;
                    
                    // Update UI with error
                    responseStatus.textContent = error.response ? `${error.response.status} ${error.response.statusText}` : 'Request Failed';
                    responseStatus.className = 'px-2 py-1 rounded-md bg-red-900 bg-opacity-30 text-red-300 text-sm font-medium';
                    responseTime.textContent = `Response time: ${duration}ms`;
                    
                    // Display headers if available
                    let headerText = '';
                    if (error.response && error.response.headers) {
                        for (const [key, value] of Object.entries(error.response.headers)) {
                            headerText += `<div><span class="text-blue-400">${key}:</span> ${value}</div>`;
                        }
                    }
                    responseHeaders.innerHTML = headerText;
                    
                    // Format and display error response
                    if (error.response && error.response.data) {
                        responseBody.innerHTML = formatJsonWithHighlighting(error.response.data);
                    } else {
                        responseBody.innerHTML = `<div class="text-red-400">${error.message}</div>`;
                    }
                });
        }
        
        function formatJson(obj) {
            return JSON.stringify(obj, null, 2);
        }
        
        function getTestToken() {
            // Redirect to the token generator page which is known to work
            window.location.href = '/token-generator';
        }
        
        function formatJsonWithHighlighting(json) {
            if (typeof json !== 'string') {
                json = JSON.stringify(json, null, 2);
            }
            
            json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            
            return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
                let cls = 'json-number';
                if (/^"/.test(match)) {
                    if (/:$/.test(match)) {
                        cls = 'json-key';
                    } else {
                        cls = 'json-string';
                    }
                } else if (/true|false/.test(match)) {
                    cls = 'json-boolean';
                } else if (/null/.test(match)) {
                    cls = 'json-null';
                }
                return '<span class="' + cls + '">' + match + '</span>';
            });
        }
    </script>
</body>
</html>
