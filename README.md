# Prospex CRM

A modern CRM and portfolio‑tracking platform built with **Ruby on Rails** for independent financial advisors in Argentina. Prospex streamlines lead capture, client onboarding, and real‑time portfolio monitoring so advisors can spend less time wrangling spreadsheets and more time serving clients.

---

## Why Prospex?

1. **Purpose‑built for advisors** – Track prospects, clients, portfolios, and holdings in one place.
2. **Real‑time data** – Live security prices via the *Data912* API, fetched in bulk and cached for speed.
3. **Team‑ready** – Granular roles (`admin`, `member`) and invite‑link onboarding for collaborative advisory teams.
4. **First‑class UX** – Hotwire (Turbo + Stimulus), ViewComponent, and TailwindCSS deliver a snappy, SPA‑like experience with minimal JavaScript.

---

## Feature Overview

| Module | Highlights |
| --- | --- |
| **Leads** | Custom public lead forms (unique URLs per advisor), Kanban‑style pipeline, one‑click *Convert to Client*. |
| **Clients** | Rich contact records, timeline notes, relationship insights. |
| **Portfolios & Holdings** | Multi‑currency support, bulk price lookup, profit/loss analytics, per‑holding metrics. |
| **Securities** | Dedicated model with `security_prices` table; supports stocks, bonds, ETFs, ADRs, CEDEARs & more. |
| **Teams & Roles** | Single‑team tenancy per admin, members inherit access; Pundit policies enforce permissions. |
| **Authentication** | Devise with Google OmniAuth SSO; magic‑link invitations for frictionless signup. |
| **Config & Secrets** | Figaro‑based ENV management (`config/application.yml`). |

---

## Tech Stack

- **Ruby** 3.3  |  **Rails** 7.2
- **PostgreSQL** 15
- **Hotwire** (Turbo Frames/Streams, Stimulus JS)
- **ViewComponent** (UI components)
- **Tailwind CSS** utility‑first styling
- **Devise & OmniAuth‑Google** authentication
- **RSpec** & FactoryBot testing

---

## 🛠️ Getting Started

### Prerequisites

| Tool | Version |
| --- | --- |
| Ruby | 3.3.0 |
| PostgreSQL | ≥ 14 |
| Redis | ≥ 6 |
| Node & Yarn | Current LTS |

### Installation

```bash
# 1. Clone the repo
$ git clone https://github.com/owen-makes/crm-project.git
$ cd prospex-crm

# 2. Install dependencies
$ bundle install

# 3. Set environment variables (Figaro)
$ bundle exec figaro install
# edit config/application.yml with your keys

# 4. Set up database & seed data
$ rails db:create db:migrate db:seed

# 5. Start the app (Rails + Tailwind + JS bundler)
$ bin/dev
# app: http://localhost:3000
```

### Running Tests

```bash
bundle exec rspec
```

### Linting & Formatting

```bash
bundle exec rubocop -A
```

---

## 🔍 Domain Model (simplified)

```
User (role: enum) ──┐
                   │ manages / belongs_to
Team ──────────────┘

Lead  →  Client
  \         \
   \         +── Portfolios ──┐
    \                          │ has_many
     +── Notes                 │
                               +── Holdings → Security ↔ SecurityPrice
```

*See `db/schema.rb` for full details or use rails-erd gem to generate a diagram*

---

## 📈 Roadmap

- ☑️  Live price bulk caching & background refresh
- ☑️  Fancy searchable combobox for securities
- ☐ Basic analytics dashboard (time‑weighted returns, risk metrics)
- ☐ Transaction import and parsing
- ☐ Google Calendar integration
- ☐ Mobile‑first redesign

---

## 🤝 Contributing

PRs are welcome! To get started:

1. Fork the repo & create a branch (`git checkout -b feature/awesome`)
2. Add specs for your feature or bugfix
3. Run `bin/rails test` & `rubocop`
4. Submit a pull request describing your changes

Please follow the project coding style and add tests where appropriate.

---

> Powered by 🧉 and [me](https://github.com/owen-makes).
