# Delivery Dispatcher App

A proof-of-concept Flutter app for managing a single day's deliveries for multiple drivers. Built with a clean architecture (data, domain, presentation layers) for maintainability and scalability, it focuses on state management, business logic, and local persistence.

## Features

### Orders Hub
- Filterable list of orders with details (items, customer location, weight/volume, COD amount).

### Trip Planner
- Create and assign orders to trips.
- Displays:
  - **Capacity Utilization**: Progress bar for vehicle weight/volume usage.
  - **Total COD**: Sum of COD amounts per trip.

### Trip Execution
- Driver interface for stop-by-stop execution.
- Enforces state transitions: `Pending` → `In Transit` → `Completed` / `Failed`.
- Clear feedback for blocked actions (e.g., COD shortfall, partial delivery).

### Persistence
- Uses Hive for automatic state persistence, restoring the exact state on relaunch.

### Map Overview
- Static map view (using `flutter_map`) showing depot and stops in sequence.

## Business Rules

- **State Machine**: Strict transitions for stop statuses:
  | From         | To `In Transit` | To `Completed` | To `Failed` |
  | :----------- | :-------------: | :------------: | :---------: |
  | `Pending`    | ✅              | ❌             | ✅          |
  | `In Transit` | ❌              | ✅             | ✅          |
  | `Completed`  | ❌              | ❌             | ❌          |
  | `Failed`     | ❌              | ❌             | ❌          |
- **COD Accuracy**: Verifies collected cash; shortfalls blocked, $1.00 over-collection allowed.
- **Partial Delivery**: Forbidden for `isDiscounted: true` orders.
- **Timezone**: Handles `planDate` in `Asia/Dubai` timezone.
- **Capacity**: Uses effective capacity (`max_capacity * fillRate`).
- **Serial Numbers**: Requires unique serials for `serialTracked` items with `quantity > 1`.

## Tech Stack

- **Flutter**: UI and app framework.
- **Clean Architecture**: Organized into `data`, `domain`, and `presentation` layers per feature.
- **Packages**:
  - `flutter_bloc`: State management.
  - `hive_ce`, `hive_ce_flutter`: Local persistence.
  - `flutter_map`, `latlong2`: Static map rendering.
  - `intl`: Timezone-aware date handling.
  - `get_it`: Dependency injection.
  - `equatable`: Value comparison.
  - `flutter_animate`: UI animations.
  - `google_fonts`: Typography.
  - `collection`, `cupertino_icons`: Utilities.
  - `timezone`: Timezone handling.

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd delivery-dispatcher