
include("Algoritmos/Ordenacao.jl")
include("Algoritmos/Organizacao_Estrutural.jl")
include("Algoritmos/Inicializacao.jl")
include("Algoritmos/Saida.jl")
using BenchmarkTools, Juno


entrada_matricial, entrada_vetorial, m, n =
    Inicializacao.inicializar_variaveis("Dados/entrada.txt")

@time begin
    ordenado_insertion_sort = Ordenacao.insertionsort(entrada_vetorial)
end #time


benchmark_insertion_sort =
    @benchmark() * funcoes_ordenacao.insertionsort(entrada_vetorial)

indices_ordenados = Ordenacao_Estrutural.organizar_indices(n, m)

@time begin
    ordenado_insertion_sort =
        Ordenacao.insertionsort(entrada_vetorial[indices_ordenados])
end #time

benchmark =
    @btime _ = Ordenacao.insertionsort(entrada_vetorial[indices_ordenados])

Saida.escreve_arquivo_saida(
    "Dados/Saida/saida_insertion_sort.txt",
    ordenado_insertion_sort,
)
