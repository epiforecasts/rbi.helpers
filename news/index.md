# Changelog

## rbi.helpers (development version)

- [`adapt_particles()`](https://sbfnk.github.io/rbi/reference/adapt_particles.md)
  now estimates the log-likelihood variance from independent particle
  filter runs at the last posterior sample, instead of from a
  zero-variance-proposal MCMC chain that understated the variance and
  chose too few particles
- [`adapt_particles()`](https://sbfnk.github.io/rbi/reference/adapt_particles.md)
  now warns and tries a different number of particles, rather than
  accepting the smallest one, when a trial run has too few finite
  log-likelihoods

## rbi.helpers 0.4.1

CRAN release: 2025-09-26

- fix documentation links leading to CRAN check failures

## rbi.helpers 0.4.0

CRAN release: 2023-08-24

- add github actions for package checking and testing
- fix adaptation when there is only one parameter

## rbi.helpers 0.3.3

CRAN release: 2022-11-16

- adds a missing dependency for CRAN

## rbi.helpers 0.3.2

CRAN release: 2020-06-18

- version bump for CRAN resubmission

## rbi.helpers 0.3.1

CRAN release: 2019-07-10

- removed obsolete test from `adapt_particles`

## rbi.helpers 0.3.0

CRAN release: 2019-02-22

- new vignette: Introduction to rbi.helpers
- removed bloated `plot` function; plotting is now covered by the RBi
  vignette
- adaptive MCMC using the full empirical covariance
- speed up proposal and particle adaptations by avoiding recompiles
- `quiet` option to `adapt_mcmc` and `adapt_particles`
- times operations to convert between numeric and R times/dates
- innumerable bug fixes

## rbi.helpers 0.2

- Bug fixes and cosmetic changes

## rbi.helpers 0.1

- initial version
