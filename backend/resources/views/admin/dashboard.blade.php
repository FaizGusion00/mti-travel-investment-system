@extends('layouts.admin')

@section('title', 'Dashboard - MTI Admin')

@section('header', 'Dashboard')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <div class="card p-6 rounded-xl">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-400 text-sm font-medium">Total Users</h3>
            <div class="h-10 w-10 rounded-full bg-blue-900 bg-opacity-30 flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 gold-text" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
                </svg>
            </div>
        </div>
        <h2 class="text-3xl font-bold mb-1">{{ number_format($totalUsers) }}</h2>
        <p class="text-gray-400 text-sm">Registered users</p>
    </div>

    <div class="card p-6 rounded-xl">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-400 text-sm font-medium">New Today</h3>
            <div class="h-10 w-10 rounded-full bg-green-900 bg-opacity-30 flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm.75-11.25a.75.75 0 00-1.5 0v2.5h-2.5a.75.75 0 000 1.5h2.5v2.5a.75.75 0 001.5 0v-2.5h2.5a.75.75 0 000-1.5h-2.5v-2.5z" clip-rule="evenodd" />
                </svg>
            </div>
        </div>
        <h2 class="text-3xl font-bold mb-1">{{ $newUsersToday }}</h2>
        <p class="text-gray-400 text-sm">New registrations today</p>
    </div>

    <div class="card p-6 rounded-xl">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-400 text-sm font-medium">This Week</h3>
            <div class="h-10 w-10 rounded-full bg-purple-900 bg-opacity-30 flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-purple-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
                </svg>
            </div>
        </div>
        <h2 class="text-3xl font-bold mb-1">{{ $newUsersThisWeek }}</h2>
        <p class="text-gray-400 text-sm">New registrations this week</p>
    </div>

    <div class="card p-6 rounded-xl">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-400 text-sm font-medium">This Month</h3>
            <div class="h-10 w-10 rounded-full bg-indigo-900 bg-opacity-30 flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-indigo-400" viewBox="0 0 20 20" fill="currentColor">
                    <path d="M2 10a8 8 0 018-8v8h8a8 8 0 11-16 0z" />
                    <path d="M12 2.252A8.014 8.014 0 0117.748 8H12V2.252z" />
                </svg>
            </div>
        </div>
        <h2 class="text-3xl font-bold mb-1">{{ $newUsersThisMonth }}</h2>
        <p class="text-gray-400 text-sm">New registrations this month</p>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="card p-6 rounded-xl">
        <h3 class="text-xl font-bold mb-6 glow-text">User Registration Trend</h3>
        <div class="h-80">
            <canvas id="userTrendChart"></canvas>
        </div>
    </div>

    <div class="card p-6 rounded-xl">
        <h3 class="text-xl font-bold mb-6 glow-text">Recent Activity</h3>
        <div class="space-y-4">
            @php
                $recentLogs = \App\Models\UserLog::with('user')
                    ->orderBy('created_at', 'desc')
                    ->limit(5)
                    ->get();
            @endphp

            @forelse($recentLogs as $log)
                <div class="flex items-start p-3 rounded-lg table-row">
                    <div class="h-10 w-10 rounded-full bg-gray-800 flex-shrink-0 flex items-center justify-center mr-4">
                        <span class="text-sm font-bold">{{ substr($log->user->full_name ?? 'User', 0, 1) }}</span>
                    </div>
                    <div>
                        <p class="text-sm">
                            <span class="font-medium gold-text">{{ $log->user->full_name ?? 'Unknown User' }}</span>
                            <span class="text-gray-400">changed</span>
                            <span class="font-medium glow-text">{{ $log->column_name }}</span>
                        </p>
                        <p class="text-xs text-gray-500 mt-1">{{ $log->created_at->diffForHumans() }}</p>
                    </div>
                </div>
            @empty
                <p class="text-gray-500 text-center py-4">No recent activity</p>
            @endforelse

            <a href="{{ route('admin.logs') }}" class="block text-center text-sm text-blue-400 hover:text-blue-300 mt-4">
                View All Activity
            </a>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // User trend chart
    const ctx = document.getElementById('userTrendChart').getContext('2d');

    const dates = @json($dates);
    const counts = @json($counts);

    const userTrendChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: dates,
            datasets: [{
                label: 'New Users',
                data: counts,
                borderColor: '#FFD700',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                borderWidth: 2,
                tension: 0.3,
                fill: true,
                pointBackgroundColor: '#3B82F6',
                pointBorderColor: '#FFD700',
                pointBorderWidth: 2,
                pointRadius: 4,
                pointHoverRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(17, 24, 39, 0.9)',
                    titleColor: '#FFD700',
                    bodyColor: '#fff',
                    borderColor: 'rgba(59, 130, 246, 0.3)',
                    borderWidth: 1,
                    padding: 12,
                    displayColors: false
                }
            },
            scales: {
                x: {
                    grid: {
                        display: false,
                        drawBorder: false
                    },
                    ticks: {
                        color: 'rgba(255, 255, 255, 0.5)'
                    }
                },
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(255, 255, 255, 0.05)',
                        drawBorder: false
                    },
                    ticks: {
                        color: 'rgba(255, 255, 255, 0.5)',
                        precision: 0
                    }
                }
            }
        }
    });
</script>
@endsection
