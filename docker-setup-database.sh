#!/bin/bash

set -euo pipefail # Exit on error, unset variable, or failed pipeline command

help_function() {
  echo -e "\n\033[1;32mUsage:\033[0m"
  echo -e "  $0 --container <container_name> --superuser <super_user> --database <database_name> --newuser <new_user> --password <new_password>\n"

  echo -e "\033[1;34mArguments:\033[0m"
  echo -e "  \033[1;33m-n, --container\033[0m   Name of the running PostgreSQL Docker container"
  echo -e "  \033[1;33m-u, --superuser\033[0m   PostgreSQL superuser (e.g., postgres)"
  echo -e "  \033[1;33m-b, --database\033[0m    Name of the new database"
  echo -e "  \033[1;33m-U, --newuser\033[0m     Name of the new database user"
  echo -e "  \033[1;33m-P, --password\033[0m    Password for the new database user\n"

  echo -e "\033[1;34mExample:\033[0m"
  echo -e "  $0 --container my_postgres --superuser postgres --database my_database --newuser new_user --password secretpass\n"

  echo -e "\033[1;31mNote:\033[0m Ensure the PostgreSQL container is running before executing this script."

  exit 1
}

# Ensure at least one argument is provided
if [[ $# -eq 0 ]]; then
  help_function
fi

# Initialize variables
container_name=""
super_user=""
database_name=""
new_user=""
new_password=""

# Parse both short and long options
while [[ $# -gt 0 ]]; do
  case "$1" in
  -n | --container)
    container_name="$2"
    shift 2
    ;;
  -u | --superuser)
    super_user="$2"
    shift 2
    ;;
  -b | --database)
    database_name="$2"
    shift 2
    ;;
  -U | --newuser)
    new_user="$2"
    shift 2
    ;;
  -P | --password)
    new_password="$2"
    shift 2
    ;;
  -h | --help)
    help_function
    ;;
  *)
    echo "❌ Error: Unknown option '$1'"
    help_function
    ;;
  esac
done

# Validate required arguments
if [[ -z "$container_name" || -z "$super_user" || -z "$database_name" || -z "$new_user" || -z "$new_password" ]]; then
  echo "❌ Error: Missing required arguments!"
  help_function
fi

# Check if the PostgreSQL container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
  echo "❌ Error: Container '$container_name' is not running!"
  exit 1
fi

echo "✅ Connecting to PostgreSQL container '$container_name'..."

# Check if the database already exists
db_exists=$(docker exec "$container_name" psql -U "$super_user" -d postgres -t -c "SELECT 1 FROM pg_database WHERE datname = '$database_name';" | tr -d '[:space:]')

if [[ "$db_exists" == "1" ]]; then
  echo "ℹ️  Database '$database_name' already exists. Skipping creation."
else
  echo "🛠️  Creating database: '$database_name'"
  docker exec "$container_name" psql -U "$super_user" -d postgres -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"$database_name\";"
fi

# Check if the user already exists
user_exists=$(docker exec "$container_name" psql -U "$super_user" -d postgres -t -c "SELECT 1 FROM pg_roles WHERE rolname = '$new_user';" | tr -d '[:space:]')

if [[ "$user_exists" == "1" ]]; then
  echo "ℹ️  User '$new_user' already exists. Skipping creation."
else
  echo "👤 Creating user: '$new_user'"
  docker exec "$container_name" psql -U "$super_user" -d postgres -v ON_ERROR_STOP=1 -c "CREATE USER \"$new_user\" WITH PASSWORD '$new_password';"
fi

# Assign privileges to the new user
echo "🔑 Assigning user '$new_user' to database '$database_name'"
docker exec "$container_name" psql -U "$super_user" -d postgres -v ON_ERROR_STOP=1 -c "ALTER DATABASE \"$database_name\" OWNER TO \"$new_user\";"
docker exec "$container_name" psql -U "$super_user" -d postgres -v ON_ERROR_STOP=1 -c "GRANT ALL PRIVILEGES ON DATABASE \"$database_name\" TO \"$new_user\";"

echo "🎉 Database '$database_name' and user '$new_user' setup completed!"
