
linhas = readlines("Dados/entrada.txt");

include("Algoritmos/Ordenacao.jl")
include("Algoritmos/Organizacao_Estrutural.jl")

using BenchmarkTools, Juno

parametros_iniciais = split(linhas[1], " ");
n = parse(Int64, parametros_iniciais[1]);
m = parse(Int64, parametros_iniciais[2]);
t = parse(Float64, parametros_iniciais[3]);

entrada_vetorial =
    Array{Tuple{Int64,Int64,Int64,Float64}}(undef, length(linhas))


entrada_matricial = Array{Float64,3}(undef, m, n, n)
linhas = linhas[2:end]
for i = 1:length(linhas)
    dados = split(linhas[i], " ")
    empresa = parse(Int64, dados[1])
    mes_inicial = parse(Int64, dados[2])
    mes_final = parse(Int64, dados[3])
    valor = parse(Float64, dados[4])
    entrada_vetorial[i] = (empresa, mes_inicial, mes_final, valor)
    entrada_matricial[empresa, mes_inicial, mes_final] = valor

end # for

@time begin
    ordenado_insertion_sort = Ordenacao.insertionsort(entrada_vetorial)
end #time


benchmark_insertion_sort =
    @benchmark() * funcoes_ordenacao.insertionsort(entrada_vetorial)

indices_ordenados = Ordenacao_Estrutural.organizar_indices(n, m)

@time begin
    ordenado_insertion_sort = Ordenacao.insertionsort(entrada_vetorial[teste])
end #time

benchmark =
    @btime _ = Ordenacao.insertionsort(entrada_vetorial[indices_ordenados])
