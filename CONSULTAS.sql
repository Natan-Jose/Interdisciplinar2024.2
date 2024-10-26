# CADASTRO DE PRESTADOR / USUARIO
DELIMITER //
CREATE PROCEDURE sp_CadastroPrestadorUsuario (
    IN p_NomePrestador VARCHAR(100),
    IN p_CodTipoPrestador TINYINT UNSIGNED,
    IN p_NomeUsuario VARCHAR(100),
    IN p_Email VARCHAR(100),
    IN p_Senha VARCHAR(255)
)
BEGIN
    DECLARE erro_sql TINYINT DEFAULT FALSE;

    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET erro_sql = TRUE;
    END;

    START TRANSACTION;

    INSERT INTO Prestador (NomePrestador, CodTipoPrestador)
    VALUES (p_NomePrestador, p_CodTipoPrestador);

    SET @v_CodPrestador = LAST_INSERT_ID();

    INSERT INTO Usuario (Nome, Email, Senha, CodPrestador)
    VALUES (p_NomeUsuario, p_Email, p_Senha, @v_CodPrestador);

    IF erro_sql = FALSE THEN
        COMMIT;
        SELECT 'Transação bem-sucedida.' AS Resultado;
    ELSE
        ROLLBACK;
        SELECT 'Transação falhou. Todos os dados foram revertidos.' AS Resultado;
    END IF;

END //
DELIMITER ;

CALL sp_CadastroPrestadorAndUsuario(p_NomePrestador, p_CodTipoPrestador, p_NomeUsuario, p_Email, p_Senha);

CALL sp_CadastroPrestadorUsuario('FLAVINHO', 1, 'FLAV21', 'FLAV@GMAIL.COM', '433');
CALL sp_CadastroPrestadorUsuario('NATAN', 2, 'JA', 'NAJ@GMAIL.COM', '433');

-- PARA TESTE
SELECT 
    p.CodPrestador AS CodPrestador,
    p.NomePrestador AS NomeCompleto, 
    u.Nome AS Usuario, 
    u.Email, 
    u.Senha, 
    tp.Funcao 
FROM 
    Prestador AS p
INNER JOIN 
    TipoPrestador AS tp ON P.CodTipoPrestador = Tp.CodTipoPrestador
INNER JOIN 
    Usuario AS u ON p.CodPrestador = U.CodPrestador;

# LOGIN
DELIMITER //
CREATE PROCEDURE sp_LoginPrestador(
    IN p_NomeUsuario VARCHAR(100),
    IN p_SenhaUsuario VARCHAR(255)
)
BEGIN
    SELECT 
        p.CodPrestador AS CodPrestador,
        u.CodUsuario AS CodUsuario,
        tp.Funcao AS FuncaoPrestador
    FROM 
        Usuario AS u
    INNER JOIN 
        Prestador AS p ON u.CodPrestador = p.CodPrestador
    INNER JOIN 
        TipoPrestador AS tp ON p.CodTipoPrestador = tp.CodTipoPrestador
    WHERE 
        u.Nome = p_NomeUsuario
        AND u.Senha = p_SenhaUsuario 
        AND u.Status = 'A'
        AND p.Status = 'A'
        AND tp.Status = 'A'; 
END //
DELIMITER ;

CALL sp_LoginPrestador(p_NomeUsuario, p_SenhaUsuario);

CALL sp_LoginPrestador('FLAV21', 433);

# CADASTRAR NOVO PACIENTE
DELIMITER //
CREATE PROCEDURE sp_CadastroPaciente(
    IN p_CodPrestador TINYINT UNSIGNED,  
    IN p_NomePaciente VARCHAR(100),
    IN p_Sexo VARCHAR(20),
    IN p_DataNascimento DATE,
    IN p_CPF VARCHAR(14),
    IN p_CPFResponsavel VARCHAR(14),
    IN p_Telefone VARCHAR(15)
)
BEGIN
    -- Verifica se o usuário é um recepcionista
    CALL sp_VerificaRecepcionista(p_CodPrestador);
    
     -- Valida se pelo menos um dos CPF está preenchido
    IF p_CPF IS NULL AND p_CPFResponsavel IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pelo menos um dos campos de CPF deve estar preenchido.';
    END IF;
    
    -- Insere o novo paciente
    INSERT INTO Paciente (NomePaciente, Sexo, DataNascimento, CPF, CPFResponsavel, Telefone)
    VALUES (p_NomePaciente, p_Sexo, p_DataNascimento, p_CPF, p_CPFResponsavel, p_Telefone);
    
    SELECT 'Paciente inserido com sucesso.' AS Resultado;
