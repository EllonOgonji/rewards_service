# Rewards Service API

## Overview
The **Rewards Service** is a backend system built in Elixir and Phoenix that allows users to earn and redeem reward points. The points can be converted into virtual money (KSH) and stored in a virtual wallet.

This system is designed as a robust, scalable REST API that incorporates clean architecture, rate limiting, background job processing, caching, and API key authentication.

## Core Features
1. **User & Wallet Management**: Users are created with a secure API key and automatically assigned a virtual wallet.
2. **Earning Points**: Users can earn points based on specific criteria such as signups, referrals, and purchases.
3. **Redeeming Points**: Users can redeem their accumulated points for KSH credit in their virtual wallet (1 point = 0.5 KSH).
4. **Transaction History**: The system maintains a complete audit trail of all "earn" and "redeem" transactions.

## Technical Architecture & How It's Achieved

### 1. Technology Stack
* **Language**: Elixir
* **Framework**: Phoenix
* **Database**: PostgreSQL
* **ORM / Database Wrapper**: Ecto

### 2. Domain Contexts (Clean Architecture)
The business logic is divided into isolated contexts:
* **`RewardsService.Accounts`**: Manages users and API key hashing/authentication.
* **`RewardsService.Wallet`**: Manages wallet balances (points and KSH). Balances are cached using `Cachex` to reduce database load on frequent reads.
* **`RewardsService.Rewards`**: Orchestrates the earning and redeeming of points. It uses `Ecto.Multi` to ensure that transactions and wallet updates happen atomically (either both succeed or both fail).

### 3. API Management Concepts
* **API Key Authentication**: A custom Plug (`RewardsServiceWeb.Plugs.ApiKeyAuth`) intercepts requests, extracts the Bearer token, and validates it against the hashed API keys in the database.
* **Rate Limiting**: The `Hammer` library is used in a custom Plug (`RewardsServiceWeb.Plugs.RateLimiter`) to restrict users to 100 requests per minute, protecting the API from abuse.
* **Request Logging**: A custom plug (`RewardsServiceWeb.Plugs.RequestLogger`) tracks the execution time, path, method, and status of every incoming API request for monitoring and debugging.

### 4. Background Processing
The system uses **Oban** (backed by PostgreSQL) to handle asynchronous background jobs. For example, awarding points for certain actions can be queued as a background job (`RewardsService.Workers.PointsWorker`) so that the main API request doesn't block while points are being calculated and assigned.

### 5. Caching Strategy
**Cachex** is used to temporarily store users' wallet balances in memory. When a user earns or redeems points, the cache is automatically invalidated, ensuring the user always sees the correct balance while saving unnecessary trips to the database.

### 6. Deployment Readiness
The project is configured for easy production deployment using standard Docker/Containerized workflows (via `mix phx.gen.release` and the included `Dockerfile`). It is ready to be hosted on platforms like Fly.io, Render, or AWS.
