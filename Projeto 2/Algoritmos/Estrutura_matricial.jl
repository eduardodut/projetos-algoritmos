module name

Base.isless(x::Float64, t::Tuple{Int64,Int64,Int64,Float64}) = return isless(x,t[4])
Base.isless( t::Tuple{Int64,Int64,Int64,Float64}, x::Float64) = return isless(t[4],x)
Base.isless(t1::Tuple{Int64,Int64,Int64,Float64}, t2::Tuple{Int64,Int64,Int64,Float64}) = isless(t1[4],t2[4])
Base.isequal(t1::Tuple{Int64,Int64,Int64,Float64}, t2::Tuple{Int64,Int64,Int64,Float64}) = isequal(t1[4],t2[4])
Base.:>(t1::Tuple{Int64,Int64,Int64,Float64}, t2::Tuple{Int64,Int64,Int64,Float64}) = >(t1[4],t2[4])
Base.:<(t1::Tuple{Int64,Int64,Int64,Float64}, t2::Tuple{Int64,Int64,Int64,Float64}) = <(t1[4],t2[4])
Base.copy(t1::Tuple{Int64,Int64,Int64,Float64}) = (t1[1],t1[2],t1[3],t1[4])
Base.copy(t1::Tuple{Int64,Float64}) = (t1[1],t1[2])

mutable struct Matriz_Contratos
    dados::Array{Tuple{Int64,Int64,Int64,Float64},2}
    elemento_max::Tuple{Int64,Int64,Int64,Float64}
    valor_elemento_max::Float64
    Matriz_Contratos(matriz::Array{Tuple{Int64,Int64,Int64,Float64},2}) = new(matriz, matriz[1,size(matriz)[1]], matriz[1,size(matriz)[1]][4])
end

function vizinho_maximo(dados::Array{Tuple{Int64,Int64,Int64,Float64},2},indice_elemento::Tuple{Int64,Int64} )::Tuple{Int64,Int64}
    function valida_indice(indice_elemento::Tuple{Int64,Int64}, n_max::Int64)::Tuple{Int64,Int64}
        if 0 < indice_elemento[1] < n_max + 1 &&  0 < indice_elemento[2] < n_max + 1
            return indice_elemento
        else
            return (n_max,1)
        end
    end
    n_max = size(dados)[1]
    valida_indice(indice_elemento::Tuple{Int64,Int64}) = valida_indice(indice_elemento, n_max)

    indice_vizinhos = Array{Tuple{Int64,Int64}}(undef, 2)
    indice_vizinhos[1] = valida_indice(indice_elemento .+ (0,-1))   #esquerda
    indice_vizinhos[2] = valida_indice(indice_elemento .+ (1,0))    #inferior
    # indice_vizinhos[3] = valida_indice(indice_elemento .+ (1,-1))   #diagonal

    valor_contrato_esquerda = dados[indice_vizinhos[1][1],indice_vizinhos[1][2]]
    valor_contrato_inferior = dados[indice_vizinhos[2][1],indice_vizinhos[2][2]]
    # valor_contrato_diagonal = dados[indice_vizinhos[3][1],indice_vizinhos[3][2]]
    _, indice_vizinho_maximo = findmax([valor_contrato_esquerda, valor_contrato_inferior]) #valor_contrato_diagonal,

    return (indice_vizinhos[indice_vizinho_maximo][1], indice_vizinhos[indice_vizinho_maximo][2])
end

#entra uma matriz com o elemento (1,120) vazio e ocupa com o maior vizinho
#e assim recursivamente
function reorganizar_matriz!(dados::Array{Tuple{Int64,Int64,Int64,Float64},2}, elemento_faltante::Tuple{Int64,Int64})::Tuple{Int64,Int64,Int64,Float64}
    dados[elemento_faltante[1], elemento_faltante[2]] = (0,0,0,0.0)
    indice_maior_vizinho = vizinho_maximo(dados,elemento_faltante)
    maior_vizinho = dados[indice_maior_vizinho[1],indice_maior_vizinho[2]]
    if maior_vizinho > 0.0
        dados[elemento_faltante[1], elemento_faltante[2]] = maior_vizinho

        reorganizar_matriz!(dados, indice_maior_vizinho)
    end

    if isequal(maior_vizinho,0.0)
        return
    end
    return dados[elemento_faltante[1], elemento_faltante[2]]
