USE master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Automacia')
BEGIN
    ALTER DATABASE Automacia SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Automacia;
END
GO

CREATE DATABASE Automacia;
GO

USE Automacia;
GO

SET DATEFORMAT DMY;
GO

--===============================================================================================
-- CRIPTOGRAFIA 

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@AlAn21220JoRiVi21081/6969!';
GO

CREATE CERTIFICATE Cert_Mensag
WITH SUBJECT = 'Certificado para Mensagens';
GO

CREATE SYMMETRIC KEY EnK_Mensag 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Mensag;
GO

--===============================================================================================
-- FUNÇÕES AUXILIARES PARA HASH+SALT

-- Função para gerar hash da senha com salt
CREATE FUNCTION dbo.HashSenha(@senha VARCHAR(256), @salt VARCHAR(64))
RETURNS VARCHAR(128)
AS
BEGIN
    DECLARE @hash VARCHAR(128)
    -- Usando SHA2_512 para maior seguran�a
    SET @hash = CONVERT(VARCHAR(128), HASHBYTES('SHA2_512', @senha + @salt), 2)
    RETURN @hash
END
GO

-- Função para verificar senha
CREATE FUNCTION dbo.VerificarSenha(@senha VARCHAR(256), @salt VARCHAR(64), @hashArmazenado VARCHAR(128))
RETURNS BIT
AS
BEGIN
    DECLARE @hashCalculado VARCHAR(128), @reto Tinyint;

    SET @hashCalculado = dbo.HashSenha(@senha, @salt)
    
    IF @hashCalculado = @hashArmazenado
		BEGIN
			Set @reto = 1
		END
    ELSE
		BEGIN
			Set @reto = 0
		END
	RETURN @reto;
END
GO

--===============================================================================================
-- TABELAS

-- Contratante (Farmácia/Hospital/Clínica)
CREATE TABLE Contratante (
        CNPJ VARCHAR(20) UNIQUE NOT NULL,
        Documentacao VARBINARY(MAX) NOT NULL,
        Nome_Contratante VARCHAR(100) NOT NULL,
        Senha_Hash VARCHAR(128) NOT NULL,
        Salt_Contratante VARCHAR(64) NOT NULL,
        Data_Criacao DATETIME2 DEFAULT GETDATE(),
        PRIMARY KEY (CNPJ)
);
GO

-- Tipo de Funcionário
CREATE TABLE Tipo_Funcionario (
        ID_Tipo_Funcionario TINYINT,
        Tipo_Funci VARCHAR(50),
        PRIMARY KEY (ID_Tipo_Funcionario)
);
GO

-- Funcionário
CREATE TABLE Funcionario (
        Funcionar_Rec INT IDENTITY UNIQUE NOT NULL,
        ID_Tipo_Funcionario TINYINT NOT NULL,
        CNPJ VARCHAR(20) NOT NULL,
        Senha_Hash VARCHAR(128) NOT NULL,
        Salt_Funcionario VARCHAR(64) NOT NULL,
        Nome_Funcionario VARCHAR(100) NOT NULL,
        Data_Criacao DATETIME2 DEFAULT GETDATE(),
        Ativo BIT DEFAULT 1,
        PRIMARY KEY (Funcionar_Rec),
        FOREIGN KEY (ID_Tipo_Funcionario) REFERENCES Tipo_Funcionario(ID_Tipo_Funcionario),
        FOREIGN KEY (CNPJ) REFERENCES Contratante(CNPJ)
);
GO

-- Paciente
CREATE TABLE Paciente (
        Paciente_F VARCHAR(11) UNIQUE NOT NULL,
        Senha_Hash VARCHAR(128) NOT NULL,
        Salt_Paciente VARCHAR(64) NOT NULL,
        Email VARCHAR(100),
        Fone VARCHAR(20),
        Nome_Paciente VARCHAR(100) NOT NULL,
        Nome_Social VARCHAR(100) NOT NULL,
        Data_Criacao DATETIME2 DEFAULT GETDATE(),
        Ativo BIT DEFAULT 1,
        PRIMARY KEY (Paciente_F)
);
GO

-- Receita
CREATE TABLE Receita (
        ID_Receita INT IDENTITY NOT NULL,
        Data_Receita DATETIME2 NOT NULL DEFAULT GETDATE(),
        Data_Validade DATE NOT NULL,
        Funcionar_Rec INT NOT NULL,
        Paciente_F VARCHAR(11) NOT NULL,
        Medicamento VARCHAR(200) NOT NULL,
        Detalhes VARCHAR(500),
        Limite_Baixas TINYINT,
        Valido BIT DEFAULT 1,
        Baixas TINYINT DEFAULT 0,
        PRIMARY KEY (ID_Receita),
        FOREIGN KEY (Funcionar_Rec) REFERENCES Funcionario(Funcionar_Rec),
        FOREIGN KEY (Paciente_F) REFERENCES Paciente(Paciente_F)
);
GO

-- Histórico Médico
CREATE TABLE Historico_Medico (
        ID_Historico INT IDENTITY NOT NULL,
        Paciente_F VARCHAR(11) NOT NULL,
        Registro_Medico VARBINARY(MAX) NOT NULL,
        Data_Registro DATETIME2 DEFAULT GETDATE(),
        PRIMARY KEY (ID_Historico),
        FOREIGN KEY (Paciente_F) REFERENCES Paciente(Paciente_F)
);
GO

-- Mensagem
CREATE TABLE Mensagem (
        ID_Chat INT IDENTITY,
        Paciente_F VARCHAR(11),
        Funcionar_Rec INT,
        Mensagem VARBINARY(MAX),
        Hora_Envio DATETIME2 DEFAULT GETDATE(),
        PRIMARY KEY (ID_Chat),
        FOREIGN KEY (Paciente_F) REFERENCES Paciente(Paciente_F),
        FOREIGN KEY (Funcionar_Rec) REFERENCES Funcionario(Funcionar_Rec)
);
GO

--===============================================================================================
-- ÍNDICES

CREATE INDEX IDX_CNPJ ON Contratante(CNPJ);
CREATE INDEX IDX_Paciente_F ON Paciente(Paciente_F);
CREATE INDEX IDX_Funcionario_Ativo ON Funcionario(Funcionar_Rec, Ativo);
CREATE INDEX IDX_Receita_Paciente ON Receita(Paciente_F, Data_Receita);
CREATE INDEX IDX_Receita_Funcionario ON Receita(Funcionar_Rec, Data_Receita);
CREATE INDEX IDX_Historico_Paciente ON Historico_Medico(Paciente_F, Data_Registro);
CREATE INDEX IDX_Mensagem_Chat ON Mensagem(Paciente_F, Funcionar_Rec, Hora_Envio);
GO

