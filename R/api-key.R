get_api_key <- function() {
  from_env_var <- Sys.getenv("DOMAIN_API_KEY")

  if (from_env_var == "") {
    stop("Could not find a DOMAIN_API_KEY in your environment variables.

Obtain your API key by following the instructions at
https://developer.domain.com.au/docs/v1/authentication/apikey/creating-api-key/

Then set your API key in your .Renviron file. You can run
usethis::edit_r_environ() to open this file. You will need to restart your R
session in order for the changes to take effect.")
  }

  from_env_var
}
