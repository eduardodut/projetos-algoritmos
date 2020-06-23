module Ordenacao_Estrutural

using Juno

export organizar_indices

function organizar_indices(
    n_total_meses::Int64,
    m_total_empresas::Int64,
)::Array{Int64}

    sequencia_pa = [n_total_meses:-1:1;]

    function n_contratos_anteriores(n_meses::Int64)::Int64
        return sum(sequencia_pa[1:n_meses-1])
    end # function
    function n_contratos_empresas_anteriores(n_empresa_atual::Int64)::Int64
        x = (n_empresa_atual - 1)
        return (1 / 2) * n_total_meses * (x * n_total_meses + x)
    end


    indices_organizados = Array{Int64}(undef, 0)
    Juno.@progress for i = 1:n_total_meses
        vetor = ([1:1:n_total_meses-i+1;] .+ n_contratos_anteriores(i))
        Juno.@progress for j = 1:m_total_empresas
            aux = vetor .+ n_contratos_empresas_anteriores(j)
            if length(indices_organizados) == 0
                indices_organizados = aux
            else
                indices_organizados = cat(indices_organizados, aux, dims = 1)
            end # if
        end
    end
    return indices_organizados
end


end
