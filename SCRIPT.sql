CREATE DATABASE OdontoDB;

USE OdontoDB;

CREATE TABLE Paciente (
    CodPaciente INT UNSIGNED AUTO_INCREMENT,
    NomePaciente VARCHAR(100) NOT NULL,
    Sexo VARCHAR(20) DEFAULT 'NÃO INFORMADO', 
    DataNascimento DATE NOT NULL,
    CPF VARCHAR(14) UNIQUE NULL,  
    CPFResponsavel VARCHAR(14) UNIQUE NULL,
    Telefone VARCHAR(15) NOT NULL,  
    DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
    PRIMARY KEY (CodPaciente)
    );

CREATE TABLE Prestador (
    CodPrestador TINYINT UNSIGNED AUTO_INCREMENT,
    NomePrestador VARCHAR(100) NOT NULL,
    DataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
    CodTipoPrestador TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (CodPrestador)
);

CREATE TABLE TipoPrestador (
    CodTipoPrestador TINYINT UNSIGNED AUTO_INCREMENT,
    Funcao VARCHAR(100) NOT NULL,
    Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
    PRIMARY KEY (CodTipoPrestador)
);

CREATE TABLE Usuario (
    CodUsuario TINYINT UNSIGNED AUTO_INCREMENT,
    Nome VARCHAR(100) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Senha VARCHAR(255) NOT NULL,
    DataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
	CodPrestador TINYINT UNSIGNED NOT NULL,
    CodRoles TINYINT UNSIGNED NULL,
    PRIMARY KEY (CodUsuario)
);

CREATE TABLE Roles(
	CodRoles TINYINT UNSIGNED AUTO_INCREMENT,
	Nome VARCHAR(150),
	Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
	PRIMARY KEY(CodRoles)
);

CREATE TABLE Atendimento (
    CodAtendimento INT UNSIGNED AUTO_INCREMENT,
    DataAtendimento DATETIME DEFAULT CURRENT_TIMESTAMP,
	TipoStatus ENUM('EM ANDAMENTO', 'CONCLUÍDO', 'CANCELADO') DEFAULT 'EM ANDAMENTO',
    CodPrestador TINYINT UNSIGNED NOT NULL,
	CodPaciente INT UNSIGNED NOT NULL,
    PRIMARY KEY (CodAtendimento)
);

CREATE TABLE ImagensRadiologicas(
	CodImagensRadiologicas INT UNSIGNED AUTO_INCREMENT,
	Caminho LONGTEXT NOT NULL,
	DataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
	Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
	CodAtendimento INT UNSIGNED NULL,
	PRIMARY KEY (CodImagensRadiologicas)
);

CREATE TABLE Dente (
    CodDente TINYINT UNSIGNED AUTO_INCREMENT,
    NomeDente VARCHAR(100) NOT NULL,
    NumeroDente TINYINT UNSIGNED NOT NULL,
	Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
    PRIMARY KEY (CodDente)
);

CREATE TABLE Procedimento(
	CodProcedimento TINYINT UNSIGNED AUTO_INCREMENT,
	DescricaoProcedimento VARCHAR(255) NOT NULL,
	Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
	PRIMARY KEY (CodProcedimento)
);

CREATE TABLE ProMed(
	CodProMed INT UNSIGNED AUTO_INCREMENT,
	Observacao LONGTEXT,
	CodDente TINYINT UNSIGNED NULL,
	CodAtendimento INT UNSIGNED NOT NULL,
	CodProcedimento TINYINT UNSIGNED NOT NULL,
	PRIMARY KEY (CodProMed)
);

CREATE TABLE Faturamento (
    CodFaturamento INT UNSIGNED AUTO_INCREMENT,
    Valor DECIMAL(10, 2) NOT NULL CHECK (Valor >= 0), 
    CodProMed INT UNSIGNED NOT NULL, 
	Status CHAR(1) DEFAULT 'A' CHECK (Status IN ('A', 'I')),
    PRIMARY KEY (CodFaturamento)
);

