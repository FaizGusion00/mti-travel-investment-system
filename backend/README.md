# MTI Admin Dashboard Backend

<p align="center">
  <img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="300" alt="Laravel Logo">
</p>

## About MTI Admin Dashboard

The MTI Admin Dashboard is a modern, beautiful visualization dashboard for the Meta Travel International MLM Platform. Built with Laravel 12, it provides a sleek, cosmic-themed interface for administrators to manage users and monitor system activity.

### Key Features

- **Secure Admin Authentication**: Dedicated admin table separate from regular users
- **Modern Dashboard**: Beautiful cosmic-themed UI with gold and blue accents
- **User Management**: View and manage all registered users
- **Activity Logs**: Track and visualize user activity
- **Interactive Charts**: Data visualization for user registrations and activity
- **Responsive Design**: Works seamlessly on all devices

## System Requirements

- PHP 8.2 or higher
- MySQL 8.0 or higher (running in Docker)
- Composer
- Node.js and NPM (for asset compilation)

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd mti-travel-investment/backend
```

### 2. Install Dependencies

```bash
composer install
```

### 3. Configure Environment

Copy the example environment file and modify it according to your setup:

```bash
cp .env.example .env
```

Update the following variables in your `.env` file:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mti_db
DB_USERNAME=mti_user
DB_PASSWORD=password

# Admin credentials
MTI_USER=admin@mti.com
MTI_PASSWORD=password
```

### 4. Generate Application Key

```bash
php artisan key:generate
```

### 5. Run Migrations

This will create all necessary database tables:

```bash
php artisan migrate
```

### 6. Start the Development Server

```bash
php artisan serve
```

The application will be available at `http://127.0.0.1:8000`.

## Docker MySQL Configuration

If you're using Docker for MySQL, ensure your container is running with the following configuration:

```bash
docker run --name mti-mysql -e MYSQL_ROOT_PASSWORD=your_root_password -e MYSQL_DATABASE=mti_db -p 3306:3306 -d mysql:8.0
```

Then update your `.env` file to connect to this Docker container:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mti_db
DB_USERNAME=root
DB_PASSWORD=your_root_password
```

## Database Structure

The application uses the following tables:

- **admins**: Stores admin user credentials for dashboard access
- **users**: Stores regular user information
- **users_log**: Tracks user activity and changes
- **sessions**: Manages user sessions

## Usage

1. Navigate to `http://127.0.0.1:8000` in your browser
2. Log in with the admin credentials set in your `.env` file
3. Access the dashboard to view statistics, manage users, and monitor activity logs

## Customization

### Styling

The dashboard uses Tailwind CSS for styling with custom variables for the cosmic theme:

- **Background**: Black, evoking the vastness of space
- **Accents**: Gold, symbolizing value and exclusivity
- **Titles/Fonts**: Blue with a subtle glow effect for a futuristic touch

You can modify these styles in the layout files located in `resources/views/layouts/`.

### Adding New Features

To extend the dashboard with new features:

1. Create new controllers in `app/Http/Controllers/`
2. Add routes in `routes/web.php`
3. Create view templates in `resources/views/`

## License

The MTI Admin Dashboard is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