-- ========================================
-- DADOS INICIAIS
-- ========================================

INSERT INTO Tipo_Funcionario (ID_Tipo_Funcionario, Tipo_Funci) VALUES
        (1, 'Funcionário Farmácia'),
        (2, 'Funcionário Saúde'),
        (3, 'Administrador Farmácia'),
        (4, 'Administrador Hospital');
GO

-- Inserir contratante de exemplo com hash+salt
Go
DECLARE @salt VARCHAR(64) 
	Set @salt= CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
DECLARE @hash VARCHAR(128) 
	Set @hash= dbo.HashSenha('senha', @salt);

INSERT INTO Contratante (CNPJ, Documentacao, Nome_Contratante, Senha_Hash, Salt_Contratante) VALUES
        ('1', 0x123456, 'Empresa Teste', @hash, @salt);
GO

--===============================================================================================
-- PROCEDURES

-- REGISTRAR PACIENTE
CREATE PROCEDURE Registra_Paciente(
        @CPF VARCHAR(11),
        @Senha VARCHAR(256),
        @Email VARCHAR(100),
        @Nome VARCHAR(100),
        @Nome_Social VARCHAR(100),
        @Fonee VARCHAR(20)
) AS 
BEGIN
        DECLARE
                @RetornoCPF BIT,
                @RetornoNull BIT,
                @RetornoEmail BIT,
                @RetornoSenha BIT,
                @CPFT VARCHAR(11),
                @SenhaT VARCHAR(256),
                @EmailT VARCHAR(100),
                @NomeT VARCHAR(100),
                @Nome_SocialT VARCHAR(100),
                @Salt VARCHAR(64),
                @Hash VARCHAR(128);

		Set @RetornoCPF = 0;
		Set @RetornoNull = 0;
		Set @RetornoEmail = 1;
		Set @RetornoSenha = 1;

        BEGIN TRY
                -- Limpar dados de entrada
                SET @CPFT = REPLACE(@CPF, ' ', '');
                SET @SenhaT = LTRIM(RTRIM(@Senha));
                SET @EmailT = LTRIM(RTRIM(REPLACE(@Email, ' ', '')));
                SET @NomeT = LTRIM(RTRIM(@Nome));
                SET @Nome_SocialT = LTRIM(RTRIM(@Nome_Social));

                -- VERIFICA��O APRIMORADA DE CPF DUPLICADO
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPFT)
                BEGIN
                        SELECT 'CPF já cadastrado no sistema' AS 'Registra_Paciente_Retorno';
                        RETURN;
                END

                -- Verificar nulos
                IF @CPFT = '' OR @SenhaT = '' OR @EmailT = '' OR @NomeT = '' OR @Nome_SocialT = ''
                        SET @RetornoNull = 0;
                ELSE
                        SET @RetornoNull = 1;

                -- Valida��o b�sica de email
                IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100
                        SET @RetornoEmail = 0;

                -- Valida��o b�sica de CPF
                IF LEN(@CPFT) = 11 AND ISNUMERIC(@CPFT) = 1
                        SET @RetornoCPF = 1;

                -- Valida��o de senha (m�nimo 6 caracteres)
                IF LEN(@SenhaT) >= 6
                        SET @RetornoSenha = 1;
                ELSE
                        SET @RetornoSenha = 0;

                -- Verificar se todas as valida��es passaram
                IF @RetornoNull = 0 OR @RetornoCPF = 0 OR @RetornoEmail = 0 OR @RetornoSenha = 0
                BEGIN
                        IF (@RetornoNull = 0) 
                                SELECT 'Todos os campos devem ser preenchidos' AS 'Registra_Paciente_Retorno';
                        ELSE IF (@RetornoCPF = 0) 
                                SELECT 'CPF deve conter exatamente 11 dígitos numéricos' AS 'Registra_Paciente_Retorno';
                        ELSE IF (@RetornoEmail = 0) 
                                SELECT 'Email inválido' AS 'Registra_Paciente_Retorno';
                        ELSE IF (@RetornoSenha = 0) 
                                SELECT 'Senha deve conter no mínimo 6 caracteres' AS 'Registra_Paciente_Retorno';
                END
                ELSE 
                BEGIN
                        -- Gerar salt e hash da senha
                        SET @Salt = CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
                        SET @Hash = dbo.HashSenha(@SenhaT, @Salt);

                        -- Inserir paciente com senha hasheada
                        INSERT INTO Paciente(Paciente_F, Senha_Hash, Salt_Paciente, Email, Nome_Paciente, Nome_Social, Fone) 
                        VALUES (@CPFT, @Hash, @Salt, @EmailT, @NomeT, @Nome_SocialT, @Fonee);

                        SELECT 'Paciente registrado com sucesso' AS 'Registra_Paciente_Retorno';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro interno - verifique os dados informados' AS 'Registra_Paciente_Retorno';
        END CATCH
END
GO

-- LOGIN PACIENTE
CREATE PROCEDURE Login_Paciente(
        @CPF VARCHAR(11),
        @Senha VARCHAR(256)
) AS
BEGIN
        DECLARE 
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128);

        BEGIN TRY
                -- Verificar se paciente existe e est� ativo
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Login_Paciente_Retorno';
                        RETURN;
                END

                -- Obter salt e hash armazenados
                SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                FROM Paciente WHERE Paciente_F = @CPF AND Ativo = 1;

                -- Verificar senha usando fun��o de verifica��o
                IF dbo.VerificarSenha(@Senha, @SaltArmazenado, @HashArmazenado) = 1
                BEGIN
                        SELECT Paciente_F, Senha_Hash, Email, Nome_Paciente, Nome_Social, Fone, Data_Criacao, Ativo
                        FROM Paciente WHERE Paciente_F = @CPF;
                END
                ELSE
                BEGIN
                        SELECT 'Senha incorreta' AS 'Login_Paciente_Retorno';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro no processo de login' AS 'Login_Paciente_Retorno';
        END CATCH
END
GO

