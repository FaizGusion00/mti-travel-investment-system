<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MTI API Documentation</title>
    <script src="https://cdn.tailwindcss.com"></script>
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

        pre {
            background-color: #0f172a;
            border: 1px solid #334155;
            border-radius: 0.5rem;
            padding: 1rem;
            overflow-x: auto;
        }

        code {
            font-family: 'Courier New', monospace;
        }

        .method-get {
            background-color: #0369a1;
        }

        .method-post {
            background-color: #15803d;
        }

        .method-put {
            background-color: #a16207;
        }

        .method-delete {
            background-color: #b91c1c;
        }
    </style>
</head>
<body class="min-h-screen">
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-3xl font-bold text-blue-500">MTI API Documentation</h1>
            <div class="flex space-x-4">
                <a href="{{ route('api.tester') }}" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg text-white">API Tester</a>
                <a href="{{ route('token.generator') }}" class="px-4 py-2 bg-green-600 hover:bg-green-700 rounded-lg text-white">Get Token</a>
                <a href="/" class="px-4 py-2 bg-gray-600 hover:bg-gray-700 rounded-lg text-white">Home</a>
            </div>
        </div>

        <div class="card rounded-xl p-6 mb-8">
            <h2 class="text-2xl font-bold text-blue-400 mb-4">Introduction</h2>
            <p class="mb-4">Welcome to the MetaTravel.ai API documentation. This API provides access to the MTI platform's features, including user management, profile management, and network/referral system.</p>
            <p class="mb-4">All API requests should be prefixed with <code class="bg-gray-800 px-2 py-1 rounded">/api/v1</code>. This is because Laravel automatically adds the <code class="bg-gray-800 px-2 py-1 rounded">/api</code> prefix to routes defined in the <code>api.php</code> file.</p>
            <p class="mb-4">For example, to access the login endpoint, you would use <code class="bg-gray-800 px-2 py-1 rounded">/api/v1/login</code>.</p>
            <p class="mb-4">The API tester tool on this site is configured to use these full paths automatically, so you can test all endpoints without worrying about the URL format.</p>

            <h3 class="text-xl font-bold text-blue-400 mt-6 mb-3">Authentication</h3>
            <p class="mb-4">Most endpoints require authentication using a Bearer token. Include the token in the Authorization header of your requests:</p>
            <pre><code>Authorization: Bearer your_token_here</code></pre>

            <h3 class="text-xl font-bold text-blue-400 mt-6 mb-3">Response Format</h3>
            <p class="mb-4">All responses are returned in JSON format with the following structure:</p>
            <pre><code>{
  "status": "success|error",
  "message": "A descriptive message",
  "data": {
    // Response data
  },
  "errors": {
    // Validation errors (if any)
  }
}</code></pre>
        </div>

        <div class="card rounded-xl p-6 mb-8">
            <h2 class="text-2xl font-bold text-blue-400 mb-6">Authentication Endpoints</h2>

            <div class="space-y-6">
                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-post text-white text-sm font-bold rounded-lg mr-3">POST</span>
                        <span class="text-lg font-medium">/v1/register</span>
                    </div>
                    <p class="text-gray-400 mb-3">Register a new user</p>
                    <h4 class="text-blue-400 font-medium mb-2">Request Body</h4>
                    <pre><code>{
  "full_name": "John Doe",
  "email": "john@example.com",
  "phonenumber": "1234567890",
  "date_of_birth": "1990-01-01",
  "reference_code": "ABC123", // Optional
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!"
}</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-post text-white text-sm font-bold rounded-lg mr-3">POST</span>
                        <span class="text-lg font-medium">/v1/login</span>
                    </div>
                    <p class="text-gray-400 mb-3">Login and get an authentication token</p>
                    <h4 class="text-blue-400 font-medium mb-2">Request Body</h4>
                    <pre><code>{
  "email": "john@example.com",
  "password": "SecurePassword123!",
}</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-post text-white text-sm font-bold rounded-lg mr-3">POST</span>
                        <span class="text-lg font-medium">/v1/verify-otp</span>
                    </div>
                    <p class="text-gray-400 mb-3">Verify OTP for email verification</p>
                    <h4 class="text-blue-400 font-medium mb-2">Request Body</h4>
                    <pre><code>{
  "email": "john@example.com",
  "otp": "123456"
}</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-post text-white text-sm font-bold rounded-lg mr-3">POST</span>
                        <span class="text-lg font-medium">/v1/logout</span>
                    </div>
                    <p class="text-gray-400 mb-3">Logout and invalidate the current token</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                </div>
            </div>
        </div>

        <div class="card rounded-xl p-6 mb-8">
            <h2 class="text-2xl font-bold text-blue-400 mb-6">User & Profile Endpoints</h2>

            <div class="space-y-6">
                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/user</span>
                    </div>
                    <p class="text-gray-400 mb-3">Get the authenticated user's information</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/profile</span>
                    </div>
                    <p class="text-gray-400 mb-3">Get the authenticated user's profile</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-post text-white text-sm font-bold rounded-lg mr-3">POST</span>
                        <span class="text-lg font-medium">/v1/profile</span>
                    </div>
                    <p class="text-gray-400 mb-3">Update the authenticated user's profile</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                    <h4 class="text-blue-400 font-medium mb-2">Request Body</h4>
                    <pre><code>{
  "full_name": "John Smith",
  "phonenumber": "9876543210",
  "date_of_birth": "1990-01-01",
  "ref_code": "ABC123" // Optional
}</code></pre>
                </div>
            </div>
        </div>

        <div class="card rounded-xl p-6 mb-8">
            <h2 class="text-2xl font-bold text-blue-400 mb-6">Network Endpoints</h2>

            <div class="space-y-6">
                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/network</span>
                    </div>
                    <p class="text-gray-400 mb-3">Get the authenticated user's network (upline and downlines)</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                    <h4 class="text-blue-400 font-medium mb-2">Query Parameters</h4>
                    <pre><code>levels=5 // Optional, default: 5</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/network/downline</span>
                    </div>
                    <p class="text-gray-400 mb-3">Get the authenticated user's downlines</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                    <h4 class="text-blue-400 font-medium mb-2">Query Parameters</h4>
                    <pre><code>levels=5 // Optional, default: 5
