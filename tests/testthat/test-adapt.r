context("Testing functions for adapting")

model <- system.file(package = "rbi", "PZ.bi")
example_output <- rbi::bi_read(
  system.file(package = "rbi", "example_output.nc")
)
bi <- rbi::libbi(model, nparticles = 1)
bi <- rbi::attach_data(bi, "output", example_output)
obs <- list(P_obs = data.frame(time = 0, value = 1.485121))

test_that("pMCMC adaptation works", {
  skip_on_cran()
  suppressWarnings(capture.output(
    prop_adapted <-
      adapt_proposal(bi,
        obs = obs, nsamples = 100, min = 0.5, max = 0.53,
        adapt = "both", seed = 3
      )
  ))
  prop_adapted2 <- adapt_proposal(
    prop_adapted, with = "transform-initial-to-param", min = 0.4, max = 0.5,
    adapt = "shape", seed = 5, scale = 0.5, quiet = TRUE
  )
  capture.output(part_adapted <- adapt_particles(prop_adapted, seed = 1))
  capture.output(part_adapted2 <- adapt_particles(bi, seed = 1, obs = obs))
  expect_true(part_adapted$options$nparticles > 0)
  expect_gt(length(bi_read(prop_adapted, file = "input")), 0)
  expect_gt(
    length(
      bi_read(adapt_proposal(prop_adapted, min = 0, max = 1), file = "input")
    ), 0
  )
})

test_that("particles are chosen from the variance of repeated filter runs", {
  x <- structure(
    list(run_flag = TRUE, options = list(nparticles = 4), thin = 1),
    class = "libbi"
  )

  ## the first number of particles tried gives log-likelihoods, from
  ## independent filter runs, with a variance well above target_variance;
  ## the second gives one well below it
  loglik_by_n <- list(
    `4` = c(-10, 10, -8, 9, -11, 12, -9, 8, -12, 11),
    `8` = c(0.1, -0.1, 0.2, -0.2, 0.05, -0.05, 0.1, -0.1, 0, 0)
  )

  local_mocked_bindings(
    extract_sample = function(x, ...) list(),
    filter = function(x, init, nparticles, seed, ...) {
      structure(
        list(loglik = loglik_by_n[[as.character(nparticles)]][seed]),
        class = "libbi"
      )
    },
    bi_read = function(x, vars, ...) list(loglikelihood = x$loglik),
    .package = "rbi"
  )

  adapted <- adapt_particles(
    x, min = 4, max = 8, target_variance = 1, nruns = 10, quiet = TRUE
  )

  expect_identical(adapted$options$nparticles, 8)
})

test_that("warnings are given", {
  expect_warning(adapt_proposal(bi, size = TRUE, adapt = "shape"), "adapt size")
  expect_warning(
    adapt_proposal(bi, correlations = TRUE, adapt = "size"), "adapt shape"
  )
})

test_that("errors are reported", {
  expect_error(
    acceptance_rate(rbi::extract_sample(bi, 0), model = model),
    "just one sample"
  )
  expect_error(adapt_particles(bi, min = 1, max = 0), "greater")
  expect_error(adapt_proposal(bi, min = 1, max = 0), "max>min")
  expect_error(adapt_proposal(bi, adapt = "test"), "one of")
})

test_that("deprecated options are recognised", {
  expect_warning(adapt_proposal(bi, size = TRUE), "adapt")
  expect_warning(adapt_proposal(bi, correlations = TRUE), "adapt")
})