ALTER TABLE Prestador
ADD CONSTRAINT FK_Prestador_TipoPrestador 
FOREIGN KEY (CodTipoPrestador)
REFERENCES TipoPrestador(CodTipoPrestador)
ON DELETE RESTRICT ON UPDATE CASCADE;
 
ALTER TABLE Usuario
ADD CONSTRAINT FK_Usuario_Prestador 
FOREIGN KEY (CodPrestador) 
REFERENCES Prestador(CodPrestador)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Usuario
ADD CONSTRAINT FK_Usuario_Roles
FOREIGN KEY (CodRoles)
REFERENCES Roles(CodRoles);

ALTER TABLE Atendimento
ADD CONSTRAINT FK_Atendimento_Prestador 
FOREIGN KEY (CodPrestador) 
REFERENCES Prestador(CodPrestador)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE Atendimento
ADD CONSTRAINT FK_Atendimento_Paciente 
FOREIGN KEY (CodPaciente) 
REFERENCES Paciente(CodPaciente)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE ImagensRadiologicas
ADD CONSTRAINT FK_ImagensRadiologicas_Atendimento
FOREIGN KEY (CodAtendimento) 
REFERENCES Atendimento(CodAtendimento)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE ProMed
ADD CONSTRAINT FK_ProMed_Dente
FOREIGN KEY (CodDente) 
REFERENCES Dente(CodDente)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE ProMed
ADD CONSTRAINT FK_ProMed_Atendimento
FOREIGN KEY (CodAtendimento) 
REFERENCES Atendimento(CodAtendimento)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE ProMed
ADD CONSTRAINT FK_ProMed_Procedimento
FOREIGN KEY (CodProcedimento) 
REFERENCES Procedimento(CodProcedimento)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Faturamento 
ADD CONSTRAINT FK_Faturamento_ProMed
FOREIGN KEY (CodProMed) 
REFERENCES ProMed(CodProMed)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- PRESTADORES 
INSERT INTO TipoPrestador(CodTipoPrestador, Funcao) 
VALUES 
(1, 'RECEPCIONISTA'),
(2, 'DENTISTA');

-- PERMISSÕES
INSERT INTO Roles(CodRoles, Nome)
VALUES 
(1, 'ADMIN'),
(2, 'DENTISTA'),
(3, 'RECEPCIONISTA'),
(4, 'USER');

-- PROCEDIMENTOS
INSERT INTO Procedimento (CodProcedimento, DescricaoProcedimento)
VALUES
(1, 'EXTRAÇÃO'),
(2, 'CANAL'),
(3, 'RESTAURAÇÃO'),
(4, 'PINO'),
(5, 'COROA');

-- SERVIÇOS
INSERT INTO Procedimento (CodProcedimento, DescricaoProcedimento)
VALUES
(6, 'LIMPEZA'),
(7, 'CLAREAMENTO'),
(8, 'APARELHOS ORTODÔNTICOS'),
(9, 'TRATAMENTO DE GENGIVAS'),
(10, 'FACETAS'),
(11, 'MANUTENÇÃO'),
(12, 'FRENECTOMIA'),
(13, 'REMOÇÃO DE LESÃO PATOLÓGICA'),
(14, 'CIRURGIA DE REGULARIZAÇÃO DE REBORDO ALVEOLAR'),
(15, 'PRÓTESE ADESIVA'),
(16, 'AUMENTO DE COROA CLÍNICA'),
(17, 'GENGIVOPLASTIA'),
(18, 'PROVISÓRIO'),
(19, 'PLACA PARA BRUXISMO'),
(20, 'CONTENÇÃO');