page=1 // Optional, default: 1
per_page=15 // Optional, default: 15</code></pre>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/network/stats</span>
                    </div>
                    <p class="text-gray-400 mb-3">Get the authenticated user's network statistics</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                </div>
            </div>
        </div>

        <div class="card rounded-xl p-6">
            <h2 class="text-2xl font-bold text-blue-400 mb-6">Testing Endpoints</h2>

            <div class="space-y-6">
                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/simple-test</span>
                    </div>
                    <p class="text-gray-400 mb-3">Test if the API is working</p>
                </div>

                <div class="border-b border-gray-700 pb-6">
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/auth-test</span>
                    </div>
                    <p class="text-gray-400 mb-3">Test if authentication is working</p>
                    <h4 class="text-blue-400 font-medium mb-2">Headers</h4>
                    <pre><code>Authorization: Bearer your_token_here</code></pre>
                </div>

                <div>
                    <div class="flex items-center mb-3">
                        <span class="px-3 py-1 method-get text-white text-sm font-bold rounded-lg mr-3">GET</span>
                        <span class="text-lg font-medium">/v1/app-info</span>
                    </div>
                    <p class="text-gray-400 mb-3">Get application information</p>
                </div>
            </div>
        </div>
    </div>

    <footer class="py-6 text-center text-gray-500 text-sm">
        <p>&copy; {{ date('Y') }} Meta Travel International. All rights reserved.</p>
    </footer>
</body>
</html>
