module Inicializacao
using Juno

export inicializar_variaveis

function inicializar_variaveis(caminho::String)
    linhas = readlines(caminho)
    parametros_iniciais = split(linhas[1], " ")
    n = parse(Int64, parametros_iniciais[1])
    m = parse(Int64, parametros_iniciais[2])
    t = parse(Float64, parametros_iniciais[3])
    linhas = linhas[2:end]
    entrada_vetorial =
        Array{Tuple{Int64,Int64,Int64,Float64}}(undef, length(linhas))


    entrada_matricial = Array{Float64,3}(undef, m, n, n)

    Juno.@progress for i = 1:length(linhas)
        dados = split(linhas[i], " ")
        empresa = parse(Int64, dados[1])
        mes_inicial = parse(Int64, dados[2])
        mes_final = parse(Int64, dados[3])
        valor = parse(Float64, dados[4])
        entrada_vetorial[i] = (empresa, mes_inicial, mes_final, valor)
        entrada_matricial[empresa, mes_inicial, mes_final] = valor

    end # for

    return (entrada_matricial, entrada_vetorial, m, n)

end # function

end
