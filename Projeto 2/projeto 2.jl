include("Algoritmos/Ordenacao.jl")
include("Algoritmos/Ordenacao_Estrutural.jl")
include("Algoritmos/Inicializacao.jl")
include("Algoritmos/Saida.jl")
include("Algoritmos/Grafico.jl")
include("Algoritmos/Arvores_Recursivas.jl")
using BenchmarkTools, Juno, DataFrames
using Base.Threads: nthreads, @spawn



#--- Inicialização das variáveis
var = Inicializacao.inicializar_variaveis("Dados/entrada.txt")
const entrada_matricial = var[1]
const entrada_vetorizada = var[2]
const m = var[3]
const n = var[4]



plot_entrada = Grafico.plotar(entrada_vetorizada, "Entrada.txt")



#--- Insertion sort
# Θ(m²n⁴)


tempo_insertion_sort = @elapsed ordenado_insertion_sort =
    @benchmark Ordenacao.insertionsort(entrada_vetorizada[1:7260])

print(
    Ordenacao.teste_ordenacao(ordenado_insertion_sort) ? "Ordenado" :
    "Não ordenado",
)
plot_indices_ordenados =
    Grafico.plotar(ordenado_insertion_sort, "Insertion sort")
show(plot_insertion_sort)

Saida.escreve_arquivo_saida(
    "Dados/Saida/saida_insertion_sort.txt",
    ordenado_insertion_sort,
    true,
)

#---Merge sort
# # Θ(mn²log(mn²))

benchmark_mergesort = @benchmark ordenado_merge_sort =
    Ordenacao.mergesort(entrada_vetorizada)

print(
    "Está ordenado? ",
    Ordenacao.teste_ordenacao(ordenado_merge_sort) ? "sim" : "não",
)

plot_indices_ordenados = Grafico.plotar(ordenado_merge_sort, "merge sort")

Saida.escreve_arquivo_saida(
    "Dados/Saida/saida_insertion_sort.txt",
    ordenado_insertion_sort,
    true,
)
#--- Heapsort
a = reverse(entrada_vetorizada[1:7260])
benchmark_heapsort =
    @benchmark ordenado_heap_sort = Ordenacao.heapsort(entrada_vetorizada)

print(
    "Está ordenado? ",
    Ordenacao.teste_ordenacao(ordenado_heap_sort) ? "sim" : "não",
)




#---Quicksort

benchmark_quicksort =
    @benchmark ordenado_quick_sort = Ordenacao.quicksort(entrada_vetorizada)

print(
    Ordenacao.teste_ordenacao(ordenado_quick_sort) ? "Ordenado" :
    "Não ordenado",
)

#--- letra k)

benchmark_ordenacao =
    @benchmark ordenado_quick_sort = Ordenacao.ordenar(entrada_matricial)

print(
    Ordenacao.teste_ordenacao(ordenado_quick_sort) ? "Ordenado" :
    "Não ordenado",
)



#--- Otimização da estrutura do arquivo

##--- Pre organização do arquivo

benchmark_preorganizacao = @benchmark entrada_vetorial_pre_organizada =
                                Ordenacao_Estrutural.organizar_indices(entrada_vetorizada)

print(
    Ordenacao.teste_ordenacao(entrada_vetorial_pre_organizada) ? "Ordenado" :
    "Não ordenado",
)


plot_indices_ordenados =
    Grafico.plotar(entrada_vetorial_pre_organizada, "Índices ordenados")

Saida.escreve_arquivo_saida(
    "Dados/Saida/ordenado_por_indices.txt",
    entrada_vetorial_pre_organizada,
    true,
)

##-- Otimização do Insertionsort

insertion_sort_otimizado(
    entrada_vetorizada::Array{Tuple{Int64,Int64,Int64,Float64}},
) =
    Ordenacao_Estrutural.organizar_indices(entrada_vetorizada, n, m) |>
    Ordenacao.insertionsort

benchmark_insertion_otimizado = @benchmark ordenado_insertion_sort_otimizado =
    insertion_sort_otimizado(entrada_vetorizada)

tempo_insertion_sort


##-- Otimização do Mergesort

merge_sort_otimizado(
    entrada_vetorizada::Array{Tuple{Int64,Int64,Int64,Float64}},
) =
    Ordenacao_Estrutural.organizar_indices(entrada_vetorizada, n, m) |>
    Ordenacao.mergesort# v -> Ordenacao.mergesort_por_empresa(v, m)


benchmark_mergesort_otimizado = @benchmark ordenado_merge_sort_otimizado =
    merge_sort_otimizado(entrada_vetorizada)

benchmark_mergesort

##-- Otimização do Heapsort

heap_sort_otimizado(
    entrada_vetorizada::Array{Tuple{Int64,Int64,Int64,Float64}},
) =
    Ordenacao_Estrutural.organizar_indices(entrada_vetorizada, n, m) |>
    Ordenacao.heapsort

benchmark_heapsort_otimizado = @benchmark ordenado_heap_sort_otimizado =
    heap_sort_otimizado(entrada_vetorizada)


##-- Otimização do Quicksort

quick_sort_otimizado(
    entrada_vetorizada::Array{Tuple{Int64,Int64,Int64,Float64}},
) = Ordenacao.quicksort(
    Ordenacao_Estrutural.organizar_indices(entrada_vetorizada),
    true,
)


benchmark_quicksort_otimizado = @benchmark ordenado_quick_sort_otimizado =
    quick_sort_otimizado(entrada_vetorizada)
