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
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@AlAn21220JoRiVi21081/6969!';
GO
CREATE CERTIFICATE Cert_Mensag
WITH SUBJECT = 'Certificado para Mensagens';
GO
CREATE SYMMETRIC KEY EnK_Mensag 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Mensag;
GO
CREATE FUNCTION dbo.HashSenha(@senha VARCHAR(256), @salt VARCHAR(64))
RETURNS VARCHAR(128)
AS
BEGIN
    DECLARE @hash VARCHAR(128)
    SET @hash = CONVERT(VARCHAR(128), HASHBYTES('SHA2_512', @senha + @salt), 2)
    RETURN @hash
END
GO
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
CREATE TABLE Contratante (
        CNPJ VARCHAR(20) UNIQUE NOT NULL,
        Documentacao VARBINARY(MAX) NOT NULL,
        Nome_Contratante VARCHAR(100) NOT NULL,
        Senha_Hash VARCHAR(128) NOT NULL,
        Salt_Contratante VARCHAR(64) NOT NULL,
        Data_Criacao DATETIME2 DEFAULT GETDATE(),
		Ativo Bit Default 1,
        PRIMARY KEY (CNPJ)
);
GO
CREATE TABLE Tipo_Funcionario (
        ID_Tipo_Funcionario TINYINT,
        Tipo_Funci VARCHAR(50),
        PRIMARY KEY (ID_Tipo_Funcionario)
);
GO
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
CREATE TABLE Paciente (
        Paciente_F VARCHAR(11) UNIQUE NOT NULL,
        Senha_Hash VARCHAR(128) NOT NULL,
        Salt_Paciente VARCHAR(64) NOT NULL,
        Email VARCHAR(100)NOT NULL,
        Fone VARCHAR(20),
        Nome_Paciente VARCHAR(100) NOT NULL,
        Nome_Social VARCHAR(100) NOT NULL,
        Data_Criacao DATETIME2 DEFAULT GETDATE(),
        Ativo BIT DEFAULT 1,
        PRIMARY KEY (Paciente_F)
);
GO
CREATE TABLE Receita (
        ID_Receita INT IDENTITY NOT NULL,
        Data_Receita DATETIME2 NOT NULL DEFAULT GETDATE(),
        Data_Validade DATE NOT NULL,
        Funcionar_Rec INT NOT NULL,
		Funcionar_Nome VARCHAR(100) NOT NULL,
        Paciente_F VARCHAR(11) NOT NULL,
        Medicamento VARCHAR(200) NOT NULL,
        Detalhes VARCHAR(500),
        Limite_Baixas TINYINT,
        Valido BIT DEFAULT 1,
        Baixas TINYINT DEFAULT 1,
        PRIMARY KEY (ID_Receita),
        FOREIGN KEY (Funcionar_Rec) REFERENCES Funcionario(Funcionar_Rec),
        FOREIGN KEY (Paciente_F) REFERENCES Paciente(Paciente_F)
);
GO
CREATE TABLE Historico_Medico (
        ID_Historico INT IDENTITY NOT NULL,
        Paciente_F VARCHAR(11) NOT NULL,
        Registro_Medico VARBINARY(MAX) NOT NULL,
        Data_Registro DATETIME2 DEFAULT GETDATE(),
        PRIMARY KEY (ID_Historico),
        FOREIGN KEY (Paciente_F) REFERENCES Paciente(Paciente_F)
);
GO
CREATE TABLE Mensagem (
        ID_Chat INT IDENTITY,
        Paciente_F VARCHAR(11),
        Funcionar_Rec INT,
        Mensagem VARBINARY(MAX),
        Hora_Envio DATETIME2 DEFAULT GETDATE(),
		MsgPaciente Bit DEFAULT 0,
        PRIMARY KEY (ID_Chat),
        FOREIGN KEY (Paciente_F) REFERENCES Paciente(Paciente_F),
        FOREIGN KEY (Funcionar_Rec) REFERENCES Funcionario(Funcionar_Rec)
);
GO
CREATE INDEX IDX_CNPJ ON Contratante(CNPJ);
CREATE INDEX IDX_Paciente_F ON Paciente(Paciente_F);
CREATE INDEX IDX_Funcionario_Ativo ON Funcionario(Funcionar_Rec, Ativo);
CREATE INDEX IDX_Receita_Paciente ON Receita(Paciente_F, Data_Receita);
CREATE INDEX IDX_Receita_Funcionario ON Receita(Funcionar_Rec, Data_Receita);
CREATE INDEX IDX_Historico_Paciente ON Historico_Medico(Paciente_F, Data_Registro);
CREATE INDEX IDX_Mensagem_Chat ON Mensagem(Paciente_F, Funcionar_Rec, Hora_Envio);
GO
INSERT INTO Tipo_Funcionario (ID_Tipo_Funcionario, Tipo_Funci) VALUES
        (1, 'Funcionário Farmácia'),
        (2, 'Funcionário Saúde'),
        (3, 'Administrador Farmácia'),
        (4, 'Administrador Hospital');
GO
Create Procedure Contrata (
		@CNPJ Varchar(20),
		@Doc Varbinary(Max),
		@Nome Varchar(32),
		@Registro Varchar(32)
) As
	BEGIN TRY
	IF (Select Count(CNPJ) From Contratante Where CNPJ = @CNPJ) = 0
		Begin
			DECLARE @salt VARCHAR(64) 
			Set @salt= CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
			DECLARE @hash VARCHAR(128) 
			Set @hash= dbo.HashSenha(@Registro, @salt);
			INSERT INTO Contratante (CNPJ, Documentacao, Nome_Contratante, Senha_Hash, Salt_Contratante) VALUES (@CNPJ, @Doc, @Nome, @hash, @salt);
			Select 'Registro Concluido' As 'Retorno_Registro_Contratante'
		End
	Else Select 'CNPJ já está no sistema' As 'Retorno_Registro_Contratante'
	END TRY
	BEGIN CATCH
		Select 'Informação Inválida' As 'Retorno_Registro_Contratante'
	END CATCH
GO
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
                SET @CPFT = REPLACE(@CPF, ' ', '');
                SET @SenhaT = LTRIM(RTRIM(@Senha));
                SET @EmailT = LTRIM(RTRIM(REPLACE(@Email, ' ', '')));
                SET @NomeT = LTRIM(RTRIM(@Nome));
                SET @Nome_SocialT = LTRIM(RTRIM(@Nome_Social));
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPFT)
                BEGIN
                        SELECT 'CPF já cadastrado no sistema' AS 'Registra_Paciente_Retorno';
                        RETURN;
                END
                IF @CPFT = '' OR @SenhaT = '' OR @EmailT = '' OR @NomeT = ''
                        SET @RetornoNull = 0;
                ELSE
                        SET @RetornoNull = 1;
                IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100 AND (Select Count(Email) From Paciente Where Email = @EmailT) != 0
                        SET @RetornoEmail = 0;
                IF LEN(@CPFT) = 11 AND ISNUMERIC(@CPFT) = 1
                        SET @RetornoCPF = 1;
                IF LEN(@SenhaT) >= 6
                        SET @RetornoSenha = 1;
                ELSE
                        SET @RetornoSenha = 0;
                IF @RetornoNull = 0 OR @RetornoCPF = 0 OR @RetornoEmail = 0 OR @RetornoSenha = 0
                BEGIN
                        IF (@RetornoNull = 0) 
                                SELECT 'Todos os campos devem ser preenchidos' AS 'Registra_Paciente_Retorno';
                        ELSE IF (@RetornoCPF = 0) 
                                SELECT 'CPF deve conter exatamente 11 dígitos numéricos' AS 'Registra_Paciente_Retorno';
                        ELSE IF (@RetornoEmail = 0) 
                                SELECT 'Email inválido ou já registrado' AS 'Registra_Paciente_Retorno';
                        ELSE IF (@RetornoSenha = 0) 
                                SELECT 'Senha deve conter no mínimo 6 caracteres' AS 'Registra_Paciente_Retorno';
                END
                ELSE 
                BEGIN
                        SET @Salt = CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
                        SET @Hash = dbo.HashSenha(@SenhaT, @Salt);
                        INSERT INTO Paciente(Paciente_F, Senha_Hash, Salt_Paciente, Email, Nome_Paciente, Nome_Social, Fone) 
                        VALUES (@CPFT, @Hash, @Salt, @EmailT, @NomeT, @Nome_SocialT, @Fonee);

                        SELECT 'Paciente registrado com sucesso' AS 'Registra_Paciente_Retorno';
                END
        END TRY
        BEGIN CATCH
                SELECT 'Verifique os dados informados' AS 'Registra_Paciente_Retorno';
        END CATCH
END
GO
CREATE PROCEDURE Login_Paciente(
        @CPF VARCHAR(11),
        @Senha VARCHAR(256)
) AS
BEGIN
        DECLARE 
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128);

        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Login_Paciente_Retorno';
                        RETURN;
                END
                SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                FROM Paciente WHERE Paciente_F = @CPF AND Ativo = 1;
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
CREATE PROCEDURE Registra_Funcionario(
        @CNPJ VARCHAR(20),
        @ID_Tipo_Funcionario TINYINT,
        @Nome_Funcionario VARCHAR(100),
        @Senha_Funcionario VARCHAR(256)
) AS
BEGIN
        DECLARE
                @SaltEmpresa VARCHAR(64),
                @HashEmpresa VARCHAR(128),
                @Verificado BIT,
                @Empresa BIT,
                @SaltFunc VARCHAR(64),
                @HashFunc VARCHAR(128);
		Set @Verificado = 1;
		Set @Empresa = 0;
        BEGIN TRY
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ)
                        SET @Empresa = 1;
                IF @Empresa = 1
                BEGIN
                IF (@CNPJ = '') OR (@Nome_Funcionario = '') OR (@Senha_Funcionario = '') OR (LEN(@Senha_Funcionario) < 6)
                        SET @Verificado = 0;
				END
                IF (@Empresa = 1) AND (@Verificado = 1)
                BEGIN
                        SET @SaltFunc = CONVERT(VARCHAR(64), NEWID()) + CONVERT(VARCHAR(64), NEWID());
                        SET @HashFunc = dbo.HashSenha(@Senha_Funcionario, @SaltFunc);
                        INSERT INTO Funcionario (ID_Tipo_Funcionario, Nome_Funcionario, Senha_Hash, Salt_Funcionario, CNPJ) 
                        VALUES (@ID_Tipo_Funcionario, @Nome_Funcionario, @HashFunc, @SaltFunc, @CNPJ);
                        SELECT 'Funcionário registrado com sucesso' AS 'Registra_Funcionario_Retorno';
                END
                ELSE
                BEGIN
                        IF (@Empresa = 0) 
                                SELECT 'Empresa não encontrada' AS 'Registra_Funcionario_Retorno';
                        ELSE IF (@Verificado = 0) 
                                SELECT 'Preencha todos os campos corretamente' AS 'Registra_Funcionario_Retorno';
                END
        END TRY
        BEGIN CATCH
                SELECT 'Erro no registro do funcionário' AS 'Registra_Funcionario_Retorno';
        END CATCH
END
GO
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
                SELECT @SaltArmazenado = Salt_Funcionario, @HashArmazenado = Senha_Hash
                FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1;
                IF dbo.VerificarSenha(@Senha_Funcionario, @SaltArmazenado, @HashArmazenado) = 1
                BEGIN
                        SELECT Funcionar_Rec, ID_Tipo_Funcionario, CNPJ, Nome_Funcionario, Data_Criacao, Ativo
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
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                        SET @ID_Funcionario_R = 1;
                IF @ID_Funcionario_R = 1
                BEGIN
                        SELECT @SaltArmazenado = Salt_Funcionario, @HashArmazenado = Senha_Hash
                        FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario;
                        IF dbo.VerificarSenha(@Senha_Funcionario, @SaltArmazenado, @HashArmazenado) = 1
                                SET @Senha_Funcionario_R = 1;
                END
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Receita AND Ativo = 1)
                        SET @CPF_Receita_R = 1;
                IF @Limite_Baixas = 0
                        SET @Limite_Baixas = NULL;
                IF (@ID_Funcionario_R = 1) AND (@Senha_Funcionario_R = 1) AND (@Tipo_Funcionario_R = 2) AND (@CPF_Receita_R = 1)
                BEGIN
                        INSERT INTO Receita (Funcionar_Rec,Funcionar_Nome, Data_Validade, Medicamento, Detalhes, Limite_Baixas, Paciente_F, Valido, Baixas) 
                        VALUES (@ID_Funcionario, (SELECT Nome_Funcionario FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario),@Data_Validade, @Medicamento, @Detalhes, @Limite_Baixas, @CPF_Receita, 1, 0);
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
                SELECT * FROM Receita R WHERE Paciente_F = @CPF_Receita ORDER BY Valido, Data_Receita DESC;
        END TRY
        BEGIN CATCH
                SELECT 'Erro ao consultar receitas' AS 'Ver_Receita_Retorno';
        END CATCH
END
GO
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
                SELECT @Limite_Baixas_Alt = Limite_Baixas, @Baixas_Atual = Baixas
                FROM Receita WHERE ID_Receita = @ID_Receita;
                IF @Limite_Baixas_Alt IS NOT NULL AND @Baixas_Atual >= @Limite_Baixas_Alt
                BEGIN
                        SELECT 'Limite de baixas atingido para esta receita' AS 'Retorno_Altera_Receita';
                        RETURN;
                END
                UPDATE Receita SET Baixas = (Baixas + 1) WHERE ID_Receita = @ID_Receita;
                SELECT 'Baixa registrada com sucesso' AS 'Retorno_Altera_Receita';
        END TRY
        BEGIN CATCH
                SELECT 'Erro ao processar baixa da receita' AS 'Retorno_Altera_Receita';
        END CATCH
END
GO
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
                OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
                INSERT INTO Mensagem (Paciente_F, Funcionar_Rec, Mensagem, MsgPaciente) 
                VALUES (@ID_Mensageiro, @ID_Receptor, ENCRYPTBYKEY(KEY_GUID('EnK_Mensag'), @Mensagem), 1);
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
CREATE PROCEDURE Alt_Paciente(
        @CPF_Alt_P VARCHAR(11),
        @Senha_Alt_P VARCHAR(256),
        @Email_Alt_P VARCHAR(100),
        @Nome_Alt_P VARCHAR(100),
        @Nome_Social_Alt_P VARCHAR(100),
		@Tel_Alt_R VARCHAR(20)
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
                IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100
                        SET @RetornoEmail = 0;
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Alt_P AND Ativo = 1)
                BEGIN
                        SELECT 'CPF não encontrado ou conta inativa' AS 'Retorno_Altera_Paciente';
                        RETURN;
                END
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
                UPDATE Paciente SET 
                        Email = @EmailT,
                        Nome_Paciente = LTRIM(RTRIM(@Nome_Alt_P)),
                        Nome_Social = LTRIM(RTRIM(@Nome_Social_Alt_P)),
						Fone = LTRIM(RTRIM(@Tel_Alt_R))
                WHERE Paciente_F = @CPF_Alt_P;
                SELECT 'Dados alterados com sucesso' AS 'Retorno_Altera_Paciente';
        END TRY
        BEGIN CATCH
                SELECT 'Erro ao alterar dados do paciente' AS 'Retorno_Altera_Paciente';
        END CATCH
