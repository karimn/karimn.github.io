"""
Site theme for Makie figures rendered into karimn.github.io.

`PioneerManuscript` figures default to the manuscript's look — white ground, AZ
brand cycle, Makie's stock sans. This restates them in the site's own tokens so
a figure sits *in* the page rather than on top of it. Every colour below is
copied from `theme.scss`; that file stays the source of truth.

This is ordinary Makie theming throughout — a `palette`, a `fonts` entry, and
per-plot-type sections. There are no bespoke keys: `PioneerManuscript` leaves
`color`/`colormap` unset on the forecast ribbon precisely so that a `LineRibbon`
theme entry can supply them.

Usage, from a qmd running with `--project` pointed at PioneerManuscript:

    include(joinpath(@__DIR__, "_julia", "site_theme.jl"))
    using .SiteTheme
    set_theme!(site_theme())
"""
module SiteTheme

using Makie

export site_theme, PAPER, INK, INK_SOFT, MUTED, RULE, ACCENT, ACCENT_SOFT

# theme.scss:21-29. Names kept identical to the SCSS variables so a change
# there is greppable to here.
const PAPER       = "#FAF8F3"  # $paper       — warm off-white ground
const INK         = "#1a1612"  # $ink         — warm near-black
const INK_SOFT    = "#3d3530"  # $ink-soft    — secondary text
const MUTED       = "#8a7f70"  # $ink-muted   — axis furniture
const RULE        = "#d9d1c0"  # $rule        — hairline dividers
const ACCENT      = "#7c2b1f"  # $accent      — oxblood, links and markers
const ACCENT_SOFT = "#a85545"  # $accent-soft

# --- Typography --------------------------------------------------------------
#
# The site's body stack is `"Newsreader", "Source Serif 4", Iowan Old Style,
# Georgia, serif` (theme.scss:9), delivered to the browser as a webfont. Makie
# resolves fonts against the *filesystem*, not the browser's stack, so the
# figures need the actual Newsreader files or they silently fall back to
# Makie's stock sans and the plots stop looking like the page.
#
# `scripts/build_og_image.py` already solved this for the social card: it curls
# the faces it needs from the Fontsource CDN into a gitignored
# `scripts/.fonts/`. This reuses that directory, that CDN and that naming, so
# the two renderers share one font cache and neither owns it.
const FONT_DIR = normpath(joinpath(@__DIR__, "..", "..", "scripts", ".fonts"))

# Fontsource mirrors every Google font as plain .ttf, which is what Makie wants
# — the woff2 that Google Fonts itself serves is not loadable by FreeType here.
const FONT_URLS = Dict(
    "Newsreader-Regular.ttf"    => "https://cdn.jsdelivr.net/fontsource/fonts/newsreader@latest/latin-400-normal.ttf",
    "Newsreader-Bold.ttf"       => "https://cdn.jsdelivr.net/fontsource/fonts/newsreader@latest/latin-700-normal.ttf",
    "Newsreader-Italic.ttf"     => "https://cdn.jsdelivr.net/fontsource/fonts/newsreader@latest/latin-400-italic.ttf",
    "Newsreader-BoldItalic.ttf" => "https://cdn.jsdelivr.net/fontsource/fonts/newsreader@latest/latin-700-italic.ttf",
)

"""
    font(name) -> String

Absolute path to one of `FONT_URLS`' faces, fetching it into [`FONT_DIR`](@ref)
on first use.

Shells out to `curl` rather than using `Downloads`: this file is `include`d into
a session whose active project is `PioneerManuscript`, and adding a stdlib to
that package's `Project.toml` to serve a *website's* typography would be the
wrong dependency in the wrong repo. `build_og_image.py` uses curl for the same
files for the same reason.

Falls back to the family name on a failed fetch, which lets Makie try a system
lookup and, failing that, render in its default face — a figure with the wrong
serif is a better outcome for an offline render than a hard error.
"""
function font(name::AbstractString)
    path = joinpath(FONT_DIR, name)
    isfile(path) && return path
    haskey(FONT_URLS, name) || error("SiteTheme.font: unknown face '$name'")
    try
        mkpath(FONT_DIR)
        run(pipeline(`curl -fsSL -o $path $(FONT_URLS[name])`; stdout = devnull))
        return path
    catch
        @warn "SiteTheme: could not fetch $name; falling back to a system lookup" FONT_DIR
        return "Newsreader"
    end
