CREATE TABLE IF NOT EXISTS "migrations"(
  "id" integer primary key autoincrement not null,
  "migration" varchar not null,
  "batch" integer not null
);
CREATE TABLE IF NOT EXISTS "password_reset_tokens"(
  "email" varchar not null,
  "token" varchar not null,
  "created_at" datetime,
  primary key("email")
);
CREATE TABLE IF NOT EXISTS "sessions"(
  "id" varchar not null,
  "user_id" integer,
  "ip_address" varchar,
  "user_agent" text,
  "payload" text not null,
  "last_activity" integer not null,
  primary key("id")
);
CREATE INDEX "sessions_user_id_index" on "sessions"("user_id");
CREATE INDEX "sessions_last_activity_index" on "sessions"("last_activity");
CREATE TABLE IF NOT EXISTS "cache"(
  "key" varchar not null,
  "value" text not null,
  "expiration" integer not null,
  primary key("key")
);
CREATE TABLE IF NOT EXISTS "cache_locks"(
  "key" varchar not null,
  "owner" varchar not null,
  "expiration" integer not null,
  primary key("key")
);
CREATE TABLE IF NOT EXISTS "jobs"(
  "id" integer primary key autoincrement not null,
  "queue" varchar not null,
  "payload" text not null,
  "attempts" integer not null,
  "reserved_at" integer,
  "available_at" integer not null,
  "created_at" integer not null
);
CREATE INDEX "jobs_queue_index" on "jobs"("queue");
CREATE TABLE IF NOT EXISTS "job_batches"(
  "id" varchar not null,
  "name" varchar not null,
  "total_jobs" integer not null,
  "pending_jobs" integer not null,
  "failed_jobs" integer not null,
  "failed_job_ids" text not null,
  "options" text,
  "cancelled_at" integer,
  "created_at" integer not null,
  "finished_at" integer,
  primary key("id")
);
CREATE TABLE IF NOT EXISTS "failed_jobs"(
  "id" integer primary key autoincrement not null,
  "uuid" varchar not null,
  "connection" text not null,
  "queue" text not null,
  "payload" text not null,
  "exception" text not null,
  "failed_at" datetime not null default CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX "failed_jobs_uuid_unique" on "failed_jobs"("uuid");
CREATE TABLE IF NOT EXISTS "users"(
  "id" integer primary key autoincrement not null,
  "full_name" varchar not null,
  "email" varchar not null,
  "phonenumber" varchar not null,
  "address" text,
  "date_of_birth" date not null,
  "ref_code" varchar,
  "profile_image" varchar,
  "password" varchar not null,
  "remember_token" varchar,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "users_email_unique" on "users"("email");
CREATE UNIQUE INDEX "users_phonenumber_unique" on "users"("phonenumber");
CREATE TABLE IF NOT EXISTS "users_log"(
  "log_id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "column_name" varchar not null,
  "old_value" text,
  "new_value" text,
  "created_at" datetime not null default CURRENT_TIMESTAMP,
  foreign key("user_id") references "users"("id") on delete cascade
);
CREATE TABLE IF NOT EXISTS "admins"(
  "admin_id" integer primary key autoincrement not null,
  "username" varchar not null,
  "email" varchar not null,
  "password" varchar not null,
  "created_at" datetime not null default CURRENT_TIMESTAMP,
  "updated_at" datetime not null default CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX "admins_username_unique" on "admins"("username");
CREATE UNIQUE INDEX "admins_email_unique" on "admins"("email");
CREATE TABLE IF NOT EXISTS "otps"(
  "id" integer primary key autoincrement not null,
  "email" varchar not null,
  "otp" varchar not null,
  "type" varchar check("type" in('registration', 'password_reset', 'email_change')) not null default 'registration',
  "expires_at" datetime not null,
  "verified_at" datetime,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "otps_email_type_unique" on "otps"("email", "type");
CREATE INDEX "otps_email_index" on "otps"("email");

INSERT INTO migrations VALUES(1,'0001_01_01_000000_create_users_table',1);
INSERT INTO migrations VALUES(2,'0001_01_01_000001_create_cache_table',1);
INSERT INTO migrations VALUES(3,'0001_01_01_000002_create_jobs_table',1);
INSERT INTO migrations VALUES(4,'2024_05_01_000000_users_table',2);
INSERT INTO migrations VALUES(5,'2024_05_01_000001_create_users_log_table',2);
INSERT INTO migrations VALUES(6,'2024_05_01_000002_create_admins_table',2);
INSERT INTO migrations VALUES(7,'2025_05_11_032542_create_otps_table',3);
