module Ordenacao
include("Inicializacao.jl")
include("Arvores_Recursivas.jl")

using Juno, Statistics, BenchmarkTools

using Base.Threads: nthreads, @spawn, @sync, @threads

export insertionsort,
    mergesort,
    heapsort,
    quicksort,
    teste_ordenacao,
    custom_sort,
    custom_sort2,
    merge_vetores_ordenados,
    ordenar

#--- INSERTION SORT
function insertionsort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return insertionsort!(A)
end

function insertionsort!(A::Array{Tuple{Int64,Int64,Int64,Float64}})

    @inbounds Juno.@progress for i = 2:length(A)
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
#--- mergesort
function mergesort_por_empresa(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
)

    resultado = similar(vetor_entrada)

    vetores_ordenados_por_empresa = similar(vetor_entrada)

    tamanho_array = length(vetor_entrada)
    m = 100
    tamanho_array = 726000

    vetor_indices = [1:1:tamanho_array;]

    n_colunas = Int(tamanho_array / m)

    matriz_indices = reshape(vetor_indices, n_colunas, m)
    matriz_indices[:, 100][1]
    # entrada_vetorial =
    # Array{Tuple{Int64,Int64,Int64,Float64}}(undef, length(linhas))


    @inbounds for i = 1:m
        vetores_ordenados_por_empresa[matriz_indices[:, i]] =
            mergesort(vetor_entrada[matriz_indices[:, i]])

    end

    return mergesort(vetores_ordenados_por_empresa)
    # vetor_indices = vec(ones(Int64, 1, m))
    #
    # lista_empresas = [1:1:m;]
    #
    #
    #
    # separa_contratos_ordenados_empresas(x::Int64) =
    #     vetores_ordenados_por_empresa[matriz_indices[:, x]]
    # empresas_ordenadas = map(separa_contratos_ordenados_empresas, [1:1:m;])
    #
    #
    #
    # busca_empresa_individual(i) = empresas_ordenadas[i][1][4]
    # i = 1
    # while length(lista_empresas) > 1
    #
    #
    #     lista_comparacao = map(busca_empresa_individual, lista_empresas)
    #
    #     valor_min, indice = findmin(lista_comparacao)
    #
    #     resultado[i] = empresas_ordenadas[indice][1]
    #
    #     popfirst!(empresas_ordenadas[indice])
    #
    #     if length(empresas_ordenadas) == 0
    #         delete!(lista_empresas, indice)
    #     end
    #
    #
    #
    #     i += 1
    # end
    #
    # resultado[i:end] = empresas_ordenadas[lista_empresas[1]][1:end]
    #
    # return resultado
end




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
    parte_esquerda = mergesort!(vetor_entrada[1:p_medio])
    #chamada de recursão para o vetor da direita
    parte_direita = mergesort!(vetor_entrada[p_medio+1:end])
    #formata o resultado para ser similar ao vetor de entrada

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


function max_heapify!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    primeiro::Int64,
    ultimo::Int64,
)   #c = 2*363000-1 = 726599 e last = 726000 na primeira iteração. c referencia elemento de posição à direita do heap
    @inbounds while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo && vetor_entrada[c][4] < vetor_entrada[c+1][4]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end
        #first é 363000 na primeira iteração e c pode referenciar o último ou o penúltimo item, a depender do ultimo "if"
        if vetor_entrada[primeiro][4] < vetor_entrada[c][4]
            troca_elementos!(vetor_entrada, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end


function build_max_heap!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    #726000÷2 = 363000
    f = length(vetor_entrada) ÷ 2
    @inbounds for i in [f:-1:1;]
        # while f >= 1
        max_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

function heapsort!(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})


    #inicia a construção do primeiro heap max
    build_max_heap!(vetor_entrada)

    @inbounds for l in [length(vetor_entrada):-1:2;] #
        #troca a posição do primeiro nó com o último nó do heap
        troca_elementos!(vetor_entrada, 1, l)

        #reconstitui o heap após o swap do primeiro e ultimo nó pela linha anterior
        max_heapify!(vetor_entrada, 1, l - 1)
    end

    return vetor_entrada
end