end

reorganizar_matriz!(dados::Array{Tuple{Int64,Int64,Int64,Float64},2})::Tuple{Int64,Int64,Int64,Float64} = (return reorganizar_matriz!(dados,(1,size(dados)[1]));)


function retira_valor_maximo!(matriz::Matriz_Contratos)::Tuple{Int64,Int64,Int64,Float64}
    saida = matriz.elemento_max
    matriz.elemento_max = reorganizar_matriz!(matriz.dados)
    matriz.valor_elemento_max = matriz.elemento_max[4]
    return saida
end

function retira_n_valores!(matriz::Matriz_Contratos, n::Int64)::Vector{Tuple{Int64,Int64,Int64,Float64}}
    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, n)
    for i = 1:n
        saida[i] = retira_valor_maximo!(matriz)
    end
    return saida
end




mutable struct Arvore_Matrizes
    vetor_matrizes::Vector{Matriz_Contratos}
    ponteiro_arvore::Vector{Tuple{Int64,Float64}}

    function Arvore_Matrizes(entrada_matricial::Array{Tuple{Int64,Int64,Int64,Float64},3})
        dados = Vector{Matriz_Contratos}(undef, size(entrada_matricial)[1])
        ponteiro_arvore = Vector{Tuple{Int64,Float64}}(undef, size(entrada_matricial)[1])
        for j in 1:size(entrada_matricial)[1]
            dados[j] = Matriz_Contratos(entrada_matricial[j,:,:])
            ponteiro_arvore[j] = (j, dados[j].valor_elemento_max)
        end

        build_max_heap!(ponteiro_arvore)

        new(dados, ponteiro_arvore)
    end

end

function retira_valor_maximo!(arvore::Arvore_Matrizes)::Tuple{Int64,Int64,Int64,Float64}
    indice_empresa_topo_heap = arvore.ponteiro_arvore[1][1]
    matriz_selecionada = arvore.vetor_matrizes[indice_empresa_topo_heap]
    maior_contrato = retira_valor_maximo!(matriz_selecionada)

    #modifica o valor associado à matriz para o próximo valor da mesma
    arvore.ponteiro_arvore[1] = (indice_empresa_topo_heap, matriz_selecionada.valor_elemento_max)

    #reconstitui a ordem em heap das matrizes
    max_heapify!(arvore.ponteiro_arvore, 1, length(arvore.ponteiro_arvore))

    return maior_contrato
end

function build_max_heap!(vetor_entrada::Vector{Tuple{Int64,Float64}})

    f = length(vetor_entrada) ÷ 2
    for i in [f:-1:1;]
        # while f >= 1
        max_heapify!(vetor_entrada, i, length(vetor_entrada))
        # f -= 1
    end
end

function max_heapify!(
    vetor_entrada::Array{Tuple{Int64,Float64}},
    primeiro::Int64,
    ultimo::Int64,
)
    while (c = 2 * primeiro - 1) < ultimo
        #se c for anterior a c e o valor do vetor na posição c for menor que o posterior
        if c < ultimo && vetor_entrada[c][2] < vetor_entrada[c+1][2]
            #aumenta c em 1 para referenciar a próxima posição, para indicar que o elemento
            c += 1
        end

        if vetor_entrada[primeiro][2] < vetor_entrada[c][2]
            troca_elementos!(vetor_entrada, c, primeiro)
            primeiro = c
        else
            break
        end
    end
end

function troca_elementos!(
    vetor_entrada::Array{Tuple{Int64,Float64}},
    i::Int64,
    j::Int64,
)
    vetor_entrada[i], vetor_entrada[j] = vetor_entrada[j], vetor_entrada[i]
end

@benchmark for i in 1:100
 Arvore_Binaria_2d($entrada_matricial[i,:,:])
