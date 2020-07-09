module Algoritmos_Ordenacao
using Juno
import Base.Threads.@spawn
export insertionsort,
    mergesort!,
    heapsort!,
    quicksort!,
    dividir_e_ordenar,
    dividir_e_ordenar2,
    intercalacao_heap_max,
    intercalar_k_vetores_ordenados

#--- INSERTION SORT
function insertionsort!(A::Array{Tuple{Int64,Int64,Int64,Float64}})

    for i = 2:length(A)
        #atribuição da chave de comparação
        chave = A[i]
        #
        j = i - 1

        #comparação do atributo valor ([4]) do elemento chave com os
        #valores de contrato dos elementos anteriores e
        #reposicionamento dos elementos com valores maiores

        while j > 0 && A[j][4] > chave[4]
            A[j+1] = A[j]
            j = j - 1
        end


        #posicionamento final da chave atual

        A[j+1] = chave

    end#fim da ordenação
    return A
end
#--- MERGESORT


function mergesort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return mergesort!(A)
end

function mergesort!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    # se o vetor de entrada tiver comprimento de 1, retorna ele mesmo
    if length(vetor_entrada) ≤ 1
        return vetor_entrada
    end
    #calcula o ponto médio do vetor de entrada para sua subdivisão

    p_medio = length(vetor_entrada) ÷ 2

    #chamada de recursão para o vetor da esquerda
    t = @spawn mergesort!(vetor_entrada[1:p_medio])
    # parte_esquerda = mergesort!(vetor_entrada[1:p_medio])
    #chamada de recursão para o vetor da direita
    parte_direita = mergesort!(vetor_entrada[p_medio+1:end])
    #formata o resultado para ser similar ao vetor de entrada
    parte_esquerda = fetch(t)
    return integrar(parte_esquerda, parte_direita)


end

function integrar(
    parte_esquerda::Array{Tuple{Int64,Int64,Int64,Float64}},
    parte_direita::Array{Tuple{Int64,Int64,Int64,Float64}},
)
    i = indice_direita = indice_esquerda = 1
    resultado = Array{Tuple{Int64,Int64,Int64,Float64}}(
        undef,
        length(parte_direita) + length(parte_esquerda),
    )
    #ordenação entre a parte esquerda e parte direita dos subvetores
    #enquanto não se chegar ao fim de cada vetor, continua comparando até ordenar
    #os elementos entre os subvetores

    while indice_esquerda ≤ length(parte_esquerda) &&
        indice_direita ≤ length(parte_direita)

        if parte_esquerda[indice_esquerda][4] ≤ parte_direita[indice_direita][4]
            # append!(resultado, parte_esquerda[indice_esquerda])
            resultado[i] = parte_esquerda[indice_esquerda]
            indice_esquerda += 1
        else
            # append!(resultado, parte_direita[indice_direita])
            resultado[i] = parte_direita[indice_direita]
            indice_direita += 1
        end
        i += 1
    end

    #Completa o vetor Resultado com o restante dos vetores da direita ou da esquerda
    #que não foram previamente inseridos.

    #caso o vetor da esquerda tenha sido completamente inserido,
    #o vetor da direita será integrado ao resultado
    if indice_esquerda > length(parte_esquerda)

        resultado[i:end] = parte_direita[indice_direita:end]

    else
        resultado[i:end] = parte_esquerda[indice_esquerda:end]
    end

    return resultado

end # function




#--- Heapsort

#função auxiliar para realizar a troca de posição entre dois elementos
@inline function troca_elementos!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end


# function max_heapify!(
#     vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
#     primeiro::Int64,
#     ultimo::Int64,
# )   #c = 2*363000-1 = 726599 e last = 726000 na primeira iteração. c referencia elemento de posição à direita do heap
#     # c = 2 * primeiro - 1
#     @inbounds while (c = 2 * primeiro - 1) < ultimo
#     # while c < ultimo
#         #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
#         #                              1                      2
#         if c < ultimo && vetor_entrada[c][4] < vetor_entrada[c+1][4]
#             #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
#             c += 1
#         end
#         #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
#                             # 1                       1 ou 2
#         if vetor_entrada[primeiro][4] < vetor_entrada[c][4]
#             troca_elementos!(vetor_entrada, c, primeiro)
#             primeiro = c
#         else
#             break
#         end
#     end
# end

function max_heapify!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    i::Int64,
    tam_heap::Int64,
)
    maior = i
    l = 2 * i
    r = 2 * i + 1
    # tam_heap = length(vetor_entrada)

    if l <= tam_heap && vetor_entrada[l][4] > vetor_entrada[i][4]
        maior = l
    else
        maior = i
    end
    if r <= tam_heap && vetor_entrada[r][4] > vetor_entrada[maior][4]
        maior = r
    end
    if maior != i
        troca_elementos!(vetor_entrada, i, maior)
        max_heapify!(vetor_entrada, maior, tam_heap)
    end
end



function build_max_heap!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    #726000÷2 = 363000
    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        # max_heapify!(vetor_entrada, i, length(vetor_entrada))
        max_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

