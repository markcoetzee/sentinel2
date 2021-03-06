#' Buy a granule at 'https://s2.boku.eodc.eu'
#'
#' Buy granule using granuleId
#'
#' @param granuleId character vector of one or more granuleId's to buy
#' @param mode one of "ask" and "always". If "ask", the user is prompted for
#'   confirmation before spending coins ( - in interactive sessions only!).
#'   If "always", granules are bought anyway.
#' @export


S2_buy_granule <- function(granuleId, mode=c("ask", "always")){

  buy_mode <- match.arg(mode)

  # Check how many coins are required and available ----------------------------
  to_buy     <- buy_check(granuleId = granuleId)
  user_coins <- S2_user_info()$'coinsRemain'

  # Check if number of granules to buy exceeds coin budget ---------------------
  if (user_coins < sum(to_buy)){

    cat(sprintf("You try to buy %s granules, but you seem to have only %s coins left.\n",
                sum(to_buy), user_coins))
    cat("Please check coin budget or reduce number of granules to buy.")
    stop("Not enough coins to buy granules!")

  } else if (sum(to_buy) == 0){

    cat("Nothing to buy.")
    return(invisible(NULL))

  }

  # Promt user for confirmation ------------------------------------------------
  # Check if session is running in interactive mode ----------------------------

  if (buy_mode == "ask"){

    if (!interactive()){

      stop("'mode = 'ask'' can only be run in interactive mode!")

    } else {

      cat(sprintf("You are about to buy %s granules.", sum(to_buy)))
      quest   <- "This action will cost you coins! Type 'YES' to proceed:\t"
      buy_all <- readline(prompt = quest) %in%  c("YES", "'YES'")

    }

  } else if (buy_mode == "always"){
    buy_all <- TRUE
  }

  # Finally buy granule's if buy_all is TRUE -----------------------------------

  if (isTRUE(buy_all)){

    user      <- getOption("S2user")
    password  <- getOption("S2password")

    for (i in seq_along(granuleId)){
      httr::PUT('https://s2.boku.eodc.eu',
                config = httr::authenticate(user, password),
                path   = list('granule', granuleId[i]))
    }

  } else {

    cat("Action canceled.")
    return(invisible(NULL))

  }
}