end
@benchmark Arvore_Matrizes($entrada_matricial)
@benchmark retira_valor_maximo!(Arvore_Matrizes($entrada_matricial))
arvore.ponteiro_arvore[85]

function vetor_ordenado(arvore::Arvore_Matrizes)
    array_ordenado = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, 726000)
    proximo_valor = arvore.ponteiro_arvore[1][2]
    i = 726000
    while proximo_valor > 0.0
        array_ordenado[i] = retira_valor_maximo!(arvore)

        proximo_valor = arvore.ponteiro_arvore[1][2]
        i-=1
    end
    return array_ordenado
end

function find_amax(vec::Vector{Matriz_Contratos})::Int64
    m = length(vec)
    arr = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, m)
    for empresa = 1:m
        arr[empresa] = vec[empresa].elemento_max
    end
    maxind, maxval = firstindex(arr), first(arr)
    for (i, x) in enumerate(arr)
        if x > maxval
            maxind, maxval = i, x
        end
    end
    return maxind
end

function ordenar(entrada_matricial::Array{Tuple{Int64,Int64,Int64,Float64},3})
    tamanho_saida = Int64(size(entrada_matricial)[1]*size(entrada_matricial)[2]*(size(entrada_matricial)[2]+1)/2) #72600

    saida = Vector{Tuple{Int64,Int64,Int64,Float64}}(undef, tamanho_saida)


    dados = Vector{Matriz_Contratos}(undef, size(entrada_matricial)[1])

    for j in 1:size(entrada_matricial)[1]
        dados[j] = Matriz_Contratos(entrada_matricial[j,:,:])
    end
    iterador = Iterators.Stateful([tamanho_saida:-1:1;])
    Juno.@progress for i in iterador
        indice = find_amax(dados)
        saida[i] = retira_valor_maximo!(dados[indice])
    end

    return saida

end

@time a = ordenar(entrada_matricial)

a[1].valor_elemento_max


@benchmark for i in [726000:-1:1;]
    array_ordenado[i] = retira_valor_maximo!($arvore)
end
@benchmark retira_valor_maximo!(arvore)
build_max_heap!(arvore.ponteiro_arvore)



#--- Teste do conceito de ordenação individual de cada matriz

using DataFrames, BenchmarkTools, Juno

include("Inicializacao.jl")
entrada_matricial = Inicializacao.inicializar_variaveis("Dados/entrada.txt")[1]

@benchmark matriz = Matriz_Contratos(entrada_matricial[1,:,:])

@benchmark retira_valor_maximo!(Matriz_Contratos($entrada_matricial[1,:,:]))

array_ordenado = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, 7260)
for j in 1:size(entrada_matricial)[1]
    println(j)
end
@benchmark for j in 1:100
    empresa_atual = Matriz_Contratos($entrada_matricial[j,:,:])
end

empresa_atual = Matriz_Contratos(entrada_matricial[1,:,:])

@benchmark for i in [7260:-1:1;]
    @benchmark $array_ordenado[1] = retira_valor_maximo!($empresa_atual)
end

empresa_atual = Matriz_Contratos(entrada_matricial[1,:,:])

array_ordenado = Array{Tuple{Int64,Int64,Int64,Float64},1}(undef, 7260)
@time begin
for i in [7260:-1:1;]

    array_ordenado[i] = @benchmark retira_valor_maximo!($empresa_atual)

end
end

@benchmark retira_n_valores!(empresa_atual, 1)







for j in 1:100
    empresa_atual = Matriz_Contratos(entrada_matricial[j,:,:])
    max = empresa_atual.valor_elemento_max
    for i in [7260:-1:1;]
        array_ordenado[i] = retira_valor_maximo!(empresa_atual)

        if array_ordenado[i][4] > max
            println(array_ordenado[i][4])
            println(max)
            println("Empresa ", j, " não ordenada")
            break
        end
        if i == 1 && array_ordenado[7260][4] == max
            println("Empresa ", j, " está ordenada")
        end
    end

end
