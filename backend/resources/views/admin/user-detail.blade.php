@extends('layouts.admin')

@section('title', 'User Details - MTI Admin')

@section('header', 'User Details')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-1">
        <div class="card p-6 rounded-xl mb-6">
            <div class="flex flex-col items-center text-center mb-6">
                <div class="h-24 w-24 rounded-full bg-blue-900 bg-opacity-30 flex items-center justify-center mb-4">
                    <span class="text-3xl font-bold">{{ substr($user->full_name, 0, 1) }}</span>
                </div>
                <h3 class="text-xl font-bold gold-text">{{ $user->full_name }}</h3>
                <p class="text-gray-400 text-sm mt-1">User ID: {{ $user->id }}</p>
            </div>
            
            <div class="space-y-4">
                <div class="flex justify-between items-center py-3 border-b border-gray-800">
                    <span class="text-gray-400">Email</span>
                    <span class="font-medium">{{ $user->email }}</span>
                </div>
                
                <div class="flex justify-between items-center py-3 border-b border-gray-800">
                    <span class="text-gray-400">Phone</span>
                    <span class="font-medium">{{ $user->phonenumber }}</span>
                </div>
                
                <div class="flex justify-between items-center py-3 border-b border-gray-800">
                    <span class="text-gray-400">Date of Birth</span>
                    <span class="font-medium">{{ \Carbon\Carbon::parse($user->date_of_birth)->format('M d, Y') }}</span>
                </div>
                
                <div class="flex justify-between items-center py-3 border-b border-gray-800">
                    <span class="text-gray-400">Reference Code</span>
                    <span class="px-2 py-1 text-xs rounded-md bg-blue-900 bg-opacity-30 text-blue-300">{{ $user->affiliate_code }}</span>
                </div>
                
                <div class="flex justify-between items-center py-3 border-b border-gray-800">
                    <span class="text-gray-400">Upline Reference</span>
                    <span class="font-medium">{{ $user->referral_id }}</span>
                </div>
                
                <div class="flex justify-between items-center py-3 border-b border-gray-800">
                    <span class="text-gray-400">USDT Address</span>
                    <span class="font-medium truncate max-w-[150px]" title="{{ $user->usdt_address }}">
                        {{ $user->usdt_address ?: 'Not set' }}
                    </span>
                </div>
                
                <div class="flex justify-between items-center py-3">
                    <span class="text-gray-400">Joined</span>
                    <span class="font-medium">{{ \Carbon\Carbon::parse($user->created_at)->format('M d, Y') }}</span>
                </div>
            </div>
        </div>
    </div>
    
    <div class="lg:col-span-2">
        <div class="card p-6 rounded-xl">
            <h3 class="text-xl font-bold glow-text mb-6">Activity History</h3>
            
            <div class="space-y-4">
                @forelse($userLogs as $log)
                    <div class="flex items-start p-4 rounded-lg table-row">
                        <div class="h-10 w-10 rounded-full bg-gray-800 flex-shrink-0 flex items-center justify-center mr-4">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
                            </svg>
                        </div>
                        <div class="flex-1">
                            <div class="flex flex-col md:flex-row md:justify-between md:items-center">
                                <p class="text-sm">
                                    <span class="font-medium glow-text">{{ $log->column_name }}</span> 
                                    <span class="text-gray-400">was changed</span>
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
                    <p class="text-gray-500 text-center py-4">No activity logs found for this user</p>
                @endforelse
            </div>
            
            <div class="mt-6">
                {{ $userLogs->links() }}
            </div>
        </div>
    </div>
</div>
@endsection
