@extends('layouts.admin')

@section('title', 'User Management - MTI Admin')

@section('header', 'User Management')

@section('content')
<div class="card p-6 rounded-xl mb-6">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
        <h3 class="text-xl font-bold glow-text mb-4 md:mb-0">All Users</h3>
        <div class="relative">
            <input type="text" id="searchInput" placeholder="Search users..." class="form-input bg-gray-900 border border-gray-700 rounded-lg px-4 py-2 w-full md:w-64 focus:outline-none focus:border-blue-500">
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
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Phone</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Ref Code</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-400 uppercase tracking-wider">Joined</th>
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
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-300">{{ $user->phonenumber }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm">
                            <span class="px-2 py-1 text-xs rounded-md bg-blue-900 bg-opacity-30 text-blue-300">
                                {{ $user->ref_code }}
                            </span>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-400">
                            {{ \Carbon\Carbon::parse($user->created_at)->format('M d, Y') }}
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm">
                            <a href="{{ route('admin.user.detail', $user->id) }}" class="text-blue-400 hover:text-blue-300">
                                View Details
                            </a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="px-4 py-6 text-center text-gray-500">No users found</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div class="mt-6">
        {{ $users->links() }}
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Simple search functionality
    const searchInput = document.getElementById('searchInput');
    const usersTable = document.getElementById('usersTable');
    const rows = usersTable.querySelectorAll('tr');
    
    searchInput.addEventListener('keyup', function(e) {
        const searchTerm = e.target.value.toLowerCase();
        
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
</script>
@endsection
