# Pratka

Ruby client for Bulgarian courier APIs. Supported couriers:

- [Econt](https://www.econt.com/developers/soap-json-api.html), [Econt API Models](https://ee.econt.com/services/Shipments/) (Work in progress)
- [Speedy](https://api.speedy.bg/api/docs/)

## Installation

Requires Ruby 3.3 or newer

Until the first release, install from GitHub:

```ruby
gem "pratka", github: "tripplesteel/pratka"
```

## Speedy

### Setup
The configuration options are `base_url`, `language`, `country_id`, `read_timeout` and `open_timeout`. Set them up like this:

```ruby
Pratka::Speedy.configure do |c|
  c.base_url = ENV["SPEEDY_BASE_URL"] # Defaults to "https://api.speedy.bg/v1/"
  c.language = ENV["SPEEDY_LANGUAGE"] # "BG" or "EN". Anything else falls back to "BG"
  c.country_id = 100                  # Defaults to 100 (Bulgaria)
  c.read_timeout = 60                 # Seconds. Defaults to 30. nil waits forever
  c.open_timeout = 10                 # Seconds. Defaults to 10. nil waits forever
end
```

### Client initialization

```ruby
client = Pratka::Speedy::Client.new(
  username: ENV["SPEEDY_USERNAME"],
  password: ENV["SPEEDY_PASSWORD"],
  language: "EN", # Optional. Defaults to the configured language
  country_id: 100 # Optional. Defaults to the configured country_id
)
```

Credentials go on the client, not the global configuration, so you can run several Speedy accounts side by side

### API methods

#### Fetch Speedy offices

Its scoped automatically to client's country

```ruby
client.fetch_offices
```

Allowed options:
- `site_id` - Site id. Limits the search scope in the set of offices for specified site. If omitted - all country offices are searched
- `site_name` - Filters the results by office site name prefix or part of it
- `name` - Search term for office name. Filters the results by office name prefix or part of site name
- `limit` - The number of records to return in response. All records are returned if this parameter is omitted
- `office_type` - array of ["OFFICE", "APT"]
- `office_features` - array of ["CARD_PAYMENT", "CASH_PAYMENT", "DROP_OFF", "PICK_UP", "CARGO_TYPE_PARCEL", "CARGO_TYPE_PALLET", "CARGO_TYPE_TYRE"]

Returns the parsed JSON response. Values keep their JSON types, so IDs are `Integer`, coordinates are `Float` and flags are `true`/`false`

Example response:

```ruby
{"offices" =>
  [{"id" => 1,
    "name" => "ПЛОВДИВ – СКЛАД ЮГ",
    "nameEn" => "PLOVDIV - WAREHOUSE SOUTH",
    "siteId" => 56784,
    "address" =>
     {"countryId" => 100,
      "siteId" => 56784,
      "siteType" => "гр.",
      "siteName" => "Пловдив",
      "postCode" => "4000",
      "streetId" => 10621,
      "streetType" => "ул.",
      "streetName" => "Кукленско шосе",
      "streetNo" => "15",
      "x" => 24.761268,
      "y" => 42.120139,
      "fullAddressString" => "гр. Пловдив ул. Кукленско шосе No 15",
      "siteAddressString" => "гр. Пловдив",
      "localAddressString" => "ул. Кукленско шосе No 15"},
    "workingTimeFrom" => "08:30",
    "workingTimeTo" => "19:30",
    "workingTimeHalfFrom" => "08:30",
    "workingTimeHalfTo" => "14:30",
    "workingTimeDayOffFrom" => "00:00",
    "workingTimeDayOffTo" => "00:00",
    "sameDayDepartureCutoff" => "19:30",
    "sameDayDepartureCutoffHalf" => "14:30",
    "sameDayDepartureCutoffDayOff" => "19:00",
    "maxParcelDimensions" => {"width" => 240, "height" => 240, "depth" => 600},
    "maxParcelWeight" => 1200.0,
    "type" => "OFFICE",
    "nearbyOfficeId" => 836,
    "workingTimeSchedule" =>
     [{"date" => "2026-10-06",
       "workingTimeFrom" => "08:30",
       "workingTimeTo" => "19:30",
       "sameDayDepartureCutoff" => "19:30",
       "standardSchedule" => true}],
    "validFrom" => "2000-01-01",
    "validTo" => "3000-01-01",
    "cargoTypesAllowed" => ["PALLET", "PARCEL", "TYRE"],
    "pickUpAllowed" => true,
    "dropOffAllowed" => true,
    "routingInformation" =>
     {"tour" => {"number" => 10706, "officeId" => 1, "ramp" => "07", "cell" => "06"},
      "officeId" => 1,
      "hubId" => 1,
      "priority" => 2},
    "cardPaymentAllowed" => true,
    "cashPaymentAllowed" => true,
    "palletOffice" => true
  }]
}
```

#### Fetch Speedy cities
```ruby
client.fetch_cities
```

Returns the cities for the client's `country_id`, which defaults to the configured `country_id` (100, Bulgaria). Use a client with a different `country_id` to fetch another country's cities

Speedy serves this endpoint as CSV, so every value is a `String` and empty fields are `nil`. Convert IDs before comparing them with JSON responses. For example, an office's `"siteId" => 56784` matches a city's `"id" => "56784"`

Example response:

```ruby
[{"id" => "14",
  "countryId" => "100",
  "mainSiteId" => "0",
  "type" => "с.",
  "typeEn" => "s.",
  "name" => "Абланица",
  "nameEn" => "Ablanitsa",
  "municipality" => "Хаджидимово",
  "municipalityEn" => "Hadzhidimovo",
  "region" => "Благоевград",
  "regionEn" => "Blagoevgrad",
  "postCode" => "2932",
  "addressNomenclature" => "0",
  "x" => "23.934398",
  "y" => "41.536921",
  "servingDays" => "1111100",
  "servingOfficeId" => "130",
  "servingHubOfficeId" => "13"
}]
```

#### Fetch Speedy countries
```ruby
client.fetch_countries
```

Speedy serves this endpoint as CSV, so every value is a `String` and empty fields are `nil`. Booleans come back as `"true"` and `"false"`

Example response:

```ruby
[{"id" => "36",
  "name" => "Австралия",
  "nameEn" => "Australia",
  "isoAlpha2" => "AU",
  "isoAlpha3" => "AUS",
  "postCodeFormats" => "NNNN",
  "requireState" => "false",
  "addressType" => "2",
  "currencyCode" => nil,
  "defaultOfficeId" => "900",
  "streetTypes" => nil,
  "streetTypesEn" => nil,
  "complexTypes" => nil,
  "complexTypesEn" => nil,
  "siteNomen" => "0"
}]
```

#### Fetch complexes

```ruby
client.fetch_complexes(site_id: 881)
```

Allowed options:
- `site_id` (Mandatory) - Site id
- `name` - Search term for complex name. Filters the results by complex name prefix or part of complex name

Returns the parsed JSON response
Example response:

```ruby
{"complexes" =>
  [{"id" => 16182,
    "siteId" => 881,
    "actualId" => 0,
    "type" => "",
    "typeEn" => "",
    "name" => "Магерови колиби",
    "nameEn" => "Magerovi kolibi"}]}
```

#### Fetch streets
```ruby
client.fetch_streets(site_id: 36124)
```

Allowed options:
- `site_id` (Mandatory) - Site id
- `name` - Filters the results by street name

Returns the parsed JSON response
Example response:

```ruby
{"streets" =>
  [{"id" => 156597,
    "actualId" => 0,
    "siteId" => 36124,
    "type" => "ул.",
    "typeEn" => "ul.",
    "name" => "Алеко Константинов",
    "nameEn" => "Aleko Konstantinov"}
  ]
}
```

#### Print label

```ruby
client.print_label(paper_size: "A4", parcels: [{ parcel: { id: "123" } }])
```

Allowed options:
- `paper_size` (Mandatory) - Paper size of the label
- `parcels` (Mandatory) - Array of hashes. Example: [ { "parcel" => { id: 'speedy_tracking_number' } } ]
- `format` - Allowed values are `pdf` or `zpl`. Default one is `pdf`
- `printer_name` - Name of the printer
- `dpi` - Allowed values are `dpi203` or `dpi300`. Default one is `dpi203`
- `sender_copy` - Allowed values are `NONE`, `ON_SAME_PAGE`, `ON_SINGLE_PAGE`. Default one is `NONE`

Returns raw PDF or ZPL bytes if the request is successful and the parcel exists

If the parcels don't exist in Speedy, `print_label` raises `Pratka::Speedy::Error` with the message `Speedy returned an empty label; check the parcel IDs`

If you send empty parcels, `print_label` raises `ArgumentError` with the message `Missing params: parcels`

#### Fetch payment details

```ruby
client.fetch_payment_details(from_date: Time.new(2026, 10, 1), to_date: Time.now, include_details: true)
```

Allowed options:
- `from_date` (Mandatory) - Start of the period
- `to_date` (Mandatory) - End of the period
- `include_details` - Include per-shipment payout details. Default one is `false`

Dates accept `Date`, `DateTime`, `Time` or a string. The client sends `Date`, `DateTime` and `Time` as `yyyy-MM-dd'T'HH:mm:ssZ`, for example `"2026-10-01T09:00:00+0300"`. A `Date` has no time or zone, so it becomes midnight UTC. Strings are sent as they are

Returns the parsed JSON response. `details` is filled only when `include_details` is `true`
Example response:

```ruby
{"payouts" =>
  [{"date" => "2026-10-03",
    "docId" => 123456789,
    "docType" => "POSTAL_MONEY_TRANSFER", # or "CASH"
    "paymentType" => "BANK",              # or "CASH"
    "payee" => "Example Ltd",
    "currency" => "BGN",
    "amount" => 59.9,
    "details" =>
     [{"lineNo" => 1,
       "shipmentId" => "61234567890",
       "pickupDate" => "2026-09-30",
       "primaryShipmentPickupDate" => nil,
       "deliveryDate" => "2026-10-01",
       "sender" => "Example Ltd",
       "recipient" => "Ivan Ivanov",
       "note" => "",
       "ref1" => "ORDER-1001",
       "ref2" => "",
       "currency" => "BGN",
       "order" => 1001,
       "amount" => 59.9}]
  }]
}
```

### Errors

Every network and API failure raises a subclass of `Pratka::Speedy::Error`, which inherits from `Pratka::Error`

| Error | Raised when | Extra attributes |
| --- | --- | --- |
| `Pratka::Speedy::TimeoutError` | The connection or read times out | |
| `Pratka::Speedy::ConnectionError` | DNS, socket or SSL failure | |
| `Pratka::Speedy::HTTPError` | Speedy returns a non-2xx status | `status`, `body` |
| `Pratka::Speedy::APIError` | Speedy returns 2xx with an `error` object in the body | `code`, `context`, `id` |
| `Pratka::Speedy::Error` | The response is malformed, has invalid JSON, or has an unexpected format | |

Bad arguments raise `ArgumentError` before any request is sent, for example an unknown option or a missing `site_id`

```ruby
begin
  client.fetch_streets(site_id: 36124, name: "Алеко")
rescue Pratka::Speedy::APIError => e
  logger.warn("Speedy rejected the request: #{e.message} (code #{e.code})")
rescue Pratka::Speedy::TimeoutError, Pratka::Speedy::ConnectionError
  retry_later
rescue Pratka::Speedy::Error => e
  logger.error("Speedy failed: #{e.message}")
end
```

## Development

```bash
bin/setup          # install dependencies
bundle exec rake   # run specs and RuboCop
bin/console        # IRB session with the gem loaded
```

To release a new version, update `lib/pratka/version.rb` and `CHANGELOG.md`, then run `bundle exec rake release`. That task tags the commit, pushes the tag and publishes the gem to [rubygems.org](https://rubygems.org)

## License

[MIT](LICENSE.txt)