function heapsort!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})


    #inicia a construção do primeiro heap max
    build_max_heap!(vetor_entrada)
    tam_heap = length(vetor_entrada)
    @inbounds for i in [length(vetor_entrada):-1:2;] #
        #troca a posição do primeiro nó com o último nó do heap
        troca_elementos!(vetor_entrada, 1, i)
        tam_heap -= 1
        #reconstitui o heap após o swap do primeiro e ultimo nó pela linha anterior
        # max_heapify!(vetor_entrada, 1, i - 1)
        max_heapify!(vetor_entrada, 1, tam_heap)
    end

    return vetor_entrada
end


#--- Quicksort
function quicksort!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    i::Int64,
    j::Int64,
)
    if j > i
        pivô = vetor_entrada[rand(i:j)] # elemento aleatório do vetor
        esquerda, direita = i, j
        while esquerda <= direita
            while vetor_entrada[esquerda][4] < pivô[4]
                esquerda += 1
            end
            while vetor_entrada[direita][4] > pivô[4]
                direita -= 1
            end
            if esquerda <= direita
                troca_elementos!(vetor_entrada, esquerda, direita)

                esquerda += 1
                direita -= 1
            end
        end
        # t = @spawn
        quicksort!(vetor_entrada, i, direita)
        quicksort!(vetor_entrada, esquerda, j)
        # fetch(t)
    end

    return vetor_entrada
end


#---Letra k
##--- Ordenação individual por empresa
function dividir_e_ordenar(
    vetor_entrada::Vector{Tuple{Int64,Int64,Int64,Float64}},
    funcao_ordenacao,
    paralelizar::Bool,
)::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1}
    m = vetor_entrada[end][1]
    n = vetor_entrada[end][3]

    elementos_heap = Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}(undef, m)
    n_contratos = Int64(n * (n + 1) / 2)

    vetor_indices =
        [[1+(i-1)*n_contratos:1:n_contratos+(i-1)*n_contratos;] for i = 1:m]


    tasks = Vector{Task}(undef, m)

    if paralelizar == true
        #com paralelismo
        for i = 1:m
            tasks[i] = @spawn funcao_ordenacao(vetor_entrada[vetor_indices[i]])
        end
        map(x -> elementos_heap[x] = fetch(tasks[x]), 1:m)

    else
        #sem paralelismo
        for i = 1:m
            # c = (i - 1) * n_contratos
            indices_empresa = vetor_indices[i]
            elementos_heap[i] = funcao_ordenacao(vetor_entrada[indices_empresa])
        end
    end

    return elementos_heap
end
#
function dividir_e_ordenar2(
    vetor_entrada::Vector{Tuple{Int64,Int64,Int64,Float64}},
    funcao_ordenacao,
    paralelizar::Bool,
    k::Int64,# número de divisões antes da ordenação
)#::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1}

    elementos_heap = Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}(undef, k)
    n_elementos_por_vetor = length(vetor_entrada) ÷ k #
    n_elementos_ultimo_vetor =
        length(vetor_entrada) - (k - 1) * n_elementos_por_vetor
    ind_inicial = 1

    vetor_indices = Array{Array{Int64,1},1}(undef, k)

    for i = 1:k-1
        vetor_indices[i] = [
            1+(i-1)*n_elementos_por_vetor:1:n_elementos_por_vetor+(i-1)*n_elementos_por_vetor;
        ]
    end

    # vetor_indices = [
    #     [
    #         1+(i-1)*n_elementos_por_vetor:1:n_elementos_por_vetor+(i-1)*n_elementos_por_vetor;
    #     ] for i = 1:k-1
    # ]

    vetor_indices[k] = [
        vetor_indices[k-1][end]+1:1:vetor_indices[k-1][end]+n_elementos_ultimo_vetor;
    ]


    tasks = Vector{Task}(undef, k)

    if paralelizar == true
        #com paralelismo
        for i = 1:k
            tasks[i] = @spawn funcao_ordenacao(vetor_entrada[vetor_indices[i]])
        end

        map(x -> elementos_heap[x] = fetch(tasks[x]), 1:k)

    else
        #sem paralelismo
        for i = 1:k
            # c = (i - 1) * n_contratos
            indices_empresa = vetor_indices[i]
            elementos_heap[i] = funcao_ordenacao(vetor_entrada[indices_empresa])
        end
    end

    return elementos_heap
end

##---intercalação de k vetores ordenados
function intercalar_k_vetores_ordenados(
    vetores::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    m = length(vetores)
    # tamanho_saida = m * length(vetores[1])
    tamanho_saida = sum(length.(vetores))


    build_min_heap!(vetores)
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, tamanho_saida)

    @inbounds for i = 1:length(saida)
        saida[i] = popfirst!(vetores)
        if length(vetores[1]) == 0
            vetores[1] = [(0, 0, 0, Float64(Inf64))]
            troca_elementos!(vetores, 1, m)
        end

        min_heapify!(vetores, 1, m)
    end
    return saida