-- REGISTRAR FUNCIONÁRIO
CREATE PROCEDURE Registra_Funcionario(
        @CNPJ VARCHAR(20),
        @ID_Tipo_Funcionario TINYINT,
        @Nome_Funcionario VARCHAR(100),
        @Senha_Funcionario VARCHAR(256),
        @Senha_Contratante VARCHAR(256)
) AS
BEGIN
        DECLARE
                @SaltEmpresa VARCHAR(64),
                @HashEmpresa VARCHAR(128),
                @Verificado BIT,
                @Empresa BIT,
                @VSenha BIT,
                @SaltFunc VARCHAR(64),
                @HashFunc VARCHAR(128);

		Set @Verificado = 1;
		Set @Empresa = 0;
		Set @VSenha = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CNPJ = LTRIM(RTRIM(@CNPJ));
                SET @Nome_Funcionario = LTRIM(RTRIM(@Nome_Funcionario));

                -- Verificar se empresa existe
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ)
                        SET @Empresa = 1;

                -- Verificar senha da empresa
                IF @Empresa = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @VSenha = 1;
                END

                -- Verificar campos nulos
                IF (@CNPJ = '') OR (@Nome_Funcionario = '') OR (@Senha_Funcionario = '') OR (LEN(@Senha_Funcionario) < 6)
                        SET @Verificado = 0;

                IF (@Empresa = 1) AND (@Verificado = 1) AND (@VSenha = 1)
                BEGIN
                        -- Gerar salt e hash para funcion�rio
                        SET @SaltFunc = CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
                        SET @HashFunc = dbo.HashSenha(@Senha_Funcionario, @SaltFunc);

                        INSERT INTO Funcionario (ID_Tipo_Funcionario, Nome_Funcionario, Senha_Hash, Salt_Funcionario, CNPJ) 
                        VALUES (@ID_Tipo_Funcionario, @Nome_Funcionario, @HashFunc, @SaltFunc, @CNPJ);

                        SELECT 'Funcion�rio registrado com sucesso' AS 'Registra_Funcionario_Retorno';
                END
                ELSE
                BEGIN
                        IF (@Empresa = 0) 
                                SELECT 'Empresa não encontrada' AS 'Registra_Funcionario_Retorno';
                        ELSE IF (@Verificado = 0) 
                                SELECT 'Preencha todos os campos corretamente' AS 'Registra_Funcionario_Retorno';
                        ELSE IF (@VSenha = 0) 
                                SELECT 'Senha da empresa incorreta' AS 'Registra_Funcionario_Retorno';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro no registro do funcionário' AS 'Registra_Funcionario_Retorno';
        END CATCH
END
GO

-- LOGIN FUNCIONÁRIO - ATUALIZADO
CREATE PROCEDURE Login_Funcionario(
        @ID_Funcionario INT,
        @Senha_Funcionario VARCHAR(256)
) AS
BEGIN
        DECLARE 
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128);

        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                BEGIN
                        SELECT 'Funcionário não encontrado ou inativo' AS 'Login_Funcionario_Retorno';
                        RETURN;
                END

                -- Obter salt e hash armazenados
                SELECT @SaltArmazenado = Salt_Funcionario, @HashArmazenado = Senha_Hash
                FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1;

                -- Verificar senha
                IF dbo.VerificarSenha(@Senha_Funcionario, @SaltArmazenado, @HashArmazenado) = 1
                BEGIN
                        SELECT Funcionar_Rec, ID_Tipo_Funcionario, Senha_Hash, CNPJ, Nome_Funcionario, Data_Criacao, Ativo
                        FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario;
                END
                ELSE
                BEGIN
                        SELECT 'Senha incorreta' AS 'Login_Funcionario_Retorno';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro no processo de login' AS 'Login_Funcionario_Retorno';
        END CATCH
END
GO

-- REGISTRAR RECEITA
CREATE PROCEDURE Registra_Receita (
        @ID_Funcionario INT,
        @Tipo_Funcionario_R TINYINT,
        @Senha_Funcionario VARCHAR(256),
        @Data_Validade DATE,
        @CPF_Receita VARCHAR(11),
        @Medicamento VARCHAR(200),
        @Detalhes VARCHAR(500),
        @Limite_Baixas TINYINT
) AS
BEGIN
        DECLARE
                @ID_Funcionario_R BIT,
                @Senha_Funcionario_R BIT,
                @CPF_Receita_R BIT,
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128);

		Set @ID_Funcionario_R = 0;
		Set @Senha_Funcionario_R = 0;
		Set @CPF_Receita_R = 0

        BEGIN TRY
                -- Verificar funcion�rio
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                        SET @ID_Funcionario_R = 1;

                -- Verificar senha funcion�rio
                IF @ID_Funcionario_R = 1
                BEGIN
                        SELECT @SaltArmazenado = Salt_Funcionario, @HashArmazenado = Senha_Hash
                        FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario;

                        IF dbo.VerificarSenha(@Senha_Funcionario, @SaltArmazenado, @HashArmazenado) = 1
                                SET @Senha_Funcionario_R = 1;
                END

                -- Verificar paciente
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Receita AND Ativo = 1)
                        SET @CPF_Receita_R = 1;

                -- Limitar baixas nulo se for zero
                IF @Limite_Baixas = 0
                        SET @Limite_Baixas = NULL;

                -- Verifica��es finais e inser��o
                IF (@ID_Funcionario_R = 1) AND (@Senha_Funcionario_R = 1) AND (@Tipo_Funcionario_R = 2) AND (@CPF_Receita_R = 1)
                BEGIN
                        INSERT INTO Receita (Funcionar_Rec, Data_Validade, Medicamento, Detalhes, Limite_Baixas, Paciente_F, Valido, Baixas) 
                        VALUES (@ID_Funcionario, @Data_Validade, @Medicamento, @Detalhes, @Limite_Baixas, @CPF_Receita, 1, 0);

                        SELECT 'Receita criada com sucesso' AS 'Retorno_Registra_Receita';
                END
                ELSE 
                BEGIN
                        IF (@ID_Funcionario_R = 0) 
                                SELECT 'Funcionário não encontrado ou inativo' AS 'Retorno_Registra_Receita';
                        ELSE IF (@Senha_Funcionario_R = 0) 
                                SELECT 'Senha do funcionário incorreta' AS 'Retorno_Registra_Receita';
                        ELSE IF (@Tipo_Funcionario_R != 2) 
                                SELECT 'Funcionário não tem permissão para criar receitas' AS 'Retorno_Registra_Receita';
                        ELSE IF (@CPF_Receita_R = 0) 
                                SELECT 'CPF do paciente não encontrado ou inativo' AS 'Retorno_Registra_Receita';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro no registro da receita' AS 'Retorno_Registra_Receita';
        END CATCH
END
GO

