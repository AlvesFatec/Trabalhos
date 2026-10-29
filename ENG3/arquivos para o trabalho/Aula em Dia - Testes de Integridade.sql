-- AULA EM DIA - TESTE ACADEMICO DE INTEGRIDADE
-- Execute APOS o script principal em uma instancia PostgreSQL.
-- Usa dados ficticios e desfaz todas as alteracoes ao terminar.
BEGIN;
SET search_path TO aula_em_dia, public;
DO $$
DECLARE
    v_prof BIGINT;
    v_disc BIGINT;
    v_turma BIGINT;
    v_assoc BIGINT;
    v_plano BIGINT;
    v_total INTEGER;
BEGIN
    INSERT INTO usuarios (nome, email, senha_hash)
    VALUES ('Docente Exemplo', 'teste-aulaemdia@exemplo.invalid',
            'hash-ficticio-apenas-para-teste-academico')
    RETURNING id_usuario INTO v_prof;

    INSERT INTO disciplinas (nome)
    VALUES ('Disciplina Ficticia de Teste')
    RETURNING id_disciplina INTO v_disc;

    INSERT INTO turmas (id_professor, nome, ano_letivo, etapa_ensino)
    VALUES (v_prof, 'Turma Ficticia', 2026, 'Ensino Fundamental')
    RETURNING id_turma INTO v_turma;

    INSERT INTO turma_disciplinas (id_turma, id_disciplina)
    VALUES (v_turma, v_disc)
    RETURNING id_turma_disciplina INTO v_assoc;

    INSERT INTO planos_aula
      (id_autor, id_turma_disciplina, titulo, tema, duracao_minutos)
    VALUES (v_prof, v_assoc, 'Plano Ficticio', 'Modelagem de Dados', 50)
    RETURNING id_plano INTO v_plano;

    INSERT INTO objetivos_plano (id_plano, ordem, descricao)
    VALUES (v_plano, 1, 'Compreender o problema proposto');
    INSERT INTO conteudos_plano (id_plano, ordem, descricao)
    VALUES (v_plano, 1, 'Introducao a entidades e atributos');
    INSERT INTO atividades_plano (id_plano, ordem, descricao)
    VALUES (v_plano, 1, 'Discussao em grupo');

    INSERT INTO sugestoes_ia
      (id_plano, comando_usuario, texto_sugerido)
    VALUES (v_plano, 'Propor uma atividade sobre modelagem',
            'Rascunho ficticio para demonstracao');

    INSERT INTO versoes_plano (id_plano, numero_versao, conteudo_json)
    VALUES (v_plano, 1, '{"titulo":"Plano Ficticio","versao":1}'::jsonb);

    SELECT count(*) INTO v_total FROM vw_historico_planos
    WHERE id_plano = v_plano AND id_autor = v_prof;

    IF v_total <> 1 THEN
        RAISE EXCEPTION 'Falha de teste: historico nao retornou um plano';
    END IF;
    RAISE NOTICE 'Cenario executado dentro da transacao: OK';
END;
$$;
ROLLBACK;
-- O ROLLBACK desfaz todos os dados de teste.