-- ARCADA SUPERIOR (16 DENTES)
INSERT INTO Dente (CodDente, NomeDente, NumeroDente) 
VALUES 
(1, 'TERCEIRO MOLAR SUPERIOR DIREITO (SISO)', 18),
(2, 'SEGUNDO MOLAR SUPERIOR DIREITO', 17),
(3, 'PRIMEIRO MOLAR SUPERIOR DIREITO', 16),
(4, 'SEGUNDO PRÉ-MOLAR SUPERIOR DIREITO', 15),
(5, 'PRIMEIRO PRÉ-MOLAR SUPERIOR DIREITO', 14),
(6, 'CANINO SUPERIOR DIREITO', 13),
(7, 'INCISIVO LATERAL SUPERIOR DIREITO', 12),
(8, 'INCISIVO CENTRAL SUPERIOR DIREITO', 11),
(9, 'INCISIVO CENTRAL SUPERIOR ESQUERDO', 21),
(10, 'INCISIVO LATERAL SUPERIOR ESQUERDO', 22),
(11, 'CANINO SUPERIOR ESQUERDO', 23),
(12, 'PRIMEIRO PRÉ-MOLAR SUPERIOR ESQUERDO', 24),
(13, 'SEGUNDO PRÉ-MOLAR SUPERIOR ESQUERDO', 25),
(14, 'PRIMEIRO MOLAR SUPERIOR ESQUERDO', 26),
(15, 'SEGUNDO MOLAR SUPERIOR ESQUERDO', 27),
(16, 'TERCEIRO MOLAR SUPERIOR ESQUERDO (SISO)', 28);

-- ARCADA INFERIOR (16 DENTES)
INSERT INTO Dente (CodDente, NomeDente, NumeroDente) 
VALUES 
(17, 'TERCEIRO MOLAR INFERIOR DIREITO (SISO)', 48),
(18, 'SEGUNDO MOLAR INFERIOR DIREITO', 47),
(19, 'PRIMEIRO MOLAR INFERIOR DIREITO', 46),
(20, 'SEGUNDO PRÉ-MOLAR INFERIOR DIREITO', 45),
(21, 'PRIMEIRO PRÉ-MOLAR INFERIOR DIREITO', 44),
(22, 'CANINO INFERIOR DIREITO', 43),
(23, 'INCISIVO LATERAL INFERIOR DIREITO', 42),
(24, 'INCISIVO CENTRAL INFERIOR DIREITO', 41),
(25, 'INCISIVO CENTRAL INFERIOR ESQUERDO', 31),
(26, 'INCISIVO LATERAL INFERIOR ESQUERDO', 32),
(27, 'CANINO INFERIOR ESQUERDO', 33),
(28, 'PRIMEIRO PRÉ-MOLAR INFERIOR ESQUERDO', 34),
(29, 'SEGUNDO PRÉ-MOLAR INFERIOR ESQUERDO', 35),
(30, 'PRIMEIRO MOLAR INFERIOR ESQUERDO', 36),
(31, 'SEGUNDO MOLAR INFERIOR ESQUERDO', 37),
(32, 'TERCEIRO MOLAR INFERIOR ESQUERDO (SISO)', 38);

-- TRIGGERS PARA CONVERTER TODOS OS DADOS EM MAIÚSCULO
DELIMITER //
CREATE TRIGGER tg_BeforeInsertPaciente
BEFORE INSERT ON Paciente
FOR EACH ROW
BEGIN
    SET NEW.NomePaciente = UPPER(NEW.NomePaciente);
    SET NEW.Sexo = UPPER(NEW.Sexo);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdatePaciente
BEFORE UPDATE ON Paciente
FOR EACH ROW
BEGIN
    SET NEW.NomePaciente = UPPER(NEW.NomePaciente);
    SET NEW.Sexo = UPPER(NEW.Sexo);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeInsertPrestador
BEFORE INSERT ON Prestador
FOR EACH ROW
BEGIN
    SET NEW.NomePrestador = UPPER(NEW.NomePrestador);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdatePrestador
BEFORE UPDATE ON Prestador
FOR EACH ROW
BEGIN
    SET NEW.NomePrestador = UPPER(NEW.NomePrestador);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeInsertTipoPrestador
BEFORE INSERT ON TipoPrestador
FOR EACH ROW
BEGIN
    SET NEW.Funcao = UPPER(NEW.Funcao);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdateTipoPrestador
BEFORE UPDATE ON TipoPrestador
FOR EACH ROW
BEGIN
    SET NEW.Funcao = UPPER(NEW.Funcao);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeInsertUsuario
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    SET NEW.Nome = UPPER(NEW.Nome);
    SET NEW.Email = UPPER(NEW.Email);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdateUsuario
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    SET NEW.Nome = UPPER(NEW.Nome);
    SET NEW.Email = UPPER(NEW.Email);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeInsertDente
BEFORE INSERT ON Dente
FOR EACH ROW
BEGIN
    SET NEW.NomeDente = UPPER(NEW.NomeDente);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdateDente
BEFORE UPDATE ON Dente
FOR EACH ROW
BEGIN
    SET NEW.NomeDente = UPPER(NEW.NomeDente);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeInsertAtendimento
BEFORE INSERT ON Atendimento
FOR EACH ROW
BEGIN
    SET NEW.TipoStatus = UPPER(NEW.TipoStatus);
END //

CREATE TRIGGER tg_BeforeUpdateAtendimento
BEFORE UPDATE ON Atendimento
FOR EACH ROW
BEGIN
    SET NEW.TipoStatus = UPPER(NEW.TipoStatus);
END //

CREATE TRIGGER tg_BeforeInsertImagensRadiologicas
BEFORE INSERT ON ImagensRadiologicas
FOR EACH ROW
BEGIN
   -- SET NEW.Caminho = UPPER(NEW.Caminho);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdateImagensRadiologicas
BEFORE UPDATE ON ImagensRadiologicas
FOR EACH ROW
BEGIN
 -- SET NEW.Caminho = UPPER(NEW.Caminho);
    SET NEW.Status = UPPER(NEW.Status);
END //


CREATE TRIGGER tg_BeforeInsertProcedimento
BEFORE INSERT ON Procedimento
FOR EACH ROW
BEGIN
    SET NEW.DescricaoProcedimento = UPPER(NEW.DescricaoProcedimento);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdateProcedimento
BEFORE UPDATE ON Procedimento
FOR EACH ROW
BEGIN
    SET NEW.DescricaoProcedimento = UPPER(NEW.DescricaoProcedimento);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeInsertProMed
BEFORE INSERT ON ProMed
FOR EACH ROW
BEGIN
    SET NEW.Observacao = UPPER(NEW.Observacao);
END //

CREATE TRIGGER tg_BeforeUpdateProMed
BEFORE UPDATE ON ProMed
FOR EACH ROW
BEGIN
    SET NEW.Observacao = UPPER(NEW.Observacao);
END //

CREATE TRIGGER tg_BeforeInsertFaturamento
BEFORE INSERT ON Faturamento
FOR EACH ROW
BEGIN
END //

CREATE TRIGGER tg_BeforeUpdateFaturamento
BEFORE UPDATE ON Faturamento
FOR EACH ROW
BEGIN
END //

CREATE TRIGGER tg_BeforeInsertRoles
BEFORE INSERT ON Roles
FOR EACH ROW
BEGIN
	SET NEW.Nome = UPPER(NEW.Nome);
    SET NEW.Status = UPPER(NEW.Status);
END //

CREATE TRIGGER tg_BeforeUpdateRoles
BEFORE UPDATE ON Roles
FOR EACH ROW
BEGIN
	SET NEW.Nome = UPPER(NEW.Nome);
    SET NEW.Status = UPPER(NEW.Status);
END //
DELIMITER ;

-- VALIDAÇÃO RECEPCIONISTA
DELIMITER //
CREATE PROCEDURE sp_VerificaRecepcionista(
    IN p_CodPrestador TINYINT UNSIGNED
)
BEGIN
    DECLARE v_Funcao VARCHAR(100);
    DECLARE v_UsuarioCount INT;

    -- Verifica se o prestador possui um usuário associado
    SELECT COUNT(*) INTO v_UsuarioCount
    FROM Usuario u
    WHERE u.CodPrestador = p_CodPrestador
      AND u.Status = 'A';

    -- Se não houver usuário ativo associado, lança um erro
    IF v_UsuarioCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhum usuário associado encontrado para este prestador.';
    END IF;

    -- Obtém a função do prestador com base no CodPrestador
    SELECT tp.Funcao INTO v_Funcao
    FROM Prestador p 
    INNER JOIN TipoPrestador tp ON p.CodTipoPrestador = tp.CodTipoPrestador
    WHERE p.CodPrestador = p_CodPrestador
      AND p.Status = 'A';  

    -- Verifica se a função é RECEPCIONISTA
    IF v_Funcao <> 'RECEPCIONISTA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas recepcionistas podem realizar esta ação.';
    END IF;
