# Meta Travel International MLM Platform - Phase 1

## 1. Introduction:

The Meta Travel International E-Komuniti platform is a sophisticated multi-level marketing (MLM) system that empowers users with a travel rewards ecosystem. Built on a unilevel compensation structure, it integrates referral bonuses, XLM staking, wallet management, and travel package redemption to create a seamless and rewarding user experience.

## 2. Purpose:

To develop a robust MLM platform where users can:

- Register and authenticate securely.
- Earn commissions through referrals across five levels.
- Stake XLM coins and track rewards.
- Manage wallets for cash, travel, XLM, and bonus balances.
- Redeem travel packages and participate in mystery draws.

## 3. Technical Stack:

### Backend
- **Laravel 12**: Robust MVC framework with built-in authentication and ecosystem support.
- **MySQL**: Reliable, scalable relational database.
- **Docker**: Ensures consistent environments via containerization.

### Frontend

#### Mobile App:
- **Flutter** – Cross-platform app development for iOS and Android with native performance and flexibility.
- **Purpose**: Main frontend app.

#### Web (Landing Site):
- **Next.js 15** – Static and server-rendered React framework.
- **Tailwind CSS** – Utility-first CSS framework for fast, modern design.
- **Purpose**: Minimal marketing page guiding users to download the app.

### Authentication
- **Laravel Sanctum**: Secure cookie and token-based API authentication.

## 4. Phase 1 Features (2 weeks):

- Database
- API (Purpose: to link backend and frontend)
- Registration Page
- Captcha
- Email Verification
- Login Page
- Home Page
- Profile Page
- Network Page

## 5. UI/UX Design:

The design reflects a premium, cosmic aesthetic inspired by the galaxy.

### - Language: English only.
### - Theme
- **Background**: Black, evoking the vastness of space.
- **Accents**: Gold, symbolizing value and exclusivity.
- **Titles/Fonts**: Blue with a subtle glow effect for a futuristic touch.

### - Typography
- **Headings**: Bold sans-serif with glow on blue text.
- **Body Text**: Clean, readable sans-serif in white or light gray.

### - Network Page Layout
- **Structure**: Upline node at the top, downlines fanning out below in a tree format.
- **Nodes**: Gold-bordered cards with subtle shadows and hover effects displaying user ID, name, and downline count.

## 6. User Registration Rule:

### 🔐 Registration Fields
- **Profile Picture**: Optional; stored as a URL in `profiles.avatar_url`.
- **Full Name**: Mandatory for identity.
- **Email**: Required and must be unique.
- **Phone Number**: Required and must be unique.
- **Date of Birth**: Mandatory; user must be at least 18 years old.
- **Reference Code**: Optional; defaults to a company root user (ID 1) if left blank.
- **Captcha**: Uses Cloudflare Turnstile to prevent automated signups.

### 🔐 Registration Process
- The user submits the registration form with captcha verification.
- The system performs validation:
    - Confirms the user is 18 years or older.
    - Ensures the email and phone number are not already in use.
    - Verifies the reference code if one is provided.
- If no valid reference code is submitted, the user is assigned to the default referrer (user ID 1).
- A 6-digit OTP is sent to the user's email for verification.
- Upon OTP confirmation:
    - The user account is created.
    - A unique, auto-generated referral code is assigned to the new user.

## 7. Profile Page Rule:

Users can manage and update their profile details while ensuring key security checks are in place.

### ✏️ Editable Profile Fields
- **Full Name**
- **Email Address**: Changes require OTP email verification.
- **Phone Number**
- **Referral Code**: Auto-generated (6-character alphanumeric); can be edited if it contains at least 3 letters and is unique.
- **USDT BEP-20 Wallet Address**
- **Residential Address**

### ✅ Validation Rules
- All updates undergo server-side validation for uniqueness and proper format.
- Changes to sensitive fields like email trigger a confirmation process via email to ensure security.
