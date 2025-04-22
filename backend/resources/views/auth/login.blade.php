<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - MTI Admin</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            background-color: #000000;
            background-image: 
                radial-gradient(circle at 25% 25%, rgba(59, 130, 246, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 75% 75%, rgba(255, 215, 0, 0.1) 0%, transparent 50%);
            color: white;
            font-family: 'Inter', sans-serif;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .login-card {
            background-color: rgba(17, 24, 39, 0.7);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 215, 0, 0.1);
            transition: all 0.3s ease;
            width: 100%;
            max-width: 400px;
        }
        
        .login-card:hover {
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
        
        .form-input {
            background-color: rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
            transition: all 0.3s ease;
        }
        
        .form-input:focus {
            border-color: #3B82F6;
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.2);
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
<body>
    <div class="stars" id="stars"></div>
    
    <div class="login-card p-8 rounded-xl">
        <div class="text-center mb-8">
            <h1 class="text-3xl font-bold mb-2">
                <span class="gold-text">MTI</span> <span class="glow-text">Admin</span>
            </h1>
            <p class="text-gray-400">Enter your credentials to access the dashboard</p>
        </div>
        
        @if ($errors->any())
            <div class="bg-red-900 bg-opacity-50 text-white p-4 rounded-lg mb-6">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif
        
        <form method="POST" action="{{ url('/login') }}" class="space-y-6">
            @csrf
            <div>
                <label for="email" class="block text-sm font-medium text-gray-300 mb-2">Email Address</label>
                <input type="email" id="email" name="email" value="{{ old('email') }}" required autofocus
                    class="form-input w-full px-4 py-3 rounded-lg focus:outline-none">
            </div>
            
            <div>
                <label for="password" class="block text-sm font-medium text-gray-300 mb-2">Password</label>
                <input type="password" id="password" name="password" required
                    class="form-input w-full px-4 py-3 rounded-lg focus:outline-none">
            </div>
            
            <button type="submit" class="btn-primary w-full py-3 rounded-lg font-medium">
                Sign In
            </button>
        </form>
    </div>
    
    <script>
        // Create stars
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
    </script>
</body>
</html>
