<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MTI Travel Investment</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            background-color: #000000;
            background-image:
                radial-gradient(circle at 25% 25%, rgba(59, 130, 246, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 75% 75%, rgba(255, 215, 0, 0.1) 0%, transparent 50%);
            color: white;
            font-family: 'Inter', sans-serif;
            min-height: 100vh;
        }

        .card {
            background-color: rgba(17, 24, 39, 0.7);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 215, 0, 0.1);
            transition: all 0.3s ease;
        }

        .card:hover {
            border-color: rgba(255, 215, 0, 0.3);
            box-shadow: 0 0 30px rgba(255, 215, 0, 0.1);
            transform: translateY(-5px);
        }

        .glow-text {
            color: #3B82F6;
            text-shadow: 0 0 5px rgba(59, 130, 246, 0.5);
        }

        .gold-text {
            color: #FFD700;
            text-shadow: 0 0 5px rgba(255, 215, 0, 0.3);
        }

        .btn-primary {
            background-color: #3B82F6;
            transition: all 0.3s ease;
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .btn-primary:hover {
            background-color: #2563EB;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.5);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background-color: rgba(17, 24, 39, 0.9);
            border: 1px solid rgba(255, 215, 0, 0.3);
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            border-color: rgba(255, 215, 0, 0.6);
            box-shadow: 0 0 15px rgba(255, 215, 0, 0.2);
            transform: translateY(-2px);
        }

        .stars {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            overflow: hidden;
        }

        .star {
            position: absolute;
            background-color: white;
            border-radius: 50%;
            animation: twinkle 5s infinite;
        }

        @keyframes twinkle {
            0% { opacity: 0; }
            50% { opacity: 1; }
            100% { opacity: 0; }
        }

        .glass-effect {
            background: rgba(17, 24, 39, 0.6);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .feature-icon {
            transition: all 0.3s ease;
        }

        .card:hover .feature-icon {
            transform: scale(1.1);
            color: #FFD700;
        }
    </style>
</head>
<body class="flex flex-col items-center justify-center p-4 py-16">
    <div class="stars" id="stars"></div>

    <div class="max-w-6xl w-full">
        <div class="text-center mb-16">
            <h1 class="text-6xl font-bold mb-4">
                <span class="gold-text">Meta Travel</span> <span class="glow-text">International</span>
            </h1>
            <p class="text-gray-300 text-xl">Administrative Dashboard & API Management</p>
        </div>

        <div class="mb-16">
            <div class="card rounded-2xl p-8 shadow-2xl">
                <div class="flex flex-col md:flex-row items-center">
                    <div class="md:w-3/5 mb-8 md:mb-0 md:pr-8">
                        <h2 class="text-4xl font-bold mb-4">
                            <span class="gold-text">Admin</span> <span class="glow-text">Dashboard</span>
                        </h2>
                        <p class="text-gray-300 text-lg mb-6">Access the comprehensive administration panel to manage users, view statistics, and monitor platform activity in real-time.</p>
                        
                        <div class="grid grid-cols-2 gap-4 mb-8">
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-blue-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>User Management</span>
                            </div>
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-blue-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>Platform Analytics</span>
                            </div>
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-blue-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>Activity Logs</span>
                            </div>
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-blue-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>System Settings</span>
                            </div>
                        </div>
                        
                        <a href="{{ route('login') }}" class="btn-primary px-6 py-4 rounded-lg font-medium inline-flex items-center">
                            <span>Access Dashboard</span>
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 ml-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                            </svg>
                        </a>
                    </div>
                    <div class="md:w-2/5">
                        <div class="glass-effect p-6 rounded-xl flex items-center justify-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="feature-icon h-48 w-48 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="mb-16">
            <div class="card rounded-2xl p-8 shadow-2xl">
                <div class="flex flex-col md:flex-row-reverse items-center">
                    <div class="md:w-3/5 mb-8 md:mb-0 md:pl-8">
                        <h2 class="text-4xl font-bold mb-4">
                            <span class="gold-text">API</span> <span class="glow-text">Documentation</span>
                        </h2>
                        <p class="text-gray-300 text-lg mb-6">Comprehensive documentation for developers to integrate with our platform. Explore endpoints, authentication methods, and example requests.</p>
                        
                        <div class="grid grid-cols-2 gap-4 mb-8">
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-yellow-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>Authentication</span>
                            </div>
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-yellow-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>User Endpoints</span>
                            </div>
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-yellow-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>Network Endpoints</span>
                            </div>
                            <div class="flex items-center">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-yellow-400 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                <span>Request Examples</span>
                            </div>
                        </div>
                        
                        <a href="{{ route('api.docs') }}" class="btn-secondary px-6 py-4 rounded-lg font-medium inline-flex items-center">
                            <span>View Documentation</span>
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 ml-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                            </svg>
                        </a>
                    </div>
                    <div class="md:w-2/5">
                        <div class="glass-effect p-6 rounded-xl flex items-center justify-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="feature-icon h-48 w-48 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-12 text-center text-gray-500 text-sm">
        <p>&copy; {{ date('Y') }} Meta Travel International. All rights reserved.</p>
    </footer>

    <script>
        // Create stars
        document.addEventListener('DOMContentLoaded', function() {
            const starsContainer = document.getElementById('stars');
            const starsCount = 150;

            for (let i = 0; i < starsCount; i++) {
                const star = document.createElement('div');
                star.classList.add('star');

                // Random position
                const x = Math.random() * 100;
                const y = Math.random() * 100;

                // Random size
                const size = Math.random() * 2;

                // Random animation delay
                const delay = Math.random() * 5;

                star.style.left = `${x}%`;
                star.style.top = `${y}%`;
                star.style.width = `${size}px`;
                star.style.height = `${size}px`;
                star.style.animationDelay = `${delay}s`;

                starsContainer.appendChild(star);
            }
        });
    </script>
</body>
</html>
