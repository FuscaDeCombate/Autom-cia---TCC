USE master;
GO

-- Verificar e remover banco existente
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Automacia')
    DROP DATABASE Automacia;

CREATE DATABASE Automacia;
GO

USE Automacia;
GO

SET DATEFORMAT DMY;
GO

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

-- Farmácia/Hospital/Clínica
CREATE TABLE Contratante (
    CNPJ VARCHAR(14) NOT NULL,
    Documentacao VARBINARY(MAX) NOT NULL,
    Nome_Contratante VARCHAR(100) NOT NULL,
    Razao_Social VARCHAR(100) NOT NULL,
    Email_Contratante VARCHAR(100),
    Telefone VARCHAR(15),
    Endereco VARCHAR(200),
    Cidade VARCHAR(50),
    Estado VARCHAR(2),
    CEP VARCHAR(8),
    Senha_Hash VARCHAR(255) NOT NULL,
    Salt VARCHAR(50) NOT NULL,
    Data_Cadastro DATETIME2 DEFAULT GETDATE(),
    Data_Atualizacao DATETIME2 DEFAULT GETDATE(),
    Ativo BIT DEFAULT 1,
    PRIMARY KEY (CNPJ)
);

-- Tipo de Funcionário
CREATE TABLE Tipo_Funcionario (
    ID_Tipo_Funcionario INT IDENTITY(1,1),
    Descricao_Tipo VARCHAR(50) NOT NULL,
    Nivel_Acesso INT NOT NULL DEFAULT 1, -- 1=Básico, 2=Intermediário, 3=Admin
    Data_Cadastro DATETIME2 DEFAULT GETDATE(),
    Ativo BIT DEFAULT 1,
    PRIMARY KEY (ID_Tipo_Funcionario)
);

-- Funcionário de Farmácia/Hospital/Clínica
CREATE TABLE Funcionario (
    ID_Funcionario INT IDENTITY(1,1) NOT NULL,
    ID_Tipo_Funcionario INT NOT NULL,
    CNPJ VARCHAR(14) NOT NULL,
    CPF VARCHAR(11) NOT NULL UNIQUE,
    CRM VARCHAR(20), -- Para médicos
    Nome_Funcionario VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Telefone VARCHAR(15),
    Senha_Hash VARCHAR(255) NOT NULL,
    Salt VARCHAR(50) NOT NULL,
    Data_Nascimento DATE,
    Data_Admissao DATE DEFAULT GETDATE(),
    Data_Cadastro DATETIME2 DEFAULT GETDATE(),
    Data_Atualizacao DATETIME2 DEFAULT GETDATE(),
    Ativo BIT DEFAULT 1,
    PRIMARY KEY (ID_Funcionario),
    FOREIGN KEY (ID_Tipo_Funcionario) REFERENCES Tipo_Funcionario(ID_Tipo_Funcionario),
    FOREIGN KEY (CNPJ) REFERENCES Contratante(CNPJ)
);

-- Paciente
CREATE TABLE Paciente (
    CPF VARCHAR(11) NOT NULL,
    Nome_Paciente VARCHAR(100) NOT NULL,
    Nome_Social VARCHAR(100),
    Data_Nascimento DATE NOT NULL,
    Sexo CHAR(1) CHECK (Sexo IN ('M', 'F', 'O')),
    Email VARCHAR(100),
    Telefone VARCHAR(15),
    Endereco VARCHAR(200),
    Cidade VARCHAR(50),
    Estado VARCHAR(2),
    CEP VARCHAR(8),
    Senha_Hash VARCHAR(255) NOT NULL,
    Salt VARCHAR(50) NOT NULL,
    Data_Cadastro DATETIME2 DEFAULT GETDATE(),
    Data_Atualizacao DATETIME2 DEFAULT GETDATE(),
    Ativo BIT DEFAULT 1,
    PRIMARY KEY (CPF)
);

-- Status da Receita
CREATE TABLE Status_Receita (
    ID_Status INT IDENTITY(1,1),
    Descricao_Status VARCHAR(30) NOT NULL,
    PRIMARY KEY (ID_Status)
);