END
GO
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
                OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
                SELECT 
                        ID_Chat,
                        Paciente_F,
                        Funcionar_Rec,
                        CONVERT(VARCHAR(500), DECRYPTBYKEY(Mensagem)) AS Mensagem,
                        Hora_Envio,
						MsgPaciente
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
                SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                FROM Paciente WHERE Paciente_F = @Alt_CPF;
                IF LEN(LTRIM(RTRIM(@Nova_Senha))) >= 6
                        SET @Alt_Senha_R = 1;
                IF @Alt_Senha_R = 1
                BEGIN
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
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;
                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                        SET @Funcionario_Existe = 1;
                IF @Funcionario_Existe = 1 AND EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND CNPJ = @CNPJ_Contratante)
                        SET @Funcionario_Pertence = 1;
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
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 0)
                        SET @Funcionario_Existe = 1;
                IF @Funcionario_Existe = 1 AND EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND CNPJ = @CNPJ_Contratante)
                        SET @Funcionario_Pertence = 1;
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
CREATE PROCEDURE Lista_Funcionarios_Empresa(
        @CNPJ_Contratante VARCHAR(20),
        @Senha_Contratante VARCHAR(256),
        @Mostrar_Inativos BIT
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
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;
                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END
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
                SET @CPF_Paciente = LTRIM(RTRIM(REPLACE(@CPF_Paciente, ' ', '')));
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Paciente AND Ativo = 1)
                        SET @Paciente_Existe = 1;
                IF @Paciente_Existe = 1
                BEGIN
                        SELECT @SaltArmazenado = Salt_Paciente, @HashArmazenado = Senha_Hash
                        FROM Paciente WHERE Paciente_F = @CPF_Paciente;

                        IF dbo.VerificarSenha(@Senha_Paciente, @SaltArmazenado, @HashArmazenado) = 1
                                SET @Senha_Valida = 1;
                END
                IF (@Paciente_Existe = 1) AND (@Senha_Valida = 1)
                BEGIN
                        UPDATE Paciente 
                        SET Ativo = 0 
                        WHERE Paciente_F = @CPF_Paciente;
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
                SET @CPF_Paciente = LTRIM(RTRIM(REPLACE(@CPF_Paciente, ' ', '')));
                SET @Email_Paciente = LTRIM(RTRIM(REPLACE(@Email_Paciente, ' ', '')));
                IF @Email_Paciente LIKE '%@%.%' AND LEN(@Email_Paciente) >= 6 AND LEN(@Email_Paciente) <= 100
                        SET @Email_Valido = 1;
                IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Paciente AND Ativo = 0)
                        SET @Paciente_Existe = 1;
                IF @Paciente_Existe = 1
                BEGIN
                        SELECT @Email_Armazenado = Email FROM Paciente WHERE Paciente_F = @CPF_Paciente;
                        IF  @Email_Armazenado = @Email_Paciente
                                SET @Dados_Conferem = 1;
                END
                IF (@Paciente_Existe = 1) AND (@Email_Valido = 1) AND (@Dados_Conferem = 1)
                BEGIN
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
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));
                SET @Nova_Senha = LTRIM(RTRIM(@Nova_Senha));
                IF LEN(@Nova_Senha) >= 6
                        SET @Nova_Senha_Valida = 1;
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;
                IF @Empresa_Existe = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ_Contratante;

                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @Senha_Valida = 1;
                END
                IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
                        SET @Funcionario_Existe = 1;
                IF @Funcionario_Existe = 1 AND EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND CNPJ = @CNPJ_Contratante)
                        SET @Funcionario_Pertence = 1;
                IF (@Empresa_Existe = 1) AND (@Senha_Valida = 1) AND (@Funcionario_Existe = 1) AND (@Funcionario_Pertence = 1) AND (@Nova_Senha_Valida = 1)
					BEGIN
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
CREATE PROCEDURE Login_Contratante(
		@CNPJ Varchar(20),
		@Senha Varchar(32)
	) As
		DECLARE 
                @SaltArmazenado VARCHAR(64),
                @HashArmazenado VARCHAR(128);
		BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ AND Ativo = 1)
					BEGIN
							SELECT 'CNPJ não encontrado ou conta inativa' AS 'Login_Contratante_Retorno';
							RETURN;
					END
				SELECT @SaltArmazenado = Salt_Contratante, @HashArmazenado = Senha_Hash FROM Contratante WHERE CNPJ = @CNPJ AND Ativo = 1;
                IF dbo.VerificarSenha(@Senha, @SaltArmazenado, @HashArmazenado) = 1
					BEGIN
							SELECT CNPJ, Nome_Contratante, Senha_Hash, Data_Criacao, Ativo FROM Contratante WHERE CNPJ = @CNPJ;
					END
                ELSE
					BEGIN
							SELECT 'Senha incorreta' AS 'Login_Contratante_Retorno';
					END
        END TRY
        BEGIN CATCH
                SELECT 'Erro no processo de login' AS 'Login_Contratante_Retorno';
        END CATCH
GO
CREATE PROCEDURE Mostra_Funcionario (@ID_Funcionario INT)AS
BEGIN
	BEGIN TRY
		SELECT Nome_Funcionario, F.CNPJ, F.Ativo, C.Nome_Contratante FROM Funcionario F Inner Join Contratante C On F.CNPJ = C.CNPJ Where F.Funcionar_Rec = @ID_Funcionario;
	END TRY
	BEGIN CATCH
		SELECT '' AS 'Mostra_Funcionário_Retorno';
	END CATCH
END
GO
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
CREATE PROCEDURE Atualiza_Receita AS 
BEGIN
        BEGIN TRY
                UPDATE Receita 
                SET Valido = 0 
                WHERE Data_Validade < CAST(GETDATE() AS DATE) AND Valido = 1;
                SELECT 'Receitas vencidas atualizadas com sucesso' AS 'Retorno_Atualiza_Receita';
        END TRY
        BEGIN CATCH
                SELECT 'Erro ao atualizar receitas vencidas' AS 'Retorno_Atualiza_Receita';
        END CATCH
