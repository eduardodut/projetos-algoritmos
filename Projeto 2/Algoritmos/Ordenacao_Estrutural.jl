module Ordenacao_Estrutural

using Juno

export organizar_indices

function organizar_indices(
    vetor::Array{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
    n::Int64,
)::Array{Tuple{Int64,Int64,Int64,Float64}}

    # m = vetor[end][1]
    # n = vetor[end][3]
    # resultado = similar(vetor_entrada)


    tamanho_array = length(vetor)


    vetor_indices = [1:1:tamanho_array;]



    # contratos = Int(n * (n + 1) / 2)
    #s
    # total_linhas = contratos * m_total_empresas
    a = [1:1:tamanho_array;]

    b = reshape(a, n, m)


    c = reshape(b', 1, tamanho_array)
    vetor_ordenado = vec(c)

    return vetor[vetor_ordenado]



end # function

end
