"""
Site-only variants of the two `PioneerManuscript` tumour-burden figures.

The trial data come from Project Data Sphere, whose Cancer Research Platform
Agreement (v. May 13, 2020) forbids publishing the Data on a blog or website
(Art. III.B(ii)) except for what is "reasonably necessary" to report research
results (Art. VII). The manuscript versions of these two figures plot raw
per-patient scan values, which a reader could digitise. The versions here show
the same thing without that:

- `fig_sld_summary` replaces one-line-per-patient spaghetti with the pointwise
  median and interquartile range per trial, and drops any time bin with fewer
  than `min_n` patients so no quantile collapses onto a single person.
- `fig_sld_censored_site` keeps the model's observed-phase fit and forecast
  (model output, not Data), but deletes the black raw-scan points and hides
  the tick values so no absolute measurement or visit week can be read off.

Both reuse PioneerManuscript's own loaders and drawing, so the underlying
numbers still cannot drift from the paper's.
"""
module SiteFigures

using DataFrames, CairoMakie
using Statistics: median, quantile

using ..PioneerManuscript
const FP = PioneerManuscript.FiguresPlain
const ObsKM = FP.ObsKM
const ManuscriptData = FP.ManuscriptData

export fig_sld_summary, fig_sld_censored_site

"""
    fig_sld_summary(; bin_weeks = 6, min_n = 10, color, band_color) -> Figure

Observed SLD by trial, summarised across patients: median line and IQR band
over `bin_weeks`-wide time bins (six weeks is the scan cadence). Bins with
fewer than `min_n` patients are dropped.
"""
function fig_sld_summary(; bin_weeks::Real = 6, min_n::Integer = 10,
                         color = :black, band_color = (:black, 0.15))
    analysis = ObsKM.build_analysis_data(ManuscriptData.patient_data(), ManuscriptData.visit_data())
    visits = FP._unnest_visits(analysis, [:trial])
    visits = filter(r -> !ismissing(r.mmsumdiam), visits)
    visits[!, :trial_label] = FP._trial_label.(visits.trial)
    visits[!, :bin] = round.(Int, collect(Float64, visits.week) ./ bin_weeks)

    # One value per patient per bin, so a patient scanned twice in a window
    # counts once toward `min_n`.
    per_patient = combine(groupby(visits, [:trial_label, :bin, :usubjid]),
                          :mmsumdiam => (x -> median(Float64.(x))) => :sld_mm)
    summary = combine(groupby(per_patient, [:trial_label, :bin]),
                      nrow => :n,
                      :sld_mm => median => :med,
                      :sld_mm => (x -> quantile(x, 0.25)) => :q25,
                      :sld_mm => (x -> quantile(x, 0.75)) => :q75)
    summary = sort(summary[summary.n .>= min_n, :], [:trial_label, :bin])
    summary[!, :months] = FP.weeks_to_months.(summary.bin .* bin_weeks)

    trials = sort(unique(summary.trial_label))
    fig = Figure(size = (1100, 460))
    axes = map(enumerate(trials)) do (i, trial)
        sub = summary[summary.trial_label .== trial, :]
        ax = Axis(fig[1, i]; title = trial, xlabel = "Months",
                  ylabel = i == 1 ? "SLD [mm]" : "")
        band!(ax, sub.months, sub.q25, sub.q75; color = band_color)
        lines!(ax, sub.months, sub.med; color = color, linewidth = 2)
        scatter!(ax, sub.months, sub.med; color = color, markersize = 6)
        ax
    end
    linkyaxes!(axes...)
    ylims!(axes[1]; low = 0)

    return fig
end

"""
    fig_sld_censored_site(; kwargs...) -> Figure

`PioneerManuscript.fig_sld_censored(; kwargs...)` with the raw scan points
removed and tick values hidden. Every `Scatter` in that figure is the
observed-scan layer (`_draw_sld_censored_patient!`); the ribbons are
`LineRibbon` recipes and the watermark is `Text`, so deleting `Scatter` plots
removes exactly the raw data.
"""
function fig_sld_censored_site(; kwargs...)
    fig = PioneerManuscript.fig_sld_censored(; watermark = false, kwargs...)
    for ax in filter(c -> c isa Axis, fig.content)
        foreach(p -> delete!(ax, p), filter(p -> p isa Scatter, copy(ax.scene.plots)))
        hidexdecorations!(ax; grid = false, ticks = false, label = false)
        hideydecorations!(ax; grid = false, ticks = false, label = false)
    end
    return fig
end

end # module SiteFigures