function heapsort(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

    A = copy(vetor_entrada)

    return heapsort!(A)
end


# #--- Quicksort
#


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



function quicksort(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    otimo::Bool = false,
)

    A = copy(vetor_entrada)

    otimo == true ? (return quicksort_otimizado!(A, 1, length(A))) :
    (return quicksort!(A, 1, length(A)))



end

function quicksort_otimizado!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    i::Int64,
    j::Int64,
)

    if j > i
        # (726000 -1)÷ 2 + 1
        indice_pivô = (j - i) ÷ 2 + 1 #mediana do vetor
        pivô = vetor_entrada[indice_pivô] # elemento aleatório do vetor

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

function teste_ordenacao(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})
    aux = vetor_entrada[1][4]
    i = 2
    j = length(vetor_entrada)
    while i < j
        valor_atual = vetor_entrada[i][4]
        if valor_atual >= aux
            aux = valor_atual
        else
            break
        end
        i += 1
    end

    return i == j
end


"""
    sort_divide_conquer(vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}})

divide o problema em 100(m) partes e aplica o algoritmo selecionado
"""
function sort_divide_conquer(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
)

    resultado = similar(vetor_entrada)


    tamanho_array = length(vetor_entrada)
    m = 100
    tamanho_array = 726000

    vetor_indices = [1:1:tamanho_array;]

    n_colunas = Int(tamanho_array / m)

    matriz_indices = reshape(vetor_indices, n_colunas, m)
    matriz_indices[:, 100][1]
    # entrada_vetorial =
    # Array{Tuple{Int64,Int64,Int64,Float64}}(undef, length(linhas))


    @inbounds for i = 1:m
        vetores_ordenados_por_empresa[matriz_indices[:, i]] =
            mergesort(vetor_entrada[matriz_indices[:, i]])

    end



end # function
#---Ordenação questão k
function ordenar(
    entrada_matricial::Array{Float64,3},
)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    arvore_3D = Arvores_Binarias.Arvore_Binaria_3D(entrada_matricial)
    saida =
        Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, arvore_3D.qtd_contratos)

    for i in [length(saida):-1:1;]
        saida[i] = Arvores_Binarias.proximo_item!(arvore_3D)
    end

    return saida
end


































function find_amax(vec::Vector{Array{Tuple{Int64,Int64,Int64,Float64},1}})
    m = length(vec)
    arr = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, m)
    for empresa = 1:m
        if length(vec[empresa]) > 0
            arr[empresa] = vec[empresa][1]
        else
            arr[empresa] = (1, 1, 1, -Inf)
        end
    end
    maxind, maxval = firstindex(arr), first(arr)[4]
    for (i, x) in enumerate(arr)
        if x[4] > maxval
            maxind, maxval = i, x[4]
        end
    end
    return maxind, arr[maxind]
end

Base.copy(x::Tuple{Int64,Int64,Int64,Float64}) =
    (copy(x[1]), copy(x[2]), copy(x[3]), copy(x[4]))

function find_amin(
    vec::Vector{Array{Tuple{Int64,Int64,Int64,Float64},1}},
    indice_menor_elemento::Vector{Int64},
)
    m = length(vec)
    arr = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, m)
    for (empresa, menor_valor) in enumerate(indice_menor_elemento)
        if menor_valor <= length(vec[empresa])
            arr[empresa] = vec[empresa][menor_valor]
        else
            arr[empresa] = (1, 1, 1, Inf)
        end
    end

    minind, minval = firstindex(arr), first(arr)[4]
    for (i, x) in enumerate(arr)
        if x[4] < minval
            minind, minval = i, x[4]
        end
    end

    return minind, arr[minind]
end





function custom_sort(
    vetor_entrada::Vector{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
    n::Int64,
)
    #cópia do vetor de entrada
    vetor_copia = copy(vetor_entrada)
    #instanciamento da matriz de índices
    # matriz_indices = matrix_indices(true, m, n)
    #instanciamento do vetor de saída

    #conjunto de heaps_max
    # conjunto_heap_max = copy(vetor_copia[matriz_indices])
    #vetor que rastreia o número de elementos de cada heap que ainda não foi copiado

    # j = length(saida)
    a = Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}}(undef, m)
    n_contratos = Int64(n * (n + 1) / 2)

    tarefas = Array{Task}(undef, m)

    for i in [1:1:m;]
        c = (i - 1) * n_contratos
        # indices_empresa = [n_contratos+c:-1:1+c;]
        indices_empresa = [1+c:1:n_contratos+c;]
        # aux = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, n_contratos)
        a[i] = heapsort(vetor_copia[indices_empresa])

        # a[i] = vetor_copia[indices_empresa]
        # tarefas[i] = @spawn insertionsort(vetor_copia[indices_empresa])

    end

    # for (i, tarefa) in enumerate(tarefas)
    #     a[i] = fetch(tarefa)
    # end

    # @sync map(fetch, t)

    return merge_vetores_ordenados(a)
