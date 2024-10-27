time_zone_for_state <- function(state_abbrevation) {
  time_zones <- c(
    "vic" = "Australia/Melbourne",
    "nsw" = "Australia/Sydney",
    "qld" = "Australia/Brisbane",
    "wa" = "Australia/Perth",
    "nt" = "Australia/Darwin",
    "sa" = "Australia/Adelaide",
    "tas" = "Australia/Hobart",
    "act" = "Australia/Canberra"
  )

  detected_time_zone <- time_zones[tolower(state_abbrevation)]
  # defaulting to Melbourne, just to piss off anyone from Sydney
  detected_time_zone[is.na(detected_time_zone)] <- "Australia/Melbourne"
  detected_time_zone
}

convert_to_time <- function(time_string, state = NULL) {
  if (is.null(time_string)) return(as.POSIXct(NA))
  parsed <- as.POSIXct(time_string, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
  if (!is.null(state)) {
    time_zone <- time_zone_for_state(state)
    attr(parsed, "tzone") <- time_zone
  }
  parsed
}