END //
DELIMITER ;

-- VALIDAÇÃO DENTISTA
DELIMITER //
CREATE PROCEDURE sp_VerificaDentista(
    IN p_CodPrestador TINYINT UNSIGNED
)
BEGIN
    DECLARE v_Funcao VARCHAR(100);
    DECLARE v_UsuarioCount INT;

    -- Verifica se o prestador possui um usuário associado
    SELECT COUNT(*) INTO v_UsuarioCount
    FROM Usuario u
    WHERE u.CodPrestador = p_CodPrestador
      AND u.Status = 'A';

    -- Se não houver usuário ativo associado, lança um erro
    IF v_UsuarioCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhum usuário associado encontrado para este prestador.';
    END IF;

    -- Obtém a função do prestador com base no CodPrestador
    SELECT tp.Funcao INTO v_Funcao
    FROM Prestador p 
    INNER JOIN TipoPrestador tp ON p.CodTipoPrestador = tp.CodTipoPrestador
    WHERE p.CodPrestador = p_CodPrestador
      AND p.Status = 'A';  

    -- Verifica se a função é DENTISTA
    IF v_Funcao <> 'DENTISTA' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas dentistas podem realizar esta ação.';
    END IF;
END //
DELIMITER ;

-- PERMISSÕES EM COMUM
DELIMITER //
CREATE PROCEDURE sp_VerificaPermissoesComuns(
    IN p_CodPrestador TINYINT UNSIGNED
)
BEGIN
    DECLARE v_Funcao VARCHAR(100);
    DECLARE v_UsuarioCount INT;

    -- Verifica se o prestador possui um usuário associado ativo
    SELECT COUNT(*) INTO v_UsuarioCount
    FROM Usuario u
    WHERE u.CodPrestador = p_CodPrestador
      AND u.Status = 'A';

    -- Se não houver usuário ativo associado, lança um erro
    IF v_UsuarioCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nenhum usuário associado encontrado para este prestador.';
    END IF;

    -- Obtém a função do prestador (DENTISTA ou RECEPCIONISTA)
    SELECT tp.Funcao INTO v_Funcao
    FROM Prestador p
    INNER JOIN TipoPrestador tp ON p.CodTipoPrestador = tp.CodTipoPrestador
    WHERE p.CodPrestador = p_CodPrestador
      AND p.Status = 'A';  

    -- Verifica se a função do prestador é válida (DENTISTA ou RECEPCIONISTA)
    IF v_Funcao NOT IN ('DENTISTA', 'RECEPCIONISTA') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Apenas dentistas e recepcionistas podem realizar esta ação.';
    END IF;
END //
DELIMITER ;

-- PERMITIR APENAS UM ATENDIMENTO ATIVO POR DENTISTA
DELIMITER //
CREATE TRIGGER tg_VerificaAtendimentoDentista
BEFORE UPDATE ON Atendimento
FOR EACH ROW
BEGIN
    -- Verificar se o dentista já está atendendo outro paciente "EM ANDAMENTO"
    IF EXISTS (
        SELECT 1 
        FROM Atendimento 
        WHERE CodPrestador = NEW.CodPrestador 
          AND TipoStatus = 'EM ANDAMENTO'
          AND CodAtendimento <> NEW.CodAtendimento -- Ignora o registro atual
    ) THEN
        -- Impedir a atualização e lançar um erro
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Um momento... O dentista está atendendo outro paciente.';
    END IF;
END //
DELIMITER ;

