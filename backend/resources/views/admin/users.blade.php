@extends('layouts.admin')

@section('title', 'User Management - MTI Admin')

@section('header', 'User Management')

@section('content')
<div class="card bg-gray-900 shadow-lg p-6 rounded-xl mb-6 border border-gray-800">
    <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6">
        <h3 class="text-xl font-bold text-yellow-400 mb-4 md:mb-0">All Users</h3>
        <div class="flex flex-col sm:flex-row gap-4">
            <div class="relative">
                <input type="text" id="searchInput" placeholder="Search users..." class="form-input bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 w-full md:w-64 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:border-transparent transition">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 absolute right-3 top-2.5" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd" />
                </svg>
            </div>
            <button id="exportCsv" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 inline-block mr-1" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M3 17a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm3.293-7.707a1 1 0 011.414 0L9 10.586V3a1 1 0 112 0v7.586l1.293-1.293a1 1 0 111.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
                Export
            </button>
        </div>
    </div>
    
    <div class="overflow-x-auto rounded-lg border border-gray-800 shadow">
        <table class="w-full">
            <thead>
                <tr class="bg-gray-800">
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">ID</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Name</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Email</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Phone</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Ref Code</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Joined</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Trader</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Status</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">USDT Address</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody id="usersTable">
                @forelse($users as $user)
                    <tr class="table-row border-b border-gray-800 hover:bg-gray-800 transition-all">
                        <td class="px-4 py-4 whitespace-nowrap text-sm">{{ $user->id }}</td>
                        <td class="px-4 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="h-10 w-10 rounded-full flex items-center justify-center mr-3 overflow-hidden bg-gradient-to-r from-blue-500 to-purple-600">
                                    @if($user->profile_image)
                                        <img src="{{ asset('storage/'.$user->profile_image) }}" 
                                             alt="{{ $user->full_name }}" 
                                             class="h-full w-full object-cover"
                                             onerror="this.onerror=null; this.src='{{ asset('storage/avatars/default.png') }}'; this.classList.add('fallback-image')">
                                    @else
                                        <span class="font-bold text-xs text-white">{{ substr($user->full_name, 0, 1) }}</span>
                                    @endif
                                </div>
                                <span class="text-sm font-medium">{{ $user->full_name }}</span>
                            </div>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-300">{{ $user->email }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-300">{{ $user->phonenumber }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm">
                            <span class="px-2 py-1 text-xs rounded-md bg-gradient-to-r from-blue-900 to-indigo-900 text-blue-300 border border-blue-700">
                                {{ $user->affiliate_code ?? '--' }}
                            </span>
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-400">
                            {{ \Carbon\Carbon::parse($user->created_at)->format('M d, Y') }}
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-center">
                            @if($user->is_trader)
                                <span class="px-2 py-1 text-xs rounded-md bg-green-900 text-green-300 border border-green-700">Yes</span>
                            @else
                                <span class="px-2 py-1 text-xs rounded-md bg-gray-700 text-gray-300 border border-gray-600">No</span>
                            @endif
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-center">
                            @if($user->status == 'approved')
                                <span class="px-2 py-1 text-xs rounded-md bg-green-900 text-green-300 border border-green-700">Approved</span>
                            @else
                                <span class="px-2 py-1 text-xs rounded-md bg-yellow-900 text-yellow-300 border border-yellow-700">Pending</span>
                            @endif
                        </td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm text-gray-300 truncate max-w-[150px]">{{ $user->usdt_address }}</td>
                        <td class="px-4 py-4 whitespace-nowrap text-sm">
                            <div class="flex gap-2">
                                <button class="edit-btn bg-yellow-500 hover:bg-yellow-600 text-gray-900 font-bold px-2 py-1 rounded focus:outline-none focus:ring-2 focus:ring-yellow-400 transition" data-id="{{ $user->id }}">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                                        <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                                    </svg>
                                </button>
                                <button class="delete-btn bg-red-500 hover:bg-red-600 text-white font-bold px-2 py-1 rounded focus:outline-none focus:ring-2 focus:ring-red-400 transition" data-id="{{ $user->id }}" data-name="{{ $user->full_name }}" @if(auth()->id() == $user->id || $user->id == 1) disabled class="opacity-50 cursor-not-allowed" @endif>
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                                        <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
                                    </svg>
                                </button>
                                <a href="{{ route('admin.user.detail', $user->id) }}" class="bg-blue-500 hover:bg-blue-600 text-white px-2 py-1 rounded focus:outline-none focus:ring-2 focus:ring-blue-400 transition">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                                        <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                                        <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
                                    </svg>
                                </a>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="10" class="px-4 py-6 text-center text-gray-500">No users found</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
    
    <div class="mt-6">
        {{ $users->links() }}
    </div>
</div>

<!-- Edit User Modal -->
<div id="editUserModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-70">
    <div class="bg-gray-900 rounded-xl p-8 w-full max-w-2xl mx-auto relative shadow-2xl border-2 border-yellow-400">
        <button id="closeEditModal" class="absolute top-3 right-3 text-gray-400 hover:text-gray-200 text-2xl">&times;</button>
        <h2 class="text-2xl font-bold mb-6 text-yellow-400">Edit User</h2>
        <form id="editUserForm" class="space-y-4">
            <input type="hidden" name="user_id" id="editUserId">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Full Name</label>
                    <input type="text" name="full_name" id="editFullName" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Username <span class="text-xs text-gray-500">(Optional - leave empty if unsure)</span></label>
                    <input type="text" name="username" id="editUsername" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent" placeholder="Username or leave empty">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Email</label>
                    <input type="email" name="email" id="editEmail" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Phone</label>
                    <input type="text" name="phonenumber" id="editPhone" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Date of Birth</label>
                    <input type="date" name="date_of_birth" id="editDob" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Reference Code</label>
                    <input type="text" name="reference_code" id="editRefCode" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Affiliate Code</label>
                    <input type="text" name="affiliate_code" id="editAffiliateCode" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Referral ID</label>
                    <input type="text" name="referral_id" id="editReferralId" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">USDT Address</label>
                    <input type="text" name="usdt_address" id="editUsdtAddress" class="form-input w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Trader</label>
                    <select name="is_trader" id="editIsTrader" class="form-select w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                        <option value="0">No</option>
                        <option value="1">Yes</option>
                    </select>
                </div>
                <div>
                    <label class="block text-gray-300 text-sm font-medium mb-1">Status</label>
                    <select name="status" id="editStatus" class="form-select w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent">
                        <option value="pending">Pending</option>
                        <option value="approved">Approved</option>
                    </select>
                </div>
                <div class="md:col-span-2">
                    <label class="block text-gray-300 text-sm font-medium mb-1">Address</label>
                    <textarea name="address" id="editAddress" rows="2" class="form-textarea w-full bg-gray-800 border border-gray-700 rounded-lg px-4 py-2 text-white focus:ring-2 focus:ring-yellow-400 focus:border-transparent"></textarea>
                </div>
                <div class="md:col-span-2 flex items-center gap-4">
                    <div>
                        <label class="block text-gray-300 text-sm font-medium mb-1">Profile Image</label>
                        <div class="flex items-center space-x-4">
                            <img id="editProfileImagePreview" src="" alt="Profile Image" class="h-16 w-16 rounded-full border border-gray-700 object-cover mb-2">
                            <div class="flex-1">
                                <input type="file" name="profile_image" id="editProfileImage" accept="image/*" class="hidden">
                                <label for="editProfileImage" class="cursor-pointer bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg inline-block transition">
                                    Change Image
                                </label>
                                <p class="text-xs text-gray-400 mt-1">Click to select a new profile image</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="editError" class="text-red-400 text-sm mt-2 hidden bg-red-900 bg-opacity-30 rounded-lg p-2 border border-red-600"></div>
            <div class="flex justify-end mt-6 space-x-3">
                <button type="button" id="closeEditBtn" class="bg-gray-700 hover:bg-gray-600 text-white px-6 py-2 rounded-lg shadow transition">Cancel</button>
                <button type="submit" class="bg-gradient-to-r from-yellow-400 to-yellow-600 hover:from-yellow-500 hover:to-yellow-700 text-gray-900 font-bold px-8 py-2 rounded-lg shadow transition">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteUserModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black bg-opacity-70">
    <div class="bg-gray-900 rounded-xl p-8 w-full max-w-md mx-auto relative shadow-2xl border-2 border-red-500">
        <button id="closeDeleteModal" class="absolute top-3 right-3 text-gray-400 hover:text-gray-200 text-2xl">&times;</button>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16 text-red-500 mx-auto mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
        <h2 class="text-xl font-bold mb-4 text-red-400 text-center">Delete User</h2>
        <p class="mb-6 text-gray-300 text-center">Are you sure you want to delete <span id="deleteUserName" class="font-bold text-white"></span>? This action cannot be undone.</p>
        <div class="flex justify-center gap-4">
            <button id="cancelDeleteBtn" class="bg-gray-700 hover:bg-gray-600 text-gray-200 px-5 py-2 rounded-lg transition">Cancel</button>
            <button id="confirmDeleteBtn" class="bg-gradient-to-r from-red-500 to-red-700 hover:from-red-600 hover:to-red-800 text-white font-bold px-6 py-2 rounded-lg shadow transition">Delete</button>
        </div>
    </div>
</div>

<!-- Toast Notification -->
<div id="toast" class="fixed bottom-6 right-6 z-50 hidden px-6 py-4 rounded-lg font-bold shadow-lg transform transition-all duration-300"></div>
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

    // Helper: Show toast
    function showToast(message, type = 'success') {
        const toast = document.getElementById('toast');
        toast.textContent = message;
        toast.className = `fixed bottom-6 right-6 z-50 px-6 py-4 rounded-lg font-bold ${type === 'success' ? 'bg-green-600 text-white' : 'bg-red-600 text-white'} show`;
        toast.style.display = 'block';
        setTimeout(() => { toast.style.display = 'none'; }, 3000);
    }

    // Edit Modal Logic
    const editModal = document.getElementById('editUserModal');
    const closeEditModal = document.getElementById('closeEditModal');
    const editUserForm = document.getElementById('editUserForm');
    let currentEditId = null;

    document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', async function() {
            try {
                const userId = this.dataset.id;
                currentEditId = userId;
                document.getElementById('editUserId').value = userId;
                document.getElementById('editError').classList.add('hidden');
                
                // Show loading state
                showToast('Loading user data...', 'info');
                
                // Fetch user directly from the table row
                const row = this.closest('tr');
                const fullName = row.querySelector('td:nth-child(2)').textContent.trim();
                const email = row.querySelector('td:nth-child(3)').textContent.trim();
                const phone = row.querySelector('td:nth-child(4)').textContent.trim();
                const refCode = row.querySelector('td:nth-child(5)').textContent.trim();
                
                // Fill form with data we have
                document.getElementById('editFullName').value = fullName;
                document.getElementById('editUsername').value = '';  // Default to empty
                document.getElementById('editEmail').value = email;
                document.getElementById('editPhone').value = phone;
                document.getElementById('editRefCode').value = refCode;
                document.getElementById('editAffiliateCode').value = refCode;
                document.getElementById('editReferralId').value = '';
                
                // Try to fetch more user details including username
                try {
                    const response = await fetch(`/admin/users/${userId}`, {
                        method: 'GET',
                        headers: {
                            'Accept': 'text/html',
                            'X-Requested-With': 'XMLHttpRequest',
                            'X-CSRF-TOKEN': '{{ csrf_token() }}'
                        }
                    });
                    
                    if (response.ok) {
                        // We can't easily parse the HTML response, so we'll extract username 
                        // and other details from user DB separately
                        
                        // Temp solution: Try to match the username from the name (usernames often match names)
                        // or just leave blank for admin to fill in
                        const usernameGuess = fullName.toLowerCase().replace(/\s+/g, '');
                        document.getElementById('editUsername').value = usernameGuess;
                    }
                } catch (error) {
                    console.warn('Could not fetch additional user details:', error);
                }
                
                // Set trader status based on the badge in the table
                const traderBadge = row.querySelector('td:nth-child(7) span');
                document.getElementById('editIsTrader').value = traderBadge && traderBadge.textContent.trim().toLowerCase() === 'yes' ? '1' : '0';
                
                // Set status based on the badge in the table
                const statusBadge = row.querySelector('td:nth-child(8) span');
                document.getElementById('editStatus').value = statusBadge && statusBadge.textContent.trim().toLowerCase() === 'approved' ? 'approved' : 'pending';
                
                // Set USDT address
                const usdtCell = row.querySelector('td:nth-child(9)');
                document.getElementById('editUsdtAddress').value = usdtCell ? usdtCell.textContent.trim() : '';
                
                // Default empty values for fields we don't have
                document.getElementById('editDob').value = '';
                document.getElementById('editAddress').value = '';
                
                // Try to get profile image URL
                const imgElement = row.querySelector('td:nth-child(2) img');
                const defaultImagePath = '/storage/avatars/default.png';
                
                if (imgElement && imgElement.src) {
                    document.getElementById('editProfileImagePreview').src = imgElement.src;
                } else {
                    // Fallback to initials or default image
                    document.getElementById('editProfileImagePreview').src = defaultImagePath;
                }
                
                // Add error handler for the profile image preview
                document.getElementById('editProfileImagePreview').onerror = function() {
                    this.onerror = null;
                    this.src = defaultImagePath;
                };
                
                // Show modal
                editModal.classList.remove('hidden');
                editModal.classList.add('flex');
                showToast('User data loaded successfully', 'success');
            } catch (error) {
                console.error('Error preparing edit form:', error);
                showToast('Failed to prepare edit form: ' + error.message, 'error');
            }
        });
    });
    
    closeEditModal.onclick = () => { 
        editModal.classList.add('hidden');
        editModal.classList.remove('flex');
    };

    // Profile image preview functionality
    document.getElementById('editProfileImage').addEventListener('change', function(e) {
        if (this.files && this.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('editProfileImagePreview').src = e.target.result;
            }
            reader.readAsDataURL(this.files[0]);
        }
    });

    editUserForm.onsubmit = async function(e) {
        e.preventDefault();
        
        try {
            const id = document.getElementById('editUserId').value;
            const formData = new FormData(this);
            
            // Show updating message
            showToast('Updating user...', 'info');
            document.getElementById('editError').classList.add('hidden');
            
            // Handle empty username field - either null it or create from full name
            const usernameField = document.getElementById('editUsername');
            if (!usernameField.value.trim()) {
                // Option 1: Set it to null
                formData.delete('username');
                
                // Option 2: Generate from name (choose one approach)
                // const fullName = document.getElementById('editFullName').value;
                // if (fullName) {
                //     formData.set('username', fullName.toLowerCase().replace(/\s+/g, ''));
                // }
            }
            
            // Add missing field if empty in form but exists in DB
            if (!formData.has('is_trader')) {
                formData.append('is_trader', '0');
            }
            
            // Clear empty date field to prevent validation errors
            if (formData.get('date_of_birth') === '') {
                formData.delete('date_of_birth');
            }
            
            // Use the web route for updating users
            const response = await fetch(`/admin/users/${id}/update`, {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                    'X-Requested-With': 'XMLHttpRequest',
                    'Accept': 'application/json'
                    // Note: Don't set Content-Type with FormData
                },
                body: formData
            });
            
            const result = await response.json();
            
            if (result.status === 'success') {
                showToast('User updated successfully!');
                setTimeout(() => { location.reload(); }, 1200);
            } else {
                // Handle validation errors or other error messages
                let errorMsg = result.message || 'Update failed';
                
                // Check if we have validation errors and format them
                if (result.errors) {
                    errorMsg += ':<ul class="list-disc ml-4 mt-2">';
                    for (const field in result.errors) {
                        if (result.errors.hasOwnProperty(field)) {
                            errorMsg += `<li>${result.errors[field].join(', ')}</li>`;
                        }
                    }
                    errorMsg += '</ul>';
                }
                
                document.getElementById('editError').innerHTML = errorMsg;
                document.getElementById('editError').classList.remove('hidden');
                showToast('Update failed. Please check the errors.', 'error');
            }
        } catch (error) {
            console.error('Error updating user:', error);
            document.getElementById('editError').textContent = 'Update failed: ' + error.message;
            document.getElementById('editError').classList.remove('hidden');
            showToast('Update failed: ' + error.message, 'error');
        }
    };

    // Delete Modal Logic
    const deleteModal = document.getElementById('deleteUserModal');
    const closeDeleteModal = document.getElementById('closeDeleteModal');
    const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    let currentDeleteId = null;

    document.querySelectorAll('.delete-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            if (this.disabled) return;
            currentDeleteId = this.dataset.id;
            document.getElementById('deleteUserName').textContent = this.dataset.name;
            deleteModal.classList.remove('hidden');
            deleteModal.classList.add('flex');
        });
    });
    
    closeDeleteModal.onclick = cancelDeleteBtn.onclick = () => { 
        deleteModal.classList.add('hidden');
        deleteModal.classList.remove('flex');
    };

    confirmDeleteBtn.onclick = async function() {
        try {
            // Show deleting message
            showToast('Deleting user...', 'info');
            
            const response = await fetch(`/admin/users/${currentDeleteId}/delete`, {
                method: 'POST',
                headers: { 
                    'X-CSRF-TOKEN': '{{ csrf_token() }}',
                    'X-Requested-With': 'XMLHttpRequest',
                    'Accept': 'application/json'
                }
            });
            
            const result = await response.json();
            
            if (result.status === 'success') {
                showToast('User deleted successfully!');
                // Hide modal
                deleteModal.classList.add('hidden');
                setTimeout(() => { location.reload(); }, 1200);
            } else {
                showToast(result.message || 'Delete failed', 'error');
            }
        } catch (error) {
            console.error('Error deleting user:', error);
            showToast('Delete failed: ' + error.message, 'error');
        }
    };

    // Export to CSV functionality
    document.getElementById('exportCsv').addEventListener('click', async function() {
        try {
            showToast('Preparing CSV export...', 'info');
            
            // Get all users - use the current page URL but increase pagination size
            const currentUrl = new URL(window.location.href);
            currentUrl.searchParams.set('per_page', '1000');
            
            const response = await fetch(currentUrl.toString(), {
                method: 'GET',
                headers: {
                    'Accept': 'text/html',
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': '{{ csrf_token() }}'
                }
            });
            
            if (!response.ok) {
                throw new Error('Failed to fetch users for export');
            }
            
            // Extract user data from the table
            const userRows = document.querySelectorAll('#usersTable tr:not(:first-child)');
            const users = [];
            
            userRows.forEach(row => {
                if (row.cells && row.cells.length > 0) {
                    const user = {
                        id: row.cells[0]?.textContent.trim() || '',
                        full_name: row.cells[1]?.textContent.trim() || '',
                        email: row.cells[2]?.textContent.trim() || '',
                        phonenumber: row.cells[3]?.textContent.trim() || '',
                        affiliate_code: row.cells[4]?.textContent.trim() || '',
                        created_at: row.cells[5]?.textContent.trim() || '',
                        is_trader: row.cells[6]?.textContent.includes('Yes') ? 'Yes' : 'No',
                        status: row.cells[7]?.textContent.includes('Approved') ? 'approved' : 'pending',
                        usdt_address: row.cells[8]?.textContent.trim() || ''
                    };
                    users.push(user);
                }
            });
            
            if (users.length === 0) {
                throw new Error('No users found to export');
            }
            
            // Define CSV headers
            const headers = [
                'ID', 'Full Name', 'Email', 'Phone', 
                'Affiliate Code', 'Joined Date', 'Is Trader', 'Status',
                'USDT Address'
            ];
            
            // Convert users to CSV rows
            const csvRows = [];
            csvRows.push(headers.join(','));
            
            for (const user of users) {
                const row = [
                    user.id,
                    `"${(user.full_name || '').replace(/"/g, '""')}"`, // Escape quotes
                    `"${(user.email || '').replace(/"/g, '""')}"`,
                    `"${(user.phonenumber || '').replace(/"/g, '""')}"`,
                    `"${(user.affiliate_code || '').replace(/"/g, '""')}"`,
                    `"${(user.created_at || '').replace(/"/g, '""')}"`,
                    user.is_trader,
                    `"${(user.status || '').replace(/"/g, '""')}"`,
                    `"${(user.usdt_address || '').replace(/"/g, '""')}"`
                ];
                
                csvRows.push(row.join(','));
            }
            
            // Create CSV content
            const csvContent = csvRows.join('\n');
            
            // Create a blob and download
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            
            link.setAttribute('href', url);
            link.setAttribute('download', `users_export_${new Date().toISOString().split('T')[0]}.csv`);
            link.style.visibility = 'hidden';
            
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            showToast('CSV export complete!', 'success');
        } catch (error) {
            console.error('Export error:', error);
            showToast('Export failed: ' + error.message, 'error');
        }
    });

    // Add closeEditBtn handler
    if (document.getElementById('closeEditBtn')) {
        document.getElementById('closeEditBtn').addEventListener('click', () => {
            editModal.classList.add('hidden');
            editModal.classList.remove('flex');
        });
    }

    // Helper functions for consistent image path handling
    function getDefaultProfileImagePath() {
        return '/storage/avatars/default.png';
    }
    
    function handleImageError(img) {
        img.onerror = null;
        img.src = getDefaultProfileImagePath();
        img.classList.add('fallback-image');
    }
    
    // Add global error handler for all profile images
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('img[src*="profile_image"], img[src*="avatars"]').forEach(img => {
            img.onerror = function() {
                handleImageError(this);
            };
        });
    });
</script>
@endsection