end


function merge_vetores_ordenados(
    vetor_entrada::Vector{Vector{Tuple{Int64,Int64,Int64,Float64}}},
)
    numero_vetores = size(vetor_entrada)[1]
    tamanho_subvetor = size(vetor_entrada[1])[1]
    tamanho_saida = Int64(numero_vetores * tamanho_subvetor)
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, tamanho_saida)
    lista_indice_menor_elemento = ones(Int64, numero_vetores) #* Int64(n * (n + 1) / 2)
    for i = 1:tamanho_saida

        #encontra o heap com maior raiz: o maior contrato de cada empresa
        indice_menor_contrato, menor_contrato =
            find_amin(vetor_entrada, lista_indice_menor_elemento)
        #ordenada na ultima posição dispnível o maior contrato do heap selecionado
        saida[i] = menor_contrato
        lista_indice_menor_elemento[menor_contrato[1]] += 1

    end

    return saida

end



function custom_sort2(
    vetor_entrada::Vector{Tuple{Int64,Int64,Int64,Float64}},
    m::Int64,
    n::Int64,
)
    #cópia do vetor de entrada
    vetor_copia = copy(vetor_entrada)
    #instanciamento do vetor de saída
    saida = similar(vetor_entrada)

    n_contratos = Int64(n * (n + 1) / 2)
    #conjunto de heaps_max
    # conjunto_heap_max = vetor_copia[matriz_indices]
    #vetor que rastreia o número de elementos de cada heap que ainda não foi copiado

    #variável que referencia a posição no vetor de saída que será escrita dentro do loop
    j = length(saida)
    conjunto_arvores = Vector{Estrutura.Arvore_Binaria}(undef, m)
    b = Vector{Bool}(undef, 100)
    #construção do conjuto de árvores binárias
    @inbounds for i in [1:1:m;]# for 1
        c = (i - 1) * n_contratos
        indices_empresa = [n_contratos+c:-1:1+c;]
        # indices_empresa = [1+c:1:n_contratos+c;]
        aux = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, j)
        aux = vetor_copia[indices_empresa]
        build_max_heap!(aux)
        # b[1] = (aux == build_max_heap!(aux))

        conjunto_arvores[i] = Estrutura.Arvore_Binaria(aux)
    end#for 1

    indices_vetor_saida = [j:-1:1;]
    # loop responsável por realizar o merge dos heaps a medida que os reconstitui
    Juno.@progress for i in indices_vetor_saida #for 2
        #encontra o heap com maior raiz: o maior contrato de cada empresa

        #itera sobre todas as árvores para buscar o maior valor entre as raízes
        indice_max = 1
        maior_contrato = conjunto_arvores[1].raiz
        for k = 2:m
            if conjunto_arvores[k].raiz[4] > maior_contrato[4]
                indice_max = k
                maior_contrato = conjunto_arvores[k].raiz
            end#if
        end#for

        saida[i] = Estrutura.ceifar!(conjunto_arvores[indice_max])



    end#for 2

    return saida
end


function custom_heapsort!(
    vetor_entrada::Array{Tuple{Int64,Int64,Int64,Float64}},
)

    @inbounds for l in [length(vetor_entrada):-1:2;] #
        #troca a posição do primeiro nó com o último nó do heap
        troca_elementos!(vetor_entrada, 1, l)

        #reconstitui o heap após o swap do primeiro e ultimo nó pela linha anterior
        max_heapify!(vetor_entrada, 1, l - 1)
    end

    return vetor_entrada
end









#função para criar uma matriz de índices para separar os contratos pelas respctivas empresas
# function matrix_indices(inverter::Bool = false, m::Int64 = 100, n::Int64 = 120)
#
#     tamanho_array = Int(m * n * (n + 1) / 2)
#
#     vetor_indices = [1:1:tamanho_array;]
#
#     n_colunas = Int(tamanho_array / m)
#
#     if inverter == true
#         vetor_indices = reverse(vetor_indices)
#     end
#
#     return reverse(reshape(vetor_indices, n_colunas, m), dims = 2)
#
# end

end#module
