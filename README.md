# Pratka

Ruby client for Bulgarian courier APIs. Supported couriers:

- [Econt](https://www.econt.com/developers/soap-json-api.html), [Econt API Models](https://ee.econt.com/services/Shipments/) (Work in progress)
- [Speedy](https://api.speedy.bg/api/docs/)

I built this because I mainly work on Ruby/JRuby on Rails e-shops that integrate with Speedy and Econt, and I kept copying the same API code from project to project. With Pratka, each project can call the courier APIs directly. I'm starting with the endpoints we use most. If you need one that isn't implemented yet, feel free to [open an issue](https://github.com/tripplesteel/pratka/issues).

## Installation

Requires Ruby 3.3 or newer

```ruby
gem "pratka"
```

or

```bash
bundle add pratka
```

## Speedy

### Setup
`Pratka::Speedy` works without any configuration. Add the gem, create a `Pratka::Speedy::Client` with your credentials, and you're ready. To override the defaults, set any of `base_url`, `language`, `country_id`, `read_timeout` and `open_timeout`:

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

It's scoped automatically to client's country

```ruby
client.fetch_offices
```

Allowed options:
- `site_id` - Site ID. Limits the search scope in the set of offices for specified site. If omitted - all country offices are searched
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
- `site_id` (Mandatory) - Site ID
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
- `site_id` (Mandatory) - Site ID
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
- `parcels` (Mandatory) - Array of hashes. Example: [ { parcel: { id: "speedy_tracking_number" } } ]
- `format` - Allowed values are `pdf` or `zpl`. Defaults to `pdf`
- `printer_name` - Name of the printer
- `dpi` - Allowed values are `dpi203` or `dpi300`. Defaults to `dpi203`
- `sender_copy` - Allowed values are `NONE`, `ON_SAME_PAGE`, `ON_SINGLE_PAGE`. Defaults to `NONE`

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
- `include_details` - Include per-shipment payout details. Defaults to `false`

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

#### Create shipment

```ruby
client.create_shipment(
  recipient: {
    phone1: { number: "0899445566" },
    clientName: "Ivan Ivanov",
    privatePerson: true,
    pickupOfficeId: 77
  },
  service: { serviceId: 505, autoAdjustPickupDate: true },
  content: { parcelsCount: 1, totalWeight: 0.6, contents: "Mobile phone", package: "BOX" },
  payment: { courierServicePayer: "RECIPIENT" },
  shipment_note: "Fragile"
)
```

Allowed options:
- `recipient` (Mandatory) - [ShipmentRecipient](https://api.speedy.bg/api/docs/#href-ds-shipment-recipient). The recipient and the delivery place
- `service` (Mandatory) - [ShipmentService](https://api.speedy.bg/api/docs/#href-ds-shipment-service). The service level, pickup date and additional services
- `content` (Mandatory) - [ShipmentContent](https://api.speedy.bg/api/docs/#href-ds-shipment-content). Parcel count, weight, size and contents
- `payment` (Mandatory) - [ShipmentPayment](https://api.speedy.bg/api/docs/#href-ds-shipment-payment). Who pays for what
- `sender` - [ShipmentSender](https://api.speedy.bg/api/docs/#href-ds-shipment-sender). The sender and the pickup place. If omitted, the logged-in user is the sender
- `shipment_note` - Customer's note for the shipment

Returns the parsed JSON response. Use the parcel `id` values with `print_label`. Speedy returns `price` only if your account can view shipment amounts, and `deliveryDeadline` only when it knows one
Example response:

```ruby
{"id" => "299999990",
 "parcels" => [{"seqNo" => 1, "id" => "299999990"}],
 "pickupDate" => "2026-10-07",
 "price" =>
  {"amount" => 5.5,
   "vat" => 1.1,
   "total" => 6.6,
   "currency" => "BGN"},
 "deliveryDeadline" => "2026-10-08T19:00:00+03:00"
}
```

#### Calculate

```ruby
client.calculate(
  recipient: { privatePerson: true, pickupOfficeId: 77 },
  service: { serviceIds: [505, 412], autoAdjustPickupDate: true },
  content: { parcelsCount: 1, totalWeight: 0.6 },
  payment: { courierServicePayer: "RECIPIENT" }
)
```

Allowed options:
- `recipient` (Mandatory) - [CalculationRecipient](https://api.speedy.bg/api/docs/#href-ds-calculation-recipient). The delivery place
- `service` (Mandatory) - [CalculationService](https://api.speedy.bg/api/docs/#href-ds-calculation-service). The service IDs to price, the pickup date and additional services
- `content` (Mandatory) - [CalculationContent](https://api.speedy.bg/api/docs/#href-ds-calculation-content). Parcel count and weight, or a list of parcels
- `payment` (Mandatory) - [ShipmentPayment](https://api.speedy.bg/api/docs/#href-ds-shipment-payment). Who pays for what
- `sender` - [CalculationSender](https://api.speedy.bg/api/docs/#href-ds-calculation-sender). The pickup place. If omitted, the logged-in user's location is used

Returns the parsed JSON response with one calculation per service ID. Speedy returns `price` only if your account can view shipment amounts, and `deliveryDeadline` only when it knows one

A service Speedy can't price for this destination comes back with its own `error` object instead of a price. `calculate` doesn't raise for it, so check each calculation

Example response:

```ruby
{"calculations" =>
  [{"serviceId" => 505,
    "additionalServices" => {},
    "price" =>
     {"amount" => 5.5,
      "vat" => 1.1,
      "total" => 6.6,
      "currency" => "BGN"},
    "pickupDate" => "2026-10-07",
    "deliveryDeadline" => "2026-10-08T19:00:00+03:00"},
   {"serviceId" => 412,
    "error" =>
     {"context" => "service.serviceIds",
      "message" => "Service is not allowed for this destination",
      "id" => "EE-1234",
      "code" => 1}}]
}
```

#### Track

```ruby
client.track(parcels: [{ id: "299999990" }, { ref: "ORDER-1001" }], last_operation_only: true)
```

Allowed options:
- `parcels` (Mandatory) - Array of [TrackShipmentParcelRef](https://api.speedy.bg/api/docs/#href-ds-track-shipment-parcel-ref), at most 10. Each parcel needs one of `id`, `ref`, `fullBarcode` or `externalCarrierParcelNumber`. `ref` matches the `ref1` and `ref2` fields of a parcel or shipment
- `last_operation_only` - Return only the latest operation per parcel. Defaults to `false`

Returns the parsed JSON response with one tracked parcel per matched parcel. A `ref` can match up to 10 parcels. Operation codes are listed in [Appendix 1](https://api.speedy.bg/api/docs/#href-appendix1-track-and-trace-codes) of the Speedy docs

A parcel Speedy can't find comes back with its own `error` object instead of operations. `track` doesn't raise for it, so check each parcel

Speedy asks clients to send at most 10 parcels per request and plans to enforce that limit. `track` enforces it already, so if you send more than 10 parcels it raises `ArgumentError` with the message `Speedy tracks at most 10 parcels per call`. Split larger lists into batches, for example with `each_slice(10)`

Example response:

```ruby
{"parcels" =>
  [{"parcelId" => "299999990",
    "operations" =>
     [{"dateTime" => "2026-10-08T11:42:10+0300",
       "operationCode" => -14,
       "description" => "Delivered",
       "place" => "SOFIA",
       "consignee" => "Ivan Ivanov"}]}]
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
