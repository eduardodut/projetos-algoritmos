module Ordenacao_Estrutural

using Juno

export organizar_por_indices

function organizar_por_indices(
    vetor::Array{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
    n::Int64,
)::Array{Tuple{Int64,Int64,Int64,Float64}}

    # m = vetor[end][1]
    # n = vetor[end][3]
    # resultado = similar(vetor_entrada)


    tamanho_array = length(vetor)


    vetor_indices = [1:1:tamanho_array;]



    contratos = Int(n * (n + 1) / 2)
    #s
    total_linhas = contratos * m
    a = [1:1:tamanho_array;]

    b = reshape(a, 7260, m)


    c = reshape(b', 1, tamanho_array)
    vetor_ordenado = vec(c)

    return vetor[vetor_ordenado]



end # function

# using DataFrames, BenchmarkTools, Juno
# include("Inicializacao.jl")
#
# var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")
# const entrada_vetorizada = var[2]
#
# organizar_por_indices(entrada_vetorizada, 100, 120)
#
# include("Grafico.jl")
#
# Grafico.plotar(organizar_por_indices(entrada_vetorizada, 100, 120), "")




end