-- Receita Médica
CREATE TABLE Receita (
    ID_Receita INT IDENTITY(1,1) NOT NULL,
    Data_Receita DATETIME2 NOT NULL DEFAULT GETDATE(),
    Data_Validade DATE NOT NULL,
    ID_Funcionario INT NOT NULL,
    CPF VARCHAR(11) NOT NULL,
    Medicamento VARCHAR(200) NOT NULL,
    Dosagem VARCHAR(100),
    Quantidade INT,
    Instrucoes_Uso TEXT,
    Observacoes TEXT,
    ID_Status INT DEFAULT 1,
    Baixas INT DEFAULT 0,
    Data_Cadastro DATETIME2 DEFAULT GETDATE(),
    Data_Atualizacao DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (ID_Receita),
    FOREIGN KEY (ID_Funcionario) REFERENCES Funcionario(ID_Funcionario),
    FOREIGN KEY (CPF) REFERENCES Paciente(CPF),
    FOREIGN KEY (ID_Status) REFERENCES Status_Receita(ID_Status)
);

-- Histórico Médico
CREATE TABLE Historico_Medico (
    ID_Historico INT IDENTITY(1,1) NOT NULL,
    CPF VARCHAR(11) NOT NULL,
    ID_Funcionario INT NOT NULL,
    Tipo_Registro VARCHAR(50) NOT NULL, -- Consulta, Exame, Internação, etc.
    Descricao TEXT NOT NULL,
    Arquivo_Anexo VARBINARY(MAX),
    Nome_Arquivo VARCHAR(255),
    Tipo_Arquivo VARCHAR(10),
    Data_Registro DATETIME2 DEFAULT GETDATE(),
    Data_Cadastro DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (ID_Historico),
    FOREIGN KEY (CPF) REFERENCES Paciente(CPF),
    FOREIGN KEY (ID_Funcionario) REFERENCES Funcionario(ID_Funcionario)
);

-- Chat/Mensagens
CREATE TABLE Chat (
    ID_Chat INT IDENTITY(1,1) NOT NULL,
    CPF VARCHAR(11) NOT NULL,
    ID_Funcionario INT NOT NULL,
    Titulo VARCHAR(100),
    Data_Criacao DATETIME2 DEFAULT GETDATE(),
    Ativo BIT DEFAULT 1,
    PRIMARY KEY (ID_Chat),
    FOREIGN KEY (CPF) REFERENCES Paciente(CPF),
    FOREIGN KEY (ID_Funcionario) REFERENCES Funcionario(ID_Funcionario)
);

CREATE TABLE Mensagem (
    ID_Mensagem INT IDENTITY(1,1) NOT NULL,
    ID_Chat INT NOT NULL,
    Remetente_Tipo VARCHAR(10) NOT NULL CHECK (Remetente_Tipo IN ('PACIENTE', 'FUNCIONARIO')),
    Conteudo TEXT NOT NULL,
    Data_Envio DATETIME2 DEFAULT GETDATE(),
    Lida BIT DEFAULT 0,
    Data_Leitura DATETIME2,
    PRIMARY KEY (ID_Mensagem),
    FOREIGN KEY (ID_Chat) REFERENCES Chat(ID_Chat)
);


-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IDX_Contratante_CNPJ ON Contratante(CNPJ);
CREATE INDEX IDX_Funcionario_CPF ON Funcionario(CPF);
CREATE INDEX IDX_Funcionario_CNPJ ON Funcionario(CNPJ);
CREATE INDEX IDX_Paciente_CPF ON Paciente(CPF);
CREATE INDEX IDX_Receita_CPF ON Receita(CPF);
CREATE INDEX IDX_Receita_Funcionario ON Receita(ID_Funcionario);
CREATE INDEX IDX_Receita_Data ON Receita(Data_Receita);
CREATE INDEX IDX_Historico_CPF ON Historico_Medico(CPF);
CREATE INDEX IDX_Chat_CPF ON Chat(CPF);
CREATE INDEX IDX_Mensagem_Chat ON Mensagem(ID_Chat);
CREATE INDEX IDX_Mensagem_Data ON Mensagem(Data_Envio);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

