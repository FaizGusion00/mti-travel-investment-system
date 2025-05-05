@extends('layouts.admin')

@section('title', 'Activity Logs - MTI Admin')

@section('header', 'Activity Logs')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
    <div class="lg:col-span-2">
        <div class="card p-6 rounded-xl">
            <h3 class="text-xl font-bold glow-text mb-6">Recent Activity</h3>
            
            <div class="space-y-4">
                @forelse($logs as $log)
                    <div class="flex items-start p-4 rounded-lg table-row">
                        <div class="h-10 w-10 rounded-full bg-gray-800 flex-shrink-0 flex items-center justify-center mr-4">
                            <span class="text-sm font-bold">{{ substr($log->user->full_name ?? 'U', 0, 1) }}</span>
                        </div>
                        <div class="flex-1">
                            <div class="flex flex-col md:flex-row md:justify-between md:items-center">
                                <p class="text-sm">
                                    <span class="font-medium gold-text">{{ $log->user->full_name ?? 'Unknown User' }}</span> 
                                    <span class="text-gray-400">changed</span> 
                                    <span class="font-medium glow-text">{{ $log->column_name }}</span>
                                </p>
                                <p class="text-xs text-gray-500 mt-1 md:mt-0">{{ $log->created_at->format('M d, Y H:i') }}</p>
                            </div>
                            
                            <div class="mt-3 grid grid-cols-1 md:grid-cols-2 gap-3">
                                <div class="bg-gray-900 bg-opacity-50 p-3 rounded-lg">
                                    <p class="text-xs text-gray-500 mb-1">Old Value</p>
                                    <p class="text-sm">{{ $log->old_value ?: 'N/A' }}</p>
                                </div>
                                
                                <div class="bg-gray-900 bg-opacity-50 p-3 rounded-lg">
                                    <p class="text-xs text-gray-500 mb-1">New Value</p>
                                    <p class="text-sm">{{ $log->new_value ?: 'N/A' }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                @empty
                    <p class="text-gray-500 text-center py-4">No activity logs found</p>
                @endforelse
            </div>
            
            <div class="mt-6">
                {{ $logs->links() }}
            </div>
        </div>
    </div>
    
    <div class="lg:col-span-1">
        <div class="card p-6 rounded-xl">
            <h3 class="text-xl font-bold glow-text mb-6">Activity by Type</h3>
            <div class="h-80">
                <canvas id="activityTypeChart"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="card p-6 rounded-xl">
    <h3 class="text-xl font-bold glow-text mb-6">Activity Timeline</h3>
    
    <div class="relative">
        <div class="absolute left-5 top-0 bottom-0 w-0.5 bg-gray-800"></div>
        
        <div class="space-y-8 relative">
            @php
                $groupedLogs = $logs->groupBy(function($log) {
                    return $log->created_at->format('Y-m-d');
                });
            @endphp
            
            @forelse($groupedLogs as $date => $dateGroup)
                <div class="relative">
                    <div class="flex items-center mb-4">
                        <div class="h-10 w-10 rounded-full bg-blue-900 bg-opacity-30 flex items-center justify-center z-10 mr-4">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 gold-text" viewBox="0 0 20 20" fill="currentColor">
                                <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
                            </svg>
                        </div>
                        <h4 class="text-lg font-medium">{{ \Carbon\Carbon::parse($date)->format('F j, Y') }}</h4>
                    </div>
                    
                    <div class="ml-14 space-y-4">
                        @foreach($dateGroup as $log)
                            <div class="flex items-start p-4 rounded-lg table-row">
                                <div class="h-8 w-8 rounded-full bg-gray-800 flex-shrink-0 flex items-center justify-center mr-3">
                                    <span class="text-xs font-bold">{{ substr($log->user->full_name ?? 'U', 0, 1) }}</span>
                                </div>
                                <div>
                                    <div class="flex items-center">
                                        <p class="text-sm">
                                            <span class="font-medium gold-text">{{ $log->user->full_name ?? 'Unknown User' }}</span> 
                                            <span class="text-gray-400">changed</span> 
                                            <span class="font-medium glow-text">{{ $log->column_name }}</span>
                                        </p>
                                        <span class="text-xs text-gray-500 ml-3">{{ $log->created_at->format('H:i') }}</span>
                                    </div>
                                    <p class="text-xs text-gray-400 mt-1">
                                        @if($log->old_value && $log->new_value)
                                            Changed from "{{ $log->old_value }}" to "{{ $log->new_value }}"
                                        @elseif($log->new_value)
                                            Set to "{{ $log->new_value }}"
                                        @else
                                            Value was removed
                                        @endif
                                    </p>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            @empty
                <p class="text-gray-500 text-center py-4">No activity logs found</p>
            @endforelse
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Activity by type chart
    const ctx = document.getElementById('activityTypeChart').getContext('2d');
    
    const logTypes = @json($logTypes);
    const logCounts = @json($logCounts);
    
    // Generate colors for each type
    const colors = [];
    for (let i = 0; i < logTypes.length; i++) {
        const hue = (i * 137) % 360; // Golden angle approximation for good distribution
        colors.push(`hsl(${hue}, 70%, 60%)`);
    }
    
    const activityTypeChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: logTypes,
            datasets: [{
                data: logCounts,
                backgroundColor: colors,
                borderColor: 'rgba(17, 24, 39, 0.8)',
                borderWidth: 2,
                hoverOffset: 15
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '65%',
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: 'rgba(255, 255, 255, 0.7)',
                        padding: 15,
                        usePointStyle: true,
                        pointStyle: 'circle'
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(17, 24, 39, 0.9)',
                    titleColor: '#FFD700',
                    bodyColor: '#fff',
                    borderColor: 'rgba(59, 130, 246, 0.3)',
                    borderWidth: 1,
                    padding: 12,
                    displayColors: true
                }
            }
        }
    });
</script>
@endsection