-- VER RECEITA
CREATE PROCEDURE Ver_Receita (
        @CPF_Receita VARCHAR(11)
) AS
BEGIN
        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Receita WHERE Paciente_F = @CPF_Receita)
                BEGIN
                        SELECT 'Nenhuma receita encontrada para este CPF' AS 'Ver_Receita_Retorno';
                        RETURN;
                END

                SELECT * FROM Receita WHERE Paciente_F = @CPF_Receita ORDER BY Data_Receita DESC;

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao consultar receitas' AS 'Ver_Receita_Retorno';
        END CATCH
END
GO

-- ALTERAR RECEITA (dar baixa)
CREATE PROCEDURE Altera_Receita (
        @ID_Funcionario_Alt INT,
        @Senha_Funcionario_Alt VARCHAR(256),
        @CPF_Alt VARCHAR(11),
        @ID_Receita INT
) AS
BEGIN
        DECLARE
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128),
                @Tipo_Funcionario_Alt TINYINT,
                @Limite_Baixas_Alt TINYINT,
                @Baixas_Atual TINYINT;

        BEGIN TRY
                -- Verifica��es b�sicas
                IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_Alt AND Ativo = 1)
                BEGIN
                        SELECT 'Funcionário não encontrado ou inativo' AS 'Retorno_Altera_Receita';
                        RETURN;
                END

                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Alt AND Ativo = 1)
                BEGIN
                        SELECT 'CPF do paciente não encontrado ou inativo' AS 'Retorno_Altera_Receita';
                        RETURN;
                END

                IF NOT EXISTS (SELECT 1 FROM Receita WHERE ID_Receita = @ID_Receita AND Paciente_F = @CPF_Alt)
                BEGIN
                        SELECT 'Receita não encontrada para este paciente' AS 'Retorno_Altera_Receita';
                        RETURN;
                END

                -- Verificar senha funcion�rio
                SELECT @SaltArmazenado = Salt_Funcionario, @HashArmazenado = Senha_Hash, @Tipo_Funcionario_Alt = ID_Tipo_Funcionario
                FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_Alt;

                IF dbo.VerificarSenha(@Senha_Funcionario_Alt, @SaltArmazenado, @HashArmazenado) = 0
                BEGIN
                        SELECT 'Senha do funcionário incorreta' AS 'Retorno_Altera_Receita';
                        RETURN;
                END

                IF @Tipo_Funcionario_Alt != 1
                BEGIN
                        SELECT 'Funcionório não tem permissão para dar baixas' AS 'Retorno_Altera_Receita';
                        RETURN;
                END

                -- Verificar limite de baixas
                SELECT @Limite_Baixas_Alt = Limite_Baixas, @Baixas_Atual = Baixas
                FROM Receita WHERE ID_Receita = @ID_Receita;

                IF @Limite_Baixas_Alt IS NOT NULL AND @Baixas_Atual >= @Limite_Baixas_Alt
                BEGIN
                        SELECT 'Limite de baixas atingido para esta receita' AS 'Retorno_Altera_Receita';
                        RETURN;
                END

                -- Dar baixa
                UPDATE Receita SET Baixas = (Baixas + 1) WHERE ID_Receita = @ID_Receita;
                SELECT 'Baixa registrada com sucesso' AS 'Retorno_Altera_Receita';

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao processar baixa da receita' AS 'Retorno_Altera_Receita';
        END CATCH
END
GO

-- INSERIR HISTÓRICO
CREATE PROCEDURE Insere_Historico(
        @CPF_Rec VARCHAR(11),
        @Senha_Paciente_Rec VARCHAR(256),
        @Historico_Arqui VARBINARY(MAX)
) AS
BEGIN
        DECLARE 
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128);

        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Rec AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Retorno_Registra_Historico';
                        RETURN;
                END

                -- Obter salt e hash do paciente
                SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                FROM Paciente WHERE Paciente_F = @CPF_Rec;

                IF dbo.VerificarSenha(@Senha_Paciente_Rec, @SaltArmazenado, @HashArmazenado) = 1
                BEGIN
                        INSERT INTO Historico_Medico (Paciente_F, Registro_Medico) 
                        VALUES (@CPF_Rec, @Historico_Arqui);
                        SELECT 'Histórico médico inserido com sucesso' AS 'Retorno_Registra_Historico';
                END
                ELSE
                BEGIN
                        SELECT 'Senha incorreta' AS 'Retorno_Registra_Historico';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao inserir histórico médico' AS 'Retorno_Registra_Historico';
        END CATCH
END
GO

-- VER HISTÓRICO
CREATE PROCEDURE Ver_Historico (
        @CPF_V_Historico_Pac VARCHAR(11)
) AS
BEGIN

        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_V_Historico_Pac AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Retorno_Ver_Histórico';
                        RETURN;
                END
				ELSE
					BEGIN
                        SELECT ID_Historico, Registro_Medico, Data_Registro 
                        FROM Historico_Medico 
                        WHERE Paciente_F = @CPF_V_Historico_Pac
                        ORDER BY Data_Registro DESC;
					END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao consultar histórico médico' AS 'Retorno_Ver_Histórico';
        END CATCH
END
GO

-- ENVIAR MENSAGEM (PACIENTE)
CREATE PROCEDURE Envia_Mensagem_P (
        @ID_Receptor INT,
        @ID_Mensageiro VARCHAR(11),
        @Mensagem VARCHAR(500)
) AS
BEGIN
        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @ID_Mensageiro AND Ativo = 1)
                BEGIN
                        SELECT 'CPF do paciente não encontrado ou inativo' AS 'Mensagem_Retorno_P';
                        RETURN;
                END

                IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Receptor AND Ativo = 1)
                BEGIN
                        SELECT 'Funcionário não encontrado ou inativo' AS 'Mensagem_Retorno_P';
                        RETURN;
                END

                -- Criptografar e inserir mensagem
                OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;

                INSERT INTO Mensagem (Paciente_F, Funcionar_Rec, Mensagem) 
                VALUES (@ID_Mensageiro, @ID_Receptor, 
                                ENCRYPTBYKEY(KEY_GUID('EnK_Mensag'), @Mensagem));

                CLOSE SYMMETRIC KEY EnK_Mensag;

                SELECT 'Mensagem enviada com sucesso' AS 'Mensagem_Retorno_P';

        END TRY
        BEGIN CATCH
                IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
                        CLOSE SYMMETRIC KEY EnK_Mensag;
                SELECT 'Erro ao enviar mensagem' AS 'Mensagem_Retorno_P';
        END CATCH
END
GO

