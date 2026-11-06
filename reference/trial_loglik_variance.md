# Variance of the finite log-likelihoods from a trial run

Warns, rather than returning a variance of 0, when fewer than two
log-likelihoods are finite, so that a trial run with no usable
log-likelihoods is not mistaken for one with a vanishingly small
variance.

## Usage

``` r
trial_loglik_variance(loglik, nparticles)
```

## Arguments

- loglik:

  numeric vector of log-likelihoods from a trial run

- nparticles:

  the number of particles used for the trial run, for the warning
  message

## Value

the variance of the finite log-likelihoods, or \`NA\` if fewer than two
are finite