END
GO
Exec Contrata '1', 0xABCDEF, 'CayoLandia',			'senha';
Exec Contrata '2', 0xABCDEF, 'AndréFeira',			'senha1';
Exec Contrata '3', 0xABCDEF, 'JonasTryHard',		'senha2';
Exec Contrata '4', 0xABCDEF, 'AlanTalvez',			'senha3';
Exec Contrata '5', 0xABCDEF, 'BogasRiquelmus',		'senha4';
Exec Contrata '6', 0xABCDEF, 'O Império',			'senhaMuitoBoa';
Exec Contrata '7', 0xABCDEF, 'SuperRobens',			'senha5';
Exec Contrata '8', 0xABCDEF, 'UltraBombs',			'senha6';
Exec Contrata '9', 0xABCDEF, 'JovenzinhosSergio',	'senha7';
Exec Registra_Funcionario '9', 1, 'Alan Ono Osanai Pan',												'senha123';
Exec Registra_Funcionario '1', 1, 'Alexandre',															'senha123?';
Exec Registra_Funcionario '1', 1, 'Allan Alves',														'senha123?';
Exec Registra_Funcionario '1', 1, 'André Fabian',														'senha123?';
Exec Registra_Funcionario '1', 1, 'Bruno Alves',														'senha123?';
Exec Registra_Funcionario '2', 1, 'Caue',																'senha123?';
Exec Registra_Funcionario '9', 1, 'Cayo',																'senha123?';
Exec Registra_Funcionario '2', 1, 'Daniel',																'senha123?';
Exec Registra_Funcionario '2', 1, 'Elisa',																'senha123?';
Exec Registra_Funcionario '3', 2, 'Enzo',																'senha123?';
Exec Registra_Funcionario '3', 2, 'Gabriel Eiki',														'senha123?';
Exec Registra_Funcionario '3', 2, 'Gabriel Gonçalves',													'senha123?';
Exec Registra_Funcionario '4', 2, 'Gabriel Oliveira',													'senha123?';
Exec Registra_Funcionario '4', 2, 'Gabriel Sobral',														'senha123?';
Exec Registra_Funcionario '4', 2, 'Giovanini Urologista',												'senha123?';
Exec Registra_Funcionario '5', 2, 'Heloisa Aiko Uehara',												'senha123?';
Exec Registra_Funcionario '5', 2, 'Henrique Bressan',													'senha123';
Exec Registra_Funcionario '5', 2, 'Joana',																'senha123?';
Exec Registra_Funcionario '9', 2, 'João',																'senha123?';
Exec Registra_Funcionario '9', 3, 'Jonatas',															'senha123?';
Exec Registra_Funcionario '5', 3, 'Jorge',																'senha123?';
Exec Registra_Funcionario '5', 3, 'Juliana',															'senha123?';
Exec Registra_Funcionario '2', 3, 'Karina',																'senha123?';
Exec Registra_Funcionario '4', 3, 'Kaully',																'senha123?';
Exec Registra_Funcionario '4', 3, 'Kelly Park',															'senha123?';
Exec Registra_Funcionario '4', 3, 'Leandro',															'senha123?';
Exec Registra_Funcionario '7', 3, 'Leonardo',												 			'senha123?';
Exec Registra_Funcionario '7', 3, 'Lucas',																'senha123?';
Exec Registra_Funcionario '7', 3, 'Maria Vitória Tavares',												'senha123?';
Exec Registra_Funcionario '7', 4, 'Natália',															'senha123?';
Exec Registra_Funcionario '7', 4, 'Pedro²',																'senha123?';
Exec Registra_Funcionario '8', 4, 'Rafael',																'senha123?';
Exec Registra_Funcionario '8', 4, 'Ricardo',															'senha123?';
Exec Registra_Funcionario '8', 4, 'Rikelme',															'senha123?';
Exec Registra_Funcionario '6', 4, 'Riquelme Brain Rot da SILVA',										'senha123?';
Exec Registra_Funcionario '6', 4, 'Sophia',																'senha123?';
Exec Registra_Funcionario '8', 4, 'Teodora',															'senha123?';
Exec Registra_Funcionario '9', 4, 'Victor Hugo',														'senha123?';
Exec Registra_Funcionario '6', 4, 'V King',																'senha123?';
Exec Registra_Funcionario '6', 4, 'Vítor Pires',														'senha123?';
Exec Registra_Funcionario '6', 4, 'Vladmir Pudim',														'senha123?';
EXEC Registra_Funcionario '6', 4, 'Wanderley da Silva Souza de Mata Pera Pereira Vazconselos Oliveira',	'senha123';
Exec Registra_Funcionario '6', 4, 'Yasmin',																'senha123?';
EXEC Registra_Paciente '54856098802',	'Alanzoca',		'algumEmail@gmail.com',			'Alan',						'Talvez',						'11975793636';
EXEC Registra_Paciente '03674704030',	'Catapimbas12',	'webosi7905@dawhe.com',			'Mike Wazaoski',			'',								'11923456789';
EXEC Registra_Paciente '05642844083',	'Bananas',		'rehab1695@uorak.com',			'Raimundo',					'',								'11934567890';
EXEC Registra_Paciente '58061315050',	'Platano',		'joao3244@uorak.com',			'João',						'',								'11945678901';
EXEC Registra_Paciente '87949685000',	'Pineapple',	'tabitha1366@uorak.com',		'Tabata',					'',								'11956789012';
EXEC Registra_Paciente '75974478096',	'Abacaxi',		'jianhui5648@uorak.com',		'Jinora',					'',								'11967890123';
EXEC Registra_Paciente '34731605040',	'Manzana',		'binbin3746@uorak.com',			'Bianca',					'',								'11978901234';
EXEC Registra_Paciente '51890585068',	'Apple1',		'wilfrido2712@uorak.com',		'Wilfred',					'',								'11989012345';
EXEC Registra_Paciente '81112054065',	'Blueberry',	'elane7766@uorak.com',			'Elane',					'',								'11990123456';
EXEC Registra_Paciente '53274699055',	'Chia12',		'aroha4333@uorak.com',			'Aron',						'',								'11991234567';
EXEC Registra_Paciente '07628546005',	'Protagonista',	'inara3252@uorak.com',			'Irene',					'',								'11992345678';
EXEC Registra_Paciente '75286209041',	'Hornet',		'mitzie9696@uorak.com',			'Miriam',					'',								'11993456789';
EXEC Registra_Paciente '56470317065',	'Bettle',		'alan2212@uorak.com',			'Aaaaalan',					'',								'11994567890';
EXEC Registra_Paciente '19483550009',	'Parmegiana',	'adiela122@uorak.com',			'Kotone Shiomi',			'Not a Princess',				'11995678901';
EXEC Registra_Paciente '93729214080',	'Rosbife',		'christopher3650@uorak.com',	'Kris Dremurr',				'Lightner',						'11996789012';
EXEC Registra_Paciente '69068097091',	'Risoto',		'rabii3924@uorak.com',			'Keiji Shibusawa',			'Dragon',						'11997890123';
EXEC Registra_Paciente '21955621020',	'Macarronada',	'charo1949@uorak.com',			'Carol',					'',								'11998901234';
EXEC Registra_Paciente '08924899015',	'Bolonhesa',	'youcef4205@uorak.com',			'Yonatas',					'',								'11999012345';
EXEC Registra_Paciente '21524961086',	'Roux12',		'salobral8643@uorak.com',		'Daiseuke Kuse',			'',								'21923456789';
EXEC Registra_Paciente '39862328002',	'TortaDeLimao',	'wenche1232@uorak.com',			'Wesley',					'',								'21934567890';
EXEC Registra_Paciente '05892157016',	'Banoffe',		'alenjandro7008@uorak.com',		'Alejandro',				'',								'21945678901';
EXEC Registra_Paciente '22942383038',	'Cereja',		'amrinder8598@uorak.com',		'Ren Amamiya',				'JOKER',						'21956789012';
EXEC Registra_Paciente '43817833016',	'Uva123',		'xantal7174@uorak.com',			'Xantae',					'',								'21967890123';
EXEC Registra_Paciente '59784195070',	'Cogumelo',		'orencia5572@uorak.com',		'Ryuji Goda',				'Golden Dragon',				'21978901234';
EXEC Registra_Paciente '54273844052',	'Shimeji',		'mayssa77@uorak.com',			'Mayara',					'',								'21989012345';
EXEC Registra_Paciente '51971708089',	'Temaki',		'xevi7186@uorak.com',			'Yoshitaka Mine',			'The Kirin',					'21990123456';
EXEC Registra_Paciente '58614220014',	'Sushi1',		'josphine8493@uorak.com',		'Josefina',					'',								'21991234567';
EXEC Registra_Paciente '21341531058',	'Lamen1',		'dinis8748@uorak.com',			'Dionisio',					'',								'21992345678';
EXEC Registra_Paciente '91948947013',	'Gyoza1',		'flors9789@uorak.com',			'Flordis',					'',								'21993456789';
EXEC Registra_Paciente '40310919070',	'Taco12',		'penko988@uorak.com',			'Peko Pekoyama',			'Ultmate Martial Swordsman',	'21994567890';
EXEC Registra_Paciente '74315582018',	'Burrito',		'khawla7812@uorak.com',			'Kasemiro Walter',			'',								'21995678901';
EXEC Registra_Paciente '90934957045',	'Quesadilla',	'husam1393@uorak.com',			'Hugo Messias',				'',								'21996789012';
EXEC Registra_Paciente '43014639095',	'Pao123',		'shanna6488@uorak.com',			'Samara',					'Sadaoko',						'21997890123';
EXEC Registra_Paciente '33077793032',	'Lasanha',		'noria3789@uorak.com',			'Nori',						'',								'21998901234';
EXEC Registra_Paciente '62062052073',	'Virado',		'cherise1512@uorak.com',		'Chiquitita',				'',								'21999012345';
EXEC Registra_Paciente '10358560004',	'BaiaoDe2',		'enemesio7189@uorak.com',		'Eneias Pedro',				'',								'11923567890';
EXEC Registra_Paciente '47298600044',	'FileMignhon',	'shameka3800@uorak.com',		'Shameka',					'',								'11934678901';
EXEC Registra_Paciente '09577340008',	'PureDeBatata',	'espiritu2026@uorak.com',		'Espertino',				'',								'11945789012';
EXEC Registra_Paciente '18065460003',	'Bacalhau',		'qasim8524@uorak.com',			'Quasit',					'',								'11956890123';
EXEC Registra_Paciente '15150863050',	'Bolo3Leches',	'badara1011@uorak.com',			'Bandara',					'',								'11967901234';
EXEC Registra_Paciente '12614706051',	'Panetone',		'margaux4438@uorak.com',		'Margô',					'',								'11978012345';
EXEC Registra_Paciente '60030094038',	'Salame',		'koro8923@uorak.com',			'Koromaru',					'Koro-chan',					'11989123456';
EXEC Registra_Paciente '74689923043',	'Queijo',		'apolinar7587@uorak.com',		'Péricles',					'',								'11990234567';
EXEC Registra_Paciente '40526767006',	'Pizza1',		'dulcelina247@uorak.com',		'Dulcelina',				'',								'11991345678';
EXEC Registra_Paciente '13164571097',	'Hamburguer',	'sharilyn2650@uorak.com',		'Shamyn',					'',								'11992456789';
EXEC Registra_Paciente '86565804001',	'Beirute',		'ayaz6243@uorak.com',			'Ainz',						'',								'11993567890';
EXEC Registra_Paciente '85194921004',	'Shawarma',		'aduen8584@uorak.com',			'Makoto Nijima',			'Queen',						'11994678901';
EXEC Registra_Paciente '08343472020',	'Carbonara',	'chengjun9083@uorak.com',		'Cheng',					'',								'11995789012';
EXEC Registra_Paciente '75064872097',	'Ossobuco',		'camelia3387@uorak.com',		'Camelia',					'',								'11996890123';
EXEC Registra_Paciente '01421826054',	'Kimchi',		'fengqin5714@uorak.com',		'Feng Min',					'',								'11997901234';
EXEC Registra_Paciente '05819922026',	'Falafel',		'humilde3571@uorak.com',		'Joao Pereira',				'',								'11998012345';
EXEC Registra_Paciente '33342562005',	'Mussarela',	'messoud4453@uorak.com',		'Roberto Pessego',			'',								'11999123456';
EXEC Registra_Paciente '82945026007',	'RomeuJulieta',	'nalaya7171@uorak.com',			'Erazor Djin',				'',								'21923567890';
EXEC Registra_Paciente '38476344023',	'Cuzcuz',		'clair9757@uorak.com',			'Parcival',					'',								'21934678901';
EXEC Registra_Paciente '30964927004',	'Cupim1',		'vidala7446@uorak.com',			'Ammon',					'',								'21945789012';
EXEC Registra_Paciente '79021021056',	'Jajamyeon',	'etelvina4121@uorak.com',		'Parfait',					'',								'21956890123';
EXEC Registra_Paciente '93379047058',	'Cebola',		'jazmine95@uorak.com',			'Maelle',					'',								'21967901234';
EXEC Registra_Paciente '55124371005',	'Robux1',		'wiham8417@uorak.com',			'Clea',						'',								'21978012345';
EXEC Registra_Paciente '78762128086',	'V-Bucks',		'huili546@uorak.com',			'Taiga Saejima',			'Tiger',						'21989123456';
EXEC Registra_Paciente '42256849031',	'Bibinpap',		'stanford1897@uorak.com',		'Goro Majima',				'Mad Dog of Shimano',			'21990234567';
EXEC Registra_Paciente '01400902070',	'Sashimi',		'alyona8632@uorak.com',			'Daigo Dojima',				'',								'21991345678';
EXEC Registra_Paciente '49591700008',	'HotRoll',		'moneyba6921@uorak.com',		'Mr MoneyBags Sotenbori',	'',								'21992456789';
EXEC Registra_Paciente '53497527076',	'Uramaki',		'obdulio666@uorak.com',			'Shoei Dojima',				'',								'21993567890';
EXEC Registra_Paciente '17717478030',	'Naruto',		'shelton9852@uorak.com',		'Boruto Uzumaki',			'',								'21994678901';
EXEC Registra_Paciente '96481104092',	'OvoCozido',	'judie4817@uorak.com',			'Tatsuo Shinada',			'Shrimp Man',					'21995789012';
EXEC Registra_Paciente '17686975070',	'Pirulito',		'armindo8672@uorak.com',		'Myers',					'Escoteiro Chefe',				'21996890123';
EXEC Registra_Paciente '37666471050',	'Marshmallow',	'kathrine2227@uorak.com',		'John Krammer',				'Jigshaw',						'21997901234';
EXEC Registra_Paciente '58700766097',	'HotDog',		'florinel5540@uorak.com',		'Haruka Shawamura',			'',								'21998012345';
EXEC Registra_Paciente '47077123049',	'Churros',		'shavon8845@uorak.com',			'Don Ramon',				'',								'21999123456';
EXEC Registra_Paciente '96939809058',	'Shakra',		'wahab4798@uorak.com',			'Kazuma Kiryu',				'Dragon of Dojima',				'11924567890';
EXEC Registra_Paciente '24547397040',	'Poshaka',		'rababe9316@uorak.com',			'Ralsei',					'Fluffy Boy',					'11935678901';
EXEC Registra_Paciente '97702083026',	'Bazinga',		'grigore2265@uorak.com',		'Sheldon Copper',			'',								'11946789012';
EXEC Registra_Paciente '05483202090',	'Sorvete',		'julija1797@uorak.com',			'Asreiel Dremurr',			'Deus da Hipermorte',			'11957890123';
EXEC Registra_Paciente '73930978008',	'SopaDePedra',	'romul6283@uorak.com',			'Suzie',					'',								'11968901234';
EXEC Registra_Paciente '54537158042',	'Bis123',		'elinore842@uorak.com',			'Louis Guiabern',			'O Tirano',						'11979012345';
EXEC Registra_Paciente '00175474079',	'Chocolate',	'iosune8195@uorak.com',			'Nagito Komaeda',			'Ultmate Luck Student',			'11980123456';
EXEC Registra_Paciente '26572689000',	'Miojo',		'hyon1372@uorak.com',			'Hajime Hinata',			'',								'11991234568';
EXEC Registra_Paciente '67593704068',	'Camarão',		'yi6061@uorak.com',				'Makoto Naegi',				'Ultmate Hope',					'11992345679';
EXEC Registra_Paciente '39867593014',	'agua12',		'sandro7749@uorak.com',			'Gundan Tanaka',			'Ultmate Caretaker',			'11993456780';
EXEC Registra_Paciente '42891855094',	'Morango',		'kelly6831@uorak.com',			'Kyotaka',					'Ultmate Moral Compass',		'11994567891';
EXEC Registra_Paciente '35295496066',	'Abacate',		'bubutsu@yahho.com',			'Junko Enoshima',			'Ultmate Despair',				'11995678902';
EXEC Registra_Paciente '65331943055',	'Guacamole',	'bubutwsubaisein@gay.com',		'Ibuki Mioda',				'Ultmate Musician',				'11996789013';
EXEC Registra_Paciente '89961711076',	'Chorizo',		'mojuro@gojokun.com',			'Madeline',					'',								'11997890124';
EXEC Registra_Paciente '31895518040',	'Almondega',	'ahitor9468@uorak.com',			'Gerald Robotnik',			'',								'11998901235';
EXEC Registra_Paciente '90653374070',	'CarneMoida',	'katarina2569@uorak.com',		'Sulivan',					'',								'11999012346';
EXEC Registra_Paciente '46261355010',	'Cupim1',		'ramata3076@uorak.com',			'Dess Holiday',				'Roaring Knight',				'21924567890';
EXEC Registra_Paciente '59442913034',	'Picanha',		'mohamedi1885@uorak.com',		'Noelle Holiday',			'',								'21935678901';
EXEC Registra_Paciente '13977711008',	'Maminha',		'ilie8901@uorak.com',			'Gladion',					'',								'21946789012';
EXEC Registra_Paciente '53595358066',	'Risole',		'doramas872@uorak.com',			'Cyntia',					'',								'21957890123';
EXEC Registra_Paciente '87370831043',	'Salgadinho',	'shirl913@uorak.com',			'Volo',						'',								'21968901234';
EXEC Registra_Paciente '52546518062',	'PaoDeAlho',	'princess9632@uorak.com',		'Arceus',					'',								'21979012345';
EXEC Registra_Paciente '85082610040',	'Tomate',		'yeraldin4890@uorak.com',		'Geralt de Rívia',			'Geralt',						'21980123456';
EXEC Registra_Paciente '56858037020',	'Costela',		'gustav6656@uorak.com',			'Yennefer de Vanderberg',	'Yen',							'21991234568';
EXEC Registra_Paciente '90226815056',	'Pacu12',		'exuperancio8249@uorak.com',	'Cirila',					'Andorinha',					'21992345679';
EXEC Registra_Paciente '63806193053',	'Cookie',		'roumaissa8810@uorak.com',		'Jaskier',					'',								'21993456780';
EXEC Registra_Paciente '27788684023',	'Bolo12',		'sefora8192@uorak.com',			'Dandelion',				'',								'21994567891';
Exec Registra_Receita 10,	2, 'senha123',	'19-12-2025', '54856098802', 'Dorflex',					'Tomar 3x ao dia',										3; --Tipo_Func é sempre 2 para registrar receita
Exec Registra_Receita 11,	2, 'senha123?', '25-01-2026', '21524961086', 'Paracetamol 750mg',		'Tomar 1 comprimido de 8 em 8 horas',					2;
Exec Registra_Receita 12,	2, 'senha123?', '15-02-2026', '05642844083', 'Ibuprofeno 600mg',		'Tomar 1 comprimido de 12 em 12 horas após refeições',	4;
Exec Registra_Receita 13,	2, 'senha123?',	'20-03-2026', '58061315050', 'Amoxicilina 500mg',		'Tomar 1 cápsula de 8 em 8 horas por 7 dias',			2;
Exec Registra_Receita 14,	2, 'senha123?', '10-04-2026', '87949685000', 'Loratadina 10mg',			'Tomar 1 comprimido por dia pela manhã',				3;
Exec Registra_Receita 15,	2, 'senha123?', '05-05-2026', '75974478096', 'Omeprazol 20mg',			'Tomar 1 cápsula em jejum pela manhã',					3;
Exec Registra_Receita 16,	2, 'senha123?', '18-06-2026', '34731605040', 'Dipirona 500mg',			'Tomar 1 comprimido até 4x ao dia em caso de dor',		40;
Exec Registra_Receita 15,	2, 'senha123?', '22-07-2026', '51890585068', 'Captopril 25mg',			'Tomar 1 comprimido pela manhã em jejum',				30;
Exec Registra_Receita 18,	2, 'senha123?', '30-08-2026', '81112054065', 'Metformina 850mg',		'Tomar 1 comprimido após café da manhã',				30;
Exec Registra_Receita 19,	2, 'senha123?', '12-09-2026', '53274699055', 'Sinvastatina 20mg',		'Tomar 1 comprimido à noite antes de dormir',			30;
Exec Registra_Receita 10,	2, 'senha123?', '25-10-2026', '07628546005', 'Losartana 50mg',			'Tomar 1 comprimido pela manhã',						30;
Exec Registra_Receita 11,	2, 'senha123?', '14-11-2026', '75286209041', 'Fluoxetina 20mg',			'Tomar 1 cápsula pela manhã',							30;
Exec Registra_Receita 12,	2, 'senha123?', '08-12-2026', '87949685000', 'Cefalexina 500mg',		'Tomar 1 cápsula de 6 em 6 horas por 10 dias',			40;
Exec Registra_Receita 13,	2, 'senha123?', '16-01-2027', '19483550009', 'Clonazepam 2mg',			'Tomar 0,5mg (1/4 comp) à noite',						30;
Exec Registra_Receita 14,	2, 'senha123?', '28-02-2027', '93729214080', 'Atenolol 50mg',			'Tomar 1 comprimido pela manhã',						30;
Exec Registra_Receita 15,	2, 'senha123?', '19-03-2027', '69068097091', 'Prednisona 20mg',			'Tomar 1 comprimido após café da manhã por 5 dias',		5;
Exec Registra_Receita 16,	2, 'senha123?', '11-04-2027', '21955621020', 'Hidroclorotiazida 25mg',	'Tomar 1 comprimido pela manhã',						30;
Exec Registra_Receita 16,	2, 'senha123?', '23-05-2027', '39862328002', 'Azitromicina 500mg',		'Tomar 1 comprimido por dia por 3 dias',				3;
Exec Registra_Receita 18,	2, 'senha123?', '07-06-2027', '39862328002', 'Diclofenaco 50mg',		'Tomar 1 comprimido de 12 em 12 horas após refeições',	20;
Exec Registra_Receita 19,	2, 'senha123?', '15-07-2027', '39862328002', 'Ranitidina 150mg',		'Tomar 1 comprimido 2x ao dia',							60;
EXEC Registra_Paciente '12345678901', 'Senha@123', 'carlos.silva@email.com', 'Carlos Silva', 'Carlos', '11912345678';
EXEC Registra_Paciente '98765432109', 'Mudar#2024', 'maria.santos@email.com', 'Maria Santos', 'Mari', '11987654321';
EXEC Registra_Paciente '45678912304', 'Teste$456', 'joao.oliveira@email.com', 'João Oliveira', '', '11945678912';
EXEC Registra_Paciente '78912345607', 'Nova&789', 'ana.costa@email.com', 'Ana Costa', 'Aninha', '11978912345';
EXEC Registra_Paciente '32165498708', 'Pass!234', 'pedro.ferreira@email.com', 'Pedro Ferreira', '', '11932165498';
EXEC Registra_Paciente '65432198709', 'Chave@567', 'juliana.lima@email.com', 'Juliana Lima', 'Ju', '21965432198';
EXEC Registra_Paciente '98732165410', 'Acesso#890', 'roberto.alves@email.com', 'Roberto Alves', 'Beto', '21998732165';
EXEC Registra_Paciente '14725836901', 'Portal$123', 'fernanda.rodrigues@email.com', 'Fernanda Rodrigues', '', '11914725836';
EXEC Registra_Paciente '36925814702', 'Sistema&456', 'lucas.martins@email.com', 'Lucas Martins', '', '11936925814';
EXEC Registra_Paciente '25836914703', 'Entrada!789', 'patricia.souza@email.com', 'Patricia Souza', 'Paty', '11925836914';
EXEC Envia_Mensagem_P 2,	'03674704030', 'Bom dia! Preciso marcar uma consulta de retorno.';
EXEC Envia_Mensagem_P 3,	'05642844083', 'Olá, gostaria de saber sobre os resultados dos meus exames.';
EXEC Envia_Mensagem_P 4,	'58061315050', 'Oi, posso remarcar minha consulta para a próxima semana?';
EXEC Envia_Mensagem_P 5,	'87949685000', 'Boa tarde, o medicamento está fazendo efeito positivo!';
EXEC Envia_Mensagem_P 6,	'75974478096', 'Preciso de uma segunda via da receita, por favor.';
EXEC Envia_Mensagem_P 7,	'34731605040', 'Estou sentindo alguns efeitos colaterais do medicamento.';
EXEC Envia_Mensagem_P 8,	'51890585068', 'Quando posso agendar minha próxima consulta?';
EXEC Envia_Mensagem_P 9,	'81112054065', 'Obrigada pelo atendimento! Estou me sentindo melhor.';
EXEC Envia_Mensagem_P 10,	'53274699055', 'Posso tomar o medicamento junto com outros remédios?';
EXEC Envia_Mensagem_P 11,	'07628546005', 'Preciso alterar meu cadastro, mudei de telefone.';
EXEC Envia_Mensagem_P 12,	'75286209041', 'Dúvida sobre o horário correto para tomar o medicamento.';
EXEC Envia_Mensagem_P 13,	'56470317065', 'Bom dia! Como faço para solicitar atestado médico?';
EXEC Envia_Mensagem_P 14,	'19483550009', 'Estou viajando, posso interromper o tratamento?';
EXEC Envia_Mensagem_P 15,	'93729214080', 'O medicamento acabou, preciso de nova receita.';
EXEC Envia_Mensagem_F '03674704030', 2,		'Olá! Sua consulta está agendada para segunda-feira às 14h.';
EXEC Envia_Mensagem_F '05642844083', 3,		'Seus exames chegaram, pode buscar na recepção.';
EXEC Envia_Mensagem_F '58061315050', 4,		'Conseguimos remarcar para quarta-feira no mesmo horário.';
EXEC Envia_Mensagem_F '87949685000', 5,		'Que bom! Continue o tratamento conforme orientado.';
EXEC Envia_Mensagem_F '75974478096', 6,		'Segunda via da receita já está pronta para retirada.';
EXEC Envia_Mensagem_F '34731605040', 7,		'Vamos avaliar na próxima consulta, não pare o medicamento.';
EXEC Envia_Mensagem_F '51890585068', 8,		'Temos disponibilidade na próxima sexta às 16h.';
EXEC Envia_Mensagem_F '81112054065', 9,		'Ficamos felizes! Continue seguindo as orientações.';
EXEC Envia_Mensagem_F '53274699055', 10,	'É seguro, mas informe sempre todos os medicamentos que usa.';
EXEC Envia_Mensagem_F '07628546005', 11,	'Compareça à recepção com documento para atualizar cadastro.';
EXEC Envia_Mensagem_F '75286209041', 12,	'Tome sempre no mesmo horário, preferencialmente pela manhã.';
EXEC Envia_Mensagem_F '56470317065', 13,	'Atestado será emitido na sua próxima consulta presencial.';
EXEC Envia_Mensagem_F '19483550009', 14,	'Não interrompa sem orientação médica. Entre em contato urgente.';
EXEC Envia_Mensagem_F '93729214080', 15,	'Nova receita já foi preparada, pode retirar na farmácia.';
EXEC Envia_Mensagem_F '69068097091', 16,	'Lembre-se: consulta de retorno em 15 dias.';
EXEC Envia_Mensagem_F '21955621020', 17,	'Seus exames de rotina estão em dia, parabéns!';
EXEC Envia_Mensagem_F '08924899015', 18,	'Importante: termine todo o ciclo do antibiótico.';
EXEC Envia_Mensagem_F '21524961086', 19,	'Evite atividades físicas intensas durante o tratamento.';
EXEC Envia_Mensagem_F '39862328002', 20,	'Qualquer dúvida, estamos à disposição pelo WhatsApp.';
EXEC Envia_Mensagem_P 1,				'22942383038',	'Dr., posso tomar dipirona junto com o remédio prescrito?';
EXEC Envia_Mensagem_F '22942383038',	 1,				'Sim, pode tomar. Dipirona não interage com seu medicamento.';
EXEC Envia_Mensagem_P 2,				'43817833016',	'Doutora, minha pressão está 140x90, é normal?';
EXEC Envia_Mensagem_F '43817833016',	2,				'Está um pouco alta. Tome o medicamento e monitore diariamente.';
EXEC Envia_Mensagem_P 3,				'59784195070',	'Bom dia! Posso agendar consulta para minha esposa também?';
EXEC Envia_Mensagem_F '59784195070',	3,				'Claro! Ela precisa fazer cadastro primeiro na recepção.';
EXEC Envia_Mensagem_P 4,				'54273844052',	'O laboratório pediu para jejuar 12h, está correto?';
EXEC Envia_Mensagem_F '54273844052',	4,				'Sim, para seus exames é necessário jejum de 12 horas.';
EXEC Envia_Mensagem_P 5,				'51971708089',	'Doutora, posso fazer exercícios durante o tratamento?';
EXEC Envia_Mensagem_F '51971708089',	5,				'Exercícios leves são recomendados. Evite apenas impacto.';
EXEC Insere_Historico '54856098802',	'Alanzoca',		0xABCDEF;
EXEC Insere_Historico '40310919070',	'Taco12',		0xABCDEF;
EXEC Insere_Historico '43014639095',	'Pao123',		0xABCDEF;
EXEC Insere_Historico '67593704068',	'Camarão',		0xABCDEF;
EXEC Insere_Historico '85082610040',	'Tomate',		0xABCDEF;
EXEC Insere_Historico '19483550009',	'Parmegiana',	0xABCDEF;
EXEC Insere_Historico '65331943055',	'Guacamole',	0xABCDEF;
EXEC Insere_Historico '39867593014',	'agua12',		0xABCDEF;
EXEC Insere_Historico '90226815056',	'Pacu12',		0xABCDEF;
EXEC Insere_Historico '27788684023',	'Bolo12',		0xABCDEF;
EXEC Insere_Historico '51971708089',	'Temaki',		0xABCDEF;
EXEC Insere_Historico '54537158042',	'Bis123',		0xABCDEF;
EXEC Insere_Historico '56858037020',	'Costela',		0xABCDEF;
EXEC Insere_Historico '53595358066',	'Risole',		0xABCDEF;
EXEC Insere_Historico '35295496066',	'Abacate',		0xABCDEF;
EXEC Insere_Historico '85194921004',	'Shawarma',		0xABCDEF;
EXEC Insere_Historico '96481104092',	'OvoCozido',	0xABCDEF;
EXEC Insere_Historico '00175474079',	'Chocolate',	0xABCDEF;
EXEC Insere_Historico '21341531058',	'Lamen1',		0xABCDEF;
EXEC Insere_Historico '81112054065',	'Blueberry',	0xABCDEF;
EXEC Insere_Historico '46261355010',	'Cupim1',		0xABCDEF;
EXEC Insere_Historico '59784195070',	'Cogumelo',		0xABCDEF;
EXEC Insere_Historico '53274699055',	'Chia12',		0xABCDEF;
EXEC Insere_Historico '42891855094',	'Morango',		0xABCDEF;
EXEC Insere_Historico '73930978008',	'SopaDePedra',	0xABCDEF;
EXEC Insere_Historico '05892157016',	'Banoffe',		0xABCDEF;
EXEC Insere_Historico '26572689000',	'Miojo',		0xABCDEF;
EXEC Insere_Historico '34731605040',	'Manzana',		0xABCDEF;
EXEC Insere_Historico '63806193053',	'Cookie',		0xABCDEF;
EXEC Insere_Historico '87370831043',	'Salgadinho',	0xABCDEF;
EXEC Insere_Historico '59442913034',	'Picanha',		0xABCDEF;
EXEC Insere_Historico '13977711008',	'Maminha',		0xABCDEF;
EXEC Insere_Historico '89961711076',	'Chorizo',		0xABCDEF;
EXEC Insere_Historico '01400902070',	'Sashimi',		0xABCDEF;
EXEC Insere_Historico '96939809058',	'Shakra',		0xABCDEF;
EXEC Insere_Historico '08343472020',	'Carbonara',	0xABCDEF;
EXEC Insere_Historico '21524961086',	'Roux12',		0xABCDEF;
EXEC Registra_Receita 10, 2, 'senha123', '01-05-2026', '05819922026', 'Antibiótico Amoxicilina', 'Tomar 3x ao dia por 7 dias', 21;
EXEC Registra_Receita 11, 2, 'senha123?', '05-05-2026', '33342562005', 'Anti-inflamatório', 'Tomar 2x ao dia após refeições', 14;
EXEC Registra_Receita 12, 2, 'senha123?', '10-05-2026', '82945026007', 'Antialérgico Allegra', 'Tomar 1x ao dia', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '15-05-2026', '38476344023', 'Vitamina C 1g', 'Tomar 1x ao dia pela manhã', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '20-05-2026', '30964927004', 'Xarope para tosse', 'Tomar 10ml 3x ao dia', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '25-05-2026', '79021021056', 'Colírio lubrificante', 'Pingar 1 gota 4x ao dia', 2;
EXEC Desativa_Funcionario '1', 'senha', 2;
EXEC Reativa_Funcionario '1', 'senha', 2; 
EXEC Desativa_Paciente '01421826054', 'Kimchi';
EXEC Reativa_Paciente '01421826054', 'fengqin5714@uorak.com';
EXEC Envia_Mensagem_P 16, '22942383038', 'Estou com febre há 2 dias, 38.5°C';
EXEC Envia_Mensagem_F '22942383038', 16, 'Tome um antitérmico e venha para avaliação hoje.';
EXEC Envia_Mensagem_P 16, '22942383038', 'Tomei paracetamol mas não baixou muito.';
EXEC Envia_Mensagem_F '22942383038', 16, 'Venha imediatamente. Pode ser infecção.';
EXEC Envia_Mensagem_P 17, '43817833016', 'Meu filho está com tosse seca há uma semana.';
EXEC Envia_Mensagem_F '43817833016', 17, 'Preciso examinar. Traga ele hoje à tarde.';
EXEC Envia_Mensagem_P 17, '43817833016', 'Conseguimos ir às 15h?';
EXEC Envia_Mensagem_F '43817833016', 17, 'Sim, estarei esperando vocês às 15h.';
EXEC Envia_Mensagem_P 18, '59784195070', 'Preciso de atestado médico para o trabalho.';
EXEC Envia_Mensagem_F '59784195070', 18, 'Venha para consulta. Atestado só presencialmente.';
EXEC Envia_Mensagem_P 19, '54273844052', 'Estou grávida de 3 meses, posso continuar tomando omeprazol?';
EXEC Envia_Mensagem_F '54273844052', 19, 'Precisamos avaliar. Marque consulta pré-natal urgente.';
EXEC Envia_Mensagem_P 19, '54273844052', 'Ok, vou marcar para amanhã de manhã.';
EXEC Envia_Mensagem_P 10, '51971708089', 'Minha mãe está com pressão 180x100, o que fazer?';
EXEC Envia_Mensagem_F '51971708089', 10, 'URGENTE! Leve ela ao pronto socorro AGORA!';
EXEC Envia_Mensagem_P 10, '51971708089', 'Estamos indo para o hospital agora!';
EXEC Insere_Historico '03674704030', 'Catapimbas12', 0x123456;
EXEC Insere_Historico '05642844083', 'Bananas', 0x789ABC;
EXEC Insere_Historico '58061315050', 'Platano', 0xDEF012;
EXEC Insere_Historico '87949685000', 'Pineapple', 0x345678;
EXEC Insere_Historico '75974478096', 'Abacaxi', 0x9ABCDE;
EXEC Insere_Historico '12345678901', 'Senha@123', 0xFEDCBA;
EXEC Insere_Historico '98765432109', 'Mudar#2024', 0xABCDEF;
EXEC Insere_Historico '45678912304', 'Teste$456', 0xFEDCBA;
EXEC Insere_Historico '78912345607', 'Nova&789', 0xABCDEF;
EXEC Insere_Historico '32165498708', 'Pass!234', 0xFEDCBA;
EXEC Insere_Historico '65432198709', 'Chave@567', 0xABCDEF;
EXEC Insere_Historico '98732165410', 'Acesso#890', 0xFEDCBA;
EXEC Insere_Historico '14725836901', 'Portal$123', 0xABCDEF;
EXEC Insere_Historico '36925814702', 'Sistema&456', 0xFEDCBA;
EXEC Insere_Historico '25836914703', 'Entrada!789', 0xABCDEF;
EXEC Envia_Mensagem_P 1, '12345678901', 'Doutor, estou com dor de cabeça há 3 dias, o que devo fazer?';
EXEC Envia_Mensagem_F '12345678901', 1, 'Tome dipirona 500mg. Se persistir, marque consulta presencial.';
EXEC Envia_Mensagem_P 1, '12345678901', 'Obrigado doutor, vou seguir a orientação.';
EXEC Envia_Mensagem_P 2, '98765432109', 'Dra, minha glicemia está 180 em jejum, está muito alta?';
EXEC Envia_Mensagem_F '98765432109', 2, 'Sim, está alta. Vamos ajustar sua insulina. Venha amanhã.';
EXEC Envia_Mensagem_P 2, '98765432109', 'Ok, estarei aí às 14h, pode ser?';
EXEC Envia_Mensagem_F '98765432109', 2, 'Perfeito! Te aguardo amanhã às 14h.';
EXEC Envia_Mensagem_P 3, '45678912304', 'Bom dia, preciso renovar minha receita de levotiroxina.';
EXEC Envia_Mensagem_F '45678912304', 3, 'Vou preparar a receita. Pode buscar após as 15h.';
EXEC Envia_Mensagem_P 3, '45678912304', 'Muito obrigado! Buscarei no final da tarde.';
EXEC Envia_Mensagem_P 4, '78912345607', 'Dra, a sertralina está me dando muito sono, é normal?';
EXEC Envia_Mensagem_F '78912345607', 4, 'É comum no início. Tente tomar à noite por enquanto.';
EXEC Envia_Mensagem_P 4, '78912345607', 'Vou tentar essa mudança, obrigada pela dica!';
EXEC Envia_Mensagem_P 5, '32165498708', 'Esqueci de tomar o remédio ontem, tomo duas doses hoje?';
EXEC Envia_Mensagem_F '32165498708', 5, 'Não! Tome apenas a dose normal de hoje. Nunca dobre.';
EXEC Envia_Mensagem_P 5, '32165498708', 'Entendi, vou tomar só a de hoje então. Obrigado!';
EXEC Envia_Mensagem_P 6, '65432198709', 'O tramadol não está fazendo efeito para minha dor nas costas.';
EXEC Envia_Mensagem_F '65432198709', 6, 'Vamos avaliar presencialmente. Agende para esta semana.';
EXEC Envia_Mensagem_P 6, '65432198709', 'Consigo ir quinta-feira de manhã.';
EXEC Envia_Mensagem_F '65432198709', 6, 'Quinta às 9h está confirmado. Traga exames recentes.';
EXEC Envia_Mensagem_P 7, '98732165410', 'Doutor, terminei o antibiótico mas ainda tenho sintomas.';
EXEC Envia_Mensagem_F '98732165410', 7, 'Precisamos reavaliar. Venha amanhã para novo exame.';
EXEC Envia_Mensagem_P 8, '14725836901', 'A Ritalina está me deixando sem apetite, é normal?';
EXEC Envia_Mensagem_F '14725836901', 8, 'É um efeito comum. Tente comer antes de tomar o medicamento.';
EXEC Envia_Mensagem_P 9, '36925814702', 'Posso tomar venlafaxina com café?';
EXEC Envia_Mensagem_F '36925814702', 9, 'Pode sim, mas evite excesso de cafeína durante o dia.';
EXEC Envia_Mensagem_P 10, '25836914703', 'A gabapentina pode ser tomada com álcool?';
EXEC Envia_Mensagem_F '25836914703', 10, 'Não! Álcool potencializa efeitos colaterais. Evite completamente.';
EXEC Registra_Receita 13, 2, 'senha123?', '05-03-2026', '03674704030', 'Vitamina D 50.000UI', 'Tomar 1 cápsula por semana', 12;
EXEC Registra_Receita 14, 2, 'senha123?', '10-03-2026', '05642844083', 'Complexo B', 'Tomar 1 comp ao dia após café', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '15-03-2026', '58061315050', 'Ferro (Sulfato ferroso)', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 16, 2, 'senha123?', '20-03-2026', '87949685000', 'Cálcio 500mg + Vit D', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 10, 2, 'senha123', '25-03-2026', '75974478096', 'Magnésio 260mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '30-03-2026', '34731605040', 'Zinco 50mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '05-04-2026', '51890585068', 'Ômega 3 1000mg', 'Tomar 2 cápsulas ao dia', 60;
EXEC Registra_Receita 13, 2, 'senha123?', '10-04-2026', '81112054065', 'Probiótico', 'Tomar 1 sachê ao dia', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '15-04-2026', '53274699055', 'Colágeno hidrolisado', 'Tomar 10g diluído em água 1x ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '20-04-2026', '07628546005', 'Melatonina 3mg', 'Tomar 1 comp 30min antes de dormir', 60;
EXEC Registra_Receita 10, 2, 'senha123', '15-01-2026', '12345678901', 'Rivotril 2mg', 'Tomar 1 comprimido antes de dormir', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '20-01-2026', '98765432109', 'Insulina Lantus', 'Aplicar 20 UI pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '25-01-2026', '45678912304', 'Levotiroxina 100mcg', 'Tomar em jejum 30min antes do café', 90;
EXEC Registra_Receita 13, 2, 'senha123?', '30-01-2026', '78912345607', 'Sertralina 50mg', 'Tomar 1 comprimido pela manhã', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '05-02-2026', '32165498708', 'Pregabalina 75mg', 'Tomar 1 cápsula 2x ao dia', 60;
EXEC Registra_Receita 15, 2, 'senha123?', '10-02-2026', '65432198709', 'Tramadol 50mg', 'Tomar 1 comprimido de 8/8h se dor', 20;
EXEC Registra_Receita 16, 2, 'senha123?', '15-02-2026', '98732165410', 'Ciprofloxacino 500mg', 'Tomar 1 comp 12/12h por 7 dias', 14;
EXEC Registra_Receita 10, 2, 'senha123', '20-02-2026', '14725836901', 'Ritalina 10mg', 'Tomar 1 comp pela manhã e após almoço', 60;
EXEC Registra_Receita 11, 2, 'senha123?', '25-02-2026', '36925814702', 'Venlafaxina 75mg', 'Tomar 1 cápsula pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '01-03-2026', '25836914703', 'Gabapentina 300mg', 'Tomar 1 cápsula 3x ao dia', 90;
EXEC Altera_Receita 1, 'senha123?', '54856098802', 1;
EXEC Altera_Receita 1, 'senha123?', '54856098802', 1;
EXEC Altera_Receita 2, 'senha123?', '21524961086', 2;
EXEC Altera_Receita 3, 'senha123?', '05642844083', 3;
EXEC Altera_Receita 4, 'senha123?', '58061315050', 4;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 5;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 1, 'senha123?', '51890585068', 8;
EXEC Altera_Receita 2, 'senha123?', '81112054065', 9;
EXEC Altera_Receita 3, 'senha123?', '53274699055', 10;
EXEC Registra_Receita 10, 2, 'senha123', '15-06-2026', '69068097091', 'Enalapril 10mg', 'Tomar 1 comprimido pela manhã em jejum', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '18-06-2026', '21955621020', 'Metoprolol 50mg', 'Tomar 1 comprimido 2x ao dia', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '22-06-2026', '08924899015', 'Sinvastatina 40mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '25-06-2026', '39862328002', 'Levotiroxina 75mcg', 'Tomar 1 comprimido em jejum', 90;
EXEC Registra_Receita 14, 2, 'senha123?', '28-06-2026', '05892157016', 'Pantoprazol 40mg', 'Tomar 1 comprimido 30min antes café', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '02-07-2026', '22942383038', 'Amitriptilina 25mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '05-07-2026', '43817833016', 'Prednisona 5mg', 'Tomar 2 comp manhã por 5 dias', 10;
EXEC Registra_Receita 10, 2, 'senha123', '08-07-2026', '59784195070', 'Bromazepam 3mg', 'Tomar 1/2 comp à noite se necessário', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '12-07-2026', '54273844052', 'Ácido Fólico 5mg', 'Tomar 1 comprimido ao dia', 90;
EXEC Registra_Receita 12, 2, 'senha123?', '15-07-2026', '51971708089', 'Dexametasona creme', 'Aplicar nas lesões 2x ao dia', 1;
EXEC Registra_Receita 13, 2, 'senha123?', '18-07-2026', '58614220014', 'Clopidogrel 75mg', 'Tomar 1 comprimido ao dia', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '22-07-2026', '21341531058', 'Espironolactona 25mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '25-07-2026', '91948947013', 'Furosemida 40mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '28-07-2026', '40310919070', 'Carvedilol 6,25mg', 'Tomar 1 comprimido 2x ao dia', 60;
EXEC Registra_Receita 10, 2, 'senha123', '01-08-2026', '74315582018', 'Varfarina 5mg', 'Tomar conforme orientação - controlar INR', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '05-08-2026', '90934957045', 'Alopurinol 300mg', 'Tomar 1 comprimido ao dia', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '08-08-2026', '43014639095', 'Topiramato 25mg', 'Tomar 1 comprimido 2x ao dia', 60;
EXEC Registra_Receita 13, 2, 'senha123?', '12-08-2026', '33077793032', 'Lamotrigina 100mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '15-08-2026', '62062052073', 'Quetiapina 25mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '18-08-2026', '10358560004', 'Donepezila 10mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '22-08-2026', '47298600044', 'Memantina 10mg', 'Tomar 1 comprimido 2x ao dia', 60;
EXEC Registra_Receita 10, 2, 'senha123', '25-08-2026', '09577340008', 'Bupropiona 150mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '28-08-2026', '18065460003', 'Escitalopram 10mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '01-09-2026', '15150863050', 'Duloxetina 60mg', 'Tomar 1 cápsula pela manhã', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '05-09-2026', '12614706051', 'Mirtazapina 30mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '08-09-2026', '60030094038', 'Paroxetina 20mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '12-09-2026', '74689923043', 'Vortioxetina 10mg', 'Tomar 1 comprimido ao dia', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '15-09-2026', '40526767006', 'Desvenlafaxina 50mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 10, 2, 'senha123', '18-09-2026', '13164571097', 'Lisdexanfetamina 30mg', 'Tomar 1 cápsula pela manhã', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '22-09-2026', '86565804001', 'Atomoxetina 40mg', 'Tomar 1 cápsula pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '25-09-2026', '85194921004', 'Modafinila 200mg', 'Tomar 1 comprimido pela manhã', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '28-09-2026', '08343472020', 'Aripiprazol 10mg', 'Tomar 1 comprimido ao dia', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '02-10-2026', '75064872097', 'Risperidona 2mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '05-10-2026', '01421826054', 'Olanzapina 5mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '08-10-2026', '05819922026', 'Ziprasidona 40mg', 'Tomar 1 cápsula 2x ao dia', 60;
EXEC Registra_Receita 10, 2, 'senha123', '12-10-2026', '33342562005', 'Haloperidol 5mg', 'Tomar 1 comprimido à noite', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '15-10-2026', '82945026007', 'Lítio 300mg', 'Tomar 2 comp à noite - controlar litemia', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '18-10-2026', '38476344023', 'Ácido Valproico 500mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 13, 2, 'senha123?', '22-10-2026', '30964927004', 'Carbamazepina 200mg', 'Tomar 1 comp 3x ao dia', 90;
EXEC Registra_Receita 14, 2, 'senha123?', '25-10-2026', '79021021056', 'Fenitoína 100mg', 'Tomar 1 comp 3x ao dia', 90;
EXEC Registra_Receita 15, 2, 'senha123?', '28-10-2026', '93379047058', 'Levetiracetam 500mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 16, 2, 'senha123?', '01-11-2026', '55124371005', 'Levofloxacino 500mg', 'Tomar 1 comp ao dia por 7 dias', 7;
EXEC Registra_Receita 10, 2, 'senha123', '05-11-2026', '78762128086', 'Claritromicina 500mg', 'Tomar 1 comp 12/12h por 10 dias', 20;
EXEC Registra_Receita 11, 2, 'senha123?', '08-11-2026', '42256849031', 'Doxiciclina 100mg', 'Tomar 1 comp 2x ao dia por 14 dias', 28;
EXEC Registra_Receita 12, 2, 'senha123?', '12-11-2026', '01400902070', 'Metronidazol 400mg', 'Tomar 1 comp 3x ao dia por 7 dias', 21;
EXEC Registra_Receita 13, 2, 'senha123?', '15-11-2026', '49591700008', 'Fluconazol 150mg', 'Tomar 1 cápsula dose única', 1;
EXEC Registra_Receita 14, 2, 'senha123?', '18-11-2026', '53497527076', 'Albendazol 400mg', 'Tomar 1 comp dose única', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '22-11-2026', '17717478030', 'Ivermectina 6mg', 'Tomar 4 comp dose única', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '25-11-2026', '96481104092', 'Nitrofurantoína 100mg', 'Tomar 1 cáps 6/6h por 7 dias', 28;
EXEC Registra_Receita 10, 2, 'senha123', '28-11-2026', '17686975070', 'Sulfametoxazol+Trimetoprima', 'Tomar 1 comp 12/12h por 10 dias', 20;
EXEC Registra_Receita 11, 2, 'senha123?', '02-12-2026', '37666471050', 'Norfloxacino 400mg', 'Tomar 1 comp 12/12h por 7 dias', 14;
EXEC Registra_Receita 12, 2, 'senha123?', '05-12-2026', '58700766097', 'Gliclazida 60mg', 'Tomar 1 comp antes café manhã', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '08-12-2026', '47077123049', 'Glimepirida 2mg', 'Tomar 1 comp antes café manhã', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '12-12-2026', '96939809058', 'Pioglitazona 30mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '15-12-2026', '24547397040', 'Empagliflozina 10mg', 'Tomar 1 comp pela manhã', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '18-12-2026', '97702083026', 'Sitagliptina 100mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 10, 2, 'senha123', '22-12-2026', '05483202090', 'Liraglutida 1,2mg', 'Aplicar 1 dose SC ao dia', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '25-12-2026', '73930978008', 'Insulina NPH', 'Aplicar 20UI manhã e 15UI noite', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '28-12-2026', '54537158042', 'Insulina Regular', 'Aplicar conforme glicemia capilar', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '02-01-2027', '00175474079', 'Rosuvastatina 10mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '05-01-2027', '26572689000', 'Atorvastatina 40mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '08-01-2027', '67593704068', 'Ezetimiba 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '12-01-2027', '39867593014', 'Fenofibrato 160mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 10, 2, 'senha123', '15-01-2027', '42891855094', 'Anlodipino 5mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '18-01-2027', '35295496066', 'Valsartana 160mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '22-01-2027', '65331943055', 'Olmesartana 40mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '25-01-2027', '89961711076', 'Telmisartana 80mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '28-01-2027', '31895518040', 'Irbesartana 300mg', 'Tomar 1 comp ao dia', 30;
EXEC Envia_Mensagem_P 20, '69068097091', 'Doutor, minha pressão hoje está 150x95, continuo tomando o remédio?';
EXEC Envia_Mensagem_P 21, '21955621020', 'Estou sentindo tontura depois que comecei o Metoprolol';
EXEC Envia_Mensagem_P 22, '08924899015', 'A Sinvastatina pode ser tomada junto com suco de laranja?';
EXEC Envia_Mensagem_P 23, '39862328002', 'Esqueci de tomar o Levotiroxina em jejum, tomei depois do café';
EXEC Envia_Mensagem_P 24, '05892157016', 'O Pantoprazol está ajudando muito, azia sumiu!';
EXEC Envia_Mensagem_P 25, '22942383038', 'Dra, a Amitriptilina está me deixando muito sonolenta durante o dia';
EXEC Envia_Mensagem_P 26, '43817833016', 'Terminei a Prednisona, mas ainda sinto um pouco de falta de ar';
EXEC Envia_Mensagem_P 27, '59784195070', 'Posso tomar o Bromazepam todo dia ou só quando tiver ansiedade?';
EXEC Envia_Mensagem_P 28, '54273844052', 'O Ácido Fólico pode causar enjoo? Estou me sentindo mal';
EXEC Envia_Mensagem_P 29, '51971708089', 'A pomada está funcionando, as manchas estão melhorando';
EXEC Envia_Mensagem_P 30, '58614220014', 'Esqueci de tomar o Clopidogrel ontem, o que faço?';
EXEC Envia_Mensagem_P 31, '21341531058', 'Estou urinando muito depois da Espironolactona, é normal?';
EXEC Envia_Mensagem_P 32, '91948947013', 'A Furosemida me faz ir ao banheiro de hora em hora';
EXEC Envia_Mensagem_P 33, '40310919070', 'Carvedilol pode causar cansaço? Estou exausto';
EXEC Envia_Mensagem_P 34, '74315582018', 'Fiz exame INR deu 2,8. Preciso ajustar a Varfarina?';
EXEC Envia_Mensagem_P 35, '90934957045', 'O Alopurinol baixou meu ácido úrico, mas tive uma crise';
EXEC Envia_Mensagem_P 36, '43014639095', 'Topiramato está me dando formigamento nos dedos';
EXEC Envia_Mensagem_P 37, '33077793032', 'Preciso fazer exame de sangue com a Lamotrigina?';
EXEC Envia_Mensagem_P 38, '62062052073', 'Quetiapina me deixa dormindo até tarde, posso tomar mais cedo?';
EXEC Envia_Mensagem_P 39, '10358560004', 'Meu pai esquece de tomar a Donepezila, o que fazer?';
EXEC Envia_Mensagem_P 20, '47298600044', 'A Memantina está ajudando na memória da minha mãe';
EXEC Envia_Mensagem_P 21, '09577340008', 'Bupropiona me deixa agitado, é efeito colateral?';
EXEC Envia_Mensagem_P 22, '18065460003', 'Quanto tempo demora para o Escitalopram fazer efeito?';
EXEC Envia_Mensagem_P 23, '15150863050', 'Duloxetina ajuda com dor nas costas também?';
EXEC Envia_Mensagem_P 24, '12614706051', 'Mirtazapina me deu muita fome, ganhei 3kg';
EXEC Envia_Mensagem_P 25, '60030094038', 'Paroxetina pode ser tomada à noite em vez de manhã?';
EXEC Envia_Mensagem_P 26, '74689923043', 'Vortioxetina é melhor que Fluoxetina para ansiedade?';
EXEC Envia_Mensagem_P 27, '40526767006', 'Desvenlafaxina me deixa com boca seca, é normal?';
EXEC Envia_Mensagem_P 28, '13164571097', 'Lisdexanfetamina tirou minha fome completamente';
EXEC Envia_Mensagem_P 29, '86565804001', 'Atomoxetina demora quanto tempo para fazer efeito no TDAH?';
EXEC Envia_Mensagem_P 30, '85194921004', 'Modafinila pode ser usada para estudar para provas?';
EXEC Envia_Mensagem_P 31, '08343472020', 'Aripiprazol está controlando bem meus sintomas';
EXEC Envia_Mensagem_P 32, '75064872097', 'Risperidona me deu muito sono, posso reduzir?';
EXEC Envia_Mensagem_P 33, '01421826054', 'Olanzapina fez eu ganhar 5kg em 1 mês';
EXEC Envia_Mensagem_P 34, '05819922026', 'Ziprasidona precisa ser tomada com comida?';
EXEC Envia_Mensagem_P 35, '33342562005', 'Haloperidol me deixa travado, músculos rígidos';
EXEC Envia_Mensagem_P 36, '82945026007', 'Fiz exame de lítio, deu 0,9. Está bom?';
EXEC Envia_Mensagem_P 37, '38476344023', 'Ácido Valproico causa queda de cabelo?';
EXEC Envia_Mensagem_P 38, '30964927004', 'Carbamazepina interage com anticoncepcional?';
EXEC Envia_Mensagem_P 39, '79021021056', 'Fenitoína deixa a gengiva inchada, é normal?';
EXEC Envia_Mensagem_P 20, '93379047058', 'Levetiracetam me deixa irritado às vezes';
EXEC Envia_Mensagem_P 21, '55124371005', 'Levofloxacino pode tomar com leite?';
EXEC Envia_Mensagem_P 22, '78762128086', 'Claritromicina está me dando gosto amargo na boca';
EXEC Envia_Mensagem_P 23, '42256849031', 'Doxiciclina queima o estômago, posso tomar com comida?';
EXEC Envia_Mensagem_P 24, '01400902070', 'Metronidazol deixa urina escura, é normal?';
EXEC Envia_Mensagem_P 25, '49591700008', 'Tomei Fluconazol mas ainda tenho sintomas';
EXEC Envia_Mensagem_P 26, '53497527076', 'Albendazol causa diarreia? Estou indo muito ao banheiro';
EXEC Envia_Mensagem_P 27, '17717478030', 'Ivermectina mata piolho também?';
EXEC Envia_Mensagem_P 28, '96481104092', 'Nitrofurantoína deixa urina laranja, está certo?';
EXEC Envia_Mensagem_P 29, '17686975070', 'Bactrim está me dando alergia na pele';
EXEC Envia_Mensagem_P 30, '37666471050', 'Norfloxacino pode ser tomado com café?';
EXEC Envia_Mensagem_P 31, '58700766097', 'Gliclazida baixou muito minha glicose, 65';
EXEC Envia_Mensagem_P 32, '47077123049', 'Glimepirida me faz suar muito, é efeito colateral?';
EXEC Envia_Mensagem_P 33, '96939809058', 'Pioglitazona está fazendo eu reter líquido';
EXEC Envia_Mensagem_P 34, '24547397040', 'Empagliflozina fez eu perder 2kg, ótimo!';
EXEC Envia_Mensagem_P 35, '97702083026', 'Sitagliptina pode ser tomada a qualquer hora?';
EXEC Envia_Mensagem_P 36, '05483202090', 'Liraglutida arde quando aplico, estou fazendo errado?';
EXEC Envia_Mensagem_P 37, '73930978008', 'Insulina NPH está controlando bem glicemia';
EXEC Envia_Mensagem_P 38, '54537158042', 'Insulina Regular, aplico antes ou depois de comer?';
EXEC Envia_Mensagem_P 39, '00175474079', 'Rosuvastatina me deu dor muscular nas pernas';
EXEC Envia_Mensagem_P 20, '26572689000', 'Atorvastatina pode tomar de manhã em vez de noite?';
EXEC Envia_Mensagem_F '69068097091', 20, 'Continue o medicamento normalmente. Monitore diariamente e me informe se passar de 160x100.';
EXEC Envia_Mensagem_F '21955621020', 21, 'Tontura é comum no início. Se persistir após 1 semana, marque retorno para ajustar dose.';
EXEC Envia_Mensagem_F '08924899015', 22, 'Pode sim! Mas evite tomar com suco de toranja (grapefruit).';
EXEC Envia_Mensagem_F '39862328002', 23, 'Não tem problema dessa vez, mas sempre tente em jejum para melhor absorção.';
EXEC Envia_Mensagem_F '05892157016', 24, 'Excelente! Continue o tratamento. Retorno em 3 meses.';
EXEC Envia_Mensagem_F '22942383038', 25, 'Vamos reduzir para 12,5mg. Tome à noite 1h antes de dormir.';
EXEC Envia_Mensagem_F '43817833016', 26, 'Marque retorno esta semana. Pode precisar estender tratamento.';
EXEC Envia_Mensagem_F '59784195070', 27, 'Use SOS, apenas nos momentos de crise. Máximo 3x por semana.';
EXEC Envia_Mensagem_F '54273844052', 28, 'Enjoo é raro. Tome após refeições. Se piorar, me avise.';
EXEC Envia_Mensagem_F '51971708089', 29, 'Ótimo! Continue por mais 7 dias e retorne para avaliar.';
EXEC Envia_Mensagem_F '58614220014', 30, 'Tome a dose de hoje normalmente. Nunca dobre a dose.';
EXEC Envia_Mensagem_F '21341531058', 31, 'Sim, é diurético. Tome pela manhã para não acordar à noite.';
EXEC Envia_Mensagem_F '91948947013', 32, 'Normal. Evite tomar após 16h para não atrapalhar sono.';
EXEC Envia_Mensagem_F '40310919070', 33, 'Sim, pode. Geralmente melhora em 2 semanas. Aguarde.';
EXEC Envia_Mensagem_F '74315582018', 34, 'INR está bom (alvo 2-3). Mantenha mesma dose de Varfarina.';
EXEC Envia_Mensagem_F '90934957045', 35, 'Crise no início é comum. Continue medicação, vai melhorar.';
EXEC Envia_Mensagem_F '43014639095', 36, 'Parestesia é efeito comum. Se incomodar muito, posso trocar medicação.';
EXEC Envia_Mensagem_F '33077793032', 37, 'Sim, hemograma de 6/6 meses. Agende laboratório.';
EXEC Envia_Mensagem_F '62062052073', 38, 'Pode tomar às 21h. Evite dirigir pela manhã se ficar sonolento.';
EXEC Envia_Mensagem_F '10358560004', 39, 'Use alarme no celular dele. Caixa organizadora de medicação ajuda.';
EXEC Envia_Mensagem_F '47298600044', 20, 'Que bom! Continue tratamento. Avaliação neurológica em 6 meses.';
EXEC Envia_Mensagem_F '09577340008', 21, 'Normal nas primeiras semanas. Se não melhorar em 15 dias, ajustamos.';
EXEC Envia_Mensagem_F '18065460003', 22, 'Efeito completo em 4-6 semanas. Não desista, continue tomando.';
EXEC Envia_Mensagem_F '15150863050', 23, 'Sim! Duloxetina tem ação analgésica para dor neuropática e fibromialgia.';
EXEC Envia_Mensagem_F '12614706051', 24, 'Aumento de apetite é comum. Controle alimentação e pratique exercícios.';
EXEC Envia_Mensagem_F '60030094038', 25, 'Pode sim, mas prefira manhã pois pode dar insônia em alguns pacientes.';
EXEC Envia_Mensagem_F '74689923043', 26, 'Depende do caso. Vortioxetina tem menos efeitos colaterais geralmente.';
EXEC Envia_Mensagem_F '40526767006', 27, 'Sim, é normal. Beba bastante água e use balas sem açúcar.';
EXEC Envia_Mensagem_F '13164571097', 28, 'Efeito esperado. Faça refeições em horários fixos mesmo sem fome.';
EXEC Envia_Mensagem_F '86565804001', 29, 'Demora 4-8 semanas para efeito pleno. Mais lento que Ritalina.';
EXEC Envia_Mensagem_F '85194921004', 30, 'Não! É para narcolepsia. Uso recreativo é perigoso e ilegal.';
EXEC Envia_Mensagem_F '08343472020', 31, 'Excelente! Mantenha consultas regulares para acompanhamento.';
EXEC Envia_Mensagem_F '75064872097', 32, 'Não reduza sozinho. Venha para consulta, ajustarei dose.';
EXEC Envia_Mensagem_F '01421826054', 33, 'Ganho de peso é comum. Dieta e exercício são essenciais.';
EXEC Envia_Mensagem_F '05819922026', 34, 'Sim! Tome sempre com alimento para melhor absorção.';
EXEC Envia_Mensagem_F '33342562005', 35, 'Efeito extrapiramidal. URGENTE: venha hoje para prescrever correção.';
EXEC Envia_Mensagem_F '82945026007', 36, 'Perfeito! Nível terapêutico ideal (0,6-1,2). Continue mesma dose.';
EXEC Envia_Mensagem_F '38476344023', 37, 'Pode causar. Suplemento de biotina ajuda. Avalie em consulta.';
EXEC Envia_Mensagem_F '30964927004', 38, 'SIM! Reduz eficácia do anticoncepcional. Use método adicional.';
EXEC Envia_Mensagem_F '79021021056', 39, 'Hiperplasia gengival é comum. Higiene bucal rigorosa é essencial.';
EXEC Envia_Mensagem_F '93379047058', 20, 'Irritabilidade pode ocorrer. Se piorar, marque consulta para avaliar.';
EXEC Envia_Mensagem_F '55124371005', 21, 'Não! Leite prejudica absorção. Tome 1h antes ou 2h depois.';
EXEC Envia_Mensagem_F '78762128086', 22, 'Gosto metálico é normal. Passa após terminar antibiótico.';
EXEC Envia_Mensagem_F '42256849031', 23, 'Sim, SEMPRE com alimento e bastante água. Nunca deitado após tomar.';
EXEC Envia_Mensagem_F '01400902070', 24, 'Sim, normal. Evite álcool completamente durante tratamento.';
EXEC Envia_Mensagem_F '49591700008', 25, 'Sintomas persistem? Marque consulta, pode precisar dose repetida.';
EXEC Envia_Mensagem_F '53497527076', 26, 'Pode causar. Tome com alimento. Se piorar, me avise.';
EXEC Envia_Mensagem_F '17717478030', 27, 'Sim, mas dose é diferente. Consulte antes de usar para isso.';
EXEC Envia_Mensagem_F '96481104092', 28, 'Sim! Cor alaranjada/marrom é normal. Não se preocupe.';
EXEC Envia_Mensagem_F '17686975070', 29, 'PARE medicação AGORA! Venha urgente, pode ser alergia grave.';
EXEC Envia_Mensagem_F '37666471050', 30, 'Evite. Café pode reduzir absorção. Prefira água.';
EXEC Envia_Mensagem_F '58700766097', 31, 'Hipoglicemia! Coma algo doce agora. Vamos ajustar dose.';
EXEC Envia_Mensagem_F '47077123049', 32, 'Sim, hipoglicemia causa suor. Monitore glicemia e registre valores.';
EXEC Envia_Mensagem_F '96939809058', 33, 'Retenção hídrica é comum. Monitore peso. Se +2kg, marque consulta.';
EXEC Envia_Mensagem_F '24547397040', 34, 'Perda de peso é efeito esperado! Continue monitorando glicemia.';
EXEC Envia_Mensagem_F '97702083026', 35, 'Prefira com refeição principal. Pode ser almoço ou jantar.';
EXEC Envia_Mensagem_F '05483202090', 36, 'Arde no início. Rode local de aplicação. Deixar temperatura ambiente ajuda.';
EXEC Envia_Mensagem_F '73930978008', 37, 'Ótimo! Continue. Retorno trimestral para ajustar doses.';
EXEC Envia_Mensagem_F '54537158042', 38, 'Aplicar 15min ANTES da refeição. Nunca depois.';
EXEC Envia_Mensagem_F '00175474079', 39, 'Mialgia é comum. Se intensa, marque consulta para trocar estatina.';
EXEC Envia_Mensagem_F '26572689000', 20, 'Prefira noite, mas pode manhã se esquecer. Mantenha horário fixo.';
EXEC Envia_Mensagem_P 1, '67593704068', 'Doutora, esqueci minha receita em casa. Posso comprar sem?';
EXEC Envia_Mensagem_F '67593704068', 1, 'Receita controlada não. Passe aqui pegar segunda via.';
EXEC Envia_Mensagem_P 1, '67593704068', 'Posso buscar amanhã de manhã?';
EXEC Envia_Mensagem_F '67593704068', 1, 'Sim, após 9h está pronta. Traga documento.';
EXEC Envia_Mensagem_P 2, '39867593014', 'Posso tomar cerveja no fim de semana com meu remédio?';
EXEC Envia_Mensagem_F '39867593014', 2, 'Álcool com seu medicamento é PROIBIDO. Pode causar reação grave.';
EXEC Envia_Mensagem_P 2, '39867593014', 'Nem uma cervejinha?';
EXEC Envia_Mensagem_F '39867593014', 2, 'Nenhuma! Risco de intoxicação hepática. Seja responsável.';
EXEC Envia_Mensagem_P 3, '42891855094', 'Meu convênio não cobre esse remédio. Tem genérico?';
EXEC Envia_Mensagem_F '42891855094', 3, 'Sim, vou prescrever genérico. Mesma eficácia, menor custo.';
EXEC Envia_Mensagem_P 3, '42891855094', 'Obrigado! Isso ajuda muito no orçamento.';
EXEC Envia_Mensagem_P 4, '35295496066', 'Estou viajando para exterior. Como faço com medicação?';
EXEC Envia_Mensagem_F '35295496066', 4, 'Vou fazer receita em inglês e relatório médico. Quando viaja?';
EXEC Envia_Mensagem_P 4, '35295496066', 'Semana que vem. Fico 2 meses fora.';
EXEC Envia_Mensagem_F '35295496066', 4, 'Prescrevo quantidade necessária. Passe hoje para pegar documentos.';
EXEC Envia_Mensagem_P 5, '65331943055', 'Posso engravidar tomando esse medicamento?';
EXEC Envia_Mensagem_F '65331943055', 5, 'Não! É teratogênico. Use 2 métodos contraceptivos obrigatoriamente.';
EXEC Envia_Mensagem_P 5, '65331943055', 'E se eu quiser engravidar?';
EXEC Envia_Mensagem_F '65331943055', 5, 'Marque consulta. Trocaremos medicação 3 meses antes de tentar.';
EXEC Envia_Mensagem_P 6, '89961711076', 'Meu filho pegou meu remédio por engano. O que faço?';
EXEC Envia_Mensagem_F '89961711076', 6, 'Quantos comprimidos? Que idade dele? URGENTE!';
EXEC Envia_Mensagem_P 6, '89961711076', 'Acho que 2 comprimidos. Ele tem 5 anos!';
EXEC Envia_Mensagem_F '89961711076', 6, 'VÁ AO PRONTO SOCORRO AGORA! Leve a caixa do remédio!';
EXEC Envia_Mensagem_P 7, '31895518040', 'Mudei de cidade. Como faço para continuar tratamento?';
EXEC Envia_Mensagem_F '31895518040', 7, 'Posso fazer relatório médico completo para novo médico. Quando mudou?';
EXEC Envia_Mensagem_P 7, '31895518040', 'Semana passada. Preciso urgente continuar medicação.';
EXEC Envia_Mensagem_F '31895518040', 7, 'Passo receita para 3 meses. Busque médico local urgente.';
EXEC Envia_Mensagem_P 8, '90653374070', 'Remédio está muito caro, mais de R$ 300. Não aguento mais.';
EXEC Envia_Mensagem_F '90653374070', 8, 'Temos programa de farmácia popular. Vou prescrever equivalente gratuito.';
EXEC Envia_Mensagem_P 8, '90653374070', 'Sério? Isso vai ajudar demais minha família!';
EXEC Envia_Mensagem_F '90653374070', 8, 'Sim! Retire receita especial para farmácia popular amanhã.';
EXEC Envia_Mensagem_P 9, '46261355010', 'Perdi toda minha medicação num assalto. E agora?';
EXEC Envia_Mensagem_F '46261355010', 9, 'Faço segunda via de receitas. Venha hoje com boletim de ocorrência.';
EXEC Envia_Mensagem_P 9, '46261355010', 'Preciso do boletim mesmo?';
EXEC Envia_Mensagem_F '46261355010', 9, 'Para medicação controlada, sim. É procedimento obrigatório.';
EXEC Envia_Mensagem_P 10, '59442913034', 'Meu cachorro comeu meus comprimidos! Ele vai ficar bem?';
EXEC Envia_Mensagem_F '59442913034', 10, 'LEVE AO VETERINÁRIO URGENTE! Leve a caixa do medicamento!';
EXEC Envia_Mensagem_P 10, '59442913034', 'Foram uns 10 comprimidos... estou indo agora!';
EXEC Envia_Mensagem_F '59442913034', 10, 'Corra! Pode ser fatal para animais. Não espere sintomas!';
EXEC Envia_Mensagem_P 11, '13977711008', 'Comecei a ter pesadelos horríveis depois do remédio';
EXEC Envia_Mensagem_F '13977711008', 11, 'Efeito colateral conhecido. Vamos trocar medicação. Marque retorno.';
EXEC Envia_Mensagem_P 12, '87370831043', 'Não consigo mais ter relações íntimas. É o remédio?';
EXEC Envia_Mensagem_F '87370831043', 12, 'Disfunção sexual é efeito comum dessa classe. Posso ajustar.';
EXEC Envia_Mensagem_P 13, '52546518062', 'Estou tendo pensamentos suicidas. Piorou com remédio.';
EXEC Envia_Mensagem_F '52546518062', 13, 'PARE MEDICAÇÃO AGORA! Ligue 188 (CVV). Venha URGENTE hoje!';
EXEC Envia_Mensagem_P 14, '85082610040', 'Fiquei com visão embaçada. Devo parar remédio?';
EXEC Envia_Mensagem_F '85082610040', 14, 'Não pare. Mas marque oftalmologista urgente. Me informe resultado.';
EXEC Envia_Mensagem_P 15, '56858037020', 'Tenho sangramento que não para. Pode ser medicação?';
EXEC Envia_Mensagem_F '56858037020', 15, 'Pode sim! Vá ao pronto socorro AGORA. Leve lista de remédios.';
EXEC Envia_Mensagem_P 16, '90226815056', 'Minha pele ficou amarelada. É grave?';
EXEC Envia_Mensagem_F '90226815056', 16, 'Icterícia! PARE remédio. PS urgente. Pode ser hepatotoxicidade.';
EXEC Envia_Mensagem_P 17, '63806193053', 'Estou com febre alta e manchas roxas no corpo';
EXEC Envia_Mensagem_F '63806193053', 17, 'EMERGÊNCIA! Vá ao hospital AGORA! Pode ser reação grave.';
EXEC Envia_Mensagem_P 18, '27788684023', 'Não sinto mais gosto da comida desde que comecei remédio';
EXEC Envia_Mensagem_F '27788684023', 18, 'Disgeusia é temporária. Geralmente volta em 2-4 semanas.';
EXEC Envia_Mensagem_P 19, '51971708089', 'Posso tomar chá verde com meu remédio?';
EXEC Envia_Mensagem_F '51971708089', 19, 'Chá verde pode interagir. Evite ou tome com 4h de intervalo.';
EXEC Envia_Mensagem_P 20, '54537158042', 'Comecei vitaminas sem receita. Tem problema?';
EXEC Envia_Mensagem_F '54537158042', 20, 'Quais vitaminas? Algumas interagem. Me mande lista completa.';
EXEC Envia_Mensagem_P 21, '00175474079', 'Estou tomando remédio natural. Preciso avisar?';
EXEC Envia_Mensagem_F '00175474079', 21, 'SIM! "Natural" não significa seguro. Pode ter interação grave.';
EXEC Envia_Mensagem_P 22, '26572689000', 'Posso tomar Dipirona junto com meus remédios?';
EXEC Envia_Mensagem_F '26572689000', 22, 'Dipirona é segura com seus medicamentos. Pode tomar.';
EXEC Envia_Mensagem_P 23, '39867593014', 'Dentista prescreveu antibiótico. Tomo junto com meus?';
EXEC Envia_Mensagem_F '39867593014', 23, 'Qual antibiótico? Me envie foto da receita para avaliar interação.';
EXEC Registra_Receita 14, 2, 'senha123?', '12-02-2027', '67593704068', 'Pregabalina 150mg', 'Tomar 1 cápsula 2x ao dia para dor neuropática', 60;
EXEC Registra_Receita 15, 2, 'senha123?', '15-02-2027', '39867593014', 'Ciclobenzaprina 10mg', 'Tomar 1 comp à noite para dor muscular', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '18-02-2027', '42891855094', 'Naproxeno 500mg', 'Tomar 1 comp 12/12h após refeições', 20;
EXEC Registra_Receita 10, 2, 'senha123', '22-02-2027', '35295496066', 'Meloxicam 15mg', 'Tomar 1 comp ao dia após refeição', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '25-02-2027', '65331943055', 'Nimesulida 100mg', 'Tomar 1 comp 12/12h por no máximo 5 dias', 10;
EXEC Registra_Receita 12, 2, 'senha123?', '28-02-2027', '89961711076', 'Etoricoxibe 90mg', 'Tomar 1 comp ao dia se dor', 15;
EXEC Registra_Receita 13, 2, 'senha123?', '03-03-2027', '31895518040', 'Colchicina 0,5mg', 'Tomar 1 comp 2x ao dia durante crise gota', 20;
EXEC Registra_Receita 14, 2, 'senha123?', '06-03-2027', '90653374070', 'Alopurinol 100mg', 'Tomar 1 comp 3x ao dia', 90;
EXEC Registra_Receita 15, 2, 'senha123?', '10-03-2027', '46261355010', 'Hidroxicloroquina 400mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '13-03-2027', '59442913034', 'Metotrexato 2,5mg', 'Tomar 6 comp 1x por semana (segunda)', 24;
EXEC Registra_Receita 10, 2, 'senha123', '17-03-2027', '13977711008', 'Azatioprina 50mg', 'Tomar 2 comp ao dia', 60;
EXEC Registra_Receita 11, 2, 'senha123?', '20-03-2027', '87370831043', 'Ciclosporina 100mg', 'Tomar 1 cáps 2x ao dia', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '24-03-2027', '52546518062', 'Micofenolato 500mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 13, 2, 'senha123?', '27-03-2027', '85082610040', 'Tacrolimus 1mg', 'Tomar 2 cáps 2x ao dia', 120;
EXEC Registra_Receita 14, 2, 'senha123?', '31-03-2027', '56858037020', 'Prednisona 5mg', 'Tomar 4 comp manhã dose de manutenção', 120;
EXEC Registra_Receita 15, 2, 'senha123?', '03-04-2027', '90226815056', 'Deflazacorte 6mg', 'Tomar 2 comp manhã', 60;
EXEC Registra_Receita 16, 2, 'senha123?', '07-04-2027', '63806193053', 'Budesonida 3mg', 'Tomar 3 cáps manhã', 90;
EXEC Registra_Receita 10, 2, 'senha123', '10-04-2027', '27788684023', 'Mesalazina 800mg', 'Tomar 1 comp 3x ao dia', 90;
EXEC Registra_Receita 11, 2, 'senha123?', '14-04-2027', '51971708089', 'Sulfassalazina 500mg', 'Tomar 2 comp 2x ao dia', 120;
EXEC Registra_Receita 12, 2, 'senha123?', '17-04-2027', '54537158042', 'Infliximabe (Remicade)', 'Infusão hospitalar conforme protocolo', 1;
EXEC Registra_Receita 13, 2, 'senha123?', '21-04-2027', '00175474079', 'Formoterol+Budesonida', 'Inalar 2 jatos 12/12h - uso contínuo', 1;
EXEC Registra_Receita 14, 2, 'senha123?', '24-04-2027', '26572689000', 'Salbutamol spray', 'Inalar 2 jatos SOS falta de ar', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '28-04-2027', '39867593014', 'Montelucaste 10mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '01-05-2027', '67593704068', 'Teofilina 300mg', 'Tomar 1 comp 12/12h', 60;
EXEC Registra_Receita 10, 2, 'senha123', '05-05-2027', '42891855094', 'Brometo de Ipratrópio', 'Inalar 2 jatos 4x ao dia', 1;
EXEC Registra_Receita 11, 2, 'senha123?', '08-05-2027', '35295496066', 'Prednisolona 20mg', 'Tomar 2 comp manhã por 7 dias', 14;
EXEC Registra_Receita 12, 2, 'senha123?', '12-05-2027', '65331943055', 'Montelucaste infantil 5mg', 'Dar 1 comp mastigável à noite', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '15-05-2027', '89961711076', 'Desloratadina 5mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '19-05-2027', '31895518040', 'Fexofenadina 180mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '22-05-2027', '90653374070', 'Bilastina 20mg', 'Tomar 1 comp ao dia em jejum', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '26-05-2027', '46261355010', 'Cetirizina 10mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 10, 2, 'senha123', '29-05-2027', '59442913034', 'Levocetirizina 5mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '02-06-2027', '13977711008', 'Ebastina 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '05-06-2027', '87370831043', 'Rupatadina 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '09-06-2027', '52546518062', 'Betametasona creme', 'Aplicar fina camada 2x ao dia', 1;
EXEC Registra_Receita 14, 2, 'senha123?', '12-06-2027', '85082610040', 'Mometasona pomada', 'Aplicar 1x ao dia à noite', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '16-06-2027', '56858037020', 'Tacrolimus pomada 0,1%', 'Aplicar 2x ao dia em lesões', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '19-06-2027', '90226815056', 'Pimecrolimus creme 1%', 'Aplicar 2x ao dia', 1;
EXEC Registra_Receita 10, 2, 'senha123', '23-06-2027', '63806193053', 'Mupirocina pomada', 'Aplicar 3x ao dia por 7 dias', 1;
EXEC Registra_Receita 11, 2, 'senha123?', '26-06-2027', '27788684023', 'Cetoconazol creme 2%', 'Aplicar 1x ao dia por 14 dias', 1;
EXEC Registra_Receita 12, 2, 'senha123?', '30-06-2027', '51971708089', 'Clotrimazol creme', 'Aplicar 2x ao dia por 21 dias', 1;
EXEC Registra_Receita 13, 2, 'senha123?', '03-07-2027', '54537158042', 'Miconazol pomada', 'Aplicar 2x ao dia', 1;
EXEC Registra_Receita 14, 2, 'senha123?', '07-07-2027', '00175474079', 'Terbinafina creme 1%', 'Aplicar 1x ao dia por 14 dias', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '10-07-2027', '26572689000', 'Ácido Fusídico pomada', 'Aplicar 3x ao dia por 7 dias', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '14-07-2027', '39867593014', 'Gentamicina pomada', 'Aplicar 2x ao dia', 1;
EXEC Registra_Receita 10, 2, 'senha123', '17-07-2027', '67593704068', 'Neomicina+Bacitracina', 'Aplicar 3x ao dia', 1;
EXEC Registra_Receita 11, 2, 'senha123?', '21-07-2027', '42891855094', 'Sulfadiazina de prata 1%', 'Aplicar 1-2x ao dia em queimadura', 1;
EXEC Registra_Receita 12, 2, 'senha123?', '24-07-2027', '35295496066', 'Adapaleno gel 0,1%', 'Aplicar à noite em acne', 1;
EXEC Registra_Receita 13, 2, 'senha123?', '28-07-2027', '65331943055', 'Tretinoína creme 0,05%', 'Aplicar à noite - usar protetor solar', 1;
EXEC Registra_Receita 14, 2, 'senha123?', '31-07-2027', '89961711076', 'Peróxido de Benzoíla 5%', 'Aplicar 1x ao dia', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '04-08-2027', '31895518040', 'Ácido Azelaico 20%', 'Aplicar 2x ao dia', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '07-08-2027', '90653374070', 'Isotretinoína 20mg', 'Tomar 1 cáps 2x ao dia com alimento', 60;
EXEC Registra_Receita 10, 2, 'senha123', '11-08-2027', '46261355010', 'Doxiciclina 100mg (acne)', 'Tomar 1 comp ao dia por 3 meses', 90;
EXEC Registra_Receita 11, 2, 'senha123?', '14-08-2027', '59442913034', 'Minociclina 100mg', 'Tomar 1 comp ao dia', 30;
EXEC Altera_Receita 1, 'senha123?', '54856098802', 1;
EXEC Altera_Receita 2, 'senha123?', '21524961086', 2;
EXEC Altera_Receita 3, 'senha123?', '05642844083', 3;
EXEC Altera_Receita 3, 'senha123?', '05642844083', 3;
EXEC Altera_Receita 3, 'senha123?', '05642844083', 3;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 5;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 5;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 6;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 7;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 5, 'senha123?', '87949685000', 12;
EXEC Altera_Receita 4, 'senha123?', '58061315050', 4;
EXEC Altera_Receita 4, 'senha123?', '58061315050', 4;
EXEC Registra_Receita 10, 2, 'senha123', '15-06-2024', '54856098802', 'Amoxicilina 875mg', 'Tomar 1 comp 12/12h por 10 dias', 20;
EXEC Registra_Receita 11, 2, 'senha123?', '20-07-2024', '03674704030', 'Diclofenaco Potássico 50mg', 'Tomar 1 comp 8/8h se dor', 15;
EXEC Registra_Receita 12, 2, 'senha123?', '10-08-2024', '05642844083', 'Prednisona 20mg', 'Tomar 2 comp manhã por 5 dias', 10;
EXEC Registra_Receita 13, 2, 'senha123?', '25-09-2024', '58061315050', 'Azitromicina 500mg', 'Tomar 1 comp ao dia por 5 dias', 5;
EXEC Registra_Receita 14, 2, 'senha123?', '15-10-2024', '87949685000', 'Nimesulida 100mg', 'Tomar 1 comp 12/12h por 3 dias', 6;
EXEC Registra_Receita 15, 2, 'senha123?', '30-11-2024', '75974478096', 'Cetoconazol 200mg', 'Tomar 1 comp ao dia por 14 dias', 14;
EXEC Registra_Receita 16, 2, 'senha123?', '20-12-2024', '34731605040', 'Metronidazol 250mg', 'Tomar 2 comp 8/8h por 7 dias', 42;
EXEC Registra_Receita 10, 2, 'senha123', '10-01-2025', '51890585068', 'Ciprofloxacino 500mg', 'Tomar 1 comp 12/12h por 7 dias', 14;
EXEC Registra_Receita 11, 2, 'senha123?', '25-02-2025', '81112054065', 'Levofloxacino 750mg', 'Tomar 1 comp ao dia por 7 dias', 7;
EXEC Registra_Receita 12, 2, 'senha123?', '15-03-2025', '53274699055', 'Doxiciclina 100mg', 'Tomar 1 comp 2x ao dia por 10 dias', 20;
EXEC Registra_Receita 13, 2, 'senha123?', '20-04-2025', '07628546005', 'Fluconazol 150mg', 'Tomar 1 cáps dose única semanal', 4;
EXEC Registra_Receita 14, 2, 'senha123?', '30-05-2025', '75286209041', 'Albendazol 400mg', 'Tomar 1 comp dose única', 1;
EXEC Registra_Receita 15, 2, 'senha123?', '15-06-2025', '56470317065', 'Ivermectina 6mg', 'Tomar 4 comp dose única', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '25-07-2025', '19483550009', 'Nitrofurantoína 100mg', 'Tomar 1 cáps 6/6h por 7 dias', 28;
EXEC Registra_Receita 10, 2, 'senha123', '10-08-2025', '93729214080', 'Sulfametoxazol 400mg+Trimetoprima 80mg', 'Tomar 2 comp 12/12h por 10 dias', 40;
EXEC Registra_Receita 11, 2, 'senha123?', '20-09-2025', '69068097091', 'Norfloxacino 400mg', 'Tomar 1 comp 12/12h por 7 dias', 14;
EXEC Registra_Receita 12, 2, 'senha123?', '01-09-2025', '21955621020', 'Claritromicina 500mg', 'Tomar 1 comp 12/12h por 10 dias', 20;
EXEC Registra_Receita 13, 2, 'senha123?', '15-09-2025', '08924899015', 'Cefadroxila 500mg', 'Tomar 1 cáps 12/12h por 7 dias', 14;
EXEC Registra_Receita 14, 2, 'senha123?', '25-09-2025', '21524961086', 'Eritromicina 500mg', 'Tomar 1 comp 6/6h por 10 dias', 40;
EXEC Registra_Receita 15, 2, 'senha123?', '01-10-2025', '39862328002', 'Cefalexina 500mg', 'Tomar 1 cáps 6/6h por 10 dias', 40;
EXEC Registra_Receita 16, 2, 'senha123?', '05-10-2025', '05892157016', 'Amoxicilina+Clavulanato 875mg', 'Tomar 1 comp 12/12h por 7 dias', 14;
EXEC Registra_Receita 10, 2, 'senha123', '15-03-2024', '22942383038', 'Losartana 50mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '20-04-2024', '43817833016', 'Hidroclorotiazida 25mg', 'Tomar 1 comp pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '10-05-2024', '59784195070', 'Atenolol 25mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '25-06-2024', '54273844052', 'Metformina 500mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '15-07-2024', '51971708089', 'Sinvastatina 20mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '30-08-2024', '58614220014', 'Levotiroxina 50mcg', 'Tomar 1 comp em jejum', 90;
EXEC Registra_Receita 16, 2, 'senha123?', '20-09-2024', '21341531058', 'Omeprazol 20mg', 'Tomar 1 cáps em jejum', 30;
EXEC Registra_Receita 10, 2, 'senha123', '15-10-2024', '91948947013', 'Fluoxetina 20mg', 'Tomar 1 cáps pela manhã', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '30-11-2024', '40310919070', 'Sertralina 50mg', 'Tomar 1 comp pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '20-12-2024', '74315582018', 'Escitalopram 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '15-04-2024', '90934957045', 'Clonazepam 2mg', 'Tomar 1/2 comp à noite', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '20-05-2024', '43014639095', 'Alprazolam 0,5mg', 'Tomar 1 comp SOS ansiedade', 20;
EXEC Registra_Receita 15, 2, 'senha123?', '30-06-2024', '33077793032', 'Rivotril 2mg', 'Tomar 20 gotas à noite', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '15-07-2024', '62062052073', 'Diazepam 10mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 10, 2, 'senha123', '25-08-2024', '10358560004', 'Zolpidem 10mg', 'Tomar 1 comp antes de dormir', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '10-09-2024', '47298600044', 'Bromazepam 3mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '20-10-2024', '09577340008', 'Lorazepam 2mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '10-05-2024', '18065460003', 'Tramadol 50mg', 'Tomar 1 comp 8/8h se dor', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '25-06-2024', '15150863050', 'Codeína 30mg', 'Tomar 1 comp 6/6h se dor forte', 20;
EXEC Registra_Receita 15, 2, 'senha123?', '15-07-2024', '12614706051', 'Morfina 10mg', 'Tomar 1 comp 12/12h', 60;
EXEC Registra_Receita 16, 2, 'senha123?', '30-08-2024', '60030094038', 'Oxicodona 10mg', 'Tomar 1 comp 12/12h', 60;
EXEC Registra_Receita 10, 2, 'senha123', '20-09-2024', '74689923043', 'Pregabalina 75mg', 'Tomar 1 cáps 2x ao dia', 60;
EXEC Registra_Receita 11, 2, 'senha123?', '15-10-2024', '40526767006', 'Gabapentina 300mg', 'Tomar 1 cáps 3x ao dia', 90;
EXEC Registra_Receita 12, 2, 'senha123?', '20-03-2024', '13164571097', 'Meropenem injetável', 'Uso hospitalar conforme prescrição', 1;
EXEC Registra_Receita 13, 2, 'senha123?', '15-04-2024', '86565804001', 'Vancomicina injetável', 'Uso hospitalar conforme prescrição', 1;
EXEC Registra_Receita 14, 2, 'senha123?', '30-05-2024', '85194921004', 'Linezolida 600mg', 'Tomar 1 comp 12/12h', 20;
EXEC Registra_Receita 15, 2, 'senha123?', '20-06-2024', '08343472020', 'Tigeciclina injetável', 'Uso hospitalar conforme prescrição', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '15-05-2024', '75064872097', 'Dexametasona 4mg', 'Tomar 1 comp manhã por 7 dias', 7;
EXEC Registra_Receita 10, 2, 'senha123', '30-06-2024', '01421826054', 'Betametasona 0,5mg', 'Tomar 2 comp manhã', 60;
EXEC Registra_Receita 11, 2, 'senha123?', '20-07-2024', '05819922026', 'Deflazacorte 6mg', 'Tomar 2 comp ao dia', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '15-08-2024', '33342562005', 'Hidrocortisona 20mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 13, 2, 'senha123?', '20-04-2024', '82945026007', 'Insulina NPH', 'Aplicar 10UI manhã e 10UI noite', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '15-05-2024', '38476344023', 'Insulina Regular', 'Aplicar conforme glicemia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '30-06-2024', '30964927004', 'Insulina Lantus', 'Aplicar 20UI ao deitar', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '25-07-2024', '79021021056', 'Insulina Humalog', 'Aplicar antes refeições', 30;
EXEC Registra_Receita 10, 2, 'senha123', '10-03-2024', '93379047058', 'Captopril 25mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 11, 2, 'senha123?', '25-04-2024', '55124371005', 'Enalapril 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '15-05-2024', '78762128086', 'Anlodipino 5mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '30-06-2024', '42256849031', 'Valsartana 160mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '20-07-2024', '01400902070', 'Olmesartana 40mg', 'Tomar 1 comp ao dia', 30;
EXEC Envia_Mensagem_P 2, '81112054065', 'Creatinina em 1,8 e potássio em 5,5. O que devo fazer?';
EXEC Envia_Mensagem_F '81112054065', 2, 'Valores alterados! Suspenda medicação AGORA. Venha hoje urgente!';
EXEC Envia_Mensagem_P 2, '81112054065', 'Já suspendi! Posso ir em 2 horas?';
EXEC Envia_Mensagem_F '81112054065', 2, 'Sim! Estarei esperando. Traga todos exames recentes.';
EXEC Envia_Mensagem_P 1, '51890585068', 'Minha receita venceu mês passado e não peguei medicação a tempo';
EXEC Envia_Mensagem_F '51890585068', 1, 'Venha fazer nova receita. Não pode ficar sem medicação contínua.';
EXEC Envia_Mensagem_P 1, '51890585068', 'Consigo agendar para hoje tarde?';
EXEC Envia_Mensagem_F '51890585068', 1, 'Sim, 16h está disponível. Confirmo sua consulta.';
EXEC Envia_Mensagem_P 24, '67593704068', 'Posso usar receita vencida há 2 meses? Remédio é caro';
EXEC Envia_Mensagem_F '67593704068', 24, 'Não! Farmácia não aceita. Precisa receita nova obrigatoriamente.';
EXEC Envia_Mensagem_P 24, '67593704068', 'Mas o remédio é o mesmo que sempre tomo...';
EXEC Envia_Mensagem_F '67593704068', 24, 'Lei exige receita válida. Venha renovar, é rápido.';
EXEC Envia_Mensagem_P 25, '39867593014', 'Achei receita vencida de antibiótico. Posso tomar?';
EXEC Envia_Mensagem_F '39867593014', 25, 'JAMAIS! Antibiótico sem orientação atual é perigoso. Está doente?';
EXEC Envia_Mensagem_P 25, '39867593014', 'Estou com garganta inflamada há 3 dias';
EXEC Envia_Mensagem_F '39867593014', 25, 'Marque consulta hoje. Preciso avaliar antes de prescrever.';
EXEC Envia_Mensagem_P 26, '42891855094', 'Encontrei receita antiga de controlado. Posso comprar?';
EXEC Envia_Mensagem_F '42891855094', 26, 'Não! Receita controlada tem validade de 30 dias apenas.';
EXEC Envia_Mensagem_P 26, '42891855094', 'Mas está com 45 dias só...';
EXEC Envia_Mensagem_F '42891855094', 26, 'Farmácia não aceita. É lei federal. Venha fazer nova receita.';
EXEC Envia_Mensagem_P 27, '35295496066', 'Tenho várias receitas vencidas guardadas. Devo descartar?';
EXEC Envia_Mensagem_F '35295496066', 27, 'Sim, descarte! Guarde apenas receitas válidas.';
EXEC Envia_Mensagem_P 27, '35295496066', 'Como faço descarte correto?';
EXEC Envia_Mensagem_F '35295496066', 27, 'Pode rasgar e jogar no lixo comum. Não tem valor mais.';
EXEC Envia_Mensagem_P 28, '65331943055', 'Preciso renovar 3 receitas que venceram. Preciso consulta?';
EXEC Envia_Mensagem_F '65331943055', 28, 'Depende! Se tratamento contínuo, consulta rápida resolve.';
EXEC Envia_Mensagem_P 28, '65331943055', 'São remédios que tomo há anos sem mudança';
EXEC Envia_Mensagem_F '65331943055', 28, 'Então venha só para renovação. 15 minutos resolve.';