-- ENVIAR MENSAGEM (FUNCIONÁRIO)
CREATE PROCEDURE Envia_Mensagem_F (
        @ID_Receptor VARCHAR(11),
        @ID_Mensageiro INT,
        @Mensagem VARCHAR(500)
) AS
BEGIN
        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Mensageiro AND Ativo = 1)
                BEGIN
                        SELECT 'Funcionário não encontrado ou inativo' AS 'Mensagem_Retorno_F';
                        RETURN;
                END

                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @ID_Receptor AND Ativo = 1)
                BEGIN
                        SELECT 'CPF do paciente não encontrado ou inativo' AS 'Mensagem_Retorno_F';
                        RETURN;
                END

                -- Criptografar e inserir mensagem
                OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;

                INSERT INTO Mensagem (Paciente_F, Funcionar_Rec, Mensagem) 
                VALUES (@ID_Receptor, @ID_Mensageiro, 
                                ENCRYPTBYKEY(KEY_GUID('EnK_Mensag'), @Mensagem));

                CLOSE SYMMETRIC KEY EnK_Mensag;

                SELECT 'Mensagem enviada com sucesso' AS 'Mensagem_Retorno_F';

        END TRY
        BEGIN CATCH
                IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
                        CLOSE SYMMETRIC KEY EnK_Mensag;
                SELECT 'Erro ao enviar mensagem' AS 'Mensagem_Retorno_F';
        END CATCH
END
GO

-- ALTERAR PACIENTE
CREATE PROCEDURE Alt_Paciente(
        @CPF_Alt_P VARCHAR(11),
        @Senha_Alt_P VARCHAR(256),
        @Email_Alt_P VARCHAR(100),
        @Nome_Alt_P VARCHAR(100),
        @Nome_Social_Alt_P VARCHAR(100)
) AS 
BEGIN
        DECLARE 
                @RetornoEmail BIT,
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128),
                @EmailT VARCHAR(100);

		Set @RetornoEmail = 1;

        BEGIN TRY
                SET @EmailT = LTRIM(RTRIM(REPLACE(@Email_Alt_P, ' ', '')));

                -- Valida��o b�sica de email
                IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100
                        SET @RetornoEmail = 0;

                -- Verificar CPF e senha
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Alt_P AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Retorno_Altera_Paciente';
                        RETURN;
                END

                -- Obter salt e hash do paciente
                SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                FROM Paciente WHERE Paciente_F = @CPF_Alt_P;

                IF dbo.VerificarSenha(@Senha_Alt_P, @SaltArmazenado, @HashArmazenado) = 0
                BEGIN
                        SELECT 'Senha incorreta' AS 'Retorno_Altera_Paciente';
                        RETURN;
                END

                IF @RetornoEmail = 0
                BEGIN
                        SELECT 'Email inválido - deve conter @ e domínio' AS 'Retorno_Altera_Paciente';
                        RETURN;
                END

                -- Realizar altera��es
                UPDATE Paciente SET 
                        Email = @EmailT,
                        Nome_Paciente = LTRIM(RTRIM(@Nome_Alt_P)),
                        Nome_Social = LTRIM(RTRIM(@Nome_Social_Alt_P))
                WHERE Paciente_F = @CPF_Alt_P;

                SELECT 'Dados alterados com sucesso' AS 'Retorno_Altera_Paciente';

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao alterar dados do paciente' AS 'Retorno_Altera_Paciente';
        END CATCH
END
GO

-- MOSTRAR CHAT
CREATE PROCEDURE Mostra_Chat(
        @CPF_M_Chat VARCHAR(11),
        @ID_Funcionario_M_Chat INT
) AS
BEGIN
        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_M_Chat AND Ativo = 1)
                BEGIN
                        SELECT 'CPF do paciente não encontrado ou inativo' AS 'Retorno_Mostra_Chat';
                        RETURN;
                END

                IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_M_Chat AND Ativo = 1)
                BEGIN
                        SELECT 'Funcionário não encontrado ou inativo' AS 'Retorno_Mostra_Chat';
                        RETURN;
                END

                -- Descriptografar e mostrar mensagens
                OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;

                SELECT 
                        ID_Chat,
                        Paciente_F,
                        Funcionar_Rec,
                        CONVERT(VARCHAR(500), DECRYPTBYKEY(Mensagem)) AS Mensagem,
                        Hora_Envio
                FROM Mensagem 
                WHERE Paciente_F = @CPF_M_Chat 
                  AND Funcionar_Rec = @ID_Funcionario_M_Chat
                ORDER BY Hora_Envio ASC;

                CLOSE SYMMETRIC KEY EnK_Mensag;

        END TRY
        BEGIN CATCH
                IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
                        CLOSE SYMMETRIC KEY EnK_Mensag;
                SELECT 'Erro ao consultar chat' AS 'Retorno_Mostra_Chat';
        END CATCH
END
GO

-- ALTERAR SENHA PACIENTE
CREATE PROCEDURE Alt_Senha_P(
        @Alt_CPF VARCHAR(11),
        @Nova_Senha VARCHAR(256)
) AS
BEGIN
        DECLARE 
                @Alt_Senha_R BIT,
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128),
                @NovoSalt VARCHAR(64),
                @NovoHash VARCHAR(128);

		Set @Alt_Senha_R = 0;

        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @Alt_CPF AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Alt_Senha_Retorno';
                        RETURN;
                END

                -- Verificar senha atual
                SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                FROM Paciente WHERE Paciente_F = @Alt_CPF;

                -- Validar nova senha
                IF LEN(LTRIM(RTRIM(@Nova_Senha))) >= 6
                        SET @Alt_Senha_R = 1;

                IF @Alt_Senha_R = 1
                BEGIN
                        -- Gerar novo salt e hash
                        SET @NovoSalt = CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
                        SET @NovoHash = dbo.HashSenha(@Nova_Senha, @NovoSalt);

                        UPDATE Paciente 
                        SET Senha_Hash = @NovoHash, Salt_Paciente = @NovoSalt
                        WHERE Paciente_F = @Alt_CPF;

                        SELECT 'Senha alterada com sucesso' AS 'Alt_Senha_Retorno';
                END
                ELSE
                BEGIN
                        SELECT 'Nova senha deve conter no mínimo 6 caracteres' AS 'Alt_Senha_Retorno';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao alterar senha' AS 'Alt_Senha_Retorno';
        END CATCH
END
GO