END //
DELIMITER ;

CALL sp_CadastroPaciente(p_CodPrestador, p_NomePaciente, p_Sexo, p_DataNascimento, p_CPF, p_CPFResponsavel, p_Telefone);

CALL sp_CadastroPaciente(1, 'reginaldo silva', 'Masculino', '1990-01-15', '010.070.089-00', NULL, '(11) 98765-4321');
CALL sp_CadastroPaciente(1, 'Castelo Ribeiro', 'Masculino', '1990-01-15', '000.000.009-00', NULL, '(11) 98765-4321');

# ATUALIZAR NOVO PACIENTE
DELIMITER //
CREATE PROCEDURE sp_AtualizarPaciente(
    IN p_CodPaciente INT UNSIGNED,
    IN p_CodPrestador TINYINT UNSIGNED,  
    IN p_NomePaciente VARCHAR(100),
    IN p_Sexo VARCHAR(20),
    IN p_DataNascimento DATE,
    IN p_CPF VARCHAR(14),
    IN p_CPFResponsavel VARCHAR(14),
    IN p_Telefone VARCHAR(15)
)
BEGIN
    -- Verifica se o prestador é um recepcionista
    CALL sp_VerificaRecepcionista(p_CodPrestador);
    
     -- Valida se pelo menos um dos CPF está preenchido
    IF p_CPF IS NULL AND p_CPFResponsavel IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pelo menos um dos campos de CPF deve estar preenchido.';
    END IF;
    
    UPDATE Paciente
    SET
        NomePaciente = p_NomePaciente,
        Sexo = p_Sexo,
        DataNascimento = p_DataNascimento,
        CPF = p_CPF,
        CPFResponsavel = p_CPFResponsavel,
        Telefone = p_Telefone
    WHERE 
        CodPaciente = p_CodPaciente; 
    
    SELECT 'Paciente atualizado com sucesso.' AS Resultado;
END //
DELIMITER ;

CALL sp_AtualizaPaciente(p_CodPaciente, p_CodPrestador, p_NomePaciente, p_Sexo, p_DataNascimento, p_CPF, p_CPFResponsavel, p_Telefone);

CALL sp_AtualizarPaciente(1, 1, 'João Silva', 'Masculino', '1990-01-15', '123.456.089-00', NULL, '(11) 98765-4321');

# SELECIONAR TODOS OS PACIENTES
DELIMITER //
CREATE PROCEDURE sp_SelecionarPacientes(
    IN p_CodPrestador TINYINT UNSIGNED
)
BEGIN
    -- Verifica se o prestador tem permissões comuns
    CALL sp_VerificaPermissoesComuns(p_CodPrestador);
    
    -- Seleciona os pacientes
    SELECT CodPaciente AS Fichas, NomePaciente AS Paciente, Telefone AS Contato 
    FROM Paciente;
END //
DELIMITER ;

CALL sp_SelecionarPacientes(p_CodPrestador);

CALL sp_SelecionarPacientes(1);

# FILTRAR PACIENTE POR NOME
DELIMITER //
CREATE PROCEDURE sp_BuscarPacientePorNome(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_NomeBusca VARCHAR(100)
)
BEGIN
    -- Ambos podem fazer a busca
    CALL sp_VerificaPermissoesComuns(p_CodPrestador);

    SELECT 
        CodPaciente AS Ficha, 
        NomePaciente AS Pacientes, 
        Telefone AS Contato
    FROM 
        Paciente 
    WHERE 
        NomePaciente LIKE CONCAT('%', p_NomeBusca, '%');
END //
DELIMITER ;

CALL sp_BuscarPacientePorNome(p_CodPrestador, p_NomeBusca);

CALL sp_BuscarPacientePorNome(1, 'João');

