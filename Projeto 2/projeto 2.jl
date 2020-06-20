
linhas = readlines("Dados/entrada.txt");

a = 2

parametros_iniciais = split(linhas[1], " ");
n= parse(Int64,parametros_iniciais[1]);
m = parse(Int64,parametros_iniciais[2]);
t = parse(Float64,parametros_iniciais[3]);

linhas = linhas[2:end]

entrada_vetorial = Array{Float64}(undef, length(linhas), 4)


entrada_matricial= Array{Float64,3}(undef,m, n, n)

for i in 1:length(linhas)
    dados =  split(linhas[i], " ")
    empresa = parse(Int64,dados[1])
    mes_inicial = parse(Int64,dados[2])
    mes_final = parse(Int64,dados[3])
    valor = parse(Float64,dados[4])
    entrada_vetorial[i,1] = empresa
    entrada_vetorial[i,2] = mes_inicial
    entrada_vetorial[i,3] = mes_final
    entrada_vetorial[i,4] = valor

    entrada_matricial[empresa,mes_inicial,mes_final] = valor

end # for


include("Algoritmos/funcoes_ordenacao.jl")
@time begin ordenado_insertion_sort = funcoes_ordenacao.insertionsort!(entrada_vetorial) end #time