end

"""
The site's categorical cycle, for figures whose series come from Makie's
`palette` (`fig_median_pfs`, `fig_median_os`, `fig_orr`).

Ordered most-separable first, and seven long because `fig_covariate_effects`
maps seven components to colour — at six, Makie wraps and paints two of them
identically. Hues are spread across the wheel rather than shaded within the
site's warm family, so the cycle survives both common colour-vision
deficiencies; the warmth comes from the ground and the type, not from
flattening every series into oxblood.
"""
const SITE_PALETTE = [
    "#7c2b1f",  # oxblood — $accent
    "#1f5673",  # deep teal
    "#b07d2b",  # ochre
    "#4a6741",  # moss
    "#6b4c7a",  # plum
    "#a85545",  # terracotta — $accent-soft
    "#3d3530",  # ink-soft
]

# The forecast band, tinted 45% toward the paper rather than toward white, so it
# reads as the ground showing through the line's colour instead of as a
# separate grey. Light end first: with a single 80% band the LineRibbon recipe
# samples the low end of the gradient.
const FORECAST_BAND =
    Makie.cgrad([Makie.RGBf(0.859, 0.729, 0.702), Makie.RGBf(0.659, 0.333, 0.271)])

"""
    site_theme() -> Makie.Theme

The site's Makie theme. Apply it on its own — it already restates the structural
choices `manuscript_theme()` makes (hidden top/right spines, frameless legend,
`figure_padding`), so merging the two is unnecessary and only makes the
precedence hard to reason about.

`LineRibbon` is the forecast ribbon in `fig_lfo_pfs`/`fig_lfo_os`/`fig_km_spop`.
`ACCENT_SOFT` rather than `ACCENT` for the line: it is drawn over a black
observed KM, and oxblood proper is dark enough that thin strokes of it read as
black at a glance — the exact failure `ManuscriptTheme`'s palette note records
for navy. Terracotta keeps the hue separation while sitting lighter than the
curve it crosses.
"""
function site_theme()
    return Theme(;
        backgroundcolor = PAPER,
        textcolor = INK,
        figure_padding = 16,
        fonts = (
            regular     = font("Newsreader-Regular.ttf"),
            bold        = font("Newsreader-Bold.ttf"),
            italic      = font("Newsreader-Italic.ttf"),
            bold_italic = font("Newsreader-BoldItalic.ttf"),
        ),
        palette = (color = SITE_PALETTE,),

        LineRibbon = (
            color = ACCENT_SOFT,
            colormap = FORECAST_BAND,
        ),

        Axis = (
            backgroundcolor = PAPER,
            topspinevisible = false,
            rightspinevisible = false,
            leftspinecolor = MUTED,
            bottomspinecolor = MUTED,
            xgridcolor = RULE,
            ygridcolor = RULE,
            xtickcolor = MUTED,
            ytickcolor = MUTED,
            xticklabelcolor = INK_SOFT,
            yticklabelcolor = INK_SOFT,
            xlabelcolor = INK,
            ylabelcolor = INK,
            titlecolor = INK,
        ),
        Legend = (
            backgroundcolor = PAPER,
            framevisible = false,
            labelcolor = INK,
        ),
        Colorbar = (
            labelcolor = INK,
            ticklabelcolor = INK_SOFT,
            tickcolor = MUTED,
        ),
    )
end

end # module SiteTheme
