include("Algoritmos/Algoritmos_Ordenacao.jl")
include("Algoritmos/Ordenacao_Estrutural.jl")
include("Algoritmos/Inicializacao.jl")
include("Algoritmos/Saida.jl")
include("Algoritmos/Grafico.jl")

using BenchmarkTools, Juno, DataFrames, Plots, StatsPlots
using Base.Threads: nthreads, @spawn

insertionsort = Algoritmos_Ordenacao.insertionsort
mergesort = Algoritmos_Ordenacao.mergesort
heapsort = Algoritmos_Ordenacao.heapsort
quicksort = Algoritmos_Ordenacao.quicksort

teste_ordenacao(vetor::Vector{Tuple{Int64,Int64,Int64,Float64}})::Bool =
    issorted(DataFrame(vetor)[!, 4]) ? true : false



#--- Inicialização das variáveis
var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")
const entrada_matricial = var[1]
const entrada_vetorizada = var[2]
const m = var[3]
const n = var[4]

#--- Insertion sort
# Θ(m²n⁴)


tempo_insertion_sort =
    @elapsed ordenado_insertion_sort = insertionsort(entrada_vetorizada)

insertionsort(entrada_vetorizada) |> teste_ordenacao

#---Merge sort
# # Θ(mn²log(mn²))

benchmark_mergesort =
    @benchmark ordenado_merge_sort = mergesort(entrada_vetorizada)


mergesort(entrada_vetorizada) |> teste_ordenacao

#--- Heapsort

benchmark_heapsort =
    @benchmark ordenado_heap_sort = heapsort($entrada_vetorizada)

heapsort(entrada_vetorizada) |> teste_ordenacao



#---Quicksort

benchmark_quicksort = @benchmark quicksort($entrada_vetorizada)

quicksort(entrada_vetorizada) |> teste_ordenacao


#--- k) Ordenação aproveitando-se da estrutura do arquivo e dos dados do problema
##--Estratégia de dividir e ordenar

dividir_ordenar_intercalar(
    entrada_vetorizada::Vector{Tuple{Int64,Int64,Int64,Float64}},
    funcao_ordenacao,
    paralelizar::Bool,
)::Vector{Tuple{Int64,Int64,Int64,Float64}} =
    Algoritmos_Ordenacao.dividir_e_ordenar(
        entrada_vetorizada,
        funcao_ordenacao,
        paralelizar,
    ) |> Algoritmos_Ordenacao.intercalar_k_vetores_ordenados


###-- Aplicação do Insertionsort
@benchmark dividir_ordenar_intercalar(
    $entrada_vetorizada,
    $insertionsort,
    $true,
)

@benchmark dividir_ordenar_intercalar(
    $entrada_vetorizada,
    $insertionsort,
    $false,
)

dividir_ordenar_intercalar(entrada_vetorizada, insertionsort) |> teste_ordenacao



###-- Aplicação do mergesort
@benchmark dividir_ordenar_intercalar($entrada_vetorizada, $mergesort, $true)

@benchmark dividir_ordenar_intercalar($entrada_vetorizada, $mergesort, $false)


dividir_ordenar_intercalar(entrada_vetorizada, mergesort) |> teste_ordenacao

###-- Aplicação do heapsort
@benchmark dividir_ordenar_intercalar($entrada_vetorizada, $heapsort, $true)

@benchmark dividir_ordenar_intercalar($entrada_vetorizada, $heapsort, $false)

dividir_ordenar_intercalar(entrada_vetorizada, heapsort) |> teste_ordenacao

###-- Aplicação do quicksort
@benchmark dividir_ordenar_intercalar($entrada_vetorizada, $quicksort, $true)

@benchmark dividir_ordenar_intercalar($entrada_vetorizada, $quicksort, $false)



dividir_ordenar_intercalar(entrada_vetorizada, quicksort, true) |>
teste_ordenacao

###- Estratégia da intercalação de árvores binárias

ordenacao_heap_max_min(
    entrada_matricial::Array{Float64,3},
    paralelizar::Bool,
)::Vector{Tuple{Int64,Int64,Int64,Float64}} =
    Algoritmos_Ordenacao.ordenacao_heap_2D(entrada_matricial, paralelizar) |>
    Algoritmos_Ordenacao.intercalar_k_vetores_ordenados

@benchmark ordenacao_heap_max_min($entrada_matricial, true)
@benchmark ordenacao_heap_max_min($entrada_matricial, false)
ordenacao_heap_max_min(entrada_matricial, false) |> teste_ordenacao
