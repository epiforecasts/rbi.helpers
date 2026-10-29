#' @rdname adapt_particles
#' @name adapt_particles
#' @title Adapt the number of particles
#' @description This function takes the provided [rbi::libbi()] and, at the
#'   last sample of its posterior, repeatedly runs the particle filter,
#'   adapting the number of particles until the variance of the resulting
#'   log-likelihood estimates crosses the value given as
#'   \code{target_variance} (1 by default).
#' @param x a [rbi::libbi()] object
#' @param min minimum number of particles
#' @param max maximum number of particles
#' @param target_variance target log-likelihood variance; once this is crossed,
#'   the current number of particles will be used
#' @param nruns number of times the particle filter is run, at a given number
#'   of particles, to estimate the log-likelihood variance
#' @param quiet if set to TRUE, will not provide running output of particle
#'   numbers tested
#' @param target.variance deprecated; use \code{target_variance} instead
#' @param ... parameters for libbi$run
#' @return a [rbi::libbi()] with the desired number of particles
#' @importFrom rbi bi_read extract_sample filter sample
#' @importFrom stats var
#' @examples
#' example_obs <- rbi::bi_read(system.file(package="rbi", "example_dataset.nc"))
#' example_model <- rbi::bi_model(system.file(package="rbi", "PZ.bi"))
#' example_bi <- rbi::libbi(model = example_model, obs = example_obs)
#' obs_states <- rbi::var_names(example_model, type = "obs")
#' max_time <- max(vapply(example_obs[obs_states], function(x) {
#'   max(x[["time"]])
#' }, 0))
#' \dontrun{
#'   adapted <- adapt_particles(example_bi, nsamples = 128, end_time = max_time)
#' }
#' @export
adapt_particles <- function(x, min = 1, max = 1024, target_variance = 1,
                            nruns = 20, quiet = FALSE, target.variance, ...) { # nolint
  if (!missing(target.variance)) {
    warning("target.variance is deprecated. Use 'target_variance' instead.")
    if (missing(target_variance)) {
      target_variance <- target.variance
    } else {
      stop("Can't give 'target.variance' and 'target_variance'.")
    }
  }

  if (missing(min) && !is.null(x$options[["nparticles"]])) {
    min <- x$options[["nparticles"]]
  }
  if (max < min) {
    stop("'max' must be greater or equal to 'min'")
  }

  if (!quiet) message(date(), " Adapting the number of particles")

  if (!x$run_flag) {
    if (!quiet) message(date(), " Initial trial run")
    x <- rbi::sample(x, ...)
  }

  test <- union(min * 2**(seq(0, floor(log2(max / min)))), max)

  ## fix parameters at the last posterior sample, so repeated filter runs
  ## give independent log-likelihood estimates at a single point
  par <- rbi::extract_sample(
    x, np = "last", type = "param", init_to_param = TRUE
  )

  found_good <- FALSE
  id <- 0
  while (!found_good && (id + 1) < length(test)) {
    id <- id + 1
    loglik <- vapply(seq_len(nruns), function(run) {
      f <- rbi::filter(x, init = par, nparticles = test[id], seed = run, ...)
      rbi::bi_read(f, vars = "loglikelihood")$loglikelihood
    }, 0)
    ## remove any infinite log-likelihoods
    loglik <- loglik[is.finite(loglik)]
    var_loglik <- stats::var(loglik)
    if (is.na(var_loglik)) var_loglik <- 0

    if (!quiet) {
      message(
        date(), " ", test[id], " particles, log-likelihood variance: ",
        var_loglik
      )
    }

    if (var_loglik < target_variance) {
      ## choose smallest var-loglikelihood < target_variance
      found_good <- TRUE
    }
  }
  if (!found_good) id <- length(test)

  adapted <- x
  adapted$options[["nparticles"]] <- test[id]

  if (!quiet) message(date(), " Choosing ", test[id], " particles.")

  adapted
}