# DELETAR PACIENTE
DELIMITER //
CREATE PROCEDURE sp_DeletarPacienteSemAtendimentos(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT
)
BEGIN
    -- Declaração de variáveis
    DECLARE v_AtendimentoCount INT;

    -- Verifica se o prestador é um recepcionista
    CALL sp_VerificaRecepcionista(p_CodPrestador);

    -- Verifica se o paciente tem algum atendimento associado
    SELECT COUNT(*) INTO v_AtendimentoCount
    FROM Atendimento
    WHERE CodPaciente = p_CodPaciente;

    -- Se o paciente tiver atendimentos vinculados, lança um erro
    IF v_AtendimentoCount > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível deletar o paciente, pois ele possui atendimentos vinculados.';
    ELSE
        -- Deleta o paciente pelo código
        DELETE FROM Paciente
        WHERE CodPaciente =  p_CodPaciente
        LIMIT 1;

        SELECT 'Paciente deletado com sucesso.' AS Resultado;
    END IF;
END //
DELIMITER ;

CALL sp_DeletarPacienteSemAtendimentos(p_CodPrestador, p_CodPaciente);

CALL sp_DeletarPacienteSemAtendimentos(1, 1);

# ENVIAR PARA A TABELA ATENDIMENTO 
DELIMITER //
CREATE PROCEDURE sp_EnviarParaAtendimento(
    IN p_CodPrestador TINYINT UNSIGNED, 
    IN p_CodPaciente INT UNSIGNED
)
BEGIN
    -- Verifica se o usuário é um recepcionista
    CALL sp_VerificaRecepcionista(p_CodPrestador);
    
    -- Inserir o paciente na tabela de atendimento
    INSERT INTO Atendimento (CodPaciente, CodPrestador)
    VALUES (p_CodPaciente, p_CodPrestador);
    
    -- Mensagem de sucesso
    SELECT 'Enviado!' AS Mensagem;
END //
DELIMITER ;

CALL sp_EnviarParaAtendimento(p_CodPrestador, p_CodPaciente);

CALL sp_EnviarParaAtendimento(1, 1);

# VISUALIZAR ATENDIMENTOS - EM FILA DE ESPERA
CREATE OR REPLACE VIEW vw_VisualizarAtendimentosEmAndamento
AS
SELECT 
	a.CodAtendimento,
	DATE_FORMAT(a.DataAtendimento, '%d/%m/%Y') AS DataProcedimento,
    pr.NomePrestador AS Dentista, 
    pa.NomePaciente,
    a.TipoStatus
FROM 
    Atendimento AS a
LEFT JOIN 
    Prestador AS pr ON a.CodPrestador = pr.CodPrestador
LEFT JOIN 
    Paciente AS pa ON a.CodPaciente = pa.CodPaciente
WHERE 
    a.TipoStatus = 'EM ANDAMENTO';

SELECT * FROM vw_VisualizarAtendimentosEmAndamento;

# REMOVER DE ATENDIMENTO 
DELIMITER //
CREATE PROCEDURE sp_AnularAtendimento(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT UNSIGNED
)
BEGIN
    DECLARE p_CodAtendimento INT;
    DECLARE p_TipoStatus VARCHAR(50);
    DECLARE p_CountRelacionamentos INT;

    -- Verificar se o usuário é uma recepcionista
    CALL sp_VerificaRecepcionista(p_CodPrestador);
    
    -- Recuperar o último atendimento do paciente
    SELECT CodAtendimento INTO p_CodAtendimento
    FROM Atendimento
    WHERE CodPaciente = p_CodPaciente
    ORDER BY DataAtendimento DESC
    LIMIT 1;  

    -- Verificar se existe um atendimento
    IF p_CodAtendimento IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nenhum atendimento encontrado para o paciente.';
    END IF;

    -- Recuperar o status do atendimento
    SELECT TipoStatus INTO p_TipoStatus
    FROM Atendimento
    WHERE CodAtendimento = p_CodAtendimento;

    -- Se o atendimento está 'EM ANDAMENTO', alterar o status para 'CANCELADO'
    IF p_TipoStatus = 'EM ANDAMENTO' THEN
        UPDATE Atendimento
        SET TipoStatus = 'CANCELADO'
        WHERE CodAtendimento = p_CodAtendimento;

        SELECT 'Atendimento cancelado com sucesso!' AS Mensagem;
    ELSE
        -- Verificar se existem registros relacionados
        SELECT COUNT(*) INTO p_CountRelacionamentos
        FROM ProMed
        WHERE CodAtendimento = p_CodAtendimento;

        -- Se não houver relacionamentos, remover o atendimento
        IF p_CountRelacionamentos = 0 THEN
            DELETE FROM Atendimento
            WHERE CodAtendimento = p_CodAtendimento;
            SELECT 'Atendimento removido com sucesso!' AS Mensagem;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido deletar este atendimento, pois há registros relacionados.';
        END IF;
    END IF;