-- Inserir tipos de funcionário
INSERT INTO Tipo_Funcionario (Descricao_Tipo, Nivel_Acesso) VALUES
('Médico', 3),
('Farmacêutico', 2),
('Enfermeiro', 2),
('Atendente', 1),
('Administrador', 3);

-- Inserir status de receita
INSERT INTO Status_Receita (Descricao_Status) VALUES
('Ativa'),
('Parcialmente Utilizada'),
('Totalmente Utilizada'),
('Vencida'),
('Cancelada');

-- =====================================================
-- FUNÇÕES AUXILIARES
-- =====================================================

-- Função para validar CPF
CREATE FUNCTION dbo.ValidarCPF(@CPF VARCHAR(11))
RETURNS BIT
AS
BEGIN
    DECLARE @INDICE INT,
            @SOMA INT,
            @DIG1 INT,
            @DIG2 INT,
            @CPF_TEMP VARCHAR(11),
            @DIGITOS_IGUAIS BIT = 1,
            @RESULTADO BIT = 0;

    -- Verificar se todos os dígitos são iguais
    SET @CPF_TEMP = SUBSTRING(@CPF, 1, 1);
    SET @INDICE = 2;

    WHILE (@INDICE <= 11 AND @DIGITOS_IGUAIS = 1)
    BEGIN
        IF SUBSTRING(@CPF, @INDICE, 1) <> @CPF_TEMP
            SET @DIGITOS_IGUAIS = 0;
        SET @INDICE = @INDICE + 1;
    END;

    -- Se os dígitos não são todos iguais, validar
    IF @DIGITOS_IGUAIS = 0
    BEGIN
        -- Cálculo do 1º dígito verificador
        SET @SOMA = 0;
        SET @INDICE = 1;
        
        WHILE (@INDICE <= 9)
        BEGIN
            SET @SOMA = @SOMA + CONVERT(INT, SUBSTRING(@CPF, @INDICE, 1)) * (11 - @INDICE);
            SET @INDICE = @INDICE + 1;
        END;

        SET @DIG1 = 11 - (@SOMA % 11);
        IF @DIG1 > 9 SET @DIG1 = 0;

        -- Cálculo do 2º dígito verificador
        SET @SOMA = 0;
        SET @INDICE = 1;
        
        WHILE (@INDICE <= 10)
        BEGIN
            SET @SOMA = @SOMA + CONVERT(INT, SUBSTRING(@CPF, @INDICE, 1)) * (12 - @INDICE);
            SET @INDICE = @INDICE + 1;
        END;

        SET @DIG2 = 11 - (@SOMA % 11);
        IF @DIG2 > 9 SET @DIG2 = 0;

        -- Verificar se os dígitos calculados conferem
        IF (@DIG1 = CONVERT(INT, SUBSTRING(@CPF, 10, 1))) AND 
           (@DIG2 = CONVERT(INT, SUBSTRING(@CPF, 11, 1)))
            SET @RESULTADO = 1;
    END;

    RETURN @RESULTADO;
END;
GO

