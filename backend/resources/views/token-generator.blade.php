<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MTI API Token Generator</title>
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
        
        .btn-primary {
            background-color: #3b82f6;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            background-color: #2563eb;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.3);
        }
        
        pre {
            background-color: #0f172a;
            border: 1px solid #334155;
            border-radius: 0.5rem;
            padding: 1rem;
            white-space: pre-wrap;
            overflow-x: auto;
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">
    <div class="max-w-3xl w-full">
        <div class="card rounded-xl p-6 mb-6">
            <h1 class="text-3xl font-bold text-blue-500 mb-6">MTI API Token Generator</h1>
            
            <div class="mb-6">
                <p class="text-gray-300 mb-4">This tool helps you generate a test token for the MTI API. Use this token to authenticate your API requests.</p>
                
                <div class="flex space-x-4 mb-6">
                    <a href="{{ route('generate.token') }}" class="btn-primary px-4 py-2 rounded-lg text-white font-medium">Generate New Token</a>
                    <a href="{{ route('api.tester') }}" class="bg-gray-700 hover:bg-gray-600 px-4 py-2 rounded-lg text-white font-medium">Back to API Tester</a>
                </div>
                
                @if(session('token'))
                    <div class="bg-green-900 bg-opacity-30 border border-green-700 rounded-lg p-4 mb-6">
                        <h2 class="text-xl font-bold text-green-400 mb-2">Token Generated Successfully!</h2>
                        <p class="text-gray-300 mb-4">Your token has been generated. Copy it and use it in your API requests.</p>
                        
                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-400 mb-1">Bearer Token</label>
                            <div class="flex">
                                <input id="tokenInput" type="text" value="{{ session('token') }}" class="w-full bg-gray-900 border border-gray-700 rounded-l-lg px-4 py-2 text-sm" readonly>
                                <button onclick="copyToken()" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-r-lg">Copy</button>
                            </div>
                        </div>
                        <div class="mb-4">
                            <a href="{{ route('api.tester') }}?token={{ session('token') }}" class="w-full block text-center bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg">Return to API Tester with Token</a>
                        </div>
                        
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Usage Example</label>
                            <pre><code>Authorization: Bearer {{ session('token') }}</code></pre>
                        </div>
                    </div>
                    
                    <div class="bg-blue-900 bg-opacity-30 border border-blue-700 rounded-lg p-4">
                        <h2 class="text-xl font-bold text-blue-400 mb-2">Test User Credentials</h2>
                        <p class="text-gray-300 mb-4">You can also login directly with these credentials:</p>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Email</label>
                                <input type="text" value="test@example.com" class="w-full bg-gray-900 border border-gray-700 rounded-lg px-4 py-2 text-sm" readonly>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Password</label>
                                <input type="text" value="Password123!" class="w-full bg-gray-900 border border-gray-700 rounded-lg px-4 py-2 text-sm" readonly>
                            </div>
                        </div>
                    </div>
                @else
                    <div class="bg-blue-900 bg-opacity-30 border border-blue-700 rounded-lg p-4">
                        <h2 class="text-xl font-bold text-blue-400 mb-2">Instructions</h2>
                        <ol class="list-decimal list-inside space-y-2 text-gray-300">
                            <li>Click the "Generate New Token" button above</li>
                            <li>Copy the generated token</li>
                            <li>Use the token in your API requests by adding it to the Authorization header</li>
                            <li>The token will be valid until you generate a new one or restart the server</li>
                        </ol>
                    </div>
                @endif
            </div>
        </div>
        
        <div class="card rounded-xl p-6">
            <h2 class="text-xl font-bold text-blue-400 mb-4">API Endpoints</h2>
            
            <div class="space-y-4">
                <div class="bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center mb-2">
                        <span class="px-2 py-1 rounded-md bg-green-900 text-green-300 text-xs font-medium mr-2">GET</span>
                        <span class="text-gray-300">/api/v1/test</span>
                    </div>
                    <p class="text-gray-400 text-sm">Test if the API is working</p>
                </div>
                
                <div class="bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center mb-2">
                        <span class="px-2 py-1 rounded-md bg-green-900 text-green-300 text-xs font-medium mr-2">GET</span>
                        <span class="text-gray-300">/api/v1/user</span>
                    </div>
                    <p class="text-gray-400 text-sm">Get the authenticated user (requires token)</p>
                </div>
                
                <div class="bg-gray-800 rounded-lg p-4">
                    <div class="flex items-center mb-2">
                        <span class="px-2 py-1 rounded-md bg-blue-900 text-blue-300 text-xs font-medium mr-2">POST</span>
                        <span class="text-gray-300">/api/v1/login</span>
                    </div>
                    <p class="text-gray-400 text-sm">Login and get a token</p>
                </div>
            </div>
        </div>
    </div>
    
    <footer class="py-6 text-center text-gray-500 text-sm">
        <p>&copy; {{ date('Y') }} Meta Travel International. All rights reserved.</p>
    </footer>
    
    <script>
        function copyToken() {
            const tokenInput = document.getElementById('tokenInput');
            tokenInput.select();
            document.execCommand('copy');
            
            // Show feedback
            const button = event.target;
            const originalText = button.textContent;
            button.textContent = 'Copied!';
            button.classList.add('bg-green-600');
            button.classList.remove('bg-blue-600', 'hover:bg-blue-700');
            
            // Reset after 2 seconds
            setTimeout(() => {
                button.textContent = originalText;
                button.classList.remove('bg-green-600');
                button.classList.add('bg-blue-600', 'hover:bg-blue-700');
            }, 2000);
        }
    </script>
</body>
</html>