END //

DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_CancelarAtendimentos(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT UNSIGNED
)
BEGIN
    DECLARE v_Mensagem1 VARCHAR(255);
    DECLARE v_Mensagem2 VARCHAR(255);
    DECLARE v_Erro INT DEFAULT 0;

    START TRANSACTION;

    -- Chamar a primeira vez para cancelar o atendimento
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_Erro = 1;
        
        CALL sp_AnularAtendimento(p_CodPrestador, p_CodPaciente);
        
        SET v_Mensagem1 = CONCAT('Atendimento de ', p_CodPaciente, ' cancelado.');
    END;

    -- Chamar a segunda vez para remover o atendimento
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET v_Erro = 1;
        
        CALL sp_AnularAtendimento(p_CodPrestador, p_CodPaciente);
        
        SET v_Mensagem2 = CONCAT('Atendimento de ', p_CodPaciente, ' removido.');
    END;

    -- Verifica se ocorreu algum erro
    IF v_Erro = 0 THEN
        -- Commit se não houve erros
        COMMIT;
        SELECT v_Mensagem1 AS Mensagem1, v_Mensagem2 AS Mensagem2;
    ELSE
        -- Rollback se houve erros
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao cancelar ou remover o atendimento.';
    END IF;

END //
DELIMITER ;

CALL sp_CancelarAtendimentos(cod_prestador, cod_paciente);

CALL sp_CancelarAtendimentos(2, 2);

# INICIAR ATENDIMENTO
DELIMITER //
CREATE PROCEDURE sp_IniciarAtendimento(
    IN p_CodPrestador TINYINT UNSIGNED, 
    IN p_CodPaciente INT UNSIGNED
)
BEGIN
    DECLARE p_CodAtendimento INT; 
    
    -- Verifica se o usuário é um dentista
    CALL sp_VerificaDentista(p_CodPrestador);
    
    -- Recuperar o último atendimento pendente do paciente
    SELECT CodAtendimento INTO p_CodAtendimento
    FROM Atendimento
    WHERE CodPaciente = p_CodPaciente
      AND TipoStatus = 'EM ANDAMENTO'
    ORDER BY DataAtendimento DESC
    LIMIT 1;

    UPDATE Atendimento
    SET CodPrestador = p_CodPrestador 
    WHERE CodAtendimento = p_CodAtendimento; 
    
    -- Mensagem de sucesso
    IF ROW_COUNT() > 0 THEN
        SELECT 'Atendimento Iniciado!' AS Mensagem;
    ELSE
        SELECT 'Nenhum atendimento pendente encontrado.' AS Mensagem;
    END IF;
END //
DELIMITER ;

CALL sp_IniciarAtendimento(p_CodPrestador, p_CodPaciente);

CALL sp_IniciarAtendimento(2, 1);