end


Base.popfirst!(x::Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}) =
    length(x[1]) > 0 ? popfirst!(x[1]) : (0, 0, 0, Float64(Inf64))


@inbounds function troca_elementos!(
    vetor_entrada::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end



function min_heapify!(
    vetor_entrada::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
    primeiro::Int64,
    ultimo::Int64,
)
    @inbounds while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo && vetor_entrada[c] > vetor_entrada[c+1]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[primeiro] > vetor_entrada[c]
            troca_elementos!(vetor_entrada, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end


function build_min_heap!(
    vetor_entrada::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1},
)


    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        min_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

### --- Definição de operações com tuplas de 4 elementos Tuple{Int64,Int64,Int64,Float64}
#### menor que
Base.isless(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] < y[4]
Base.:<(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] < y[4]
#### maior que
Base.isgreater(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] > y[4]
Base.:>(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] > y[4]
#### igualdade
Base.isequal(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] == y[4]
Base.isequal(x::Tuple{Int64,Int64,Int64,Float64}, y::Float64) = x[4] == y

Base.:!=(
    x::Tuple{Int64,Int64,Int64,Float64},
    y::Tuple{Int64,Int64,Int64,Float64},
) = x[4] != y[4]
Base.iszero(t::Tuple{Int64,Int64,Int64,Float64}) = isequal(t[4], 0.0)

Base.copy(t1::Tuple{Int64,Int64,Int64,Float64}) = (t1[1], t1[2], t1[3], t1[4])

### Operação com vetor de tuplas
#### menor que
Base.isless(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? true : isless(x[1], y[1])
Base.:<(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? true : isless(x[1], y[1])
#### maiorque
Base.isgreater(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? false : x[1] > y[1]
Base.:>(
    x::Vector{Tuple{Int64,Int64,Int64,Float64}},
    y::Vector{Tuple{Int64,Int64,Int64,Float64}},
) = length(x[1]) == 0 ? false : x[1] > y[1]


##--- Ordenação por heap 2D

function intercalacao_heap_max(
    entrada_matricial::Array{Float64,3},
    paralelizar::Bool,
)::Array{Array{Tuple{Int64,Int64,Int64,Float64},1},1}
    m = size(entrada_matricial, 1)
    n = size(entrada_matricial, 2)
    n_contratos = Int64(n * (n + 1) / 2)

    elementos_heap = Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}(undef, m)
    if paralelizar == true
        tasks = Vector{Task}(undef, 100)
        for i = 1:m
            tasks[i] = @spawn ordenar_empresa_individual(entrada_matricial, i)
            # tasks[i] = @spawn ordenar_empresa_individual(dados_empresas[i])
        end
        map(x -> elementos_heap[x] = fetch(tasks[x]), 1:m)

    else
        elementos_heap =
            map(x -> ordenar_empresa_individual(entrada_matricial, x), 1:m)
        # map(x -> ordenar_empresa_individual(dados_empresas[x]), 1:m)
    end

    return elementos_heap
end

function ordenar_empresa_individual(
    entrada_matricial::Array{Float64,3},
    empresa::Int64,
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    matriz = [
        entrada_matricial[empresa, :, x]
        for x in [size(entrada_matricial, 2):-1:1;]
    ]

    # matriz = entrada_matricial
    mes_final = size(entrada_matricial, 2)
    vetor_indices = map(x -> (1, x), [size(entrada_matricial, 2):-1:1;])
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(
        undef,
        Int64(
            size(entrada_matricial, 2) * (size(entrada_matricial, 2) + 1) / 2,
        ),
    )

    @inbounds for j in [length(saida):-1:1;]
        contrato = (empresa, vetor_indices[1]..., popfirst!(matriz[1]))
        saida[j] = contrato
        #remove o valor máximo
        append!(matriz[1], Float64(-Inf))
        #aumenta o mês inicial da coluna que teve o valor copiado
        # if vetor_indices[end][1] < vetor_indices[end][2]
        vetor_indices[1] = vetor_indices[1] .+ (1, 0)
        # end

        if matriz[1][1] < matriz[2][1] || matriz[1][1] < matriz[3][1]
            max_heapify!(matriz, vetor_indices, 1, 120)
        end

    end

    return saida
end

@inline function troca_elementos!(
    vetor_entrada::Array{Array{Float64,1},1},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end
@inline function troca_elementos!(
    vetor_entrada::Array{Tuple{Int64,Int64},1},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end

function max_heapify!(
    vetor_entrada::Array{Array{Float64,1},1},
    vetor_indices::Array{Tuple{Int64,Int64},1},
    primeiro::Int64,
    ultimo::Int64,
)   #c = 2*363000-1 = 726599 e last = 726000 na primeira iteração. c referencia elemento de posição à direita do heap
    @inbounds while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo && vetor_entrada[c][1] < vetor_entrada[c+1][1]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[primeiro][1] < vetor_entrada[c][1]
            troca_elementos!(vetor_entrada, c, primeiro)
            troca_elementos!(vetor_indices, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end



end#module
