<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'MTI Admin Dashboard')</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- Custom Styles -->
    <style>
        :root {
            --primary-bg: #000000;
            --accent-color: #FFD700;
            --text-glow: #3B82F6;
        }
        
        body {
            background-color: var(--primary-bg);
            background-image: 
                radial-gradient(circle at 25% 25%, rgba(59, 130, 246, 0.05) 0%, transparent 50%),
                radial-gradient(circle at 75% 75%, rgba(255, 215, 0, 0.05) 0%, transparent 50%);
            color: white;
            font-family: 'Inter', sans-serif;
        }
        
        .sidebar {
            background-color: rgba(0, 0, 0, 0.8);
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(255, 215, 0, 0.1);
        }
        
        .card {
            background-color: rgba(17, 24, 39, 0.7);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 215, 0, 0.1);
            transition: all 0.3s ease;
        }
        
        .card:hover {
            border-color: rgba(255, 215, 0, 0.3);
            box-shadow: 0 0 15px rgba(255, 215, 0, 0.1);
        }
        
        .glow-text {
            color: var(--text-glow);
            text-shadow: 0 0 5px rgba(59, 130, 246, 0.5);
        }
        
        .gold-text {
            color: var(--accent-color);
        }
        
        .btn-primary {
            background-color: var(--text-glow);
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            background-color: #2563EB;
            box-shadow: 0 0 15px rgba(59, 130, 246, 0.5);
        }
        
        .table-row {
            transition: all 0.2s ease;
        }
        
        .table-row:hover {
            background-color: rgba(255, 215, 0, 0.05);
        }
    </style>
    @yield('head')
</head>
<body class="min-h-screen flex">
    <!-- Sidebar -->
    <aside class="sidebar w-64 h-screen fixed left-0 top-0 overflow-y-auto">
        <div class="p-6">
            <div class="flex items-center justify-center mb-8">
                <h1 class="text-2xl font-bold gold-text">MTI <span class="glow-text">Admin</span></h1>
            </div>
            
            <nav class="space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="flex items-center p-3 rounded-lg {{ request()->routeIs('admin.dashboard') ? 'bg-blue-900 bg-opacity-30' : 'hover:bg-gray-800' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('admin.dashboard') ? 'gold-text' : 'text-gray-400' }}" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
                    </svg>
                    <span class="{{ request()->routeIs('admin.dashboard') ? 'gold-text' : 'text-gray-300' }}">Dashboard</span>
                </a>
                
                <a href="{{ route('admin.users') }}" class="flex items-center p-3 rounded-lg {{ request()->routeIs('admin.users') || request()->routeIs('admin.user.detail') ? 'bg-blue-900 bg-opacity-30' : 'hover:bg-gray-800' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('admin.users') || request()->routeIs('admin.user.detail') ? 'gold-text' : 'text-gray-400' }}" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
                    </svg>
                    <span class="{{ request()->routeIs('admin.users') || request()->routeIs('admin.user.detail') ? 'gold-text' : 'text-gray-300' }}">User Management</span>
                </a>
                
                <a href="{{ route('admin.logs') }}" class="flex items-center p-3 rounded-lg {{ request()->routeIs('admin.logs') ? 'bg-blue-900 bg-opacity-30' : 'hover:bg-gray-800' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('admin.logs') ? 'gold-text' : 'text-gray-400' }}" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
                    </svg>
                    <span class="{{ request()->routeIs('admin.logs') ? 'gold-text' : 'text-gray-300' }}">Activity Logs</span>
                </a>
                
                <a href="{{ route('admin.traders') }}" class="flex items-center p-3 rounded-lg {{ request()->routeIs('admin.traders') ? 'bg-blue-900 bg-opacity-30' : 'hover:bg-gray-800' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('admin.traders') ? 'gold-text' : 'text-gray-400' }}" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M8.433 7.418c.155-.103.346-.196.567-.267v1.698a2.305 2.305 0 01-.567-.267C8.07 8.34 8 8.114 8 8c0-.114.07-.34.433-.582zM11 12.849v-1.698c.22.071.412.164.567.267.364.243.433.468.433.582 0 .114-.07.34-.433.582a2.305 2.305 0 01-.567.267z" />
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-13a1 1 0 10-2 0v.092a4.535 4.535 0 00-1.676.662C6.602 6.234 6 7.009 6 8c0 .99.602 1.765 1.324 2.246.48.32 1.054.545 1.676.662v1.941c-.391-.127-.68-.317-.843-.504a1 1 0 10-1.51 1.31c.562.649 1.413 1.076 2.353 1.253V15a1 1 0 102 0v-.092a4.535 4.535 0 001.676-.662C13.398 13.766 14 12.991 14 12c0-.99-.602-1.765-1.324-2.246A4.535 4.535 0 0011 9.092V7.151c.391.127.68.317.843.504a1 1 0 101.511-1.31c-.563-.649-1.413-1.076-2.354-1.253V5z" clip-rule="evenodd" />
                    </svg>
                    <span class="{{ request()->routeIs('admin.traders') ? 'gold-text' : 'text-gray-300' }}">Trader Management</span>
                </a>
            </nav>
        </div>
        
        <div class="p-6 mt-auto border-t border-gray-800">
            <form action="{{ route('logout') }}" method="POST">
                @csrf
                <button type="submit" class="flex items-center w-full p-3 rounded-lg hover:bg-gray-800">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
                        <path fill-rule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 001 1h12a1 1 0 001-1V4a1 1 0 00-1-1H3zm11 4a1 1 0 10-2 0v4a1 1 0 102 0V7z" clip-rule="evenodd" />
                        <path d="M4 8a1 1 0 011-1h4a1 1 0 110 2H5a1 1 0 01-1-1z" />
                    </svg>
                    <span class="text-gray-300">Logout</span>
                </button>
            </form>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 ml-64 p-8">
        <div class="mb-8 flex justify-between items-center">
            <h1 class="text-3xl font-bold glow-text">@yield('header', 'Dashboard')</h1>
            <div class="flex items-center space-x-4">
                <span class="text-gray-400">{{ now()->format('F j, Y') }}</span>
                <div class="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center">
                    <span class="font-bold">A</span>
                </div>
            </div>
        </div>
        
        @yield('content')
    </main>

    @yield('scripts')
</body>
</html>
