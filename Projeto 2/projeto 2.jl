include("Algoritmos/Algoritmos_Ordenacao.jl")
include("Algoritmos/Inicializacao.jl")
include("Algoritmos/Saida.jl")
include("Algoritmos/Grafico.jl")

using BenchmarkTools, Juno, DataFrames, Plots, StatsPlots

insertionsort = Algoritmos_Ordenacao.insertionsort!
mergesort = Algoritmos_Ordenacao.mergesort!
heapsort = Algoritmos_Ordenacao.heapsort!
quicksort(vetor::Vector{Tuple{Int64,Int64,Int64,Float64}})::Vector{Tuple{Int64,Int64,Int64,Float64}} = Algoritmos_Ordenacao.quicksort!(vetor,1,length(vetor))

formata_casas = Saida.formata_casas_decimais

teste_ordenacao(vetor::Vector{Tuple{Int64,Int64,Int64,Float64}})::Bool =
    issorted(DataFrame(vetor)[!, 4]) ? true : false

function calculo_tempo_medio(vetor::Vector{Tuple{Int64,Int64,Int64,Float64}}, iteracoes::Int64, funcao_ordenacao)::Float64
    tempo = 0.0
    Juno.@progress for i in 1:iteracoes
      entrada = copy(vetor)
      tempo = tempo + @elapsed funcao_ordenacao(entrada)
    end
    return tempo / Float64(iteracoes)
end

#--- Inicialização das variáveis
var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")
const entrada_matricial = var[1]
const entrada_vetorizada = var[2]
const m = var[3]
const n = var[4]

#--- Insertion sort
# Θ(m²n⁴)

entrada = copy(entrada_vetorizada)

tempo_insertionsort = @elapsed ordenado_insertion_sort = insertionsort(entrada)

"Duração: " * formata_casas(tempo_insertionsort) * " s."

insertionsort(entrada_vetorizada) |> teste_ordenacao

#---Merge sort
 # Θ(mn²log(mn²))

tempo_mergesort = calculo_tempo_medio(entrada_vetorizada, 100, mergesort)
"Duração média: " * formata_casas(tempo_mergesort*1000.0) * " ms."
mergesort(entrada_vetorizada) |> teste_ordenacao

#--- Heapsort

tempo_heapsort = calculo_tempo_medio(entrada_vetorizada, 100, heapsort)
"Duração média: " * formata_casas(tempo_heapsort*1000.0) * " ms."
heapsort(entrada_vetorizada) |> teste_ordenacao


#---Quicksort

tempo_quicksort = calculo_tempo_medio(entrada_vetorizada, 100, quicksort)
"Duração média: " * formata_casas(tempo_quicksort*1000) * " ms."
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

a = Algoritmos_Ordenacao.dividir_e_ordenar(
        entrada_vetorizada,
        insertionsort,
        false,
    )

Algoritmos_Ordenacao.intercalar_k_vetores_ordenados(a)
function calculo_tempo_divisao_ordenacao(dados,
        iteracoes::Int64,
        funcao_ordenacao,
        paralelizar::Bool)::Float64
      t = 0.0
      Juno.@progress for i in 1:iteracoes
        entrada = copy(dados)
        t = t + @elapsed dividir_ordenar_intercalar(entrada, funcao_ordenacao, paralelizar)
      end

      return t/Float64(iteracoes)


    end

#--- Aplicação do mergesort

novo_tempo_mergesort_1 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, mergesort, false)
"Duração média: " * formata_casas(novo_tempo_mergesort_1*1000) * " ms."

novo_tempo_mergesort_2 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, mergesort, true)
"Duração média: " * formata_casas(novo_tempo_mergesort_2*1000) * " ms."


dividir_ordenar_intercalar(entrada_vetorizada, mergesort, false) |> teste_ordenacao

#--- Aplicação do heapsort
novo_tempo_heapsort_1 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, heapsort, false)
"Duração média: " * formata_casas(novo_tempo_heapsort_1*1000) * " ms."

novo_tempo_heapsort_2 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, heapsort, true)
"Duração média: " * formata_casas(novo_tempo_heapsort_2*1000) * " ms."

dividir_ordenar_intercalar(entrada_vetorizada, heapsort, false) |> teste_ordenacao

#--- Aplicação do quicksort
novo_tempo_quicksort_1 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, quicksort, false)
"Duração média: " * formata_casas(novo_tempo_quicksort_1*1000) * " ms."

novo_tempo_quicksort_2 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, quicksort, true)
"Duração média: " * formata_casas(novo_tempo_quicksort_2*1000) * " ms."


dividir_ordenar_intercalar(entrada_vetorizada, quicksort, false) |> teste_ordenacao

#--- Aplicação do Insertionsort



novo_tempo_insertionsort_1 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, insertionsort, false)
"Duração média: " * formata_casas(novo_tempo_insertionsort_1*1000) * " ms."

novo_tempo_insertionsort_2 = calculo_tempo_divisao_ordenacao(entrada_vetorizada, 100, insertionsort, true)
"Duração média: " * formata_casas(novo_tempo_insertionsort_2*1000) * " ms."


dividir_ordenar_intercalar(entrada_vetorizada, insertionsort, false) |> teste_ordenacao
#--- Estratégia da intercalação de colunas

ordenacao_heap_max_min(
    entrada_matricial::Array{Float64,3},
    paralelizar::Bool,
)::Vector{Tuple{Int64,Int64,Int64,Float64}} =
    Algoritmos_Ordenacao.intercalacao_heap_max(
        entrada_matricial,
        paralelizar,
    ) |> Algoritmos_Ordenacao.intercalar_k_vetores_ordenados

function calculo_tempo_intercalacao(dados::Array{Float64,3},
        iteracoes::Int64,
        paralelizar::Bool)::Float64
      t = 0.0
      Juno.@progress for i in 1:iteracoes
        entrada = copy(dados)
        t = t + @elapsed ordenacao_heap_max_min(entrada, paralelizar)
      end

      return t/Float64(iteracoes)

end

tempo_ordenacao_heap_max_min_1 = calculo_tempo_intercalacao(entrada_matricial, 100, false)
"Duração média: " * formata_casas(tempo_ordenacao_heap_max_min_1*1000) * " ms."

tempo_ordenacao_heap_max_min_2 = calculo_tempo_intercalacao(entrada_matricial, 100, true)
"Duração média: " * formata_casas(tempo_ordenacao_heap_max_min_2*1000) * " ms."

ordenacao_heap_max_min(entrada_matricial, false) |> teste_ordenacao
