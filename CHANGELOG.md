## [Unreleased]

## [0.1.0] - 2026-10-07

Initial release, with Speedy as the first supported courier.

### Added

- `Pratka::Speedy.configure` for global settings: `base_url`, `language`, `country_id`, `read_timeout`, `open_timeout`
- `Pratka::Speedy::Client` with username/password authentication
- Location lookups: `fetch_offices`, `fetch_cities`, `fetch_countries`, `fetch_complexes`, `fetch_streets`
- `calculate` returns price and delivery deadline for one or more services
- `create_shipment`
- `print_label` returns raw PDF or ZPL bytes
- `fetch_payment_details` returns shipment payouts for a date range
- Error classes under `Pratka::Speedy`: `TimeoutError`, `ConnectionError`, `HTTPError` (with `status` and `body`), `APIError` (with `code`, `context`, `id`)
- Validation of required params, which treats blank values as missing
- Supports Ruby 3.3+ and JRuby

[Unreleased]: https://github.com/tripplesteel/pratka/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tripplesteel/pratka/releases/tag/v0.1.0
