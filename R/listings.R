get_listing <- function(listing_id, api_key = get_api_key()) {
  path <- glue::glue("listings/{listing_id}/")
  raw_listing <- domain_api_call(path, api_key = api_key, parse_response = FALSE)
  listing_df(raw_listing)
}

expand_listings <- function(
  listings,
  listing_ids,
  api_key = get_api_key()
) {
  for (listing_id in listing_ids) {
    new_listing <- get_listing(listing_id, api_key = api_key)
    listings <- rbind(
      listings,
      new_listing %>% dplyr::anti_join(listings, by = c("id", "time_updated"))
    )
  }
  listings
}

parse_inspections <- function(inspections, state) {
  if (is.null(inspections) || length(inspections) == 0) {
    return(
      dplyr::tibble(
        recurrence = character(0),
        opens = as.POSIXct(double(0)),
        closes = as.POSIXct(double(0))
      )
    )
  }

  inspections %>%
    dplyr::rename(opens = openingDateTime, closes = closingDateTime) %>%
    dplyr::mutate(
      opens = convert_to_time(opens, state = state),
      closes = convert_to_time(closes, state = state)
    )
}

null_to_na_character <- function(x) {
  # the is.null is redundant here but code often behaves supernaturally
  if (is.null(x) || length(x) == 0) {
    NA_character_
  } else {
    as.character(x)
  }
}

listing_df <- function(raw_listing) {
  parsed_listing <- jsonlite::fromJSON(raw_listing)
  state <- parsed_listing$addressParts$stateAbbreviation
  media <- purrr::map_dfr(parsed_listing$media, dplyr::as_tibble)

  upcoming_inspections <- parsed_listing$inspectionDetails$inspections %>%
    parse_inspections(state = state)

  past_inspections <- parsed_listing$inspectionDetails$pastInspections %>%
    parse_inspections(state = state)

  next_inspection <- if (nrow(upcoming_inspections) == 0) {
    as.POSIXct(NA)
  } else {
    max(upcoming_inspections$opens)
  }

  soi_url <- parsed_listing$statementOfInformation$documentationUrl
  soi_price_range <- soi_extract_price(soi_url)

  dplyr::tibble(
    id = as.character(parsed_listing$id),
    address = parsed_listing$addressParts$displayAddress,
    unit_number = null_to_na_character(parsed_listing$addressParts$unitNumber),
    street_number = as.character(parsed_listing$addressParts$streetNumber),
    street = parsed_listing$addressParts$street,
    suburb = parsed_listing$addressParts$suburb,
    state = toupper(parsed_listing$addressParts$stateAbbreviation),
    bedrooms = as.integer(parsed_listing$bedrooms),
    bathrooms = as.integer(parsed_listing$bathrooms),
    car_spaces = as.integer(parsed_listing$carspaces),
    property_types = parsed_listing$propertyTypes, # is a list-column
    main_property_type = parsed_listing$propertyTypes[[1]],
    latitude = parsed_listing$geoLocation$latitude,
    longitude = parsed_listing$geoLocation$longitude,
    url = parsed_listing$seoUrl,
    objective = parsed_listing$objective,
    channel = parsed_listing$channel,
    time_listed = convert_to_time(parsed_listing$dateListed, state = state),
    time_updated = convert_to_time(parsed_listing$dateUpdated, state = state),
    headline = parsed_listing$headline,
    description = parsed_listing$description,
    display_price = parsed_listing$priceDetails$displayPrice,
    new_development = parsed_listing$isNewDevelopment,
    upcoming_inspections = list(upcoming_inspections),
    next_inspection = next_inspection,
    past_inspections = list(past_inspections),
    sale_method = parsed_listing$saleDetails$saleMethod,
    auction_location = null_to_na_character(
      parsed_listing$saleDetails$auctionDetails$auctionSchedule$locationDescription
    ),
    auction_time = convert_to_time(
      parsed_listing$saleDetails$auctionDetails$auctionSchedule$openingDateTime,
      state = state
    ),
    media = list(media),
    statement_of_information_url = soi_url,
    statement_of_information_price_lower = soi_price_range[1],
    statement_of_information_price_upper = soi_price_range[2],
    raw_response = raw_listing
  )
}
