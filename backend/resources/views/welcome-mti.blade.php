<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MTI Travel Investment</title>
    <script src="https://cdn.tailwindcss.com"></script>
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
        }

        .glow-text {
            color: #3B82F6;
            text-shadow: 0 0 5px rgba(59, 130, 246, 0.5);
        }

        .gold-text {
            color: #FFD700;
        }

        .btn-primary {
            background-color: #3B82F6;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            background-color: #2563EB;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.5);
        }

        .btn-gold {
            background-color: #B7791F;
            transition: all 0.3s ease;
        }

        .btn-gold:hover {
            background-color: #975A16;
            box-shadow: 0 0 15px rgba(183, 121, 31, 0.5);
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
    </style>
</head>
<body class="flex flex-col items-center justify-center p-4">
    <div class="stars" id="stars"></div>

    <div class="max-w-4xl w-full">
        <div class="text-center mb-12">
            <h1 class="text-5xl font-bold mb-4">
                <span class="gold-text">Meta Travel</span> <span class="glow-text">International</span>
            </h1>
            <p class="text-gray-400 text-xl">Backend Administration & API Testing</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
            <div class="card rounded-xl p-6 flex flex-col items-center text-center">
                <div class="h-16 w-16 rounded-full bg-blue-900 bg-opacity-30 flex items-center justify-center mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                </div>
                <h2 class="text-2xl font-bold gold-text mb-2">Admin Dashboard</h2>
                <p class="text-gray-400 mb-6">Access the admin dashboard to manage users, view statistics, and monitor activity logs.</p>
                <a href="{{ route('login') }}" class="btn-primary px-6 py-3 rounded-lg font-medium w-full">
                    Access Dashboard
                </a>
            </div>

            <div class="card rounded-xl p-6 flex flex-col items-center text-center">
                <div class="h-16 w-16 rounded-full bg-yellow-900 bg-opacity-30 flex items-center justify-center mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-yellow-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                </div>
                <h2 class="text-2xl font-bold gold-text mb-2">API Testing</h2>
                <p class="text-gray-400 mb-6">Test the API endpoints, generate tokens, and verify the connection to the backend.</p>
                <div class="grid grid-cols-2 gap-4 w-full">
                    <a href="{{ route('api.tester') }}" class="btn-primary px-4 py-3 rounded-lg font-medium">
                        API Tester
                    </a>
                    <a href="{{ route('token.generator') }}" class="btn-gold px-4 py-3 rounded-lg font-medium text-white">
                        Get Token
                    </a>
                </div>
            </div>
        </div>

        <div class="card rounded-xl p-6">
            <h2 class="text-2xl font-bold glow-text mb-4 text-center">API Documentation</h2>
            <div class="flex justify-center">
                <a href="{{ route('api.docs') }}" class="btn-primary px-6 py-3 rounded-lg font-medium">
                    View API Documentation
                </a>
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
            const starsCount = 100;

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
