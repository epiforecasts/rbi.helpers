## Build the rbi.helpers hex logo: a proposal distribution being adapted onto
## the empirical covariance of the accepted samples, one round at a time.
## It writes logo.svg and, in the same design with a dark palette,
## logo-dark.svg for sites shown in dark mode.
set.seed(4)

width <- 1200
height <- 1385

light <- list(ground = "#f6f7f9", navy = "#1f3864", blue = "#4a7fbd")
## the same roles on a dark ground: light lines and text, lighter samples
dark <- list(ground = "#141b24", navy = "#dbe5f2", blue = "#7fb2ea")

## centre of the parameter-space panel inside the hexagon
cx <- 600
cy <- 935

## accepted samples: correlated, the target the proposal has to match
n <- 200
target <- matrix(c(1, 0.55, 0.55, 0.5), 2, 2)
samples <- matrix(rnorm(2 * n), n, 2) %*% chol(target)
emp <- cov(samples)
emp_eigen <- eigen(emp)

## pixels per unit, set so the adapted 2-sd ellipse spans the panel width
scale <- 282 / (2 * sqrt(emp_eigen$values[1]))

sx <- function(x) cx + x * scale
sy <- function(y) cy - y * scale

## ellipse from semi-axes in pixels and an orientation in degrees
ellipse <- function(ax, deg, k = 180) {
  a <- deg * pi / 180
  th <- seq(0, 2 * pi, length.out = k)
  x <- ax[1] * cos(th) * cos(a) - ax[2] * sin(th) * sin(a)
  y <- ax[1] * cos(th) * sin(a) + ax[2] * sin(th) * cos(a)
  paste(sprintf("%.1f,%.1f", cx + x, cy - y), collapse = " ")
}

## the adapted proposal, taken from the sample covariance itself
emp_ax <- 2 * sqrt(emp_eigen$values) * scale
emp_deg <- atan2(emp_eigen$vectors[2, 1], emp_eigen$vectors[1, 1]) * 180 / pi

## earlier rounds: a wide isotropic guess that shrinks and turns towards it
rounds <- list(
  list(ax = c(345, 267), deg = emp_deg + 34, opacity = 0.20),
  list(ax = c(308, 205), deg = emp_deg + 21, opacity = 0.30),
  list(ax = c(293, 153), deg = emp_deg + 10, opacity = 0.42)
)

hex <- "600,8 1194,350 1194,1035 600,1377 6,1035 6,350"

make_logo <- function(palette) {
  rounds_svg <- vapply(rounds, function(r) {
    sprintf(
      paste0('    <polygon points="%s" fill="none" stroke="%s"',
             ' stroke-width="6" stroke-opacity="%.2f"',
             ' stroke-dasharray="16 16"/>'),
      ellipse(r$ax, r$deg), palette$navy, r$opacity
    )
  }, character(1))

  final_svg <- c(
    sprintf('    <polygon points="%s" fill="%s" fill-opacity="0.12"/>',
            ellipse(emp_ax, emp_deg), palette$blue),
    sprintf(
      '    <polygon points="%s" fill="none" stroke="%s" stroke-width="14"/>',
      ellipse(emp_ax, emp_deg), palette$navy
    )
  )

  samples_svg <- vapply(seq_len(n), function(i) {
    sprintf(
      '    <circle cx="%.1f" cy="%.1f" r="10" fill="%s" fill-opacity="0.55"/>',
      sx(samples[i, 1]), sy(samples[i, 2]), palette$blue
    )
  }, character(1))

  c(
    sprintf(
      paste0('<svg xmlns="http://www.w3.org/2000/svg"',
             ' width="%d" height="%d" viewBox="0 0 %d %d">'),
      width, height, width, height
    ),
    "  <defs>",
    '    <clipPath id="hexclip">',
    sprintf('      <polygon points="%s"/>', hex),
    "    </clipPath>",
    "  </defs>",
    sprintf('  <polygon points="%s" fill="%s"/>', hex, palette$ground),
    '  <g clip-path="url(#hexclip)">',
    rounds_svg,
    samples_svg,
    final_svg,
    "  </g>",
    sprintf(
      '  <polygon points="%s" fill="none" stroke="%s" stroke-width="16"/>',
      hex, palette$navy
    ),
    sprintf(
      paste0('  <text x="600" y="500" text-anchor="middle"',
             ' font-family="Inter, Fira Sans, sans-serif" font-size="145"',
             ' fill="%s" letter-spacing="1">',
             '<tspan font-weight="600">rbi</tspan>',
             '<tspan font-weight="300">.helpers</tspan></text>'),
      palette$navy
    ),
    "</svg>"
  )
}

writeLines(make_logo(light), "man/figures/logo.svg")
writeLines(make_logo(dark), "man/figures/logo-dark.svg")

## rendered with:
##   inkscape man/figures/logo.svg -o logo-full.png -w 1200
##   magick logo-full.png -resize 240x -strip man/figures/logo.png
