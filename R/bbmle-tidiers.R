#' @templateVar class mle2
#' @template title_desc_tidy
#'
#' @param x An `mle2` object created by a call to [bbmle::mle2()].
#' @template param_confint
#' @template param_unused_dots
#'
#' @evalRd return_tidy(regression = TRUE)
#'
#' @examplesIf rlang::is_installed("bbmle")
#'
#' # load libraries for models and data
#' library(bbmle)
#'
#' # generate data
#' x <- 0:10
#' y <- c(26, 17, 13, 12, 20, 5, 9, 8, 5, 4, 8)
#' d <- data.frame(x, y)
#'
#' # fit model
#' fit <- mle2(y ~ dpois(lambda = ymean),
#'   start = list(ymean = mean(y)), data = d
#' )
#'
#' # summarize model fit with tidiers
#' tidy(fit)
#' 
#' @export
#' @seealso [tidy()], [bbmle::mle2()], [tidy_optim()]
#' @aliases mle2_tidiers bbmle_tidiers
tidy.mle2 <- function(x, conf.int = FALSE, conf.level = .95, ...) {
  check_ellipses("exponentiate", "tidy", "mle2", ...)
  
  co <- bbmle::coef(bbmle::summary(x))
  ret <- ret <- as_tidy_tibble(
    co,
    new_names = c("estimate", "std.error", "statistic", "p.value")
  )

  if (conf.int) {

    # can't use broom_confint / broom_confint_terms due to
    # some sort of S4 object dispatch thing

    ci <- bbmle::confint(x, level = conf.level)

    # confint called on models with a single predictor
    # often returns a named vector rather than a matrix :(

    if (is.null(dim(ci))) {
      ci <- matrix(ci, nrow = 1)
    }

    colnames(ci) <- c("conf.low", "conf.high")
    ci <- as_tibble(ci)

    ret <- dplyr::bind_cols(ret, ci)
  }

  as_tibble(ret)
}