-- Função para validar CNPJ
CREATE FUNCTION dbo.ValidarCNPJ(@CNPJ VARCHAR(14))
RETURNS BIT
AS
BEGIN
    DECLARE @INDICE INT,
            @SOMA INT,
            @DIG1 INT,
            @DIG2 INT,
            @SEQUENCIA VARCHAR(14) = '543298765432',
            @RESULTADO BIT = 0;

    -- Verificar se todos os dígitos são iguais
    IF LEN(@CNPJ) = 14 AND @CNPJ NOT LIKE REPLICATE(SUBSTRING(@CNPJ, 1, 1), 14)
    BEGIN
        -- Cálculo do 1º dígito verificador
        SET @SOMA = 0;
        SET @INDICE = 1;
        
        WHILE (@INDICE <= 12)
        BEGIN
            SET @SOMA = @SOMA + (CONVERT(INT, SUBSTRING(@CNPJ, @INDICE, 1)) * 
                        CONVERT(INT, SUBSTRING(@SEQUENCIA, @INDICE, 1)));
            SET @INDICE = @INDICE + 1;
        END;

        SET @DIG1 = @SOMA % 11;
        IF @DIG1 < 2 SET @DIG1 = 0; ELSE SET @DIG1 = 11 - @DIG1;

        -- Cálculo do 2º dígito verificador
        SET @SOMA = 0;
        SET @INDICE = 1;
        SET @SEQUENCIA = '6543298765432';
        
        WHILE (@INDICE <= 13)
        BEGIN
            SET @SOMA = @SOMA + (CONVERT(INT, SUBSTRING(@CNPJ, @INDICE, 1)) * 
                        CONVERT(INT, SUBSTRING(@SEQUENCIA, @INDICE, 1)));
            SET @INDICE = @INDICE + 1;
        END;

        SET @DIG2 = @SOMA % 11;
        IF @DIG2 < 2 SET @DIG2 = 0; ELSE SET @DIG2 = 11 - @DIG2;

        -- Verificar se os dígitos calculados conferem
        IF (@DIG1 = CONVERT(INT, SUBSTRING(@CNPJ, 13, 1))) AND 
           (@DIG2 = CONVERT(INT, SUBSTRING(@CNPJ, 14, 1)))
            SET @RESULTADO = 1;
    END;

    RETURN @RESULTADO;
END;
GO

-- Função para gerar hash de senha (simplificada)
CREATE FUNCTION dbo.GerarHashSenha(@Senha VARCHAR(255), @Salt VARCHAR(50))
RETURNS VARCHAR(255)
AS
BEGIN
    RETURN CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', @Senha + @Salt), 2);
END;
GO

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure para registrar paciente
CREATE PROCEDURE sp_RegistrarPaciente
    @CPF VARCHAR(11),
    @Nome VARCHAR(100),
    @Nome_Social VARCHAR(100) = NULL,
    @Data_Nascimento DATE,
    @Sexo CHAR(1) = NULL,
    @Email VARCHAR(100) = NULL,
    @Telefone VARCHAR(15) = NULL,
    @Endereco VARCHAR(200) = NULL,
    @Cidade VARCHAR(50) = NULL,
    @Estado VARCHAR(2) = NULL,
    @CEP VARCHAR(8) = NULL,
    @Senha VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Salt VARCHAR(50) = CONVERT(VARCHAR(50), NEWID());
    DECLARE @SenhaHash VARCHAR(255);
    DECLARE @Resultado VARCHAR(100);

    BEGIN TRY
        -- Validar CPF
        IF dbo.ValidarCPF(@CPF) = 0
        BEGIN
            SELECT 'ERRO: CPF inválido' AS Resultado;
            RETURN;
        END;

        -- Verificar se CPF já existe
        IF EXISTS (SELECT 1 FROM Paciente WHERE CPF = @CPF)
        BEGIN
            SELECT 'ERRO: CPF já cadastrado' AS Resultado;
            RETURN;
        END;

        -- Gerar hash da senha
        SET @SenhaHash = dbo.GerarHashSenha(@Senha, @Salt);

        -- Inserir paciente
        INSERT INTO Paciente (
            CPF, Nome_Paciente, Nome_Social, Data_Nascimento, Sexo,
            Email, Telefone, Endereco, Cidade, Estado, CEP,
            Senha_Hash, Salt
        ) VALUES (
            @CPF, @Nome, @Nome_Social, @Data_Nascimento, @Sexo,
            @Email, @Telefone, @Endereco, @Cidade, @Estado, @CEP,
            @SenhaHash, @Salt
        );

        SELECT 'SUCESSO: Paciente cadastrado com sucesso' AS Resultado,
               CPF, Nome_Paciente, Email, Data_Cadastro
        FROM Paciente 
        WHERE CPF = @CPF;

    END TRY
    BEGIN CATCH
        SELECT 'ERRO: ' + ERROR_MESSAGE() AS Resultado;
    END CATCH;
END;
GO