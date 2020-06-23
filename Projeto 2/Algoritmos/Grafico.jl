module Grafico
using DataFrames, Plots, StatsPlots

export plotar

function plotar(dados::Array{Tuple{Int64,Int64,Int64,Float64}}, titulo::String)

    df = DataFrame(dados)


    return (plot(
        [1:1:size(df, 1);],
        df[!, 4],
        seriestype = :bar,
        label = false,
        title = titulo,
    ))

end # function


end  # module