-- DESATIVAR FUNCIONÁRIO
CREATE PROCEDURE Desativa_Funcionario(
        @CNPJ_Contratante VARCHAR(20),
        @Senha_Contratante VARCHAR(256),
        @ID_Funcionario INT
) AS
BEGIN
        DECLARE
                @SaltEmpresa VARCHAR(64),
                @HashEmpresa VARCHAR(128),
                @Empresa_Existe BIT,
                @Senha_Valida BIT,
                @Funcionario_Existe BIT,
                @Funcionario_Pertence BIT;

		Set @Empresa_Existe = 0;
		Set @Senha_Valida = 0;
		Set @Funcionario_Existe = 0;
		Set @Funcionario_Pertence = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));

                -- Verificar se empresa existe
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;

                -- Verificar senha da empresa
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END

                -- Verificar se funcion�rio existe e est� ativo
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                        SET @Funcionario_Existe = 1;

                -- Verificar se funcion�rio pertence � empresa
                IF @Funcionario_Existe = 1 AND EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND CNPJ = @CNPJ_Contratante)
                        SET @Funcionario_Pertence = 1;

                -- Executar desativa��o se todas as valida��es passarem
                IF (@Empresa_Existe = 1) AND (@Senha_Valida = 1) AND (@Funcionario_Existe = 1) AND (@Funcionario_Pertence = 1)
                BEGIN
                        UPDATE Funcionario 
                        SET Ativo = 0 
                        WHERE Funcionar_Rec = @ID_Funcionario;

                        SELECT 'Funcionário desativado com sucesso' AS 'Retorno_Desativa_Funcionario';
                END
                ELSE
                BEGIN
                        IF (@Empresa_Existe = 0) 
                                SELECT 'Empresa não encontrada' AS 'Retorno_Desativa_Funcionario';
                        ELSE IF (@Senha_Valida = 0) 
                                SELECT 'Senha da empresa incorreta' AS 'Retorno_Desativa_Funcionario';
                        ELSE IF (@Funcionario_Existe = 0) 
                                SELECT 'Funcionário não encontrado ou já está inativo' AS 'Retorno_Desativa_Funcionario';
                        ELSE IF (@Funcionario_Pertence = 0) 
                                SELECT 'Funcionário não pertence a esta empresa' AS 'Retorno_Desativa_Funcionario';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao desativar funcionário' AS 'Retorno_Desativa_Funcionario';
        END CATCH
END
GO

-- REATIVAR FUNCIONÁRIO
CREATE PROCEDURE Reativa_Funcionario(
        @CNPJ_Contratante VARCHAR(20),
        @Senha_Contratante VARCHAR(256),
        @ID_Funcionario INT
) AS
BEGIN
        DECLARE
                @SaltEmpresa VARCHAR(64),
                @HashEmpresa VARCHAR(128),
                @Empresa_Existe BIT,
                @Senha_Valida BIT,
                @Funcionario_Existe BIT,
                @Funcionario_Pertence BIT;

		Set @Empresa_Existe = 0;
		Set @Senha_Valida = 0;
		Set @Funcionario_Pertence = 0;
		Set @Funcionario_Existe = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));

                -- Verificar se empresa existe
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;

                -- Verificar senha da empresa
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END

                -- Verificar se funcion�rio existe e est� inativo
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 0)
                        SET @Funcionario_Existe = 1;

                -- Verificar se funcion�rio pertence � empresa
                IF @Funcionario_Existe = 1 AND EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND CNPJ = @CNPJ_Contratante)
                        SET @Funcionario_Pertence = 1;

                -- Executar reativa��o se todas as valida��es passarem
                IF (@Empresa_Existe = 1) AND (@Senha_Valida = 1) AND (@Funcionario_Existe = 1) AND (@Funcionario_Pertence = 1)
                BEGIN
                        UPDATE Funcionario 
                        SET Ativo = 1 
                        WHERE Funcionar_Rec = @ID_Funcionario;

                        SELECT 'Funcionário reativado com sucesso' AS 'Retorno_Reativa_Funcionario';
                END
                ELSE
                BEGIN
                        IF (@Empresa_Existe = 0) 
                                SELECT 'Empresa não encontrada' AS 'Retorno_Reativa_Funcionario';
                        ELSE IF (@Senha_Valida = 0) 
                                SELECT 'Senha da empresa incorreta' AS 'Retorno_Reativa_Funcionario';
                        ELSE IF (@Funcionario_Existe = 0) 
                                SELECT 'Funcionário não encontrado ou já está ativo' AS 'Retorno_Reativa_Funcionario';
                        ELSE IF (@Funcionario_Pertence = 0) 
                                SELECT 'Funcionário não pertence a esta empresa' AS 'Retorno_Reativa_Funcionario';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao reativar funcionário' AS 'Retorno_Reativa_Funcionario';
        END CATCH
END
GO

-- LISTAR FUNCIONÁRIOS DA EMPRESA
CREATE PROCEDURE Lista_Funcionarios_Empresa(
        @CNPJ_Contratante VARCHAR(20),
        @Senha_Contratante VARCHAR(256),
        @Mostrar_Inativos BIT  -- 0 = são ativos, 1 = todos
) AS
BEGIN
        DECLARE
                @SaltEmpresa VARCHAR(64),
                @HashEmpresa VARCHAR(128),
                @Empresa_Existe BIT,
                @Senha_Valida BIT;

		Set @Empresa_Existe = 0;
		Set @Senha_Valida = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));

                -- Verificar se empresa existe
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;

                -- Verificar senha da empresa
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END

                -- Listar funcion�rios se valida��es passarem
                IF (@Empresa_Existe = 1) AND (@Senha_Valida = 1)
                BEGIN
                        SELECT 
                                f.Funcionar_Rec,
                                f.Nome_Funcionario,
                                tf.Tipo_Funci,
                                f.Data_Criacao,
                                CASE 
                                        WHEN f.Ativo = 1 THEN 'Ativo'
                                        ELSE 'Inativo'
                                END AS Status
                        FROM Funcionario f
                        INNER JOIN Tipo_Funcionario tf ON f.ID_Tipo_Funcionario = tf.ID_Tipo_Funcionario
                        WHERE f.CNPJ = @CNPJ_Contratante
                          AND (@Mostrar_Inativos = 1 OR f.Ativo = 1)
                        ORDER BY f.Nome_Funcionario;
                END
                ELSE
                BEGIN
                        IF (@Empresa_Existe = 0) 
                                SELECT 'Empresa não encontrada' AS 'Retorno_Lista_Funcionarios';
                        ELSE IF (@Senha_Valida = 0) 
                                SELECT 'Senha da empresa incorreta' AS 'Retorno_Lista_Funcionarios';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao listar funcionários' AS 'Retorno_Lista_Funcionarios';
        END CATCH
END
GO

