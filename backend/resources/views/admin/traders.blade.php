@extends('layouts.admin')

@section('title', 'Trader Management - MTI Admin')

@section('header', 'Trader Management')

@section('content')
<!-- Traders Section -->
<div class="card p-6 rounded-xl mb-6">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
        <h3 class="text-xl font-bold glow-text mb-4 md:mb-0">Current Traders</h3>
        <div class="relative">
            <input type="text" id="searchTraders" placeholder="Search traders..." class="form-input bg-gray-900 border border-gray-700 rounded-lg px-4 py-2 w-full md:w-64 focus:outline-none focus:border-blue-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 absolute right-3 top-2.5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd" />
            </svg>
        </div>
    </div>
    
    @if(session('success'))
    <div class="bg-green-900 bg-opacity-50 border border-green-700 text-green-300 px-4 py-3 rounded mb-4">
        {{ session('success') }}
    </div>
    @endif

    @if(session('error'))
    <div class="bg-red-900 bg-opacity-50 border border-red-700 text-red-300 px-4 py-3 rounded mb-4">
        {{ session('error') }}
    </div>
    @endif
    
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead>
                <tr class="border-b border-gray-800">
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">ID</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Name</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Email</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Cash Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Voucher Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Travel Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">XLM Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody id="tradersTable">
                @forelse($traders as $trader)
                    <tr class="table-row border-b border-gray-800">
                        <td class="px-4 py-4 whitespace-nowrap text-sm">{{ $trader->id }}</td>
                        <td class="px-4 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="h-8 w-8 rounded-full bg-blue-900 bg-opacity-30 flex items-center justify-center mr-3">
                                    <span class="font-bold text-xs">{{ substr($trader->full_name, 0, 1) }}</span>
                                </div>
                                <span class="text-sm font-medium">{{ $trader->full_name }}</span>
                            </div>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-300">{{ $trader->email }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-green-400">{{ number_format($trader->cash_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-blue-400">{{ number_format($trader->voucher_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-purple-400">{{ number_format($trader->travel_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-yellow-400">{{ number_format($trader->xlm_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm">
                            <div class="flex space-x-2">
                                <a href="{{ route('admin.user.detail', $trader->id) }}" class="text-blue-400 hover:text-blue-300">
                                    View
                                </a>
                                <form action="{{ route('admin.toggle.trader', $trader->id) }}" method="POST" class="inline">
                                    @csrf
                                    <button type="submit" class="text-red-400 hover:text-red-300 ml-2">
                                        Remove Trader
                                    </button>
                                </form>
                                <button type="button" class="text-green-400 hover:text-green-300 ml-2" 
                                        onclick="openWalletModal({{ $trader->id }}, '{{ $trader->full_name }}')">
                                    Manage Wallet
                                </button>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8" class="px-4 py-6 text-center text-gray-500">No traders found</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div class="mt-6">
        {{ $traders->links() }}
    </div>
</div>

<!-- Regular Users Section -->
<div class="card p-6 rounded-xl mb-6">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
        <h3 class="text-xl font-bold glow-text mb-4 md:mb-0">Regular Users</h3>
        <div class="relative">
            <input type="text" id="searchUsers" placeholder="Search users..." class="form-input bg-gray-900 border border-gray-700 rounded-lg px-4 py-2 w-full md:w-64 focus:outline-none focus:border-blue-500">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 absolute right-3 top-2.5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd" />
            </svg>
        </div>
    </div>
    
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead>
                <tr class="border-b border-gray-800">
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">ID</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Name</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Email</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Cash Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Voucher Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Travel Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">XLM Wallet</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody id="usersTable">
                @forelse($users as $user)
                    <tr class="table-row border-b border-gray-800">
                        <td class="px-4 py-4 whitespace-nowrap text-sm">{{ $user->id }}</td>
                        <td class="px-4 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="h-8 w-8 rounded-full bg-blue-900 bg-opacity-30 flex items-center justify-center mr-3">
                                    <span class="font-bold text-xs">{{ substr($user->full_name, 0, 1) }}</span>
                                </div>
                                <span class="text-sm font-medium">{{ $user->full_name }}</span>
                            </div>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-300">{{ $user->email }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-green-400">{{ number_format($user->cash_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-blue-400">{{ number_format($user->voucher_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-purple-400">{{ number_format($user->travel_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-yellow-400">{{ number_format($user->xlm_wallet, 2) }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm">
                            <div class="flex space-x-2">
                                <a href="{{ route('admin.user.detail', $user->id) }}" class="text-blue-400 hover:text-blue-300">
                                    View
                                </a>
                                <form action="{{ route('admin.toggle.trader', $user->id) }}" method="POST" class="inline">
                                    @csrf
                                    <button type="submit" class="text-green-400 hover:text-green-300 ml-2">
                                        Make Trader
                                    </button>
                                </form>
                                <button type="button" class="text-green-400 hover:text-green-300 ml-2" 
                                        onclick="openWalletModal({{ $user->id }}, '{{ $user->full_name }}')">
                                    Manage Wallet
                                </button>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8" class="px-4 py-6 text-center text-gray-500">No users found</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div class="mt-6">
        {{ $users->links() }}
    </div>
</div>

<!-- Wallet Management Modal -->
<div id="walletModal" class="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center z-50 hidden">
    <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 w-full max-w-md">
        <div class="flex justify-between items-center mb-4">
            <h3 class="text-xl font-bold glow-text" id="modalTitle">Manage Wallet</h3>
            <button onclick="closeWalletModal()" class="text-gray-400 hover:text-white">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>
        </div>
        
        <form id="walletForm" action="" method="POST">
            @csrf
            <div class="mb-4">
                <label class="block text-gray-300 mb-2">Wallet Type</label>
                <select name="wallet_type" class="form-select bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 w-full focus:outline-none focus:border-blue-500">
                    <option value="cash_wallet">Cash Wallet</option>
                    <option value="voucher_wallet">Voucher Wallet</option>
                    <option value="travel_wallet">Travel Wallet</option>
                    <option value="xlm_wallet">XLM Wallet</option>
                </select>
            </div>
            
            <div class="mb-4">
                <label class="block text-gray-300 mb-2">Operation</label>
                <select name="operation" class="form-select bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 w-full focus:outline-none focus:border-blue-500">
                    <option value="add">Add Funds</option>
                    <option value="subtract">Subtract Funds</option>
                    <option value="set">Set Balance</option>
                </select>
            </div>
            
            <div class="mb-6">
                <label class="block text-gray-300 mb-2">Amount</label>
                <input type="number" name="amount" step="0.01" min="0" class="form-input bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 w-full focus:outline-none focus:border-blue-500" required>
            </div>
            
            <div class="flex justify-end">
                <button type="button" onclick="closeWalletModal()" class="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded-lg mr-2">Cancel</button>
                <button type="submit" class="bg-blue-600 hover:bg-blue-500 text-white px-4 py-2 rounded-lg">Update Wallet</button>
            </div>
        </form>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Search functionality for traders
    const searchTraders = document.getElementById('searchTraders');
    const tradersTable = document.getElementById('tradersTable');
    const traderRows = tradersTable ? tradersTable.querySelectorAll('tr') : [];
    
    if (searchTraders) {
        searchTraders.addEventListener('keyup', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            
            traderRows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    }
    
    // Search functionality for users
    const searchUsers = document.getElementById('searchUsers');
    const usersTable = document.getElementById('usersTable');
    const userRows = usersTable ? usersTable.querySelectorAll('tr') : [];
    
    if (searchUsers) {
        searchUsers.addEventListener('keyup', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            
            userRows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    }
    
    // Wallet modal functionality
    function openWalletModal(userId, userName) {
        document.getElementById('modalTitle').textContent = `Manage ${userName}'s Wallet`;
        document.getElementById('walletForm').action = `/admin/users/${userId}/update-wallet`;
        document.getElementById('walletModal').classList.remove('hidden');
    }
    
    function closeWalletModal() {
        document.getElementById('walletModal').classList.add('hidden');
    }
    
    // Close modal when clicking outside
    window.addEventListener('click', function(e) {
        const modal = document.getElementById('walletModal');
        if (e.target === modal) {
            closeWalletModal();
        }
    });
</script>
@endsection
