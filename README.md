# 🚀 Docker Database Setup Script

This script automates the creation of a PostgreSQL database and user inside a running Docker container. It ensures the database and user are properly set up with the required permissions.

## 📌 Prerequisites

### 🐳 Running PostgreSQL in Docker

If you don't have a running PostgreSQL container, you can start one using the following `docker-compose.yml`:

```yaml
services:
  postgres:
    image: postgres:16
    container_name: trading-postgres
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=admin
      - PGDATA=/data/postgres
    ports:
      - 5432:5432
```

Run the following command to start PostgreSQL:

```sh
docker compose up -d
```

Ensure that the container name matches the one you use when running the setup script.


- Docker must be installed and running.
- A PostgreSQL container should already be running.
- You need the container name, a superuser account, and the credentials for the new database and user.

## 📝 Usage

Run the script with the following parameters:

```sh
./docker-setup-database.sh -n [container_name] -u [super_user] -b [database_name] -U [new_user] -P [new_password]
```

Alternatively, you can use the long-form options:

```sh
./docker-setup-database.sh --container [container_name] --superuser [super_user] --database [database_name] --newuser [new_user] --password [new_password]
```

### Example

```sh
./docker-setup-database.sh -n trading-postgres -u postgres -b trading -U trader -P securepassword
```

## 🛠 Parameters

| Short Flag | Long Flag | Description |
|-----------|----------|-------------|
| `-n` | `--container` | Name of the running PostgreSQL container |
| `-u` | `--superuser` | Superuser name (e.g., `postgres`) |
| `-b` | `--database` | Name of the database to create |
| `-U` | `--newuser` | Username for the new database user |
| `-P` | `--password` | Password for the new database user |

## 🛠 What the Script Does

1. Checks if all required parameters are provided.
2. Verifies that the specified container is running.
3. Checks if the database already exists:
   - If it exists, logs a message and exits.
   - If not, it creates the database.
4. Creates the new user with the specified password.
5. Grants necessary privileges to the new user.
6. Confirms successful execution.

## 🏭 Example Output

```sh
Checking if database 'trading' exists...
Database does not exist. Creating...
Database 'trading' created successfully.
Creating user 'trader'...
User 'trader' created and granted privileges.
Setup complete! 🎉
```

## ❗ Notes

- Ensure that the container name matches the actual PostgreSQL container name.
- If the database or user already exists, the script will log a message and avoid unnecessary re-creation.
- Use strong passwords for database users.
- You can provide parameters using either short flags (e.g., `-n`) or long-form options (e.g., `--container`).

## 📝 License

This script is provided as-is, without warranty. Use it at your own risk.