-- APENAS UM ATENDIMENTO POR VEZ
DELIMITER //
CREATE TRIGGER tg_VerificaAtendimento
BEFORE INSERT ON Atendimento
FOR EACH ROW
BEGIN
    -- Verificar se o paciente já tem um atendimento "EM ANDAMENTO", exceto o atual
    IF EXISTS (
        SELECT 1 
        FROM Atendimento 
        WHERE CodPaciente = NEW.CodPaciente
          AND TipoStatus = 'EM ANDAMENTO'
          AND CodAtendimento <> NEW.CodAtendimento  -- Não impede a inserção de updates no mesmo atendimento
    ) THEN
        -- Impedir a inserção e lançar um erro
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Paciente já possui atendimento ativo.';
    END IF;
END //
DELIMITER ;

-- IMPEDIR ATUALIZAÇÕES EM ATENDIMENTOS CONCLUÍDOS
DELIMITER //
CREATE TRIGGER tg_ProMedProtegeConcluido
BEFORE UPDATE ON ProMed
FOR EACH ROW
BEGIN
    DECLARE p_TipoStatus VARCHAR(50);

    -- Recupera o status do atendimento associado ao ProMed
    SELECT TipoStatus INTO p_TipoStatus
    FROM Atendimento
    WHERE CodAtendimento = OLD.CodAtendimento;

    -- Verifica se o atendimento já está concluído
    IF p_TipoStatus = 'CONCLUÍDO' THEN
        -- Lança um erro para bloquear qualquer alteração
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido alterar um procedimento associado a um atendimento que já foi concluído.';
    END IF;
END //

CREATE TRIGGER tg_ImagensRadiologicasProtegeConcluido
BEFORE UPDATE ON ImagensRadiologicas
FOR EACH ROW
BEGIN
    DECLARE p_TipoStatus VARCHAR(50);

    -- Recupera o status do atendimento associado à Imagem Radiológica
    SELECT TipoStatus INTO p_TipoStatus
    FROM Atendimento
    WHERE CodAtendimento = OLD.CodAtendimento;

    -- Verifica se o atendimento já está concluído
    IF p_TipoStatus = 'CONCLUÍDO' THEN
        -- Lança um erro para bloquear qualquer alteração
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido alterar imagens radiológicas associadas a um atendimento que já foi concluído.';
    END IF;
END //
DELIMITER ;

-- APOS O ATENDIMENTO 'CONCLUÍDO' NÃO PODE SER MAIS ALTERADO
DELIMITER //
CREATE TRIGGER tg_AtendimentoProtegeConcluido
BEFORE UPDATE ON Atendimento
FOR EACH ROW
BEGIN
    -- Verifica se o atendimento já está concluído
    IF OLD.TipoStatus = 'CONCLUÍDO' THEN
        -- Lança um erro para bloquear qualquer alteração
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido alterar um atendimento que já foi concluído.';
    END IF;
END //
DELIMITER ;

# VALIDAÇÃO PROCEDIMENTO 
DELIMITER // 
CREATE PROCEDURE sp_ValidarProcedimento(
    IN p_CodDente TINYINT UNSIGNED,
    IN p_CodProcedimento TINYINT UNSIGNED
)
BEGIN
    -- Verifica se o dente está selecionado
    IF p_CodDente IS NOT NULL AND p_CodDente <> 0 THEN
        -- Verifica se o procedimento já está vinculado ao dente
        IF (SELECT COUNT(*) 
            FROM ProMed 
            WHERE CodDente = p_CodDente 
              AND CodProcedimento = p_CodProcedimento) > 0 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Este procedimento já está vinculado a este dente. Não é possível escolher novamente.';
        END IF;

        -- Verifica se o procedimento está fora dos permitidos quando o dente está selecionado
        IF p_CodProcedimento NOT IN (1, 2, 3, 4, 5) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Procedimento inválido para dente selecionado.';
        END IF;

    ELSE
        -- Se o dente for nulo ou zero, os procedimentos 1 a 5 não são permitidos
        IF p_CodProcedimento IN (1, 2, 3, 4, 5) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Procedimento inválido quando nenhum dente está selecionado.';
        END IF;
    END IF;
END //
DELIMITER ;
