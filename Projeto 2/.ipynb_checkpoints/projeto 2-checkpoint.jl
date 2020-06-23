
include("Algoritmos/Ordenacao.jl")
include("Algoritmos/Organizacao_Estrutural.jl")
include("Algoritmos/Inicializacao.jl")
include("Algoritmos/Saida.jl")
include("Algoritmos/Grafico.jl")
using BenchmarkTools, Juno

#--- Inicialização das variáveis
entrada_matricial, entrada_vetorizada, m, n =
    Inicializacao.inicializar_variaveis("Dados/entrada.txt")

Grafico.plotar(entrada_vetorizada,"Entrada.txt")

# Θ(m²n⁴)

#--- Pre organização do arquivo

@btime indices_ordenados = Ordenacao_Estrutural.organizar_indices(n, m)
# Θ(mn)

entrada_vetorial_pre_organizada = entrada_vetorizada[indices_ordenados]

Grafico.plotar(entrada_vetorial_pre_organizada,"Índices ordenados")

Saida.escreve_arquivo_saida(
    "Dados/Saida/ordenado_por_indices.txt",
    entrada_vetorial_pre_organizada,
    true,
)

#--- Insertion sort

@btime _ = Ordenacao.insertionsort(entrada_vetorial)


@btime ordenado_insertion_sort = Ordenacao.insertionsort(entrada_vetorial_pre_organizada)


Grafico.plotar(ordenado_insertion_sort,"Insertion sort")

Saida.escreve_arquivo_saida(
    "Dados/Saida/saida_insertion_sort.txt",
    ordenado_insertion_sort,
    true,
)