-- DESATIVAR PACIENTE
CREATE PROCEDURE Desativa_Paciente(
        @CPF_Paciente VARCHAR(11),
        @Senha_Paciente VARCHAR(256)
) AS
BEGIN
        DECLARE
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128),
                @Paciente_Existe BIT,
                @Senha_Valida BIT;

		Set @Paciente_Existe = 0;
		Set @Senha_Valida = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CPF_Paciente = LTRIM(RTRIM(REPLACE(@CPF_Paciente, ' ', '')));

                -- Verificar se paciente existe e est� ativo
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Paciente AND Ativo = 1)
                        SET @Paciente_Existe = 1;

                -- Verificar senha do paciente
                IF @Paciente_Existe = 1
                BEGIN
                        SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                        FROM Paciente WHERE Paciente_F = @CPF_Paciente;

                        IF dbo.VerificarSenha(@Senha_Paciente, @SaltArmazenado, @HashArmazenado) = 1
                                SET @Senha_Valida = 1;
                END

                -- Executar desativa��o se todas as valida��es passarem
                IF (@Paciente_Existe = 1) AND (@Senha_Valida = 1)
                BEGIN
                        -- Desativar paciente
                        UPDATE Paciente 
                        SET Ativo = 0 
                        WHERE Paciente_F = @CPF_Paciente;

                        -- Invalidar todas as receitas ativas do paciente
                        UPDATE Receita 
                        SET Valido = 0 
                        WHERE Paciente_F = @CPF_Paciente AND Valido = 1;

                        SELECT 'Paciente desativado com sucesso' AS 'Retorno_Desativa_Paciente';
                END
                ELSE
                BEGIN
                        IF (@Paciente_Existe = 0) 
                                SELECT 'Paciente não encontrado ou já está inativo' AS 'Retorno_Desativa_Paciente';
                        ELSE IF (@Senha_Valida = 0) 
                                SELECT 'Senha incorreta' AS 'Retorno_Desativa_Paciente';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao desativar paciente' AS 'Retorno_Desativa_Paciente';
        END CATCH
END
GO

-- REATIVAR PACIENTE
CREATE PROCEDURE Reativa_Paciente(
        @CPF_Paciente VARCHAR(11),
        @Email_Paciente VARCHAR(100)
) AS
BEGIN
        DECLARE
                @Paciente_Existe BIT,
                @Email_Valido BIT,
                @Dados_Conferem BIT,
                @Email_Armazenado VARCHAR(100);

		Set @Paciente_Existe = 0;
		Set @Email_Valido = 0;
		Set @Dados_Conferem = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CPF_Paciente = LTRIM(RTRIM(REPLACE(@CPF_Paciente, ' ', '')));
                SET @Email_Paciente = LTRIM(RTRIM(REPLACE(@Email_Paciente, ' ', '')));

                -- Valida��o b�sica de email
                IF @Email_Paciente LIKE '%@%.%' AND LEN(@Email_Paciente) >= 6 AND LEN(@Email_Paciente) <= 100
                        SET @Email_Valido = 1;

                -- Verificar se paciente existe e est� inativo
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Paciente AND Ativo = 0)
                        SET @Paciente_Existe = 1;

                -- Verificar se os dados conferem (seguran�a adicional)
                IF @Paciente_Existe = 1
                BEGIN
                        SELECT @Email_Armazenado = Email FROM Paciente WHERE Paciente_F = @CPF_Paciente;
                        -- Verificar se email corresponde
                        IF  @Email_Armazenado = @Email_Paciente
                                SET @Dados_Conferem = 1;
                END

                -- Executar reativa��o se todas as valida��es passarem
                IF (@Paciente_Existe = 1) AND (@Email_Valido = 1) AND (@Dados_Conferem = 1)
                BEGIN
                        -- Reativar paciente
                        UPDATE Paciente 
                        SET Ativo = 1 
                        WHERE Paciente_F = @CPF_Paciente;

                        SELECT 'Paciente reativado com sucesso.' AS 'Retorno_Reativa_Paciente';
                END
                ELSE
                BEGIN
                        IF (@Paciente_Existe = 0) 
                                SELECT 'Paciente não encontrado ou já está ativo' AS 'Retorno_Reativa_Paciente';
                        ELSE IF (@Email_Valido = 0) 
                                SELECT 'Email inválido' AS 'Retorno_Reativa_Paciente';
                        ELSE IF (@Dados_Conferem = 0) 
                                SELECT 'Dados não conferem com o cadastro' AS 'Retorno_Reativa_Paciente';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao reativar paciente' AS 'Retorno_Reativa_Paciente';
        END CATCH
END
GO

-- ALTERAR SENHA FUNCIONÁRIO
CREATE PROCEDURE Alt_Funcionario(
        @ID_Funcionario INT,
        @Nova_Senha VARCHAR(256),
        @CNPJ_Contratante VARCHAR(20),
        @Senha_Contratante VARCHAR(256)
) AS
BEGIN
        DECLARE
                @SaltEmpresa VARCHAR(64),
                @HashEmpresa VARCHAR(128),
                @Empresa_Existe BIT,
                @Senha_Valida BIT,
                @Funcionario_Existe BIT,
                @Funcionario_Pertence BIT,
                @Nova_Senha_Valida BIT,
                @NovoSalt VARCHAR(64),
                @NovoHash VARCHAR(128);

		Set @Empresa_Existe = 0;
		Set @Senha_Valida = 0;
		Set @Funcionario_Existe = 0;
		Set @Funcionario_Pertence = 0;
		Set @Nova_Senha_Valida = 0;

        BEGIN TRY
                -- Limpar entrada
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));
                SET @Nova_Senha = LTRIM(RTRIM(@Nova_Senha));

                -- Validar nova senha
                IF LEN(@Nova_Senha) >= 6
                        SET @Nova_Senha_Valida = 1;

                -- Verificar se empresa existe
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;

                -- Verificar senha da empresa
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END

                -- Verificar se funcion�rio existe e est� ativo
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                        SET @Funcionario_Existe = 1;

                -- Verificar se funcion�rio pertence � empresa
                IF @Funcionario_Existe = 1 AND EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND CNPJ = @CNPJ_Contratante)
                        SET @Funcionario_Pertence = 1;

                -- Executar altera��o da senha se todas as valida��es passarem
                IF (@Empresa_Existe = 1) AND (@Senha_Valida = 1) AND (@Funcionario_Existe = 1) AND (@Funcionario_Pertence = 1) AND (@Nova_Senha_Valida = 1)
                BEGIN
                        -- Gerar novo salt e hash
                        SET @NovoSalt = CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
                        SET @NovoHash = dbo.HashSenha(@Nova_Senha, @NovoSalt);

                        UPDATE Funcionario 
                        SET Senha_Hash = @NovoHash, Salt_Funcionario = @NovoSalt
                        WHERE Funcionar_Rec = @ID_Funcionario;

                        SELECT 'Senha do funcionário alterada com sucesso' AS 'Retorno_Alt_Funcionario';
                END
                ELSE
                BEGIN
                        IF (@Empresa_Existe = 0) 
                                SELECT 'Empresa não encontrada' AS 'Retorno_Alt_Funcionario';
                        ELSE IF (@Senha_Valida = 0) 
                                SELECT 'Senha da empresa incorreta' AS 'Retorno_Alt_Funcionario';
                        ELSE IF (@Funcionario_Existe = 0) 
                                SELECT 'Funcionário não encontrado ou est� inativo' AS 'Retorno_Alt_Funcionario';
                        ELSE IF (@Funcionario_Pertence = 0) 
                                SELECT 'Funcionário não pertence a esta empresa' AS 'Retorno_Alt_Funcionario';
                        ELSE IF (@Nova_Senha_Valida = 0) 
                                SELECT 'Nova senha deve conter no mínimo 6 caracteres' AS 'Retorno_Alt_Funcionario';
                END

        END TRY
        BEGIN CATCH
                SELECT 'Erro ao alterar senha do funcion�rio' AS 'Retorno_Alt_Funcionario';
        END CATCH
