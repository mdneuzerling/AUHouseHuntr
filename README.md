
# AUHouseHuntr

<!-- badges: start -->
<!-- badges: end -->

This repository contains scraps of code that I use to help me buy a house in Australia. There is no commitment that the code in this package will work.

**Do not install this package**. If you wish to use this code, clone the repository and load it in RStudio with `devtools::load_all()`.

In order to use the Domain API [you will need an API key](https://developer.domain.com.au/docs/v1/authentication/apikey/creating-api-key/). Set this as the `DOMAIN_API_KEY` environment variable in your .Renviron file. You can open this file with `usethis::edit_r_environ()`. After setting the API key you will need to restart your R session in order for the changes to take effect.

The creator(s) of this package are not affiliated with _Domain_ or the the _Domain Group_.

## Example

Let's look at [a modest Toorak home](https://www.domain.com.au/1-edzell-avenue-toorak-vic-3142-2019562785) as an example. The URL contains the listing id, 2019562785. So we can get the listing information with:

```r
get_listing(2019562785)
```