# INSERIR DADOS
DELIMITER //
CREATE PROCEDURE sp_InserirDadosAtendimento(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT UNSIGNED, 
    IN p_CodDente TINYINT UNSIGNED,
    IN p_CodProcedimento TINYINT UNSIGNED,
    IN p_CaminhoImagem LONGTEXT,
    IN p_Valor DECIMAL(10, 2),
    IN p_Observacao LONGTEXT  
)
BEGIN
    DECLARE p_CodAtendimento INT;

    -- Verifica se o usuário é um dentista
    CALL sp_VerificaDentista(p_CodPrestador);

    -- Verifica se já existe um atendimento ativo para o paciente
    SELECT CodAtendimento INTO p_CodAtendimento
    FROM Atendimento
    WHERE CodPrestador = p_CodPrestador
      AND CodPaciente = p_CodPaciente
      AND TipoStatus = 'EM ANDAMENTO'
    ORDER BY DataAtendimento DESC
    LIMIT 1;

    -- Se não houver atendimento ativo, lançar um erro
    IF p_CodAtendimento IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhum atendimento ativo encontrado para o paciente.';
    END IF;

	CALL sp_ValidarProcedimento (p_CodDente, p_CodProcedimento);
    
    -- Inserir a imagem, se o caminho não for vazio
    IF p_CaminhoImagem IS NOT NULL AND p_CaminhoImagem != '' THEN
        INSERT INTO ImagensRadiologicas (Caminho, CodAtendimento)
        VALUES (p_CaminhoImagem, p_CodAtendimento);
    END IF;

    -- Inserir o registro na tabela ProMed
    INSERT INTO ProMed (CodAtendimento, CodProcedimento, CodDente, Observacao)
    VALUES (p_CodAtendimento, p_CodProcedimento, p_CodDente, p_Observacao);
    
    -- Inserir o registro na tabela Faturamento
    INSERT INTO Faturamento (CodProMed, Valor)
    VALUES (LAST_INSERT_ID(), p_Valor);

    -- Mensagem de sucesso
    SELECT 'Atendimento Realizado!' AS Mensagem;

END //
DELIMITER ;


CALL sp_InserirDadosAtendimento(p_CodPrestador, p_CodPaciente, p_CodDente, p_CodProcedimento, p_CaminhoImagem, p_Valor, p_Observacao);

CALL sp_InserirDadosAtendimento(2, 1, NULL, 8, 'ASAS', 20.00, 'Em obeservação');

# CONCLUIR ATENDIMENTO
DELIMITER //
CREATE PROCEDURE sp_ConcluirAtendimento(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT UNSIGNED
)
BEGIN
    DECLARE p_CodAtendimento INT;

    -- Verifica se o usuário é um dentista
    CALL sp_VerificaDentista(p_CodPrestador);

    -- Recuperar o último atendimento "EM ANDAMENTO" do prestador e do paciente
    SELECT CodAtendimento INTO p_CodAtendimento
    FROM Atendimento
    WHERE CodPrestador = p_CodPrestador
      AND CodPaciente = p_CodPaciente
      AND TipoStatus = 'EM ANDAMENTO'
    ORDER BY DataAtendimento DESC
    LIMIT 1;

    -- Se não houver atendimento ativo, lançar um erro
    IF p_CodAtendimento IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhum atendimento ativo encontrado para o paciente.';
    END IF;

    -- Atualizar o status do atendimento para 'CONCLUÍDO'
    UPDATE Atendimento
    SET TipoStatus = 'CONCLUÍDO'
    WHERE CodAtendimento = p_CodAtendimento;

    -- Mensagem de sucesso
    SELECT 'Atendimento concluído com sucesso!' AS Mensagem;
END //
DELIMITER ;

CALL sp_ConcluirAtendimento(p_CodPrestador, p_CodPaciente);

CALL sp_ConcluirAtendimento(2, 1);

# VISUALIZAR ATENDIMENTOS CONCLUÍDOS NO DIA
CREATE OR REPLACE VIEW vw_VisualizarAtendimentosConcluidos AS
SELECT 
    a.CodAtendimento,
    DATE_FORMAT(a.DataAtendimento, '%d/%m/%Y') AS DataProcedimento,
    pr.NomePrestador AS Dentista, 
    pa.NomePaciente,
    a.TipoStatus
FROM 
    Atendimento AS a
JOIN 
    Prestador AS pr ON a.CodPrestador = pr.CodPrestador
JOIN 
    Paciente AS pa ON a.CodPaciente = pa.CodPaciente
WHERE 
    a.TipoStatus = 'CONCLUÍDO' 
    AND DATE(a.DataAtendimento) = CURDATE(); 

SELECT * FROM vw_VisualizarAtendimentosConcluidos;