END
GO

--===============================================================================================
-- TRIGGER E PROCEDURE DE MANUTENÇÃO

-- TRIGGER: Validar receita após baixa
CREATE TRIGGER Validade_Receita ON Receita AFTER UPDATE AS
BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
                DECLARE @diff INT;

                SELECT @diff = (r.Limite_Baixas - r.Baixas)
                FROM Receita r
                INNER JOIN inserted i ON r.ID_Receita = i.ID_Receita
                WHERE r.Limite_Baixas IS NOT NULL;

                IF @diff <= 0
                BEGIN
                        UPDATE Receita 
                        SET Valido = 0 
                        WHERE ID_Receita = (SELECT ID_Receita FROM inserted);
                END

                SELECT 'Uma receita sofreu baixa' AS 'Retorno_Trigger_Validade_R';
        END TRY
        BEGIN CATCH
                SELECT 'Erro no trigger' AS 'Retorno_Trigger_Validade_R';
        END CATCH
END
GO

--===============================================================================================
--TESTES

-- PROCEDURE: Atualizar receitas vencidas
CREATE PROCEDURE Atualiza_Receita AS 
BEGIN
        BEGIN TRY
                -- Invalidar receitas vencidas
                UPDATE Receita 
                SET Valido = 0 
                WHERE Data_Validade < CAST(GETDATE() AS DATE) 
                  AND Valido = 1;

                SELECT 'Receitas vencidas atualizadas com sucesso' AS 'Retorno_Atualiza_Receita';
        END TRY
        BEGIN CATCH
                SELECT 'Erro ao atualizar receitas vencidas' AS 'Retorno_Atualiza_Receita';
        END CATCH
END
GO

-- Teste 1: Registrar Paciente
EXEC Registra_Paciente '54856098802', 'Alanzoca', 'algumEmail@gmail.com', 'Alan', 'Talvez', '(55) +11 975793636';
GO

-- Teste 2: Login Paciente (Retorna as informaões e senha criptografada)
EXEC Login_Paciente '54856098802', 'Alanzoca';
GO

-- Teste 3: Registrar Funcionário
EXEC Registra_Funcionario '1', 1, 'Wanderley', 'senha123', 'senha';
GO

-- Teste 4: Login Funcionário (Retorna as informaões e senha criptografada)
EXEC Login_Funcionario 1, 'senha123';
GO

-- Teste 5: Registrar Receita
EXEC Registra_Receita 1, 2, 'senha123', '19-12-2025', '54856098802', 'Dorflex', 'Usar 3x ao dia', 3;
GO

-- Teste 6: Ver Receita
EXEC Ver_Receita '54856098802';
GO

-- Teste 7: Alterar Receita (dar baixa)
EXEC Altera_Receita 1, 'senha123', '54856098802', 1;
GO

-- Teste 8: Enviar Mensagem (Paciente)
EXEC Envia_Mensagem_P 1, '54856098802', 'Mensagem Teste1';
GO

-- Teste 9: Enviar Mensagem (Funcionário)
EXEC Envia_Mensagem_F '54856098802', 1, 'Mensagem Teste2';
GO

-- Teste 10: Alterar dados do Paciente
EXEC Alt_Paciente '54856098802', 'Alanzoca', 'algumEmail@gmail.com', 'Alan2', 'Talvez2';
GO

-- Teste 11: Mostrar Chat
EXEC Mostra_Chat '54856098802', 1;
GO

-- Teste 12: Alterar Senha do Paciente
EXEC Alt_Senha_P '54856098802', 'Alanzocaaa';
GO

-- Teste 13: Atualizar Receitas
EXEC Atualiza_Receita;
GO

--Teste 14: Desativar Funcionario
EXEC Desativa_Funcionario '1', 'senha', '1';
GO

--Teste 15: Listar Funcionarios (Menos os Desativados)
EXEC Lista_Funcionarios_Empresa '1', 'senha', 0;
GO

--Teste 16: Reativa Funcionario
EXEC Reativa_Funcionario '1', 'senha', '1';
GO

--Teste 17: Listar Funcionarios (Todos)
EXEC Lista_Funcionarios_Empresa '1', 'senha', 1;
GO

--Teste 18: Desativar Paciente
EXEC Desativa_Paciente '54856098802', 'Alanzocaaa';
GO

--Teste 19: Reativa Paciente
EXEC Reativa_Paciente '54856098802', 'algumEmail@gmail.com';
GO

--Teste 20: Altera senha de Funcionário
EXEC Alt_Funcionario 1, 'novaSenha123', '1', 'senha';
GO
--Teste 20.2 Verificar alteração
EXEC Login_Funcionario 1, 'novaSenha123';
GO

--Teste 21 Insere Historico
Declare @Teste VarBinary;
Set @Teste = CONVERT(VARBINARY(MAX), 'Histórico');
EXEC Insere_Historico '54856098802', 'Alanzocaaa', @Teste;
GO

--Teste 22 Ver Historico
EXEC Ver_Historico '54856098802';

--TÁ FUNCIONANDO PRR!!!