# VISUALIZAR PRONTUÁRIO - FRENTE
DELIMITER //
CREATE PROCEDURE sp_GetPacienteAndImages(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT UNSIGNED)
BEGIN
       -- Ambos
    CALL sp_VerificaPermissoesComuns(p_CodPrestador);
    
    SELECT 
        a.CodAtendimento AS CodAtendimento,
        p.NomePaciente AS Nome,
        IFNULL(p.CPF, 'N/A') AS 'CPF',
        IFNULL(p.CPFResponsavel, 'N/A') AS 'CPF (Responsável)',
        p.Telefone AS Celular,
        p.CodPaciente AS CodPaciente,
        CASE 
            WHEN p.Sexo = 'FEMININO' THEN 'F' 
            WHEN p.Sexo = 'MASCULINO' THEN 'M'
        END AS Sexo,
        TIMESTAMPDIFF(YEAR, p.DataNascimento, CURDATE()) AS Idade,
        IFNULL(d.NumeroDente, 'N/A') AS NumeroDente,  
        pr.DescricaoProcedimento AS Procedimento
    FROM 
        Paciente AS p  
    INNER JOIN 
        Atendimento AS a ON p.CodPaciente = a.CodPaciente  
    INNER JOIN 
        ProMed AS pm ON a.CodAtendimento = pm.CodAtendimento  
    INNER JOIN 
        Procedimento AS pr ON pm.CodProcedimento = pr.CodProcedimento  
    INNER JOIN 
        Dente AS d ON pm.CodDente = d.CodDente  
    WHERE 
        p.CodPaciente =  p_CodPaciente
        AND d.NumeroDente IS NOT NULL  
        AND pm.CodProcedimento BETWEEN 1 AND 5 
    ORDER BY 
        a.CodAtendimento, pr.DescricaoProcedimento;
    
    -- Selecionar imagens associadas
    SELECT 
        a.CodAtendimento AS CodAtendimento,
        img.Caminho AS Imagem
    FROM 
        Atendimento AS a  
    INNER JOIN 
        ImagensRadiologicas AS img ON a.CodAtendimento = img.CodAtendimento  
    WHERE 
        a.CodAtendimento IN (SELECT CodAtendimento 
                             FROM Atendimento 
                             WHERE CodPaciente =  p_CodPaciente);
END //
DELIMITER ;

CALL sp_GetPacienteAndImages(p_CodPrestador, p_CodPaciente);

CALL sp_GetPacienteAndImages(2, 1);

# VISUALIZAR PRONTUÁRIO - VERSO
DELIMITER //
CREATE PROCEDURE GetHistoricoAtendimentos(
    IN p_CodPrestador TINYINT UNSIGNED,
    IN p_CodPaciente INT UNSIGNED)
BEGIN
       -- Ambos
    CALL sp_VerificaPermissoesComuns(p_CodPrestador);
    
SELECT 
    DATE_FORMAT(a.DataAtendimento, '%d/%m/%Y') AS DataProcedimento,
    IFNULL(d.NumeroDente, 'N/A') AS NumeroDente, 
    pr.DescricaoProcedimento AS Procedimento,
    prest.NomePrestador AS NomeDentista,  
    IFNULL(CONCAT('R$ ', f.Valor), 'INDISPONÍVEL') AS Valor, 
    pm.Observacao AS ObservacaoPaciente
FROM 
    Paciente AS p  
INNER JOIN 
    Atendimento AS a ON p.CodPaciente = a.CodPaciente  
INNER JOIN 
    ProMed AS pm ON a.CodAtendimento = pm.CodAtendimento  
INNER JOIN 
    Procedimento AS pr ON pm.CodProcedimento = pr.CodProcedimento  
LEFT JOIN 
    Dente AS d ON pm.CodDente = d.CodDente  
INNER JOIN 
    Prestador AS prest ON a.CodPrestador = prest.CodPrestador 
INNER JOIN 
    Faturamento AS f ON pm.CodProMed = f.CodProMed
WHERE 
    p.CodPaciente = p_CodPaciente;
END //
DELIMITER ;

CALL GetHistoricoAtendimentos(p_CodPrestador, p_CodPaciente);

CALL GetHistoricoAtendimentos(2, 1);