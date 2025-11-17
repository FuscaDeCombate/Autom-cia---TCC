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
CREATE TABLE Baixa (
	ID_Receita INT NOT NULL,
	Funcionar_Rec INT NOT NULL,
	Data_Baixa DATETIME2 DEFAULT GETDATE(),
	FOREIGN KEY (ID_Receita) REFERENCES Receita(ID_Receita),
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
				--
				INSERT INTO Baixa(ID_Receita, Funcionar_Rec) VALUES (@ID_Receita, @ID_Funcionario_Alt);
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
	DECLARE @Nome_P VARCHAR(50),
			@Nome_F VARCHAR(50);
        BEGIN TRY
                IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_M_Chat AND Ativo = 1)
                BEGIN
                        SELECT 'CPF do paciente não encontrado ou inativo' AS 'Retorno_Mostra_Chat';
                        RETURN;
                END
				ELSE IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_M_Chat AND Ativo = 1)
                BEGIN
                        SELECT 'Funcionário não encontrado ou inativo' AS 'Retorno_Mostra_Chat';
                        RETURN;
                END
				ELSE
					BEGIN
						SET @Nome_F = (SELECT Nome_Funcionario FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_M_Chat);
						IF (SELECT Nome_Social FROM Paciente WHERE Paciente_F = @CPF_M_Chat) is null SET @Nome_P = (SELECT Nome_Paciente FROM Paciente WHERE Paciente_F = @CPF_M_Chat)
						ELSE SET @Nome_P = (SELECT Nome_Social FROM Paciente WHERE Paciente_F = @CPF_M_Chat)
						OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
						SELECT 
								ID_Chat,
								Paciente_F,
								@Nome_P AS 'Nome_Paciente',
								Funcionar_Rec,
								@Nome_F AS 'Nome_Funcionario',
								CONVERT(VARCHAR(500), DECRYPTBYKEY(Mensagem)) AS Mensagem,
								Hora_Envio,
								MsgPaciente
						FROM Mensagem 
						WHERE Paciente_F = @CPF_M_Chat 
						  AND Funcionar_Rec = @ID_Funcionario_M_Chat
						ORDER BY Hora_Envio ASC;
						CLOSE SYMMETRIC KEY EnK_Mensag;
					END
                
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
        @Mostrar_Inativos BIT
) AS
BEGIN
        DECLARE
                @Empresa_Existe BIT;
		Set @Empresa_Existe = 0;
        BEGIN TRY
                SET @CNPJ_Contratante = LTRIM(RTRIM(@CNPJ_Contratante));
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ_Contratante)
                        SET @Empresa_Existe = 1;
                IF (@Empresa_Existe = 1)
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
		SELECT 'Erro' AS 'Mostra_Funcionário_Retorno';
	END CATCH
END
GO
CREATE PROCEDURE Mostra_Receitas_Func (@ID_Funcionario INT) AS
	BEGIN
		BEGIN TRY
			SELECT * FROM Receita WHERE Funcionar_Rec = @ID_Funcionario ORDER BY Data_Receita;
		END TRY
		BEGIN CATCH
			SELECT 'Erro' AS 'Mostra_Receitas_Func_Retorno';
		END CATCH
	END
GO
CREATE PROCEDURE Mostra_Baixas(@ID_Funcionario_Ba INT) AS
	BEGIN
		BEGIN TRY
			IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_Ba)
				BEGIN
					IF (SELECT COUNT(ID_Receita) FROM Baixa WHERE Funcionar_Rec = @ID_Funcionario_Ba) != 0
						SELECT * FROM Baixa WHERE Funcionar_Rec = @ID_Funcionario_Ba;
					ELSE SELECT 'Não há baixas' AS 'Mostra_Baixas_Retorno';
				END
			ELSE 
				BEGIN
					SELECT 'Funcionáro Inválido' AS 'Mostra_Baixas_Retorno';
				END
		END TRY
		BEGIN CATCH
			SELECT 'Erro' AS 'Mostra_Baixas_Retorno';
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
CREATE PROCEDURE Funcionarios_Paciente_Chat (
    @CPF_Paciente VARCHAR(11)
)
AS
BEGIN
    BEGIN TRY
        SELECT 
            f.Funcionar_Rec,
            f.Nome_Funcionario,
            tf.Tipo_Funci AS Tipo_Funcionario,
            c.Nome_Contratante AS Hospital,
            CASE 
                WHEN EXISTS (
                    SELECT 1 
                    FROM Mensagem m 
                    WHERE m.Funcionar_Rec = f.Funcionar_Rec 
                      AND m.Paciente_F = @CPF_Paciente
                ) THEN 1
                ELSE 0
            END AS ChatAberto,
            f.Ativo
        FROM Funcionario f
        INNER JOIN Tipo_Funcionario tf ON f.ID_Tipo_Funcionario = tf.ID_Tipo_Funcionario
        INNER JOIN Contratante c ON f.CNPJ = c.CNPJ
        ORDER BY c.Nome_Contratante, f.Nome_Funcionario;
    END TRY
    BEGIN CATCH
        SELECT 'Erro ao listar funcionários e status de chat' AS Retorno;
    END CATCH
END
GO
--Apresentação
Declare @PDF Varbinary(max);
Set @PDF = Convert(Varbinary(max), '255044462d312e350a25e2e3cfd30a392030206f626a0a3c3c
0a2f54797065202f466f6e7444657363726970746f720a2f46
6f6e744e616d65202f54696d65732332304e6577233230526f
6d616e0a2f466c6167732033320a2f4974616c6963416e676c
6520300a2f417363656e74203839310a2f44657363656e7420
2d3231360a2f436170486569676874203639330a2f41766757
69647468203430310a2f4d6178576964746820323631340a2f
466f6e74576569676874203430300a2f584865696768742032
35300a2f4c656164696e672034320a2f5374656d562034300a
2f466f6e7442426f78205b2d353638202d3231362032303436
203639335d0a3e3e0a656e646f626a0a31302030206f626a0a
5b323530203020302030203020302030203020333333203333
33203020302032353020333333203235302032373820353030
20353030203530302035303020353030203530302035303020
35303020353030203530302032373820323738203020302030
20302030203732322030203636372037323220363131203535
36203732322037323220333333203338392037323220363131
20383839203732322037323220353536203020302035353620
36313120373232203732322030203020302036313120302030
20302030203020302034343420353030203434342035303020
34343420333333203530302035303020323738203237382030
20323738203737382035303020353030203530302035303020
33333320333839203237382035303020353030203020353030
20353030203434342030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203736302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302034343420302034343420
30203020302034343420302034343420343434203020302032
37382030203020302030203020353030203530302035303020
30203020302030203530305d0a656e646f626a0a382030206f
626a0a3c3c0a2f54797065202f466f6e740a2f537562747970
65202f54727565547970650a2f4e616d65202f46310a2f4261
7365466f6e74202f54696d65732332304e6577233230526f6d
616e0a2f456e636f64696e67202f57696e416e7369456e636f
64696e670a2f466f6e7444657363726970746f722039203020
520a2f4669727374436861722033320a2f4c61737443686172
203235300a2f576964746873203130203020520a3e3e0a656e
646f626a0a31322030206f626a0a3c3c0a2f54797065202f46
6f6e7444657363726970746f720a2f466f6e744e616d65202f
54696d65732332304e6577233230526f6d616e2c426f6c640a
2f466c6167732033320a2f4974616c6963416e676c6520300a
2f417363656e74203839310a2f44657363656e74202d323136
0a2f436170486569676874203637370a2f4176675769647468
203432370a2f4d6178576964746820323535380a2f466f6e74
576569676874203730300a2f58486569676874203235300a2f
4c656164696e672034320a2f5374656d562034320a2f466f6e
7442426f78205b2d353538202d323136203230303020363737
5d0a3e3e0a656e646f626a0a31332030206f626a0a5b323530
20302030203020302030203020302030203020302030203020
30203020323738203530302035303020353030203020302035
30302030203020302030203020302030203020302030203020
37323220302037323220373232203636372036313120302037
37382030203020302030203934342037323220373738203631
31203020373232203535362036363720302037323220302030
20302030203020302030203020302030203530302030203434
34203535362034343420333333203530302030203237382030
20302032373820383333203535362035303020302030203434
34203338392033333320353536203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203530302030203020302030203434342030203020
30203020302030203020302030203020302035303020302030
2030203020302030203535365d0a656e646f626a0a31312030
206f626a0a3c3c0a2f54797065202f466f6e740a2f53756274
797065202f54727565547970650a2f4e616d65202f46320a2f
42617365466f6e74202f54696d65732332304e657723323052
6f6d616e2c426f6c640a2f456e636f64696e67202f57696e41
6e7369456e636f64696e670a2f466f6e744465736372697074
6f72203132203020520a2f4669727374436861722033320a2f
4c61737443686172203235300a2f5769647468732031332030
20520a3e3e0a656e646f626a0a31352030206f626a0a3c3c0a
2f54797065202f466f6e7444657363726970746f720a2f466f
6e744e616d65202f54696d65732332304e6577233230526f6d
616e2c4974616c69630a2f466c6167732033320a2f4974616c
6963416e676c65202d31362e340a2f417363656e7420383931
0a2f44657363656e74202d3231360a2f436170486569676874
203639340a2f4176675769647468203430320a2f4d61785769
64746820313833310a2f466f6e74576569676874203430300a
2f58486569676874203235300a2f4c656164696e672034320a
2f5374656d562034300a2f466f6e7442426f78205b2d343938
202d3231362031333333203639345d0a3e3e0a656e646f626a
0a31362030206f626a0a5b3235302030203020302030203020
30203020333333203333332030203020323530203020323530
20302035303020353030203530302035303020353030203530
30203530302030203020302030203020302030203020302030
20363131203020302030203020302030203020302034343420
30203020383333203020302030203020302030203020302036
31312030203020302030203020302030203020302030203530
30203530302034343420353030203434342030203020353030
20323738203020302032373820302035303020353030203530
30203020302033383920323738203530302034343420302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020302030
20302030203020302030203020302030203020302030203020
30203020302030203020302030203020302030203020353030
5d0a656e646f626a0a31342030206f626a0a3c3c0a2f547970
65202f466f6e740a2f53756274797065202f54727565547970
650a2f4e616d65202f46330a2f42617365466f6e74202f5469
6d65732332304e6577233230526f6d616e2c4974616c69630a
2f456e636f64696e67202f57696e416e7369456e636f64696e
670a2f466f6e7444657363726970746f72203135203020520a
2f4669727374436861722033320a2f4c617374436861722032
34340a2f576964746873203136203020520a3e3e0a656e646f
626a0a31372030206f626a0a3c3c0a2f54797065202f457874
4753746174650a2f424d202f4e6f726d616c0a2f636120310a
3e3e0a656e646f626a0a31382030206f626a0a3c3c0a2f5479
7065202f4578744753746174650a2f424d202f4e6f726d616c
0a2f434120310a3e3e0a656e646f626a0a31392030206f626a
0a3c3c0a2f54797065202f584f626a6563740a2f5375627479
7065202f496d6167650a2f5769647468203231360a2f486569
676874203231350a2f436f6c6f725370616365202f44657669
63655247420a2f42697473506572436f6d706f6e656e742038
0a2f496e746572706f6c6174652066616c73650a2f46696c74
6572202f466c6174654465636f64650a2f4c656e6774682038
3833370a3e3e0a73747265616d0a789ced9d877f5655b6f7ff
80fb7ebc3a808ced5ae6cebdf7f3ce67e63a48959684404295
8e5214a4895d074471000b2a888802022aa2224d054144c48a
0e553a2924a4f73ca94f3d6d97b5dfbdf77912d274de913ce1
44d797f5096173f29c27e7f99db5d75abb1c21100441100441
10044110044110044110044110044110044190f6061782caaf
c00475049146056582332198006df27bc65423a302489d516d
1cd471427e1500f22ff7d5648b6075a6fecffd82203f09b87a
1204c0014e8101d8cab8889a82836aa752ad4d4c8a4f4a910a
ee08db11610621e04101b656a5b6fad3a016919f463a3a4b84
a58ab8d49cf45e443681603ceacc6863635a76aea9c3a440b9
ad5e01a43942ca9802278273e518dd57e0da530a47ff3c82b4
0c17d48600153542540ba865604a3945040f02ada5b486d05a
c2fd04fc44a8af94d5d8b4ca74a4d538cc4f5880902071420e
0fdb82e8fe5b6910b8f6af5a8d511d12b7b7469016515ed014
9cc84ed736c0cca90eef3c5c3c6fcdc1bbfebe3ff9c13d03e7
7c36f0becf07ce96b66fe0ecfd83e77cdbff9e2f7addf5e9ed
13f7c44ddd3f70e65783677e3774da77c3a67d357ad6e7d39f
dcb5e4ed839ffe589c1f2601b00d6e13e9293975a579b97f51
c4db00738cb0e9407190aedc72bedbc8ed57dffa6ec75b3774
eaf1f24d0356ff31f9cd3f0c5aefda7f0edaf05f8336ddd067
fdd5dd5775eebeeaa6fe1bfe38f0fdff1cb4f9e6a4ad7f487e
ffe6816f75eef3da15dd5ff9f75eab7b4fddf4e9c9d24a0211
6a0be14a11c343e4e76060074920addc8e9ffad155dddfbe25
71d363af1cdb75a8e27c69a430681585ec92b0e55a71d02e09
da857eaba0d628f41b457eab2860cb46754c481e69e4d59afb
8e57cc5efcdd0dbdd7dfd0f7ad55dbcfd5a87447078f1c5087
483d3252d3951419c911c128a52cc4f9b1a248f7f15ffcaeeb
dae90bf7a5e519114a2d0870952447b3dc7a63324556d4bf9a
fe87faa74a4be44fc8fcc666e2504aa0db988dd7f458bd66c7
85308418932fc939a0109128d23d519d9ba81cd771646691e3
b7931ff8a863f7cdcf6eccac08db3c024c3a31b02fe52c3617
87b32bfe77e47b37dcbef1787695c32384510698a7205140d5
fa84ce646d4658908867d61decd075f59c6507cb08101e16cc
66aa887349676114c2dcdef0656ea72ebba7cc3be087308320
f6cb481db217654c5597393093329e5a12f9af84d7bb8ddb9d
19242637b91311344481d897a8190a8c04ca281d30e3d0f5fd
36fe58e823dc062c1f2251648c46a23a04cb607ccd8e940edd
56aed8763e2428a7d20f0ae527859f5e62cd59fe34212101cf
6e3e73458f97367c79c16158c646ea916ab054f621dda23064
8632e1892fafedffeef1dc6add193341a427235cf855867b29
70357e62026c3f72e1caee4b9fdd9866523df48c200ae9924c
77c898825143f96de3b7de3a6ebf2fc48180b0a504b92dffe2
448d7e5c1a9cca2091fe905ad9b1cbc6056bd3c3dc119796fb
20bf2240856e4209917316e0e2c6feeff79efa997456a007e0
b89e5a131d1abeb4f350cea49a0fa7f8afecb6e189d5271cb8
f417457e4de80aa29e4123a3c01b7a6d8e9ff5a9d370ac035a
636a0c977207d9c91f4df5ff9f1e6be7ae3e4cb153461a7151
8735445cdf73f380fb3e431d226dce451dd612f11fb76f4998
bd077588b439753a8436d2e1bff5583b6fcd11d421d218d421
e20550878817401d225e0075887801d421e20550878817401d
225e0075887801d421e20550878817401d225e0075887801d4
21e20550878817401d225e0075887801d421e2055087881740
1d225e0075887801d421e20550878817401d225e0075887801
d421e20550878817401d225e0075887801d421e20550878817
401d225e0075887801d421e20550878817401d225e00758878
81e8139841a00e91cb877ee4ad7e6e1454117143afad0366c6
f6f929a843a405940e191740a33adc326016fa43a4eda9d7a1
a8d3616c9f6b863a449a23dd211394e9a7d25753717daf4d03
66ed461d226d0c08e2ea9070915b634a1d263f80f121d2d680
709820ae0ecf15545fd3fddd194b4fa30e91b605a40e557ca8
7578a6c02f7538fda5e3047588b421a02a364ccb4c8a849dca
0f5fd76bd3ec6547d825aaae39a843e4a769ac437a2a3fa275
78187588b425a843c40b34d1e189bcf0b53ddf8fb50ef139e0
48139afac342f39a1eefdf17e3f810758834a1a10e1d20c7b2
fdd21fdebffc28eab03dc205303534a666ad34ac7280c7ece2
7bbaf8ce994c93d51be7dc00e7e383599dbabefdccc6b4d6d7
2108065ceaf070aaff8aeeebe7ae3e4a405c72310869049557
1828153600951f2870066083a01cc043a6677669b874834a17
82c9f76c4a471801e1183560cf7ee560e71e6f7c7aa82016fa
90e795a7fb3ecddff1b677e7ad3e69b9b72fd28a50211c2547
01b2f3610c08054b0dd8caebec2553e3266af4440fa0e8efa9
b018af162440acf0c10cff7f0fd9d47dccc63293a30edb23ee
a018555e86a9792bf23b5bf574f22f4f9910449bbc6d98d00e
52de32260f4448e8dc053b7eecb7d7765bb7f3871c8359b1e8
3151873142f670ee57e9586c2e3b381e01c714860d8e7434ca
385c7623755f23044a8350ec87a21a5ee41785b5a23820722a
e1cbf4aae7de3df997a41dd7deb6fd8577ce4498cd89d9fad7
4aa95e462fe67729fe0e5dde7de28dd3a6ba6b49ab9fe8b789
0ab66434488260db1153fc2335f8e2e693d396fc9034e7bb84
e95f0e98f1b9172c51dacc7d3d27edfa43f247b7247f7c73d2
8737276fbf2969ebcd83b7fec7c0ad57f7da7865f7e5ff33f8
cdf57b727c7680518b8563933e0077c03c905a2b7528fda1e9
f61dc825e3fa4349c0e1bb0e1424deb5bbd36d1baeeab1f6ba
8477ff90b8f796c1bb6e1ab6f5b2dbcdc3b7dd3864f34d43b7
dc326cfb1f9377fcf7e09dff77f88e8499df24ccfe2a7ef6e7
83e7ec9bf5f481753b4f1744204829e321c64de2b4be0e3997
d74ba645d6075fa4feeeaf1b1f7df598ea97a9d3e44ab623a0
316d7e7aa1eb342a28e4f22303ea0bf3c7571dbaaaefeb57f7
7df3eec507b7fc5070bad85fe4a7657ef00584070ccafd5c5a
999fcb1eb9240065610882088108021842d85c988c10ce98ee
bf09588e68fd7e59552ae55984bd657f5a872e1b5ede9e1521
8472c29801c10a3b33835cc880ac3471210db232444b06da9a
fc135a3a260687658a0b17a4415666bdd19c0c9e9329f2f245
4535446450c674b60a8e0e42e41feaae826cfd4ba951f7b5a5
6e6f0728f7975b64fcfc6fafeaf2e6e07b771e385b192232e8
5135125d2469bfc4e8bd7322c8b62f333adeb66ed5275952f9
b669040f7d93ffe8f4c2616373ef18573a32c9372c39ef8e91
c5239a5ae9f0916523b40dafb311cd5a5a6cbcf4c3e437c346
970d1ba36cf868d74a878fca1f3da460c4d0e29163b3ee9c9a
fbc442ffd6edbca0803856583015a931db164a2731cac474e5
4d3a125b9eab3ac29e5cfe7d87aeaf4f5dbc3f2fc8038c184e
48e5805c1dd49e7518239aea901555664e99953d24a960fcf4
9cd973cb9f9a57397f41e9c2e7ca9e5aa86d519d2d2c7d6a61
c9d3ca4a172c72cdfd67c396161b5be3b0862d512b7f6aa17f
de13b54fceab98ff48ee0353cf8e189431a07ff9f8f1c6ae3d
3c58c9c0e2c4911a7462764b83aa101ab22b3304df7bb8f4c6
ee6fc54fdb911374c23c62b21ac6c242978c9952220e5c35a1
993f3c9f7574d888dc25f3445181a809725b7670b5dc0c0b33
d0d48c3a8bd459f396161b5be7307fd48c3a8b48bf13626684
da010895d2f413e51bde3a3d76c2b9a12302ebd741a89c5347
3a244be84e3a06a8310926fff04a42473df4d9b53dded97bda
1f912793b7808cb6a24181fc6281c0a2442338a7f2ea7cf875
6627a5c31c029c9c4b3b3d6870f68a8522ec0722232ba25652
73f72aeb9ec73570afba878cead03a2284fcaae6b25b5c0468
e4684afa3df714c60ff5efd8c25998c85ed31db38a81535417
86aaeb75ba247275afd7863db8b7429e8ceb1d11dcc1331d1a
4a87893a6c861a5fdeba3fa36397b5ca1f3246ce9c39953ce8
fcaa4536090355e194a3abff2d8c8c838ecc2fa3316d0d5a98
2ed0aa31732944c6d52c0e4ac8e17fe425df91327e8c959d42
41df53b1d121034a65de077ce3be8c7fefb6e6d59d19365363
143a4522caa277b0fba69186c8649c6cf9224df6cb6b765fb0
092167ce65260ccc7a6db18cac85ea54e487e9a88fd51d12e7
7506f59ef1a20e9ab7b4d8d84a87359a24e28e5e08624b93fd
aff4f3aa222583414244205cfdc1faf4e4b8ea35abb8695a2c
56e1191536e59603ce336f1dbdaadbbabda74aa42e950e550a
2dbdb3ad72945659587479717b4680c6bee05ff8f93a737f3c
3af42e7de0da0f4e74ecf2dac66f33238c3a296752070cca5b
be8491b02a7900951e8609a6d6b12a637546799db9d33340cd
6e6adad262636b1cc6eaae45b4bb8bce18e16a7cd4d4bdb3ed
9640a9903e9257e4a48d1de19b7c3794fb0c46496c74207b16
ceb80d64f6d2239d7bae3f9e59cadb6311f69f003a02627553
757440d4f833fa59e31727f5a8be418d9ba85e84d9119b3fb6
e8e8757d5eff2aa7ca00eea49f3a3930b974c972b06b892ac8
aa63dbef108bbaf1a43732ece2a716d60c4982ac0b8c3b31fa
75a4ffe52a2ca0d3971cbeb6cf865359e5ec57a7431d02cb0b
4898da7cc91596db3fd168ecf1f3a6e322ae1d07af33412927
a13325a15b06bdd7edceede536e766c8493d7d6a6072d18bcb
c109505579d55b9c5cee5fff17a30637a41737ecea652b4ae3
fbd92929ea068ccdb9a80e5f644e7eeff387afb9fdad1359e5
eae2fdca8418ddf146894a8641ae63d47dd1ffdf74db3a1f28
640e2c1da94edfa4a82bfc6cda9203ffd6f3d557b7a511a568
8b9c3d76764052eeb2e5c2092a5fa87f9cb7db8006d46f29a3
3352fbfa1bc57d7b474e9f9291488c92843a7fc8a62f39726d
ef0d27b3b50e6373aecb06b853c3a423b380870544801b5c06
2375890397a1c94558337300c200410e41c28232af7418af76
e0e93773aeecbe39f981f76b4c1b6c215f8e1cff363d31a960
ed1b821a6a21bfd2216bbf7557a543b52d01ad7a6d4d49bf3e
e19327e5cdc863f3dbfc5674a86629aa196d321ab618353984
398480058005818504afb720f0a0a83350268f8c3011e642fa
b85a26f2fdec70ba6fdcbc2d57745f173ff1ab0ba53640adcc
e7a438cd2f3e4a8f1b50b5633bc833e8aaaf9ad0de6e7b66ae
c797a50e2b1be83046e2f84de850251a940193c9600d1327f2
6bd7edca7ae4e51f26cedf35f2e1eda31ed93efad1ed631e53
26bf19f5c8b6518fd6d923cac63cfce1d8873f1ca3db073ff0
718f893baebefdcdce7d5ebdfbc95d39a596e5302afb6bd92f
47cca2e79ec94f1a62fcf80fa0960c490df5519276af43422b
ea75a8c7356201d3a3d8f2aa4d7ff1e8b57ddf3999eda3bcdd
8787eee6872aac5351b5ec792dcecc10d06fb282772ef8fea6
84b73b745ffabbdb5eecd86579c7aeaf74e8baac43b7a51dba
bdd8a1fb928edd9674eafa42335b72f56dcf75eabab853b785
b724bcd277f2c7b35e3cbbe7b8bfd292af4b99c30c3d095ca4
9c3b3ffccefc29f78ac26c353391a97e59d55ddbed6dcd7521
59ead0f7bad6e171a5c318f5cb3a6b1426a7773f7ba4d3ed1b
8e6694d3762e43f9b1db3210147acf2f19d939a64c658361e7
954dc7afeebbaa43cff7ee78e8bb4dfb7352cb486e909646a8
2f422b23a4d2203e8b945bc467aa6fa2662a938d65f2bf4c52
61921a9b861c6e326e51ea70421d994e3287869d9a9c92271e
cb4e1816fc680784aa4c70683428bddc97e312d0930141505a
be6ab5ca537e543a8c51beac0a18146c6063e77f7765b77507
538b2e56dbdb27ae0e6d1d6f8023d30ca8e6ecb90fcf77eeb9
f12f43def9f8870b7ec7716ca052446a0cdd51f3ec549959b9
ae4625e63a236a258c0c5d546cc4541d9272d5edda52e4cc04
d361505a59f3ccb292fef145f3ffc67dc5168bf88152372865
ed7800a0ed7548808f9af7cd55dda50e0b58bbed475cd40895
502bdcb9ca8e5988882d3f945c99b0f57f866e3e94e137c1a6
20339508a7b58219f27b43d811414c416590276394e6d93205
ea08874817c7a58b55d319941e1d10110a664d30f760f6d38f
fa7a0d2b9c743fcbcaa6c40a7212d6533685aa21aa2cfd725f
925fc8e5f0877ceaf3873bf7d9a8eb87edf6068ee28e855301
2661b42844fb4cdafafbde1fee3a5464725bfea60608534a8b
1a6047686d352d2ae469293ce5144b3dce528eb3d3a7a276a6
ee9bb32759ca099672929d93df9f6667a49d318e1c2addb2c9
f7e843854307a60e8acf7af249a7205f557d69b4e2ad5710aa
8961acddf6cd0d7558d22faa4312a3b53e753a9cb6e488d261
b6af9debd0ad3b0bad03cbe6f0de17d91d6e7b65cea2af230e
939da9259dbfecb00ddb49cb2d5ebb3a6dd2d49cbe43ab7b24
57f54c2cec9790139f901737286afdeb2d31b7df00d772fa25
e6f61f981f9754d227aeb04fefdcc46165773d18d9bc87d754
1a3c68cbceba7e25abdaa69b113df5eb725f935f08eaf012e0
7a1282728a323d911df394f932de58b3ef448121836042d4d2
ce40c4bfedc38cb1a333e206e64f98583e7f7e68e9cbc1e52b
034b57d72e5b55fbf2cadae5da5e7ed5efdab295c1a5af295b
b6b276d9abba7d85bdfc75fbed0d91630799cf078603d2f312
8749d4ec01ae5790ca2e4c0708ed36ef6b4b1dba5300643c33
7dc9f7d7f55e7f3cbbc27d1453bb253a0e27f47c8610856e23
77fe79dcaeec2091e11da5941b81f086f7b30624664d9910d9
be13f273c1aab5b96173b53e47f7a24e53a37a06147194c9ef
95d333653b5773a44c1961aaf99b7aae30d3a129d35536474f
b0d1a3d1edf56a823beb86491dbe5ed2af6fe4d88f32ec7562
7432bd97748d80d94bbebdb1e7ba23d995f2e36ab73d894bdd
f3f53804b8b8a5df87bda7ed0e2a5745a464fcdffc90376840
e5dd539cf44c37e8fed54deb683da233c358d9aa9545fdfa1b
478fa80a446c7a4b955d825d23ec07971cbcb1e77b47b37d54
2d0788c5a9da8ca80e857ecee3f53d3f1830fb7347e62d34c8
8b8a73a73f9e3d74a89372d8e40e8f514df65784ea5ab40e0b
fbf78f1c3de24ee68dc58954ad57442222f4c4b21fafe9b2e9
40461983d0af468735fa795209f77d6ec8b08605cccf7716f6
19ec5fb9dca17ebf9e182d844035fe146e0514182b7b7d655e
5cfff08f47a2dbaac500a26abd1102a157df39d9e17f37beff
7d89c5ecf61bd2681a3cf7d6513aec7bdfdea0fc859cdaa215
8bf2e2e29d94a30e57ab98909fc79d6fc32da77cf9f2bcc484
f0e9636a59008dd17c6cae2bb5e6f7a72a7fd775fdd425dff9
edf6be56b9a90efbddf799dae1c6ac297dfae1a21143497911
7340d8ed77a274dba10aa106a958f44cc1e041ce85b3c47d3a
4d0c50ab15649f65395526e93e79d735091bcfe685daf94c87
a63a8cbf6f8f9a7260f8cb1f9a593b7a1c9457719319106edf
05aa3641ad9fa88964cf79b064ec4856926942acfca1ca2ad5
30aa6d017defeb82cebd568cb8ef930a83dbaa59b94ab78a43
eb371669ba2f70e346f1b38d313a0c1ab6a969d3a07766e10c
7c16fcbeff9af839fbd4dcc370adeffe99c1b11378493961dc
d08bc25b19bd30aed17a2c77da57e309de1e4dd0dd89198401
530f28a4ee33b92823274fe5240e2e9dfb280d56b3e888790c
4eaeae8c5aa74505a9b2d8fdcfede9dc63d5f4a7bec82db703
1625cce21051b347893eaaf924008f19a85a8cae045a0eb1cd
4a0b6eecb32e69fa218b3108d6963f30a366dc38ee2bd5fb72
c660b84d2d7a51154319ed38c06cb55d8b5ab357bf3aab7e2b
5bbdc68579c7f4b42b3549d8e054d5fbf5bb9637320f042a16
2dce8b8f0fedddc56d267f31136222c4e88a41b544d48a50c8
afb5ee9efb49e72ecbe2267ef4d69ef317aa4848d8863022c2
0a0b2e7b328f5b48801fd47b0e8159439d8c0ab8a5e71b6366
7d49a4430cd416de3ba56ad4285e5e6246674ab73af2352d19
7aaa8d4c855a3b1a10c4d20f8386c69b7b37d8dcc12346854c
57856dabdd45e52fa1d6e250c734777c5a183f3463eefda2a2
544a50a67b91d83844bdbe1af436bf86699b0615be105bb0e1
c71b06afb9a2c71bd7f5fbe48f49fbff3af6eb6e133feb3a71
773bb0bbf6de36fe8b5beffce44fe33fb93e71e7effbede8d4
eb8d67df39a1666357face8f1f553674182b2e8ca86bdffadb
53e8e0c9d11b6430b579aeece3a89e9ce3ce7ca85f39dd7823
052f18a87d45a4f366eaa9848e1acb1386dfffd56769c347e5
8d1a6ba51e163270b34540de69b1d96c09845b6bd3f7809a36
aadc6e08446a99f1f27ba943677cdd6dccd77f1eb9ff4fa3f7
fc65f4ce5b47edf0ba8ddcfdd711fbff3ce6a33f8ddbfaa7d1
bb7a4ddcfdf7b5878b232acfe3551517268cae18369c1615a8
418158ec65ed9635a8de535c0d65cb8ecea1404974b11fd74b
49f55268883ee0a07ecff9fae5d20d37a26fde18a3c39417e4
cc02b542274c22a420d3bf76cdf9814332c64f300eec15b65f
de568eda9b50d7196210e0eaa19b66ef99126e86290999d4ac
b5799901c561280f812f08be40030bd659f396161b63745883
c68a80a8f40b5f989445226521e237c0961d2491f19ae09515
17c68ff60d194a0bf363a5439d98c86e58f6fb868c0f79c471
2a79a41cfc3e21ada65c549488e27c5190230ab34451b6b2c2
3a2bca6edad262638c0e936f29b31052cf1bdf7d1b5cb5d637
715661efa1fec973c881038406b80c6b1c19f6a8b9232a828b
41c70cd1101fdc05e67a272a19a35a545e432ebb69d39291bf
5ae7c6f46492c67344a1ce9ab7b4d818a3c31a35aa659e5cef
14a4e6ab12b5aa983a7a73850a5fe6b85155c3efe0c545546f
e71a83aba94e6c0b5590e5fe4afbd081e2179fc97f704eea94
4967278c4b19372e63dc84f491a333a58d1e93317ab4976c4c
dac8f17949c37df189c57109e7478fa97af34d969d454dd354
fbf4a8e2830c772d4162b6b8dd0d531b9640948774d48c25b5
cf895e63c1f543226883fd0cbc6bd17dc9dcc847397abd7c5e
0ab4bc2c7df408ffc8d1505aa2fbe918e4296a0981cd48b593
9352f0e843a9fd7a660c1d9d7ad78cb377df9b3a6d46dad499
2953ee4dbf6746faddd3d3a6cdca7de4f1dc471ecb7f6c6efe
a37f6b648f34b0e68db1392ce7b1b9e7e62f28796169edba75
a17d7b842f5f3083c87e51449d14283d30edec915f8eabc3d4
91c3fca3940eedd8e8507d5476c4ce3c92357946ce80e4b2c5
0f5907bf17253ea8ad804035846aea4d046b45382002352214
10217f230b36b0e68db13a4cbe8da08884d586ac547a74a637
c4f666a1b31dd3363ab4401881d29cc766d6f41a69bcff9115
c925dc6f33c7d11b21daba9771cd12dc50eba9a1a15997cf54
92afd6fe5ba0561ada4469510518ad7e897ee3b48d0e6d1091
9dbb2afaf4aa59fa12319d3067324f626a11a0ae9a93fa8c50
958d395c2c2247db2e6f340384ca948e3b6ae5445d73ab5fa2
df386da3436e59fec717540fe84f724e38eeb46cbd94be6eff
c38ba6b6e864441b8d7ee6a07723e3acd140076fd6d8bca555
0ee33cba1162fd9e88bc1def00e059da488755bebc8977174c
9fcc6acb858cb328b5b9aa4634dfcb4ed517f56203bd8c85b9
c65a1a716b2bd3fb27bbc3e2e0ba668a8fc76a75da4687ac20
276dfc98f4b9f3206c32464ca8716460485adacdee2746d7e0
f2191551d3a33dc0dd8a3cd27aa8bb9c032bf39d1f36bc74dc
385e5aa636ae6eed9b5dbd626a7aeae04117e63e0641c3564b
aa4c77d277731d46df9697ace1405fddb420cc975b13b55f90
d461a92f6bf8a8fc3bc74b1d0ac7dd0dba35913a2467d2cf27
26e4ffed4111881055cdd60f9ec14f13d180bb17717965e19d
134bef9d2a2a2b518748dba3e7f102f82a8a264f299c314d54
550a1b5a3df8411d223f4f340bacaaca9b34a968e634515ba3
d6ffc4203e441d223f43bd0e73264f2a983d4df85187c86520
9a115655654f9994377b1a681db67a71ac5e8779a843a425c0
5dab5455952bfde12cdd2fd398e429f4f8b9f3897139cf3d25
c28473c6c05522ea105170771fb886f1618c7478e4647a42df
8c254f8b10538bcbd4631351874894b6d3e1a1e39903e3ce2f
5920c2a843a4296dacc3f4e79f421d22cd693b1d1e3e717e40
fff3cf2f1021b5a73b0722daefd3a490d60675887801d421e2
0550878817401d225e0075887801d421e20550878817401d22
5ea02d75988e3a447e8236d3213976ea5c527ce68b4fabf936
4088da0bb1754f82b463da4e87a7ce9d4e8acf7ee55911a14c
3d05cd896e8e8d206da9c3b3696792e3f35e7d1e758834a7ad
75b8e239d92fa30e9126c45a87f54f8a943a3c9d14972bfd21
ea106906ea10f1029745871c758834a6ed7478eefcb9c484bc
152f08c3014e6cbd5c1f4b37884b5bea3045eb104ca5434b58
1c7588d4813a44bc00ea10f102a843c40ba00e112f803a44bc
00ea10f102a843c40ba00e112f803a44bc00ea10f102a843c4
0ba00e112f803a44bc00ea10f102a843c40ba00e112f803a44
bc00ea10f1026da7c394f4b30307e4ad78511836806d0947af
4fc1855288a2910ef5f3a4800203d25aafdf4087678f2727e6
beb25c188623c21157ecc05aeb4448bba60d7578e64472428e
d6211161533d3dc57da81a82b4a10ecf9e3e33302167c50a61
5a4cad1d05c1dc932388d2219162a9aece9f3cb968e6545153
2d484ce2437afa545a627cceca1560da5c58eae1e35c0ad169
ad1321ed9a3a7fa874583ceb5ef739e04cb4be3fa4c78e660e
88cb5ffd3ab7657fec702e654899b05beb4448bb26aac38aca
8229530a67dcd3eafe506829aafdbebedc9f9d1057b3e93d46
9800a575d421528ff456048085aa7db366164d9a0cbe0a191b
525d4fd126dd19e73aad85e8b3ebeb0cb489164d3b41f905e4
cf52b505b143aad66fc8498833bfff9630ae9e772fcfc118c3
7e1971e1c224ccb24baa173d99376824c9bc604b95102912a9
3fd9794ae76513412cc189921dbd68a04db4689cb9e930a361
1e09b38028292b9c30ade8ce3b79414e04982d254ddd7c1941
14520a0e65600683dbb6a50c1a5ab6ed6d4243dc01c654fc06
dc1160ab6e54e6145c458d4d4cba33bb9951613311547ed491
2207cb0afa3fd87221f98ef297978b803f22752e5da53c29c7
2a36124576bb8c138b0a965d503a6e52d998613cfb2401ea28
8d49154a37c8a8ec97c1cd38687383666608d30643f6f7526b
10b6c8b747b3c7dd7574c27827239359c456ddb53c4afd2756
6d90289c32665780ec7aa9f1d6dbe57d7b173ffe382d2e96fe
8a12a6bca28e0e554151f6a4c26a66171d2180a9cd921120b3
a41fa516ab8e9cf947c9b8697989c3439fef151143058baa7a
cda4ba5d8f8a200a46397142420df7f24049f6a2b9790977e4
3cfcb49192224201b02dce897496361099e2322dc986c67536
e29aecb9a5a6a549318a0013b5d591dd9b33c78c48197647d9
bbef8a50adf4a88ed0cfa0d78e56ba4e1c4d415c54194fba28
1dabd932ef0854e42f7e2e37615856d288aa058bcc0f3f22a7
8fdab967c2c5678ce234273fcbc9cf6e68243fe7a2e55c20b9
594ed67972e248e9c6f51933a617f51d52306a4af5fe7db619
a02aa99181a73c9903c210aa84280003444423b3e0880aea88
1a65b3a597e23c5816daf65ef1b42969830665c52515f64eaa
ec9954db35b1b2474241bfb82656d82faea8defac615f6e92f
2d2bb1efd9a4de0577de55f3d24a9a95e3508710a664a83264
e94289ccd141972971de17524f339f04c01c56551c3cf0956f
cdaaf2679fad5cb8d8b76851e9e24525cf34b0c57556dfb2f0
ef658b16d6bef44270ddfae0975fb3fc5c6104383832cd6926
39f483c83f47e6b32a8d706c610684ed17cc4f20e0708333e7
678c1087528731d9f15a6086c08970b09974b6aa168ecfd243
fe7564e4a6aa3640655447b92a58cb9c42e9a9852a4dbdc954
581ec838b5388d08a95ae2a80aa48c0a01301044fe75a4eb32
050f0b080a11d6c56a95d9b216eb36cdcd94b1a6a55da01a0e
54a37cc2cdac2ff7af85b437d4809e23fb66954dab9c5a0f32
73d7afd5593da2696374f20415f54f48411d22bf04192072d5
a5aac9aa3ab355331504755477fdcf4df5e05c8d1f332d5ffd
82989a20ff323a3c54836ee0cedc57d121d5331d1a8c2d439d
89a68d0084aa274649dd32e28e07322cd12008822008822008
8220088220088220088220088220088220087249fc3f327c6b
430a656e6473747265616d0a656e646f626a0a32302030206f
626a0a3c3c0a2f46696c746572202f466c6174654465636f64
650a2f4c656e67746820333631320a3e3e0a73747265616d0a
789cc55c4b6fdc4612be0bd07fe071186428f68b64034100c7
769e70908d8dec61bd87b166accc429e91a55160ecbf35f610
78819c9cbde4b455d5cdee66933d438da82440246a5864d7ab
bffaaabbc7d9d90fd9679f9d3d7bfccd93acfcfcf3ec8b278f
b3b7a7276551e27f4d538baccc945685945923595135d9f5ea
f4e4ef9f649bd3932f5e9c9e9c7dc93251662f5e9f9e30102d
3396b146164267b5e48592d98b3720f4d5f33abbb8c1f7325d
6565514b9d99ebeb0bbadd246efff8d5e9c93f665fe673315b
9fffbcc872395be21f2bb8c8be861feb9b7c2e67bb8ff95ccd
ae730552dbecd907b8589a67b6f93fb317df9e9e3c055dff76
7a7277db6451361df354094ff0d0bc61ab52c664a8181a92dd
4b359eb132564d705e80661c06358a65a84746c3327696cf6b
f8957339a34b5e7235bd0a555d34291d228bb3a7cf1e675990
81ecb80c1cd443aaa2043dcaba907757844fae48a565c1efae
88985e91a62c1a716745a455a42cb4a8f1b99a17ba919962bc
28ab8c37ac6055c62a78b922755e7f62dff23690ad0be64415
64481d681e8ea6ec68750d734c6695d44525320eef2925e04b
c165778cf0d9cabb6cd4b8ed4c6755ecb17674255c0edd69a6
7f93f372b6c9e7d5ec3500d236af09a1de2c7e45b0fa1ffcb9
ca199bdd6400559a6e1334fc00d0b0c08b7342309425b90d08
eccc5ffb43554fe6002e545137c73ba08f7043fa3651b07150
e6822d0acdd3c1d6c7daca07232d9aa1b9f12cd7101109d183
509ec3c5369f338dd1d2b317f9bc99fd7199b30642259af0d6
7241200f575fe6acb27736981337f042ac60e7146a2b74101c
cb696ce56589d14cd83a2e648c453183c2538a206616930663
c6f8b441e3b2d0ec5843446448d914a50e934fee811a268fb2
84a72c01d0d6fd1af1829042ce2e57af730638b2710408d3e6
c7555e5142ad97061ce46c63d003c811e0086733cace83e9a5
a6b18535552158ca969151a9ba5151503c251b9b5e47e3df60
5094ae0bae7b86bc9c211830f632c7df1409dde8521ff27233
8d724c9445c552cacd0f6931116c3260c7954e6921346b0ef1
ac89308da906312da1c8b8a4e311a629204a528fac437c5a4c
538dc0f01e69488469aaaa8a66ecece1d3429aaa742155cf90
a700698452ae99bb86fff1f7af545e0f64cd5450c52b4c9784
8e239d1d4395e245333a6b26862a050cae9f353f01f1a8819d
4011a04ae01887e13573a829583f3cb1d951d55861a3f8a961
26f0e351cef9ec17642f85fbec5b78ec77436bd69d37f3aa3a
14c389809033a8fe29cb478650472114bae063e78b9808c1da
b12547fe111b42cebf327121074bf5e850e7c8268256a60b21
528a0d7a78509d16208552a0846d1b59051ab154dbd88aa2d6
ade4beae51083706f48b55db363255175a1f6a1b45007c6306
4e774dede80fdb350915196bdaa6d6d8fdc023aa638ced01a8
1bba29543f379e2c76b836b730cd5087b47ebfb8c196f6fc50
0ed793a82901e70193136a8e747713b9db743cdedd7b41421f
995bc3ee1e6e784a7556d667e866a6d521e225cb4934928c88
f9bd5a30c922cf9a162c48e47d2d98e493ba963184fe230d89
e0c7762de352441e053fa9198944b8ec539a1f70d2e124c47a
7f886549358d460d141f99d268a467abc8b3869a8fc33a7914
88a43224c1ccabfa90379b69b4a8d91e2d467a5347de34fdc1
b83c55470147324fef43bd55041c967a8fcb0a75146e24ed80
37d4fdd58e4797c89777b842700bdc4d4097c371c56f7faa28
318d6a5aa05c42b5912e96918b0d351e992a47014872e20d13
50461dcac1e9a78e223c7d5d00785492a58f26c3aa85246677
524a60a615ee9cd5b8c10275c879b50c2590c73323813f4a68
795a394bf1ad88e5f8b150bc796387b4d20adb9d569434134a
162cd44c69087b47ae0ce59c7e24178f6efc6e85ace3931a5a
6133b215ee2ba870c39387ae2b718babab5d2be4bd8742fb7c
a3ca60638b179004fda16d4cac18c58481ce4d27244602bceb
82469e190aee1e31d7beb1220c6df755de71b2a8b86fb0804c
d5e9d07af5e96d91056547d2ead7c6b6337c3ba7581186b623
12062cf01ac6221ad609b51eb1f1eafb6e94647ffa05b5f86e
a701a017d651df6ea22735d49e8a10c1dcc106cf5c0d36757d
9df4f43a415d97fb747a4a6b3f6f72b361c567e7b4ed78930b
5c0752e633b3a9906123b7027161c457d7f8f1455ecdfe4b1f
6ee0ea7cbde8e1df7d2de11543130e5a32e45dbfee21907b36
19af755143b2284819995842a8facb39079edebf9e23c156d9
ecdb51e495d938746b678fc1a3dcafd4d1a6a3bb39bca7d8dd
4f8c83702f3b9866b84d98b0631c8ba8fa4b51f7732a87dfd5
b1caf457ea4729935ae196c882e49d36edb8364470e5d65e07
f7ee2eef15c9fe6a3788632487f51de93c316d2485d658f0c6
6caed5923713a7b6d9434be8309f7a30da2a4b0c56378c4f3c
9ed9114b8cb797a9124516c8b9edd04822943a009c9df58b31
4f1bc5459fee3758d21380f313ae60ac2f71922cec1e06c2a3
dbbfd8ad3ec5a36d76c762dee08e85ecec58c8d9ef1ba854b4
233eb453715ffda596c87ec601667f82a989dd380c95e49aab
1d7800dc291576a98fa675033ec5c448a81ef44435d0234968
f145dc22794ae0a4ea42c8bd5cda8ad849354855058c55fb11
fbad8f1fb7156d874d506472a795b2eedc4792bdb1dda6c68f
eb049dbd43fc3774a0d0b4a9653c5816bc92a1678c04c3701f
ec57f6c939e4620172ed71b2d78a2422c5ca50b01d749f8bad
d4081707ee201f77077642ced2438dc801d17e92d7c7b27eae
12ac1f0fe0aa3b70e529466ea863beebc87d6f4cdf9709dcf3
39620feeeb35b64178ac9c18b839496eb8089f3dfb608f2ea8
cec75fad0c57eff3b629da207dbc31fbbba386178a1011d850
9d71d04ab15491ef9f1b3af0b4b349f402641920b4ee62a84e
ce9bf6876e2f1204e96815200e823729159e6c5718e14dceea
d90e3b6056ce965b52e50639c60a93e01ddec50fb96da46d0b
0df7e9f8eeede51a49fdf65367cf7265ceffc325688bbfe811
1a664b0f7ad9761ccee0e5a29eb5e29cb56a9d9bbec17db25c
85776f2cef815a4f83ecb05f94d85bea19a43634901790c037
03a74fdf4ee5631b668ebeeeb9188f43afda238ada5efe82ba
2f7a66b45e21478b48026c69cc83abc9b384350d9d471eb420
d9251c3f9c16f84581e1e17ce2f9cca1cfe8c71a9db8b141a6
6c7c4f51a7bfe926e5e4d63fbbfb60f2fadc74a7734121a1bf
166e942063599cb03e57e9430aa319ef16efe3dbfc8bda4c66
3629df520ade9ab0b5423e275ee75cd84bfba178f03405aa02
653c767b30ebad59c89b2fd6ded1e1b44369157acd8769b7c2
8352b5f9a4e3bbf6e9adb7ffddda014aebbec8916e1a5cf8a7
ccb706dee08121ab9455089a6a356325f9fcbb0b5c9430b329
401ef3c11f411403139d0800d74387a112d843c561683d2d82
7940572f7330ad987e2af212f7ac13da8c5b31a9fb0b8af7f6
8eacf1e8c95f5932132a7c8d59f5dea5e95854a9300303681f
0ab19f2cfd6ff4ddd728ce05eeea25fd3afd7835eea824c65b
6e570e5f5bded107451162227a857eae37bfe1c43f27d1b599
f7eb8d457efc68e96b8199cfdb38184b42208f5baf965b828c
37446416be5a3f340608ec9e7adea1a1b76d2ea12e6bb4f8df
2eb9966d8af5a0ad53708cacad4f8492015bf2487f655d8d78
6fbc46af70be8f72f36a4b4f1967b721213435148514a267a2
0a10d4e8ab904e9a5cb0ac6e7d9d37f1837d8af8b051611277
5ae3a89066aed82fc947be7afd8a3ffee3a9874fb601820b96
538efbafc05942d3f5799cb6867efc0639fa8b89137d7a4633
c0d6c8809074696658c177dbc2ee7d35b347b648f62785e75c
5b3bb1acb1fec5538386944043552a00d3f350a9047e8f2731
de10117de0d4631a1cd03f74e16793fdbe64cb110c10042972
e532c8d0605f9ea2acdcbe32648d90e52a4ee1c2cdbdef5766
17b4859336a5b9ecd2c4013216a84598f09eeede3a7858393c
f3539d12ebe3f48116b25075cabd3437d63b5c5b0fb1ee6123
0d2fa8fb84eb67db28b433d64cb7b0ddf173d37b6de0290729
dd062498c6d15b0262d2ed55372ef6d1a8be4cbfea160c2ff2
2a6eec4d569a62eb21acafe3bb85af54419ead37efaf69333e
32c29226f796870e5e550d1d4d5c6f76f40d1fd7099982b7f1
8124b5e9de03307951d311c761dd4632f9fe2ef6bd7d050faa
bf96c9275488983c6513e1e7f6dd3a9a6fcb7e110da92b0fd8
cc7e62bfecf2371c95d9ab207b5a0a0520bb7e0dac638da756
548f6304af49325a8236a4b4e69b51facf013780db8123af66
f207c6dd065d7867f65ab2df62d207727940b9e2359e687dc8
ae43783ada06cafebb0358862e3dfc3c73e5159de8662dfef2
e8f2e832883e8d12b83f5ee589968cae3efaf704f0704b6fd9
3e74305853883ebbf10b5cb6c7405e39bc8cd6016dc76043ae
ea63b9583e40ef5ad6b8359030c4bb3668dc76abebbc6d96e2
156763d4366878c2296d92d1e7e1954b8c45172a62d7f8bee7
f672d7fefb16318527cce955ea60025cfa06ec225c1b7bd814
29f9d017171ee3ce10e5c5c62290c51a6f0a11c5e7b93417df
9aca065781b7dd9abd75c1875e67240cbfbc5d2f43e2487783
e7b8a0373346bf78592acf529fb7c87971bbb1eaed5d4ef0ea
b98f7a9df69f47271a45dfff89ddef375fbad547f452be3b8d
c180de3c8ea680d9b7c1a7fe6572afeb8b388b97e10a8adff8
d96e7e0ed66323c7ae5c613373d117dad0e5a2bfb661c67ae5
c1fee3952d85dda5e23635469e47aff9c0590bc1657b2079f8
38bae01a97b1f69e00302236fa899d78b367ef461b3cc16d65
dc8087ce39d8ec21ddb8acf01c4074cea1ae283183c3f4fc8e
2268a015f1067684acde81327837d2a715f283f9e3e9fd57ed
97ea473638b037b7dbd075c5717f18ae44a95893dc8f06b5b5
a2d908571554975a1722ab1a814726cef19f75fbe6cde262c5
44f6649bb569f57fca728d820a656e6473747265616d0a656e
646f626a0a352030206f626a0a3c3c0a2f54797065202f5061
67650a2f4d65646961426f78205b302030203539352e343420
3834312e36385d0a2f5265736f7572636573203c3c0a2f466f
6e74203c3c0a2f46312038203020520a2f4632203131203020
520a2f4633203134203020520a3e3e0a2f4578744753746174
65203c3c0a2f475337203137203020520a2f47533820313820
3020520a3e3e0a2f584f626a656374203c3c0a2f496d616765
3133203139203020520a3e3e0a2f50726f63536574205b2f50
4446202f54657874202f496d61676542202f496d6167654320
2f496d616765495d0a3e3e0a2f436f6e74656e747320323020
3020520a2f47726f7570203c3c0a2f54797065202f47726f75
700a2f53202f5472616e73706172656e63790a2f4353202f44
65766963655247420a3e3e0a2f54616273202f530a2f537472
756374506172656e747320300a2f506172656e742032203020
520a3e3e0a656e646f626a0a38312030206f626a0a3c3c0a2f
4f72646572696e6720284964656e74697479290a2f52656769
73747279202841646f6265290a2f537570706c656d656e7420
300a3e3e0a656e646f626a0a38332030206f626a0a3c3c0a2f
46696c746572202f466c6174654465636f64650a2f4c656e67
7468203130393039300a2f4c656e6774683120333634343630
0a3e3e0a73747265616d0a789cec9d0960dcd49980ff19cd7d
6aeedbd61cbec6679ccb712e278e9d134862436d1aa81ddb49
8004524829b440d3162835d0424befee927659ca428f4942db
00bbdbf4e40857b812689b8384231c2dbb2ddb83c2ecff7e8d
27137b703dad6dd9cefb34ef97f4ded3d32f8df44befd7d313
a80020804203b72c695bbeb4eb67e72740fbe123009147972e
69697de1c1430f82706e1840285fbafaacb6277f76eb63209c
b70454df492c6d3b7bf1378f198f8156b30960f36b2bdada5b
b7242fd0e1f2ed586ad1aaf6b6659bdfb8e7228045cf003870
e9da7adf256dd700a8fd98deb5ba79557be7d39f3c0642e771
9c9f75ce92333ace8c6ffa14405b02f3dfd6b3a57bebcf6fea
990d6a4d13aefff19ecbb749915ef50150c730bb78ed86ad1b
b76ce90cb581da2002983a37765fb6150210c5f29e6119366e
be728376e3adef82bafe5a80e7afd9d4bbe58a85ebbe772f40
ef1e50dd7ec3a6beeede136bbfd907a0fa265bff268c709de1
fd18ceb3e5139bb66cbbe287e72536a2be57002c5c7751dfa5
17bfbbee9db741a8d981793eb6f9929eee4d17d4358060d100
c4bebea5fb8aadfe2af13e4cfb332e2f6de9dbd6fdccd75eb8
08f7c7369cdf7c71f796beeb9c6fb941a8c3fd59f1a5ad975c
b62d9d805ed4f75e967feba57d5b77d77fe156503b3703d8bf
08ecbfd1bdfdf3a51b5e4e7ec83eef6d43c0008c6f1f8bfc8c
8d9fbe6881f69d6defde249e6f5883b346cacfc0b13efa5e0b
7c408477b6fde529f1fc6c4a06db7a16e358053782081d2080
1ac74d703dae6e06ae578da9823053750b68c1a0fdba763a16
59228f851db041ed5469d56a9da0d568d582e608d4a4f7c215
1f240d90f6339a252c4b7a47a3bde9bd56d5747d54f54013a8
d2e9342e7d9b7615db52f0e8e6a8c22cb77a20dc0dc7852570
1de401d3da31d464e7012ec6f9361cdfaa9e0302eefc1518de
c25085a10d8384613d860e0cab305c85610de64d61f85cbe75
681fc43dc0c6e7c00a9c8e6b8e4152731944717a199bc7f54d
172290c4e918a655e82310d33e987e89a563bed8403938bd1d
d31760bc198333771d181fccb76e8670332cd740fa1d1cb7a2
ae4b70bc0ad779164ecfc76045bde7a9e7a47b68fbe7c07cdd
1c70603c3bf05a70b9bfb06530bf1575ecc57437ceab313868
bd00219617cbac78bff5bf9f4ef9e6998e4cbfccf4aa8c4ef3
062fcf741b3cd6c87ff788d1b9e565691d77c31b852c3b5ee0
3e6866e1fdd255e7bc774fee3c1e23010cbec165fcb37ad031
7237056f36ee6e3891193ff0cf96cfe14c5434cfc22ea575e0
70389cd301d55de9fb95d661a468439347570e87c3511215a4
ef37601081db4d0e87c3e170381c0e87c3e170381c0e87c3e1
70381ccee8a1f9296cc8173fd00e96c3e10c45f575a535e070
389cd3837cefbe4c7484a3b058fd6bb858f8192c163e09f5c2
539010fa61067b674a78059a850370217b674a330736aa7f0a
abd9bb55c21e3893bd5b85cbd2bb55381fcb79b76a9ee659a8
d03d88e12ea8d06c80b8ee4e1cc7c0243c025ecd5258aeb903
82c26d3053f810ceefa679bfda0365eacf4358b30dca84fd50
a60d629977804bb31d960b778149331fca3445e055ff11ce40
9d6a35d78241630313db064c0b6b9c9467f6dfdb5ea647ee98
a69766de67623a611888673a0d591ef51908d938d4e51ffe03
fe01f2e9c599faa8cf011f862b313831ccc660c13017431443
3c13171d693e56a6410f0b94de2e0e87c3e18c368e557a954a
b57113cde87400bef30cf38bb22c95135ac0d6e45fbf74415f
5f4f9fbfa9a91360ceda26f61672b75c4afdf90b97ad3cdedb
3e77172cfd43fbf9e79f5f1b9bdede0d3d0ff6e5ac4a4f418f
3ff966c8c086dcdba245007f1a91d2bfcfbc2ccffa2ae863ab
f8ebe01c733f849bd2079b0ad8131389979556600aa3fafb59
fe81ac9cbf035a19a555e070381c0e270faa1c39f9992adb31
11995b486655026f7d54452a59d250343750a229d614638c5b
55a19aa6aaf6517a5ca59254b9774ac538e03fe976034ca3b2
589234cccaa6fd631b344aa8f2c00f44cee98400021df75a41
50a9f1f0f76bdf30ef853f1bd2ccdb917e0f8c604269226906
73fa5db08005a595a40dac28ed28ff0622d8513a483a4144e9
42f90eb8c181d2034e945e70a3f4a1fc2bf8c18332003e9441
9221f0a7ff026108a28c902c8210ca6208a39450fe19a21041
198362947190502650fe094a208ab2146228cb48964322fd7f
5001252893508ab212ca50564179fa6da8860a94359044594b
b20e2ad37f448b5485b21eaa514e2739036ad37f8099508772
16c9d9300d6503d4a7ff17e6c074948d3013e55c92f36016ca
f928ff0716c06c940ba101651334a25c84f22d580c735136c3
3c944b603eca1694bf87565888722934a15c4672392c4aff0e
56c062942ba119e52a5882f20c6849bf0967422bcab36029ca
d524d7c0b2f41bb01656a06c23d90e2b519e0dabd2afc33970
06ca0f90ec80b35076c26a94e7c29af46bf04192eb602dcaf3
a00de5f9d09e3e011f82b35176c13928bbe10328d7a37c157a
a003652f9c8bb20f3e887203ca576023ac43b909ce437901c9
0be143e997e122e842b919ba516e217931ac4fbf0497400fca
add08bf2c3d087f252d8903e0e97c14694db487e0436a1bc1c
2e40f951b8287d0cae2079256c46f931d882f2e37071fa45b8
8ae4d5b015e535f061949f407914b6c3a5283f0997a1fc146c
43f969f848fa085c0b97a3bc0e3e8af27ab802e567501e861b
e04a949f858fa3ec2779235c953e0437c1d5286f866b507e8e
e4e7617bfab7700b7c12e5adf029945f20f945f834cadbe0da
f46fe04b701dca2fc3f528bf029fc1a5be0a3760ead7487e1d
3e8bf21b7023ca6fc24d98e75f48fe2bdc8cf276f81cca1d28
7f0ddf825b507e1b6e45f96ff0059477a07c01fe1dbe88f24e
b80de577e0cb28ef42f93cfc077c05e5ddf05594f7c0d730fe
bb24bf07dfc098efc33751fe80640afe05e54ef8d7f441d805
b7a3dc0d3b50de0bdf42f943f876fa00fc08fe0de58f49ee81
3b50de0777a69f83fb493e00df41f99f7017caff82ff483f0b
ff4df227700fcabdf05d943f85efa59f819f91fc397c1fe52f
2085f297289f865fc14e940fc26e940fc1bd281f26f908fc30
fd14ec831fa17c147e8cf231d883f271b82fbd1f9e80fb513e
49723f3c80f229f8cff493f034fc37ca6748a216289f83bde9
27e000fc14e54192cfc3cf51be00bf483f0ebf26f91bf825ca
dfc2af501e8207d38fc1617808e5117818e5517804e58bb02f
fd281c23791c1e45f9123c8ef26592afc013e97df02a3c89f2
04ec47f91ac9d7e1e9f423f0063c83f24d7816e5ef48fe1e9e
43f9161c40f93f7010e5ffc2f328ff002fa41f863fc2af51be
4df2ffe03728ff0487d20fc19fe130cabf90fc2b1c41f90e1c
4d3f087f23f92e1c43f91e1c47998697d2bfe236fd34b7e9af
934d7f9d6cfa6b64d35f239bfe1ad9f4d7c8a69f209b7e826c
fa09b2e927c8a69f209b7e826cfa09b2e927c8a6bf4a36fd55
b2e9af924d7f956cfa2b64d35f219bfe0ad9f457c8a6bf4c36
fd65b2e92f934d7f996cfacb64d35f229bfe12d9f497c8a6bf
4436fd38d9f4e364d38f934d3f4e36fd18d9f46364d38f914d
3f4636fd45b2e92f924d7f916cfa8b64d38f924d3f4a36fd28
d9f4a364d38f904d3f4236fd08d9f42364d30f934d3f4c36fd
30d9f4c364d30f934d3f4436fd10d9f4430adaf4af666cfaf3
ff904d3f4836fd20d9f48364d30f924d3f4836fd20d9f48364
d30f904d3f4036fd00d9f40364d30f904d7f8e6cfa7364d39f
239bfe1cd9f467c9a63f4336fd19b2e9cf904d7f866cfad364
d39f269bfe34d9f4a7c9a63f4536fd29b2e94f914d7f8a6cfa
7eb2e9fbc9a6ef279bfe14d9f4fd64d3f7934ddf4f367d3fd9
f427c9a63f4936fd49b2e94f924d7f826cfa1364d39f209bfe
04d9f4c7c9a63f4e36fd71b2e98f934d7f9c6cfa6364d31f23
9bfe18d9f447c9a6ef239bbe8f6cfa3eb2e9fbc8a6ef239bbe
8f6cfa3eb2e98f924ddf47367d1fd9f47d64d3f7914d7f846c
fa2364d31f219bfe08d9f487c9a63f4c36fd61b2e90f934d7f
e834b2e995dca6739b7edad8f4affd5336fdc018d9f41f709b
3e0e361dd0e28263b5d96b0441d068c94ba3d100081a41d065
11044a3080dea0d7e90d1a8d416f3218f4005a92d47a05d132
345a965d30e2625a8d06e70027727c405a0a5afc0195aa6343
6e06037de260040c2cc5be84c05ae78076700e81366584c54d
3cf44a2b308529e0f319fc6f183d5466efdfcfc4e170381cce
b8235fed0585b5182d0afa4a18a7200a3a46b05e84e8f0a7d3
e8b434e804bdd1a833b229162d60bc5ec7e6b0d2c46a4dba81
655915097f5867ca549974343f4a9a8d3a421ec0aca84a1cce
7862f18fc49f620483518f3640a335ea2d46235e797406237b
e927f3e20f998993fe143d1a060d9efa6825725695d79f929b
c138cafe140df7a7708650c08dc6b8beed3fc5515bfc4aabc0
e170381c4e1eb83f8533320a3a46325e1486265badd29b4c7a
134ee8b55abd5ed0e87506bd9e1c2efa61fd297abd7ef8ca81
b247af260f605154250e673cb1064dcc9f229fc1197f8a26c7
9f227b244ce44f31e4f853f4a7f853d00ce8751ab40ccc9f82
27bd5ec3e640abcf7574e82830076cc638c8fdb29cc434627f
4ac6e0b06b069530d49fa29dd4fe145e911f3b0ab8e4f0bf61
f4505b834aabc0e170381c4e1ee4abfd64bd651ccc54f10b4d
440af3a768337529562b1aa85619cc66bd99b5f8d7690d06f2
a7b0f6ff7aad8e755479b252c4aa48f863f59d49eb4fb12aaa
1287339ed88b2c781a68658704f941b51a8d3e4bc69f620693
d9683099b53ab3d16a361bf1e26334b3865c46b914caab95fd
29669a267f8afe94f629393ddbe6f7a79847ec4fc92cc58a31
301586348113d8a64c5e7f8a516905a630055c724c7f3f0b67
84a8ed454aabc0e170381c4e1ee49baec97acb3818ee4f193b
0adab7ac5e44180cda6cb5ca68b5182c06bdc1a8d7b156ff06
bdc98873061d06309cfcdc07fbf807eb6c419f392e2969b8a7
7cca1ebd79fd29764555e270c613511ae44fd1e8341a4396ac
3fc56c361acd66adce62b4592c78e5319eea4f4163a0d790fb
4530a34d308cc49f425f0acaf5a758f23434c9cb40fb14560c
7964f2fb53b493f6e2c8fd296307f7a728825a94945681c3e1
70389c3cc857fbc97acb3818ee4f193b0adab7061dab1c516d
4a47630c82c966355a0d06e3402f0a06134eb20cc6a1fe14e3
497f8ad1681cbe72a0ecd1abcd03888aaac4e18c278e98f5a4
3f85f929343a3cbdb368b3fe148bc968b168f51693dd6231b1
33dbc2fc29991aa75eb61606d6398a156d8241a7d71af46038
c55d22fb53980356769b18d990eb6cb58ed89f92d33ec5c454
18e24f61fd3a4d627f0aefc369ec28e098e07fc3e8a176c494
5681c3e170389c3cc8f7b223bb039df8707fcad851d031227b
518ccc79a2331a68306a4d369bd186532683de6462fe14b3c9
c432184c46d96922c3aa48acf3ca812f7598586d67b8a77c13
d09fe25054250e673c7195daf134d0c96e0d7242e8b439fe94
4c47b556b05acd669b55a7b79a45ab0deb99668b95bd1897a9
71a219301958cb350d686c463ceb75062c042d43aebb44ee6f
85396065ff87890db9ce56dbf07d579f64a0d8ac3f654813b8
4c47d8232b6ee2c1fb701a3b0ab8e4f0bf61f450bb4a955681
c3e170389c3cc8f7b253c59f32591f254e060adab746bdec43
c16a913e5bad328ba249c44a93d96830532f0a16b39932984d
b2d344865591f0c71c2c745c9ad94b01c33de553f6e8d5e501
5c8aaac4e18c279ea478d29fc2da9569f5787a67c97c49c706
36bbd562b7eb0c768bd36eb7307f8a9dbd1897a9711ad13418
f52613eb6c563499d1301874cc321873dd25460acccd22fb39
ccf41a514e0671c4fe944cb1ccae59725e3b3a894eeeb869b2
fa53781f4e6347011743fe378c1e8227a9b40a1c0e87c3e1e4
41be979dacb78c83e1fe94b1a3a063c4c41e361bb14ec4baa0
35d160d6599d0e8b03a72cc64cab7fabc582f10693c52c3b4d
645815097f597f8ac56219fe29df04f4a778145589c3194ffc
752e3c0d0cb24794b52bd319747a4b96cc9b350e101d76abc3
61303aec1e87c38627b54d14819a9430cc161c0c660bf3a738
d97206231602f466501633c81db1a02083646143ae71708ef4
43c1968cc161d70c6a2633c4c4e8581316fda4fdee30efc369
ec28e092c3ff86d143f0d729ad0287c3e170387990ef6527eb
2de360a64a3b9b894841fe148b913d98669522abc1c2c61874
76b7dbeab698ad36b3c966d319ac66bbcd66b65a8c169b05ac
96ec733c5645022b3d75a675da6cb66c9deb9fd76cd4d1e701
fc8aaac4e18c27a1591e3c0d32fe14e607d51bf5065b964cc3
1517385d0ebbcb6530b944bfcb85f54cbbe8620db944b91434
03368bc162c3d3c7e066cb194d066619acb98e0e0b05e66691
2f5a3636e41a07cf88fd299962d93523b799cc49f46c530c93
f683b7a2d20a4c610ab8e4f0573f470f21344b6915381c0e87
c3c9834872b2de320e86fb53c68e827c6e5693d562b5d8ac56
d6658a95069b5ef479ed5e9c122d6651d41bed568768b7d86c
26abdd263b4d645815097facbe43ebb4b3dace704ff994f506
1af200214555e270c69348a3efa43f85bdb877aa3f25d3d5b4
1b5c1ea7e8769bcc6e47d0e316f1e2e3f4b0865c991a27f3a7
588d5696dde0257f8a190b019b35f78d898c3fc50a56f9a235
c49fe21de9876d061cb8ec9a41cd6486f8530c6c538c93f6e2
c8df391c3b0af0a7f0bf61f4d0441a955681c3e170389c3cc8
f7b293f596713053e5bda5894841c788cd24fb506c76bb89c6
180cce805ff4db6da2c36a61adfe459bcb215aed76b34db4cb
4e13193b739e88d4069fd629b2da8e385a9a8d3a79fd291145
55e270c613a92980a781597650b0766506139ede59323d9578
c1e3733b7d3eb3d5eb0afb7c4e00a7cbeb836c8dd326e260b2
db59e7283e3b2e67361bedcc32e4ba4b6c14989b45769b886c
c875b6fa47fa85da8162993fc5c12e83435cb6f43567d3a4fd
e0ad5b6905a63005b8f0f9df307a68a426a555e070381c0e27
0ff2bdecc89ee84d7cb83f65ec28e81811cd769bdd268a76d1
611659dd0883d1150a39430ebbc365b3b256ff4ebbdbe5b43b
448bdd298243ccb68b7630279f839e3a93a7c4e97452b708ef
8bb2fe14631e405254250e673c892e0e0ef5a738b264fc293e
f0fadd4ebfdf6cf5b9237e3f3ba93d3ee64fc9d438ede44f21
f78b31c0fc30668bd1218228e6fa53ec1406f953725fa9088c
d89f92f19fb06b06b330dc9fc2193105f85378575aa38726ba
586915381c0e87c3c9837cd33555fc2953a51f98894861fe14
0b568eec0e517438cc0e1c637018dd61e64f119d2ebbcde532
9a9da2c7e5c2788be87280c371aa3fc549f51d5aa78b75b230
5cab69658f5e531e20aaa84a1cce7852b2220246a3597648b0
f7f48c66a3c995c5287b24021008f95cc190d91ef4464321ac
67ba7d21f6629c572e4574e26071ba983f25e2723a5d169bc9
e504a743cc59954841646e143aed9d6cc8350ee1e1bf057692
8162993fc5cd2e83433aba30b24d314f5a7f8a576905a63005
b8f079575aa387b66485d22a70381c0e879307f9a66bb2de32
0e86fb53c68e82bc164eab032b47ac52e4b6ba1c2e270697d1
5b5cec2e7639dd1e87e8f5982c1ea7dfe371b85d36a7c7056e
57f671aa8b394fdcd4069f8e4b0feb6461b8a77cca1ebde63c
4089a22a7138e349b23d8aa7814d7648b07665669bd9e2c992
e9f9b508c245415f51c42616054a8a8a7c00be60a408a84909
c3e5767a9c568fd762064bd4ebf678eca2c5e3068f2bd75de2
a2e0646e142ad5cd865ce3208df40bb5035e1876cda0663243
9ac059d8a65827ed076f834a2b308529e062c8bbd21a3db4c9
76a555e070381c0e270ff2bdec705fa39d4c4c957e60262205
1d236ebbdbe97679dc6e8fd7e671d3e0b10412715fdcebf6fa
5dce00b5fa0ff9fd2eaf5774fb3de0f5641fa77a9993cf0bac
1a454f9afd7efff04ff946f63c7aacb0e401928aaac4e18c27
35eb12781ad86487046b5766b15bacbe2c999e5f25288e8683
d1a8dd190d5744a358dd0f462409a84909c3e3737b5d76af97
7dbc27e6f5fabca2d3eaf382cf9bfbe28a87829bf95cc92031
63419db00c101fa93fc59329965d33988519eab2b5b08e596c
c37e5a6c2213565a81294c012e7cde95d6e8a1ab59a7b40a1c
0e87c3e1e4417e7a32591fc10d66aabcb7341129c89fe215bd
6eafdb87b522bfe8f3f8bc187c96705969a0d4ef0d843cae50
c8620f7a23a1a0c7ef7778833ef0fbb21e133f739e0480b54a
a1750683c1e11fb62aeb0db4e6016a145589c3194fea7bcbf0
34106507056b576675586d812c36f9f2128768a2389448385c
f1a2aa4402abfbe1e2440258c315c28ba6c16b0ff8993fa5c4
1f0c041c2e9c43cb90fbe28a978297b95164e3c086404e86d2
e1bf05769201072ef3a7d06b4743fd296c53ec232c6ee22129
adc014a6007f8a34664a9c7ee8ea7b955681c3e170389c3cc8
f7b293f511dc60a6ca7b4b139182bc167ea78f558ffcfe40d0
11f005fc180296a26432940cfa4311af2712b18a61bf1409fb
8241a73f1cc03a51d663c2aa4810627526d9cf170e87877fd8
aaac37d09e07a85754250e673c99b53909369b437650b0be5d
6d4e9b3d9425d3f36b2924caa24565650e4f9954575686579e
48b4ac0c13329d0df9433838832cbbbd822de7f4d843410885
72dba6f929f899cf954a0db121f7958a8a3c1da1e465c081cb
7cf011d688c03738879d6d8a63d84f8b4d64624a2b308529a0
4924ff1b460ffdaccd4aabc0e170381c4e1e249293f511dc60
947df3636a53d031127405fc417f28180c455ca14028882164
8fd654175587839162bf4f2ab6398a82b1e2a24024ec0e1685
2012cab68b0e33e74984dae0939fafa8a828fb0c3b2fca7a03
c53cc02c4555e270c693c66dd560b73b6487047b4fcfeeb28b
912c7691122aa02c192f4e56b87c15b119c9a484179f7892bd
1817974b0946707086c398dd5e19c6e55c3e318cc6209cdb36
2d4821c87cae6490226cc875b6568dd49f12ca14cb7cf0f4da
d1908e2eec6e17eb556564c54d3ce24a2b308529e0e102ef4a
6bf4d0376e535a050e87c3e170f2203f3d11955562d4982afd
c04c440af2a7843da1403818098723c5ee482812c610b1c7a7
d5497545a1e258d01f8bd95d52b824160d151779c2d1081417
150f2c5bc49c27c5acce24af331a8dc2b01fcc51d61be8c803
342aaa1287339e345f3f034f03b7ec9060edca1c5e872b9625
d3f36b2d54d755246aebdcc1dab279757558cf2c29afabc384
72b994a258512ce28dc65c2e70ce884563316fd0158b4254ca
ed81a288421173a350a95136e43601a81fe9176a2319172df3
c197b04aef908e2e5c6c533c93f6bbc3154a2b308529c0855f
39765a9c76189aaf575a050e87c3e170f220dfcb0ef735dac9
c454e907662252d03122f98b2352512c2ac5e2be58714cc210
7395cf692869884b89b2a2306bf55f2255969516276201a934
0689586260d9387bb29a00d62a851e0d97969652b708ef8bb2
0f90dd7980664555e270c693955f6e0497cb2f3b280201b415
0197a7348b477670cc84fa5935c999b3029159d5cdb366613d
33593d6b3626643a1b8a96e2e02f61d93d73d8728188a7b404
4a12b9bed428852873a350a9a56cc8350e7346fa85da68a658
76cda8a8803c2e5b0fdb94c0d0f7802609b54a2b308511479e
b56eac74380d31aefcb2d22a70381c0e8793876a92237ba237
f1992aef2d4d440a3a4612a17834112d2d499496074be3a509
0ca59eeaa605150bca12e55531a9aacaed4f26eaaa92b1f2b2
7022590ae5a5e503cb96e100e5108b81fc6838c95e0a18ee83
39ca3e40f6e601562aaa1287339eb4ddb9083c9e90fc8209eb
edc813f2f892597cb247622ecc9e37bd66debc70745efd8a79
f3b0ba5f3363de3c8081ce864a9238842a2a7c7ef02dacc0e5
c292afa2022aca73df9828a150823fd9cf9164436e4b8c8523
fd507022532c6b6a50cd2e8389c1397c72c74d2373cf4c3c78
1f4e6347012efc9963a7c56987a9ed4ea555e070381c0e270f
d3484ed647708399acafba4f060a3a46ca8bca12e525c9f2f2
64552459962cc790f4d5b7b6d4b4549655d595c4a7d5794335
e533eb6a4bab2a8bcb6b935095ac1a58b6923591aea236f8d4
c3656d6dedf00f5bbdc3a48d3dfe3c409ba22a7138e3c9ba3d
cbc0e72b929b891417a3ad88f882355982b2836331cc5fdc30
7df1e2484973c3dac58ba7034c9fb39835e49a2d9752518343
71754d3004c156b65c712258530d35d5e539abaaa0c0dc2cb2
dba4860db95fd36a1dbeafa59c92325e18e683afaf873cefc7
04d9a6140fed576592d0a0b4025398021a6bce1d3b2d4e3b2c
ebf628ad0287c3e170387990ef6547f6446fe2e3545a81294c
41c74875b4b2bcaaa2a6baaa669a545359538da126d870e619
d357d5554d9b5951366ba63f32bd6aeecc19c969b5b1aa19b5
30ad76dac0b275ac89f434aaefd0a3e1193366a0186665ca3e
400ee501d629aa1287339ef43e7426040251d9efc1dea30944
03e1fa2c61b9bfd865d0bc6cfeec65cb8acb97cded5cb60cab
fb0df3972dc38479722955f53844a7b1ece133d972d1322c04
a6d756e7acaa8a4215fee44f7ed5b321b725c6aa917ea1b62a
e3c0653ef859acffe8eac139c26c536243fb5599242c505a81
294c018d359bc64c89d30f6bef434aabc0e170381c4e1ee4a7
27c37d8d76323159bb0e9c0c14748cd4256aabeaaaeaa7d5d5
cf8cd5d7d4d761a80fcf3bbb6d76db8cda998dd5c9b98d41a9
a1aea9b1a166e6f492ba86e930737ab65df40ce63c99496df0
c987d3d0d030fcc35665bd81913c40afa22a7138e38c900961
50b159d5a5388753ea2b40a33a07235660bd520b268841055e
7316c16a3807ce850be172f818ec80efc3bdb0078ec2317805
5e8337e16df8ab6a9a7ab6fa57eae7d5bf11aed1354946a948
aa9596c43c258f963cf18e269d06e63729872a2cab19dab0ac
6ed80c576059dfcb29eb0496f5873c658573ca82743a7d2ccf
d003907e1e12e91bd2fde91b70fa3318ae4ddf6138f89ef89e
eadd77feb6e36fa9d71f0778fdae231f3d74e74bf37ffd4bb6
d9efb37772bdc155993098dc5635cc432c423f6c854be14af8
385c0dbb71ab7e61fd08fc04f65a2fb77e1457a53bb93a955a
8dbb7a5079982868b43469b600d84587d3e5f6787dfe403014
ce74c69b80d2b2f28a646555754d6dddb4fae900b36637ccc1
84f972194b5a5a972e5bbe62e5aa33e0acd56bd6b6b59f7dce
073a3ae183ebcecb5dd30518b6c0254c59fafc0a697c4d4e86
7e809bdf67cf641032e3ddf7cae30730fc642f8a5f0cc9faec
7307005e80dfb0697e6c8dc9b1d5f481ebb65d76e987b75e72
f196cd175d78c1a68d1bfad69f7776fb5967362d5c307fdedc
c6390db367cd9c311d2fefb535d55595c98af2b2d292443c16
958a8b22e15030e0f779dd2ea743b4dbac16b3c968d0ebb41a
41ad82aa96786b97942aed4a694ae3cb9655b3f978374674e7
4474a5248c6a3d354f4aeaa26cd2a9399b30e78641399be49c
4dd99c2a519a07f3aaaba496b8947a6c495cdaa33a774d074e
dfbc24de29a5dea4e93368fa169ab6e274348a0b482dfe4d4b
a494aa4b6a49b55ebea9bfa56b0916b7d36c6a8e37f799aaab
60a7c98c93669c4af9e25b77aa7c0b5434a1f6b534ee5483c1
8a4aa582f1252da9407c09d3202594b474f7a656afe9685912
8a463babab52aae69ef8fa14c417a7ec9594059a6935295d73
4a4fab912e605b03374a3babf6f6dfb44784f55d9596de786f
f7ba8e94d0ddc9d6e1a8c4f52e49f93e76dc7f72160b773677
7c26373524f4b7f82f90d86c7fff67a4d48e351db9a951263b
3bb18c94baa4b5abbf15577c13eec2956d12ae4b7d5d67474a
751dae5062dbc1b649debabe780b8be9ba504a19e38be39bfa
2fecc23f26d89f82b557467705834df7a58f40b045ea6fef88
47530b43f1ceee25e19d6ee85f7be5ee4093143835a5ba6aa7
e89077eb4e9b3d3361b1e64ef465d3688ab2b3a9956bb3fb55
c5348a2fc7c32125f548a849471cb7a98189be06e8ef69c06c
48a70a974af5e2ff7141cad8dcd52f3662bcc8964f694bc4b8
d4ff36e0ff1f7ff38d5363ba3331ba12f16d6093ec28c91e68
983e309daaac4c2593ec00d137e33f8a3a2ea0f999d55597ef
51a7e25b450947b8fb6035eedbeecec65adcf9d128fb7b6fdc
d304eb7126b57d4d873c2fc1fad02e68aaadec4ca9bb58cade
8114cfd92c65fb404a76f1ae381ec7f792f1f0a40ca5d99f5d
f4ba5a3635a654de6192fbe4f4956df1956bceed905afabb32
fb7665fb2973727a43362d33a592137087a73425b8a796c7f1
d05b7b6e078bc09fb6a435de7241d7323cd550c794abb94308
a93be5297548a0a2f0f85d972d99cd745858599a121d1dffbd
7bf4063c80294625b5a6c4ae65b2ec3445a3235c684ffa2db6
148d4e2e96d9a65463e5a9f3734f993f453d4bbf800a6b4ad5
2bdbcfedef379d92d68ac6aabfbf352eb5f677f577ef496f5f
1f97c478ff7d4287d0d1bfb5a56be0efdf93beffc650aaf5a6
4edc884daac6eaaa384be9efefdd0942497b47aa29b4534513
b39b6fec4c9d55d9194fadaf8c47e31d7db8929d8d6089b677
35e3941a16ef8cab6e58b3b3497543dbb91df7897845bba1bd
63975aa56eee5adcb93381691df74968ea2956cd6259249b91
d80cac54e1b9b44b6da0fca1fb9a00b653aa862268be678f0a
28ce3010a7829e3d6a394e9457544a2b6ac2bb939e3d1a39a5
6920b706e30c72dc7639777926b701534496723fa8d95d244b
94d98933ed1d4da6d94d8d4d739b16a817aa718fb0a85d1873
3fe69dab82dd0b540b55a19d58e65a8adea3dabe736e53e83e
2a696d26e776ccc9e2b667e35073962da7205c9fbce1679fdc
82b3cfedd8bd00b07c9298633183d94b5422f74c20f3c2ce02
b2a53d7801db8063760a77c5f1ac8eafd8a93eb392c62a1af7
af88b7f4620e16f00a3113b58a4abd9d2c579c1d1dec1f7edf
4caa9c4cccee51e1fde2dc813955660e67f0d79fda78eaeca6
ec6c2b0b78412da9914f103c9ee9d88ca62e0ca536775666b3
74a7b6af97faf1206e644772232dbc94852e3cb197a6b6f774
b3731c4ffa9e3846acc008a9637d28da8905b2eb4a3fbbccf7
74e3629ad2ec9a5217579e52241efcaa765cb5ba846d4e6afb
6aa9ab53eac29345b5a6034f5429a5c5b1b401aff5f16e7682
ac96b76735da2a1c75f7b7e1b2807f446728a5478bb5a1bb2f
ce4eef14fb63e5bd2fdba6152968eb4841a8bf3fde9f52a18a
25ad98198b2f4de94a97b311feb656c6bbfbd86dc8067617d2
275f21515dda3bacb4504b3cda8959d425b42f71c7e111b59e
899e7e7693735e5725ee0947bfb35f9ad38f47f67978526a4a
7bcee9c2135812a55689feeaee10cee14e58cee63ab12039a3
b18465c4e5e9579ada52b9f33c7dc9c918fa5d5229673650a9
74cd4bad1ec8a2a71f4e7cb832a5f6356022db7815b3c7b275
663b4f5bb21c776f131e5521b6b49452b7672ca5bcfc72b668
68e00f9317c3183a35e9728ab6a74475c3eadc537e5dcab572
ed0743b863d913eb452668177eaffe1e44a058f89df026ccc3
f19bbb7491e23dc21bbb8564f1c2451ee138740927e076e125
388c410322c68838b510c3569c4e63d0a6f70a4777b7b4d437
edc171650d8d779557d4dfc7127605c3f5ff251c557f17caa0
18230eeff28628e5d0aec58b3313b31ae489ddc9eafac38b4c
c221f83d06b57048388c77ffb4d4eef29afab716593142255c
0376950a8a6187f05b4861504393f0c2ee4469fded3f111ec5
f4478487a197167b7897d5518f053e28fc189cb8793f127e98
49f9e16e9ba31e165d26dc8cb6722fca27311cc1f016060d5c
227c073e81e1f3187e8041037694c5186a319cc562847b847b
50cf7fc7e5ed286b315c82e1f31834b867efc6f88b9814ee12
2ec41a51b17093701b78707ca3f0451adf81e3208ebf8df145
38fe16ceb3f1ed99f96fe098a57f3d13ff359cf7e2f8ab99f1
57303e84e32fe33c1b7f29337fb9f0115a6e5b66bc43b86c57
51b1b8a808d3250c7518049cba0da76ec35d771babf4a15409
9f1636d39a76e2b81ec75be431eeaeab7745e3f41f5dbddb17
a8df81bbf46adcf557e39ebb1af7dcd5a0c1a4ab06f25c25e7
a916aec23c57619eab30cf55b857ea84cb707d97b11a324a11
838441c0fd7e19ee77169f42b917c393147f2dca5b30ec6073
c247713f56a0569f152edc555e8c07d9c6dd739aea173e206c
c05ddd246cd81d88d47ffee49cd1c40e441cdb32633bcbdb47
a97dbb8d1616dbb73b1891c798eba24536a1073e8e410d6e94
090c33302cc1a0117a76256a8bef17ce842d0668b2157f42fd
09e1ffd9fbd2f8a88a6cf13a5577e935bd25e9ee74d24b3a9d
adb3910d823de426843581a0ac413121286b34844d41300145
1494a0a3a88303711450d121e9b034cb13f489e33ae0b82f23
51a3a24e6618077183ee77ea76dcfe6fde87ffeff73ebc0fde
ca3955b7aaeead53a7ea6cd59da45d681785a21ab01e63c564
9286ff0a8d95e59390861cf0348660e8faaeaaf5ac598dff9b
71b6cd2831cd389f66e4c459d688f55e76254223f2a51189ba
12eb0962827766845358eec35cc43b13f633613f13d69ab0d6
84b504316f9984d084b078b055fab1e5876778ffb3bc05210b
5b13b0360167d987f82c2f218cc73b23de19f1ce88bd4ed10b
48a119b11761120253ebfa10f821c7851fdb8a06db9b1024b5
fdacdae78736853f4b2f287959c773a03b07ba72604b0e28a1
caaa62251d91d56a5ddf59b7b7ee58ddc93aa1b1aeb5aebd8e
0d8dc48ef7868345c56a9e1ee0f9feb033a578a8a9ea12ba17
296b44bc03e13402231ec485089508ad0802dd8bd883daad10
a112a11ea11141c4279ee0328bd833d8c6eb77a86dbcc4dbe9
2fda19cee1f1f0f092faaa09a8c71a117620307cf7e3d8feb8
da3b5edaabd67723ee53ebeb07fb77a9f51ec43f3cc3d467b8
ee9839883d0895088d088b114472924d47bd3b9dbf1fb10761
31c25e0481cdc4349d4da74f607a9c3ecef214e390248ffa4f
a888d5a2315799a90117d5088fa8f83e15dfa6e24a15672809
e38de7c71b9f1c6fbc65bc310b0b349b5461c3dd2af629fa2a
e3be2a637d9531a7ca886fb3131f31d224154b1cc3172a9ea8
e23c25d167fcd667fc97cff84f9ff1f73e639bcff81b1f7f2e
15c5c2481355ace718b6aa78bc8a3315bdc7f8acc738dd631c
ea315619613be0e8a45ac56e15bb38862ff7996a4c447b04be
2435f8260887723c68d1d50c62e1501566d170680c6617c3a1
ed987d170efdd67314be05d55ac0f97046bfa72a09cec13881
dfff6b30ff278c237b303f8bf93ccc77911004307f381c5acb
fb3f84cfff0eefff40d235bcff836492fadc0e18a7d6ff7ef0
b907c279cd38eab670de4a1cf577244f1df5de705e3fd6fe36
9c771b667785f35a30eb0c0738810bc3a15c4f9505e6910cca
fbce2101ca29a91b1c712cbeb905f331f1874785f3f853357c
80088c0cfb876096c5a93c0a7e32491dce13f6ab934c237ef5
15a9c4af12ed2201354f00934abc91a4abb926ec5f8b6f91f6
05fa3d5f878ef08993afc014deeef9e828ce6f1ade7e08e3c2
7b3caf1ce2ec0a7b4ee6452070c0f367ff11cf898c084c0b7b
8ee74534d8702c2f4261bfa70799dc8d7d291cf0eccd9be779
c2afb6eef4632b2ef58e50be679b7fa6e7fe00de873d6bf38e
7232c83538e369d8dc9037c25317dae3191d8800362b211c4c
d17986fb97782ab07a5804c6f5eef10cc98870528af01d7b0e
787271c44c3f92b2cf533675ead0c3b48cc8b05cc99397c9cd
f234f952f912b944ce97bd729a9c2a276aac1ab3264163d0e8
341a8da411345443348991589f12e4277b8992996792c0b1a0
96cd94631a3ff8a3a0a1283ddd36564b6b275743b7b596d44e
a9ee1e1aac8dc8b1cbba87056bbb35932e9fd103b0b901efba
e9ad189b4d99815b9457ad77f173a04304a070fd1d2e9eaf5e
7f474303d4761f9f436a9bbddde727e34c7418cf8afe6a0749
5e51e9a8b48eb0548caef937a86910077fba1cc19f5f8eb4ea
eeadb5936784cb1e7b2cadbaa1bb582dc76258aeed1ec30f92
0ed136da3aaae6105dccb386198760156d1b7519af8755350d
3f7623e974317623219ef16ebd249d7723e9d0ab76ab53bbe1
7e4d1f55d3939e1eeff4348ce39d701f3dad769a177f57060e
81ef9ac433ec46dd24437d570675f36eb831e22f33fdfc6506
0226f5652603515f96ca3bf50402d8252fc0bbf40c0d60879e
c050b579cf4fcdfe409c9c061250c70940833a0ec04f7db2e3
7d70330cf6a11aec13fcdfbcaeaefeffe80cbdb3dfbb6a0e3f
ce6bf28fba1aa1a97bd38af90e1eea797bae7a6ff09c2fb3a9
79ce7c9e63b0f39effea9aeeabfc35de9ed973fe4df31cde3c
db5fd343e68c9a32a3678e72754d78b6327b947f764d43efae
f691b5bf18ebb61fc71ad9fe6f5ed6ce5f36928fb5abf6df34
d7f2e65d7cac5a3e562d1f6b97b24b1dabf6b26aa89d34a347
43aa1b465e11cf7ba95e8762d184f16175b279f10855462ef1
396e741d1608da2f7db0a1dbe0afee3622f0a6fcaafc2ade84
42ca9b12f881ed6093e3c64b7caec3f0c8609319ab2dfe6a12
248e510b6a7efc59ba74e9b2a51c2d5f1e44bc6cb943ad5c86
c2eb9b5cdb3d9a9f2f85ba43a3ba95a69a06e0eb811d6728e5
8dfec6406376e34ea1d5df1a68cd6edd29d4fbeb03f5d9f53b
854a7f65a032bb72a750e82f0c146617ee143c7e4fc093edd9
292c57af86913314f3b1d0c9106d0db5873a433b427b4362bc
da7a2cfd643a6d4c6f4d6f4fef4cdf91be375de20d57cc38a0
8476a4ff239d2dc79d08cbf01a55a392bb1c73fce1b7cb96f3
892c45ea329ab48bb51d5a66d67ab5455a453b492bb6b276d6
c9988715b24a56cf1a99886e54581e5e8299325a1a5eb245df
a5efd61fd79fd28bddd271e994d4279d9544af542429d224a9
495a2c75485ba42e49bb45da22d326fd627d879e99f55e7d91
5ed14fd28b1e1908ce6d2902e7d1f2e52ec52c4b351ebdaec6
c3688d47aba9f170f63504970747cea84a2773d03f06f4e5f3
890dc18f508230194124ff89f855848f10fe8520909b10ff16
e121845e5ec3f259fe28c7821ace838620d7a40e56dc5b5456
3c2c82f9ecb9f17cf2cc783e6a623c0f55153b300f5796e8aa
4ce8aa03398cf8058477103e47f80e4164c5ac587df9f2b80c
362c254b8380d32278b38ca3a5c16510c402f0bdb36c693048
387071c5fd845d83f04b2926b0743959ba94e0eec20c3ba9b5
4bf963cb79fec3850d44ed2f6e2644ac231e845435aa23b10f
10fa11ce44c7c72e888b883fba30d6c7f8af653f3108fcef2e
6e253b4806390b43c8d3e4381aa85deaa76f779331e424d94b
12c84a7811f9e947d7e911d47f1e3467a3891d44723f799b5c
4196908f491f46dab5e47db0e27b4691c5186156c43e23fc0f
a6de1a3b84bd746424f923390c2d30991462792ccd435e0448
67ec38b193ecd8cbb1b7f0eef7e463c888f590b158fa845830
8e68277762e8bd90bc10bb40f8e79ccd6437ac86cfd0696c22
9b845261636c11b984ec27af432d96269095e25bdafde8f6dc
491e023b1c8f9d8e7d4a9e4427e16a7cd33a722b521c26c769
011b2976112fc924bf2113c96c6cbd81bc0d3618c2945856ac
3a763fd6ee265fd2207d96c94847908c238de40ef22072e30d
d28f3e8e1ecad075db83e915f8bbf816d2564b969355a40329
df85cf3e4e0ec1101842ede8f8529c610e998a6d9d64278edf
4b4e412d34c071788aed148ba295b1c45852ecd3588ce49219
48e10ef2148e710e8ab00f8ec0d2d932c12d2c138b2faec519
5e451e20a7c82b48c7fbc8f7afc837908be9037a236d8f4d8f
3d12fb1869d1a053348c5c4a669256b2825c47fe80abfa3479
86fc13bea75aec79523821ae12cfc6ee42de66926aa4bd1e7b
4fc6776fc2550a9308a637709616f0e22c86c144b80ce64127
6c8508bc0d6f5389fad0f47fcebad98bec3da15c1463c3f14d
c93cfac75d329dccc715b811b97d17cef71172823c0f499009
f938a337f0f9f3f4125a83e9217a92becfd6b34ee182784bb4
2ffa45f4fbd84622e32e1b837c584e1e432efc039291861c58
084be123a47c0bddc7129899f95919ab62535803bb95ddcd9e
637f1696087b8477c471e26c718f3c3b7a6df495586dec66d5
ed9290ae2c92474ac950dc3f7371372d42fa16ab9f9cae266b
c946b219f7cb5da40b1df90839469e27af93bf92bfe10a10f0
21cd0b70f46b70d7ad87cd98ee87c7e1293801cfc307709e27
9a8e299b96d34a3a928ea6f3e87a4c77d353f40d7a86a5b239
a8453b306d6707d8db687504212616631a2b6e12774b2fcad9
f258b959f3d285818bb9171b2ebe1f25d194e8e5d1add1a7a2
9fc6a6c55622fd01924f0a90d20d48e5fdb80777627a0c77e2
01f22c7989bca9d2fa25501071c73bc08fbb210f57ad12c6a0
eb340e26c0a598a6629a0e3331cd8666988fa91d3a601ddc04
37c31d708f9aeec3b9ed8447e100a6837018d3eb701a3e81cf
e14b8a9b9832dccd019a450b6905ce74241d43ebe96598e6d1
564c8be912ba02576837eda587e81bccc602a86f67b336763f
fb237b9abdc6be15a89027140a21619a304fb8493829bc22bc
257c2f7ac451e27c71bbf8b4e4924aa5a9d242e93e69af7446
ba204bf224f4c257cbafc9314d00b5d59f70defb7ff18978a1
7412968a89c2f5f434ca85832d1637c054e49844a7b016b699
fd459c0b679917de818d6c015b147b888da6dfb05698468f41
3af388c3d95c723b89c11efa013d473f1592600afd0cb2853b
e1206d65233154c54b7c5548126e12cfa003ff26194ed7c071
7a82ddc46e8afd07192e6e87d3e276fa0af10a7dd4464ea354
6fa0f7e2437fa60be82632432815bf270b90ef8f8ad723bf47
d05b2197bd266c271f333ffd17868d5b516bbc0ce3850c7a25
ad803da8712f829b0c401b590cf710058ec05f2182aefe236c
37d45103ae563735c2508c265e663e788de94803a711326912
4ca267e95476543ac5ca309e3b45fe4256018322dc3b3f5c51
722d4ac0dd340b75da28d426af423171907b51df9f8b1ee51a
5b7c4bdc84fbec4196472e234564167d910c47d9f818d30c72
0b292687710fde4a8ae87d6475ac03ae42bd3f01f527251890
9242d0a3b6b4236ded682f92693aeac2461cf51bd4ff2fa0d6
af85bf93ebc08b92759c640bbce57661146aa626d4bf9b305d
4566e1dd03e42e69bff82aa9073b218237ba1d77f97be44ab4
391fe1f8292484f4cd240f0afc7b1d5ed4cc6df8c403d1b144
c1740b7911285983348f40399f248c45cdbb35b61067b8006d
541ddac4e7c982d8bd6424aedd65b19b629b4863ecc1d81518
824f8e3d82fa77452c4ccac906b1814e13834229ead8e7e119
b447efc226d4db63c93ba88f02e0209f63fa23d23f423c4236
0a6fa2eeac8cdd1e7b9d24f1bf708e1c6a462bda4fae217f47
be8d65c749497422ed898d668bd1429d2697c676c73ca023f3
632da8798f929db288baa783b8c59db8773709736911d29b43
92a1106baf1077b037d93f85c5ffc337477ebd7ebd7ebd7ebd
7ebd7ebd7ebdfe2f5fc998ece86f39d08b71610c9ba3fe9f83
3cd5bf2f44dfa6147d8fa118b955a0ff7209fa39bf412fa61a
fd9ed1e84dd4a19f558f6932a6a918633560e47d05fa4bb3d0
336ac418f62af4c2e661e4b500d322f4f25ad12f5aa1467fd7
a13f74237a641d18ebac430f6903a68d18cd6ec6b87f2b7a46
f7a2ffd48531e243e8ad3d8e5e4e2f46161172883c89b1d053
6adc7802238d3fa107f70279117db197c89f31fefc0b791563
8f77c8bbe89bbd4f4ea377d587fed92784422a7acca9fc0346
8ce55abad70767f45038429fc4384ca6c7c2441422f4c97d8c
e8645ed80fc4a991c463d84e09831ca2854570257104cde743
174313cde742132e86482596cd17100d2972f5102122bfd9db
4240c6bca70588a33058182c1ad2e0b3f82c0144902a900b5e
76fc822292efd1313fcebf55dd1feb8767c545c480dcbf9953
75843e469c441b3bae68cb87951245a92ad5f093ad44b7af54
97f24dc2bc72a2e49695ee2607714e1136eea0516646c5a6c7
7299622444279895e4529d227ce3349f1f383760b156140e90
ca814af327438aa04d3d9109c2e81a97a235da00649b5666c4
515989dd2c25482df8596659697949717252a2cc3896fce9bc
06e667ce904616165609d71654551520c03c965b9652595757
eb085e28aacae7d5f9557c56eb318a388ab332e28e0af3591d
8c389f737e6d608648ec9b5e7fa054cdf38b4a21123bd38bd3
2191d8734a1a169c0e4429c3107d6d00d96037505dea7a9cb4
113df929bd324b49c03c9cc8084e779fd1a81312f8bc935352
ec16dd35c27fdaaf2116b0ac77a5deed5bb8ca110c9e9f75f1
7c9c05837cb818aae4cb1584b6598387d24b5cfb4982222772
2e94a4bc5ccc79c0b27ec603dfcf194295f2643aac205861ab
88360f4d2ecbcf1b9e52cefc90b1d2e9ac1c3e7cc8d439d177
217b559e32fc9221599ba36ff3487f4a743c5d2d6e263652cb
79a1f8b75a765be82d86db2c54779fd642ee031bc6263aed23
09e99324903a12a75cc937daac818ba19039c4d76e6008c63c
30cbd50b36ec8fabc5894ccacccaa46566323449926852a2dd
4de9ea7bafdef200149fbf61fb445fcaf835d1d640dddc3b61
e36b500eb16b736bfe16dd7ae28dbd1b77ff8e535580544d53
a91aaf52959123e46ac68a0cc9b12059360ceeb43a24297e70
caa48ea4190fff77b238515a1bfc4094ad2cd99e6c4d3213b9
acbcdc5a569a55400beebbbaf381e8c9af6fd831c1e7ac5d2d
5e955b3bf7aee875af475f88c2b581515fc0a213af776fdca5
d2746d740fdc479e436d748d4a5356036db03f93ccb4f626e7
2927d3029105c1a4b1920356c5a017869b923c491d492c2902
b98ade636a345193d3f1009289123a6bc2c5597ce3f75b2bc0
62b557705aa1cd7510596db05a0d7abedcb8e50b4b54b2cbcb
91d84c7fba3cb8dbd5e596ae9dd7a695657dc09a3864786d79
f5bccee89ebcf4ce4936a336513bbc64c8e8a58df37a38dd93
a183cea076d42d5354babd54ec48bbaabc5d0450bfffc10835
c32468822dd005a740820894ee271dc294999ca31767717e16
0e20e644065197b08826a5a785701dc2c9f325f92653f1e2f7
d47e2f8e7627ea8c56d4807a72893a5a2a51243d53b4caf032
ad5259d6a8851ddabd5aaa5d6fe032603edfb62418e49c402d
1526923a717c69e0e7b24d0a1555a49f567141a1c267c562fd
7404ee1046e6a8e36889f8a207f50fa0aec9528c9425528a53
433da447e9f428895e56c49ad862d6c5fa98c48ec013f44521
02ad3da7391503e7f872842a431bc482e01af3332884ae5eaa
c7e707f733f8818e88264d822fc4cddf4d131f43ce8d8f9d61
07c5f9c44c32c8bb9c86f06c8d370252581493786634a644c0
a458b5292453c9a44a66536657665fa69069e1d5098d686eda
49279a1191380387c18dcb31b83706269a67b59d9f3030b88d
47ae54ea20c39f919e41250a0ca82407525d692eb78b49b64c
53409fe970da9d54f2099666e291529a2131014bc9062c6580
b7195c1a445673523371ea10a99a85a35c157273d7ba7a446f
44fe7c5f8b281a9322f267e116a311671eac5417b8d43a14b7
9c3dd992487149b232879aedc925c5e543cb2db82be3fb928e
bf7dd9cca607566fbbf5d5e6a7d75ef3cca88ab6f265ee82a2
8c8a9ce13565634be9f633507f59d58e13d1bd7f8b1eb8e7e3
a7be8e9ee9b967f692c7a1e2ccb6a545bedf4c8e3ec057f52c
9a4009799a1cd7cc4aa2e268727439fa1c0271280eba024d31
4da8b2c102a842abd745d2d1fef1b206cb7e7cc137c4040b48
32d610f852490093896a29885a8d81327218bec6eee3146b42
8249b1941599da4d5b4c5d26c1e4b41fa619d03fc8fe606882
79a09f2b11dc0f162ea015e4ab810bf05530a86abab659ae7d
20ca5a5d847d186ed11a38a38a55fd1228b1242627db937c65
236819670ee7cd5918efb385ae88d2a661c93a399012a816fe
f4e0f71b960c73d34080a60d5945dfbb3bd7ebf6e0ecf370f6
7b70f66eb8479dfd3ad9a1afb03b527f53ea5010393932b993
9373e4903c4e7e549614efe5c24ccde5f6998e459a659665d6
07f4bf4fb8dff2b8fef184e7c5e7edcf39deb6bfede8f37e2b
7c6b4f4a8234c129ba929cc94e7b9a43d6daf50e7d5aa9738c
f3367ba757763829b5a7380d4ec9c89c54941c766e506c8231
02f315ad564934547668411b61258ac12ca6743a618773af93
3a0fb31264e91dbd400dee08dc81365efab0ded6686bb5b5db
045b0464c5c6bf1a9d42bc8ab7c3cb9abc5d5eea751e816f51
6e8da028898db495b6d34e7a8c9ea4a7e93fa8863a3d8761f3
4fb2d01f8a4bc3ac0928a2662ea4031767b5a1a16ceb91f8f7
8e0f766ae198f6a49692596d0dc17eae4cd535b356545073bc
cbbe35ce3b9cd8de9010da6016d73c93f00c773696a01f08aa
c3e13a68349add6e6ad6a262dbd76216a9130be1166a88cb00
f73e2a0a55d3eb2b23a4ac14975592fde583665792a9ec2b2e
2f1fcaf6345ee883d9e0dd7eed553b3203ce93db76feb568fc
ae6f474073cbf4d1292046bf0f4035dcf7e8da5dcbdb0e3dfb
da9679f3feb03f7a76987948beaaa7519f4cc3d52f8676befa
87882ed617365468b983153254546947e946eb6bd385935ac8
c91996a39436959e2ced2bfd5a279352a8d2b6fb57153c9671
28e370c1f305a7fda703ef167c9efe59c0304e931381db7bb3
b3cd2442fb7b4f1541518495ee67a239199223b0637f9a122c
2c4d8bc0c85eb33127fb08cc2789444b3f52f49370c5e81675
c570dd7bbb0d6088c016accfefc8a75bf2bbf2693ed6ef6f94
db910111fab1a2534aa1abf47829458f09461c546cc76cd4e6
2ce1aaedcc8fcba9aee5c0acb6731cf5a3af8a4a2e38b0a472
60d6007782546d575e50e8ced4990429ddc7ff7762c0274862
20213353876aac50c86f06b7094b3e7d5633e8b40552513378
8c695caf9943831f08e6aec54b95d52504dd4a740358760eca
ebfe1664042b8a686cfb5a90056911f9ab708bd9f8e33a2370
412e57f51dae6db2bac0be41ab6b47e1e69aaf4cd57b997e3f
9773be1be4f9c37b6e7e687af5e1351d8bef8a7e71db9c429f
33c572bd3d903bf75e7f8a27b875a2b77ec7d8b54ddbe60be3
6fbb6761fdccbbb70f397043f7da476ab2d2f23462a5a4dfde
525f3b2c2dbbcaadbbf2e6fa79edbbf8b7f9501b1cc2fda043
4961aa3ec84e3682898c322a26a69820d70049321a03605a51
02c1a03712c16014248311a53655b1ca9a4459d66898204b06
0df118c178041ec088420f3b14a308925623491a5130188423
300ee551037315bd566b62b083ed659445e06bc50195aaf89a
a00935659f8999244506d999f033196d0ba96b1a4201c5e227
661e7b5456149ad163300f982f2e09592a2caa406e28080a68
5b79d16432a12e5d826e631bbab80641438d52446357742db2
ce68143859837e7f4949b0d8a2ae0a24f92d7e8baf0c4a3003
76e8c0ce8b4fd3e5d7ee8c66c0b9cdd1dfc1dc0eb6eec2edf4
c18b8d5c9a9a519a568a75c4071354de8d7c58006b837b81bb
5d6c97dad36e17ee4893cb68996f2a9bea9dee5b94ba425c99
ba816e4cd998fa107b44dbe5eff39b881fd45f1d4d4ab66b12
d1a3609cad16af0f5d09c1eb4b71a532d9218858bba3d7ebf5
d90ea35673309b82fc870f09fdd0e72302da9c11c40563f677
c85d5c4ae02b94123f28fe263ff5a3f87d7bc04cbb7ce0e32f
51b45ec5dc65a66667fa61b8073e53b9db3f0b8d917916e7a4
2a38fda800b18c7e812a2e689bb8c6dba029088ac85ac26fe2
4a4f312e81257489771daca3ebbc126a3faef450e78dbc6286
a25f24b45aaf722f1617a789b31ad04dee61de88c6b7bf8531
9fd111d1907de800f82856855b7cc24fd2c15741f6c902970d
49fa993b3a2816281559c0564e8cce6f00edb6f5d36fbe74e9
ca55ad05fe94acc2da09cb7bb66fbae6280862dd6307b2b6df
1a5974a0236be8e4e2d4a0d957dad37ec3ebc3f3656ac27d3f
0357ae07f7bd836443505dbbdce5da15baeb12d669df0e7c16
9024066bd82a6155f27abb10d2644b22f33bb39d12f3366a40
837aec80371332334de8c6ded1eb202277c97a4d46c0a550f8
8a2a567d0ac95572a992db94db95db972be43ae3ab844dc466
b6796d4536c5b6c5d665936dce9c9f1cb30be8b4f70f7a66aa
da4253844c9935b004990e3f717e9f5e7249546538eab2bcd4
80d69a96ea4ea5922560cc0c68fda8adccae66e24bc052862e
b31952adde66926e40447ef0ccb8028bbb1a3d9a4c5452fb5b
341a930322f25bfb5a1ca2099db58fc22d26e32f57262981c9
3fd824eea7594aad19e525202525feb83e68b8d8d69b773fb4
2863cb9d9b5e9ab7faa54db39fbc0b4cdf2cbaf89275cce892
71d36fbb754de674717ec058ff873fdd36a7affbb1db1fbba2
17d20ec0d8e88c8b351b26377d505df8f07d7bbef37219ab8b
f5b39d28637ad217b75842acafd7e61a21aadfeec382530322
cbd55613c5d864ec32be00cfd3b7e02dda67c425003d10a362
645414d00fffad92c2682263546046511953267e081266d287
80421481fb0f74e941ef348887e919c2e8a78a810866411126
095d82281ca59f10c3e03af118b05f3535e7b8af10340f04e3
5efd868435cf0c8a867699b84cba59bc591206c5027d8125c8
77d7019d8e08e8c344349e700b896f7cab6afa31cac110c087
aeae9cf567fa6634b418ee896e6a2b9a529226d6657ef7a470
c255d0a4472dba1a77ef46dcbd4e92494ae06175ff1ec6f841
5be229c9cd6a2d5995dea1ef3074a474b8d6053a3237963cea
d899b23bd06bd8977230f348d609dd09fd9bc66499e84032d2
146d56b2d19e123006126ae176b8c9b83ee151927009190eb5
a416c66537c2e55957942c240b61019d97b9306b7ec90db03a
6b45deea924ea153ec903b34eb2cebac9d899dc9f7095b3577
5bb65ab725efca7c22eb8992887040f399fe73c367099f657d
569c231bb559c349050c2b166b34c4909225a8c86c57e31949
cce799cd9856a545fba34539e250846533da0c332953caa852
d654d655d6572694f98f62034389ca4589d215d915fb163bb3
3b4b0fc3df07951a0f71cea90a6da0ff5c3ccae1e2033c0e46
91290e16bad32dc9822629e013fd18d2c869cd909798db4c0a
ac68ebd30534fe6e1ed20493f39b49a1253f2e388392c32d3f
5774f8b3c47530c540b2049b8402f3f1be1649b4e547e40fc2
2db61f24c7ae1a96cc9f826a39d91e8f3cd5439640f9a0d070
11b2493c1b34ff70db83b35e7af4e1e75af67457d4bdd3f354
cbb49530e47a65c5dcb91d6543ca274fbae39a96759963e89e
9bbba6dd7c2cbca46efba25b27ce6deb7c71e5eca5337bde68
5953bfe0ba15f5a5f30ba39f8eded9b476dbaae9632b16a2ee
bb1425ea11dc3d769205f1f8b9e486acb7c537d3dfce12e60b
2bc5359a55daeb0cd71b57daaef36ed2dc64d369359d39f412
8d98e5f0653944e60e0844160fc31ce200655fd624b4d5a811
156d61a03580e10671f3854c105137debecf6e274607d77c29
603a48ac66abd7caac11b81ab5608e92d391c3949ca69cae9c
be1c2107b8eef4613745774c4775ceec5ff8740371a7ee62dc
36550e2a45b37abc6789ebc68af8cae6ba32341643a639909a
e9cff4187dcd24cdc483540d96bc7a3746aa1644e9dac0cf55
215f52d572b97ae44044fe7a7f8b2c2790b82e24c6043706ae
e19604f117bad0ce4f7886c6edd3d041678ea25604be9ef105
555562cbbabe57727edfdef9d2dc1b9edd7ddd5def3ffbe093
b4c45abd7242c32d0d558d0537a606e872c8d87bf55f0f8637
3dba71cff71f4657ae5d480fad9b38fb83ebbbb6bf7addb43c
7ea2d81deb872dac1bf5a09d5cae9ede3227ff1e759a715ef9
16671786e60a910d68784c4a1253b4a55b92ba9268d25108a0
8dfb0b90b8d63aa7463783e756189318ac12b1ea89ccfd204b
49fcf8f367a722b69f9f90f8060f3df30aabaa79cebae34725
0555176dd5f15235d2b939ba0722ac07e9f41335c6505cbec0
539679e5cf9a9e49a706a3cb9664d61a0e380c9cdec4089ba8
78dc8a438fcea6d6a3a5da729779b8c9e7f175f898ef399733
831fe0e006e0475966f5fce422525f68ee57d75b5d72680bf2
a35c83c1edd04bea544a2a4be2a75a3f9f0bfb1f4eb8206570
5e57febf475dac47894f4bf9eebbff7ee845899910b15b5c44
5289874e899fa7ab9adf0a1e3775a711b4c724cd036895139f
641f123b828ca0631f2a760d4d7533932635398d7816430750
008d896a48213705b35e3ef5726121dfd5e68181bfff0d0ae3
9779cd86679e31230c2972292e4d82c96434ebdc5acf249f94
64b299532c292e57aa234df2f1af8306ca78d65b34a354cd83
056a1ece89577b33e3d529ee78b55dad0e27a99972afd9566a
34e9f1e515a6f1a6d1e671ee7a5f8369ba796ae20cf742d33c
f37cf70a7387b02161a369837983f536f7ad9e6da66de6fb2d
dbdc874c87ccff9172c8fda2e905f373692fb8df35bd65fec2
74c67cc6fdade91bf3b769dfbaf3b4a65a17f5a01d45269134
b73b559ba073699353edae640d955d9a244ba22be97ab7c9ec
35bb5353d32de644cb620bf0bf759110a1cf2b16ea4ea4d4ed
49db49489c7111d8af183466134b4a4ed668b49ad4087ca768
4df80cdd99a05822b4a8b7febf08f916f0368a73ed99d9d5ee
eabe5add565a49bb2b7925d9b2a5b5253991ed441b72278198
920b0eb80925055a4cb14d08047e1ab75c42420be9a15c7b1a
68b99494b4e41e1128712fd04381bf69cba1b4d0923e0fe470
4b9bd214da2696ff99919c84f6f4f91d6b6776b552e4f9de79
bff7fbe61b2560a2863eb03c9ae5e9f71cf3309eef68576ca6
332212c5c892a344fa92b89f0414f8781c8be189be8d9e86e2
dd38e8c9cbb98d38aacfc9403c0ac5f17f3d6e146ffc491fdf
877fa9043e5df23d3a38a0ec4f78e371bb57c57c72d4720da9
2a0e80f87080a1e99ddd4321bb40509b0b7711ebe77c341740
e0abf3d42904f572f7b4ee69b0081b891f0a642762b64dfce5
a264ef67eacb96458a33e1ef52f0b5cae0f913ef9e57c97ee1
c807f0f9579764d4026f185ed9bc8bbde8c47db79d67330c36
afb7af826ed432f1065157674ffec1e6c5186e697a82b3ec89
022ca0025350eff1de9f78d8fbb0b4cfbb5f720a09180a6349
7c43f0bad05799cda16f32f744b7334f337617e361517c0133
c0d80a82e86b51b090b2ed450a8407408d59b44f7bc0968d31
b086dedcebcbed10a1586366edbdd3fda01bb96b4cc12a04ec
64bf14845de2f6277d50f5557dc817b5b0b8b6f76932f4caaa
8c641ceca065f24263cd25940b7283a3347bf9d1e80876f123
841370a47ffc48f5e807c7b12988d77f817a022da8702ede88
a69de990c129f60ee00ae28310b1754047d8dd41f81f9ec9fe
a3580b63906831518c211488b530315b8d7f7fcf508c09b869
181fb0375c40b561a4a99c8d3f45091f050312cd5a863936a5
11ef2eb510bf50ecc2e6637fa1aa338f7c6be36f6f5c77f4be
9b7fb65ebdb47eece9fa934f6dde07ab3fb8ebce364909449d
b62beac59fefdb547fe5cd5afdc32d238f07f63efe8f03275f
844b9f5e10f22b26669d14661d127386b0af9c436d36e0549c
f15bc5bbc5ff166debc475818de27dfefb832f282fc45f1105
d92705e209860fc28dd1db12282b70aa02b0c45415b79e0aeb
1135ebf1b851241b0a0121d6b744820d276d4a9664936a93bf
df47c65e5a9822bc30b35ac671a59682c32912bb32293dccf9
fd6859d8e5f59223b9358ce9d5258a6819472f72517291db9a
bcb869bb5caeef9c097ac4fe7c34f7113566c3a7e387af5221
09506cbb5834e10d8a46209df0c696c368101fe23e753954fc
91e5536623e1cb089e6023ca4eb75e13d0ae21b75ae3ff881b
179e5738bc44205ce327b0ca8ed4f80f700369361590d9865f
4e1ed878c532310f4da5a652655d63a5a0c8737a065b0df844
80fd45aab8bc2514cb9c53445968c2193fdcfec3fa35af6f58
fe0eecaaffdf632baf36a6e95733431bb4766373fdd95fd5df
7ef695cfc4e03c18861138278ee7581b00ec1e6cb122dc42ed
55b5ca97c5ae8d7dc3dc266f379f360f9785e591616e98df20
6cb08f7163fc9dc29d767b8baac4f5a4a12a393d2558644005
dde351ed8ac01353e8e40aaf23a4720a1f13150453d81fc48b
e0d15c1e7488246d867e65e9eded398cc947e3ca3bb1585cb0
6f17046e7b95e4d2002ff24b7806bfd711ab9fbed7bafcf6f6
9cda51c02f1d8a6ed7b08779536194f3fbcbc3587233652052
538bd4aa2235b598345aa8a95be8c5166aea96ada5c34fc18d
546e1033535be3b93a78f4f8e05b13d8dc8347fb688655fc00
332c6eea946af16cea9be8234e5d3cfa0110ff9a83cdb6990f
c7f3d29bcfe7382e67b7e7a2d1780e7a3197ee1d82309e03b8
b76b28d7466d9e43f1003d8f27a8b1e30d63e3dfd3d47ac6c4
f5e9646a167d299a6bd3496abd48971da615199d02e33432c8
24c73db81db6adcd9438c3f078a44f2dabbf2a66a71fb9fa72
73e6acec3527de37cd9c168eb62c35d9a037132c76653f6b43
13efa4f26bebd94b62a96c7dd6ca4c582bccbcb1bedd088bd6
25ccc8971259a3feeb2bfa835ec2c73ac60ad927d001afa38a
225ba8c18435cd58d36d67ed8e1d05e6bedc81dcf3b9df30bf
cabdcbbeeb38c19e70d8876dc3dc068c9e31db187727468fc0
3bec6d88d75dae1a4c5b6e41e1e3aa12d6931c860bb9d26a53
388faa84f4544255d27a2ad79e75082ed6863088b061c31d20
950659318bb2044346269346a1b090c965b78356085a4d2cdc
87b15edfc2712a0f97f0f0200d00f65a79e0a118f150387828
463cc9449c62244e2fc62946e25bf3ff4207c7311bf4617f3c
42153ec6c51f074fc1824a7caaf0734d5c4c4cb5181c2324c1
8725a0abb5356db3a505219c8698ac3f24e008a71be0481b34
2f9b4681b04c6111161a2b2aff0c0b8a0902000c893c4aa57c
58c263fe2e06f5d32c318506fc3c7cf8e3654bdc86013373e7
7cec7668ed66e7c40173695a763b540c5ce6cfee5474ee673f
8f21f0fea2abeae525671bf5e597e91149368c4eed7a66a8d1
afbfba6a204bacbf007be3ef626f5c820f53a658ea60e7e551
2413cd2251162348ebb6ba57775f270ccbc391ebdab6c85b22
3be41d116747619d73a39391bbf3d1feeee1eeafb0df630f77
b32ee656e77837b340c05696ff929408065225ea9f7753ff0c
7703c02cb266773ed01e96e524976d673cd9a41de6d4848bd8
31414d96e088c970aceceb97b648c82b2d9110f1111ba44989
9558625b093b8ab7f6504751437fb39c8ebefe34f4a6d5344a
d7268f5922799bb4489e4f2f2cafd9dcb43c267ecc07851c35
3cc5c05b3434213617a73c79d31b94b41c2f0a4636d39a69cb
309c2bdd6278755f2fd454d1c7e71c1dc09dc20751f3f4027b
86eb804ec3d3d10cee88a2a34b90d4c5e70897c051ece915cb
d1d9d98e50b23d148e624c58f6a17038d95e62da39ec2cf60c
b533490f8dfa9267ba7c9a273ec3eb632c6844a435dcbe8fc4
7d653d48628ca08fe31a1a0093c9a9f4e534f65d0c9ea5eb9f
ad4f6c1cb9e72f638bbe324b9df529e48e9c1b0f5c7d7853fd
da97ee5f7ee9aebb5f3c7bfd55d3fd7e85c17a60e943e75df3
f2f7fef4a3faf8dd6903de7669554fa74bc695f58b67f69cfc
c1c7bb1ff9f1e756c8adc15411e38768836f62f6980b0f9c8e
47f6cfb7c8d003a336f9d15e6257a3549b3c6949a45ba2f3b1
440d5df2e31b2c3fb9ec87498a80249dc3c9dae43b169dc449
7a63323a4bc4714c1c3fdaf1a3801f79e0c2473b7e54f1a30f
8fa673066869c9cf40f99803816a81c6352fe370e6830fe801
1688031f7f3947dadfe5c6c95ab835323cffa1f987e61f9ecf
fae76f8d59ddfdb88b306e9d7a32a92a313d595295bc9e9cab
2a33f5245215879ef2ab8aa2a7b09becd053655599a1a7f028
a45a5a94993366389d0e94efe888c51441f2279195846f26a1
963493c3c98792879287935cb286342b2ace5f3d7f7c3ea3cd
87f3e71ac9727f69750995b6cebbf80d39778e787c94143a89
23a394a068c9533346c0ff1af43425f5694c0db1dcdf5bc5b2
78661f06d5bea1787b8151a294735a081759ee21fce91c3391
0375088a00aaf887020bab7ffc4b55ff6992a148c250fa6716
d2ff3d2f355f021f45eb3021e54c13cda13e093352bb694e3c
639e9f8e4c6ca64f754e3cdde42afc0c9a8b6d80d5f6afe1cd
9737182a2cce5a73f2eed37405bf59bfe40cf2bae28cdb30f6
8ae4db48c92e37708472d7553a552d3a059f6e65cb11fd62df
9a6e4155909e945545d2931155817acaae2a3e3d25f9b0fb11
e40822b88b0804671196bc3492b40f0b63c261819914a029f4
0bab056695302e1c12188125b70914c3426df26f7bc86b71a7
6ec5a960ba581bd6c7f4c33a63eafdfa6a9d19d70fe98898f5
5c6c4bea7c30f98c8c363d10753b0d3b92a3b22be013a9d7f0
211531d48268ca6b103b19ff66eca7ac85aefba7e1c5034f87
ddf804f993fec9afd33ed18a937f607c78145350a2a3d83b57
82abfcab02684d78387c8beb09efb8619364681a9681a24263
30e3741843724c0c45104466c00aa0fe000cd418c7de48d66d
8fc76a93ffa063833bc7f79031231d4b27e3164bdaeda66009
770a0f0a4f0ab683c29bc2241e59d41ccaf7ac001dca101de3
a8f1268ee00eb71835d4b95b3ffc6d39973bf7ad412af40647
b0a26f8ee3d1a38323d5bec67adc949e17a38ac31575c57aa1
d3a13823bd007bf03ecac9648d7c44d91308403796e9efef1d
72db5908e87843d41cef667efcf40873a7d36ecd7587a6155e
a2032dcf7e64eda787227abb56cc845b94021d775b860ef6c4
e7ee7ff6ab837d9d11b5edc2eeb396325ba7c63e89d9f3353c
f6b3d11fe9d8d76ef03ceb41386ad800ae413778d699ebcbd7
771f741c700b570228b173f318cedd6819fa2c1a439bac2de8
7e6bb77b8fe740f1c0ecff76ffbacb2d3921e3411cb275dd0e
36766d05dbe1439e5f74094e404aa26c2ed59e70b7010316ec
55fb12fb57c0f3a5df800f4b5ebb33e234611915adb3acfeb9
8fc187d1a3d63eb4cfb1e3ac97c11be0107c05bdcabc0fde87
c7e05f1dc75c1fbae55031542a7599a5a5f07ef075f73d5d77
97eccd1508bde04d26fa1273e70441d0441e13301939145164
4e165ad34aa6378308994d3c470f24db34420d5698e853ac0a
e7e6158e28073d595095ac9eec9b3543e9b3b1ac62f35225a1
aa4a464ff5967a945e0840d2e30ee0407216002449b3d42c05
4cb304a0bb34cb36d704b34a6c8f1b22f25da53cef19f61cf4
204f9a67793e148a6c97fb7a7bb3d9cc8c9e1e2ce0b667e470
98e36c196413faee623da65960c76c70d8066d3534dd7259ee
7e371a73c31d6eacf1d0dfadf682976a4e2ff54c5eeaafbc49
2c60086a9b0286f24362eb9cb9cfc03e2cb02f861140807b86
f8c4b27394147cd0e564ac42aa62a33bd1279efed738c12334
58c0634552ce6451d4434bb9369204116e9be921ac3a4e6786
9a27640d0887aa606474f60596bd50ec985538ab63363b3830
9823aba58e6e39e4ae3ab440a5ab3679789f58b1444f851487
eef25400beb28b9e8def12c9d9f84edc34f34bb9dc40632542
b13ca60730728613da7a6630993411358e216ce620cf327284
ce28993258b8ab916df235d7269a79a5c6ea2afcfffa165ff7
34308d2e5a906b1e44aa53d6c0e3377c7fc5c40d3d457fb9de
4ee75b7ee2d933f8efac7ca15d9503d7c0d6994a5b970a3f6c
5f70f9e2d05e74aceebd6100075319594e97e0cfeb8b3ea18f
9372c3c5586bea17fb87a0786136114e61bd1daace0b3c85e7
6c2b8e97f6e339ab813f3472cd2210a10634682557a0cbd0b5
68b376bfb64d7b4a73c1640dde61153d6bba97a18b12087b1d
464f86a629be194987aa887a4a533560020b30e07f623e11c5
528811f0a41d4235f413ab10fadf521d76bb8302cd41af3a28
d01c5bf58b074f07370d4e3c7e9c1615e199f6d620a144a215
46b15650f662092e895e1aba8a8889d5f8e3bb861896da8a99
0a5dbb1af407c38cfec95c4530dd14073468ed66efd1d79e38
525c6e0469b2e2d2a1159ae8eabae992fffce2e5f05abebec5
98aead65ae20890a03b659eb4f6e3f5f0d06f2d78006f7711f
e27134114bc7f11daf0c3d40087b22eeacb7d5dbc69abc3403
ce280cc857c1cbe52b0bebe57be1038517e5dfcaefc0f765b7
5b868e3067ce33996eb9db9c2f33213323a74d86936d6638cc
e4402b3eeb053de18a5c8e94cd6ad792aecbc1f5609dbc3eb2
d6dc0c36c9b798f7837bcd6de031f3a1ae1d5d2f855f90c7bb
de08ff463ed47534fc9efc5ee470d747e01fe18f4d63015c18
9e57580907c2cb0b9f0f5f17795e7ece7c557ed57c5b7edbf4
6066b2eb494d55a27a324f590bab44414f8934dad529639150
07c000902300466499d0d54cb31030e5b059900bb0803f7b38
1a8984915d100030cd4c56302fc4da2652c827354d7f48dfa1
131d7158e7f4ad5617ec8288bc855bf46a5e1fe69ead9d5460
60eb13dd780ec97c900ef686853a8640934c1af291ac5a9d2a
abc0ad4c3bf2693589d5c908660c5a4ea114c480ab0a1b07b1
22cbbe8a2c4a1520c895706df2d0de70256c062a8d6233fa18
806439cb7241b9c0d82321048448ac11e7441067b44e259fb3
a793cfb9ea1423e894043e490124b281f00c8d73c6d3909937
715c31facd7ad65cde120a78169d0fc7e007f02d385658d112
8a19fd85897173452a34f157f69a93eb6e54db0ca3a48d32eb
5666e319e3c4eb2c3d3db9f9d4139b4fdc0ee0e4db93efe178
7831c8c08f292a176d96a0742784c85a52be1341298e600675
f8a7fbaff3df87de449388f7279392482283a44e2283244310
910a1044a424c90771bc2725039294c46cf06dcb9bd90e1d76
3b444a5490ec0cb5a44b3adfe7d34453b44446c4c4bbc787cd
2a4e0927d2a12951716b2bc9c389d5b2d50a35f2f567875b51
ab3f40de22a8eb66128e27711445a3261a00274928eca0f154
247bf1b7a718a2a19b4e6543f105dc3f42cb9b1a28397a7463
b3ee46aac00a05074fcaa4c120712459bb14915a611554a425
e06c691558295d053e2f5d2f7d036e834fc3bdd28bf01f50fa
138224ee1d00233938329b7c5b0f9a7c7c7742aa22b20884fd
0e0ee0dfd987e168c52aa4bbabd928b4d917a960654ebaaf59
5ea92285a40a1283f811a9e090f1b55dce0a7e9b438de66f7b
031564f9a6bcd3a9d55582478a463f52ec0049f68ccb2e5075
6d47b212a37ca79c52d75d342622406430124b9f10d7a97f86
264dca297098994160065f23006c39f96525bd04a391a0af77
466fbcd7b6f824cf78a6f07562133be7e40f4ea1edc9b9ed7e
fca968fee53aba174501bfa488ebbc577a9cdfe6d826b2d7c2
f5fc46781bcfce16dc59c004b39c5dee23dfc182002332a4f0
db626cccc2384145b45ad6e2561cc57d7de47b5b5063697361
acb9804152dee78823b98f1ab9efa9faeb2ea8903aeb68da9f
f6b87c1d408172070cf0b817b2e19ee87077c008c207490876
80301bec00670e71ee4b9830949dc08da3cc3d4380e182584d
ef1ae2eca78aacb163f4894027c769dd2451efa345d6924fcc
a4d15128c09bead7d7dfafbf53bfe98d831feffbc2a63baedc
7df0ef9bbe60bba27e55fd95fa8bf5cbe11db00fce7e69e7c2
8d8fd79fa9efd97d1b6c83b3e0454fdc86c70e7b103647e3bf
76b8b351a993c74371574fb990bf465eabac8dfd9fec70feee
18bf5ededf7220fbbaf27aecb72d5c2423e6b3e98a51c9f466
cdfccacce732c3f9b1bcf37900a3b1d6d8a2d8af23af2bb6c7
b3f0672dbf09ffb6e53799d7b2efb770312b15cf0a1e42ed49
a82abc9ec2c41fd45320aeb5b7c5b3d5d492144aa5f8605b36
140a228117241015a366d48a0e476dd185f9e65a06c8432bbf
238f1ecc8fe70fe5997c3ba42e1e52670ea98b8749af87cee1
664e937a78cfd68e7c0d5ebb5b2749cc4fe8c8e62c1e3c877c
874d9ae97857a1cdd181464a936ec12125a815a9a101c83a47
4b6b38261bd9746b385d842d317cc844da8ad05052c533d639
162ec5215402935aaa974d26b45e6c4515409adb02b94629ca
281c25933ca7ec8ca76afc7b7b87e27121d856e3ffbc6b2818
a0532d8845b59d4e35e113e94f9af4fc17be2773ae2bd45c40
cf849ac55d64fd1c3e124b9f539a781a2b8d80829506fcf3be
5f6e79fdbf3a4767953f15bffcde05372f2df6a31bead78ca9
58694c57d73243a4b768d7f58f1df2cc7738be3576c1bd8bfc
44758c4dfe81b5e1f9361ddd4f675b44babb1d7aa1976c8af0
b259d06acb2d814b90ddd75383f3ac43ddd3bba38cc2ae9257
45564557299ccd6df380b6f11e76ad73ad7bad679d773831ac
0e1786cd4dc2adce8dee8d9e9bbd1b738fb38f1745c95d7497
dce578315e8a97c9026707ab2534b5b5b5a33813ce4455d68c
98095335f519a519e505ee056d4b9dcbdd2bc4e5adcb737115
aa4829aa65a57ba9bc34b2343ad07551f1a2d245e58bba574e
f3304e67abdfa9b4a69c5a4f6fabd9332a8dfa37b5dcc7df57
b8df7cbc309efd61dbf3b9f19e633d817385e90ab80a294fc2
9f430437c0e6faa8e52e3fd01953e257a94a2271204eae9422
0f04da30985c9e80cbe5c9b9da3c6cda4e1b2e0527b04ecb76
32a92c59378556225982504dc3740da62cb1e03be8436ffaa0
e67bd2f7a68ff1d5d0c6fdeaf6444e2455f5f806f5c13c3c98
ff537e1283dd9a5fb6f23fc7270cc86b79134f0136ff0c9c07
2a701e949b453783b9114c50a3c74931fce8c428464a83ad28
929be5882400f234229fa99c2ded0d427104f71ba5d62d26ef
cfa69dedf62268f51298fbf18137f1a9a3c355044e577b2e23
62d07b3dad6d8684812f14b82204cde42d3d4cd55d6151333a
4822a84b9c97ba2f132fc991080ae25907461a65a72ea7ecad
b0a6b752c40f4290038ae52f973b23914e843a138940e77426
6eefe4f0c4d833d4c904f05cf9d319ebbad57f5d222289fe46
314f38819a755b8dea7c5f3181a66a525bd253f5db24cdcb3c
614883db2fbafcb6dccc779fbd7dd19f9ee92da93f8e46e2bc
61442fd83b74e3d7a6f564ea8fdcb5f8f0f786d64f0f477507
26d9dcc6873ebde1bc99c545375e7ae5d7cf7be04dbbad9a28
c05ffcc7d756dfbcb2ebd2f6c48fd77e65e97ffcaa1c510b64
eeccc47cbb83f02d4cd0b9d3b312ae442be32b1357c02bd015
f12b124241afea4bf4fb6cf72a8fdb1e537804e38910897492
38f6f1ea295e4e0115895e41afa171cb6f873960853d55c98b
29bc1f3c494a2251d68a0a76ca8a764a8076ca8af66438a4e6
1284463de41520212656251e4ab08903280b42931f584ec299
21ca9621fceebbb535838d05c1e383841a1338907596c91bec
727a4be48bc4de12fb9acb40c4b6c07296f163eaa923943e49
a2158a2f90b57daa6cf7a14442145419874c7b8754e4167d94
dac4532a8214769f4ad3a71b6b3967501c8d65f9949ffd9637
edf4ab972d3d88254361e287443f3cbc2a5b3a9b4f8bb6c5f5
1f2d6de99976e2f89456605d1effd0457026b68073f2b06d27
b6401e6e6ff83b138ba9b642c9a415362db4b5968662a52cd7
c32de6d67b59236564ba525d99b9a9b99947337c6ba69241fd
e65ae70dde073207337f4b737d9e464a4f5595889e6ca3893d
3f49c2a470a882104446d66d6fc3caf3cf7bc808e3ce112a4b
69878c762bd19fa2dd2e58ae8a6061192298021248b6cf1708
a065024deb0b1ccde91129db48a0d24f3aa75a164d386c3e64
ee300f9baca96ad4f01a35bc460daf252569831f5ee5877eea
15fd1ef29c3f419ef3470ac74fabdac1a9c897d432535d9b1b
3c1d0ed3bae6e6c20c76838bce5bbf739a808922ad671d3eb2
1f03715e2363b478b40e20fad2aed60ee874e8a2d101b24e83
a81e4869a151c20c07f1cc0723842094bdac0218394cbd1d94
91dba0f1b4bb31b98bcdfcfa3f65113369ecee3e91bea593ba
e904995fc0c3c5fe5cf0bca32ffdfe88a9cdc571f5d9a5a52d
91f8e23b2fbfe597e7e0409ba41567ab2313bf7de90fdf7ae0
cb037f45d28de71a46b9657462e7929746cf5ebbf73564e098
9bcc5909ebcbef93398ba611c4ec71783915355669f6846042
74e30fbedfa3a210ef413cad05ab8a13870e8dc30229f97249
a20e4382b3b22d0469b996dc28e62a961bc55ced05da5a3769
a9d25fa413ea319d39107e4a7e3aba43ff3b6fdb16d91e7dc6
b68f7b8ac721d577b86dfc7783df09d9bec16ff16e911e086d
d16d9f0bae09af65d73bc674dbcad08a70bffe59ee73bced42
7e40b8d0f169cf40d066e9fd6029b3c2763e67d3f4123b3d38
0f2cf4d80cae95cf0ad9603664c3a24437f5d5383ab6355390
31e0d13547281a6a0b3121de4dfe44c5c3f19017540fc93e56
07c589e79e7b8e24d568ee51b102c00615e00d8a8ad723e09b
d57042516b931b2d5f88e73481e7935891605562e33802f572
284c76c3a95eafc70310cfd94f8461f87fcc9015da123a1662
43ef98412bd81fdc113c16b469c1d5c1e1e058900dd6d0fbfb
34fd1e9dd480614a1a8c1c1f7c6b1063a41997934a6ee2d370
2bd3cebf2ffb6a6c7838fd43639dc11c1c25aec8ee90a58ad7
922a2c89a2c48a20f82b3c8e98f6f92b8eac9f5c7d6da7b732
a5df07c81e89fd215e4c40c6e3a610c683c413ec52e836f7a7
703c1ebf14249496c19025f5c261089bfb22cab6ef2f30caad
f58c5167336264e14cd4f6e9e9793800ad42cf5c9bcbb6d870
eb9d9f3df145f66b2b036aca6618f67c4bd7e74fbecdf8d676
c4cb4ecc2f74270e6049d4ed83058a52c9c2f39d00eb33fe68
69ba77ba38c776b6f75676937bbf9dd4fbd90d782e980bcf75
ac613fc3aff6af6547f961ffadec4dfc987f1bd8e678d47d10
d4e04147cd1df08a368eb7310ce7b371240d9eb43b0276bbc3
2e0a0e88e3151fddfc675945c1e14cf97c80d423f0a4a2afb1
01fb418ee5a2057fd5bfc4cff87d5d9a08c53b8488e45faf5f
314875f839d88a986e8e0cd26d95e7d0ea92893ef14873fb73
63735023906e5c39ed4c608e186c0f105d24bd7a6c57a0e2c0
b1ecce463e6540d96fb3f94451f039a968f02101d6f80fa754
f4997bf7a04e8abf18bd0cf564c3b93c70f216d43eb6a9ac5b
27763097d6cf1dbab8184cc76c8b4f70c34f70f5fb0df6d5c2
c0f5f07c52e1bb70f228b3897912748119cced67d4936a55ba
8656b5081d07153e6f084e275a66504a3680ab48320b4e4942
cb8a21720b3eff3d750f45c2fb4142d1457a6fb1c2d396efa0
219066c72fc91741826d6d374b2ecb8edfd465c5e3e4e8c34f
b96a93af58097293cbc56e90a14cafcaf40e5934127c5f3b0b
0a580ffe04933b5dc2cce55e2e4c9079fc4aee6558c02714d8
e3e3bfcbe57e22bef232595853acab9cb1cd45249ddf0d254d
ad8c551fb7ef7330524eba11dc58bc15dceebcbdccc5a5508f
581dabb2f6d862db626eae3637b9b8c7aa6e8a0b0e0faf81e4
42b8c8b1d0b9b0bc68daec9e853356382f73de62bfd971b3d3
bb34745308a9d55555b45a2882525fbeb5a3f434e61317704d
8eefb3575c5967c54523f49eb2e8ea77210b1f56bb188d36eb
5cacab4f26698e56676589bc4abe4a660af20619c95f5431da
f05f6cf6597d08ffd9c3647b6247198f5b8d9967f958677ebc
0376ac3640d1ed72954a78e04f620b70cb8a4f93af010706f9
1f3d1560a8c698b1c5602de39881c60c6888e426e369341bf0
2088195dad046bf0322ba1142a9dbce5a9687c3f3fc633220f
8ff19014dacf9e39fb0b0d713e323a9a233b1c72d8a592a813
eba7a9958a8f06f104383ef1d6a07874a47a94ac6ce47c1572
4f2e576810f32ec605c1e040a378be59373fbfdc1b4bd9fcd3
a6774f479c5d700888d3935a127165674503beb83f0624bf57
75c76032d56babc4c074a1a4c172c929c5c418f424f1a187eb
8b015af045047bd347b7b5918d9270148e60273d8263d4d917
ecaa4a906c09cb013aed3af15f9a276b1c226df6792ad334fc
b7930c948b34872da7b3226bce4a183f6204ed512766506765
5a96b40edc3a706bc7adfd54e669ea6700901579596613ae52
8d7f67ef90cb652644dcdb3384edd95a13dc7b864c27db5713
ecbb865867330c38551644167aa736a14debee9ed6d88ac905
c3815355e464b524482bc7482d59906a0a1fc7377772a0f95f
6de99eb1ea8644eb8b1fac38bf6aa451216d14763c78fdb9bd
31c911f68aae60dff0a59d3df0def62573964f5f7cf395bec8
973f3fbb73ce75cb5b365d9a4cb6f7e4bb4a1dcbb7b4aa67e5
6ea9bf70536f8077f74dbf67ce5d70b02fd2bebab26015e68e
c913936f314fd9ee0021d0023f3acd1d3b1336c2012261035b
c005649a80945d442e12aa7011a0924bb44398c245ee7793fb
5d2e390c5864f793a4b12f60d9f16d8120500cbb531fc0f284
4482d5dfe51aa1209de9bfcb8d8bcfe3694fbe0ca6e1ffd3f8
2d18fc16f875e435e4b5099b2d6d0052d3cb2d9311c13ff938
7fdb43ce71e78ffbc925972b6d34aa2230758c93decbcdffef
e5c6375928d67a310d1fe1f6717bf9f754d6969eed1eecd6d2
d730ebd85b998dec63cc13023f9f873d4220e39ee54f04e6c8
6117609510c012ead427e9546d5b6c68b56dccf6a48db1bdef
0a0120b7b85ca2bbdf3decdee266c7f061879b016ed1adb94d
dc1d771f72f36ecc1ffbfbcaeed5c68f1635eb91490d41637d
706270b411238f567de10addd14f275736a2314e3ead31090d
461d720c4464a72b26e03395d53518712a3110e714adb925a5
a98dbff4253c6568cdd2e8c080b23b08905e13c27b86b02a50
685d9b7d0aafc4f99cde9687f1d7c8d4648ca2cf173ab52f8f
e760ef2d0f7cf597dfbefd89fe47977b3539d6e681fe8ee295
950bbff9cd35e572167df4d49f7f71fceeb19e1e66ef7f2e88
8aa9e189ecc41b5dc5ff3ab8e3074a006b8379186767631fa5
a324fd360a8185535e0a453f51f84b3d0d1732bc767eb53eac
23224d69f9911ec77e658f1f4723b8f3b37dc46fc53b19ec48
b093c80d567f729482e965b2cb61a744eb8eaf6eeb288114b1
70d8bdc28662fea5ecf958852ee52f502e88f197d9d6d9c6c0
98be47794e3ba41d066fdbecd3e07cb85c5e165b955a2daf8e
ad9347639ba53bfc5b7c5be4c7e023e8c9d46ef843f853fea7
917785b762ef69c7a1cca1b3a515d2edeaedda58ea588af769
f099c9c340c30f15d312880342f326c6ce6a7d4c474017b1d2
252525c3fa963356848ee96efdd2f89b5ee8fd69c8b0f37192
1c0f5448634d972af88f74ea2fa92eb8c475a70bb90a225d6d
5c0d86c116b0038c83c3c04e2e20f0ddaba33745517f143e18
85d11a7459ff8fb16f016fa3baf39d3323cd8c46afd1481abd
a591f5d64896645bb6159b681c3b71f0031bf2b2139cb8247d
417a639bf22c25de524ad3721b97b6d0945e9c6e9f977edb98
e01087bb296e9b5268eb92ddedb22df7a6b0fbe55228b8cd76
596e5bb073cfff8ce438ecbddfb74e66e6e868663423fd1fbf
ff73a44b2ca25891d5719091ed6ee83e437f5e77d2400efcd8
d4e4cae4d8c549427aaa5a5d5e9e240ae2a2546343615b687f
e8d610f38510820e06987fdadbdb513b297882643855d5d18f
b712c0d215c353a328d6c3cdcaba703302903a19386db79ba2
51c62493761e268e092df0c1930719f37be110d85774b9856a
6eaad7bbd55a7910c9888525d397f8d57d5f7d0da1f907be57
ca75841de6586ce3816baeffda919bae6b6b41379efa11625f
fe15b21d1d4c1692eedb23e1be9bbef68d77ba1bef02bcd473
f9a2c188655e84cad353ebf052b240328f32ac979020af9323
214d4a09c94404ca668518c5407d0a318a15b2379efd93a65b
bc5e3842093e0da96e001e208935228130149d9ac9862d5e17
85013497cb310405812c2ce005d550cf058c7916092943725b
ed97b841c247518a9961e0d0e0440869a1f1101d8a98f169cc
32918ab2014420be42176c1583dd8ed734bca32885c60cd987
dc1cbb83650b8d444e2ea9bab884943a1504d085b1b1a5ea32
96955864624e3a4315b085d8dbdb520086daa436b68c17ee31
dc63fc8c61ba70a2b058e0b4c27481a60a72d6adee30eee0b7
ab0f73dc560e298536a157d8297cd9f0edecf102b758b8a4d2
8a4229d1a7316f98b166dedca90c297b950f080795bb95596a
56799c3bc33d9b35277967cad225859d3dee504aee0a86433d
117c98d99073936f2d9243b95c8431472873d4a200e891dce3
f2b47c426622d876a3e53732c32c58b5e9c616d89eee2db3dd
8ddd876b1e86c1e595a9b1ce954ef883c8fa14be652c704522
7129f18ae0f52755039f4a24f98c42a906bc4a730905658d39
a55efd015504edc00fe044475350bb8385ed291715319b120b
dceb84c2730bbcf10a8593763d895a0e92841140f98ab8d571
80c7182b3bc06f58a375fa27ddd37d0fbff2a71fdd3584c5ae
5fb52247de1e950379f3eaa546b6737f6164f39eb9837b3eb8
e59a777efc63d43bf8dfff1b91beef5cf85a6fd0119b7c1efd
aa67a232f4a1e77efa4f40f95013bd8d99a35c5488995f47f9
695ec69ad662c7a44ad9c8a69685ed2e6a1482f4061a1e4e4c
430a0991c030d01c10e1a4287320e1e0a02e80860a8379389a
23321befc7615bf54572041efcf434708da16436137103e89f
64ed82db678c903f060285a5c52b3020e49ea68e6321c7d433
2cc845e89fa8d733c481d4454ee1e63886e2c639686560e01e
32fcb5e1a481818fe2f0ad01c72681ec5dae4818df270cf1dd
62f680bbc51b9b0c53365b247c35785097ce037e183b870df4
26bd7614b307a0089fb4cf3be61ba7c65d2f32469f12c41033
5891b5602502572574f7b5f011503c11428ae91632bd2ddbd8
12607da611e75e799f67b7778f9f438c89e54cbcc5e8be963d
423fc83e60f98c787fe8ebf477bda79cbfa47f6d7f497c8bfe
37c6298d73e3fc04bebb23a61f70cfd92f71587f72d64fd28c
09f889c5fcd4d76ada42f79a8622dbe9eda69be829fa88f388
ef98f31ba66f080bfc29d39cf013fab7f42b96b704177f9e43
14779ea327610bdfdd0cfed2e63896fbb8c1451565375caa53
aa48fbdc87ddb3ee97dd06b73bf00f06648060ad8bf8244eea
4e086dab5481eff8c600825f84fb392fa70315bb8c0ec987e5
a33223bfe5724d43f2e50c4f17f9a3fccb3c23f21a8fef849f
e35fe159fe719bdb401d01ba62729a54b441951d43d9449b62
632ed9900daec484bf4b5b77b8bb8699b0f932b83209806912
12af96b18d424a53a780a4d429ac40c04e38e4c676820a4d06
df1ac30a8db430a3dadb21e7bf7b649e8527b34f8e12c38638
5ea6486c9bc39f668e552c5abe62c50b340f3c9906c70b6c40
969c0ce8af02fa7bb55782fe4ad05f99c82bcd66aab8455fc5
a7382a568584b5917a9585310ab282e3cc0e37b5c0fdef5307
dd6eb323406ac61c9cd9406afccd57f462dda470b29e5a9d98
ae2125d0908968520f2cbc840e1c7860f7fdf988fba75ffee6
1bfffad4579e5d79007dc728faf6b76ebb8feef8f9473fbaff
4ed7917f46e8d76f20ee678f6f1889b76b7f05fec5218a62ee
363e48a974d73aa990c8137d98d740ade5892f21a022d1c622
de96413c89734a36c8f59480b16d1211197ac0937d5acfebd6
043e9e087b28ca9eb12fa0c04989855ad5e54571b1bab42c2e
eb4a6f110c8073e2b3f0ef1cc9a2ad098033949d1c43e143b5
50868de333f119441818b1c0b9885802e4327ea59909179379
fcfa256211d86cf95c5dc55d8015fef8a5253d761ed0367e56
39e63e96647a981ecb56dffdccfd16e3570ca8903f1c85479c
ccf2b3a6c7c4c71c737993c862f9b62fbb4fa583bc6d3ecc3f
d480e6c3dc02c36b91587836fc4c980e3be2090f5287b1c15f
cc662407cb738288196301ddf0e4516ce42fd06f9f44597501
899a359d4192dd213e64b7a33810f993e3e32d64bb6183bead
56f56dbc44b69a1c8cb6ccd810b0c63edb846dd176dec6da7c
b9a71996e16a41379d98079731c9136bbe136f5e1dbb384562
209d9d2b539dd5156ccd176af163299172c9c9843b9990d341
2ae58a07514dab812a838a464ca04f78e20bdc9b9ae96038ec
c0bfa1039bbf6f3c7530e360d7e2c1821e346956f512d4f744
84c1191e2b37636bb756e60e9a8f40396ce4ba9bdde85bc1c4
c66d2b1732e94dbe9327474e4d7e7864434bd8d3dc1789241b
b5e09bccc0cab7a61b72f178bae7267af7d6ce23dfbfad27df
1e2e473fe274963ef8e2a6ad58255cb3ba85f99fd8b2e8a0ae
a5469915bd3799240f3f923cd6ca5079710f7d7bf6f66d3495
651bd91b3eab18aa6d437b0eb5dd969cd8037d28eef37cd27b
b4fc998df76d3edaffa9a12f79bee43d36b46038639cf7cc7b
9f6f79be7f71cff93dafecb9b427e057dccd62d9d51ad963fc
36dfd75a0d5032d31aed0b50be6e098a8cad90a46a723a5d26
7e3a81a404f8d224acf712f033ba2c55d86a66c95c9d4d9c48
3c9360120be8b15323ea74145cf2bfd1acb0af341b3d117d26
ca446bc7902d3e248af7d5bc337da80f7a9df56978aa2f072c
d747d2b511af390ff1e8308f070e08d694d963dda87b812969
165f9f50f0a161dfb48ff69da5ff9e6231530e529df82d81e5
7cd7a3eb7339fbe0f79922d6af61bcae50834c518b884574a8
78b4385b648a5ed0e7450bb052b15c6964a6b7a3ed706f56cc
e578f0d379d14506bf217eabed7ab21266c0ed89481aa509ed
7afc2d47d368283d915e4c9f4f1bd236d8335dcf8cc283df6b
12089af46dca9ee21e6dcf71fc9d1bf7c0a141b3a5658fede8
c35bd016e2f1da525264649727e417b07259b8fc47cd41e285
16002232b94679813eab398f5551b5546486197a9841906643
33f055fa422d648bcfcac0c7037c87c169b847e6c3bbf73c8d
eea4a24878e208344025b1276c1b4dad90c1b23a75515427f5
9c75750ab48d3a295e240549cbe2724d09adbc0a2aa92a428b
09a8599c12617fbc33d64af32f445f8ed2582f4dbdb50c0e7f
9849bc9cc033537a8630f135af7588abfbd7eeeedfb56173bc
1c0c79bcc8984c34959a4b2d2586ed4a0e251b13d9e4cec4f6
200a768483547f7950a136a1aa425d63ac06a9e1fc6090ba41
ddaea01eef9620da91da15443b77853604f0ee810e6aa0d4a7
a0febe72ab46772b1017367406d17585eb83d4b6ccf50ab5d9
d31dd43b97d423e9b5d5d54f35ca92962620342095184d1255
aa098d22a6d1b228815feed213522d9efe04ef5ae0ded61207
31a96282ddc7a3211e557954e0518447761e490ccf6aad7d39
2ae0eb5ee05e3e75d0e7eb633bc988e5aecfd9498f06a20fc9
d7e31797f6ed5d8ba0ac6b96e221d9fde0d36063b19a09c9ea
ad86e0df5a1322bdc6aa8d1c85d6fa6e90162aecfa57f87579
fbeea5e3f78dff50b531ac91b1ab77b49ffb664f6f2e122d06
277e71cdd8a19bbfface0feeef373bcadcbe16b582dc7d077a
5a86076edadcbcfaa74271c381b3f3df6d6ef9ca3fa3eb325f
18fdf439cdc89a3c7ec1c86e9d987eca95acb81c0a67608c26
ebc40d93fb1fdad5d4eaf5263699f6474a91d85efa81dbef7e
6cd7a6a9bb67776f7af7af9a4712c5f8c6c35b5b64d980610c
65c59afbdfb02ddb4a9f5da7b943ed1a8807517008444d0bde
38bcf692c0ba17bc66c0795ef09012fbd66b0356f026419747
6022196d29a7f2286ab058e81d51728e68de0be7c8434d08cc
e2c1dbc40598af73321ebca9d9096420e7cb236c8376091808
487849e0258d9714d5826181bd4cfc82e5562ae508e50ce015
2c14c01226555e1068d1ad6102c5c573cf3689e7547d66099b
c7e7d659c6232d12307e99acf127a65af049e1948e9440c081
40008140408350f31c92a99a2fd1dbde86a2643a4aa6a3643a
8aefe612916978f0c77978030fde3d0defe5f3ed6d354c4120
456dbc045012df85ee6d242d46206e5168d7b265a17d1c5b03
f6843d39dd3ed36e986b5f6c3fdfcea82c1a6e1f6f9f8029ad
1d29bc3713762c3076cdd190cf84537d0d42262cf6c5a29970
7281b1698db172aab1ab255cee414aaa95227789919fc3210a
3e6fdc3423a03901d98509615678413008200a13792a1a6f8c
e487f3e3f989bc613a3f93a7e7f2084abd17f3e7f386fc78db
b70e9386167a991ae0eaf5e56acb508f53a97518ad4107973f
68e4d944201934fa8288e3fd5c08c043cdf3485cf550594bac
61fcfb0a86d0022f601061e0ec8934e39008727008b58202dd
28468e56bd24a79696aec3079251a6e7cc10fb186a0df4caea
9ad98c060f7da2ebba8980d32614b5d58d6ead4960223dc5d2
cd7deeca96d50dd7c45c5e7bc4ef2ed89064fcdcca4d776fde
79a3f6f8eadfee52bcc1783c9514af433d0fef2db40cad06f7
3646e271a7d0be93b94637a1c15eeec42b0e7397996aa00f5d
e1af33541c2ba710295cb512e6b04689d727ea053e883abd8c
096b35a25f4c900a4c925fc01226b9300b977ff114ec6db27a
eb5a080ffe65bec69cafd499f3c553843715701d7986a287a2
873134683884b97e9c452c41e5c4c30127601b582746b62f62
45b334265e18ab7993f448da1266202cc755682dbac6375685
704c94ace13cf3fdfdb54157973ed07c6d6dec0e0d9c88c759
1a3e94a2946803e784db7b5b0bc29126533c6625dc63a58149
ac847be0ce74eef1829820dc86674eeb0c178fade318ddcec6
d77e61a9baa4079b6a8ce39b89a3f1f8447c267e3c7e296e54
e2c3715a83551c947853530bd9b66fd0b7f9a2be8d25c8566b
f4f95b303b39fb1aac99b0849928e5eb52c2d11e8bcfe29cc1
b752a1a8060be794841913325500179cec2ec346b357cbcc2d
168bd5678d7b35b5e22571bfd60d2d335e34ec45e3de09ef8c
f7b8f792d7e83d193bf975c23ca45134700c8603cb3ae4c668
00ba12ac35e7d5d526660cdd297f8662f9d2690d5f04e770ba
084b386b60baea5f7e6f3fa535ea6f6d5debdd8ba93f93ede8
c8663b3beef595ba56bbbb1b03262eec0fa66dc865fc1cbcd1
99cd76ac4657949d154ceefece1de87d5fca293e7b7c82a22f
ef5fdd828e1a8f62dacea04beb748739ed24669f3302bff25b
f320f4c9a046c4afd489f8579a53a7629d030498b646162eaf
9243f0e04d72081efc2f7248040e31c121118acda480aa2d69
0ddca3e98c1cf88548159697c00f2abeb854235e55ad93affa
2cb6d69efaaa1fb13ea4c2ef516d2b5bd59358a46aeab03aa3
7ec7f69dd0719555f08b699511f1cc7995f1f3e994d2950aa7
7b7c704bec0ea7df94f505948c859317904db38a1465e1f027
db672151017d50ebcceac4a0f5969946d5e3f1632ad0699b38
53e14ef13a1e89cc28c8ae20e8187c49611485f85b172eff3b
b691c1db7a32abfe5d14288324f9d6a23c7a52d3e6f7f7bc3a
f816a6110c13c1dd5ad5b9718e5d0acc13aa5c9e1a859626b5
aea4925a6befacd74206c3367b2811b44782286c0b003e4375
8b0dab1e6cb205e66559ccb00b7ce9298d42194e0c2c70974e
1e14edc4938009abe647780f71ad0b49cacdefa1b1b4dad9a9
62529a7eeef89e9152d41f70bc2fea6d94af50da51f27656ed
5c55defdc01b1737c5624d566e5762d7e7e9071f51a384da10
750d96a4762c49dd7ace5b5d8e7ab0182172d465611157f329
90ea5cc402c8401650beb588e3ef08eeb0d445a505042a0938
62ebe31489411acf6280c143bf2cca09b5e4ceb5e82364455d
509bd65c0ebaec39075e87755822e524d2d0451ce8107ca428
aee66dd0fd0c840ce0a274e166d1a10f19e8c2cd62f1c857c1
812af1a3833c3b3de359f45cf2301e62e06f6981adb6a1d2d1
823c27ad075a873d48f30c7bc63d139e19cf71bc2367c984b9
be069409b3a9583d1c892f8963050ac5ad96da69f4b4847247
cb8c050d5bd0b865c23263396eb964315a4ecaebc493aed4ab
9d57041286ebc4e627f268de4d19399ec8214e58eb1a8eae16
3c759af898afa577b55a6df4db225e7fda811cc6cfbdd3b5b3
3d44840ca33dda4b1428a21c14c516b16dbecbc0af93309e51
824e478947c9e3203fba63c740b18e238bf053c30f0b339a1d
7efda24af6524b6d5bea7b6da9efb585d424c35e5bba7abbc8
7e5d8484ba0809750db8e0d306eac70dd471eb40fd0478f017
cd07fb0e08709a01951cae92c3d536922503136da415451b64
b7903cd5b6209cb88d8066d8b58d26ef9312e836073987839c
c3012909fa3994622d5af443fd1c4a964492162ebfa4996157
85aebdff2ea65e882ec9be42d3e6ad202c95deed3b34d8a7b0
030ded38b4e3f00e66c74eb6b7e44de4cc5c67cea847d60b00
a3b135b424ae2cc25f1d47af49d3ab863526002bef9ca892ed
b30427acb9e0b44e7c7a7c763367e4b6efd8c9794bbd0ec20b
0e85849b1495806695cca96d5de4551779d53580efe377a7f5
00d4481b981d30dda6db1f64f047f26e5bdbc800e025981ca8
f3161efc89bc3b30303a526329c7da5ac4574e167c0b14b9e7
a56a15ac704cd773d6feed23cf505b2ebf466dc64b012fc5cb
af9df27b7d5e0cf6f5bfd180166ce1ce8ffe4166a631958f02
3a57ad68661483702513f62ed0efce37b465c2253cd0cc0d03
99706f5f832313f6601c3e1f5333e1e202639d8f7565c25bf0
40db18db911aecda1eded1c367da06b54a26cd535ca277e72e
f86112398b60e6588391ebdd522a7a3dc228d62ca2231e2d2a
6842998316e6a8acd9db328d6abcbdd88626dae6dae8369893
077775c507062283c383f4f4e0cc204d0d8a83f420e6f8a75c
72cbe0f8c8e802bdfbc92846f00be8c0fd44ddace514bc0538
fea2bee9bc0ef40e9411e2bf2af93f087d9a3beb1d30a93584
5fc7f80d718bdd9a8825e3966810d9ec0db6c47a8c3f05b98a
c445a8093bb9cd4d059f6cec052a3d7db0e4ed1512c64e0cf9
9f3c683692b68ae02024858224dba04d47faff0fbcdfd65a2f
21c1809ff35c913d6bd3dc3a43e02a35d58c860f48f90f35ef
bcc7fdc1cff55f3b1995ad42eb35ab9dce8ea8473004523bcb
b70cd0b47bc396d5d240c56c8ce6865acbdbf2be52ff6a47b5
c94f9459ca8e5c2afde6017b327b60df9dfdfd3b36dcb37afb
4e45c67681478c3986d167261ab5f256b3bada4f8c8578dc71
039e2b69a15cdbaa7b776b201e0f74ec407b1fc9e94a0fcb3f
0bb6ceff0f967fcd8c61bdfc2b13f95724a677492f13e2ed72
0c044923bc8a85e2199e08b25aa70a2245789918f1b5ec7812
7b96eb424daea7eec9e04d4bc2ee3215220787c88942e414a1
0cb1e133c43ccf00cbd5b2c12fd5b3c1dfae6583638928c011
192a48c78ba4fcb344b05aa9c90a4d29a1914b836ed56ba6b8
3ddec4f9737a6e4fa1a0776b21193e57d9f1eae23aa92382d8
117553fe8ab0d95b9089a791f8f24a644c2ea0a49fdf1ee789
36e6897ce189ace16512e296c994ccc3942c975ba810d93344
2642e4cd10b9511205af0b990c8820d8239329b7fc674d7a6c
9a6c28639b9e2f83d4289687cbe3e589f24cd99837208d8ca7
f1abb9323b573e5fa6e7ca681c4f2c9699102f67c276ddbccf
64c2f1be063e13b6f5c54299704c37ef4ba96c57315cea0952
b1a66672c7f158cc6eb7091e39cecdf0680ebc6413fc2cff02
6fe0c1bc0f649a43f16c24339c1987de5ad39999cc5c86a132
62862665a6262c2632e32dba89affee74d7cc9eb635843c2c7
7882c8c87a8dfe3af393b47992398fa6740bbf89b30bb47f81
b7600b9fe61a442b134f90b274bb100720b1dec8ffff9af898
87d74f5e811acda8ff6b0ff51f54649bb9b469b5c3a9350b86
aec13b6e37db80755d5b4ad8bcaf71eef20ffb7776deb37ad7
ae888f18f7f62174c7c7273fb11a1a934398377b0fa0eddfdc
ea279c4963c57091398339d34e85e8fc3ade0c6220aa27b111
4049a2e01611d2662d7e03701bbc0903cd099306b29bc193e0
cd6282d235b09e86a45b2e5742d926781ff6f3c3c101a042bf
c14568d4651109861409803410bc014383216cb1e82169a2f2
801cb1cea3eac1abcdd2b41b7d5b7e4afe317ade742ef46b13
2bfd56405b4d9be55deefbd183a623f65f07b888d654369050
f46c043deb7ede4f6b11742d5fbf1ac90064a24ae6ea10265e
033a0feb61c3b861c230639833b08637a1357055b3cc5a68cb
5a14163248c161a4f6cfa5b7f5cf0d5fbffb094bf8da272286
6b6fd83d7216726629035e22971741d5768ffc2de5679a2803
e5629a5e175f0fac7b89b5d0e8954ad656149212b6249d0826
85049b74d85d0a15427e05c9263cf27278e4b48a0a0a3078e5
367b14ca67c42b62585ff149939c514c9d984e51f788e6b88d
be8dbd5bb8db76b774a77c9bf7b6203f365a7bd48029283a2a
01bcb8c14d6dd6ddd410f7a24492a24471bc8714c3f2e62bc5
b07a20abde85bbd503b12c9754f314d3d4f97b6fb9fd85c32f
dcfdc18fff7c5bf9964db39f78dfbd1fee654e3cf6c0898fbd
3bfdcdcffecdbd7fbea3abfad83dcfadfee6f88fde7a701c5b
e27f5eed639ec6b498a22af4b675b498e92099db4d421636e0
c6044faed347294cc649a4ba532189db0af864ebb891487265
2d1b5361d2aa64b0b1fea7f556c29a19c3a0c684ad7594e588
0d6ea2885ca710a65e2cb331825c2622fcaaf4cc45f1592caa
0b57e5249da19a2ebf7b0a08b549009a25894582d0b1015f1d
a16b2791ba4e45d72ac442febd1620a051c17ba5595b8a423e
1bbe18335c0d5c00c9d51475598bd67231ced7923154a0fa7b
850ea0e68a78adb8473ce2307c2a873a72d58efedc9edccd8e
9b73b7f27739eeca7d92ff26f73aff6793b5d831d23cda72b0
c5a075a002cfa4339213c33bdfa71a9c18e4a562542a3a940a
533db4a4a61943a3d88ae04a680eaec9e7b5359522c28c408f
0bd3c2098111de5068e2260828ca30a4264e4711a4f4e9697c
c6e8f80648ec24e6162920d0733a41c0822fc8b3e60b626c22
e030bdd56ca1cc59f9444bd2922c26ca5c93820a56bc6a36b5
2aa8646e54ded36a96445940ec3e8938b695e474b29cad7181
fbeda98336b3c7a7370cf3d96aa56c7a8227936876af3d3486
d06daa0ea29ae575ee54a32e82a1c8ad06b668e44ff61e1dfa
cc8d939f9e78bcaf35dde4a9f4af2abeb694d32dc6c2de046a
31d93eb2edc0c6eb6fd4468a853853997af1aef71dfce42f97
1f3decb6e7575fdfdb1c869e2be6d201e6a6d1a2d77678f5f1
43b10d23d77de0ccdf4f5ee79520176fb5cf4061da0f512a6d
5c47fbfe2411bd49376920e5661117ae79076c604b91fcbb5a
5535414236704c112405bd04480a82f169dd19a0895c88b587
a558c2cb6646253367d3e90c935875bd3b609150b84e648b81
2c88e44016e83690059af5dbfde19d2283f2c45450bca9e13c
ade5a7f3df481fcf1b8afe62b49a6d578744cdaf4587b25bd5
11fbb07f343c1cdd9ddda71e126ff2df143d94bd479cf41f0e
4f460fabf7fbffabfa55fbc3feaf861f8e7e39fb98fa1df95b
feef06ff463d237f1f5fc14bea9bea3b6a56c9df9ab8357dd4
f988f311d7629edbe6440dbc2d13e652359f40c06b0f479898
3f83e0b662899097e3585b204045223620d302154133881e47
d3e80462104f3c186f244ba27bd84d3fe37ec1fd0737e32671
557777ae9e210795bb2bead894de3eb3405c06cbd515a05fa9
de93cb1b4f3b3d714f52a1d24ebc4ac83105a55c902857f747
417ee8e454bb0a29a2ea68603ec4e9ce85f9839ccd1b237d12
bd9c9459e0e59307a5b5dcf9ab5d0eb526aab56c398ad80c6d
8ca3de221f1c55cc2ddee6bed526677bc8e5ddf3e96befff3b
e4fa51653cb9a17c5fea4075e2f8d76fedb89139f1ce07469a
82898468ae60b87e70e88f3f7b1d251425185f29a0ef61c4f0
fd1f9c596cd62369f4694c8969f4d2faccb82c91c16cc4e348
11389df24650cd65b1dec28fd49178a48ea12320ed487c3a42
1c101102ba23c4b2273b2291f1cabeff8189d44b253199da86
52875287534c2acd792d0c16864b60c92f633bfe3fe068f0e7
8b5787c16270ba243ef690e9b08936e11378597ca544103b88
a50ed7f817228823e0f900fa8601c9928944b2992bf0179f9f
64c98cada1de8076089ba9f626bac9aed19afd13064ecba27d
591401294aece24fc55229a52b194ef5508239eb7029223278
e1b16c15d1822ca30c4371d8f2ddc7228d456c63248bb29423
1e89441434adcc2834a588d8125e54ce2b46653cf3adb55a15
dd969dba3839556b8530b53ce6a83db5815ae75c9fc288148b
c59332e95785a94b485b1678e793b73069dd04d57bef21776b
3da7b86e4d7ad6e24a6deb5d5c03b7ded5b6b5251edbe596dc
f9a2d3ba69e3aabaa5c12718ad317f2425203773e217bfe8ce
a55a37bb327b57af1d4861881997899db8fff83541ddeb79e0
f245fa1f314d950c37afa3a95433a1a9660d10248d48e40891
c811b207fc7cca02f3a9a8bd2ed2eca0cc9b489fb212c7a7ec
5183a41ad15d4674d0888c89024228cbf9ee08a3fd61144e28
7e34ee9ff0d37ecc56d573636318a715f0166fc620a917c808
63d3a55f2e89bfd4b5f91a053545ed29de9095c352a391ce96
38fd343ea9df886e317ecc481b1359ae278c0e843f1aa6c309
c98ce00affa8f981a2ecf6e6263f6f23b6594a824d2ad5dc54
d3dae7f4ed39c8a41c83453c776eac2a9e233544b5aa8c8c29
e7cbd192d4a8992bb9b4b9e2758d5a76271f15bf18370a9c90
1632e3cd13cdd3cdacbd790129da035804ffccfa33dbb9f8b9
c43fc55e8cff3af7aae1d5d8abf1d77366a99a1bcbfd97fcc7
7347d151fa2833ed86a7d94c078fe48f365aa14384c0982c6c
50c83dd7f07c8c0f32b24b0aca215f26903b663a263caa7c21
f685b85952ade95c5f6ea8795ff39d993b739fb27d2776a2f9
35e6d5a025c397c2d4593a8c22a8401e21a09ea4ce362e20bf
e6c87ac3beb381b03fe247a25fc1df1cbce93b2bc39b0d9214
8f59cd067b8a6c8c61f413aab1902d51147ca9fe7b7d3e2f14
0ab8e4027cb1f4cf2584244816f903e402312ecd3c01cf389b
b0cfd819fb026ad57c29bfaf31c2233e379b42e3a989d4748a
5152c5149d7a1a295413529ee8af3310f4612026df0ae4455e
8ea2b1d14a0163df9397111e92c7bcbe451e8c425ad8ad6bd0
8091b380adcfb8d5ecb25acdf5760da37abf86b1a9ab3a36e0
61edf1528d8ac9da42a9fae3a582e94c44111d2c1771448388
cdf0410a1ece4071696310d59505589450bbff0ef7b6f8b6e3
9db4616c144d91a60c239a6f16cdd2b3ccacf92bd619f78c7f
2630133cd6f0486c366f81f677906d0259349ab9102bc43f9b
7b34fe68ce38360ac0de91567c1553da57419a50a1f112d053
34fd24aa29541af1548e2ca68a450c4b559b022b28e10c54c8
c65789eb89ae317d6381525c6725e775eae792f473d925fc11
12fe08a992532438e69266b7e3ddec1546b4e2cfb1c2092e69
92157f8e15ef8317af832cef2d38bbfa0fe91568a301cd4ad3
8d7ebfdc58e27c42d6b8c0bd3a7f30cb49613c58a73bebed27
f4c6136b4f91f1ac3d3008dad13b9aeb253df1d4faa613f44c
3479c78d5b762a917d0ffdecec6ddb0f46dd1e6b341a7ceca6
cdbbdeb7fa9b7cfed18fb50e363b44c9c29c587dee0b37f7e5
dbd399c6defd7ffdf16361c18f7a1ffcdcf595cd7b67365476
4d7ed963b7414f4cd7e57fa53b0d3fa002747a7d46694893b0
e40b9100a3d9429c5116b713199d64e8242ad259cf4f71d6a3
8e4ef806f5c601663e67975d064825a5108b75e4caf9a5c2f2
b99a76bc50af23bb22d57c1e3d2f8cacddebc6f8577c8df880
fcf5810f902509fd4c9891d91e40ee0fbbd0b52e443e4ec304
8c3fdb1c404662d6188963c948f4abd1a9bbd25872a544b3e2
c15f88f7dae90c05d73996483e7975e5fcd8d8a2b8249e1bab
c785313104ce50567c015d96ca3eb48fa6aba1638e63be67dc
cfc80bbed77cdc6c081df1a321cb90759f659ff5dfbd46d6eb
f6a6bc8cecf6fafc0c82952b701c31ee62ed6a99224d23d652
868b965f70bf4cd0defb5d819f53e605f4a69653b05a6e2c84
e642748842c86030c65dc34e34ed44f098b939e7a2f3bcf315
27eb1c0f7ef748dda8a9b5b51c230f3b85679d50d5958bfa23
fff05b171156cc14c1897a7775f2e43230569e0a202cdb9081
e03ec4da79523369afd12ec9e3d2fba7bb630e82ebda9a09ea
4b42f6682b798449df8b2f36a7a31b1da9d8744fe348f6f36d
b7e63d19c30f56ff61cbcaf7463766d237ed6fdeb79ffe5054
fef0d6e4fb31fdd1972f322bcc17a9043db28efee414f1bcf2
3553c2aca46bd1971a2653c2352bfaa21edb56fc6447bf4422
3d529d30a5babd8d076f91240d295e37af6dde046b566c5e36
94b39939c8053f05e6352f50850b2ae41deb66c79bf510b7de
cffa82ba1ecbede2f424798617cc8ad96b8b273cf8acfa29cd
351c2fe89148129b54fc242ee92730cf2f10df92c4f34985d0
a8c2ea1198a404b154d845aae764c08050a924a592eb632c78
25122f2dac1649a01a932b01831893920a88324a8125a4a440
ffcca50c2de6b6c806656b64ab62f4f3ce21b0aea343e1442a
c6a7501717e67b147322c42fa0cd9a53a01209acf2e07e6c82
59309ba3a490c746cd216447136816bd800c88a42f493e7f5c
92869d334e7a1aafe69c8cfe14449d403179267f78f86aac08
fd586bcf59d71f0e429ae1c195afa14508a507827647d0ee0f
52a223208682f5b6c2a4131600c938e90672fa20361a05b32d
b4c05b4e620b5b0fa337eb58725dc94e9d5c317ce4cad11a11
e357a932b3df1e952329dbeaeff3b7dfb3797032176cdb8aba
46abea47fa2bbb992faefce32c29d4f9e1f4a6d107a7d1b1ae
a6004aac3c3a3ddc3a4073d7b591be0a0e4ccbcb989615fa77
5768f9299389f24b2c794294032f0a5e68e65f9ea058e8a3fc
e69bd502d64c852bfec7925730057893a9218a8f33bb886bdd
e5641dc4b675482c4d66b0c450c84081f32ca957feeb49a985
0b4b22a90bd34cd23661c4fb7f19fb12f0388a73c1aa3e667a
7a8eeeb97b663477cf7df4dcd2c8926674589265c9128e6c6c
63d9068c2d83b065e3031b1c3b01ec0001938424e43449368b
591c1c5fb2c049e07dd192bc2ce6b12f6048360979bb262109
02279f1f798fa0f156758f64d9813c46eaaeeaa3baabebffeb
3faafeffaf1b1ca4430ee5570c606e78a3b56871589c414d80
f51b7d2651f0397cce664d996d36e1009ecdce3e6691a68b5d
282c742c726e62bece7c45f30de7575d87034f8223cc7735df
767cdb79c4f523e6b466829d10ce389e759e753d1f7855788f
7d4ff89b3375580303b2e5cfba829c26b24aea8929694f8f92
46224a1a0c2aa9d128a7d5aaa3a1c005ee0678edd171fa6edf
a7e8fb8c87029a66a6c01684b2eb05d5f3fed79deacfb0f70b
071d64a3a95720cc82c563062e9f079858a307f59603d5a4c6
e9f0090e47468941e1723a450d83728c5a455314834443b309
896f40e5746885498818de5a16f2acc81e6627d857589addab
716164e7ab2ae971e619e625d4cbf76a1c3b9c38dc800f6850
7d395341533757c6e9895c1127677445a0791ea97693f0b909
3e00f70794d64077e174823317fc98543bf84402479dc774c5
3923fcce81fa8670c9398dd36d82b290bcd22730bd3ef83122
96c81145b1419ff293bb8812a9e434ebb3e92b88c8bd7506a5
1a518b8da57e8ba425169b96b2e632e343e212daa0c2e3a032
bc5ad56b9cc0a4726a7d460b099410e908df147bc08ab2a0ae
1947d5c1328cd92c0f47c9eb23ccc630c1214b8cf058432466
7df5bc9dd1060a3051b0041b6a6763b5676c51af31473e1a0a
fb82999a8ad037b90d1a4e1b0a51464ff707ef907449e2350c
9e9d730140fe1ef5ab26aa3a8f47e8c2ac50085329d0e04d4a
58974c9979a209c7e407298f5185fb059ee3c2e175e49d324e
8abbc441d342161ed21f321c321e0c1f2c9cd79eb7ff32f2cb
bc864b87d99056d46d6377687f97533734a7b955252a5da12b
7cc5d814ae44cb854cf322ed203f68ecf62c0af7471717aacd
cb1dcb4343cd3bd4fbb4fbf87dc67db67df62faa0ff3878d4f
0867c31e03cdf19c914b7a79afd19b8cb131bbd4ccf2cdcb34
ab4a43cd54bdc78ba8debb9b6013fe909d1294d2e182c05220
8dbfc19376bbcbe97473b92e36e2392e39862bffeb11fc61f2
1e7fd3a7c282e0402a72a45028b25a9d2e2fe050dc8e70a158
c81743a64336c9088d45c4866c3af75ec710d240a5d096e0be
20113c14844147289d2ee7537f89c522f921d4e27b8bb048d3
ea9043ad168b214bb118d2d922914c5e67c9e775482c15343a
7b3e1272689ba4b0c092ba82bad8807b6e52a3e958c635c006
2f828994c600415dd268c4fd2c9df2e1ab540aa6521e8f9bd5
2116737a8b0ddad2a1496838e97340077e848e2f561ddf77fc
d671d141e113b89739ce122590076ab8f144311d9984cc4990
87f9b3c43f81326826064efacfc98e00237865b099c44862eb
f4a5d9c5de4612b3dd08fb92f232c3411a098e8b8185a07a80
3bbcacab1ce21b67a0602aef9584b7f90b23b8d52fc84d8fa3
828fa033bc7cc8dffd36caa919bec5d072d0c0b7ec9d9ac2c9
1433a5460983ce2ad1c065d7fead4009c9aa45da0a5bd66273
094dd98ef518947f0b4769b5628156d360ace8ab2ebe22e0b3
e800a755b3dd50a1f1cc8e5a40bb12ce35632283d25894c34f
bb38c195433e0e77e5d74f70d8b9edb72891838cebd105bd7c
06eb3f611fde8ce89c1197c3715d71f7471a929c181562e0d2
9779d40046b4d991b2c4f35cd988b664d58a83c15e3c612ddb
94c4242f2888b5ab8b55b3b55c62ace568c6528ea1cdc8d8f0
8af3e861b672ac6a449bb59cc31b7ab31dbf1d6db8f87163f9
2a27852bbf6b752e78d5054c9a74ac102e5069824792469312
09dd0854496f039996e4b8c79e343b1bf7588eae64af53ab59
854b09705e27566a733d42ba3ca61eb96a59be464cd45cf058
cc1fd4dada17f706c2b09415b3cbf65e18ee2dd786520e73f5
c017ba52a9daaba22bbceaf9a7fbae6b4554adc12ee4f8c0e8
e8cd4eab3b142285c0b6276a93bbb3a4285a0c76fbc8d4d40d
46214288226d71efbafcc15823b642a8759397109dcb11cbe6
d139c4b3127112dc198111379223e451286c873a6194b33828
de042167099ccdc9d9dce4ac8891984ebc8dfe2ad2b9915902
58a73b1e4d02b82d46624f0ee6109507aae01efc0ece62c903
50c8cf521c24474e21a952a634ca20e3f7f9c5c32b7e085c97
ff03382e5f04cecb178fb37cdd58e7290df6283124be1823cc
85b46d7de91efa3e15a1d1d026c6c13835098b33ac114da233
9c68822553d1d5631ad58cb29b1c1b9c37bb46937732bbd9dd
8e5dceedae3b93f7b3f73b1e038f69beecfc52e22c78b9f0a6
2a88b87722918cc75928f36f0766fac95c9de987199fc3e9cc
c4590bba219948c8ec3e114745e24e0dc53249943a580dc304
eb8c3f22fb7fa2da46a460d9cd15ec76a703fb68b90eb1f00d
f6229e4e1a67df6549762f5ec061ad86d4ec65b039aa3b719e
c366a5877d84efd0da24949295249174e40b4f62031f6cdc33
b26de0c2c8d60b339746b057eb4cdda86760e642a2beaccc6c
6c4da6ced5ebab0b60b2f49191c8d43c83288b620e88c98ad2
0b121a37825d6e963f9f42fcd91d99647c27c6dc8a2da9b20c
40f9a359b5ccab55f32c4bb148dc88e38fa13f1d7cca9a4af9
df3867543381048c87a282c6517bb074ecba05fd8d197f39ca
7a7ac4f6da19ceefe0ed7984f6117764612d07df8f454d1aad
1e3173c16fa87cb0f9becf7425e3791bd7b6f23071d29b0eea
781d50a2fb936308e3adf0bcec0f2899184aa00e5387f5870d
4f529394fab01deaed3bf4d9d21058c10d594917653798b935
d452ee0dea654e5dc7e42824ed3692230cb46e310defa2e110
bd8e26e88c4ed5c5c1ed1c5ccb6de1082e43b0480f464459de
5d5973ac8c8464f01ecfb75b3d58e516ab399a3ec57ab49481
e34492b29024456a098a833a835d8fdf420dd190cee8752a7e
2d07b90c2458ee2cd1060c8022daaa4912a60fa34f4b0fe961
465fd58feb49bd53b257ec8376d2ae4b6b8b808084c366ff96
c2b4965cda3a70094735c3b1a22f8d5ce02fe0f529642f50bc
9bad63dddf0c498107f74e09f5b5f3ea89cc6a90028fc43d99
cf182ebf5cd520ae4266d04e361bd0a30c57c547a2adcc4d5e
fed584ad4c452d38fbfa84a54c8d9b70f69109539912ac38fb
d684156539393b2f82dd2c055ee93aa3d5eaac564247cb4305
3a15c1c94b6911ecb51142eaa1d2108e051bfd56397c5aa991
5cadfde075625ded951b5bcc2e2aaa22c1cc57e1924d8bedbc
163a6abf17c9b82398ebab853e782598f46dbc7c59899c466f
26c2a00be0e1a4877600e0aef284d45e691f6c27db3db6de04
012bcf10df43288598c54811cc95ea9f2bf51a2a65ad6a88c5
210fbe7d70ee76f9eeeeda1e1cf906dddd2ddffdabdb01b09c
800172f2f2ef277a13100618e56674af1c9f41ae4f2fc013f2
0f814f03001c551d51f143bf31871fefbda6364a994d7365ce
83afa232d1e3b297846248322e5e1409d138597beb147e82ef
ca13e4b72a5e2ef8adaf2aadf0430002552d1c74c27dce434e
c269c326d7b8aa8e2b25b7e292b2158d5c7269bdbedf04b805
3962d00ff7a12a03fe9a2a6f95ebac94db3457ee3c9840e5c4
aa9e90c42d22312e3e87ea0b266b7f91eb2b7ee85bfbe74abf
06fe875cda4070090961493571384127c024ec938b4bf31a0c
95964786e43aafa8d7f9002aedad9ae0606c6d6c4b6c5f8c8a
b96df86ba3f35b1a50e8bdff46bf4cdf0670a0db0ed04fec92
69cbc942555bcea22d8fb628da5268c3d31812127394cd5216
d2905ab2c8bbbe4405d8a83e0d0aa0487bd35e89e0a25c9ad0
9854369553e3918a52e92ef34e2b4307a341628b638b9758eb
5d675c6727878c43f6b50ef2aec83e89484aab23ab25721b13
91d2e9e3d188251a8d44d31219494593914ea9e3a8aff168a9
70b4d87954ba9881998cbf983c9aeafbb28fc7d60a3ec5bf98
6cafea402a9d2e798bf0fb4828c72716307c3720856e465304
05bee02b908587b31dbe44a3b7044b632dfb933039b61f49d9
63de1ec8f5c09ee3bc08f78b87c5632229e2f5d02c54a6b3b3
bf9fcfc2ecf156a9e550cb232d640bba30a16be87e1e878f20
8355ada57b4807758b0670447b1e49d6caf2dc9824c9c23462
71d323db2e8c2081189dbdd4a20c324e57f04ddb5aea77b44c
d723a2b7c87eb7f2413d56e34145e6ce6684ceddd5e1ae4530
bc30a4581479c236d9a6c819ea0af7e4e1a240cf0268e42ccb
8117362c87760dca39d428d71deacc8370a437d8b700db1a6d
876e12edac5a613b70d168a74890d7bac12614cb38fc93d795
dc8658e9b6d93535d0cf35912e9518e0eb9f54fffec498af6f
52fd7f26c67c3e06746626d5bf383dd6d9c90025b61c201901
654e8c319aaba33f289e52caeae494c96a21a86040c4212044
7b80c20b0853f99c682a160891f6cb539c48f644f2a815a961
c66bec68c34133b69e95cdee48f6241c7eee07b5a727276bc7
7ef01c1c3ef19ddacf9e7e0a168e1c81c5a79eaefd6ce615f8
e9cf3db671d7ff0e7bcc81c9da2ffb55a9cedae732518d9a54
8752d33b6f6fdeba229ca66f3b537bea99c9dad367cfc2a593
cfc065675a8fd4fef9c923b5178f1e45cf7a12361e79e59e91
fe3bbcb5f3458b8ef4c32fd6fe97dfe3f7db6dfc00a1edd3db
1db57bd29f285eb799c7fcfb6dca4a14e9cd80047d721fe310
73831cbaf02a4123710a75ed99d3e4bd8483a22709cd49ff9b
ffad1ec7b32e124903d323b244e33a41560920484e797c1906
cd44b1f68bc0267a73ed09b81210a093dc8868e76dc00652e0
b0fca62804064ab0875cde6880316aa3d5c084dd58d54e003b
128424f46e4e8ec588ddf7e355ced5fc38c2831f7306af61bf
8134e0731aaaf998055a1c485b80db4ffa87572992db00c274
19ddeb425b6580474ae5a5e979e2c2ec4cbbc60e02daa8d688
be5ea84ce572c6bc31af44709d7549cecff3de097df869d8bd
a29fd5e8f54953acb5afb173ec3ee2865baa88b96a93b658eb
4053c7ad07e8db62e9f50b827a03d79acc2cdcbe6cfdf7c2e1
e6d56d0d0603bf2091edddb66cd3f710b5acb71024c1142281
df01a82dc6b3fbb30480449cc4b47104c1abf6d4e59f114fd1
a3a8c603722b1a047205394adc491c21ff83509193c49a9304
d4923f202388d5bc0b08327202fe8e7a9668260c78c1df4bd3
ca324732c84e125a127f79450119249efa60e54af2097af4fd
9be86f221470a07ab4d20f832afcb3accdd46dd1c2d07522a6
b2e1b90f3d502d28a400eb63bd9c9dc30e697844539e4597c7
cb395af65ca4f11ac6a23c8b2387ffa1e98e766097efb0cb96
c57679a2c71e0be109227c1a65fe4d1e3747993fc97613a150
47fb55d145aed80dcb160a52cbbc6023cbc6a5f102d127554b
0f480f949e949e2c3dde71baf442e942891d6d5cd731def1c7
d21f1bffb3f4b746f55007f4315cccc34602a1531edf81001d
f3682241fb298ff74030162a35d9c92c576a5a3058808549b2
abaa5f104a01eb1052b33251bc08547735158d4581cae76535
6c56a2794ea40ed3c790ecea1ceff8970ea2a36a17c35b4287
4244e8f311477bc724bce1a4ffa9efcc46c3c50e03b30b10c9
62a3ec3180e38a60f9717a7aab51b1cec3488b17a45086d46d
2d9578b2add25a215489704bb2ea0395f8029fec6114976d82
b08986eb4ca100522c9b5a202f359102b66804af6ec98e81a8
caad65489f5f1e0ef4cdba07e7653bb659b7357fae1147ca9a
55a9156276f562bb4ac81139e2c8dc22144ac811a47dc32d70
dfb83f591ca935ddd4606199d49e37749a86a42f5ed389dd6d
c78fdff2c2dee59fed4c790399b23fd410cfdf6276928faa66
9ab754904a9df06c846f8e9839e3ccd1319f606c10c5817b89
e1c567ceed2caf8c04d2c1eb242bb7b4d87b0adb17db119656
1096864101fe1ce3e924ccdda7e0ea697b5c1080014f611a55
1023aca1a04ac5adc0c7f8d46122129ec5d8f01cc6869d0df5
99cabf2818eb9431d6e944449c90ef2064e75b42c658c2a857
9c2f55cb50e6351963f5b318abd7a306fa108cad87bc9a87b2
b8d131da16b4d2508978bc04c74b4856d59ff2300702e198c7
170910a73cea034167cce38d048dfa64c24e1282331c8ddb53
f14918a9e6532f09560086b03253881879848e8c9a8d8645c7
61e73124563ad1034b7942346cd11fd213facf738e62e91f60
e22c1e2a4accf4b469d647d23e1f0b8574ce64c9e632392947
aacce1b425df0072a654c31c1e8e6cdd86bd56e2f18255003e
d69a9a54bf737acc0a208f748d771022167895caef21af8a70
338788573011cffe34cec3b8360229b93276ce8ef0a0f3c639
432395d54a6a6ab77816f6d434d172f7f1e3eae153ab36dcf4
50d45aeeac953b8216c1174a6f6f0ed843bc8eec9d3936d619
462857fd2cb1a2ff9f9fdbd6d7f7b7ee558d1e288ad0cc9656
13cf2395f9498ba729fefc2a8c6d9db529f213e0a708eb24f0
5d9902b77eddf5f5f493d2a4f453e90f926a8f6187fd01c37d
764a70344400a4383f13d70913f1aaa80513a6aa4e9bad3434
0fa52097f2a6f6a7c894ccdc1e47e4e4c7543367f55af75b49
2b3a77927364b2f3d9da0012dfde1bc176ae7809e60be87fd6
70b7cecde0d611d71901887193498727cff2789d48cccdccc5
d29c95e9ec1001eeadf4479cbfe3960aabd5b3369b2dde32d0
d871db4178f3f5032cabd3dbec46c4e14a5d63f7d5a6e2e591
56c4bf18a62591e9dd76fda6a7c578ea960541839e61da1299
ee1d88c761e942d677c863c006175ce120d5ac45f6fdb4ca7b
9bc56a53d30c23306ed532462dd8ebfe9fc4bc59d7f95ea0ef
5deb052ad8af727107523e61cc577e7d8e577c414f3e2240d9
afdc91cb15c68563c24581f40943025145bb75c2230225d47d
db85ba6fbb50f76d974b851ccec215efd0bea035a26fb778ac
5d7ab50da865ff503d1465c75007f65b971d431fd15dd411d8
3b94d09db0d7fd42b109ffb432555a693195aff655c7aeead8
37d475caa6feaf5d43e7fc85ef725eeb8b4e1efb300f740407
ca436ca1370115b85dc659ff1eea058ad801ee80bb28bc36fd
14f902f51af57b4a43902ae255a082aa4998aadaa97f41b495
e208483cba0f9d73a89947af88593323786871fa6d79b5a4fa
821fa728125455b2189897c7abf2e660481dfccfc91f796bef
bee9a137d54ebffa2aaa8f8d5a487c89ee4712c613727d3a9f
e09e212638f27ef501ee8099dcc9ed323f48901bcc7b88dd6a
f25662937a3d477e85f812778420012c183fa5d985d0f15314
a507ba514eefd54b7a523f09c7cf8051e870aef88d3c4d8de5
40790a619a6fb93473a945995b433f24f7e928a491d82065c3
e132b46394b10a34d04c1b35938ceef898117d4062ed9a1127
7f2e31828d3ff197044b734edb8d799b6a768919b5aae4a36e
5d120ba4be1bf5650d5e981f9106775492d698a0a516ddbf47
6fbcbdb46ce4f6d6a1844934a22fff03b516fe982e032d6851
e4ed7de82479bbc6a1d3ffd5ffe6af95be3e0da4912bdeeacf
0015b9647a251ef6c5537775c5649e00ba3c55ada652d50a5d
c609de70df3b5bdb032f021e58c193f29b12b4fdab868da545
56b8d2bac94aecb6de6f25e2d6662bc15a9d560249fd5f0156
0b005602024481ba4e1304d08f32933053e52160ad56a06559
1ba09bf802e2a487aa2c0e8bbb1fc9a10edbb3f029b8ae1e1b
0dc73bc7fdb145b1689e993196a569a80c7ce181d25928203d
cd8cdfc000f44552beae6f85f2eaba2411295e09890c37b5e4
2a6d77ae0d951b2cf9ee7480e5f941bebfd47bbb3a4175263c
4924228313e07e2a48be0ff42075fa8cee273a02b4ebe08b40
0d38180214cab12835807f85008bc1efcd20d5451682a12cba
806000600f13e2b6cdafecacd526ced46a3b5f21dfdff6ca36
9483c4993b7ebe0dc0cbcfc2103c027f8eb5851f22c9fa0c80
e44900c8c9e33494b0f0861fe82ffae1919a09be03434f03a5
0cedfaafcbd0aef70fd3375e2903c1479579f3ca7b40ed59d8
7da50cf331ca30e0afcf32f3caf01fa30c0fde7d9657caf060
035845dd402dc10d8b78a01744101f6c0415d00306c1f5602d
d808b6805d601ff869f5e6d1b1a1e1e1d52beebcbba9657c7b
34b96ebdd8dfab63baaa1460d05f834f6c498a62b2855cd150
c858785e6858d2b773dbb69b3674777c724f29b7f956936de9
7242d5dcb61cfd05d6acf23857edb975d5aa5bf7901b02ac21
9e4e87031b80f49b7365e9dccb72c8714992f897b1e90c627c
127f0e67e76ff27d505252fe25e5fe6b6efebbfb510b588281
62219f8bd453733db5d7d3d9ebea6b8eaf4dafbdaeb65d7d1c
bae6f9b3ef235fc9140a9947f1eeaff96c3e2be25cad31877e
dfcb67b3796229decf38f109e29eb97b679ece14723911660b
852cfc09be585b8df77fc5773f8a73e497d02e838e6aafe5f3
d937d001fc32ca2cc74fbb0bede00f735271a617e5be98c914
085ffda69a1a65dec2c57e51c814d2288330094738f924e2f3
de3a7fd13778aaee2e8f1a68a19bc43395552f6b2c688d14e7
8e00d16af5fb94286483cc5a660b7399a1180931484c37a691
c6feeba90440e457a80cfcbb13ab73135a2de555534639c006
a54c8ad4e3fecf4517ab07f9bfb2349ee2d2f8c9256b7ed09a
ebca0404b73595f5b55ab41a5d5e669509eb4f761fb2ba8a81
bc5e134b5e977c04c7d068ae7b13cffb65417ddc56af4e1225
d08f2edbc143975f873f0296aa86c0919235552234491c0595
221e882640c7e50be461f25d6046bd637b75c98a30fc6908fe
d40f57f8e0f50d1b1b889fb8e04fecf07adb461b71bf09ee31
c1cfe8e06e1d3cc8c09d0c3c48c01d04a46f0cc24cb01a1c0a
92c160cca14c7f7858ad054c92ef80cab90ac2e4917372945c
84a323d7fc600eaf826620828134512cb411f680011de33593
dad0719a807fbef19b5bdb9ac61e1fbde9f0b6b645bbbf76fd
c22d03316fcf9625fd5b7a83c9814de4bb430f9ebd75fd0f3e
bf72e8c1e7b6ec7dfed39db7376e7aecc6decfef58d4b1f5b1
eb6ff8c26819b5d266d42ab792e7810b644f3b398b0e4b0d8b
aaaccf92b110162774b926c9e9533acea5c7b33653e81fd579
e6372ff0bf7901752b2bae93bc9013166c50bd8ca862c12271
6bac3d25b8a4b6608d895652823d598992e7457db8a73cf3a3
72a5811645c6d75a226ecc367b3422865507225977a0d64e82
7555bf80740f759826292afc7f75ea8c111a8dceb45aedf039
33580d42bc8acc033ff94e5543028aa7082a811a347f020b72
957333b917477295999772b86df3923cf0692a4fe7a473782a
75249b09e17935b5bfd84636b691b821b1aa1b69a3f3f5f656
5b89d53dfbd3811b66e2d2e6cdb7849265bfcebf60481ade99
f0aaede1d2e21b2b43e33dfef29dcf7eea50a9487c1088dd78
d36a31d1576d7426972c085edfa73536b555f2bed2f0fa74c7
ee7bbf7e0b85702f57db4216d1f7a981edf21bb58308bfc4da
5af26be80c8bb85dd3199d46cdaa296c21bfe8945ead852cc2
90137a0d44df7592a690185999425f3685cdcaa4ff39736eca
54e6cfe51000641bd0a0d15f846ae827fe70e2c4b7667e458c
f7d5fae004f9ee078f1dacad85dfba917cf877339fc43da050
db4e2e265f47b5102eff6bedb3e8cc8acb6f91c7e9514285c7
89101c3a6bb79113081b74a0a3dad0431c24be4c9c2128e231
ea086a6648a23f838ed56a59ea2c899d8074e43bc7490249eb
95bcdce2e764854542ed7c0e9bea5a6104fa118aa8236672a2
16df04bf596b8b74b7e6cdbe9de479fdfbdff6524711920478
d88c6b772baacb9df428128f5cefe0e3eb6a0f91472823aa6d
0300b527d1998de88e57e43bcc6e7cc710c2dd0de8580d2c97
d7017c2689f0e829f97bacf2f11254e23ab984ed6ff8d887ae
3f235fb7cbd76f42d7772319168964f2f155ed818e03880adc
255f779ec7c777a3eb0fc8d75df2f5ebd0f523f27103007373
430fa363446310946300d0ebe907c112700bf85cb5f9e6f883
4be1d2d5ebfbb6f7117d7df160301bf73b857ddc2144186897
208ec4e3cd1bb389d56273a1a5b5b9d915cfb40aab5559d15f
c0a615a6408eed1b5c1eeaea02370f0eb2a6107a4565e6c59c
9437e62524c057a666a6a6a62a533881d2d4af5fe067a65ec4
1d009df8150e73f6826c4c90c71d62040f56cc2731b2208c7a
b355b62a9ed7a3fd571de1b1a2364aee2bd636920ea429a594
1f93a846958aba2bb5ac1ad15b1d3aabafc1c5399bdc999293
3e7ad49eeecdcdcc245bc3c6da2d5c7041b2e64fb4864df7dc
a3f3375d7fd7d2dc0ddd317379f19ada694738e017930dc536
af067e8d60f43ace473f28245a4593dbaad509417b2890ec1d
c91e5934f3959e0151150a69238bdb898d335f69e98b71a190
2ebab8426c5c24dd3eb6be3f6d8b34fa28776bd6fb277b2012
b0a70747cb9fb9c15f4844ac1aa8c046b5977e0841660ff8ef
d5ae5ddd0f6f829b6ebeb9bb5259d21d8b49ad4597b8bdfb90
0eea683ae217a541096624d82d754bcbef5ed27387b87c68c5
cae5cbbb8b99953ed776d5d0404b2c5c91a1b424dacade1e5a
b306ecba79c3064681d2f4390425194c0a786438e5af0514ea
3a2323fccc8b7909416b0a9f934d9e30c8cecd03984a86579a
c42d8f97bfb1e2e9dc3c06937d8e0cd707fa10e49461be8f80
248121692f95e601b2506a3410d43f2d1ced0ea6bc264743c8
cbb9fd1187b3981259831eee2bf718135a6f33125f1265bfde
6fe96e7b43e3ab94d89a2e28e6bddcd5e08d8d7ce9f6fcf59d
4975d3b3b55357c1d6e564ac36faa148b9e208a6289b94b47a
acac2d9c71053f7943892267163477897a8818b3d8dd0affdf
768e51cf1ced5c9a4230e6d34bdb89e16b20bee6fb07af3347
dae26b564c5f01f68a47ca0ce2114836c6b03e88faa10944c1
36f07835bb64c96af3b023161b6e6bebea5f6812c5e14251cc
ab4157a60b0e770d77addfbe66c3fad5cb82e2c6f56b6e58dc
b6600906ad77756b3feb0e6dde9c8e996d48f34c178b795d28
0dd60f2fcc6c34892aa000b7329dcf237134f7772087b827be
a8f4430c6b7eeac5fc746e0ed208ca78904ec2745d59325181
b1d54ae2c32b10423dad8d94217705ec88972900beeae043fa
2dddcdf89c0e516f71bbbdb65ca38bdea20b99845830184ab8
14d0b09cb9c1b564f9b2a02a562cdb1ff618c32d899a3fda12
31d746756247a9a62b7484f457039a13175cbf6b00839afc02
8c3026bbc5977469cb6bf72e1c827e1d7305264d2b1696ca52
57d24a1adcae457f5bdeb62882c10cd9705f3bb169e6cb95be
88161feb124b7bfe0eca8ddbc7d6f6c4109c31af0ad6bac9a3
a8ffae021babd9038370e3e0ae4162bf155ab5ee43bdb0b7bd
1d8a6e77617522382c1652a5c642b0906904c3aafe50570b88
a7b0915682b5bfc4ab3824354c63d906ed7197bc8a7462c161
84ff156667482433ce93c7e4f6b7e5e7a41eff35bded4aff9a
edb10a8555cb1d1681903c5a5c7bef50ba2b6533d83c3c2299
0167d66f0fd8758c2b9fa8fd917166e3897aa73a78b065dbb7
3754477b23a84bba3da2d3dd967716d222eb84ad42b9b96825
9ffe60c38eefdd5136b9832693cfae27740e21612c6f5a491c
5d714b4e3f7334de5f0ecc769d45f73e77f702b1b1bd2198d2
38d2a1781477bbaec912923354982ed6bae9b751bbee000f80
c3d52106f48bc683bbd369a34623dc6bdc3f0a47d78c1f6a85
ada5d2b0389e1987c671e3b8ffb382e91ed1ef0a8a7ebf1164
3ed12fdeabbaf5a59b577207d33b7796b37b43b15867280b5c
ac5ac003634e0d96686a53725f91a679993ae2f69f9aca7f08
4de4e7a080bd20e58e92c7977147f9d8242eff51b4138122ff
8f000bafa18de4d31f8bdeedfd280ada26343597ac89e2dafb
10f09357802f05ecc13af0f37f4f2ac9be8f49ff3e82a222d8
fe431481cbff9e6e12483a059440fe198410dd7cb1ba1d29f8
11a743881a9835cc6686ac31f04f0c1c60609c696608170335
0cfc1903271928302c2346054b342a180c2c1b0d85c2ae0677
d42daa0b6a428d32195a6da169358419ba4a13220d693a1a8e
849c51978b118cac81866ed113e2593c908a7425c42d6bb929
f90f214019f75287941710bbcc4b07796c8d05b7f2070d5334
421e741a61c8dcf99191adf26f9b72d988af6733792cffc33c
f490b3d8520847227e7935398c41463fc95ac2d1a40bf6f270
cc128ec4ecb58daccf63e30c8db5c78b1ac6eaf16860ee1b22
5407baaba4fb8313e9bc03e935246b3519e39e7dfbec7edee2
e2d4221c83639803d9d0eeb3e46b48426d074bc1bad39f1980
cea5d6b3640e34820099ab8a7d8de84f35dcbe54542125cce5
4c65424b0707db3a1686a027c9b6b785741e03d2c5b0bb4a0e
6f78b46d3a873ddd7f33853a83d25564f30e24288ce4e7a963
fe9c8752341b0f2da7063248e241d0360ae93f941c2ed8669b
d52bf1a1ad5cf5aa34feb612fcc6da07d62df06b735ddd663e
dbd8946cf0c5e3acaba9776dc736aed9ad8e640ac90657a254
4c1b8488c5be38da3cdce834966f5be9ca72a243ea8813916c
57d212744b2d2d8de605fd693b459106215cec494b3d5937cd
99753461461a865648b467b23d52034791e407df52a942cdbd
416bffe24682c0b47ed1e50b1481f0b002c6abc115126c34f7
98898d126cab5480d7e7837ea4e2b7cf2d78d3ce4fa216b50e
2661d2e785e8cfae0d652b95e56558ce22743a690f45f09a3a
953cc21edc5ea8e18c79a42f2a2bd620ad11b36da49263d78d
11184c93b38cd8e2a1f0d031421dbb81be422f6c768446321d
21ff5d547336afd5d5ded3272edebb2a172cf70dfd7ff6be05
baade33af0cd0340fcff5fe2f3f8003c7c088000081000018a
24f8272552a42888fa5232484224258a6048ca0a1d3b8e127f
d7711c375d27753e4eb339f9366ee2c8b16337d9b8d1a66ed7
9263c727dad3a4de6eb3693e1bb9494fd36d1311da3bf31e40
5092dd9c9c664fbbcb37d270decc9d3bf7377367e6cd7b18f7
e4eeccd9bc4eabc62b73c6faa6ef189bfbeac307261f7a7e71
ace4b131068544acd76bc55efa31632812b138c28caefbf6cf
2c9e78b8d4ebd70693e64030d268d2e5060673dcee7b9f2bbf
ed9b8f4cbab50a9594166b5927eea5f897648f826db9a8366a
26ef78a805e55a5036f26084ce05d07d4a3424438322344023
09964b932ec486de1ffa78481c0a59d22e7d1b6761bc3e3da3
55b4c57c4e86aa373214bbfa3a791f7dfaead60e4575d980ed
a87ed98f8814c4bc1141316d7cecfbef1fd48586d29d6fdf78
4777e578a4bd49a5f3a6fd28a7e0c231abb3307d7c4facefec
c78f6b83419f427465fc3d9f9ff6cf2c9442d0b5c59c864dfa
e98d967656e9bdb62c924a445a7ff76df71e5af8d47a171289
1058450afad43cf0dd462de5d37e1fa7d51af47a0eff5a0dcb
218e6b4927832d721bd7c21938838df1f9b5488b640a9fcd26
0b327e85cc97ac314b7eac88b704c120506cf3a24ee01d8c21
812d2211e357dd563009985d639507927afe86f8216203d27a
9988120a4e12ef1bf3bcf2a7b9bc4b8c673632776ff61991b9
a579325118da65e73a36e571e0576a4f8645577edc3fe269a8
dce188b4bb2a8f71d9664be51926ec50a9c313fdd7b9a658d6
4eefc7b95efcfc05b8ef03ee5ba823f98046a3d7e95a2816c1
e58b85591f23b3723e0da5a1a4729f5567d531525f9869c19b
392e9661f8cd9cab3cab5b0cbf54e5f85282b00bbc6eb19aa9
6775db7e8f5bd417109b4283e9ca4783d98059cc71b4c6df9f
79b8c1d999aeb8dbbb59690393cf8958fa6a7ca0c55c79978c
e94c557e2fbccba7ab5c8375a19de32c2d7de096837d71bb57
e8ed8fd7f5f65c0cb54751368406356841843b3da22817c739
f23664b3f528b1551b706f77300ce5741a1a706f275dfd69ab
c1c7e1ce0e43657792efedb1cb64138b74f6cb64b1453abb60
dbdefaae0e4c93b712dd668dc86c2693f09bbabcd8ee35771d
5cdf5dfac0f1165ff7e4e1a341aeab2da48355cb1f3b625ee3
a16faede77e5b17da38fbe726fba9c34da744a99c1a26ea07d
f4e753b3a3d1c27d9f2e4cbea73412b3a8f44619120f74d220
3d957b57eb3fc733fb1fba30537ae183c74c66b9b281d69a6d
723c16daa0b7634fd241ade73b1a2c16ce25376939cae58a74
26029114d7c17011caa7659a981833ce3cc23cc134740b8997
1909c3f852097903236d035b7886b39a028cc5876763fcde01
9e9361c1bced2ab687d7ab5de0e2a6f0172c22c5ebfce6bd3f
b7f966cb30f3eb97be06a6338dfe3ad5c52a549ece448575a4
228e8a4bca76672b8d99ee26a994e96e473f4ae759396d7e23
d01bb57bbdc6f06072f37ba981663dc735383b52a869b3b937
06c6628ff536d33e6c4a5eaf253a10fd31964a00a2ab201507
15ccab1c5a33877fdb5da7c61f10bc7ac14133d4d6fe25f697
df074edc37534af841572bb958bb4b2e766453e85ba9ac432c
77b5c73873a82b48f7b1bb622e2ff667ece6d7825d21336edb
79fd7fd2b741db312a9457999b025403d712a05a9818b4fdb4
ddeeb9acc3ee261123ad5fdebcac7b1d3f93e0db333534e071
74dbdcb36ef29972d3b7b565ed62b15269ccf68e78add98457
697219f5368356a677c8cd36052d7777a7d077441798d65eae
f271776f4fa7233e14b7a9ec61460b4e4761b06bbd1a67accb
43fb405a64ec006989ef008afb612d3cd4df4fe5905c8e7272
a93cde9e33b5cb95edb91ccccda45a29922af5fa46b952ce39
1a4d8e46b943ab552a9b07635c73c2ddeee09a1ded9c14f5c5
124c6b3f309b57341a945a37c7e83d8249c1848d37aa04f928
4f9d494167a45eb85f42e668093c659b8621569fbc5f06d336
f15d1729ec67f04c0d6f328ba552702e6477238dcd2f806e31
08f10a44c2a66e4accdaa2a9ae7d277bee407ddda5bd394bc5
ee67242a93a6f2bca4a9afabe2c18a252a7e3ddcd56c447a25
eb329bec7689e88a97d630ed535deb954ff68f0594228e7369
641a9d458f8e56beeddd15b1719c33d6d144f731bbe28cd7ab
7477262b7f872805ebf5693506b9c82bd8a3e88b20610f95ca
eb8d7a83c1ceb166bb47c2d9598a7183acbe6250facc8c11e4
7475f32562199bd5e1f752b2661e35af22dac62b2defec671b
685842bf6aeb1e1ef57107af5daef1f337a20be6707f6cf303
56b7492e0d4eedadbcc131b10e17dde7ee8c3908751ed0ffaf
80ba04f5b9fcc21107ba0fa173e039ec0e9137aa475a7d939e
d6dbb46239d748db6ce1b6567fd8ed8515b7ce4b7b9d9fa4d0
2af56e8a9ea5503f55a0f03bd70de08c68ca15a7c2ba301df6
1bb45e466f470e4eaf70399dadb6c646712b43f3be168c821c
d1d427bb2fbe96b8a8bb46f645a63713fcf89bb83c3d5d3590
240c3aba97a6f1078ca0a4352ea76f31e878113eb17b9335a0
2330b9f7a1e1f42e9754e2ec6cafec6a4d358ac595a7dc95a7
c4ba403e5eb93fd3e19088ecbbb2a22b9b11fa35af333110dc
fc41a02fe1e4387766a4993e78ed799173f3f36d79af0a2c20
9a71d08a5d87b24e223f23c8ef61905f80fa48be28d7c63f48
a177500f51f4610a05f588d21bf41ca24c8892be1fa11e8474
8845712442c8d01c70b8e3ba46d4a8352099c1e6601af5f7f2
b2d7352a145246ee3e65b8c3401f35a06103ca1a90c1cf5072
22b8d7ae12112560aedffd1a24f1a41fc58e4fbf34bd79996c
5540e1e5fb8525cff4b46d132f8fd1b6bee1ddde6dc0d3a590
977e5cede96e456536ed377b37334a4f4faaf240769753ec8e
3737db41385974951f6b65ae4cf4da7745d2cd57f0fe0db8df
d6a1083def0d59a45e3c0bc55e3b035edb0c73f1723e96890e
45e9e120ca06513b3bccd219c790833e645c30d2470ca70cf4
94faa49a3e202d49e923a253225a817db89ee2741c4b7ec0e2
8b5c03c7252d90fb0ce5f26995619f842c04c90743afde3021
9d9e36d6b65ac83a5e9ce1ddb7b0bed1884776dffbecf2ca73
f7eede73efb36712ab2bf3e3b16f8af4befe536363a7067c7a
91c414ec3f39dc5b1c8834cad1e6c2571ed83bfedeafaf2c7d
eda10973ebbe739f386a3ab0583edad171b4bc5030796e9b2f
4d2442c3d3f38bfc0a59b40696c0c13a6ecf572929b0e1d5c5
d8181d8bb9b266ad8f73796d2e5fc8a755a9dacc36c6a2c8b4
f9bc7593eccd8bfc424e58c6bd549d6c2361d1467e651ab496
31df3cd5aeadd7d057ad859993fbdb3a8fafa6ba67e272efc0
aecd4d4f57cca1f0f4e7d094acc91f36854792ae40e76e8f6f
c824ba22d27abb678686e77b18adb2f26bdfae66337e07d2d5
9da377477b9a8dde4a58ac9035b83b265bbb0f24cc5229d66f
a0724dcc827edd5427f5d3fce8500e0da7d048049d0adf11a6
4b81b3017a3080520134d084324de82083865c286d99b2d069
039ad29fd4dfae17a5f428ab3eac5e546fa8c539153adc801e
a0612a67c2cacfc4cf3bd19a13cd38d18413f53851dc891a9c
16a7df297a4404d3beb78b68a7c829f2fc61fc4b715a1767e3
ef8f8be2f16e0fae6bfaba02fdb1027d4c81ca8abb158f2844
8a8c0f1cff1bcf34fb9c22a59ba1f02f072789ed606be1d779
c27ebb70e13da69b1fc2e219a19f0b4425a9adbd3c70d75270
46e8061313b34f569e7bf8d8dd85a845327adfb367def6dc3d
230787edb1788249df76642a72ed2f04833b4d0cce1c18a81a
5ce51afd8ebbccfb4ae59951fdcad71e18dbf7dee74fbdfd5b
0336afc32cef99889ac5f4cb6f6e7fb00a103364241fa01ecd
9b1ecca107b3280c4314d71236b5b4845192c3128a75b6b6b6
bcbb05ddde826e6b413d2da825d1d9694aa8a549cee4d09a92
295f308cc20d08a9077a7d76c6499c794b2ba35669194acd3b
73ddcfc89a508f87e6e92d8b8d81340d7884c60e5c07b2e537
5ec82121376a68100cf8066fcd4f74c0c2c5bc6b47164b3a5d
f74456e4acfc478d516f5431e15663a539d9ed562adcdd6de8
8fd8b17d93be60ca1149a7631a84aca170dcb5d96b08c5532e
26ecd4b8d26331675a875ec42ba1ca2fb35d2e09c79922fd71
3a101b8898bd626d93c375ac233ad8c6d934e2ca379d61c6d4
c0a15fc3e258a3d1869399c6c868a6494a761dc6605ef71a58
fc28f5a7cfe855963d60aa16fc7d316d16bfef43b7b575ed0d
fa020115ce2b747d81fa1a45bf937a1f459fa0ca141da5107e
f30910e9a5f7e8d1a47e46bfaa17b5e9fbc1b5c6face07d144
10b983880aea827430988d3d9445d359d491dd93a5b30ea9af
6f7474b80f9b70cce7f0fb59075ec360f1565731d3e4dd4962
bf7a43fddd348c8fb0a0b944eec983ef4be46432f2fafdd587
7cf8310123aa3efa238b7558e33192ea9812888aaa064f8eca
d18f720a7fc87b2ce44978f4de9e63d9d891819077f4f6497f
4f7bcc6468d42bc55eaf3691eb48fa24dc401bdb949d6c4b14
f7c6bd03f3fdc1aeb85f6fb529fdf493e1a3c970b3d91b6d0c
e47339b7233f7ea22332b33fa333e8945abd148df64def726b
44467f47b3675747aec9d5b567ba33313d14d2e8353633e823
0663eda7c0d69ba813f98e26e6632e74b7eb1117dde5daeba2
9b5c3117edb250e8511aadd0efa2e956ba87a675344bd3b456
c6e92c1abcc3e14256998f1f7c372f7e9f5f0ebcb4f9d2eb58
6e97123ae1efd6127fdb4c83882923fa90c6dbc0443b3cbfaf
6473b14a4bb28391fd5eb227a817716ad1959f667a39d566bb
afbba591e31a5bba7df48b967077f34f817a19f8c73b81fa2c
55cca73622e8506421423fa4470fead0bd2af41e056a6fb727
a886784f02e9126c229e102512860e3bcbd90c0e1b6a67b276
a0fbcb417086d80d9249355e4d08be9fff5b5bc60a13257e6d
e1bf718dc32f6df153227eaa7c672edfd460b0ba8fcdcd065f
7d5981d7133f4a77b3325acb761cedf38c0e759b0d16258ca4
b938cc8e1dad7dc1ca1d1d1bcdd9a1a0e6abcfa0cff2d30373
64a0b572509de91dc8fad48e08eb4867322ef429361db09039
9302f8179319f13df9c18c0335382c0ebf4364956564d0491a
6432cee13239640a87cbed76b91c76bd5ea6b0d9657645dc66
37d9e03f8e1c76a5cb6d333520859e310a33caeace7037c803
efdcc1f8439616f8556eb2194c32615d4172c8a28288c84f3e
2f6034e241c72f48077f2f85cc8b3e1c8d6a9495ffaad0c8c4
613fd279627eafb9f23f7c95c7cd3e0e4f8bbcc8683705ac9b
5fa1f5ce60934dd968f37a998e03e94d936830d9ee10e35596
13c6660f703c8664f90f0683f1aeae36ab95d20c6afae3c309
a62d3ecc326d1e45b289696306d49a7e8d4ad3ef5194daceb6
dddb262ab4a1110d6a83dc38d3666298b6c646868169bb62a8
353e1c57ba3d0acf8371f48e38ba4f81ce2ad049058a2b3c0a
6e386e1a1e8ec380e1411e4ffff8d8d8f0707f3e1fef47fdfd
f9b64e8f3fdecc04bb14c3a38c5d813456c6769308710ae6e5
f8f84c92df4717b6c06adbe9d859deafb97891447a5ec2fafa
72ed56b156abd5c33c96ecc813f3e40d138f3f5661b00f0882
971a85159eb0170f966bae3dcecc6444442bbf34f919a358e3
6a5c78586d564b35964605da6def1c3e90b8f37274281bb755
d252b7bb516779e22185d5a8d6dbecf2caa76de9be42fac317
ad898efe105edc292d2699de19f57fe45b46a7d5a4d41a9462
e4f59a9287069eacbc38b4d72fa7f13e3efe6e16fbc60b2ad6
e3d1690d0a317e99401e98dcf35d14f60e643c58bff8e9888c
f8def3f91ea35105da91295432c1f326126170b36185caee54
385571bb1316974eb3d9ee7572be70d869f479180e5cacdd22
432a2363ba5113786298251dfc52629b49db7497a7498e4c30
f07ac1627b4ea7ebb668a4a2fa5d99146fdccf283c9e46b3f6
c52fb99cda46b70175da82a138fb33b1aba7b3626bedf2aa2a
3fb736b1c1266ce67293c11ab456fe0c595a52b06a5188f042
20d75a79fc6fbd3d0986e30ca181e49fa18f79a30e25964986
fc86c71558211dcc47ef9123b95426a3ec4a2457a229849488
429c4269522894202c335e172b64c8a750c062581896612dfc
12f463febc569d55e981d34b497cac08b98515317fb8c86b14
bdb27914fd8703a59c43e5f75f3b497faef2dcde23499b8a73
8aae5c9b73e7f6462b6f883e6c88edeb422a7c4a873cd592fc
39ed57df21bcd3fc53ea287f12301491caf274f859d1dff127
016bd0e76bd057a8af5229013a8da143f5d0239577e1271500
7d2781fe3e759d6aa0945f41d444afd59a17de72273bd78482
770a143cc15380a8745a46e751a61e270ffd7c0dfabbd447a9
491eba2313a5f2a8a31e1aef84fd4af22240bf9b7f3ffdbf1c
e161194626cb23661bb578cd46e87880a703355625914c5ab8
3cdd7633f4f335e8ef52bfe2e9a0a9f6360cdd7e33f4dd35e8
2bd43f5149017737864ed64313ef4828799f4049b82a918e0e
36790b1eaf4aeeabf1f8974f8ff1b0be2699398f3c3558fc6e
19fd09ba53f21865857569326f0b9a51407b454b07a0db9df7
fb93b6f3309f203f6877e8a9b04442755fba367d895f63f24b
4c616d895763623c5daa5b5be2a993d8dabeff84dfd1d5958d
d85dd1dcae8ca979f640f66124d335c53cee16974e8ae4ce54
0b137641df11bb4bef3bdcacf775149607f7ac15b21e8dffc8
07960cf9d1bdf960a8677c24a76e3b57ea63d30323c3d09736
e827d17708e5b0c4b158ad0aad8ca2cf6bad460b922a281992
01cd5f4240f2b5e9bfba880f9ca0d866e225dde5440c6f2025
b7cfbac92b7d0134ec5337faed95a79a9a6d7299159ca849f2
d8e6fd2eb756d4d424d1b3767421daa6943ba17503fd24bd1b
5a073de40d52494383f7bc46d3d81292cb6d8d8d8d20affe0b
4ca801ffd87c7fde704a8eb2f211f961b948097d9e922229a6
8d21b4e17d0b988726f0120b9f118c25ab272b3099d56726d5
a93feed1fce916b23830a3478251a74e11ebad28def9070587
3bd16ef5a7fd96865883357564b867bac3d9608b4e6c1c1029
246a8beef71dc547960ff883ed5e5da337a0b60ef5c5831dfd
4e534ba6ffe09901319e8764c01eacc0572775241f7476dacf
4bdce7db3b25eded924e91ae3b1cd6ea3a3b51a793d2692908
8a6892f223ff73e810a540fd5f32034757c1402e094f0df5c9
4b30e14e622fc91f46171ec01aebd80954d9916ecdb9c961e7
adc3bcdee7f0b4d9ca456dee6893591e94b9da2676f986dabd
f3e99c4312185bdfdbda1bd071265b2414b13be29c25dc7f20
248e49acbe8cdf1976680c8e268dded09ef4998339dfdebda6
8e8eb82c7e6430a432d994568bdea837fb5a9dadbd413df407
15e87514f857501a6a28af53537890568845e8bc4625154bb1
3ab51ab9928aa16e44e32ff4e023c187be4461cea7c9695afe
940cc4972e2675e4fb96e420aa195c4e0a49bd3030ff55b97c
77e5497457585c41b4e4b14af0d8850bc7d07ffb50e51b5803
1da08198e441ca47f5e41b6151253bef7205689f4fa71381e7
15d1461ba5466a2c721a444e6d893c061d3301960472270684
ed47eaad89d5bf5daae280918e25ffa1b5eff6c36db9e31bdd
3dfb7c7a5bd01fb0301d5197c412197ffbd4c7250f1e3bae8c
8f9cc8656747c2218fd9a237e96da15d9cd49fc8c4dc3422cf
57dd406f0a24c6c0f895cd5b294a7d3e124935493ce7ad4dad
12f06f01ca800c7800a1186100c18be44bf8f16922c1db3a50
aa1149abc7506aa74dc449241c39d8dacea1bdbd670ef5d95c
03c9c8be4e5f70f044a6636eb8d9999d5a7d64aaf28848a2f5
649b4d61af55d59409fbb292b37464cf4297a6d1999e48a58e
0f8562fbcbf9c4a9d2e13e7fe57e5dc8ee3d3896d2fbbb5a1a
77f7c71de4dc14709301e92b6134d42011f047536aa55ca190
8b40f75fa660ddbca56f72ac37593dd68b358dbc46deaa3374
a6f2f7c7fff1c7aa262e68699e903cb8d9483f2432f83caa3f
a244a497b9406601aa9dda43edcbfbb4a8a56530684a81c2b3
92c141ef580a49245dc89ba59884c21454f4510cf826685841
060ddcc1c89b1d64394b5e470222f0a34a7ca40e3ad8d61295
3c8baeef5afcda8617269e120953c9a4f0f0e08abd2de270ef
da9f4c16ba3cde64bb053f77f4f71e6c6d3bd2ebd7725d1f68
6ab6c81d8190363dd01e372919a751e749f953c33247aa45ec
d5fb6339ced3ddea7246730c9b8e7854ae643ae7090d259d4c
a217d67cf1d4097380f3ea83515b43b6c5d7cb6ec8ec81366f
633ae2ec4caa9b020977bd4d39c12b75e6ed2eeb7909cb2643
e7d5605dae18362a9f81a29cc8894562e045a2ab9915bfd112
4b5e4d92a12653ff6852b02f244c036baf0da493bd670e8359
0d6e33abfcbb5e388fde0646e56daf332afa9b7478cba84e0c
85e260547b9eb8a78036b461bbe7d0684a0726651f0193026f
6cbdfe4bba93fe8948aad943519bfb29f997116584556a8acc
7536c0a2be434a4749a9f4294aa680425c66a010bd9b948ddd
549601ac5652b6b75ae6570a652aa8374acac66b2de2e3ff7c
8b1d5033467f1f4a27aa35d5d59a6e284b919afb6a350d355a
bd509a213527ab3569651d3d2e52733f29535ea0614e45aade
80b950c3ece43143afeba228e9af24775107a9b3f95dfbf6a9
0fa6529de3eea621ee20733011e23a0f42301d76399c267583
476bda974a68557b9936f58462a82fe2f6491de6062fc3b20c
4d7583f2372fbe441e696f9d2cbd8c9f1e9139333ec3b07959
9fd46d266a2788a1df625b20affe27abbf1682b734a40d0d30
81766792fa7466ebe7c6f85351649360eb6555fed71fac753f
ff207ed2da31b7f78ac33711db7c213ec559fed374a86db7d4
af13a73f112df7f4f03f352ed13a436ca5cbcc869d3a8948a7
ed8fc7d3e91185c2e51caae4ba3c66a54adc9d1c0c9b7efd0f
7735857cbeb6a635b14a633c3d8dba5a37d736bcde03d3dd9f
affcc9945b65d448394e617419f1ef907fa8251eb5dbc72bce
dbcc569d96e38c4a87738abcecb347085f419d75e101f42a0e
74942ed17f40ffa5e81eb1484237281a3e2bbd4f7654f64385
58f1df9549e567b6825a01e1079a3fd1beaa7b45ff0b63ccf8
aae9fd9653568ded70e3a3f698630407e78f5c9f615e604d42
f8767df0bcc1797c0bfe1f067f111a8f5c8ede15fb5fad9e56
4fc2d5f6d1f4a9cc17b3d1dc5ac747bbecdd47f2dfe85dea5d
eaffebc1c34367de243c208427203c3df432849f0ffd7c585d
0bcd10f0353f7ccfadc3ee2c0967fe1543658f7e5b18e2c3e8
e363aff061efc2bf14c623e3ebe3bfc061c20fe1a33be1ff6a
787927ec847f87e127bf8bb04fb41376c2bfc1e0da97d9b773
ed5c3bd7ceb573ed5c3bd7ceb573ed5c3bd7ceb573fd46d7e4
b1ba707127fc9b0a2fed849df0ef30fce07715f61fdcff7841
513016c60a5385e3858f143e59f842e1e9c2d70bdf2a5c2e7c
b7f07ae16f0b6f14feb15039d070e0b5a9bf3878e1d06d874f
1e511ef9dcd1ecd1a78fb51dfbc3e9f8f4f3d3ff7c7cf284e8
c4e489bfbfedcedbfe7771692633f3c3d92fcca9e6de5b9240
f8e5c9bb4fbe7253f83184eb38cc1b2034cfe74998aa8533f3
f7cc7f9884a77ecbf0e2ffbf61c1b730b7f0edc589c547177f
726ae2d47b4e1b4f6f9c7ee0f463a73f79faa9d32f9c7ef9f4
eba77f76fada9212c27fde093b6127ec849df0ff5220675310
fcbb9d7c53ff1b9484fa0c25a2b8eb8fe0d372d7bf07711662
1365ba7e81e22811e47390ef82385bf927880f5f5f80f8d8f5
7eaa99d25e3f06b19ec41ce4c700fe02fe8a3394c6000f8e8f
018624c94f02bc0b623d893928cd40fef720d642dd0ca52339
7a92765d7f1c6206ea6600f218c40902d97ffd6d100f927898
c4a3d79f857892a40f90f414491f22e96390ce9256b29416e8
cf9256b2949ea45dd056165ac1314772fa81b62c60c6f1e8f5
7b219e24f90748fa10898f41e9083502380f00e54f42acbb7e
05623d507b80da0df98721ff1d10eb213e46d2c7481a5f39fa
eb14fe1213be96482c221a61c89d887caf53834c425a441da2
fe46488beb6024940de5847403e54193425a4add5e83915171
ea8b425a4edd87d685b45a2346bfaa7d9938adad0869446975
6d429aa6a4ba0784b4888ae8ca425a5c0723a154ba0f0be906
4aaffbb49096521d35181965d34d096939d5a77b5648aba5b4
eed7801989f1c94f957593a42590d6d9d4248dbf01a7b2b948
5a4af29b495a46d25992960b32e4d3bc0cf9342f433ecdcb90
4f8beb607819f2695e867c9a97219fe665c8a77919f269b5c6
621b2169451dfd4a4c9bff0449abeaf23538ed2f9334fe3494
c67f37491b216df03f4cd2a63a7833c623a42d75f98da4ee13
24ed206df1385d75304d75698ec07f81a44324fd3c49b790f4
9fe3b4ac8e7e595d5baaba7c559597cf522c950089b4526948
15a805aa047fc7a832b50cffd7a90d6a85e4f4c1dd2aa4715c
84fc45021185921e90ec12fc9d84bc79a8bf4ead91bb12fc2d
01f4ed10cf11c802409c21f92cf96eed39025786bc22e062a1
149714e1ff3a69650e6070d92a751af2cad4c9df8ac21b2173
ff221d98f679ea2c7085db66a920e058a466215d863a988e75
181da708776b423b2cc82f0a2349ba0e3b8f7b0bf304b51f30
156e417ba196ea27d49f031ccb40034b8d436b2749ebb8b405
feef877a18db12e46c08925825b2c35823903345e0d7493e4b
8d122eb02c97218f054d6761ac4edc8227165267818e15c0bd
48b4c6427e99d4c3fa3b0ce9b3f01773835b3e4b348cb5b520
e8ae0acd92d65982bf44b4512294cd11b81522d90da2eb65d2
ca0ae180af392be0a8d25b24985788b4cf00d43a29c3b56608
8e75c1229604292dd7a8e26bac919679596ce555ed89e72152
bb5fafd9d7cdd25921f77350074b3742e4c55b78553f7c2b37
72b048ece31c91d22cc4b796d83981530c3d0bdc9c253a9bbb
a5e4cb44ff1bc43617c11659d2536604b9dc0a3b4fc36f2bdb
2dec7335cb5c2536be4e34375beb6fb7e2a0dafacd7475d4d9
00e684e7659db457edc9183fcfeb1cf9f508cc79998c0e6f65
79c56d5655227a290b31cf159f3e0b772b246609b55bbae4f1
60c82580782b1be547c16541335bd8abfd63519032b61e4cef
0c9134af5b3584ea9886795822dc6df5ffed561d219a2992f4
9c6007f5363b02b86eee0941322a633e73307b8b91922869e3
34fc5f21b816016b9448681e20aa653101e7091845ea713613
4a8a7563c55a4d62556ac609e6e5bab16d94586f599036e673
9e60e539c712eb25d2e1e92f12af320c356788adc128cd3a6f
c0315ac5c1ba6ad67c0af2783d55ada6447c106e6f659b754f
923656488f1c267688f53a4bbc4dd52a77139d2d13086ccf6b
35bf87353751eb396b759e80d7376f0525a1ad7962cbcb82de
2384675c5aaa8d3c78642812f9f37aaeda316f572b82b7e15b
280356ec05309f554b290a76b922d8e1c9dfad2e6a122a12de
b1dc1685917e4ee8abb380fd8cd047b63c324bfcd9926033c1
2a8d6fae5b0afb3c7e0c3e472454026d37d7c9688ef898a56d
e3cccd3cbe053e32fa2e927a55e85b8f6e911b46b7aaec6fac
bd44e6008b37f05da56b75db4c89e761cb0f55751821e37d99
b472b2765faab3103c6ef11a5a036c5bfe95a77a86d05212fc
d4d99a2eebc7125e873141e36ba4972cd568a8f6ebedb6f49b
4b75ab852a97f59e66bb4d6f49e21c91e399df528f556f7016
ee9705c994ea289823316e734b2ea70062b6ce77acbfc578cc
8ffc738483aac7cb6d1bc58b80b14c469c2d5d6e699c15667e
552fb3259faa27db9251fd98b2bdd61a192b785dcd087cdfda
e716df44a3ab35eed784f9e43ae9bf4b84025c5eefd17f5b0b
a8fab7616a80948e53837077907ca918e78c401e0ba3e82494
4cc15d3fe4f6434e0020f60be501a2a983c40f0d03dc01e2e3
781c9310ef85fbc3648c1ba458728feff600fc5ec085eb0ec0
6a7182b4b89f601d8734c63d06b9a3f0774080c335fa20e700
dce3f4101905f9f6f642ad02e17644f0893ca505c8676b1c6e
a76a84b458a56c0cee2601ffb050da03b847083e4c3f6e7f90
a4f7d6e81c1428ed2132c29831ce3ea06894dce1dc03f07702
e0f693f67b08cf3cb57b090f8350cef3324028c02d47055e79
382c9f29a104eb08d3370a618bab1e22836142cd96fcfae0ef
04508ef10f416981788871a8d94f38dd4fa43720c80c733b4a
eeb6b8e235d547b8c152c532e887f418fc1faac96e92c43c2d
9375d8b6cbee2029df82e2f9eb11e23e22b97172c76ba38fdc
1588ae706944d0e524e1e3c6560f124b1c20503d84e3fd350b
1924d6cb535fb54ebe8df13a4af8f6b06eeb69a95a35fb167d
84c7522d3f2068fa66b960a9f7109960baf6d75a7e33ccd037
3fcb26e2ad69b6b05062c7cacbe5f58d9512db575e5d29af16
d717cbcb51b66769899d5c9c5f585f63274b6ba5d5db4b7351
b6b078a6b4c6ee2d9d6327cb678acbece21a5b64d7578b73a5
33c5d5d36cf9e49b23ac66e66ec431599a3fbb545c6583638b
b3abe5b5f2c9f5e6a9d2ea1ad461d3d16c9a800334019ed83f
56a8612fe0a87fb5786e71799e1d3f797271b6c4b6b0fbd78b
cb4ba50d20627571adbc1c61a71667d7cbabec687175aeb4bc
ceb66693895a4becdad99595a5c5d21c7bb2bcbc1e650f97cf
b2678a1becd9b512bbbe00dce16c76bdccceae968aeba5083b
b7b8b6b20400c5e539766575110a670102e32daeb12ba5d533
8bebeb806d6603aa97d825206919a38282b5080b5490149613
b410c17f31d816392babe5b9b3b3eb11160b1cf30355aa0d2c
2eb3e716166717ea083b078d2e2ecf2e9d9dc3caa9125f5e5e
da60838bcd6ce9cc0cd0b2050e18de8a5a023e8785b95a5a5b
5f05b1810eb61ac0d56bb83a8804828bd0ca7ae90c56f2ea22
b43a573eb7bc542ece6d175e9117556915b35386a6203ebbbe
72769d9d2b112e0166a1b4b4b25da26082cb1b0238d6072004
f12c2cce2c02cd51b51a5bdac9f2d25299e85f1075849d29ae
01ade5655eb223859a12820bebeb2bb958acb41c3db7787a71
a534b7588c9657e763f82e0690274679c8e6085b2456b18609
c368c6574acbc4da468b1b4039bb549e5f9c85c657d9dec519
c05f5c62874b33ab60d2af0a10a318e23b58cca7cac013164d
e9f6d252798517f764716965811d2e2ecf96674f1351ee2e2f
2cb3c367e7d670df53ab27b072d6482700be410425a835bf5a
04c9cc45d893aba512369ed985e2ea3cf08c650cb2028d4275
b63cb35e5c5cc64229822c5736aa66f69b7381092aaead9567
178bd83ee6cab367cf80464847664f2e2e81648218e3366ed9
fd60c1e78aaba5ef34138ae64a807091d7c32de1fe0f7b5f02
584575fd7dee9d798fbcbcbc7911101296101065312c424404
4402494830040c61159135066493552802222202ae454a69ca
9f5a4afd2c1fa57c94528adaa2e20241360151a90b2eb57ca8
14159132ffdf9cb97979f3f280242424919c9bb9e7eedb9cf3
bbcb4ce6c5cf1c3b2dd70a0e12b704256e56eb0ba2c78f859c
da755b654db1410935b00e593d4c889f3069f4d81c8b8fe101
993c1d1d9a9acbfa8aa2474eb77477aa15a8a4043d6c838e4f
1d03944309d6bd56a314b6a99cc1aad2561a35d2dc8899b993
265ca48f961a4c9f32118d19c3058c9e143f7512b765dc9851
d30a04ac508e21fca3c7b2e275b2457cc4c84933c6702fb9e3
f1003f4b65b83d96924d2e941415353577047a35728c437347
0475748a55fd54e0e4b4b1b845505e5bd12f360096bea5a5c4
f7eb939a3d30292b253ebd5f7cdfac3e03d2935392e39b25f5
83bf5942fcc0f4ecb43efdb3e391222b29337b707c9fd4f8a4
ccc1f177a4672627c4a70cea9b95d2af5f7c9facf8f4de7d33
d25310969ed923a37f727a66cff8eec897d9273b3e231d9a88
42b3fbc45b15aaa2d253fa5985f54ec9ea91066f52f7f48cf4
ecc109f1a9e9d9995699a9283429be6f5256767a8ffe194959
f17dfb67f5edd32f05d527a3d8ccf4ccd42cd492d23b2533bb
356a45587cca0078e2fba5256564705549fdd1fa2c6e5f8f3e
7d0767a5f74ccb8e4feb93919c82c0ee29685952f78c14bb2a
74aa4746527aef84f8e4a4de493d5338571f9492c5c954eb06
a6a57010ea4bc25f8fecf43e9956377af4c9ccce823701bdcc
ca0e641d98de2f25213e292bbd9f3520a9597d50bc359cc8d1
870b41becc14bb146ba8e31d7704492c7fff7e29856d494e49
ca4059fdacccc1895bfbb03c98c45b0d6bd93f9197f4236996
f061e13e0efe7ff1a6a320bee0d879b47d9cacadd2fea4bda8
bd8cebafda366d7df57172f57172f5717225384e8ee4abfa48
b96a1e29db77affa58b9fa58b9fa58b9fa583914cdab8f969d
47cb05a3537dbc5c7dbc5c7dbc5ce98e97a19b853bcc113c4f
14f83fe21de718c70e748c638fc9bb4c3d4ebf49bf43efa9df
06fb56a41e01f4b3d6ea3666e58a8de2371a31862621fd14e0
86bd2a08bc8f496663240f47022922d0c46bc8659ae4b7de62
ec2d3f6b27495b4ed4dde5ca805f9d75179009a2dbcdf3d9bd
33b3dab6255aa4debca5282239400e2369552d9791908fcb5f
922657c95570ff4afe0aee3c9907f7afe56ab8ff477e0df737
f20cdc3f68d790d06a6a3549d36a69a970f7d4ee803b439b0b
f73c6d1e496dbe761aee6fb57370ff579f4a429fa64f234d9f
aecf827bb63e1bee9fe94fc3fd8cfe73b897ebcbe17e567f16
ee15ae0412ae56aecea4b9bab89349b853dc28df9de1ee0d77
a67b20dc83dc83e01eecbe0beea1ee69704f774f877b867b26
dc0fb81f21e95ee47e14eec5eec7e05e52632d891abfabf13b
d26aacabf167b8b74424918ce81e91475ac4af234e9288f82a
e234dcdf7a50b267b06726699e07bc1e12de48af8f34afe16d
0e770b6f7bb813bdbf87fb79ef46b8ffe4fd07dc3bbcafc2fd
9a7717dcbbbdf924bd7bbc5fc0fd2fef0984ff7fef29b8ffe3
fd16eeefbcdfc1fdbdf77bb8cf787f80fbacd7242d8aa27690
887a256a27dcaf477d03f7a9a8ff908c3aedc39df645fb6248
f3c5fafac33dc07737dcc38ce1248c11c60892c64803a36acc
361e24dd986bfc05eeadc6df11fe0fe335d28c9dc607083966
1c83fb9ffedd24fcf9fecf49f37fe1ff1749ff97fe2fe1feb7
1f23e0ffcaff35dcdf444346a261488b96d1126e2d5a2319ad
47c7c25d2fba1ec2eb47e7c07d6ff4bd70e75e7307644a5792
25a931df6bfb2edbf757dd598c7616c6393b027730625004c6
396248c430b847448c829d133119f68c8859b06747cc41ecbc
8887602f8858809087231e867b61c422b81f8d780cee25114b
e17e0a77d0ba77a7d49d92b84737c29de06d83116eeb6dcb77
017df4fedbfb6f1ee15761bf16859189da89d1b6c6f65ad875
7c7530aa757d75e18eb1469b7b134927b46de41a3165c4488a
1f356bca787ae0de2963eea325b963464ea1bcf123a64da4e7
a901e9a9495958c4f7ce181c4f89fd3293e3a95bffac640b9c
adef616ae482bed6536e3745537de5ae016d6ea0dc1154931a
2ab7876a511c8fa9e5d7b925b5a9515088202f5d0b182b08b1
7e05339a6446765a3cc56567dd110f00b6534a687b5d6aac7c
1a602ec6fad533f6e964502c5d474d474d9e3a998eb27d9ced
936c9fb16c21ef1b3365a28862bb29db5dd8ce667b3cdb0bd9
5ec2f6536caf603bcf7ac6269e637b23db2fb1bd9beda36c7f
c1f649cb9692edee6c0f607bdc84fb26dc27e7b2bd88ed27d8
5ec1f66ab6d7b1bd81ed2d6cbfc4f64ec6d5da18a93a257045
62bc62302ef5709f1ae09ec461e4e3af40b828f8cf88b0b60b
1c608f7be6ba0c9f200fbf131f011e09c9f04102fc9042422b
1a432e200b743ddd806566736c2e5bd28d90a356981cdbf03b
d7eda83d25d2cdd4816ea18e742b96fc9da90bdd667dd3356c
99c50d93d08a1ac5e235ad5f9cbb045f2822453dd1527412d9
62b49826168ae562add82c5e1507c571715aeab2b66c2a1365
b2cc96a3e534b9506e97a7b5046db496a71dd4a5de561fa62f
d3f3f4f5fa76fd43fd6b579cbb768d8935e6d67822222aa26d
c4da88fdde1bbc1dbca9de01de1cef0cef22ef0bde6dde6351
f1519951c3a22646e545ad8fda1eb53beafda81351e77c51be
06be045f175f866fa86fbc6f8e6f992fcfb7deb7ddb7dbf7be
ef84ef9c11653430128c2e468631d4186fcc31961979c67a63
bbb1db78df38619cf347f91bf813fc5dfc19fea1fef1fe39fe
65fe3cff7aff76ff6efffbfe13fe73d151d10da213a2bb4467
440f8d1e1f3d277a59745ef4fae8edd1bba3df8f3e41d67f0f
08be241190defa0f05db0fdc38b7dfe1179eafd96ffd925b4d
0ea5ed718af70d4a0979f21e0cf25bf1eb83fc6ecc24cf38fd
35d7b0d4056aaa75c6e96f3ec3e96fd1cde96fb9c2e9bf71bc
d39f1392fedef810ff39a77f52167964b01ffd1154d8de079f
27eb57df03fef91141f991f06fc79cfe17739dfe9716b2df05
448e21eb70a7ad3d4eafa62a3e5cf1d98a2f577cc305f26d55
fca0e25fdbfcb528c59b87cff75aa2e27d151faff862c5d75e
20df46c5f7287ec2e63b2315bf407d3b3b289eadf814c59f52
fc02fddbb95df1a38a9fb1f9eb75144fe47cd66c5507387583
0a4d567cb4e20b155f1b36f516c50f29fe9dcddfa8132ef51b
cd154f533c57f1c56153af527c9be2aa1f6f9c756ad8bc0521
fe634e3d7ae314fb3560636d6a6087bdd94971253b6f6639cb
5860eb5e488bde5ca1f81ac5d72bbe8d53c700c1bb62fb9389
adee30cac1266406cdc5f6e0095a41ab691d6da02df412eda4
3d74888ed1677452e556f2f7e6878a2bb978f3accddf722b5e
5b71851f6f2528de45f14cc5872aaee4f2ad398a3fa1b86afd
5b9b15dfa1f87ec53f56fcb4cd77a9fa77d5535c8dc6ae44ee
7513ea85adde103eea9a42b369012da16768153d472fd026da
463be82dda4f47e963fa924ed15921318fd4c44cd20473493b
cc26dd452f91a54a542ddfa5e462d70cc51729ae347ad75ac5
95f4ed523dd8b557713592bbd408ef3a6ff3ddd18aab11dcdd
5af16e8aab11dc3d4cf1c98acf57fc19c5d729ae4670f7ab8a
2b2dd8fd85e2e76c9eaf903fbf89e20a41f2951ee40f527c9c
e2739dd2f890db29d17b86b13f8a25b37518a9b3532969dda3
eef71e25ad7b943eed51addea3466dcf31c555ebf7a8fbffb6
545ce1e2db3145f5e96d55d7dbcf29be91d37811df146b9d44
ac6792b16ecfa6a1d8872bb9dcabe46aaf1a9dbdf18a2bfcda
abe47a6f2fc587289ea3f834c51542ed7d2a9cceee5352bb4f
61cfbe8e8af7e2d49d690e2da465b49cf2682dada7cdb49d5e
a5dd7490dea7e374824ed339a18b28515b34104d458248145d
44b2c8c01a68285641e3b10e9a8395d032ac85f2b01a5a8ff5
d076ac8876634df43e564527c469710e2ba328ac8d1a607594
80f55117ac9032541b462aaee46c9f92b37d0ad9f7a93bb76f
93e2ea8eed3ba2f8978a2b39dbafe47b7f53c515caed5723b8
5fe9d7fe898aabfaf62bbddaffbce22f29ae1061ff678aab7a
0ea83b76a0a5e2aa9e03aa9e03aa9e03aa9e03aa9e034a7f0e
28fd39a024f18092c0030a790e28c93ba8e4fda092b283ed14
57a87d5049c44155cf4125090795341e7c4171d59f830a690f
aa713ba866c477543defc428ae64e51dd5af77d4fd7a47ad30
de5133f03baabe77562abe3e641659e1d4db433b42fc212bbe
43279d2bbc85a94eff239d8a6adea1e38aabd5cba17321798e
15cd73588de3e1ae8a67701a3756a8f580e72db123513d3fac
24edb0aae5b0aae5b0928423aae5476a87d3bd236a9c8ecc55
7c89e221e3f2aeee6cf32219aeb47795b4bdabd643efaa95ca
bbd9ce515fb439c88f75e3bb6b8ae10f5a67befb7c887f7d88
7f53887f6b88ffa510ffab21fe9d21fe3742fc6f85f87787f8
f784f8f787f88f84f843d6d5ef1e0ff17f19e23f11e23f15e2
3f13e23feff41fd543fcee107f5488bf66883f26c41f17e26f
12e26f1ee26f1de24f0cf1770af17709f1770df1770bf1770f
f12787f85343fc6921fe5e21fe8c107f6688bf6f883f2bc43f
28c43f2cc43fdab9433d3acee97f7f9bd3ffcfc810ffc74eff
8721e93faae3f47fbccee9ff646188ff33a7fff84b4effa7f5
42fc5f38fd9fed74fa3f5febf47f11bc1f7013fd6bb3d3ff65
74887fbc33ff976f38fd276248aec9b35cbfd57fbf9c1ec36a
be9a2e83cc2771bdc766739994f5a465b84c9477f965561499
ef397c55b61f578aac7b5e24ace1f933a6f50d9b0be7ca3593
9df166c3b26e597913f7b2e5c57ae94cadf850fb62776ef9b4
ac7251e97a194ef32c9981e4b4bf444e874416f7fe541e2a5e
2f0b53db6365c95740c6aa5c9f4b4365d74bf311a0d593e190
cc916a4359d5573154bc5e16a6b6e742466a68b0b90a798716
ce8ee6fd9661d7d6606e6eb5e3caa3075786827b59825cc883
f920f9fc191eb35c8b07e202ba693e62875ba31bb0abdccc57
48c1bd2c3eb15c25439e18bb608246a0707e343714f020fb91
cb6d71c551e9eeb385ed90ab862c57d6cc103c56eded8b57df
ed0be3cc86c59d3d2a2b95974e1453b3ab307a9584a061872f
361f146bb432caac39959aacef4baa6f4c56533585a1d2ed07
ab096371a4d02ee79aaa77dce1d23f191ee9af8ed1ba1ae9a7
853e4557bb0521e7e795e74a385cd9e7e7955f7d55834a7e7e
75f552c9cf64ae4e2add990ce78cb4af72a08cf3af98c6f957
2e52f7d672a9b70474b1d65d5932579bf9e66a76adb2afca46
76eb2a0315b6c4ccb1afca46c16375f1757b71b1ad98f5ae37
d75f20bcd1f93721ef6f0642a63ae273c3855e29b25a67baac
969bae2b586b2fb3aed9de1c00577d3be4fc46d3ba7ad9b16c
07e61ef50c7f98398c7d41b3f7953c4b340bda55d7e695812a
2356155271f6ce65a5836623b67fd23a58b67875c15ade33a7
9addc1bb5f89da4a4a414ff9ae60fb302253ada741a1cffe11
baae485a47aa70ae2b45e61f8b996e5799d61a5603c3e96065
a292cc8316d6d878530eed4835879ba9e55376d99039bca25b
50ec67655588d4fb0ca9fc3e439e9977b9a5318ab3e1800cec
52b3cdebec71e3bad44cc73b9ecdeadd88cd6c4fe5f72518c5
aee47c88f6bd57d0fa4ba4b49e3b9f85be4ad697cbd496e2af
45cd9baad7a2974fe64b15dd822b47e683e683965dacb44152
5f90a3f8b97fba5459cf646c2ad61ea74c577ec0ab5ed57be7
12d6ff4145d45af5c8dc626e617bdc05e237daa92c17523d6a
bea67c9b0bf2dbd7d540e649f300ec0325cc75c03276fe92e7
fea9128fc57b01d7e76cbfeb48f1935bf15f88c29d33844f17
9aab22cf1a2a866c5d2ab9160574b054b9aba9a2c8fc543962
4363ce7f6a5f252e719e99cf3cffb21a56c988f7f0191891af
c0df56618915dba6ca49b64499abcc4f0bf618e6ae9f962c94
1f99a5d0b74b965969777a25237e3abec13ac7339f37d57b57
e662f3e715dbaaca49e6cbf6930af34f6ce75bcf54ca43b67e
1a6466e3c2fc777e16f852fbc9a559643ebcac1acae9ff26d4
4cbb0a2603669efd2cc80a05faae0c4ee3c8b5d20ee77c9b4a
545f868d26767faa0aaa632c36f19858d729984fcdade647dc
7ff4dedc1e4897efcc15524a097b8b3a4fb15de1ef859584b0
7ab3c74ac905c66a8892959f07cf25171f0d6bec90b3d823a6
d60c0f9b6b50bfedce473b0a6b8b2d9d4696ef5ad46ccc7ad0
deccb1fa5a445e720ac6112efe12ba3da6f06d82b1bea83caf
3034d0de79accf177d0bac0aaf45834f4863c386dae1657c92
6aee29dbf2ae08c556c48c7de1fd6065a6022d87f9c0fc4485
9d506105bb9095457205424afa74b8aaaeaf80b0163207deb0
51e3b6a9d02e0c0df82eb35f97c2f6ca4f965cc13e1cb8cbb1
c1a3c208ef1823b546b27a1982e3971acbaa2a574529644494
cf5a1185a4cb2fea2a8b1aab12856f79d1d0d0b12ad9dafdd2
355636e2fd497e60d56969dde3981587abde4f08a42bebdec4
72dd47ecda29d23c81ddc2d381dad4c53fa654322ac7e7c3e7
cf625db915a363214eac65782e9c64c79a81ff5303265d44ae
8a50fb4b4999b5b2b257ba5465d60c965c312fd4276b56dc15
b4868f0de1a1145bb0bb091acd4bf4fe52e7a285dff72819a1
c4327ddbb448e9f314ff3480e281e73b6aaf688fa6bd8ac857
bbc5fcc04e671305de38b1dd6a8f7371b99a192cb5a1747e93
7dd9a597a03719aa37e5b21f3c3f8bdf67fb9477ab05f7b8e0
3d783b749e196b669cffc88ce4f39a0c3eb78965976dabff5d
635908a08b157bd15e95fbf955d91346c23e43b2f1ca92197b
8f6cdf9f0b20ebe5ae1a71dfadba169b1f5f5e3915410a6f56
2a3d532374c9156521f297f80cd271325145cefa82a9a4eb82
cb5f4754c97386cba552224d798ed585678e72aaaf9cfe57fb
4a3cf32afbb1425bc7f139f20618eb4c8677c1e604ebed4acc
83e5f4c4aeaa3e1f34b3ad59895b5ca0499181673785bb8e32
3d93a14bec712a2759e729fcd5496b15101b98115343d7801c
1e40a5ab73ac4a49356da6f62abbd493c22afe2dd4b2226b7f
187c06639f3007fc81fd48d99d69553d2ad82562744e5bef32
07423f2838fd4378beb98d77dcceb1ba0c3d2dedf3c1ca41d6
de3ac8b792c7e6e2cf57af3ab90aa1e2deebf2fc8f8cca2b6f
aa654aaac2b5b3bdbd172ec933fa9f2a054eb5d4939da0187b
7df15eb0bf6a9c9c972ff17fbbbe17b4c2fac442f580ef1d7e
efe53055f0ff0895e7a968316affa840b38a4a4de0fdab4fcd
4f38766320e6aa94aea24f058b4595177faf00616d151bbc76
0afadf9ef6d6fb6e2c5f851a60ad8fdea5ab949cf32046e7a3
e0b882f56a20a88a7f4dbd9414eb78e6758131c058596b86c3
41b92e8b2aeb17cf2e41c1ebabc0b8053d0f8c75be21a2a8fd
65ee71d4f3c1c2e770c5a60a94e8807ecd0b6eb7b92e748f13
e62de5ab76651a72d6971f1a6badb54cc7377faebe75833dc7
b1abe8faca7e42f61abf8155f0f4d90ebbeac6290c5dd5eba6
b2a080e48daed8765416325750f057d9deb3fed7dc117fba70
87a342ae5a3db4f67e8e33e4e093bf4fedb12afd7b7d456a2b
e53b457415a28479b3baf24bb6f230330adf7cba3aa86c7e4f
a0eafd2ac1a57fe9346caea0df002d718da5cc57b154da5f12
299b5f07a87abf3150b2df5008e46a587a1daa7aba6751d5bb
b3154b25fbbd8940ae82df00dd53f237b48afed27355a0d2ff
de44e037404b315656deaa3756a5fb0d508b02bf017aa4e4bf
fdc579afc8b7bacb924a8fb281df002d9d5c35ac7af85eea99
ac4cbe1a5d5edf9ebe1264aeb6be2ecfdfd96e77c9b497f1fb
38e5f4bb3a5790cc848a6e41d5a1c25fefa19fcc1784ca8fcc
df9520ed657cebbe2ae3944d25fbd67de0fbeda55933e45efe
97cc2b968afffd764e23d5f7db4b335656de2a2d5b66bbc07f
dc55a3d525c8f17b5eb32bae1d55878a3b0f5abfa170fe6c29
d7ed677f2a3a68feac5a074b43e657178a39ffa9995fda6fb1
5a79d5bb29f37e1acf28f8cdc9b9e08de1b9568555bdb788ae
00a9776f7687ffe640d9fce7df95fe5fcbf222eb2b16e606fe
9ec5f3812f15f536ff52d1edaa8c649e5088627f6b2b36f43b
45e73701774af77d8613565e557a86f33facaa2af1fb47a330
2a7fe0f7961cdf67289b2f8396d7f745af3455cdef8b560ca9
ef8b1eaf5adf17ad1852687edcfaba5ae0ff32aad437e82a80
6c84ba3adf862f26a9efc9ac321f87fd5bfeead6334445bf15
86f9b2a433597bd3e12b83c65634d96fc55ff05b6197f3fdab
c27ce5fb35ac2b47fc2e60353e1583940e6eac7e1bb73814fc
15dc30ff737133d6dea57b07722fe72d58b7efbdcc66566e92
94431a0c516d18414d6124b580d1a80d8c0ebc6e4f2eba19c6
4db7c0d4a05ba91345501798484a87f1527f98281a4c43c847
4361fc3492465134fd0f4c4d5a4fff976ad19f690b5d4bdb60
ead22bf42ac5d04e987af4064c7dfa174c032185a48642173a
c5099ff05123e1177e8a17b122961a8bfaa23e35118d4423ba
4e34168da9a9b851b4a2ebc50ab1829a8bbf8abf520bf18a78
855a8ad7c5eb74a3d827f6518238200e502b71481ca2d6e203
f101b511ff14ffa4b6e223f111dd243e119f503bf18df886da
8b6fc5f794287e103fd02de247f12375942405dd2a5dd2459d
650de9a32ed22ffdd443d691752959d6970d285536928d284d
36954d295d26c804ea255bcb367487bc49b6a3de3251de4c7d
e42d7204dd2947cbd13447e6c81c7a50e6ca5c9a2bc7c9c934
4fce900fd02209438fc9c572312df1cdf6cda6a5be79be79b4
ccf788ef117adcf798ef317ac2b7d4b7949ef43dee7b9c9ef2
3de97b8a9ef63de37b867eeefb956f0d2df76df6fd8556f9f6
f9f6d36adffbbe63b4c677dcf739fdd677d2779a7eef3be33b
431b7c3ffa7ea43ffafeeb3b4f1b0d6948da64e8868bfe9fe1
313cf467c36b78698be133fcf417a3a6518bb619758d58da6e
d4371ad0cb469cd188fe613435aea7578c6646737acd6869dc
44af1b894622bd6d74343ad25ea393d18df6193d8c643a62a4
1a6974d4e865f4a20f20533b58ce04cb996439d358ce749633
17cb999be5ac06cb5904e4ec56f240d63a41ce2c69f3b2b445
b1b4f958da0c963683a5cdcfd216cdd2e687b4fd99ae81c46d
81fc5932578b65ae36cb9c9f65cecf32578b65cecf32e76799
bb9665ee5a96b93a2c737558e6eab2ccd585ccdd4831224124
50ac6805f9abc7f2e767f9bb96e5af0ecb5f5d96bf5a2c7fb5
58fefc2c7fb558fe6ab1fcd562f9abc5f2571ff2f72dcafc4e
7c074df81eb2d89065318e65b1116491281e8d15d498253216
1259839ac8081941d7498ff45053192923e97ae9955eba4146
c9286a267d90dae62cb52d20b575a8a5ac0bd9bd11b25b9f12
640348702b96e0d62cc16d5882db42825bd34db20de4b81dcb
717b96e344c8f12d74b3ec283b520779abbc15e19d6427ba45
76969da12d5d641768cb6df236ea24bbcaaed099dbe5edd099
6eb21bdd269364127595dd650fe44a96c974bb4c9129d44da6
ca544a923d654f84a7c934ea2ed3653adcbd642f68da1df20e
685a86cca014d95bf686be65ca4cea29fbc83ed0babeb22fb4
ee4e9985f4fd643fe85eb6cc86eef597fd1132400ea00c3950
0e841e0e928328530e9683113e440e814ede25efa2be72a81c
0acdbc5bde4d5972981c46fde43df21eca96c3e570ea2f4740
6f07b0de0e64bd1dc47a3b187a3b8e86c8fbe47d74971c2fc7
d35039414ea0bbe544399186c9497212dd232743b78743b767
d0083953cea491f201e8f928d6f3d1ace76358cf7358cfef65
3dcf653d1fcb7a3e8ef5fc3ee8f99334def714b47d026bfb44
d6f61c68fb66b8ff0c9dcf619dcf659d1fc73a7f1f74fe1ba4
3f05cd9fc89a9fc39a3f099aff5f9aec3b0ffd9fc4fa7f3ff4
5fa729860b28308951e07e4681a940011f4d334034ddf00311
6600116ad24ca31670611270a12e52c61831088905463c008c
a80fbb0190621690228e661b8d80173f63bc9803bc68460f1a
cd811a73811a2d699e71a37123cd37128c047ac86865b442fa
d6466b5a60b431daa084b6465ba4bf09f8f210e3cb838c2f0f
035f3ad142a3b3d119257731bad023c66dc66d28b3abd19516
19b71bb7d3a3463760d00260500fd8c940a23940a254d83d81
470f331e2d8632e52b3c72c148204c246c3f8c060c89062a5d
03e362b4725343981a140713c1c8e5a17630918c535ec6a928
c6291fe39441c9307e4a8589a634986b18b96a522f985afcb5
e5da9405732df583a943d9307519d76268004c2c0d84a94783
60ea03e9065303a0dd10b4c2c2bb38fa3f308de8059878fa03
4c63fa134c13da04731d6d86918c804d1901afa717616ea097
609a31723567e46a215a8bd6982ddb8836982ddb8ab6982d6f
123761b66c27da61b66c2fda23d6c2a636e28c388339d3c2a3
9b188fda3112b567244a64f4b999d1a70323ce2d8c381d65b4
8c06e25c23af012ed49435810bb5642de0426d591bb860e1d1
6d8c475d658c8c0122c4ca5820423d590f8860215477d95036
040ac4c938a080855329325ec603059ac8264081ebe47528c7
42ae3479bdbc1e587083bc0128d04c36432dcd657360410bd9
0228d052b684fb467923625bc95640840eb2036c0bbf3219ad
fa304ef5659cba93b1298bb1a91fa3523623517f46a2018c44
0319890631120d0606dd0944b0d0e72e469ca18c357733d60c
63acb987b1663863cd08c69a918c35a3186b4633d68c9123e5
48ca91a3e428ba977127578e9163682ca3cf3879afbc97ee63
0c1a2fc7cab1348191682223d12446a2c98c44f733124d6124
9aca483442de2fefa769728a9c02f7543995a6cb69721acd90
d3e5749ac938f500e3d42cc6a9d972969c453f63849ae383a1
077df37df3612ff62d86bdc4b704b685507319a1e63142cd67
847ac8f7acef59c45a3835c7f71bdf6fe0fe83ef8fb02dcc7a
88316b8e6fabef6f0879c5b713f6bbbef7605bc83597916b3e
23d7438c5c7318b91630662d60cc7a98d16a01a3d5c38c530b
19a71e619c5ac438f528e3d402c6a98719a71e659c5acc38b5
d8686834a4c718a196188d8d26b41438d5949619d703ad961a
37183720d642abc78d16460b845898f50430ab15dc164e2d63
9c5aca38f524e3d453463ba31d422cb45a6adc6cdc8c341d8c
5be0b6906b89712b906b2923d71246aec718b91e67e47a9a91
eb1946aea5469291443f37ba03bf96327e3d66a400bf9602bf
7aa29634a0d85223dd48a7e58c654b8de1c6707a96b1ac262e
ebd77304aedb81012e63b9f12c91b1d2f8254963bf718074e3
907198dcc651e33d609920e1ea1cc83943e5ec869cd1dacd5a
0722ed316d0949ed2bed14e9ae34573a45b8dbb96fa6487727
776732dc5dddb75334d75193eba86de419bfa63ac64ee3758a
e1faea717d0db8be38ffcbfebf53bcff15ffabc02a67ddf554
dd49b0a53122da0a97f27bdf002cc11f000e0f0596a5555f57
f082f46035d8165bc4765801bab0021c4c6e5eb7246096ef45
ad7067a27167ba57784b2bcb2549e71d2961cefc9e34f103e6
c048df8fc09bc624f5087241c02bba8dd557f5557d55dc25a9
37f86d98e946522e66bda7e869a0c37afa23d6edd6394533da
4907a9397d08730b7d0cd3918ec3dc4a9fc374e2338bcef46f
982ef41dcc6d74867ea0aef4234c37fa2f4c129f6874e7138d
1ec22ddc942c22848752845778a9279f71a4f11947bab8465c
43bd442d518bee10d78a6b2943d41575a9379f7d64f2d9471f
d15034a4be7c0272279f806489ebc475d44f5c2faea76cd14c
34a3fea285684103c412b18406f269c820b152aca4c1629558
4543449ec8a3bbc46ab19a868a35620ddd2d9e13cfd130b156
aca57bc43ab18e868be7c5f33442bc205ea09162bd584fa3c4
06b181468b8d62238d119bc426ca119bc566ba576c115b2897
4f5bc68abf89bfd138f1a27891ee132f8b9769bcf887f8074d
e0539889e235f11a4de2b398c9e24df126dd2f76895d3445e4
8b7c9a2ade166fd3343ea399ce673433f88c66a638228ed003
e2a8384ab3f8bc66369fd7fc8ccf6be6f079cd83be545f2a56
aab37d67695e600513a35630ddad958d3b03775a18f71ad311
129aa28795c2fb9b8ba448e614cf5d24450aa7587b9114a956
0ae3f39014b579ad655f443dc3b6d599262d6c6b9d69d2c3b6
d799a657d8163bd3dc11a6cd1269e238a5ddafe0d6daad2f9a
a6b7330d5a5f344d66489ae7c2a4e91392666d98347d9d69d0
7aab5f757035404c03182bd59d61473a3455169730e312a9fa
71aa99974895cda9665d22557f2b95bf56c888d7a17895b60e
a71a1076cc43530d0c19891961530d0a4935336caac121a966
854d35c4990afdb0ce74ea04d2d977e8ae30ad2f9a6a6898d6
174d757798d6174d352c4ceb8ba6ba274ceb2dfd15902f8d4f
9be238ddf0b0525134dd88b0725134ddc8b0925134dda8b0b2
11c37bb71876c570bad161ef7bd17463c2def9a2e972c2defb
a2e9ee0d7bf7630229854a971bf6ce164d3736ecbd2d9a6e5c
d8bb5b34dd7d61daa773ba8294b61c8c0fd3be70e92684695f
b87413c3b42f5cba4961da67b9ac59a439a7988c149a7c5c3e
8b5de02fe42fc8e3fddefb3d9f9446c85fca5f1279067b0693
f00cf340e23da33ca348f38cf34c24dd73bfe77ea4fe8ff73f
14e9fdd6fb2d7955d95d90378b718ee87e15d61c615d698a23
cc7a46d412926587955d2bd04fb99ced67544d164e0ee17aa6
a890ee283993e7bdc2b0d6e0d6096fa2233406e3da944d9c0a
b74a5ec1f69ac2f6e9cfeacf0277a6bba7938c488d4845fb06
7b6690ce2d6bc22dbbceff95ff6b6a6a978b5db7941d64172e
73aa0a036acb26b2a3232c02e362c896b26970a838859df919
99e6083b86fde8714932d111fa06ca70e6dd827447c476b1c3
11ba063bdb1d30ebb0320b0e5f8c3ded0b6c9e10cb1d311351
ce53621a5684c1a18350ce6c310cd734477837848f84491543
1de1cd517e2f98d6b8921d310662dab2a92d5a06c7d069728b
3a96a1b3b0a31d7147c0cfd231d1da11ba0377f138bd41c745
8c23fc0584ef86d928c811fe0cb9f88c7d25ae2f1c31d649d5
2a3673698f236618b9693e9bd1b8363be22c791b4dab1d6196
bcf585718c1fcb5b273605e3e79437092df90511eb872deb9f
944a0aad9cfbd9ceb76bd6a0b75a776d01d73a4d8535274ddb
a0b5d6263a426b92aead8489d1060587cbb3484dda666d9b23
f438528f935f6aabb5b58ef0dde4d2b2b42cb95f5ba42d73c4
6c422fb73a5b2257a3eca672adb3257231ca3634433e11d292
c9d09a195a4b2dd5113a8474f9a11caed5d6da3ac2bb934bbe
019326cf69318e18f45fb6961f6bba2314fd972b658cdc2d4f
06878bb328673e0cc9cdf29023e643e8ca673247dee0087d0b
e5f4157b655f19ed08df84723aca8e622bae338e9895d0a2d5
324e6649477fc57ce4708b45d22d3bc96e8e981ce8ca0998f1
e2848c0fa9bf175a65d55fcf119a883ab6894e629b74f45a34
803e6257279ae03ae188918889108b8129c7e10e8a81eeb881
1327c544e4794b695241dc6eaa21b24416ed87bd083bc1dd8e
d80dd083cd2251e48a858ef015a8ab01e5890668f97847cc1c
d465ed8b17c0ee20b21c71c3515a0e7d26ea892e8ef03468f3
1ecc047b90a7a923a635b4d94280440b014464204e005d04ff
f28c1d626ba7a448d63af2dce5b91bf3d43d1ed4e819ed194d
6e4f8e27876a78c67ac6528467926712793c533c5329d23303
9a19c5dae8b3f2cbdfc81731fbed906f5143990ff9b9411e91
1f535b795c7e4e9dddd3dcd3e876f74cf74ceae6f5783d94e4
fdabf7efd4ddff6fff49ecbb4a8b00e111255fe14a2146fc8e
ed5fa9bd513d1e397b04a60746a0865c13e8411c7af03935e3
f676e7f6f6e0f626737bad3d92e619e21982f19aec998cf19a
ee996e8571995fe3b2a57e860a3986d9ae367de6087b0bb26b
05ec77840275459c23c4dab11e11518eb027c05f8571d6f200
cb6b7088b54acda3438eb02cf0c5303b1ca196546d7284b444
dee1b4c6115607dc7a32bc4c850aac658678269778ec4a77af
f32cdb7b98ed232cc91652580899c9ed99c96109b8daa18ed9
98c30a430bf694a3b132b6430b66a5821e5c9efc8697454bda
4ec258d8634bdb03d63a1c2b83a33042440485eab89b67f8ae
0a3a15142e693d7d08dfd1e01280352b196f763a4ab09ea42f
c02568a3a38471583b085ae928610976cc7be15fe828611a4c
37b2e6bf898e129ad3f3f00d7084d5c61ac25a191484954c0a
30621e6bd7e3c5884116e4afa09d3e96088325c2cf12110d89
9849d7b044b46589b889c7b69dff4bff97d49ea52331ac7468
7cafc705f5dbde63646235bd9857d40b82c25dd4013a3019c6
d2847141316ec84d137ee36100ef4cfa06e24a831b65d96bdc
03774777576810e611b7bdea9d6df5dcddc47dc88ddd917b00
ae158170e98e74639e460ee9dee99e1b947e83eb940b58e2c6
eceace0984ebee15ee15aea32e489fdbc0951994638eebefae
9d245ca751d61c7762509e91ee91ae752eb4c675147123ddf5
0a73b996b8bbba9e42cc4b8849759d0fca95e09aec6eea02a2
b8b0c6721d0fc4b8dc35dd355d03dc912eacba5d5869bade2a
cce5faced5c975d2051470613f09df86c27c68f751579c6bbf
0bd8e1ca42ec51d7338523e142c1084f84eb6bd777852dd4bf
70e5e9d05717b0c275c475ac3087be473f887069f5c2f592eb
d5a05e4dd637ebd018fd0be459eb7a21a87d035c03f4553a30
54df83b82556df03b93ae97375ac0cf44d96db35d1352d285f
9c2b4e1fa9e722760562e35c59ae41416d4cd6cfe8401c1d5a
887e24ba3a15e6d48febcdf5f775ec1df4a1a831c615573822
fa1b3051fadf75ec9df56ee8d139970ccaf98276527f4e3b8d
b826a8e305fd981e7417f465fa326dafbe50c35ca2eb885f86
7276168e8eb65103ea68c751ea1a7d4b50f84a0d7b066d37c2
17eb6b0bfba0cdd713b54588d98c98c9faa2a0981cbd9e0679
d6562166803e25a8ac0c0d6b226d3e6a8fd0bbe85941794e6a
ed34ec3a35cc777a13bd6361afb48330311a4641cbb09e6fea
7141b9b662b58c11c05a1a6eed841e341a5a9e96879536666c
ad3662f3b4bdda67852d81a65bbbd2ef103357dba4ed092a73
b47c5e420ae5fbdcf7cd4125f6d27ac927ac7dbddc81b8b9da
aaa05cade51489d95baeb3dcda486d6e50be9a5a4d394042fa
e5ff32f735507125d799f51ea8f91530589631264496318319
06f3f3deeb47ffbeff6e210d340463acc132c62cc62cab280a
4751086130212cd1622d9189425842889668150e56585647ab
68393ab22c73747430966546ab6099b08a2213ac255a8c5916
6379efadf79a6e34cc64463339f6a9f355ddba5575ebefd6ad
9f6ee853909a1c6144d4864ac229fb090b16806d027a35222b
c2132a09bb571a7b87059bc506a0c6f888fd616993f48c0f6b
006edb2cfb34c21696360cb7f07e6609d25240ea303bcb2e85
f5bd83eda0378508a02eb3d3a1b630636c0d9cfce95d816d60
07d989309987985e5663c016313741463b1bb24abbd83c368f
6966b3981648bd00a9756c4b58c964a6928dc53b37dcd323d8
64d660ab43ad6144067a8ce768b638ac25fb997b702f67984a
dabf50ee58bc6b4309969962d3c2f25f841d17ec1f03f6cfba
33d0bae9e74473b8fbc28ecd587706b3442bb94e50ffc1fe31
adccddb032b54c2d394fc6e88ecd42ec4aa814390575a30d00
fbc718cc6058a91c720cceef78a28255c27484468749669249
259cdfb1d760ff98865029b206b7ec657a0ac2f7b435e650a8
1c3d61a4c3e932839ef95832c7e459a92f76defde5de0ff09b
36fdb0577eb0f784f01b82f58a607dd30747eaf768ad7f0692
185af68fdf92a3752b074a3f83af7f547ae45b72fefeb69ca7
d95eeb9dd0fc7ea78b9ea34c10d24679b8ca732d04791524fc
93a8b6ad997cb137c61bd4ff163dcb996f9b27adb3cd1bb45d
4d7042ea86785d18174f7d782728d9e2bd68ed5fc31189a98d
697e9b9753ccf367effd74456789859ee00a9cb05ad94e7975
b02e1932b48d1780d321aeab709e8bbe689dd8c6cba2735dbb
8db7871c0d1b89f6171e89335b2381b1af93d0fbef9f50ff4f
d1873131dbdb19d6deaf5aed6d0b6bef57adf61e0b6bafc9ab
a537c4922dde8bb6f7f4b6f6fe47eaf7bee32c86564332adbb
0372c7bc833df90ad893df845b591cb524bba92549a4ab3989
ae03b485e70017a8b43fa03c7c4b3e0d72fda42f8c5b40b53a
827e17ba2d8c8f2b08df5452a9abb7523eb8dbc81f53ff1be0
c7d29b089e3bf0bb8456fc1783569ca53d62490170e45f8824
f88d42ccb76ba3e6e773db3eff8827511bf749dd0edcee9db8
eb533b71ffefb3b770a309f3ec7fffab70a0173ffbedb7b6e1
673fdea9653ffb4f3b71ffdfdfedc87de95df402f2ad1ddd71
0c2277e2aeb6ecc4fdc9c4bbab69bd6fc77666efc45d1bde89
fbd3b7ce2d8cdf66d70ef37d75c7f10bfc8a6ac12f978323f3
9d9dc660537f3ffa06a7eb0258bbf85715718494c512360c18
679e036b8581c0c3c0626039b01ad8282365b6b2f8b2e4b294
b2f4b20c8b935d96572640e82a532c8e1f78a4ac043802c42b
ca0e0716cb6a20961e582ecb28ab476965f520a1a6aca9ec78
d949c8d956d60932b3cb4e95f5421ae42c3b5b3648e9bcb273
6517ca2e965d024957cbae53370535a443d85b365d7617fc92
b2fb545e986fd54b7dab5ed337e59b65dfe2bf9b9e5229f356
1f1fbd5d1f69efb05ff356bfc27bf4ce7d316ba1355a326929
b36d561f9702abb4a777cb9e96ad4178a96c13c715e5d0b1ed
85d663cede72b63cba3ca13ca1ec3a94786b8f688d6ffb59f0
7b3acb6cd7af9251c28601e3cc7360ad30507aa9f46a495fe9
c9525b695e4947e9f5d2a6d28ba53525d74c4ee9f192ee9261
481928b96371a64a8f437c1138c380d5928dd2aba5152503b4
fc40e93495365d5a535a511a5f9a5c9a02396f97de0599c74b
7b4bef97f441996ba542a98bd2dda54aa9bfb4a474104acf97
5ea0ee51e912947e0ae9574aebc15f041eca0bf3cd7aaddacd
7a4d9fcab7cabed57f173d85f2d74ab3cd3e96aebd6d1fa177
b45fd966bfb6f5e89dfb628ea759a329d32c65b6cdece326a4
634feb036c201ac2c140028e2b9583637b1f5a8f39ef07f604
5203fb02fb20e5e40e3da2357e30fa452ed177de78f34c76a8
98045e5b7e6df557d991177b71ddd6cf83b5247070f2e0999d
dc6bc93bf3a99b0ccf67e67c2d856247696f27ebb574ea92c3
6506f3be968169072fbf603f73e869d7ea67710b892f9ed9c9
1d726dc98f61cfb1e740fe5fb1703362ff9afd6bd0abbf61c7
4924fb5df6bbc4c6de65bf0f6d78937d1372ceb1732416eafa
31de02986ae638948f87b3339ced8b13281840e0e0ccc1d983
73ef010b071fbfa7fc413c7907796f27f3bdb4ed45dbf57cd9
e7ebfc17e4becd278bef5517ae90eb5417f64249e23f4a11f0
77f8eff9c7fc27fc1d076c076c10eba0fe09ff79ff31ff04a4
8cf94f536e05fad40d1f488154741833c361cb854b53c2644d
9872b6a4808ce2cae2eae2dae26a2aa1d5df0a5229fccb88e2
0648ad2e3e4a5eecf34486e41131d45b5f3b45bc3fdb77c574
fe6ca44d1ce80aabe585f57fbb4df181defb327d8103e9be1c
08a3fdb7c187d017f035504ea6ff26e5a5422c077801a01a7c
fb80d3405d001ca6a402cf74901e94e6ab0d9745e560de2d19
07320e6483cba3d2728053ec9b04ba984ad9774038e03aa01c
c09725f393a7f761538c4c126f1418edc60d40bba1515a43f8
6bb6e4bff898d6e1db27d4554c1209d1afbe30e2f56bfa8005
7403461ed2c6fd0fe015f3c57bb76d456a0f2802469a91ab7b
f415f013f43d46ae51a53fd647b5fbda923ea3cff85220b6a2
5f861c97f5765fba9e609c30f61b91be0c74fa28e45c829c97
8167ba70695d46952f7b4b16ca0129211910e66af7a16c1ac8
caf365180efd89b11feaccf009469d29c58824a157cbf7617f
d4658a809ea62d18253aa72da84beaa6b6a0ef057fd2c8d36e
e9693a67646bfbf4bdbaa40500d190b3c238ac57814b42a74d
82bb053925ca4317264d3b1a268b433954ca960cc8b1005a20
413d4986a0771b352093ca36ea8d26538a5ef501f596500474
bfd6a8edd50cad519d53368186509d5157d4154849d25d7aa7
5607b15a2d572d5617f4537a9bd6adf7ea6de8201fcda9ae68
dda60b97a67121595a12c4eaa8942d1990a3115272753f9576
56ebd09b801ed4cfe917f4e3a614bdf7857bbbc0eca1bdf500
8892fc9e1050ebd574254d255a8e7248d9afe5a8f5f213a55c
69d4fa9507101b54fa5497d2a8c4ca8fb521d5a5bab42e355b
79a056a0837ce5f2babcae34aad9960b97d6179425af431ce5
8094900ce510e46d044ebd5aa18d002a41663684059aa6b598
52d4f8177a157d5ffb957487225e4e901eede09648e89dfc45
de6bb7d755470175c99e3077d90a133ec8babceb14f172f1b6
ba6aadb0f87dd6b5ce983b53257e97cddbf381202079a44cef
6129531af2ae41380421c4bcd3c0f78478166788baa300cf36
07e9f23245b8b4e9305943540ed25b32947825594901970ee9
97c19d3121f721940c48cd56b2dfc7bbf9fbba3579724840de
f3abedac77f7f7d8cf7857fc04de649816f23aac0d11e0218c
a441580c08005d096135a0d60a110d61349caea566400b00ce
9e129c3025d027e90ca0dfc290158e5818058c5b401aee7cd2
64587c94306ecd0ca51b10de02cc006601738005e03f86f009
60c52a83e13a05233db3d2d6697fb04dcf03db48db29470262
014980bd8491d300fb09c1fa018c1552da1b6fd27216e4c985
90db39df73f16019223b0012a6b1e3defbde79ef23ef92f729
ac0ec4a6c422a4682941da034895f651644a39140592086b43
9434a9982260a152aa966aa5065845cd528bd42e7541d803e1
19a99f62481a9146a571584fd5d224e4bb21dda218827ca352
bbf7a93443b129cd22a43969417a2c3d9156a4758a67901720
474aeb14b1400342ed94932842f1bd08394d4aa0d80f34224b
cea5e02c38a41c0ac982211fa228978ae572b96a2b7e04e247
205e0734a2513e46118c9f001ad12a77bc23bae5d3729f3c20
0f83bcf38031884f40fc0ad0d70037e5db1477a07ff7e407f2
4379916219e2ab10df500842b149c51468b1a8d5921f50a483
9542642b791482e2a250a45b147ea544a9909e2887951aa55e
69528e4bfd88adf9ab544e4ab54a5b701e604ed621bca57402
4e81fc5e7951392b352b8352bb720ec20b30c743ca456954b9
149c4be52ac8445cb73025552bd3528372575aa7b80fb210f3
40231e010df03e5596283695a708694559a378a66c2282f955
56ba85783eee7daa46536caa090815f48002f480621fd0884c
a001215d51732842f102842a425e71c7fc1e84aac199112067
a9010b9508e05553d4cab908e03520d4a3104734ab2d14ed6a
17458f944371c684ec50fb2d0c5918b140e3ea28e4438c9b08
eaa87a599d44847458bd41114cbfa5de408474589da1b0e2ea
ac7c0c11d455754e3ead2ec803ea63a9587d12a69b00a5535d
514ea92bc1b8ba0ee7e0f5b038ac55f519e8eb567e2d5239a5
c506e35a92744b4b921f687be5458a340bfbb52c8a5c385103
82f626a8ef9a43211412d0080368c421a001f286568e506c5a
15423b22895a1dc8b0ec94d608f163801340238e68ad5a9dd6
2a05b40e4037c44f43fc34d07d80016d18f29e87facf42fd67
43eb4d1b83b603b6e213109fd829ae5da14881fe2304ed1a85
22cd22b49b8a8be2b60948bb43a180be03b47bc00784ec98b4
0fa13dd01e6a8bd2136d595bd536b4559d68abc1b51c846eb3
106f21d9428a85740b1926d006e8d97a9e2e40e8921a74681f
851fd211257a8554ab1f86b08686f570a339ae9f84db4d93de
a99f0cd3b34944c836eaa7107a2fd8ba34b475fa59f99a3ea8
a4d3bbd045fd927e55bf2e89fa14605ace4504d7827e57a9d1
ef2b4dc1d0fb549fa7d8d41f21602f98a188956611a17d4c5f
42482bde358a674003f4a7fa1a4251f4470890b549b169b008
235a5a4740bf6f218c042981628fbc17f1fcbea86a462a42ce
32f65104f793adb180b5734bae3232e5d3468e3c601448c586
08f06c5f5bc1b56668dbd79ad26914c3bae90e5b47b1108f34
02926854826e5aeb20387e4635c806480546ade4316a159bd1
00386a342b19142d4a1e424937da29b28d2e0ac1e8a1b0c6c5
38a3b828fa610c104340234680063cbfef18608f8ca05d1a0d
f5df1887f68ccb55a171332e5384e29388adfc37203fe216c8
43ccc0d8236661fc117352b3b1603c369e40b8623cd64ba46a
635d6a309e49b3088cfb22a5061fe802422ff12549b5bebdde
4d5f1ac2b75feaa7c8b290ab37f938fda4cf01a1a49f0cb5cb
672082edf2816d416cc5e17c4051a510df11401dd075780ef2
35427dc7a0ae1388e03c6da517f85a258faf43d27cdd92a655
f94e437bfba0bd03d05ec430c4cfc33e0c7d41f8c6203e2135
84f47bfb39294c3f93106f396f6cd963b0cf00f9a1ef0ac532
d0ab60c39f9b47df352583e2a6928750a67cb79569a50dce6a
b388603c68bf6487ef0e2268737cf77c0f10b0866610c172be
87be45845ce75ba668f4ad229e3f4ffa36fc04e1b7493988d0
79c91f2f9ff727cb1bfe1484a4f9d311706bf810fb7f583861
e377744974842fe22089d955b88b2309bbc45d4e9264d36d07
c91e5b89ed37c8c76c95b6cf928fdb3e677b9d7c22ee42dc38
c98cdb88fb05f9f4eecadd9f277cc23713be4ddc09f309f344
49fc4ee25da226fe5de28fc881242689215549a949a9e47349
5f4efa32fd6f027bd87f669f42adbf1eb19fb0112f47e4115b
446184409222be1ab14af6eccada9543ba77b96c4ef2359bc7
a6325fb355dbbecc7cddf615db5798bfb0fd5b5b13336c3b6e
fb6de65cdc7f8dbbc28cc433f14799b184b684ffcea6264c25
fc90ad48fccf89d36c535254522c7b36293ee9a3ec40d21792
ead90bf8f77b6c34bd2d9d215f24a4106e0d85498429dc0b61
1a603fd070ca2f849b412167850847182d010cc0214039a00a
ca1c81b00ed068e198159eb0d00ae8b080743794391d166f25
4cde5e332cec837000300c380f18034c00ff0a84d70037ad32
18dea6600aef5869b7697fb04dcf03db68b6f31ee001e02160
1178cb805542b07e00638594ce9fdfa28369261e98bcc20dc2
e0bfc2e36c3b977f2e1e2c4338b88571c966ba63def1086624
f95f49137f4454aa8347a80e7e81ea207deb879b3413911531
14ba3be76d1292cf42afa3214c00c08d3c3f15c27d804c2b44
e484d10500b873e7c31d351fee88f9c550260021dcb9f3ab2d
d45a618305b86fe7375b40ba05cab487c58f122637da0cf3e1
ae9b0f77dc7cb88be7c3fd3b1feee1f923c087fb723edcb5f3
2f5b65309ca460f26f586993b43fd8a6e7816d34db09f7f27c
b897e7c3bd3c7f0e78702fcf877b39d60f60ac90d29fbe63d2
f94f200fdcd5f3d777cef75c3c5886e4c39dbe2092a67d9c68
a49c54937a728cb4904e729af49373648c5c26d7c96d324be6
c92259219b8c0da62e95c9613c8c9f29676a9846a6996963ba
9933cc208910c7c5cbe2a47843bc25ce10569c7ab5409c16ef
023529ce007716a88957d3c53be235a02e8857c529f13a5043
afc66219a0fac4f3e215f12650a772d6c48b34b55d3c238e88
fd409dc879284e88634035896d50be13a8da9c19b14b1c01aa
4a6c145bc561a00673ae8ac745b06b50b2526c10ab813a9d73
5e3c221a285954c40ad10f5457ce19b1582c00aa43cc152591
032a19240b547234d49c2376914848ed164f8b7df6c7e2807d
c5be0e1c888903e230b4760c5a7485b0f6b91cc3feccfe18a8
3bf687f655fb2289b09fb35f10fbed97ec57edd00ffb959c0c
b1d70e7db35fb45f17bbec53408de42489adf671a006ec63e2
71fb0450bdaf6c42194cedb2f7db47ed43501f116de261685b
8998623f663ff14bdb276223de8878036afd69c426616c276d
bf47626c6db63f24bbe3a6e3be433e1cbf12ff13f291842f26
7c917c34e14ac2ff20a9898b89ff44d293229222c83eb0f5d3
f83729b0ba1de42021afa6033200790001a000fc56882809a3
2b00870135807a4013e024a0cd42a7159eb2d00b386b01e9c1
303a888b804b80ab80eb8029c05dc07d2b1dc3790b77ad30c3
aafb792c0160077d750d00562b3bfb9d910bd62c37f55de401
8b969b49fcc211a10ed0281c134e08ad4287d02d9c16fa203e
00fe30e0bc30066e42b802ee9a7053b82ddc11ee01f781f010
38f7682aba2bc2a2b00cfeaab091d36527769b3dde9e6c4fb1
a7db33ecd9f63cbb6077d915bbdf5e62afb01fb6d7d8ebed4d
f6e3e04edadb2cd7693f65c7ef66a7810682cd6157d99fe237
8c411be95f16c1c901b5318a6a633c686311e8a4734b275f02
9d2c2329b6df00cd4ca39af96bb6c3b6c3e4d74133c7c8beb8
8ba09f9f04fddc245971cf404b5f012d7d9dbc0a5a7a931482
7ece107be29dc4ef91a2c4ef27be499ca0ab73c493f820719e
48890b89ff0bb4f71168af4eb5f700d55efc4bf08ffd92db8a
ad74d256ba692b25da4a85b6d2a0adf4d1ef9a3fa3efe3f5f8
bf92b26147ce8615920d9a9f0ddafd32c641b3b3416bb3a72c
3ee21160c94ccf9a35430ad0d8ecb5b0b8890ff1870ab30b37
f972be0adc11be8e6fe48ff127f856be03e2ddfc69be8f1fe0
87e9feff13f62730666bec1a6176397639086b2bb7959308b0
249f2391b6d7c19eec8afb46dc37882deee7713f2751bbabc1
9e44277c1bec492cb5277189df4dfc2e894fbc0b566577e2bd
c4fb2421f107893f202f25fe7de2df93e4c48789ff403e446d
cb87a1be973ee0fab0a6045a5322ad2989d604679ce4d50f55
e1b720996b04562e077b38077b383742c172b08f73b05773b0
7f73b05f73b07773b02773b0277330bedc1c6001f0d8c2138b
8ff956b6c070eb84fde48809ee1961f94842f858089342fcb7
03bf1790f62ef2c1699dcf02e4d2b8d92e00cf596d83b6f030
8e2f83e5e4a56d65cd7c706ae60f41f97293c757bd008e50d9
5bd8925b07721b01c7b6fa8ce3ba553f0fa770be95c28c77bc
2dccf42318b2f385f70a1f143e2c5c2c5c2e5c2ddce0e0a4cb
c573c95c0a97ce6570d95c1e27702ee02b9c0d7c3f57c25570
87b91aae9e6be28e7327b936ae933bc5f57267b941ee1c7781
bbc85de2ae42ce649093c75da76593b9a9c2456e1a72dee5ee
73f3403f2a5ce596b8a790678ddbe4593e9a4fe0f7146ef0a9
5c09e47fca95f0fbf8cccc513e872fe045dec36b7c311fe02b
f96abe966fe08ff2cd7c0bdfce7741bd357c0f7f86efe787f8
117e941fe72ff393fc0dfe163fc3cff273fc82c579cc3f815a
56f875e0f4805f0dfe3328d52344f2fd42ac9024ec15d284fd
4296902b7082836f067e3ba44afca8600887b8ab42b95045f7
8c6d3b46e143d3c771833d6300470c768ff3901ff60ece867b
07f8b07bf0e2361ff6922dff26fad83bbab72cf2eddbfc65ea
c3eec24f0aab7682beb081bb0c7270a7e11760af49e1abb7f9
b0f7503f8faf161eda059416e62fa31fbe2f156e606bcddd89
efa112cc1d0af6a6c287f65eda53da23fb59fba0fd1cffd87e
014e5d701283d118833e96d83b699e01fb752edba4ed53f669
180d9373d77e9fabb1fc798b7e04fe921d74609bbf66dfdcee
8b7072e4274d1d3367534c10f770f362aab84fc81233c51cce
251688a2d061eaadd5af25285b227ab085a206a7d280dd0567
d76ab116ceaf4785876233df2fb688eda0c9a0936217cebed8
635f12cf408dfda869e210a547c451d03daa75e238f64bbc8c
3388ab469c44fdc49336b43c85af1567f8a3a1b523cea2968a
73e608880b388fe263ec85f8445cc11e89ebd823f159a87745
91d0bb5ad49fa2589cd9a2244aefa5b3bc44c79fce6f515ad1
7eae53bc5c9425ec2dca45ba88a3b40347a648c291c1555664
a03e171d12338bca0b578baa8a8e088ea23a1cd5a246aa036b
543fa956141d13733247c57e1cc9a21338aa45ad94ee28ea2e
3a5dd4573450345c74be68ac68a2e80a8e43d1351c87a29b74
940a6094aa8b6e235d7487d2f7e8ecdf297a00fa3640e99b38
02f629ba46eed0d118121bb0769c0b618cd2cb48a3b511fa8a
1e162df2fdf6a5a265aea468b568831f751087cd11ef48162b
1d29a616f1e3b80a1ce954a3cc1541f58a1fc7958296ca9181
3ae3c876e43904eeb8c3e550f819b45a0e3fda074789a3c271
d89182e3efa83173a20573d4a3ad709498d68cd24d8ee3c284
e3a4a38dae0e3a178e4ea4d1b239fc68431ca71cbd38fe8eb3
38fe8e41c739c705c745c725c755ba466ce6ba735c0fa3a742
e38ff650e843cbe39876dc75dce7f7e0bb017735a4c98e25c7
53c79a63d3c962aa331a539d0994de43e9544aef0b2fe5cc14
8e156e3873381bdfe32ce0abb925a70874b3d3c3b7a30e3b35
d46167b1b9d24deb646aaf33c0b7382b9dd5f6ebce5ad31659
2b7a19e7d41c676743709c9d4771f49ccdce162ed9d98e36d6
d965ad68aab1d83be0d3de415d9bc15ea3b577f6987635bccd
9655a116c66c1bac20689b6943cc79779e09c977f6a34ce710
ca748e38479de3cecbce49e70dbbcb79cbee77ce38679d73ce
05e763e713e78a731d380bce67ce2766aa2bd2156b6f7225b9
f6bad25cfb5d59ae5c0771715c8acbe1925c8673c175084bb9
ca216795eb88abced58833eb3ae63ae16a15355787abdb75da
d5e71a700dbbcebbc65c13ae2bae6bfcb8eb263fe9baedbae3
bae71c713d70c4bb1eba161d29ae65d7aa6bc34ddc3677bc3b
d99de24e87bacebb33dcd9ee3cb1da6cb95b70bbdc8adbef2e
7157b80fbb6bdcf5ae87ee26b05d60c7dcc7dd27b9fbee3673
b77277ba4fb97bdd67dd83ee73ee0b8e4bee8bae46d721c705
f725f755c755a4ddd7dd53ee69189911f75d907cdf3def7ee4
5e723f75af993bacb997b9373dac27daf49d2b9e04bbdfb3c7
93eabc81adf2ecf3647a723c051ed1e3f1689e624fc053e9a9
f6d47a1a3c473dcd9e164fbba7cbd3e339e3e9f70c7946803f
ea19f75cf64c9a7bb4e786e79667c633eb99b33799a70873bf
f62c880d9ec7ce21baf6073c4fb84ecf8a0776673c2d387b4c
fd819532e1ec815d2cc5d9e579c6677a23c502a1d51beb4dc2
55ecddeb4df3eef76679733d9a97f33abc12ca447d40995e83
4f70ce790f79cbbd55ceea904535f726ef11aa4be69e65eec8
d44679eb50cf41e7a7b7743ecc9e84ebbcb7316401c22db3f7
185a63ef096a8da995f6b6226d59da9bd4d22685567db895f6
7678bbbda7bd7dde01ef70b8ddf39ef78e7927bc57bcd7bc37
5d0fbdb7ed7e9c3bef1d9c3bef3da11b5747d11de1b6f701ae
5cef436bdf19c3d5017626052c70d86af22e7a979d37bcabde
0d897857259b4450bbec7e8b4f7dbb4b8a17aba5642905560a
5d4752ba94e16a95b2a53c49b07c97a4487ea944aa900e4b35
52bdab1bf3e3990ae7576a928e4b27a536a9533ae5d923f53a
6f382aa4b362b5eb219ed3d007f983d239d7867441bac8d548
97a4abae0dd7b2743ddc775f94a6a469e9ae745f9a971e517f
09cf72e0539b6cfad253694dda7467cbacdd2f47cb09f21e39
55de2767ca397281375216a57ad9236bf43b6ea21c902be56a
b9566ed8f28fcacd728bdc2e77c93df219b91ffc21b91fd797
3c228fcae3f265cb9f946fc8b72c7a469e756d98b3e6a890e7
ec7ea94d5e901fcb4fe415795d7ea6443a52945825c911afec
55d280deaf64c1e911e72b167d2537447b63154e712812f806
f50fe12c28e54a95798a568e28754aa339ceca31e584d2aa74
28ddca69a54f19508661543bc56ae5bc32a64cb897942b4007
e5a07f4db9a9dc56ee28f79407403f541695656555d950896a
53e3d56435454d5733d46c354f155497aaa87eb544ad500fab
356abddaa41e574fe21e51348c7b84daa676aaa70a5761dfd4
f8a36a6fe1b27a164fe6ce4abc3ba88348abe7d40b7816522f
e27909f6d964f5927a956f50afe3b9489dc273943aadde05fa
3ed28e26751ee84750b6415d42ed559faa6b7c8bba19aec945
2734967369d15a0257e3b8aeed81b596619e19708d68a9b846
f06e0276036e01da3e8b9fa9e5987cd855915f80b426d29b42
7ff8d940f3a0fdd134b43f7836502f69c5703698465a0b20ad
55e20941ab36f738ad566bd0aab5a35ab3b399f25b90afb553
ba8bd23dda19ad9fbba00d69233cab8d527a1c69bc256997b5
49fe897643bb8576c93cc3e349439b417dd666293d87b43a4d
e90553cfc54ced31e7b2a76b4ff87e1813a43390563bd1ce68
2b6867f034a25ec2d388b68eb416a0f4333d528fc593899e24
64e18957a7f71d3d4ddfaf6771f37aaece0959450e4a3b90c6
fcfa5eccafa7a99d785fd325dd101c68aff443a8f97a39d2ea
20a5abc2ed18ddeb7bccbd3e74aa11e79086f1075a3fa2d7e9
8d3c6bcfd08ff1a37807d44fe06d4bdba7b786ce30782bd43b
f0fea5cd08637a3757a29fd6fb601d99f4803eac9f072bb789
960dcf0cfa58e8048b16529fc0f5a55f41fa153fa5afe1eceb
37f5dbfa1dc1e1dca3df83f14fa7b718ba0be80ff4878e4d7d
515fd657f50da9c920e8f33376976103dbb56cc4bb2fbab38d
64b1da4831d28d0c23dbc83304c3652886df28c16fb21b35f8
6df5c27bc671e3a4d166741aa78c5ee3acb3cb3ce1172e1a83
c6391c79e302b6c7b8685c32ae1ad7ad1bae79b7356fb5db6f
accf82b75463ca98de7e57b576707a7e30ee1af78d79e391b1
e4aa339e1a6bc6a6695745d6c7c22d98ca91da7cd1f2635f82
6f8f2f95aed925732562bdbe7dd66d1acfc64da626634b7c99
96bddd6a892f27dc42d29b723fde917d05a64d438be113cdfb
b56997702deb4770eff0794cdfe498b5f834be52a9f215fb02
be4a534370d7004eb5afd6d760be4e982f06bea3850f7ccde6
eb84afc5d70e3a46df22cc5bbfafcbd7e33be3ebf70d89d5e6
9b83396ee6ab8279cef48df8467de3e1374aeb05c37caf8052
becbbe49df0df186ef966fc637eb9bf32d288dbec7be27be15
d407df3a6149526473643321912d912d84893c13f975c2d2ff
451119ad4457915dd187a38f90b4e82f467f897c3cba3efa18
c9883e11dd4a3e1dfd46f47f2042746ff42051a3ff397a8504
e23e1597472ae2fe29eec7a43afe5bf153e40bbb9376a7902f
411d85d66f7c68e4f32495d492af128efc11b80afa7b1f9f21
c3e42fc967c979709f2363649c1c267f4bae922f9029f226f9
225920ff487e8bfc883c21bf43d6c82fc8ef332c934dfe3d73
8ae921e3cc59e64df2df981f328fc84f221b23ff1df959e448
e47f21bf889c8cfc261311391df97d26267231f2c7cc4b916b
bb22980fefcad8f549e613b653b649e693b6ebb66f3255b66f
d9bec51cb6ddb27d8f79ddf63fa36cccbf898a89fa08f32751
bf1695ce8c447d3cea0de67ccc1b315decae983f8a39c3ee8e
f9d39801f623317f1e33c67e2ce66f626eb3afc47c3f668ef5
c5fc30668d2d8df959ec1ef62bf8ed5ff60fe212e212d9ceb8
e4b88fb05d71f3713f627be27f33fecfd9b3f1abbb19f6dbbb
5377a7b2dfdf9db67b3f3bbbfb53bb3fc5fe6077ceee1cf641
62426202fb4382ff81a791befaa6137c21dc6f218b907d7748
2a9fc6efcfbafca9d69793f92c3e97e778072ff1067f08df6f
3fddf7dcfb2dbedee6f2f84b0311748649b41aad1236ba38ba
98fe479064fa3ba784fe9229437f0390a5bf551a417f9f3492
fee29f8dfeca5f14fd2dd168f6b3ec6112437faf6f375bcb7e
8924d05fe14ba2bfb6f712fd0dbd64f677d816f221fafb9e1f
8151cf2029b6efd9be473e4af0ff4ecf87beefcd4d935ad06f
faa2c63da26b23ec2d8d4fe5e6d1eee13accca7ea737b47fe1
fd0cedd00a9409b966cbf5586e7ccbcd5a6e9d7f2644d27517
fb9cad92d09aa39d801bdc117e16d7237e521df557047f9521
5cdbbf428e82b61f03dd7590df05cd57a8b61f042d1f27af81
9eff2d29012d7f9394922570013a4665519f88fa24298f7a39
ea65f299a857a25e219551af46e592cf46e545e591cf450951
02391ce5887290d7a35c512e521de58bf293cf47bd1e554dbe
107524ea08fded8341fa3f88e2c97eb20bf42609b0d7421ad5
25179fcca7f0e97c069fcde7f102efe215decf97f015fc61be
06f8f57c137f9c3f09a96d7c277f0af2f5027d961fe4cff117
f88bfc25fe2a7f9d9fe2a7f9bbfc7d7e9e7fc42ff14ff9357e
536085682141d823a40afb844c2147281044e0e5f0838247d0
04fcdc8589fead68fccf16f84ba3e1a3f5bbe038f25d703cf9
077002acfd7f2476b2084e8c0a44054851d467a23e431c5175
5175c44998f8f5dd09f4af83b34914f4aa1dd04518be07c233
807ec2ecde244c427444e1968e20900eea0ad288a0ce04d350
778269c17c5816694c0fa6a17e0569e407752d3c44d9483fa1
3be1330a8b460ddb4a0b22d896603e04ca0fd2205348e2bb10
41bd0fc6290feb7cb708b627bc5def16c131c23658bc6ded08
a65beda7fcbd565b3144a4f197b721acfc3659ebf4a57b888e
d97e9803181f2c4ffb60d541f3615d3847e1711ccf11b30c6d
2b8e5f96196e8d6d504e706c61a587cf69b02e1a5a6d414b40
43b40649dbdbb015623d50ff5668b57dab2f3806f82aff7cb9
bdcfd51bf66abfd5ceace7fab2535badfe6c1b8fb0f1823366
48b7709cb06f5688f3111edfd2c9705db4fab125d3fc047a20
7cde69d8f336fddfa14ddbca59eb6b8b8f65862ddef3615859
fac9f7c4ff27efebe3aba8aeb5f7998f734ebe484cd290e021
c15c2ec299395f889844c594225244a488942a44a4c845a416
1091d28848a92022e5458a91628a9422458b9422a5be5c2f46
8c29975a8a88482945e045449a0222d2144fdef53c33279c1c
13a4edbdf79ffb9bdf5ab3ceda6bafbdf6da6bafbd67269971
9e7a278feb179d65ff7c49e5ade452fd7d0967d64ffc4ef5f3
ac7662a98d33c6afd56ff4bb9d73c22f9fd3bfd3fdeb802f38
5fd4aea47eb4196fee5cebbdc77d3e04da3db7e465770ef66e
ec7da645a6e91a8558c1b3a2e47c9df8eb04fa6cd685d848fc
b54272fc25ffe5424b7e70f3019e1561fe26e717b637e59ae9
ac3bf39a392d712ef6e1af1c00e0394f91ae59437a9df3173d
8857dc61c61dde6b0e5c7304778ff19b791ef5cf4a4e4cac41
6d8c652aff9af3d2969ba7cbb40b6d24cacbfc788e54d6e973
63d15e6c065acfed2fcc57a963e9faa8ac0b9e5995f54cd80d
df969595f549f655cb5a54d34e1e121e9f6a09b4ac95899c9c
281fe23eef729f79954d2d9b91bc9e96cd2a6bd1d56a6d828d
0bca16a7ae6f725d5dcb5d9d0b2d7af0840ce7a4bf55633bed
40d9eeb27d00e6b204ef60d9d19639ecaea5784a5676ae2c9e
9cd3ca8d72c642794e7941bbebb2c8e2ce2bfa8b3e96772f0f
277496f72aaf48f657796579fff241e543f164ac7c6cf984f2
49e5d3caabdb7ae255fe6aabb52331f792ce2d6b4a6a1e6ee7
9c1a5f2d7ba0d4b548f27e627dbfa4b528654d42ddf26d4ebc
b62997b49e422e792e332fc8bcc37827ced89b38bbfb2fe8df
45722dcfa5ee5e237176e74dcb7a97fa3bb1feb9f907bfcbb7
b73eb7ec6dce7dbe1fa9ebeda5dadb52eeae95a9eb6a7bfb8f
d4f14cccad9676117fe2eff29de57b52f7b68cd5fd78025ade
88670089279fadf68cd00b804f445745614571cb1c86bf92f7
c789f997d887b8f65474ad08629dc0d3d196790ffe75157df9
943aa97ec5808ac12dfb8854dda2174f525977f485f9959c9f
12b9a865ef0c9bc7554c4c94574ca9989ec8ef15332be6b4f8
cdb5194f5793f743093f562cad58de6a8c111f893511f5dca7
b0a07125ef7fd2ff03a532621957293de344c609e515ee95ff
b3775a4c5d35f38eca5dbca372b777abf775cf12de4ba9e1bd
9495bc97b28bf752dee7bd94c3698fa4e76bfcff686d2fef90
bcc73b247fe01d92f77987e423dc21d13be10e89de1d7748f4
1eb843a2477187448fe10e898effc8577c3722dfb2abf1fb16
9e45a44790ae23ae22de433c8c6f583c4a19bec3d67386d826
3e485c4999a5c44dc47c53b13691a5abc8d9efbe2f139c6a96
3a6fc91d02dc3c1538be92a5ceb7e5d6aa6ca1a750b21bf906
f9dd898b598bdfb6888fa44c3fca0c24bd05589f44ce3a72d6
90d3c5d5ec5895cd6f47a1b482a56c5dcf043616933e46dc87
781c257712f36b217a2fe2a1d43685da1a59ca6ff718652ce5
b72df439ae3744467f911c8d32fc8e85be1bd8bc839cf5c45e
f68e5ff368a69ee6d5b4bc2731dff7dc7cc8f5791347b041e1
7b1942377b899793b396df12ea8fb7dbcac836b0d70df47003
c7b181e308c9066a536a2ee9b91cc7b91cc7b97cbbfa5c46c5
5cb608bc8b3de2374ff44dae0fd1bb19ec0bc748e3db9d757e
a9d20813cf64697fd29d5c7fa216bfa7a26f277f34e9f3a407
517eac139fcda794fbc5547da41b154d1ceb06c65203c6a2f9
3423b98163d1406fa05fcd663e7a61fc4de1eb3fff82de990b
c0015f387741c6c0fbe35f37f68243fe27acd5d9c0bb887779
af0436f1e6f7f74d78f5758577e4171bf708be8edf34e84e9c
ef7cdfc0c57c3b386464bc6ea687f9cd01af4dcc6f8199e4d3
3665aea00cdfbe4f7b142d51c621d1704adaf434afa0cebf19
a5ecc574cc0bca34b1173f72eaaa10303de67c1157e907389a
f78afcbd8678c0f33e3db351ff2570f38de2b14e127d1e4fb0
f97178c0c05bd74fc6af104eadf19cd0c7e3b9a47f8828329e
869fe3a30407bd26de87dd8cf7f9571bbf449c37ff55e8cda0
3db6f913c893637bf17efc653abe41b0a739227881fe2d7c41
30fe3c6cf0bec7b1c0dbb6a78396c89c0cbe0fdf919c0eecd9
637c080df18f280ffec96683f2ddd90b03a5e6bf42b381f74f
6f347f4f99bfb25fcf912e21bf86347cf281f75929bd0b325a
27b3afd02bd5d594798b9c4fd8d6a38cc07ec4d0566b7e03fd
32f106f077f1150fcf13acf5aef756f844a258304ab5a5c64d
12c915cdf8ef2cdb789673f06a7ae661967e0fdf0c904ce0d1
07343f4afad7f415fc7c906d7532106f073edb43ff230e8f93
b68d5f71a40640c63b8a56fd909a7fc81846eb8fe04b249a0f
7ad4496f06f9872143cdc7cd8790bbe27f6129fde9cd14f92c
f32bc0cea8997f12fc12389e979aefa0cc9342dfaaffa7c8e8
cdf82ac432a39c630af90fcd71c0f1336c0bef223f6edccd6f
37601e7d6022a24acdd1cc2739c08cc665cde9a26db0c1d104
ada6c7eba9612e7109ac351e613cdcc078b881f475a4afe368
1632060aa9a71ed8bc87f1b68791f61846d3bb82a3b99fb441
ba9ab1b19cd1de0ba3dfdc406d0b585ac95293a55fa2873771
dc816b59ba0a58e6c26ee249e49792fe12d64ddf28f61423fe
04740aee010eb0440b34bc89baea5d9f5ff07aef0ee18c652c
bd46fa41d66da4cd41f309ccb5f87f10bf879528fe01f90b39
136f6154fc0d7935fe67e22b38820b105d9f2102c79b43104b
6ceb383d70d23b9e9834ad3a69becebea3751b73dc331e5866
d966c6cc97b1aa42a7f8f95de4768efb2a330fab27e75196f7
dbd429767a7eefeb471a31f67efc1d48d2aa6a7310b20471b5
f900e90738a61db1a368dec6bc91c358cd21672feb4ea25593
58eb61d6c2b71b4efa4612c3da6b68eda392fb250e31fb3c1f
7a319a8fc69b4957a2eff098a79b9b01860b9d8e78f6f46ffe
2330e247f00946d195c44f027b7bb0d71f9183e73eb9581724
c690c7f6208fc95cf829e3ed8ff4e4b728d983328df4702563
89b1dd8cffe2f9507f49f0cfe3929db4bb35acb33fffec27b4
7c0c38f82a8c8cdd679ce35770c4ff4c3f607cf538be84309d
b97a63fc3b1cfd428e5717fae7a7f40ff0ad26c6a8d48b58aa
421449540fa4259f12dfc65cd79ffc79c43fa58521f2638cfc
151ce5fdccc0bd18b7a768d5ed2cfd1a23ed65f61a5f2a3fe0
3dce3c361ef67004abcda768cf538caebf704cdf608f46b147
c079c6cbcce1d730b7f46156414cde480d1ffa6c46c8088ee3
28c6d54f18f9065b6f607ef672f615b0f5c128f5699c95af72
b6ee67eb8f339eb9d239ab8cf709729ee0d8fd96f9ff06d2bf
23fd657ae945e239c4058c048eaff16d8ed7b51caf22d2d793
be9c961ce3b8bc43fc116787cc23edabc0623f315643d1f93c
69ac7453dcf8df865d3ae7cb32f346da738a1ebe959176001c
4367e96ad288e1dec8e79e3c2ff9de4798514b9831b0be1f64
2e3dd80c9bafe5ca7526fe75ae5053116971fcd7cc2183fec4
3aab0d607efbaeeccda556fc1752da4cdb16e16b08da64135f
371ad33c013b3753f61ec672e452ad11fd926c80bc7ad42006
ad4fe2cee728734b9dc3c1d755241fca0e47cdf605586ab3ad
f3e013d7b1b4c11765bb5d9913baa22e2241ef02be1e04d6b6
20db68f5c0faa4780d259763374eba0ab4d9e01dc66f9c7197
6e9e04a6cd6b80fdc760adbf0bfaeb5d642a60d0c621d6eacf
ac5267f29a881ed86276a7cd75d486af4d3731a336791711e3
2b2ecddc3d3678ab047f029b55936f16719432eb488f60c4fe
4ce88fbcfc5a92975fe4a2bc127bc139439adf77642bcae477
a7d9aec2dc94bde25e96f23b495e7e5b12964be9af495f49fc
57e2296c77307d8b8cd4e01f473c92185ff07ac92fbb8be605
b4e17dcc68b59fb69df43adfc7c2ce44791611f3eb6ece7763
3ddcdf6a7c56adf1abcb9e2a62f6c8f9e692c7e90bbe0f395d
fb2a3cc375f028b1428617ccef6535df49fe56e25e9c2312c9
ead7cdfc9e123283483ab5f895bdf800627e872a2e733f7e0c
fbf678393298d0b2033fcfebd6e65372e5211823de7cca7476
dd39e460f79eed6270ded2f9e54ec88b0c7632d7b91c69b779
9b5cb1799a3fe08ebac8b99232f0659e6cf79bde72dddd7cd6
69111ca11d3ef7f668b7f984ab193325dba1a15fe4a94df3b3
d4cbd2f3d4e07c6f9c7a0cfa017ca1c533da394482fe14ae0e
b473b80ad0a681630c22671a398de49c25a7b1f9034632386f
91b38532f3c9594ece7c72c690339c9c31e098c5a0cda5ae9e
535c5ff653723a67dc29ee19f6b3c5e99cbfd0530f8ed993b5
eac9d940cd9dc8d9008e3e0e1c6f1c1c7d1c391a6bad254723
e798d36e5c3c66e490ce65df7793ae40bf8c43942f60dd05a4
3349cf7668ead90d8e6f3039bbd9affba9a196566da3e57be4
fa55dac2e8cbaaf401fb25f1affb789d789c9c3ac8e87d2813
27e720640c2fb5f9c93943992e943943cf4f838c964bfe31f0
b55cc4b0f405fa0740bf964b4f163a92b4a7901c9b9c6ee0c8
9e19b5fcac3587b5fcec5d26349bd3a9d9cf568682d6e710af
a425ebd8bb2d8ced8fa8b99a9c9d2c5d44cb07b2dd83ecef40
fab6133568d4dfe4f49afacfbb1ec0c856806394b1f50a58e8
394899172953479973d8911a53f11d4b19cd498837dfd5b8c3
00beb9d6e193ee035a2f207d1eb4670fbee9a897f3ea758f79
17fb053ace5de21996de47ce19948a0f5f42b6e735ec28604f
6fd7b763e93d687896f32817750583f30b70f4ff4bfc67962a
afac4186e2de5bc11bfa4246ec4646d142f6eb057a6638fbfe
02c77a07e34199f7498b5771bccea1a7460ff6b11efdd20f50
cf41ea39805ae69bf473263554c01ee37bb0c1f880b5e6d31b
99f44615b4e95f71693ff4bbde13be59e47a0ff4bb94293470
ed9fab238a745a5242fe13f4dbe5ece918ca67935f47fea7e4
57d03fe5a6accec603f8aea4568e5e1bca38079fa077b22ea3
eebd6c37c898b98a6351859551fbc4db113b288ed46660f3cb
6ce52035ef445dcf1fd8e2e36cb19e9c752c3dc73dc91e60ed
07b4fc2df2e7937f863adf0447ae4150ab907b8351d06f1ca6
6f2b392b47387393ad68943c4e3dd3a8f34e5aee73facbd261
4e5490fe9923c9a81e082cfb04d83f903eff983a332979062b
b856cb1119032c7dc438ce83f7cc178025f3208a7a79ff55f8
11731fe4e9c3bb112dc63b8ca2a3ce7cf1fe3bf7d2a2417b8d
33652775d691331fa5fa22278671d560dc8cab42f37d5a95eb
ebc6d501961f66ebd526e6c2616a56e67b8c67cc88616ca58a
9e2c243ecee8aa621f6d66f5c9b837a5d573cefa899511640c
0491c9c1d135b714d17e043ab523cc2771cec738bfc9fa1165
a2f455356d9b0cabcc306d9b4c7b0226ee4e941baf81e65c68
74b4391ec6b8ebcf83f63de3c43cf4485ee2d8d1fe3ae6c67b
4cb96ef574606e9c41efd573a476b3779a4bfb49dfc5dcb51e
739091732d46c1fb9fa49fe388fc9cf1b68cf838e6bbe73863
720d35af7173cb7e7a72253d89d223f4de1172e2e434127f46
1b7cacab3b63e4f5708cba708ce0b77a43764d7a5f1df737ea
19332f63c6e9e91ccddf981ed01ccd419c9b35b8cad606d163
8a1c058e710be7ec0bd49f01fdfa55f8eeb0f70160fd2aca5f
616067bbd6cc02cd5c544dfd3f801e6f854373d61fc6488966
64d443c82afa0c7d2c688efb64c86b1eb465688867cdc36cf0
00e56f679c3fc4d647b1f587d8afebd94a2e64f4eb29938fac
6b1e607ff3e98d2d8858cfedd4bfd6d1c615bc1a7769244b97
c22a604f00753d8d940f705c4e6276e8371b9f80663cf4638b
6fb3c57eb4e121675ea04786c2d5bafe4bf4c2bb13faf55fb2
77db506a5ecf2cba8d9c67e8e763f4fc33d4fcb2719619f24e
e61c8cfe087a7818254731ce87d1aa22de417a90775a5633b7
04ccaf033b344bcf2386b5c96cab91e37e9af32546ab46b217
f3d98b91b47f1cae1acc83bc6f338eb52cee6dba3a3990be7d
19b524ba64e6ea5f06966b49e1fb27201ad3b90afb27409b6f
0322336d18e6858fbb35f38fe0f89ee44cf92338deddd0e657
d0efbd0f3df5764066f305b8637c9d2df667ae9b421b4e80e3
dbcc5a47c0f155b2d661c8789f47a99945ba1ca5c6ef996f6f
4306f0eee27cbccd59733167cd0caed49773365dceb87d9839
c1cfecf73bceac7e9c65fde8d53ae20ec80ffe79b8324ae73e
d33fcfed6f3efb2bf3dd3c015a7a4a9a239bced1bc9eb1fd5d
aeecb3a96d19579fcd6c6b1fdb1ac14cf54df2a7905fc95a8f
727657b2d612ce9d1e9c3b4b9c58a2cc31ce9a67c899e0c5d5
ebe3e604d04e06e0c84e663ea927ae6374cd67deaba7cebed0
a97564f638a2e33e6147d63da2afa706ee64a0476631a2cb03
49e35f9867d651c365b46a1de7dd4fc9799b9c9f92f3063995
e4bc41ceed5c05d6eab887dcc8d2db79bfcbb9e2e8e6ac1428
d5ba311e9e046ddc4cf900e76923ef3c1ba8ebd98ff9e50950
67396b95a354e71eccf831f748ceae83325ecae85c297467ee
7cc6d86ea2fecf9c59499ffcc9906b34335d87557fa26d2b39
dfffcad295e4f4e37eaf1499c7b39eb3e376f6713df89279b0
6ede45cdc3d8d6eddc59ad85cdea2447ed13d24dce1c774be1
8d55e47c4cdb96eb5f054ddb3ea0b645d4f60c67fd5aae5c39
e4f4206739b3c44bb424600ee4fa782ffb054fbee4f896a5ef
d3ff0fd187ef3b6b0123610223e1306833465ae10bef12033a
f7f3b0ea142df91b7297a71eedea4fb25d5ebbe97d41eb7d91
df64049b1881b0f030eb56b347ceeec2e66ad21b58b3694357
c6c000dad9957e28c31c9771c77d837dd4b3997a2651cf6667
87c9fb36bfc1d7e6bdf761dc8ddf300b79c9a9e3dcf4a2aef7
7ab7f44ecc29e333a1bfcf38e9417b9e823ff5758cf6a71839
2b4d9fc81c352cd05ca1ee3577891e0dbd33eea58c85568cb9
d46331ba4ac999414e29357760561fcffccf9d86e704395d79
c79b7943f60c03b8cfc4b5cf2066a735cc246bb81398867b1a
b297c093852ddcddfd90d77aceece67584670725b750c64fbc
8f1ae837ed43d21fd287c7c9994ffa4dee52de64fe7c8eed4e
f3fe015773a0cd85e48c0247ae4357720f29b4fe86b3efe53e
ad91da3e664ebb1a1955f6b78e6dbbb913dbcdbd1fea6e407e
36d63bd71ab827a66da1fe25942c74250790866f9f824e6f9c
bbee01dcbf4d67261fc7fd5826f766e3b8d32be055640169cd
d9adb145bfc38166c1e8e355d4f63b5e77ace39eb3036464cf
89d673597737addae9ee155772de41db44f79a08dffd3ec3bb
9a97b32fd57c1a32107c59499dab00d49a423cd0f503bcf427
5e9d9de60a750ffb92490b6b9c76419bbfa6ce389e65c8b5b3
73ad2ab471934333a26a9d15c4c9ed2ea6fd6ccbf6e209d710
58e2bd91bd0870a5bb09771db5d10666f43403f7c347331bd8
cca8b6339bb82f7a13587f86fc7edc6fd463bfede12e487b84
3b9c81dce13cc27ebd4c4e19392f73ec7877c25c8cf5512fe4
bce8c8ebdf1f705e7474c6174f97b473cdf83e4f23ee46cace
139c46dc7d95fd793e57a230efdb803f0d92321623d95fc15a
29e7ec4b5cef38d73ccff04ec55ade4fb8d9f899c273d52ad0
2c3dc4ecf106f3e1402f6ce6bd116320bd9acb3cef61fee9c9
5c34d6a1e9a52ada9cc93b8a1f314ae3c47b88d711d7b3f5bb
9915a7303fef25ff6966f8c3ccf04fb3add7381f5fa35567cc
ef205be26f03b4df71077e1bf7abbfa36f1563fb65e6d2b5b4
9f2ba967ad73f7ccb1811a02d0e019085a72e65d8cbd95ccbd
d050cf2b945bd947bf433ba30f0df1637862d27c8ad132d9fb
a9e0777c31d8eccb05f6624ff20e6cd31fe6ee7a15384680fc
17dcbde208623cabeacadd88c2d35ec1c2d79c55f257e47cc6
a7c0ef3af266255719dc6d2ed2ea457f09af70e7f0ffe99ec2
9317f35643c3150aaf538a88df253fc68c9a4fbc144f1f4c87
ee68ca0aee7d1db45985bbca4617e33bf85b14e316a1cb8d1a
69e53953e2df7c82b8da1cc03b7e526a7ecbbc49f032733872
38b5edd331ee4f6bbf129ca7df26f84ececd5e3aae92aa4d53
f0367d34ae4a743cb79aa26f15fc137d15d7d31f09fd6fe623
a273b2eeacb0fd793584baf38827e87842fd231dcfb9e6eab5
822fd71722b3e9351c773ca7f899fe1c6cd09f15bc5d7f5cf0
d7f425d80752c34af8cdfc26e91751cbf36fbc36e94a9bbbea
e3058fd2711f608d8e27989f123702cb2e0e775dea75e48708
f1481dbbc469faf3ec055a790e3a8d6c1d4f9cb3f5ffe05de8
5ae29ff0ee3d9f2c683ba57496e730e2815fdcdaa9bd81f942
7a327139f116f0b5c3a03de3890f6a78d2374c077e081c7d21
250f6bbfe0eeee656ac3df18bc40ba1cadeb051aae6e34d4d5
cf6bdd90493c4b911f3c8849e5c1df9cd47bfe1fe9bf81d66e
628b6598711a9f4a33264b3dd881577a1e0447c75f4404b437
319b3cefb2ae831d3db5c4872109be6721fa2e29e304f97bb1
e2e049879e8927209adfb31d595ae35336d2caf333f6e50fac
050db76bc7b0162bec2dc7307b8cc0f302cfadce5f3ae12f7c
b40af79ec32a60e43d7338e9e1a08dc3a08dc3a41f20fd0073
e35aae476b41eb9d41eb9d41fb48fb1cfa49d24f5286b44eda
e0f32683cf4db472ea2907ed25ed256dbee99b887681b5b5a4
1f00368713dbb4d0a6e64a6aaea4b6add4b695fcfbc8bf8fda
5ea0fc0b6c9d7c837ce31dd2ef385651f3b3947c961a3ea186
4f9cbed0866b297f2dadbd9ad65ecdbaf49831dce92924bd57
13e753269f323594a961ddef93ff7dcabfc156dea08c46198d
323d28d383fdf2b15f3ecabf4ff9f729338f32f368e1387a7b
1cfb4bbe49be7915e9aba87f0df5af21ff34f9a7a9e706eab9
8132432833846d2d605b0b488f263d1a743a47249da39f360c
fcb461a0fd1c593f47d617a03d01ea9c429d5328738432479c
68a1578738da28ff8c8359ebbbacf55dd28f927e9496d0333a
3d63ec267f37e908e9087b67b07706e547527e246536526623
f94f90ff04e915a457d0db57d2db5752fec794ff31659a28d3
44fde9d49f4eba1fe97e94ff16e5bf45f90f28ff01e987493f
4c99b194194b7e1df9dc6fe8a7489f22fd29e94f49736eea9c
9bc600d61d40fe24f227710419d55e46b5973abdd4e97d9bf4
dbaccba8339ca85bc7baeb687f8cf6c7287f0be56fa1fc5cca
cf253d83f40cd29ce306e7b8fe1ef5bce7cc658ca3ee8ce96b
94798dfcc7e9cfc759b799fc66d27f26fd67b64b1bbc8e0d61
d261cadc48991ba96729f52ca5cc1594b9823283283388743d
e97ada760f6dbb87fc8fd3b0979b43ce1c96b2159dad98bfa5
077e4bba96742d656ea7cceda4a959a76683320665d42a85bb
caeeff4b5b03d4006b8035d81a66dd618db6c65913ad29d674
6ba635c79a6f2db2965acbad95026bac75d646eb156bab552f
e553ac1dd62e6baf75c03a621db74e5a67adf3b666fbed0e76
beddc9ee6277b36dbba75d66f7b1fbd903ed21f6707ba43dc6
1e2f7c1c03ed81a211c72b38f0cbee46002d207679fcdf509a
ca48f96fde19aa977a583da27aab757294f33f7b2bd4efd52e
75adda2dc7f59edfc8bad2c7d869bcad2af17ffa52d3a346a8
aaa4fece51a5497d9b23e73942ad941e82835e26fa09b8d0cf
add2d323722c17a9a5d656da38566cec283676151bbbc981bf
c1ee2ebca01cbab2e53054584594a962aaa7f2a9ab55994a13
9bfaa92cd55f8e0e4abcafb2d5403972d420392e5383d5ad62
e9d7d45095af6e17db0bd454393aa969725cae66ca1150b3e4
e8ac76c8512c7d7f5b95783a783aa82bf8aee499497d4dd77b
5ae9568e556005ac52abbb15b67a591572545afdad41523254
7823ac2a6bac3541e849d634e1555bb3ad79d6426b89709759
2bacd5564eb0ce7a51b46cb0360b7ed5da666db7765a7bacfd
52e39075cc6ab4ce584d5233dd56d20ab40e150d2d87ed153d
3c8275c13a3bd3cea596c4312971d885d650bbd87ad5ee0a5d
a263901d14cdd54297124a693b8ea1170eb1adbf9d29b6ee11
bb9bac801d951a67acee766fe9ed6aabc2beceee2bfd5f4218
2b7ae6d903ecc1e28fb1223bccbe43b42e136f6cb0fa439300
fc05182ab655493f01a2dd1e6d8f132feda79f00684dc09e68
adb6a7406f4b2bd09800d820604f97732fd10aa890562aa445
39db33ed3942bf6855daf3ed45f6527bb97871a53dc55ec3f6
6983bd8ebd9b606f6c695bc07ec5de2ae3750cbdb5eb492500
fd776a4f126d3b68dbe7a02dbebdc3de65ef6d657f12b00c36
1fb08fd8c7ed932d1626415b7cf0ecb3f6f964eb5b7a217cfb
2c47d901d801dfb8f687b4905f62b134d4c15a48c80f75120f
07425d42ddac79213bd4335416ea638543fd4203434318d912
a7a1e1a191a269bb35343426343e74bfb52d34953e2c0dcd08
cd8227438f8516841687346951c6305413aa0dad0aad0dad0f
6d0a6d09d5851a426f857687f6850e868e864e844e87ce85e2
8991440bf62b6103104e0fe7582f3a3550162e0807dcf8713c
9af01e475ca0654cddb84a7841622b5c1aee8ee80887c3bd24
861bc3158cd55de14ad6806f2658a5e1fed6c2f0a0f0d0f008
6b6cb8ca5a121e1b9e20c724bb6b789a1cd5e2117f78b66899
17ac0b2f941637c8794978597845787558e670784378b3f56a
f8d5f0b6f0f6f04e39f684f7870f593bc3c7c28de133e126bb
abdd35a222dee0ee48a63529921b298c1447ba468aad3d9160
241ae91de91d3e16b94eda10df46fa46064406478645ee08cf
8e8c8e8c43496462644a647a6466648e3d31323fb228b234b2
5ce61aa22dc75a185969ef8dac89ac8b6c949c203330f24a64
6ba43eb223b22bb23554136989bcc881c891c8f1c849f6bebb
e4a07062f644ce266651e47c548bfaa31de8578c7a65343fda
29da25da2d6a137a46cba27d64ee0c92ac95008e8d7d32da2f
3a303a243afc7311dc5d721b80e3631f01444746c72076a2e3
a3f7338612b4e482e8d4e88ce8ace863d105d1c5b03f5a13ad
653f12112ef931ba2aba16b332bade3e2eed3712aa9db88b6e
8a6e89d6451ba25d24af1c13debce85bd1ddc8b6d17dd183d1
a3d113d1d3d173d178cc905a05b174c953136239b1825840e6
c4586b45ac54fab34d6c75b27193b53ad63d168ef5120dfbad
6db18a486eac32d63f3648f8fd634363236255c21d1b9b109b
149b16ab0eed8b0463b363f3620b634b62929d632b62ab632f
c636c436c75e65fe4b7762d77a31b62db69d3e11bb633b9d6c
297eaa9208df1fdb13dbcfb5f01e59f7bafd6ff87f31e9ed78
35896f09e1d76283b3954720bf9bd1cd08ce94638e1cf3e558
24c7523996cbb1528e3572ac9363a31caf04b706ebe5d821c7
2e39f6ca71408e23721c97e364f0a4b4a3f9eff28f96364c75
a3ba49fcfa5575b3ec2b6e91dd8157dd26decb103f8f5279ca
937922f32c2de2db7d82f78b4553e53c43ceb3f4ab82538333
82b35c00fd98c00297062c16a8492aab4d2a4bc8cd72e9c792
ca5625d1e0af15589f725eecd2804d2e24e82d49650948d8b2
29893735895e9bd4e6ac147ba6bae5970a9b5220d5968b41c2
47b352ec4c40a23c99ff58d2f931b7afc930b51dd8e4ca6f72
c7a026c9dfc96dac77cb937f2f4eaa33cbad933827e4d6a69c
eb52c634f99cb0a5c13dbfd5860d89f32cb7fdc439d9f6849e
dd6dd44b6d779fc04181a34976a6f6a52d5bdbf24f7be7c5ae
4ded9d1331991c8b8fa5f04e089cbe881f52fbff453625cfaf
c49c49f052cfc975cf09c483332ca39df1fdaf3cb7e7f74b3d
a7faf952c7abadf3b94b3c27d74bf8e98bce176b37b91fed95
0b6da50be4b8744e526c24625864ad82249980e327ab34d82a
5f5bdd05c2c10b39c38d0dab974045ebb6ad4a81fe02838217
f2831b8772f5e4ccdfe4fc82f646b875ab82ade6a335d601da
364160924b4f13a80e3216add902f304160a2c717e33cfa37f
b5c10b6bd0258c29db72f374721b2de5cb0456b4e1ebf662f3
8b622d355fb5959760cb6a811793ec10dfca4ebb75ee4ab521
5517fcb9d98196752d919313e5af0a6c7361bbc0ce60abf5d4
da935437796d828dfb839f5bdfac43ee582420a1e7987b6e14
3823d014fcfcda9404b67280b92cc1f326f9d55d4bed4c81dc
d6fdb60b1d7bede2a43ea782c8da5d9dfea28f76304967b4b5
bfecde02d709f415182030586098c01d02a305c6094c149892
34268935bbadf3dfb3665c6a8e5bd04e3cfdbd6bd2c5ecd874
9173ad3bdea9e77f26d7267249f23975fea49e13ebdf179dbf
a83fffa8bd175b332f655cd7a7b4efe6267b7af0f37b5bc4ea
4c813902f30516092c75ebce4a6ae731b7cf88e5e5c10b7378
71b0f5fe3831ff12fb10d71e7ba5b34ed86b8217e63df8eb9c
f9975cdfde98645faa6ed16bbf92c473e757727e4ae4a296bd
336cde7aa1dcae0fb6e4777b4792df5c9bed5d297192c8097b
53c67841f0c25c44bd0302471c1a6f7bcc48cfc852ea7fdbfb
493c8b34fcc753a6a783aa54aaa450a058a0ab0b4181a8406f
81eb04fa0a0c10182c304ce00e81d12e8c73f9909b9804535c
39c0745716fc9902735cfe7c8145024bff0158eeea9993a26f
a56bff1a5737605d8a6ceb7a95c51b8a3717bf5abcad787bf1
cee23dc5fb8b0fc971acb8517e9f91a3b1b8a9787f89e2e12d
c92cc92d292c292e51c58d255d4b8225d192dec5b38b67975c
078cb34395f4251e5032b864981c7788bea6e26325a34bc6c9
31b1644ad281af14e67efe5dc7febefea1caf08ff08f505ff2
cff057ab02ff23fe475591ff7bfeefa9807faeff71d5996f39
eec2b71c87327a64582a9611cd88aa5e191f657ca4aece7c3d
739bea9d599f59afcab272b2bea4cab33a66755437fc8fb7e7
f1e47a26f059c22bca52aa385da9dc410e14e7081408042ef0
da83e25281ee97201716e82550e1feae4c29efffc53a5cb03a
d7765e9572acedbcbe85ded48abfa5855effb95aad0e19810e
7c97b5f20ff37f5d79f82e6b93efb24ee7bbacb3fcd3fcdf51
85fed9fed9e2fb39fec7c4f7f3fd4fa82e1976464495667c98
715c75cb7c23f30dd53dab20ab40f5c82acc2a54c1ff36bd78
2b4ed985a74139f35576604d605d6063e095c05681fac08ec0
aec05e815d8103812397e1ff9b3d5a8dd8e3d79ed79e9704fb
73ede7c279497b4969da066d83d2b597b59795a1d56bf5ca44
4e53de8c5f676c553e916ad08e2843dac2532d9553acb424c0
6f4f0a80af270178430203037d023d034372660486074606c6
04fa05c607ee0f4c0dcc08cc0a3c1658e0f2ef0f94e50c0f2c
0ed450666aa026c1cf59102823af566071205fb47508ac0aac
e5794c60bdab75556093d38e9c6749c916e1d504ea020d526f
48e02da167889edd817d39f9223546dacd0f1c0c1c0d9cc0ef
9ce1976f0d2c089c0e9c0bc43b1ba2d12f25659dd33be7040e
e61cec5c004bf30eb2c6c85caf9cc596ce01a7a5d4732bfb70
4ed8e79e13ed27f4b5776edb6fd947daf55b4fe1ae12bfb9fe
ea5cfa85fe72fc04ffac6ae59f567eb9547f24ec68b1d76daf
c5bf6e7f127eca5f2892b33a77ef1cc8f55e5615385830b273
40da1adf39cc91dc4dfde8d32639f70bf8514fa8e19d7be56c
caabed6ce4d58ac40c69b99d784ad825b16f684f6a3217b5a7
b5a7555a465dc636959ef169c6a72a4bca7cda0aeddfa5ac4e
dbae8ab5df6a1fa82bbd0f791f525cdfd5573817fa657f94dd
a806c95cda2899b365f66565aa2145d33b696d1d854d6df371
24d7296c72248be600dad6d69eaea23538dcfad35bcb16d5b3
7426e7ffd2bfb79fc63e335f3240a69aa03a2a4f66578272cf
a9e075cf867bd605b4a4f2e47a664addaf15f629acc9995758
5314c8389b71b6e3f1ccfbb3c299f71795168e291cd3f178e1
98ec3a50ceafcc91b97d324716c6ddb29acc1ad4737f752aac
11e894f825f53a25eaa5485eac1ecb122d648e2cea9e39d2b5
6046765d56b8a87b61bc285c384424cf89d5e78a7a399259c7
326b04eadab2daf99571d6fd6567850bedccb75adadb926c99
94b5b45e28ad1726f5b6a8a2551ffab5dba356bfb267659fce
9e5554496b3665151455c87a12767c9d5d57d43fbb4e343992
17f9d5da2fc9bf8a06b5f86568d188d6bf52fb27765449f976
d61b0bcb326b8a2a8b26b86593da2bfbef88905c2dab2057cb
d5302eff5531d15614b437ee171be97f7e6c8ba6155567d615
cd16adf952d650344f7c394feae51796152e2e5a9833af6889
78b08ffc46d9b2a21552d647caa44722d9bd68b5d3a3942888
17f52f7a31679e78d8f9b5011c6754a4f5cd59051724b37b4a
59a53b3b0a8a0a126585330ae399c38bba8b056ca12850b441
a07fa29e4440bca8c0f95514c8ee59f46aa2058e474d568178
54ec2cda269edf261e6e281c5f787fd13cd1b7c2eddffdec51
a2b7b545dba5473bc5c3e209c98369da8fb41f29e57dd0fba0
f2a4dd91364a696977a5ddadbc6963d3ee556969df4e9ba4b2
d3a6a43da02e4b7b306d9acacbfe4bf6497e65d87f291914b6
aa41cca3783fd53c4f1d9fe17107e5dddf029e24ba2d482e1f
92b73bdfc8f3fb6af3eaf2a6e66fc89beadf9617f707f2fae4
e5e71d059db7db773a4fcbcbf707fce9beb2bc13f99bf34ef8
4ea70ff76fcb7f35cf164e1f7f20bdd6b7ca5796bfc137d037
55e074ee4c5f597a6d5e5c605ffe36df5bbea3527e3aab53de
b9fc8204401fc0bb2bef0480f5219704eddad6277f7baa5dd0
419b12f6b8b6b4650775885ed4834cde6e7f3a6ccadfe9eb92
77ced7d35783df69b9bea3e90dc2df936fe4eff7cfce3f949f
93bf24d916e8e2a83fa33da354da37d2be21a35e955625a33e
26ed9b4a4f9b9076bf32d326a74d56e96953d3a6aa8c8c8f33
3e5699199f647cf20fed0f8e71c7dc57eaf29d862ee8497402
b49472c877c83d2f1ef35f1676ceb9479cb3d9e4fecebd507e
59b5f007b9e56d9c519eab2e9b20e70eb9c1cb26e49c4e3e27
e418d797ee1b7825f3a23b2a8faa568b2f3cb7c65b45f16e17
173ae62ccfed752990db3db722b732b73f6150eed0dc11b955
844a81b1c21b913b41e8498469b955a88377de8a5d4f8a5dff
475b8cffbad296f0eb3519c9d6b2b7e9ec6d067b9b99f64de9
6d167bdb81bdcd630ce4b3b75f62bf0aa45f93d42af6ab8f80
5cdeb40b9e367899d95bb2b75c36e7b2be09c02f8189424f14
4e5f9776ca7b676f69675cbed9322e062d4da3a5e9b434e31f
aa83f1dac43ded70d9d52aadac7dc83972f1f224c8cd9996b3
a4c38e9cea9c2542550bacc8592de7a172ae0617659897ccc3
2aed4ec9c31ec9c3a3c5c6b16963251b8f936cec6336ce6036
ce4a9b26d9389bd938e79fa8e9519d5429fbcbbff4f00c2078
b2f08e254d7b96fff5e19199ed51f978438a5e62e2ceccff67
efbbc3a428d6f5bf9a9aea999dedae1e60091297252f191624
e7b8e4209224e7242e88888880480611101111011191b0ac80
4850010594a8924454b2808801444484e556bd5d2c3bfb3b87
eb39f779eef9fd71b79f7dbf4a5d5dfd757d6f55cf4c7dd5c7
7f4ee1763115ab253762e5cc0085454527acd5792cdd5a1dbd
e27d92c0efbfb146a8b04eb13ed161d145f4d06bbdfc7b54cd
db84ee2b7f015350f346941926fa637dce406281565829341f
f55cd45e1d7975ac8d89e34f286c8af581828f533818ab5277
f2193a9dabdad8047e5ee15c7e1ae9da1fdc08b155d53c820f
43996158e1f324d6e7689f629dcc2a9df158a5a37dabb5f7eb
556d4fead53efc3dbd2a462cc0dae957b45753fe35df7c6f95
0e11d6729cbbabbd88aec2aaad274c8a5efdf508c2ab905bd9
f39a043fc29e2f24fc529fc1cbb08f50c6f3e57a0565e05986
f5f5bc1b230cffc59ecf65ffd9fb5e89f949acce9d79dfa3ae
e7ebd91fc6aabf9dc60fb24e81772abf6e35b34a78de9071ee
04ed63cbbf1e29b168cfeefb5e7d057c5df1789c5becbe4f64
cfdbb2621a8df034cd1620d78657af5fb122bd1f6a187fdf53
302b8bb576adb1b6ada2f129acd32f1b6fbffa2af0e7cb1b21
7d9cb71215b9773c5f3f40f88c661d702fb5eefb14f6d6c5f9
bf43f9fd48c12a385f8ffbde67fc675347e9bb00ded6e85b04
fc024fe409fccabcd27d8fc64268df5e6c992ec3bae0ac9368
6189fbfe8bd575b50f947366e59eaea722ae78dad333ceca86
1ae06b9b8f22bd7a0dbead7d65b0966f1910de4354dbf4aad4
e608c703f76a0f7a9ef76a9fe719d9eb03b5f104bfc2b32e80
9497907b0257ff062925d1c2207e49bf171af8deeb87c885af
6a31059aec8b95b4fba1b1e6b8bbf5da1f2ec7ba20cf0b8fbf
12ea3981eb3e8dfb3d877bc72a145f135c7d31f025a3ff9715
53c10777300557f915380dd73d8a73736b0c4c47fa31b4f016
9e7b1ba454434bc678bd089a8c422efc56585d4dbfd29e70a7
4187a7d0ce6ee869f048ee73809ee79a9b08c3cbb9fe645095
3c8e968f434a7fe08bc07dc01d386b0e74950f25cf78fd10b9
5fa0fd33e1d508ded5457bac6488c15d1c442e9e971fdecffd
3d7116d6d2b05da8b3376aabe8adec42f847a4b742c9295e6b
510f3c8333ac7bf1bd83942cc87d0ae5e11b5d94c5553623b7
b2b9966ebfc7334f033b01dfc559f05ace24ca6c470ad6ea88
4da86dbd4eb7ca207d1bce8ac39d9643fdd0213f8574cfc73a
bc3529eb3ea2f901083f5f662df446edc98ef747fa518dfe14
edc9da073f80aafc50f4314f9f7b71ee5e7d96f60bc937c222
4e009f406e3de4c297bdf0fcb66f35abc1d35668f3815835dd
cf5b5d8f9a77227c0625bdfe80bee74fbd7b034f41e7ce450d
5fe35ade3afc4d26ac6b5b873263d15a784d521cb217d6adb1
8db79e1c3d30271076e4cb84f604706e67d4032ff6fee2d0e1
405c6506ca3c85705bedd1db9f17cfe23330d275f374b46d9e
f0fa27ae8e36f81a420ff0ceefcb8ddd0a5fc793c2f3e50120
f4ccb7a37c61cf7316ca78cfe83da42c46ee24d327757bea23
77354a7682ae8e03c700eba06432ca24785e48804fa17c5184
67012f795c8d7b39883e8c1ec5cea16d5535524bac961cadef
9d3fad19cf57160c030f087c09c6c1b277f59ae7e508bf097f
106bc0456f032b68dfeb8af9355b7a5e75c67ba32daef5267a
e064d41c22ed5f26ac91674599e6f0c07e16beae7af867c3e7
e36cac87c49a588da29d46ff39e0308dbe951a791e8d010f67
2005e8c759beca1a2da02881dc5a48df8ef040a4af427984fd
4791f23a727f474a55d4500161b4c18a41783ec22fa0e42ea4
f890520cf507907e062993d1b63ea81961511ee557207c0d65
6a22a525ce9a0eeca631847b8c6aab31883b0ae446c924a49c
47caab487906380ee7a20dfe23c0d2b88a1fe99d91b201e169
c0c5686d11a4bf81945b281f02d643fa60a45f043e8b945e08
7f0cbc0afc0388e7e56f84f050dc17b46aa1a47518b99ec692
517f59a43743fa24e028209e26ff1ae11d68e11484ef027fc2
59deb9a590521f65e621253f529a0277a39edec00940941707
808b90f2081025fd48f17c98a65606de5bc36fdd5bc97ff72a
fca991bf20529ac287a98705e1c9f4769a2f516f7f826a5e8a
e7cf141e4849d770f78a29938273adfb3e46d58871cf0b2abc
a3aa7037e016d59edb7a9d616a65edc53b75890edf6d187806
756e00626eac7d46abf0abc009c06f28cd47adf6a1a0cad441
f832c287810580fd617151c89d8f94e9081f4118f5582329cd
1f2e3ccc92d612c16b8cf17b4bda0fbe0acfa2fbde75fdc06c
69fe61d37b74fd1bbe5cbd5d3a3c9fadb72fc0c3c83d5fb41b
e9be4f5b2f5db716b35fc54afaaca626acbdc1e6f4465ecc2d
4ba4ce24b33f87b7338ab7db8acad578cc70a3466fe7156f17
166fa710cc9acc5e29985f79bba1787bb778fb88783b6aa877
0c8dd88fc4dba9c5db5fc4db3fe3aef7de81f1d4db7f45dd89
c23b734d4997ccae2a84bd3dbcdd62bcbd5eee160462ce9c8a
b7923b3d501bf68021ccf7bc9d5dbcdd68bc7d68541b749dde
5c11b3176f77106fcf186f5f196f9797bb0bbdb916ca60acf7
f623f1f66e51d7bd8532d8ab4387454bd52e9d92177a988714
efbef2d2bdbd5272605795f43ba66087156f3717a5c3cff4d5
cd5e23da5b10768b313b9a4c35357c46f77658398df2d815c6
f387eb1b8b16620f18b3930a74e2ed34a32c4a87b12b8cd917
07fba3a44203de1e39a9b1d024c6fa54cc21ef60c6958a37a3
3bd0612ac6f73b78174bc5ae3677a0bd3bd0672ae6f6a9b822
c18ff06df48dd4232625c42607f693e89ed4bd07c5f67c3a69
10edee9bd47b205de8d7bb4712b306751f3e8465a3dce46f50
bb752c556cd6b4432cb56ed3bc5e2c0d79a4b54275adbb7795
ae056555589a12a8313d4695a91f15424e3459944d6119aa40
752991ba5015ea4f854d5e80b2934d65a922d553237e57aa4a
03a888c90b520e72540f7f98ea5353eaa646ec81ba57222f4a
59aba4f254493dc966d49daad3202aa63f7533f9b19493e255
dfaa41cda90db5273de71e9c2e3f3fe5a2e214a69ad482da52
073de7a02169f95cdd6f26eaa13f6d69dab6512c9568dbba49
ac6abb776e1ce5a11294996a297b7c843a925e2bf438f26c2a
a0345c92b2506d6a48ada81d75a23eaab6a126b720e5a352ca
12eb50236a4d8f5267eaabaef90425f52c37aca72f19b809f8
31703ff058cfee8386fb4e032f00af00af016ff6ec3978a82f
55230f01b301e380a5805580b5804d8163805381737b0deadf
972f022e07260337023f02ee061e041e037e0b3c0fbcd26bc8
e383f975e02d8d7e025a40bb4fff21ddfd9981398079810581
f17d92baf7f497015601d6033607b6ef3fa4ff707f0f603fe0
10e070e0a8fec31e1fe41f0b9c089c0e9c0d9caf9ad6ddbf08
b81ab805f819f0d8a0214f0ef69f075e06fe0abc01bc3de8f1
9e83840f18044a600c3027307670ef5efd4561600960396025
600d554d92a8074c04b604b603767e5c09d103380098041c05
1c3f54e354e02ce03ce042e0d224750362053019b801b805b8
1db87bd8e09e43c57ee031e069e065e0f561c3ca9415a91a2d
3f30040c03b30d5757b172030b024b001380fa4d9c2bebca45
b9ff85105376fecfd1af8ea0b2e9d0bf11668a1d88bc3dc37c
0867572c54066bd4cb2b36aaa0b8e561c5139515ef54551c52
5d71424d65bbb59515d655ac93f16c6ec2e9433ec56dd9fe96
2cacd92b4d322af90f52efe7167f20da0f40ae182ebf62a2bf
1f62241f88d10f40a1d830b362b518dce5bf1b6314ff40c41b
2a793b79b94001f49e83373b731e88710f409fe2e6427f43de
db79ee9f61f881580a3acfa346817cff4288518e07a04f8d1b
c5fe5bd99136d26e3aa6e6643798c5b2b1c2aca22fce57cdd7
ced7c737c237d137cfb7dcb7d1b7db77cc77c1778377e3a3f8
5cbe8c6fe03bf9117e9e5ff7fbfd31fe82fe047f3d7f5b7f2f
ff70ff04ff5cff32ff06ff4eff11ff79ff75e117e5ac8ed600
6b9435d55a60adb4b6587bad13d665eb562014c819880fc606
cb046b45c9a8bc51a5a29646ad8bfa38ea50d4d9a86b215f28
73282e542e5427d43ad42394141a1f9a1d5a1a5a17fa387428
749602dac594b2653cf75082e9033aae6c32f441643c1c9b2e
ae4eccb449cfcaeee767da982eaef233af50f1a874f12d19f2
3f407e76c512d5141334553381ce6a26308886d3689aa066d5
7369212da3d56ab6fe01eda4fd7444cd57cf7b6dcdbcd4c8d5
466e3272b7915f18f9ad91978dbce5c92c7e23c346e635b294
91958cac67646b237b1839c8c891464e34729e918b8d34edcb
e2ddbb4f7166662f25c6b42046fe3f39d58c6c14a9bf980919
e25323e3b94a45c6f36d898c176c9e2eae9e57c1e991cfafd0
a5c8fcc2fec8fcc2b119f25b233f84efb5e215df57519c9ea8
66561dc968a9f02c23177ab288d16a914423cdd3289adbc8db
9e2c56d493f1e6a9c437caa8a3e2a64471ef9ed3e7986b146f
1079f7c58744f6dee2f333c4e76588df8a8c976814192f9d23
437c7486f8a1c878b995e9e2aa7de55664c8df99217e3c43fc
4a64bc3c455a67f9980cf1dc19ca77cc10cfa08ff2e333c433
e8a3fccac8de50fea30cf1dd88fbd578964df16a61ef2ecbef
35f28891a78dbc82d279d44ca0919ac7b757ef177a1dfc481a
4b936916cd57efa42b288536d176f556f7051da7d37449bdc5
ded4ce015898e560b15e3d09a62725b437b29f91c62e13a61a
69ec32619991eb8cfcd8c843461a7e49b8eec90a9691a67755
30d7ad50c6c85a463637b28b91438d1c6fa4b1840a86172aa4
18b9dd4873fd0ae6fa156e7ab26228f2293c1c8cd4fac35686
78e60cf18a19e2ddd2c555fd95c391f995bb64880f898c371a
1a196f9c23329e3835433c2592f313bd3123879a15d650ef8e
cdd53b5a17f58e368446d0189a4833691e2da2e594ac46d38f
d4787a508da827d598fab3d7dac4c946ce35d28c0289e66926
ee34d26833f1ac91e669363177dd24c6c83823cb1969d8be89
61fb26dd8c344fb3c95823671b697a531333fa34d96fe47123
2f18792d52eb4daf476aa999f7d462d4fce5efe9c5abc5b065
33dbc89c46c61b6998b0592323db19d9c7c8e1464e30d2dc55
33a3d566a68f36337db4d941234f1a79c548d38ee621237346
de6d8b829177db2219f168f5665250bdc9671cfdbd738e1969
34d8e286275b9a51b3a5b1c796c61e5b9a71bba5193b5b1a5e
686978a1659f7476a4de295a4d4c37f7518156f322478b56e9
d94e973f12196fdd3ef29e5a7f9b217e2932dec6ce104fca10
bf11597fdbd8c8f6b48d8fe481b63522edaa6deb0cf19619e2
cd23afd7b66986788f0cd71f90217e3d32fec802f35ea09f83
1e8b49f55a9f4a6b4acd54f27ab69e7c812a812af815d4fff2
5a233140bdb984599c2f8137f0b757bd2cfdbc640025d1281a
1f31caa4e79af37485aed36de667766023f1c0eac09ac0fb90
c9814d906b039b2153025b945ca3425b21d7043e804c0e7c08
b936f011644a609bd2c59ac076154b56a57740ae097c0c991c
f804726d6027644a60972a9d1cd8ad626b55e94f21d7043e83
4c0eec815c1bd80b9912d8a74aaf0dec57b11455fa00e49ac0
41c8e4c0e7906b035f40a604be54a5533268e41f8dbbff4c23
8770e7ab03878d668e18cd1c359a396634f395baceeac071a3
9faf8d5e4e18bd7c63f4f2add1c8774623278d464e198d9c36
1a39038d9c351a39673472de68e47ba3910b462317a1914b46
233f188d5c361af9d168e48ad1c84fff8d46fed178945e233f
1b8dfc6234f2abd1c855a3916b4623bf4123d78d467e373de6
86d1cc1f4633378d66fe448fb965f4f397d1cf6da3973b462f
a94623773d8d04c9d34890791a09fa3c8d04b9d648d0ef6924
283c8d042d4f23c180a79160d0d34830ea5fd0c8fdb7b2cb74
8d6e311f0b05439e4682d19e4682b6a791a0e36924283d8d04
5dad9160d8d3483093a79160664f23c12c9e4682319e468259
b54682d93c8d04b37b1a09e6f07a4cf0214f33c19c9e6682b9
748f09e6f6f413cc63f493d7e8279fd14b217da7c158a397fc
462f71462f058c5e0a7a7af9973572254d23858d468a188d14
351a296634126f34521c1a29613452d268a494d14869a39132
462365a191724623e58d46128c462a188d54341a79181aa964
3452d968a48ad14855d363aa19cd54478fa9613453d368a696
d14c6d4f337af5b46eb71e07d86cc5f4360d510341508d09b9
d5fcbf8cd2573d3593696f1f524c5f37d8ca3fdb3e6c4273ec
2308b55669474d688e7d4c85eaa3dc572634c73e8e902ef7b5
09cd51d7c9a9660ea5a8927a1e4dd54ca99b62f5e16a9e34d9
3e9176a56fd2aef46dda95be4bbbd2c9b42b9d4abbd2e9b42b
9db97725fbb20a350cd655693f9ad01cfb0a42f555da4f26f4
a0169d4d6bd1b9b4169d4f6bd1f7692dba90d6a28b692dba94
d6a21fd25af4735a8b7e496bd1af692dba9ad62265fbac142b
45a4176511f315f01550693e3d7e3be53192ebd9df35ccc24a
a9b7b04435fb1aa27af4525aad38ee922a6991cd3393cff787
d39e7ca2b2496988948e48513307e73115aa62f21a23efd174
a51391d221ad7467941658c79643bd2516c439d7719dab4e3b
955b15e7fc8eeb5cc3399d7076ba73f4157cd775abd4391d74
69dd1edf355dd277d3bbb2be92ef866e9def37d4d24eb7446b
c07755fffe4c541655952ef4afaab935c99ae8bbab35c631a9
e1211ed2bf98e2363416229f7bd5d56df1f9aef87ef2ce71ef
baa961c2397eaee64fd1cba3971373efb877300bd2df463276
81bceff81aea5910bbccd4fc991d4997c6d931756c51a9dbd3
a532edcd9cad8c383759efe5cae6479cbb401dcbf4af6dd3a5
fad9041c3355fa90883a47abff76117576d42bb259bd883a1b
a843efd25d26a2ce3238d49b2ecb1951a79a73335f449d16d3
9fe4fc9abe4ed5c7ae313d6bfc367d9d2aa60fadd5dde9eb24
fdf94072fa3a691de9f78e8511752e52875e0f3939a2cec938
f43b5952449dfabda663449d5d48bfc9358aa853fbcdd56f1f
09117526e0d06f4e79d3d295f5584df19bff3ff5b7cbaabfd8
14b2265a93b06e83c9bef2499465d14b80fa7d8ac9a7105e86
f045b44b7f4652c2d4da08edd29ca97f277e2f4d9ff1e6dfb9
921c89f38baab74746f79e6963a4c5e8dfb95299b4b47f5c9b
aa232c1e906779fd9eff60e5e19a5d9895cfcaaf3ffd66ebe8
18bfcc6379515e8297e2e578453e9e4fe013f9643e95cfe4b3
f85c3e8f2fe08bf852be9cafe4ab79324fe1ebf846be857fc4
3fe6bbf95e7e901fe2c7f8097e929fe517545d57f8cffc577e
4d14756f8beaa2a6a82dea8afaa2a1682c9a8816a28d785474
125d454fd1570c148f8b61e229f18c784e8c13cf8b17c42431
454c1333c48be2253147bc2c5e11af8ad7c4ebe20db144bc25
de116bc4bbe23df1bed8223e10dbc54ef199d82fbe1087c411
f195f8569c16e7c5257145fc2aae8b9be2b64596df0a5ab615
b6325b31560e2ba795d72a6015b28a58c5ace25649abb455d6
2a6f55b02a5b55ad9a566dabaef598d5ddea6d0d8b5e17bd21
7aa3edb32d3b644b3bb39dcdce69e7b5e3ecc276513bde2e61
97b113ec4a7635bb965dcf6e6437b55bda6dedf67667bb9bdd
cbee670fb007c9e7e4f372929c2667c897e41cf9b27c55be2e
97c837e55bf26df98e5c23df95efc94fe53ef9b93c2cbf92df
b8cbdc15ee6a37c5dde06e723f70b7bb3bddcfdcbdeefe7030
ec84dd709670f6f043e16e61ed65fa280f723d59ccc7f3299e
2bc28b908f17e7c5d5d32dc94b929f97e56549f00abc02597c
1c1f4701fe3c7f9e82fc05fe0245f1497c1285f8143e85a2f9
0c3e43b1fc8bfc4572f81cd52f247f99bf4c2e7f95bf4a61fe
3a7f9d32f1257c0965e66ff1b7280b7f87bf43317c155f4559
f91abe86b2f1b57c2d65e7eff27729077f8fbf470ff1cd7c33
e5e41ff20f2917dfc177506ebe8befa23c7c0fdf4379f9017e
80f2f12ff99714cb8ff2a3949f7fcdbfa638fe1dff8e0af033
fc8c1a53bee7df5321fe03ff810af31ff98f5484ffc47fa2a2
fc17fe0b15e357f9558a174545512a2e4a881254425413d5a8
a4a8216a5029514bd4a2d2a28ea84365443d518fca8a06a201
95138d44232a2f1245222588e6a2395510ad456baa28da8976
f4b0e8283a5225d14574a1caa287e84155441fd187aa8a01ea
5db49a1822865075912492a886182146504d314a8ca25a628c
1843b5c5583196ea88f1623cd51513c404aa27268a89545f4c
1693a981982aa65243315d4ca74662a698498dc52c318b12c5
6c319b9a88b9622e3515f3c43c6a26e68bf9d45c2c100ba885
582816524bb1482ca25662b1584cadc532b18cda88156205b5
15abc56a7a44a488146a2736880df4a8d82836527b65135ba9
83d826b65127f189f8843a8b4fc5a7f498d827f65117f1b9f8
9cba8a2fc597d44d1c1687a9bbb298afa887f8467c433dc529
718a7a8973e21cf51617c545ea237e143f525ff18bf885fa89
dfc46fd45ffc21fea001e22ff1170d1477c55d1a64718bd360
2b60056888156d45d3e3966bb934d4ca6465a227ac2c56164a
b2b25bd96998f590f5100db7f25879e8492bce8aa3115641ab
203d6515b60ad348aba855949eb6e2ad781a6595b04ad03356
29ab148db6ca5865e859ab9c558ec6580956023d6755b22ad1
58ab8a5585c65935ac1a34deaa65d5a2e7ad3a561d9a6075b6
3ad30b5637ab1b4db47a59bd6892956425d1e4e877a3dfa529
d1eba3d7d3d4e8f7a3dfa76936b3194db7852d68861d6547d1
4cdbb11d7ad1ce6467a25976563b2bbd643f643f44b3ed3c76
1e9a63e7b7f3d35cbb905d885eb68bd845689e5dcc2e46afd8
c5ede234df2e6d97a657edf276795a603f6c3f4cafd955edaa
b4d0ae69d7a4d7edba765d5a6437b41bd21b7613bb092db65b
d82d6889ddc66e434bed47ed47e94dbb93dd8996d95dedaef4
96ddd3ee49cbedbe765f7adbee6ff7a715f6407b20bd23c7c8
31b4528e97e369959c2827d26a39554ea53572ba9c4ec97296
9c456be56c399b52e45c3997de95f3e57c5a2717ca85b45e2e
968b69835c2a97d27b72995c461be572b99cde972be40ada24
57cbd5b459a6c814da2237c80db455ee96bbe903b957eea50f
e54179903e9287e421da268fc963b45d9e90276887fba6fb26
7decbeedbe4d9fb8abdc55b4d35debaea55dee7a773ded76df
77dfa74fddadee56faccdde66ea33dee27ee27b4d7fdd4fd94
f6b97bdc3db4dfdde7eea303e140384007c376d8a6cfc3322c
e98b70e67066fa329c2d9c8d0e85738473d0e170d770573a12
ee19ee4947d5985582e6f0381ecfcbf0047e9d4fe7b3f97cbe
902fe6cbf80abe816fe21ff0ed7c27ff8cefe75ff023fc38ff
969fe6e7f92535325d11c5f875514c14e7d34433d14a3c223a
88c74477d15bf41783c513e249f1b47856bc29de16abc45ab1
5ed9d766515c7c243e16bbc55e71901f51f29838214e8ab3e2
82b82c7e16d7c40d714ba45a3ecbb24296e49744332b1b8fb3
725b83ac8a56759edfea6af5b4fa466fb2fd76d0b6d56dc6d8
39ecdc76ac5dd02e6597b32bda55ec1a761dbb819d6837b75b
dbedec8e7617bb87ddc71e22c7c917e414f9a27c45be26df00
ae926be57af9bedc230fc82fe551f9b5fcce5deeae7493dd75
ee46778bfb91fbb1bb3b1c0a670a670df708f751a3c56c8c13
8471826184f06184e01821fc180904c6000bec1f00fb07c1fe
5160ff10d83f1a2c6f83e51db0bc04cbbb60f930583e13583e
33583e0b583e062c9f152c9f0d2c9f1d2c9f032cff10583e27
583e17f83d37f83d0ff83d2ff83d1fb83b16dc9d1fdc1d07ee
2e00ee2e08ee2e04ee2e0cee2e02ee2e0aee2e06ee8e077717
07779700779704ab9602ab9606ab9601ab9605ab9603ab9607
ab2680552b80551f06ab5602ab5606ab5601ab5605ab5603ab
5607abd600abd604abd602abd606abd601abd605abd603abd6
07ab3600ab3604ab3602ab3606ab2682559b80559b82559b81
559b83555b80555baa995c3e6a057e6c0d666c03666c0b367c
046cd80e6cf828b8af3db8af03b8af23b8af13b8af33b8ef31
705f17705f57705f37705f77305d0f305d4f305d2f305d6f30
5d1f305d5f305d3f305d7f30dd0030dd4030dd2030dd6030dd
1030dde360baa160b727c06e4960b76160b7e1e0b527c16523
c0654f81cb4682bf9e067f8d027f3d03fe1a0dfe7a16fc3506
fcf51cf86b2cf86b1cf86b3cf8eb79f0d704f0d70be0af89e0
af49e0afc9e0af29e0afa9e0af69e0afe9e0af1960ab99e0a9
17c153b3c04d2f819b662b6e2a4573797e5e8c97e6e5f96f7c
1a7f89bfc25fe36ff037f9db7c3d7f9f6fe5db94c5ece2fbf8
e7fc30ff8a7fc34ff173fca2b601c54dbf296e8a57dcd454b4
146d457bd1597413bd443f31480c15c3c548315a2c15cbc54a
912cd6a95eba49c48b0fc50eb14bec1107f861258f8aafc577
e28cf85efc207e1257c5efe24f71c76296b0a22c875f144dad
ac8a91725903ad8aa2ad0a75b17a587dc499e8f7d4eb72c08e
b65d3b8b9dddce65e7b30bd825edb27605bbb25dddae6dd7b7
1bdbcdec56f6237607fb31bbbbdddb1e2cc7ca0972b29c29e7
c905721170a54c96ebe446f999dc2fbf9047e471f9adfb96fb
8ebbc67dd77dcfddec7ee8ee707785a3c2e1704cb87b58fff2
73ceffb1d3ffb193c74e98abb5074775004775044775024775
06473d068eea028eea0a8eea068eea0e8eea018eea098eea05
8eea0d8eea038eea0b8eea078eea0f8e1a008e1a088e1a048e
1a0c8e1a028e7a1c1c35141cf504382a091c350c1c351c1cf5
24386a0438ea2970d44870d4d3e0a851e0a867c051a3c151cf
82a3c680a39e03478d05478d03478d07473d0f8e9a008e7a01
1c35111c35091c35191c35051c35151c350d1c351d1c35031c
35131cf522386a1638ea2570d46c70947efbcf4921fd9998f7
c999fb9b7bddcac72fbb7fc20f80fe8c0c1fa8284bd49fa471
7c92e65776715659e2657e990278a641abbfd55f7fc7c96a90
a4381a4ebbe90b3a41e7e967bac97cea016663b12c9e255088
f42fe0e3a82895a204aa42b5a80135e5bfabfac7f33f144ee0
eaca7c32ff4be14c6b32f944756ba4c29ad62885b5add10aeb
ca4de4536fd25b14cef92735de408d3751e32dd4781b354e41
8d4fa3c66750e3b3a871336adc8a1a19f9ad31ba3442cfa585
c6a685c6a585c6a7859e4f0b4d480bbd702f645f4b0bfd762f
e45e4a0bfd80904f31da297e9a48dc11a9e4534ced537508cb
224b317688828a69fba8a7b5d9dd42b6f9cc2988cf483347ef
57cf63863e9b5fbe1f564f86e9b5739165c3fc7ed9fbe17465
abe093d282281d56b5f9d3eaf59b923a47f2e7547f50e99ec4
f93e6f37724ac437088529c1ab435dc59f763d7fdad5fcd107
54ec373e53712d6a94ddbd1a3d89eb707c2e41f88481a9334f
e13359fd3be3782a4315f5da43aa4364d2eef504eff331ec17
a677aa5488cfeab42f03852b551d59bccf8e79669e598d200d
79138a12e5450249514954a5b055df6a42315673ab0de5b2da
598f527eab83d5890a44af884ea1c2d1b7a2ef5269a79df318
55903be42eaa2e4fca9354c73de01ea2baeed7ee456a1c6661
46edc339c339a943b86fb82f75441b0368731d858da839b555
ede96c5a1f306dcf6dfab1770f4dd0e2378027f1593f47f836
f014747e199afa4fdd914bedd43de86fe387aaff112a3c9ac6
abd0549aa5c2f3cce7bd5ec912f03ca92db4163555e1d6d45e
85ba511f151e64eeb829ee6c2bf034eeaf22fff5fe9d47ef47
ce3ee0f5b4fbd7b19f80eb8167ff831a89812ef4af7d26a8ff
a92aacbf571c438bb0c39e174a51a97a85db07463731a65f24
524bf5df4e85b54e134d4d5e68b44a1d6fb4d4ec7fa8a57169
fde7ff078d65513d601025d148a59b914a6b53a1b185b4345d
6c052599ef13bc33d2b85efdb7c65e7ebda0adfbb111da1f32
b4d51c77f8127083b9db8cba9a914e23c9c037d371c605a3c9
ff9c8e1856db15a47bab29c2e6de5ae03b03fdbb2ee6ba26af
9492f570e8122d4d6a0eec3ae81d5ebae2d2e825d14b89a297
452f5363df457c9b71ffdb089f3a274acf09dc3fdddfdd1bee
1fee4df796fb97de79087300c2b8ef53b326750d356b6a4b42
cd40f46fc1bd6f278743cbfafb955e545ae69679645e994fc6
cafc324e169005652159581691456531192f8bcb12b2a42c25
4bcb32b2ac2c27cbcb04594156940fcb4ab2b2ac22abca6ab2
baac216bca5ab2b6ac23ebca7ab2be6c201bca46b2b14cc4f7
81257c1d54a327fb26ab3bf42986cdefdc913ee9ca2c324666
95d96476f990cce1fce5dc76529dbb9224935cfaa590960cc8
a08c9221192d6de948a9a64b9964669953e6c2b7afc55949a5
c0abec0f15fed3e7eaef115950cdd4ba3aa39c679cd1ceb3ce
18e73967ac33ce19ef3cef4c705e70263a939cc9ce1467aa33
cd99eecc70663a2f3ab39c979cd9ce1ce70d67b1b3c479d359
e9ac75d63b739d579cd79c454eb2f3b2f39bf3bab3cc59e8bc
e52c75de765638ef38cb9dd5ce1a6795f3aeb3ce4971e63967
9d3f9c579d0dce7ce713e78073c6d9e46c76363aef3b1f381f
3a3b9c8f9d2f9dc3ce11e7a8f395f38df3ad73d239e59c772e
383f3a579cdf9d1bce41e73d678bb3d5f9c8d9e66c77763abb
9d5dcea7ce67ce1e67afb3cfd9ef7cee7ce11c728e39c79daf
9d13ce77ce69e7a273c9f9c1b9ecfce4fcec5c736e3a7f3ab7
9c5f9d5f9cabce75e79cb34069a7b99af745a9bea23dae33fc
9a2217bcacc7d16a5aab52b7a8a3a89a0f1ea162745a1d95e8
ac3a2aabb9e17965c117d551957e504735fa511dd5e9863a6a
d04dfa936ad25feaa84d77d45147cd227d5497f9999fea3135
35a2fa2cc8a2a8018b66d1d48839cca1c6cc652e25b24c2c13
35615958166acab2b2acd48c6567d9a9397b883d442d582e96
8b5ab23c2c0fb562f9583e6acdf2b3fcd486156005a82d2bc4
0ad123ac082b42ed5831568c1e6553d9546acfe6b179d481cd
67f3a9a3feb6963ab1856c2175668bd8227a8c2d668ba90b5b
ca965257b68c2da36e6c395b4eddd90ab6827ab0956c25f564
abd96aeac5925932f566292c85fab0756c1df5651bd806eac7
36b28dd49f6d669b6900dbcab6d240f621fb9006b16d6c1b0d
663bd80e1ac23e619fd0e36c17db4543d9a7ec537a82ed617b
2889ed63fb68183bc00ed070f639fb9c9e645fb22f69043bcc
0ed353fa7b691ac98eb3e3f4343bc14ed028f61dfb8e9e61a7
d8291acdceb033f42c3bc7ced19880faa3e79c064e031a6b2c
f67f6a950fb278cf623bfa26298b9de29b028b4da438659dda
36b515a6d9adb2d73bb0565f067bd5d69ace563dfb9621ed5b
8e9562e555cd615f16b27c597dc529e49bee9b4ef995e586d4
dbd5bf67b90b95a5beaeec7791b1e0a5ca5adf5296ba1cb6ba
52d9ea2a65ad6b952dbfabac759db2ee05b06f6dd9e33358af
67bb1f1aebfddfb7dd034a4b2d8cedea7d1218f5a771ca76f5
3e0909d821a1829aa5a4d0c3b4591d95e8a83a2ad3197554a1
73eaa84adfaba31a5d524775baac8e1a74451d35e90f75d4a2
5beaa84db7d5518752e9aeb25dceb8b25ac184b2da000b5043
1652cfa2917a3bb495edea9d6a13d5d01756b69b996556b61b
c36294ed6663d994ede6603994ede6643995ede666b995ede6
657995edc6b25865bb712c4ed96e415650d96e615658d96e51
5654d96e3c8b57b63b8d4d53b6fb0a7b45d9eeabec5565bbaf
b1d794edbece5e57b6fb067b43d9ee12b644d9ee7f11772e70
316ded1fdf6bede93233cd14250e21b92595dd457227241429
4422dd4b5795c271a98ed37109212a1d945b242ab94b45b9c5
21b914a224b9850eb9dffe6b3d53d3ecf39ef39ef3befff3be
6ff3e9377b9eefecbdd7cc5acf7ad65a7bed35dbd176e2bb3b
d14ee2bbe9289df8ee1eb487f8ee5eb497f8ee3eb48ff86e16
ca22be9b837288efd2b9b1bee8103a447cf7083a427cf7383a
4e7c370fe511dfcd47f9c4770b5121f1ddd3e834f1dd62544c
7cf72c3a4b7cf73c3a4f7cb7049510dfbd842e11dfbd8c2e13
df2d45a5c477cb5019f1ddebe83af1dd72544e7cf716ba457c
f70eba437cf71eba477cb71a5513dfad4135cc62548b6a9925
2aaa2aaa4c94249cc4dd68590466a085c8b486960e9ddfabd7
d46a9808f3614e9007239d2ca5773a90a84f5a553a10f5db33
22e938a9add44e3a5e3a416a2f9d2875903a4a27fdf63d9259
123789bbc443e229f192784b7c24be12bfdfbe07ee59a4f774
b6256d89ef9aee6225ef21fbfafdd97124b32561f299c930bb
594a7ff510fa44a45c22985541efa2d020c7d66d1e01904490
4f3b86b19544c2f304c97c78b693cc25fb8e610a88da3285b4
f44be611859634cca5a029992df19704480225419260498864
8e2494a4e0af7e22596affe971143f35f9dea7489da453a5d3
a4ced2e95217e90c920fff5a2e287c33f811a94de91d6a74bd
307aff418b9dc54fe444d612a4ede149500e1c9a2c83c85197
31ab7936fa8bd5e1cc7e9e4d8bd86631a94d36042bd1fd5d6b
63cad618ff77569f444268690add69eb15e7b198ae4745fea5
904e473a84857791473d39c72b58b5acc5be9a95e2ebb00a14
c2d572bb004790c75b9c47aca7c9ff7939a1ab73d1f5fa107e
2ab7616c834b61fd3e846f2abcf338f9a723490c365578af0e
a6bffeee4bb69ecad685697a771cf927ed685c862bf0bd96f7
a37a4c3e1db624e4382ec46715f67026ff9d883d957c366785
3d8e632b429409598657632b853da21884e8b760ac600b20b6
0a1a8b519c82750aace7c1e291782cfaaa601f0233da58d2d6
36a52b63c9cf698d7bc0dc513a2faec5ca610d98b186d157c4
29d8db219207c893b4a7eb503d4a6d21cc5752b7d1f5bc5852
2b96a10a857d4a48cd48e7b3d1b50ee5f947da4fbb61de5d7b
f2afab608f272db46d30ab0dc19cb5263bb3052d45f44e329a
7b0d2df9cdc432b12800d13e26bde3a84281042007648de8dd
27f4dea07c3951221ee0802c9121a233b5b690ff1d0a7b5990
58a683e85d49f4beb1650a7be990c75b842155f41eb7a02626
f32352f661756909fcf6871456285557b556b56634884f4432
ada0ec7350f64dc0774cd59faa3f65cc606d5273f023f076a1
1bf3afae3c8c71123973b3278a709a7cdf8e64df9b4c0f5232
6b180ed792e30c540e570e6786c2d186c1d186c3d1ace06863
e53511c23b4193a0afdd08db5b408fc96214f1674ae8dc4eed
e65a8b1c53406aad3dd4a3e8fa7c0cbdb39d85f556691e0bc4
a7495a9361ab48be550c5b24bf49998f87da8a837dda915e88
6c1f5a1336efd5b25ddcb4adb0272d51242516246fc29905a4
3d1ccbc431eb98a4a6311c7a57451e4357bbb94cfa35b749af
a60ee688bf27a557405a351aa4d542f29eb4428c91391a8086
91f2634b4ad154341379a2d9280445a08528062d43ab5102e9
4fa492fe42265e45d2bf0aaf26ba1aaf21ba86a405e378bc96
285d8b18e375783dd1f5e45bc13881d4b8186fa0398537927a
1793da37097230997e0f241f314e2125080b3690128495e792
128455ad49ad8a49397226ea2c9c4e74bad085a80bac613e03
6adb99425758cf9cc45ae12c5a8a846ea46695ade74ceb624f
a29e422fa25e426fa2de421fa23e4252a3097d8524720bfd84
b389ce16fa13f51706100d1006120d2435381606098389d2b5
75b13084e43e26757a2851bace2e168691ba1c0bc38524cdb0
763a164690528f8591a4846052f6df107d434a3d16bf23a51e
93b2ff92282dfb581d46c048496cb99fa91df8d6244636daf3
7779587ba679345d4dfc967cab7154f11328abd90c92ee2775
496b522f58a3596801c9e1fda4b557833e636dcce1b1d8132f
26b974005fc275a4426acf9ab3e3595f3686fd993dcc96b24f
0502412781a5c04110208815a40a8e0bae0b5e28a92ae9290d
529aa214a2b442698752be5285d22b6535e51ecac3949d891f
ae56dead7c5ab952f9ad8a868a81ca4895992af354d6a964aa
9c55a956f9a8aaa56aac6aa3eaaeba5075a36ab66a896aadea
57613ba1a9d096e45c947093f0a0f0b2f0b1088b744416227b
d16cd152d116d1515199a85eac2cd6150f104f1207899789b7
89f3c437c50d6a22b56e6a43d4a6aa85aac5a9ed522b54bbad
d628914af4255612174904e9296590bec93dc97bd2233324fd
c059d20552ba7eb62a2365b46809578d8372fe04f4b19cac06
b21ac86a1e5903640d90353c120f241e483c8fac05b216c85a
1e5907641d90753cb21ec87a20eb792401480290041ed90064
03900d3cb211c846201b792411482290441e49029204248947
9281240349e6911420294052782415482a90541e4903920624
8d47b601d906641b8f6c07b21dc8761ed9016407901d3cb213
c84e203b796417905d4076f1483a907420e93cb21bc86e20bb
79640f903d40f6f04806900c20193cb217c85e207b79241348
26904c1ed907641f907d3cb21fc87e20fb79240b4816902c1e
c906920d249b477280e400c9e19103400e0039c023b9407281
e4f2c8412007811ce49143400e0139c42387811c067298478e
003902e4088f1c057214c8511e3906e41890633c721cc87120
c779e4049013404ef0481e903c20793c7212c849202779e434
90d3404ef34811902220453c520ca41848318f9c017206c819
1e390be42c90b33c720ec83920e778e43c90f340cef3c80520
17805ce091122025404a78e41720bf00f985472e03b90ce432
8f5c017205c8151e2905520aa49447ae02b90ae42a8f940129
0352c623d7805c03728d47ae03b90ee43a8fdc007203c80d1e
b909e426909b3c520ea41c48398f5400a90052c123b780dc02
728b476e03b90de4368fdc017207c81d1ea9045209a49247ee
02b90be42e8fdc03720fc83d1ea9025205a48a47aa815403a9
e691fb40ee03b9cf2335406a80d4f0c803200f803ce0915a20
b5406a79e4219087401ef2481d903a20753cf208c823208f14
8900e2a900e2a980174f690b56358e2a7e02da422281440289
5424d0de8da38a9f80ca096d03abc651c54f405b8833106720
ce3c321dc87420d379c405880b10171e9901640690193c3213
c84c203379c415882b10571e9905641690593ce206c40d881b
8fb8037107e2ce231e403c8078f08827104f209e3ce205c40b
88178f7803f106e2cd233e407c80f8f0882f105f20be3ce207
c40f881f8fcc06321bc86c1ef107e20fc49f470280040009e0
914020814002792408481090201e0906120c24984742808400
09e1913940e60099c323a140428184f24818903020613c120e
241c48388f809708c14b843c2fa1fd2842228044f008f88f10
fc47c8f31fd28fa23d1b2125a02d0422ba1822ba9817d1c510
d1c510d1c5bc882e86882e86882ee64574314474314474312f
a28b21a28b21a28b79115d9c0f241f483e8f1400290052c023
85400a8114f2c86b20af81bce6913740de0079c323ef80bc03
f24e91d05ea96a1c55fc04b4853c03f20cc8331ea907520fa4
9e479e03790ee4398fbc00f202c80b1e7909e42590973cd200
a401480310cc6828f68961bc480a633e86305ed4177ac9f6d0
4b9e08a33d0ed0577684bef22418f90983919f70e8372f847e
f322e8372f26fde6066609e9176f63248c2e63407acf4360c5
5617c69b096116304b99d54c128c53c3e8076cc108086cc128
086cc148086cc168086cc188086cc1a8086cc1c8086cc1e808
6cc108096cc128098cf9343218c6a204b2910446f6ab4f890c
236e247631a45e8d41c899d1664c9941cc78661613da945a7a
5ff561e63c53c65432754c03f3513ebfd106ce42db5d49b2d1
0168692541cc4c69b2d0165612e47eb3a5142cf50a96ab6079
0e167ac4323822ddba26dfba2edfba21dfbaa970e67238f343
f9312ae4efba25dfba2ddfba23dfaa5438c65d38469dfc18f7
e4efaa926f55c396ac7c69435b2389b45659bc993c9790e72d
f2a3d5c0a77ad1fc39e9a8352975bb492f4b05ef27fd26359c
4dfa3b129c4bfa29eaf830e911b462105c1716c115167a0cda
76de0cede42d4d960b6029010b1dc13c46d2a0785de44153ee
d37148186f94bd22b94c478930b6c4c3880d563c672637d9ba
6143a2a14da3f6cd5629d6269fc7853c7414ede82dfa4ace33
121e021ea94434e767624f9ef52cba4c8ea3856df0789e7d3f
3acc08d067f41973d8824712d0cf8c12bdd2876ab0f66fce3e
0f4591f46bf06c9e2880decd8b3ef3ace3d11486a5f316501d
cf6e8186c8ef36bfcc233aa81bd12d301ada62554652a2cb50
86a295aee8468e3e0485a2d53c3b5def8d453d9033bd6f5dc1
4e578313d0abbec80acde411bafe868069641a913e1acb2374
1d4925e6367d90fd0c788caee1a1c4e4c3e315d2e231ba1e15
62bef26cc3483d4453fd9467358015e4757936ba061e66ce22
b5262b2d6599b8e26f1a27975ff1827a16413d8ba18665490d
1b416a285aabea41adda154620bb358dadd3f913b23a8bd656
701d8cd43d5461ce2b2e935f05f89bae2b9036050bdf07f5c6
9679b653e06c307f0e1f6e1a81a5db6bf923a5d0f35e05bdec
0dc033e8d1d025f4987ce3b456d0c32e703c27b01f84ab3d37
6557b9e4d62d70b58a446fd4d8740d4b668fc593889d5e9533
54b086e091704d8af81c6614ec53e9bb10fdfda8af0a562bea
5988b47851122a53b01b50af46b6e4bf54c1aa851ae14a1446
b3d18e163bf31955123b5dd17e9b82b50e5d82eb50180d4211
0af6cb88ce476c202c5cc17a148e486a6752ca6d14eca97085
ee3479b7b5827505785626d9aaa657c1e4f65044eb9d04585b
bfc5ea82e868f86286aec650af601f89e85c6aba9edc5305ab
31a2df279d29b8b4e9ca97ccae0d1e46afffe53559e9ef39c2
d513bc8ee42f0bd78255a01cc1ba65743cf1dffa354221de86
b793a3ee8491c23d780f390ffdb579257c041f2551e40a899f
aab88c444611be4162a11aae223149d214d15b7e5f92a64404
712783943c067ebd1e91584347cb4e637a3de826f15c255c49
22a032a4f80ad372f50a7c09ae4321728ea6717ed95563a2bb
40af31b2351ae837d3bc46c5d4bfe9ea38ad6564bf4a990057
99e951301c8585a308e0284a701465380aff37481163d1b49e
670f98fd29205624f34b68135a937622bd4622905d4321cf2f
81b3505b30a49e184d722c5248e754c8aeaebc25b5b733894c
09e8367cd2694df67bc46e851692c7799efd2c890206e87053
d468b66613ab164a459b7856ba22dd57148f16f3ac4bc9f363
b40005f1ac41e4b98cf8a003cf3a953ce7a149c88a67b522cf
bbd0c8a6a8d26c3524cff1c8180de05949ac6716a0764d5166
da7fa59d2c2beddb9a4a3b82d2ce92929a4dcafc15521e95a1
9cab403917e2dba4f489481479067ef237cdc190cfa4a0f578
31e869d02228e3c9a06b405783d256793b68a36930b8d5b056
c318b6d570faa0e587bc1e4e989494bd1b627575a958cafcd1
ca82dd1875a98fd457ea279d2df597064803a541d260698874
8e34541a260d97ce65fe684593c58c3ad9bbf97e10aba63b2b
9ce1be02d9ac722c9d27f501f505f5039d0dea0f1a001a081a
041a0c1a023a073414340c341cf4ff95260d65fc01f423e827
d0cfa05f40bf827ea34aefc0228a4031a808540caa46553916
f4a73f4c93fceaba348f11b03bd85a96faa2ec0e1963799cd6
9616302aec3d8665b7b29fd92af629ff75d35d04f48e9410d8
87b6fcf5191b29bdbfb29a6d6058f125f2de8b64bb917d4ab6
9eb3b964bba6895bfc2b9c9c4bce99e6fb1d56cbcf6acab848
f319ad3f386b344dbbc2f165effcbdf3ff857736a5241a3eff
3fa6c95cfecd16329aec414264fbd23babf6b3dbc9375da7f0
aab1694fda3e92cdd3529216aaabab6ba8b752a7fd163a9b1f
7c461a218d94ce57d764fe689efe5f9945467b3c6799e6995a
74be45b0bc5da8dadc5663e8fcc04ee0c5344502b8e221eb33
9f69da6a6ef3b6f4ac9a7be2b26378c3af35ff7e99c738595c
41e315e84c500fd0d9a0fea001a081a041a073a8927aaa02ae
f957fc9bb3c32218e96fef0fe4dd31425aa562da5b4e004da6
4a525a0e292d879496434acb21a5e590d272486939a4b41c52
5a0e292d879496ffffe3b5c002e610b4439d5037123739d24b
1b44e2aa0de9c54d22717716f2a6b39548ef6f319dcf4462e5
463adf09ed26bdc883e8382a24bd4c983f85eea15af4143590
5eea678cb12ae9c56ae1f65817f790cde0c243e80c2f6c8fa7
907ead3bf6c541381c2fc0513816c791965c12e9bfef202da6
6cd21fcf23d1ee3cbe8caf93c8538deb703d7e85dfe3afac80
d4331aac36abc3eab1faac316bce0e6087b1d6ac2debc04e65
67b29eec6c36848d6017b231ec3276359bc06e6253d95d6c26
7b803dcae6b3c56c095bcade642bd91af631fb82f8c7470123
5016a8095a0bda093a09ba090c049c3c975683ae018d075d0b
ba0e74bd424e6e00dd089a089ad492c338053415340d741be8
76d01da03b417781a683ee06dd039a01ba173413741fe87ed0
2cd06cd01cd003a0b9a007410f811e063d027a14f418e871d0
13a079a027414f83168116839e013d0b7a0ef43ce805d012d0
5f402f835e012d05bd0a5a067a0df43ae80dd09ba0e5a015a0
b7406f83de01ad04bd0b7a0fb40ab41af43e680de803d05ad0
87a075a08fa80a20bf94e782465255b556f04567d0e9a02ea0
33147cd4157416a81ba8bb82ef7a827a817a83fa80fa82fafd
05ff0e060d69f17561286818683828a45c18010ae9276d3eaa
909b62c84d31e4a61872530cb929ce072d002dfc6d2d42da65
e5748e13e833d07ad0e7a02f405f823650fd2fb45165fd1a04
bf72a646d7e3267f4ab881ed20f011f80afce03562647f7484
007b0604f9346deb85c9b6e9afb5ea0d274730d41d1e1a1864
a83b627e6880a1eee8502f7f435d1b2ff750435d5bb7f0a03f
7f079c0bc952c4301d0f330cfc3a1ff9ebb89f8be998a12c34
88b5897d27412a3835a6630a312562844cc49c5059a9b794c5
ed9518ce4d59d45b1909504c3f8c04a98edc44ce50c1a2b3ad
53940e0967f431817167c29860d280f362c2c9ff10fae0ba28
1c4ca0a5b5f6f4d8aed1c5953f2558f6328af16875758bcbbd
d498769e5c8ca0888b61f7a6b21861ac69469298e9a1fde881
f5e45c1d4870262791a796fe4a361709c964270b9435f16447
134dae157da1aa2972720bf3f50bf2090f0e32d1e0a4d4a8a2
a9e2e0e519181ce469d289d3a11691661b3b3f8fd0e0b060ef
70dd11c1a121c1a16ee17e648f2e5c67ca59cd762d7c925fa0
979163b85b6088aefd88e15ca7b612130bae2f6766d2cfc4cc
d4cc99bcecc759ca5f72d1b9ff9194493831e5624d81dd047b
07939e5c77d9cb4e4123fc427cbd4275473a8ed21de5387ec0
08cedadcc88cb3b4301a39cadad2a43bd755f689747ef71339
7a8546f879787131484ff11b464a0c1b83d4196217e1188498
ad5dee2ead0c1d73d1e97df04a1b77ac21593245f3468aeb9c
f2686b2526618f64986d5ddea52fd3da7b0de8f6b0ebaff85c
cad2a8d30e59db4ead7cb5aadfe4122b8ba2c5d7667a9844dc
5ffab5c1c4c28f317f586b3be865ba43065e5b3c2ec877defb
ec9423d39deef7bc6990a2b2e783cb878ffdb486cf58e6991d
f260daaea967638d76fbf91e7e91f8f0b24f9ede9da75bc7e7
de708f8fcc6f637b2a635ceb11fd6e77904efcb0382de5056a
0c19d46a8ec7afbbca225cecb2e7de36dffbabe854dbbcad37
5ebeeba59fb1e1915ea57799d7d0c18f737fce3a5c9592fc8b
ebb962e7b801d3364467ae5ea9ff79d191c84e17578695c577
9cbb68d5e3ecd647c2cd3b497ff93650b7ffca678998f42ed0
f6182424df8812d7917ca51da5026d8156172743f4fc077b5f
bfbba7ecfcf6aeda3b21a19f3b94a18e5d05ed38ed28adaee6
ef6f395887889e0ffb14f129b7777651df5c756e127d436781
1d378e1b933a3a7554ec08dff0f090017dfa788406180736e7
93b14770609f107f3f6aed13121aec39d7233cac8f3c1b692e
42269252694cdec24d5556258ea9a4a48290c0961bcbd934bf
e670eca0a613444646fede09bc42ffc991c3394d9adeee0235
4ed47c4856f5370ec9d252626db1c2192757db4504a90e9ee1
67655c553d4eb269e52493271fd40bab6b72576a9679468eb1
b3cc7789f55af1a16ab86190434651e3e8f706bb3a75d19962
5b7d68b4c3c19ce1c5e2a9adf416e75a283d08efb0ab977597
e817f34b33b206bcaf6cfbce79dcd22de3544c7ddf8ffb79aa
c38f49c39c0c0bc7bd4e7c257a86d78ff43d75f54946a7802a
4b4f53d533ae8fda4e3775b23f7276e18897c290123db580b0
64add953f4beffb04375d7936973b49fb28bb5ae95d89d78d0
b130e7d0b92fc94e1909528f349399ef375e2a118fb77bd868
eaf47edfc0d3fbbed4b2b6f523d77dbbb86ec68ab6736cbef5
ecb578f455498cf3ac228ffae0e0ce81464f33bfe468eedc6e
569ff50d7de56294554835f652568d89dcb47dcda1f6d2f96d
ede50ad58248b8aec7f2f5af0c3dd177da2cc90b93efb8b63c
a3509e5526465c6f991f776bf16387e060524990bcf3f3f6f3
700bf7d21d3e37dc3738d42f7c3eada5b87e9c39a9964cfb9a
71fd492d656a022fcd38faf27f577dfe69459316905375c766
9dc1427fe3efee9fac797026796257fb7d97efb61bdf4dfdc5
d5f4abb6fbc239dd56cf546e4cdad0664c4207ab75fb935cb8
1eb719ffc7df9fac5faea2fe4e2a486a587ea9f345b36e3f6d
7ed5e8a363f8f9fb47cb3a3e7d347e7bdaa9ae8e25ab3e8eba
222c9d99559a6d25d8f66157c07a9f72fd4a6bc7ecd8d287fa
d6c63d3363274c7650ab650d3fcd8e8fe7827e7a3d8ddbfc71
f1cdc4dcc75d1217bf2fd37cad7ac431d0e1e0a8f8ad36ccd8
d1dead7af6f2de9d587b4d397aecb60f4bd35b8dd612c66c5d
fa7cf2bcaf6853477bd51f190dcefaf9917b5dad4f141b4dda
9ad569de7093c84b2955037f589fe6860f7594e47c7e977200
5dd61b37e9db07a5a2d3bae2e68a662ff946d23975ea789a08
7d1328712c7952a8797eb762a131a2a3ba4040ca5f2ca7a12c
6c0ad46d10b5305c7492ac668a8ee7a2574569493363660d9b
d233f16177cdcf06f7458e1ba6d5ee48f3d8e1f61f2f9e311a
f3f769a78d4dddb9cf366c6aa38aa6b117672fab12c770a3b9
51a9235287c70efdeb55a21c879233d2ba0caac3490ad5a10d
67cd8d54a80e2dff95ea907e8e11b2a3fec5aa907cd71a892b
8a5cd89116779f1cdc1779e7f2fc897628c7387ccef44035cd
bd97f3bf5f73d4f87aeb6d7181ee479df0c5f1ba9af6c97717
0cab713a91357593cefd8e2836f3c4bc572b4beb07a21735f9
6b444ae757d9d43438b6b93b61efbada47ab66df883a5597f0
4ab9cf8fec93b506ddf4423ebdfd5c3b2fd958f24ea52624af
ddf8cdabfd45a11b8ea6f5ffd9c7e8cc44e9537797a1da492b
7587d6a8b437fd70c9646c84c9e0dea1e2f34f43067ffb51a4
59755ae4b6baa1fc68db67e3572e39d3b7f7cced05cff21689
adbebfee18dae5055772629e97cb74d456a4252dbbad95f466
d031efa9b9467d1e7df831f6d2c4298f3787240464f6b7bdfe
767e4146bb05eebd5e6e4be965ae1cd9defdc2e04e819d631a
c4e70c4f5c1991fbf043fda2430f76ec0eef7b74fc99395d5b
f788100f72889be36c3d422b2f3737dbcee7fc56ab6f51f3bb
446d69c3793fb66a3db3fdf92d7a5d4a473ce9fde444a3cd25
c3eb15a651b63d0c6cbab93a3f9df272d7bde4cd2503824f46
f70c576ef522a24b414acca99e930ee7cc1ebc3c2dc2ed6050
9ae6ae828cd10dad83bfac300d38f0b56ae2f9b8ae17bc4f6e
eef8536b4f3cd8286bda9aa3b55d1e1eca2ef138386f92d2f5
e1c6f69909d93be7edcd4ddd38b7fdad753f69ced5eb63ba5b
3528757a5cf782d4974b4bbadc7cd669c2854d2fc654bf435e
c1cbc58bcefb9daf0b7a9a9e78d9a4d737e999e92e15761dd2
2a3ef6d932d478b2b6ff05cded5f4828d020a1e0bd428bd673
f4d284d83bc3bfb38498e0a9586ac424262cfe8f54c9fa5c0f
99637656e49e5eba8e7e3e41e4a8b452d635e54c4ca061dbd7
8433b5342561c2dc42d6b03591bfe4a27ff86f346c9bdecefe
c1dbff347eac37be5d513724e95607754f57bbdd53edb406be
5bb0f4f3a05626035e2e3f3dd668f84e9b19775b6f79b9d75b
dffcc62283c9dfdbdaad7855f8eb816b0e6d561ece553dbad2
5e7c77c9a7d9c2d44a1f41f1af557973dbe90ecb9f67983ce5
ee8b37c67787587d70eecced475a2bb2630e4d4cad09f4fafa
ae9d681517683720fdcc6b0ba317ae86a9eb981c1ddb9a8bef
be75ebbea47c4de1ddc4a0cb07da1e3ea73332bd5bc9e2e8ba
3a9363dab7660cb9eafb22ff179bd258c3fd95d22ea70a5714
bde8b07e9ae6dbb303a342db2d73fcb4b7801b921a79d26159
c1828ac7d9ebf7a57588bbbe789786bd46fefdf33a9e1f7f32
fe543cda5bbb70e9f71659aec77f1c1980d58daab3a51db60d
e9de1c3f96906fe47b594bb43b6d89ca6b2b56de7db355450a
f164ea943982869327ccdefce07be95194f53ba7ac323d6e22
c5ad04a42db98354a0bfcd2b33ce84be54d2343033b13037ed
6ddedfcbd2c3ccdbccc8d4ac6f7f23f37ede16466e66ee5e46
161e961ee6fdfa9a7898bb5bf01ac736419e0fed95aec564b4
edd74fef50e0ee92b978c31f378e7fb7b20e0e098360404a0b
29d6a45093f24c8bb32b1523ae9f116709d1c04d211a4ce648
3f56211a8cfad3133407847f728a704e4d1eac31c7fcc6bb21
262cab51f31cd1f1aecbfeb8813f763bb479d8cd93de99d39d
fade6a7c3ca07054b286dd9d83f1b5172326460b1b72d7db35
be695d7bd2a6a75646b051b9ff0fd7cfa6cfff7cad7b07eb92
08bccc74bffda48fec8718746665ae47bbb11e0f73be6a0d54
2bbaf62aeae8a0ee4f661d68987cacb2ef5825a367413e1e79
7df3f3ba7d28bcfba8f825ab67afa574e8d2d68317f4d1dbe9
870b54cdcdd3f70dd4fb14d9f688c1d271fe032785ee7cec16
6415bf26ae607e9ecea38c8d3a5bdb58980cea34d5b59b70d0
0ea17b6733f1cd2fa51b2e4e387edbec58fcbbb854e97def0d
bb933f081246cfbd713c71e416519db712aaebfba6f2ca9a44
afe0fad7671c177a6d9fdb658d8bd1f1f556af9df66c6f95d6
73dcc4a34746cee6be85f7082f5e5eb3a0d84975474c75c8ca
4acd9ee3949c0eaee8fa0585264de1d4b766a294ac51fadd7a
ebbec9e40672ef045d7d0b943b8de74483f1a679391d95d3c7
0f4eebd5d6a2c3d5956ff73f47c7cde31d6db47f11b85bff2a
5afc5070df60a9d6fa0bdbcb1ef77ed07d6db6fa18bb63194e
d2176f2f46d7d62409ce486a5a7f3bbf66539be982cfdb6cb6
7cf8755cdf0b37a26bfd570f93fc20622e2c5e78c42623f0d1
b98cf3fd467aa6721d4e728c8b4f9a7d6fd5b4bb968d12c7ca
9850fb0dcf2b9f6946cedd14d41ab944252dd1d42d1f73dbcf
c774e283eae94b36147e696bb8f7e840d73caffb077ccdb755
cd49bfec77c02dbd6da5d6538e8b5159c0c528b937770fa4f1
65100ad8df8682e865ff91aad694e364756bafbfd2486b890a
26a42b41c240dffeb28e8405bc34e1e8cbff79d48ac1ff180f
308d0798c403e2737b1b3e866ae818efab08ca88d1b0333ffe
eaf0d42e5bad3a18f83f71b6cf38aa6cd95e30e6f89222b54e
77fbf99f6d5d216eb03c9dac9c7dbeff0da46562756db964be
e74f8b1366750bc8da32e6e727be33cbaa521c0f880c8bb26e
ede9bd7f8130ab7ce3b49259ed959e78473c3675e8d1bacfa3
bdaaf65772471e9951516cccceddebfbfa62e0eb012e69da8d
d6c7ab2d3d33833cfbcedb95eaa16e746dd8faf70feea9486e
b8ccdf39a6d723497eaa66647ec2e0979f1ef476d6e86c3745
7fdb82d0ead6038e8c9959f1fcf988b53fdcfafec0f7b11d6e
0dc9899bf178f984a5ed5fa5f599561b3fd068bfd9d4334786
7c35bd96cb0ece3990b5ce7271d9e628c337e3a7acedd2b77b
51ff20cf258ec77f56dff75dd7a5171b8fb3b1abdeb936943a
14c425fc9457d825bcbb6b3bfdc3977aea5b764fea3fd6e2ca
c29c75fb75baa6eff1ae77eb3cfbbefe98cdaecb6abacfb8d6
65dc1087e2434e43bbb10d57174cef73a3eb839019ea13ad23
73df33f7f332718ceb9dc236b9273b5c9f3cee51ff34f5275d
c7e4b53b3a72e1a8da5345a10baa431f75ab2ab04e3ef3f2b4
8ed39d1f56d5db8de1d2f7aeaeaa9fbe35ebf3dd6cef9a5389
d1df3fbff97cdca331bdd235f577a52ff289aa5be13ecff540
9fa5e54e3fbb1444eaebfffa3cb0487f8de19a61fd269cbaff
e3c8e5c542db33d7778ee813bee15dd0fb79ba530d3567ccda
b069c804b3a5b7b397b5bdb7657ce3c6ec3cebd480a4b2ea9b
cbe2e4fda9e7241e3ef99d2e514b00fcdd60f49d7c072d2c50
eb24621c99b98c3b338219ceef6bfd43474d31cc851a0dc026
f1238e69298dbfff34fd9cc9d5aecbcd39675998a323aa1352
ed52c7c58ef997c68088df12af25ce2a8f44ae9c99aba92904
bb990ac1ce81b3e7c62b043babbfd6f5f927c70fe7a2b7d2c4
eb0aa213b9e8042e7aadfc4b32664933911bda7c3a8cb4cdfe
2cb67a067b84914fe617e8163adf2324ccd8373c901b263f00
e6cc3b99ea76646c192fc687716302185726040699fd180f66
3e7915c684133b1d700e24fff48e7463dd8ebf177d7d5ec5ee
4caa9e34bfbdf1b58a701fbd14f1c656f73dd6255b6d5c5436
5f2dfe9497abb1e190f745a157037ff89a3ff4b1a86460c1e8
3ddb5ffbddf128d0ebbb337186d7d2f8452baded2757a8ad5b
58d67e9cceeb41562b1d4ab3bff83f18a262dc2ba56e70879d
d70f758c4ce85ff3c4f3c2c8c1f316747dadb968577cf80fab
1a2ff6c0d606a757689cd8b147492de5b9ef475fe30da90643
0dfca78ef1e82cf40b724eda58fb4363e19ad7d6bdef7d1e58
7ab2efcba0eefb1f66f57c5e7af7b5342b593f31c94e3a58fc
4a75f9cdce45a6ed6a1ace185d9ebee5e098fea2b3a2d367f7
ed7f78e0d69d36cb268e9a6a693aa767fb25398d3ddfdf331c
a0eb977460da72dfa0e0f423e145c39494772103fd21314335
edbcc585b9766feeaf59a213dc66d1a8f48887c30cbcb617cd
70708f2deae86191185b75fbf5fb57da699b7adeff656762e9
8b191ec31f4c57f9f9a721ca91ca579573e676d6ca77733bd4
5079b68320bf6af839a9fe8b7b5e7dea13dfa6b96cac606ea6
599f9cf63a71a7709c8d467254e752a6d7999c949d43474576
ea7bb66cdbb6ad0b16e87db4d9d079efa7d15da3de6c795fe0
7f645c62cdb3b9f3dad73fed973cbfddb86f3773bbfaceadcb
faf879e53371d453bf81599fb9e702dbd5555573033dd60ebe
ba79caf80905514e7a69f35a997659f072b82867e8a7dd9776
cc3895b62cc569ce94f136a30aad2ea4444c1745d9f87f99bf
f5d4c9c0c0d9171cc234250bec7f3189111ce562040731425c
f486ff75e0fafd2e61cbb592d4e84bb4f2692ac442d6444df1
420c4945cb2bb1899453a46db8ae2d3b0a4c48d5c68e8cfcf2
f1e49ba2563d035b3dc8fb74d4416feb702e4061173593999c
4baa41943e63078e154a5c8c5ecbf126eea4cb4c228e469dce
87d8ddc8962f333fcd38ca907a76d8efbab657d0ff4db7b458
3fa4b2203fbd28b120a3525f01ad8e6669626430cd8d9fbfa4
992d2941dc74725b0e9bbdac0563d847ab1a6efdeb05d96e9b
b8c3e6fade6fe4bdf7f416bb89d9ed49ba2cc556295b56b1ef
fa32a52551f485dbe209257377dcdaa3787f569e8a5ce91b06
e77599471cf628d6f4883ac92abf4b2fbdfae34329a3b08dcc
eaba45bbaea4b0d73cc9f59e28a55e2eaefa62e7e79ed993d7
fe6b6bac5ce86c2915a153f0720e8b79f8e72e0d5303b34d09
56f354ee945a1e997ee8597fe4dc151dd7e2abaff645bd34b2
df722370b6d0da25ccc27b936435bc173319db19aad8b6ffb2
beee7de7f572ae98841097904b9e37fd182b152f4cdedee37e
aaabab566886e609666e7d0fadb4808c82a5d5363e530a37f5
d50af4f64c148e4e95baf16c61139306b099a282882b36c326
2651a090203889f60dd8202df60938a4b4196b20819c34b911
13898c40cbe132ac86fc90c9322353434b609a378fc24899d1
266192f57f7902f33ecefd11d771fbb83fa77422da701a28ad
88662f14375e2526b04acdd8a95ea64aecd89ca3b96ff8eb4f
4597fd2cdc193757474fe761f1baf5d28f041f979ffe3835a3
574761da867c19d66d2c7703851cf4bd3e70d6d97f4bd42fb8
da38bf4bca37ef6b9e03d3c6f57c53e674b5ad7f79c8317926
d38235fbcc1617375edaae966b59af1510c0f2bd71c1c54b19
2c817c1ef5fd3fdb1ded55941fdd123d7be899a956a2f8d956
495b65a3ac8469b20b536ff548046f8ddfc936e1d5f6e3b57f
172ff9b52ed0797230dfa16e4e37dda5a5ab229e2e3ab13eee
c0c34f47d8b774784c09cfff1dd77cdfad596186e585796fa7
ecdb5474a1a1e7ef8a62e669eebbf9051efe9c304b3b47845b
2539bbe4966b5040ce5a2bb9bed7a5b541e9b31918007af725
870a656e6473747265616d0a656e646f626a0a38322030206f
626a0a3c3c0a2f54797065202f466f6e744465736372697074
6f720a2f466f6e744e616d65202f54696d65732332304e6577
233230526f6d616e0a2f466c6167732033320a2f4974616c69
63416e676c6520300a2f417363656e74203839310a2f446573
63656e74202d3231360a2f436170486569676874203639330a
2f4176675769647468203430310a2f4d617857696474682032
3631340a2f466f6e74576569676874203430300a2f58486569
676874203235300a2f4c656164696e672034320a2f5374656d
562034300a2f466f6e7442426f78205b2d353638202d323136
2032303436203639335d0a2f466f6e7446696c653220383320
3020520a3e3e0a656e646f626a0a38342030206f626a0a5b30
205b3737385d2033205b3235305d203131205b333333203333
335d203135205b323530203333332032353020323738203530
30203530302035303020353030203530302035303020353030
20353030203530302035303020323738203237385d20333620
5b3732325d203338205b363637203732322036313120353536
20373232203732322033333320333839203732322036313120
3838392037323220373232203535365d203534205b35353620
36313120373232203732325d203631205b3631315d20363820
5b343434203530302034343420353030203434342033333320
3530302035303020323738203237385d203739205b32373820
37373820353030203530302035303020353030203333332033
38392032373820353030203530305d203931205b3530302035
3030203434345d20313035205b3434345d20313039205b3434
345d20313131205b343434203434345d20313134205b343434
5d20313136205b3237385d20313231205b3530305d20313233
205b3530305d20313235205b353030203530305d2031333820
5b3736305d20313739205b343434203434345d20343034205b
3630345d5d0a656e646f626a0a38302030206f626a0a3c3c0a
2f42617365466f6e74202f54696d65732332304e6577233230
526f6d616e0a2f53756274797065202f434944466f6e745479
7065320a2f54797065202f466f6e740a2f434944546f474944
4d6170202f4964656e746974790a2f445720313030300a2f43
494453797374656d496e666f203831203020520a2f466f6e74
44657363726970746f72203832203020520a2f572038342030
20520a3e3e0a656e646f626a0a37392030206f626a0a5b3830
203020525d0a656e646f626a0a38352030206f626a0a3c3c0a
2f46696c746572202f466c6174654465636f64650a2f4c656e
677468203332370a3e3e0a73747265616d0a789c7d52cb6ac3
3010bceb2b746c0fc192ed88048c21711af0a10feaf6031c69
9d1a6a59c8cac17f5f7965923481086c18edccec88dda82877
a56e1d8d3e6c2f2b70b469b5b230f4272b811ee0d86ac20555
ad7433c2bfec6a43222faec6c14157eaa6275946a34f5f1c9c
1de9d346f5077826d1bb55605b7da44fdf45e5717532e6173a
d08e3292e75441e38d5e6bf356774023942d4ae5ebad1b175e
73617c8d06688c988730b25730985a82adf51148c6fcc969b6
f72727a0d54d7d561d1af9535b64279ecd58cc903ddf9f5917
d32dd25811d8ab991deae2d694f3407bc911ad112522a0e094
ac02da05b4419484304b86284d1109fe385a2a9096862e22f9
17edeebd697881585f9bc6f7a6fb9064362d30d036c4db4eb9
62c68b879df81a69cb627fdd699ac8b438e771cb93b57ed2b8
5d38e269b8ad86f3029ade4caae9fb03331ccadd0a656e6473
747265616d0a656e646f626a0a37382030206f626a0a3c3c0a
2f54797065202f466f6e740a2f53756274797065202f547970
65300a2f42617365466f6e74202f54696d65732332304e6577
233230526f6d616e0a2f456e636f64696e67202f4964656e74
6974792d480a2f44657363656e64616e74466f6e7473203739
203020520a2f546f556e69636f6465203835203020520a3e3e
0a656e646f626a0a38372030206f626a0a3c3c0a2f54797065
202f466f6e7444657363726970746f720a2f466f6e744e616d
65202f417269616c0a2f466c6167732033320a2f4974616c69
63416e676c6520300a2f417363656e74203930350a2f446573
63656e74202d3231300a2f436170486569676874203732380a
2f4176675769647468203434310a2f4d617857696474682032
3636350a2f466f6e74576569676874203430300a2f58486569
676874203235300a2f4c656164696e672033330a2f5374656d
562034340a2f466f6e7442426f78205b2d363635202d323130
2032303030203732385d0a3e3e0a656e646f626a0a38382030
206f626a0a5b3237385d0a656e646f626a0a38362030206f62
6a0a3c3c0a2f54797065202f466f6e740a2f53756274797065
202f54727565547970650a2f4e616d65202f46350a2f426173
65466f6e74202f417269616c0a2f456e636f64696e67202f57
696e416e7369456e636f64696e670a2f466f6e744465736372
6970746f72203837203020520a2f4669727374436861722033
320a2f4c617374436861722033320a2f576964746873203838
203020520a3e3e0a656e646f626a0a38392030206f626a0a3c
3c0a2f46696c746572202f466c6174654465636f64650a2f4c
656e67746820323338310a3e3e0a73747265616d0a789cc55b
4b8f1b3712be0bd07fe8637710719a8f7e610d0389278f5dac
137b63ec021bef613cd2c80dc8d2644632b2f951f951c921c8
c127df72daaa229ba4bad97a77163646fd28b28ac5e2570fb2
7f188f0ac1aa5245852a5856462a4b595e443c6769193dccc6
a37f7d122dc7a3e8ea45f4e4c9d5f3677fbd8ed2a74fa3cfaf
9f453f1cd8f6f357e3d1d5973ce29255227a75371ef128857f
3c2aa09982e6d0ae52d1ab7740f7d57745347f1c8fd2684e77
a5b9fb6a3cfa3e7e97f02a9e2513194f9309cfe3cde226828b
34fef8984c8a98fed0eb1bfcc392ff44affe361e7d01fc5f8e
47e78bcb33202d7c71494a235cd461f792fe475f3c7f16f9fa
e3467f1c1b8348a9009172c9f23c828ef3282761ee3e31dd5b
8a92159a80fe3434cd98e8b519d21601b1c904f5efb14953d1
e664891a4e48d3edab114809983dfd5e70c685a56afa7104d8
d1360d69c54d49a9a84f237f9e414bde637ea2637e7b1adb09
adfaec8f974ceaf9649cf45ba82ad2d70ff3d0d37fd08c7f5d
3f26325e7f4c262a7e408babd11c65fcfc7763a2595cdfe2a3
2c7e914c2a4d339b27867af6f8986460aa3d567af2a84459b2
fce441b5ccd8ce53c9b25445422956829da9946515c8563110
313c4fd29ba7831aeb1109b320fd119592a5b98a721898283a
0bef3ac9e35532c9f5d25f827a7f4b38470cc8e3c7689a0050
d075844f6b9c8d25e2c81d4ec92ff8826e6f6902932a342167
8a2f708e7ac50f29dcd7a33a4d8f2a046029676915e5b0c039
6f0bf224e5957a7aced8b320cb8aa93e9601cc3c865f10a341
d7bd438caf6738fde42768be57cbb709373e831ed015acd832
5ecf1e92e6127c8c02db002b99aefc27774919af3ec507f494
fa25d7f3400b7b2238b82c59c4f7964864f17be468a8266091
1facf5cda8c502efe9fda7444f5d63871b6cf886b06545ee6f
8bd2c8706ff9af8c905327fd7aa6dda56e4efd0d3703aa62b9
eccc40a31590a69e4fe18e97f1a24e8400e11e7145d228a66e
1e702874774f7fbdb9f80def7f2575045cfd99a31059893142
cf28f6add9ecb4351b12a4c13e89207db420f9e505e1e0338e
d74871716f90019c965d8d7cbb0177b006a3793081203a81eb
04ccccf7118df9e8f717477c5e098c147b44dca7abf2e2889f
011c561dd73328e287590e87373dfcbe21c49f5bccd518fc96
0044238a46e1f58ca06889841eb010045948459f30e152c3cf
8d436b07bf3a2fa92d30bfd1a0a5a1cd7302e4160cde2f2062
a911d744bc2117d246f3f56a8100a9517bee3a27925b9befa0
849aff074be2de9a4e87d23e44a9aa6be9f79b05e135e1bd96
7f69a602468e02bbb15aa0f728b6b48bf366bdb5d10cf54ec3
f51c831b3475bce5edb6ef7523e3ad8319e399ea914230c830
7ad4b30f08aacb0381841ff1e7024190e580a618e6f7025699
594d34e90b6792f30fdb4b6a45ab703d5bdd2076187cf0cdeb
e2c106387710b947f28d8bf3d0526d8004eb636ed6035c2eed
d270c1a711fafdf6f05ec74070eb85919ba54fd084a833877a
6f081b5dbf24d0ebc41746eae8d70bdcb416e952a5c3cd3617
2c18651a1cd1525c7e6173050946d6c37edfbae6e9c5c33205
1147991f2f09bfbc2485646aef7aef4a222e1e21aa8cb3b22b
c967494e558275e3705ce63785c7b68aa0dfc3daa7a2ceb324
d7c5038a2bffc0154057f3a4d0cf6f917475f9e28104432bfb
c6b257ab27566176b81005289577ca9f83ba9030cbe15c480f
bf6f1028b3edf002d0f22e110d94927f686a014299941d48a5
1ff175eb090e9c971ea2bfdd50a7ef5ae85c2f752eaf63d1f7
1efcb7035753d3d2a60ad6f987fe9987a22407dccb0d75167a
6f1c23b903e724869b0778c3bba0562fd7cd3ad5035adaf07e
3a4029801719965e7b84d9bb024facdfed40585949569c8005
97af4ac842b174efc2ec4a7262596207d6cb4c84bc0e62fd02
d1d9580b5a3fa6fcbad03b4cee2f2b4c447b04daab9a130b25
3b005b4ac1b23f15af831c87838930bbef34463435d8066711
2bd7b35b6b133a625dfad54742128a717f77186341133ab0a1
ad97c94b3ff7b7d859da3dcb06a3d7d858197fd14af71de3da
a4cdd6672cd737588f76281c4e6d37eb87a41c2ce8cdd0a08a
c3a6b76bd92796b576c10f44dfa7044527e6d53b241100c9b2
3c5a12716222b0030845c159d195e49f89d905333141b30b36
1808164cca3e61f6aae5c4ac6407080a8c9f3b99daa0281866
391c0cf6f07b4195c5852b59eabc58a3978b9c34b2d5c142dd
c286b55e7effbeddd455118205541df56ebc5e69dbe7271b66
6afc1c2080934ab05c1c381f648c2f5b470e9adcb43930902a
dc5d0c9ed668282a2c0f34c735b2aaaadc890d3d1c436286d3
26d2a7366062b9cf2d7468c3d0587ee6d046b737239a80f804
d440a2a95c3151ba831bd49747807db5685a0702384f99b2a3
e08260b0e7e0463717ddd37a3fd8f18255c7d7554537263f57
125e65acea6e387f5d93c35e03fa7e4c0a734aa4893df56111
ef4c93f22a0944f12e11c576418236b11e4df39e8572d05824
bc4013d8def454ac2ac363017b4853256165dd7e1fbf8edfde
bca9d79b9b45b3473e85f809f3d919dd014b8c4038a71f91a6
d9ebe4e2d22a4076c1fb34bfd706bad9d04192ecf03198281e
b9cb7610cb1d3e26ccf24cd3d8e1637af87d4b15012f5cbdb7
7b2a3fb5ce2bb812b4484d61049eceafbc630ada3d507df92f
171f88c0d37b07eaad6b34ddc4f56ca3c972263a1036acd104
590e6834617e9f2d281021d3b877898c4eb7eaa5b74dd3d80c
bef837a669fff5766f0cbd4dbb7e06c329b69ac8347585b4f9
15f5dbdea81dc8daa4e058aa394ce35d73eb1603ce363799b3
f2b86ac0d9e6166439a0b985f97d091e744307a39a73c2f620
d2d41c2336f6f2f7c484acba885bff88443fc3abccdbf47238
a6fe7fd685f9af3a50c15debea26e4675b17c463eab8938567
5b5790e580d615e607811e60d7d4205266b0e9c77a83f59899
cbad5adbb059ea3b417a5e5e95989b497dd861651da9abfadc
afdc3ef096a1355eb337853addd294c44acb61ca0ea6504dcd
25dd4a45a44d45f2767e841b5f2eddd3194dde4955a49faab4
0faa6b2e3ccd5068e2c245895559cbaaa150a8162f5bcb8f22
31cad5243b05f66441815be234349695cbe5ba1ded24ea2c76
d9fd6ae3d003e67d9f6d54292bf2bdc59d10f248be650ce67b
0240b1e67b82eee70d8a7b9f6ce851f3ce0707ae8790351836
2575a8d9643092cce76528f0c77e6a817d1d47421297be76db
448dc44e1892785b1e47d4306b3ec80877b58b8ae6e07f1ba9
3c600a656e6473747265616d0a656e646f626a0a362030206f
626a0a3c3c0a2f54797065202f506167650a2f4d6564696142
6f78205b302030203539352e3434203834312e36385d0a2f52
65736f7572636573203c3c0a2f466f6e74203c3c0a2f463120
38203020520a2f4632203131203020520a2f46342037382030
20520a2f4635203836203020520a2f4633203134203020520a
3e3e0a2f457874475374617465203c3c0a2f47533720313720
3020520a2f475338203138203020520a3e3e0a2f50726f6353
6574205b2f504446202f54657874202f496d61676542202f49
6d61676543202f496d616765495d0a3e3e0a2f436f6e74656e
7473203839203020520a2f47726f7570203c3c0a2f54797065
202f47726f75700a2f53202f5472616e73706172656e63790a
2f4353202f4465766963655247420a3e3e0a2f54616273202f
530a2f537472756374506172656e747320310a2f506172656e
742032203020520a3e3e0a656e646f626a0a3134392030206f
626a0a3c3c0a2f46696c746572202f466c6174654465636f64
650a2f4c656e67746820313535380a3e3e0a73747265616d0a
789cbd594b6f1b3710be0bd07fe07137a8367c2e97adb1402d
c7690bb8481a173d343d3891ec08b02dc792fa7f839c7aeead
a70e87dc25b54bf911af6cc3321fc3996fc87991fa3c1e695e
984a12599a4255442a5a949a70230baac9ed7c3cfae305b91e
8fc8cb37e4e0e0e5c9f4e72342eb9a1c1e4dc9e7872e3e3c1d
8f5e1e33c2446138393d1f8f18a1f0cb88d685929268586824
39bd02bad7ef34b9588d47945c60aff2bdd7e3d19f19c9ff22
a7bf8c47af80e35b40f5ea644a6268ecdba071c2ca82564968
dc14c24143441ec84f8b7c22b2d53a2fb37f739ddddade2237
d9593e290125f4dee5cc644bdbfd983306931305b33abbb40d
a498db716cbdc999743c9640719e4f0c325bad169604995ce7
325ebeb50d8fd4561006d4e596b65c5785e2bbb4bd6fdbf9b7
6dbb4c588451852a2ba2a92998ea0239a0ccc8fa29baab8448
466148ef10f9c4bd4e193d8321b553de493ed1d9f236b7d602
0601f6518105a1694c58995de542bbc1669a2bb018952d2ec1
423ee54cc71357d608a1cfad0142736599bba9bf2de91ca72e
3f7932917d6739237b37d51177839f16dcdab64a27c0915e5b
866b0029b3655871b9b9081866cbc03fa913c7cfcf38ba6975
41798e312ae099ece95c4a830bbbe792c4ebf7cf6f82f0282d
5eec7e0c3b3f434d66f3ed4dfe62bb179bf8d42a4f84cd9653
3476f3df074471b9c83977b0c2da40863b759633e10e66eee9
f04cc399aded51a9ec0302c12588d6295bb4387f058955b641
4eb1c47d1d01f061a67704ed6e04a033dc8ac5c6b6832f74dc
27dabc77e0245f5139ecbec1a86a7762838718d9a7a5b4d3c5
e04af28a1690597628795fac1583c7da52f1423f6fac4d8bdc
a341a5e54df309c494c6aaad276f1670e4e88fce9a96c1ab90
0c2c8fcb6c718dc68273adebd8f1beef008f63eba72e722cbc
9d56d9f266de84b62f281ad23ff3b162d95832f78ef6219a3c
0b212744d9f53fd066d4c7471c576598be1e7c5fa5a48510bb
f6752b4cb799c042760172b3ed9f5ba9e629485346de588090
05ef45f5034a9584bfaa661adab2aa2702fe53514f2a3b57d6
93e4b8aa951fe6cc364ccdedbce23837e148446b6670b086a3
3f08525a2ea25da1a2e143e1b92aed4430cf4d685cd470e361
892c1dbe20aa91dd50cb6337d0686279371c5015ddd7b2e12a
a55fd3ec86ef1fca6d7a7a887ab464532fd2b3a1539c66ec49
4125698c5049895d477c6f4095835f674a26adc93d16881a1c
888208cfc4a3819483dfa2940627ec03f93177179b75543009
5ff0c0b00fbbd2779adbd2b1bd2de145eb2ae7daddacf05ad4
deb16e9f5e9d242f4942146ca732f7edaa1e3c712b25acdd3f
67e24e8bdc5fe2de210f2f495f5b63f93e2effb88873e49659
d93acfe7769f94a284a9699c3081cacdfd8005b2cbf5b3a533
c9f5dca55b248bca495f73db8c1dd27da738479a9b006b719e
57d9e2e3999562d3e2d6ddae8aaaed8daf3fbc84e1eb52a92b
1b3f1f76c43df3ae86376f7037d3f3b3fd9a7752e4feaa925d
2a52216ae953adab30a690398f6ace7dbee52a2a3b025527cb
b719bc2954ba25489bda79c8dbcd1c33f07798a0658e476a4d
5c4628e360cb6ea9d1291bda7aa745eb0b075f1735ff78bf1e
7b44058212f65782884a59a77998fdf47cc70cef3b5082c8f2
797d2729728fa9212def777caa689e6820232c6eed7b2a3e7a
44a13a7a1328e51d81bff3ecd53c9bccbd94ceeb97cf0b214a
63d09eb91b5efce266170e1fc18536057be041f4dfcebff15d
ff0e2b94b04257cf6a856991fbb3c21df28ee0e0bdf1ac8617
2db92deb9f4f55a9eed8da6328ce3b8fcfa1a87a9f81d344be
2655e79952a6abaef779530a05d259e7593848092f9cebb395
f5f620db74e5dd232eedefceb977fafcbe6c4b97453f99dc1b
5cfc4bffe0a0caca92a641a582cbdbedaf0d59f3e51cb3eb00
0de592e852146549a8bd6a9508e3fc85e7dc5254857604f8d1
d07875dcb4d7668b00c5288efc233194f2aea496a8916469fa
bc3c2059c2ed5eba796e20e0b21893a310768b1bccca18f348
127750223aa82e91c71c81b1a03b785aa25698d72ccdea4eaa
7ebe88bef5a305b53f55a505d88a7d76804b7f255901492061
5ba6f75ee17705024df3f563c1706bb434c4b56f2f52a3bfed
34bfff0147921f1d0a656e6473747265616d0a656e646f626a
0a372030206f626a0a3c3c0a2f54797065202f506167650a2f
4d65646961426f78205b302030203539352e3434203834312e
36385d0a2f5265736f7572636573203c3c0a2f466f6e74203c
3c0a2f46312038203020520a2f4632203131203020520a2f46
33203134203020520a2f4634203738203020520a2f46352038
36203020520a3e3e0a2f457874475374617465203c3c0a2f47
5337203137203020520a2f475338203138203020520a3e3e0a
2f50726f63536574205b2f504446202f54657874202f496d61
676542202f496d61676543202f496d616765495d0a3e3e0a2f
436f6e74656e747320313439203020520a2f47726f7570203c
3c0a2f54797065202f47726f75700a2f53202f5472616e7370
6172656e63790a2f4353202f4465766963655247420a3e3e0a
2f54616273202f530a2f537472756374506172656e74732032
0a2f506172656e742032203020520a3e3e0a656e646f626a0a
32312030206f626a0a3c3c0a2f53202f500a2f54797065202f
537472756374456c656d0a2f4b205b305d0a2f502032322030
20520a2f50672035203020520a3e3e0a656e646f626a0a3233
2030206f626a0a3c3c0a2f53202f500a2f54797065202f5374
72756374456c656d0a2f4b205b315d0a2f5020323220302052
0a2f50672035203020520a3e3e0a656e646f626a0a32342030
206f626a0a3c3c0a2f53202f500a2f54797065202f53747275
6374456c656d0a2f4b205b325d0a2f50203232203020520a2f
50672035203020520a3e3e0a656e646f626a0a32352030206f
626a0a3c3c0a2f53202f500a2f54797065202f537472756374
456c656d0a2f4b205b335d0a2f50203232203020520a2f5067
2035203020520a3e3e0a656e646f626a0a32362030206f626a
0a3c3c0a2f53202f5370616e0a2f54797065202f5374727563
74456c656d0a2f4b205b345d0a2f50203237203020520a2f50
672035203020520a3e3e0a656e646f626a0a33312030206f62
6a0a3c3c0a2f53202f500a2f54797065202f53747275637445
6c656d0a2f4b205b35203620375d0a2f50203237203020520a
2f50672035203020520a3e3e0a656e646f626a0a3332203020
6f626a0a3c3c0a2f53202f500a2f54797065202f5374727563
74456c656d0a2f4b205b3820392031305d0a2f502032372030
20520a2f50672035203020520a3e3e0a656e646f626a0a3333
2030206f626a0a3c3c0a2f53202f500a2f54797065202f5374
72756374456c656d0a2f4b205b31312031325d0a2f50203237
203020520a2f50672035203020520a3e3e0a656e646f626a0a
33342030206f626a0a3c3c0a2f53202f500a2f54797065202f
537472756374456c656d0a2f4b205b31332031342031355d0a
2f50203237203020520a2f50672035203020520a3e3e0a656e
646f626a0a33352030206f626a0a3c3c0a2f53202f500a2f54
797065202f537472756374456c656d0a2f4b205b3136203137
2031382031392032305d0a2f50203237203020520a2f506720
35203020520a3e3e0a656e646f626a0a33362030206f626a0a
3c3c0a2f53202f500a2f54797065202f537472756374456c65
6d0a2f4b205b32312032325d0a2f50203237203020520a2f50
672035203020520a3e3e0a656e646f626a0a33372030206f62
6a0a3c3c0a2f53202f500a2f54797065202f53747275637445
6c656d0a2f4b205b32332032342032355d0a2f502032372030
20520a2f50672035203020520a3e3e0a656e646f626a0a3338
2030206f626a0a3c3c0a2f53202f500a2f54797065202f5374
72756374456c656d0a2f4b205b32362032372032385d0a2f50
203237203020520a2f50672035203020520a3e3e0a656e646f
626a0a33392030206f626a0a3c3c0a2f53202f500a2f547970
65202f537472756374456c656d0a2f4b205b32392033302033
315d0a2f50203237203020520a2f50672035203020520a3e3e
0a656e646f626a0a32372030206f626a0a3c3c0a2f53202f54
440a2f54797065202f537472756374456c656d0a2f4b205b32
36203020522033312030205220333220302052203333203020
52203334203020522033352030205220333620302052203337
2030205220333820302052203339203020525d0a2f50203238
203020520a3e3e0a656e646f626a0a35312030206f626a0a3c
3c0a2f53202f5370616e0a2f54797065202f53747275637445
6c656d0a2f4b205b35375d0a2f50203238203020520a2f5067
2035203020520a3e3e0a656e646f626a0a34302030206f626a
0a3c3c0a2f53202f5370616e0a2f54797065202f5374727563
74456c656d0a2f4b205b33325d0a2f50203431203020520a2f
50672035203020520a3e3e0a656e646f626a0a34322030206f
626a0a3c3c0a2f53202f500a2f54797065202f537472756374
456c656d0a2f4b205b33332033345d0a2f5020343120302052
0a2f50672035203020520a3e3e0a656e646f626a0a34332030
206f626a0a3c3c0a2f53202f500a2f54797065202f53747275
6374456c656d0a2f4b205b33352033362033375d0a2f502034
31203020520a2f50672035203020520a3e3e0a656e646f626a
0a34342030206f626a0a3c3c0a2f53202f500a2f5479706520
2f537472756374456c656d0a2f4b205b33382033392034305d
0a2f50203431203020520a2f50672035203020520a3e3e0a65
6e646f626a0a34352030206f626a0a3c3c0a2f53202f500a2f
54797065202f537472756374456c656d0a2f4b205b34312034
325d0a2f50203431203020520a2f50672035203020520a3e3e
0a656e646f626a0a34362030206f626a0a3c3c0a2f53202f50
0a2f54797065202f537472756374456c656d0a2f4b205b3433
2034342034355d0a2f50203431203020520a2f506720352030
20520a3e3e0a656e646f626a0a34372030206f626a0a3c3c0a
2f53202f500a2f54797065202f537472756374456c656d0a2f
4b205b34362034372034385d0a2f50203431203020520a2f50
672035203020520a3e3e0a656e646f626a0a34382030206f62
6a0a3c3c0a2f53202f500a2f54797065202f53747275637445
6c656d0a2f4b205b34392035305d0a2f50203431203020520a
2f50672035203020520a3e3e0a656e646f626a0a3439203020
6f626a0a3c3c0a2f53202f500a2f54797065202f5374727563
74456c656d0a2f4b205b35312035322035335d0a2f50203431
203020520a2f50672035203020520a3e3e0a656e646f626a0a
35302030206f626a0a3c3c0a2f53202f500a2f54797065202f
537472756374456c656d0a2f4b205b35342035352035365d0a
2f50203431203020520a2f50672035203020520a3e3e0a656e
646f626a0a34312030206f626a0a3c3c0a2f53202f54440a2f
54797065202f537472756374456c656d0a2f4b205b34302030
20522034322030205220343320302052203434203020522034
35203020522034362030205220343720302052203438203020
5220343920302052203530203020525d0a2f50203238203020
520a3e3e0a656e646f626a0a32382030206f626a0a3c3c0a2f
53202f54520a2f54797065202f537472756374456c656d0a2f
4b205b35312030205220323720302052203431203020525d0a
2f50203239203020520a3e3e0a656e646f626a0a3239203020
6f626a0a3c3c0a2f53202f54426f64790a2f54797065202f53
7472756374456c656d0a2f4b205b3238203020525d0a2f5020
3330203020520a3e3e0a656e646f626a0a35322030206f626a
0a3c3c0a2f53202f500a2f54797065202f537472756374456c
656d0a2f4b205b35385d0a2f50203232203020520a2f506720
35203020520a3e3e0a656e646f626a0a35332030206f626a0a
3c3c0a2f53202f500a2f54797065202f537472756374456c65
6d0a2f4b205b35395d0a2f50203232203020520a2f50672035
203020520a3e3e0a656e646f626a0a35342030206f626a0a3c
3c0a2f53202f500a2f54797065202f537472756374456c656d
0a2f4b205b36305d0a2f50203535203020520a2f5067203520
3020520a3e3e0a656e646f626a0a35392030206f626a0a3c3c
0a2f53202f500a2f54797065202f537472756374456c656d0a
2f4b205b36315d0a2f50203535203020520a2f506720352030
20520a3e3e0a656e646f626a0a36302030206f626a0a3c3c0a
2f53202f500a2f54797065202f537472756374456c656d0a2f
4b205b36325d0a2f50203535203020520a2f50672035203020
520a3e3e0a656e646f626a0a36312030206f626a0a3c3c0a2f
53202f500a2f54797065202f537472756374456c656d0a2f4b
205b36335d0a2f50203535203020520a2f5067203520302052
0a3e3e0a656e646f626a0a35352030206f626a0a3c3c0a2f53
202f54440a2f54797065202f537472756374456c656d0a2f4b
205b3534203020522035392030205220363020302052203631
203020525d0a2f50203536203020520a3e3e0a656e646f626a
0a36352030206f626a0a3c3c0a2f53202f5370616e0a2f5479
7065202f537472756374456c656d0a2f4b205b36365d0a2f50
203536203020520a2f50672035203020520a3e3e0a656e646f
626a0a36322030206f626a0a3c3c0a2f53202f500a2f547970
65202f537472756374456c656d0a2f4b205b36345d0a2f5020
3633203020520a2f50672035203020520a3e3e0a656e646f62
6a0a36342030206f626a0a3c3c0a2f53202f500a2f54797065
202f537472756374456c656d0a2f4b205b36355d0a2f502036
33203020520a2f50672035203020520a3e3e0a656e646f626a
0a36332030206f626a0a3c3c0a2f53202f54440a2f54797065
202f537472756374456c656d0a2f4b205b3632203020522036
34203020525d0a2f50203536203020520a3e3e0a656e646f62
6a0a35362030206f626a0a3c3c0a2f53202f54520a2f547970
65202f537472756374456c656d0a2f4b205b36352030205220
353520302052203633203020525d0a2f50203537203020520a
3e3e0a656e646f626a0a35372030206f626a0a3c3c0a2f5320
2f54426f64790a2f54797065202f537472756374456c656d0a
2f4b205b3536203020525d0a2f50203538203020520a3e3e0a
656e646f626a0a36362030206f626a0a3c3c0a2f53202f500a
2f54797065202f537472756374456c656d0a2f4b205b36375d
0a2f50203232203020520a2f50672035203020520a3e3e0a65
6e646f626a0a36372030206f626a0a3c3c0a2f53202f500a2f
54797065202f537472756374456c656d0a2f4b205b36385d0a
2f50203232203020520a2f50672035203020520a3e3e0a656e
646f626a0a36382030206f626a0a3c3c0a2f53202f500a2f54
797065202f537472756374456c656d0a2f4b205b36395d0a2f
50203639203020520a2f50672035203020520a3e3e0a656e64
6f626a0a37332030206f626a0a3c3c0a2f53202f500a2f5479
7065202f537472756374456c656d0a2f4b205b37305d0a2f50
203639203020520a2f50672035203020520a3e3e0a656e646f
626a0a37342030206f626a0a3c3c0a2f53202f500a2f547970
65202f537472756374456c656d0a2f4b205b37315d0a2f5020
3639203020520a2f50672035203020520a3e3e0a656e646f62
6a0a36392030206f626a0a3c3c0a2f53202f54440a2f547970
65202f537472756374456c656d0a2f4b205b36382030205220
373320302052203734203020525d0a2f50203730203020520a
3e3e0a656e646f626a0a37352030206f626a0a3c3c0a2f5320
2f5370616e0a2f54797065202f537472756374456c656d0a2f
4b205b37325d0a2f50203730203020520a2f50672035203020
520a3e3e0a656e646f626a0a37302030206f626a0a3c3c0a2f
53202f54520a2f54797065202f537472756374456c656d0a2f
4b205b373520302052203639203020525d0a2f502037312030
20520a3e3e0a656e646f626a0a37312030206f626a0a3c3c0a
2f53202f54426f64790a2f54797065202f537472756374456c
656d0a2f4b205b3730203020525d0a2f50203732203020520a
3e3e0a656e646f626a0a37362030206f626a0a3c3c0a2f5320
2f4669677572650a2f54797065202f537472756374456c656d
0a2f4b205b37335d0a2f50203232203020520a2f5067203520
3020520a3e3e0a656e646f626a0a39302030206f626a0a3c3c
0a2f53202f500a2f54797065202f537472756374456c656d0a
2f4b205b305d0a2f50203931203020520a2f50672036203020
520a3e3e0a656e646f626a0a39312030206f626a0a3c3c0a2f
53202f54440a2f54797065202f537472756374456c656d0a2f
4b205b3930203020525d0a2f50203932203020520a3e3e0a65
6e646f626a0a39352030206f626a0a3c3c0a2f53202f537061
6e0a2f54797065202f537472756374456c656d0a2f4b205b31
5d0a2f50203932203020520a2f50672036203020520a3e3e0a
656e646f626a0a39322030206f626a0a3c3c0a2f53202f5452
0a2f54797065202f537472756374456c656d0a2f4b205b3935
20302052203931203020525d0a2f50203933203020520a3e3e
0a656e646f626a0a3134382030206f626a0a3c3c0a2f53202f
5370616e0a2f54797065202f537472756374456c656d0a2f4b
205b33315d0a2f50203938203020520a2f5067203620302052
0a3e3e0a656e646f626a0a39362030206f626a0a3c3c0a2f53
202f500a2f54797065202f537472756374456c656d0a2f4b20
5b325d0a2f50203937203020520a2f50672036203020520a3e
3e0a656e646f626a0a3133322030206f626a0a3c3c0a2f5320
2f5370616e0a2f54797065202f537472756374456c656d0a2f
4b205b32325d0a2f5020313031203020520a2f506720362030
20520a3e3e0a656e646f626a0a39392030206f626a0a3c3c0a
2f53202f500a2f54797065202f537472756374456c656d0a2f
4b205b335d0a2f5020313030203020520a2f50672036203020
520a3e3e0a656e646f626a0a3130332030206f626a0a3c3c0a
2f53202f4c426f64790a2f54797065202f537472756374456c
656d0a2f4b205b345d0a2f5020313034203020520a2f506720
36203020520a3e3e0a656e646f626a0a3130342030206f626a
0a3c3c0a2f53202f4c490a2f54797065202f53747275637445
6c656d0a2f4b205b313033203020525d0a2f50203130352030
20520a3e3e0a656e646f626a0a3130352030206f626a0a3c3c
0a2f53202f4c0a2f54797065202f537472756374456c656d0a
2f4b205b313034203020525d0a2f5020313030203020520a3e
3e0a656e646f626a0a3130362030206f626a0a3c3c0a2f5320
2f500a2f54797065202f537472756374456c656d0a2f4b205b
355d0a2f5020313030203020520a2f50672036203020520a3e
3e0a656e646f626a0a3130372030206f626a0a3c3c0a2f5320
2f500a2f54797065202f537472756374456c656d0a2f4b205b
365d0a2f5020313030203020520a2f50672036203020520a3e
3e0a656e646f626a0a3130382030206f626a0a3c3c0a2f5320
2f500a2f54797065202f537472756374456c656d0a2f4b205b
375d0a2f5020313030203020520a2f50672036203020520a3e
3e0a656e646f626a0a3130392030206f626a0a3c3c0a2f5320
2f4c426f64790a2f54797065202f537472756374456c656d0a
2f4b205b385d0a2f5020313130203020520a2f506720362030
20520a3e3e0a656e646f626a0a3131302030206f626a0a3c3c
0a2f53202f4c490a2f54797065202f537472756374456c656d
0a2f4b205b313039203020525d0a2f5020313131203020520a
3e3e0a656e646f626a0a3131322030206f626a0a3c3c0a2f53
202f4c426f64790a2f54797065202f537472756374456c656d
0a2f4b205b395d0a2f5020313133203020520a2f5067203620
3020520a3e3e0a656e646f626a0a3131332030206f626a0a3c
3c0a2f53202f4c490a2f54797065202f537472756374456c65
6d0a2f4b205b313132203020525d0a2f502031313120302052
0a3e3e0a656e646f626a0a3131312030206f626a0a3c3c0a2f
53202f4c0a2f54797065202f537472756374456c656d0a2f4b
205b3131302030205220313133203020525d0a2f5020313030
203020520a3e3e0a656e646f626a0a3131342030206f626a0a
3c3c0a2f53202f500a2f54797065202f537472756374456c65
6d0a2f4b205b31305d0a2f5020313030203020520a2f506720
36203020520a3e3e0a656e646f626a0a3131352030206f626a
0a3c3c0a2f53202f500a2f54797065202f537472756374456c
656d0a2f4b205b31315d0a2f5020313030203020520a2f5067
2036203020520a3e3e0a656e646f626a0a3131362030206f62
6a0a3c3c0a2f53202f500a2f54797065202f53747275637445
6c656d0a2f4b205b31325d0a2f5020313030203020520a2f50
672036203020520a3e3e0a656e646f626a0a3131372030206f
626a0a3c3c0a2f53202f4c426f64790a2f54797065202f5374
72756374456c656d0a2f4b205b31335d0a2f50203131382030
20520a2f50672036203020520a3e3e0a656e646f626a0a3131
382030206f626a0a3c3c0a2f53202f4c490a2f54797065202f
537472756374456c656d0a2f4b205b313137203020525d0a2f
5020313139203020520a3e3e0a656e646f626a0a3131392030
206f626a0a3c3c0a2f53202f4c0a2f54797065202f53747275
6374456c656d0a2f4b205b313138203020525d0a2f50203130
30203020520a3e3e0a656e646f626a0a3132302030206f626a
0a3c3c0a2f53202f500a2f54797065202f537472756374456c
656d0a2f4b205b31345d0a2f5020313030203020520a2f5067
2036203020520a3e3e0a656e646f626a0a3132312030206f62
6a0a3c3c0a2f53202f500a2f54797065202f53747275637445
6c656d0a2f4b205b31355d0a2f5020313030203020520a2f50
672036203020520a3e3e0a656e646f626a0a3132322030206f
626a0a3c3c0a2f53202f500a2f54797065202f537472756374
456c656d0a2f4b205b31365d0a2f5020313030203020520a2f
50672036203020520a3e3e0a656e646f626a0a313233203020
6f626a0a3c3c0a2f53202f4c426f64790a2f54797065202f53
7472756374456c656d0a2f4b205b31375d0a2f502031323420
3020520a2f50672036203020520a3e3e0a656e646f626a0a31
32342030206f626a0a3c3c0a2f53202f4c490a2f5479706520
2f537472756374456c656d0a2f4b205b313233203020525d0a
2f5020313235203020520a3e3e0a656e646f626a0a31323520
30206f626a0a3c3c0a2f53202f4c0a2f54797065202f537472
756374456c656d0a2f4b205b313234203020525d0a2f502031
3030203020520a3e3e0a656e646f626a0a3132362030206f62
6a0a3c3c0a2f53202f500a2f54797065202f53747275637445
6c656d0a2f4b205b31385d0a2f5020313030203020520a2f50
672036203020520a3e3e0a656e646f626a0a3132372030206f
626a0a3c3c0a2f53202f500a2f54797065202f537472756374
456c656d0a2f4b205b31395d0a2f5020313030203020520a2f
50672036203020520a3e3e0a656e646f626a0a313238203020
6f626a0a3c3c0a2f53202f500a2f54797065202f5374727563
74456c656d0a2f4b205b32305d0a2f5020313030203020520a
2f50672036203020520a3e3e0a656e646f626a0a3132392030
206f626a0a3c3c0a2f53202f4c426f64790a2f54797065202f
537472756374456c656d0a2f4b205b32315d0a2f5020313330
203020520a2f50672036203020520a3e3e0a656e646f626a0a
3133302030206f626a0a3c3c0a2f53202f4c490a2f54797065
202f537472756374456c656d0a2f4b205b313239203020525d
0a2f5020313331203020520a3e3e0a656e646f626a0a313331
2030206f626a0a3c3c0a2f53202f4c0a2f54797065202f5374
72756374456c656d0a2f4b205b313330203020525d0a2f5020
313030203020520a3e3e0a656e646f626a0a3130302030206f
626a0a3c3c0a2f53202f54440a2f54797065202f5374727563
74456c656d0a2f4b205b393920302052203130352030205220
31303620302052203130372030205220313038203020522031
31312030205220313134203020522031313520302052203131
36203020522031313920302052203132302030205220313231
20302052203132322030205220313235203020522031323620
30205220313237203020522031323820302052203133312030
20525d0a2f5020313031203020520a3e3e0a656e646f626a0a
3130312030206f626a0a3c3c0a2f53202f54520a2f54797065
202f537472756374456c656d0a2f4b205b3133322030205220
313030203020525d0a2f5020313032203020520a3e3e0a656e
646f626a0a3134362030206f626a0a3c3c0a2f53202f537061
6e0a2f54797065202f537472756374456c656d0a2f4b205b32
395d0a2f5020313335203020520a2f50672036203020520a3e
3e0a656e646f626a0a3133332030206f626a0a3c3c0a2f5320
2f500a2f54797065202f537472756374456c656d0a2f4b205b
32335d0a2f5020313334203020520a2f50672036203020520a
3e3e0a656e646f626a0a3133362030206f626a0a3c3c0a2f53
202f500a2f54797065202f537472756374456c656d0a2f4b20
5b32345d0a2f5020313334203020520a2f5067203620302052
0a3e3e0a656e646f626a0a3133372030206f626a0a3c3c0a2f
53202f4c426f64790a2f54797065202f537472756374456c65
6d0a2f4b205b32355d0a2f5020313338203020520a2f506720
36203020520a3e3e0a656e646f626a0a3133382030206f626a
0a3c3c0a2f53202f4c490a2f54797065202f53747275637445
6c656d0a2f4b205b313337203020525d0a2f50203133392030
20520a3e3e0a656e646f626a0a3134302030206f626a0a3c3c
0a2f53202f4c426f64790a2f54797065202f53747275637445
6c656d0a2f4b205b32365d0a2f5020313431203020520a2f50
672036203020520a3e3e0a656e646f626a0a3134312030206f
626a0a3c3c0a2f53202f4c490a2f54797065202f5374727563
74456c656d0a2f4b205b313430203020525d0a2f5020313339
203020520a3e3e0a656e646f626a0a3134322030206f626a0a
3c3c0a2f53202f4c426f64790a2f54797065202f5374727563
74456c656d0a2f4b205b32375d0a2f5020313433203020520a
2f50672036203020520a3e3e0a656e646f626a0a3134332030
206f626a0a3c3c0a2f53202f4c490a2f54797065202f537472
756374456c656d0a2f4b205b313432203020525d0a2f502031
3339203020520a3e3e0a656e646f626a0a3134342030206f62
6a0a3c3c0a2f53202f4c426f64790a2f54797065202f537472
756374456c656d0a2f4b205b32385d0a2f5020313435203020
520a2f50672036203020520a3e3e0a656e646f626a0a313435
2030206f626a0a3c3c0a2f53202f4c490a2f54797065202f53
7472756374456c656d0a2f4b205b313434203020525d0a2f50
20313339203020520a3e3e0a656e646f626a0a313339203020
6f626a0a3c3c0a2f53202f4c0a2f54797065202f5374727563
74456c656d0a2f4b205b313338203020522031343120302052
203134332030205220313435203020525d0a2f502031333420
3020520a3e3e0a656e646f626a0a3133342030206f626a0a3c
3c0a2f53202f54440a2f54797065202f537472756374456c65
6d0a2f4b205b31333320302052203133362030205220313339
203020525d0a2f5020313335203020520a3e3e0a656e646f62
6a0a3133352030206f626a0a3c3c0a2f53202f54520a2f5479
7065202f537472756374456c656d0a2f4b205b313436203020
5220313334203020525d0a2f5020313032203020520a3e3e0a
656e646f626a0a3130322030206f626a0a3c3c0a2f53202f54
61626c650a2f54797065202f537472756374456c656d0a2f4b
205b3130312030205220313335203020525d0a2f5020393720
3020520a3e3e0a656e646f626a0a3134372030206f626a0a3c
3c0a2f53202f500a2f54797065202f537472756374456c656d
0a2f4b205b33305d0a2f50203937203020520a2f5067203620
3020520a3e3e0a656e646f626a0a39372030206f626a0a3c3c
0a2f53202f54440a2f54797065202f537472756374456c656d
0a2f4b205b3936203020522031303220302052203134372030
20525d0a2f50203938203020520a3e3e0a656e646f626a0a39
382030206f626a0a3c3c0a2f53202f54520a2f54797065202f
537472756374456c656d0a2f4b205b31343820302052203937
203020525d0a2f50203933203020520a3e3e0a656e646f626a
0a39332030206f626a0a3c3c0a2f53202f54426f64790a2f54
797065202f537472756374456c656d0a2f4b205b3932203020
52203938203020525d0a2f50203934203020520a3e3e0a656e
646f626a0a3135302030206f626a0a3c3c0a2f53202f500a2f
54797065202f537472756374456c656d0a2f4b205b305d0a2f
5020313531203020520a2f50672037203020520a3e3e0a656e
646f626a0a3135352030206f626a0a3c3c0a2f53202f500a2f
54797065202f537472756374456c656d0a2f4b205b315d0a2f
5020313531203020520a2f50672037203020520a3e3e0a656e
646f626a0a3135362030206f626a0a3c3c0a2f53202f4c426f
64790a2f54797065202f537472756374456c656d0a2f4b205b
325d0a2f5020313537203020520a2f50672037203020520a3e
3e0a656e646f626a0a3135372030206f626a0a3c3c0a2f5320
2f4c490a2f54797065202f537472756374456c656d0a2f4b20
5b313536203020525d0a2f5020313538203020520a3e3e0a65
6e646f626a0a3135392030206f626a0a3c3c0a2f53202f4c42
6f64790a2f54797065202f537472756374456c656d0a2f4b20
5b335d0a2f5020313630203020520a2f50672037203020520a
3e3e0a656e646f626a0a3136302030206f626a0a3c3c0a2f53
202f4c490a2f54797065202f537472756374456c656d0a2f4b
205b313539203020525d0a2f5020313538203020520a3e3e0a
656e646f626a0a3135382030206f626a0a3c3c0a2f53202f4c
0a2f54797065202f537472756374456c656d0a2f4b205b3135
372030205220313630203020525d0a2f502031353120302052
0a3e3e0a656e646f626a0a3136312030206f626a0a3c3c0a2f
53202f500a2f54797065202f537472756374456c656d0a2f4b
205b345d0a2f5020313531203020520a2f5067203720302052
0a3e3e0a656e646f626a0a3136322030206f626a0a3c3c0a2f
53202f500a2f54797065202f537472756374456c656d0a2f4b
205b355d0a2f5020313531203020520a2f5067203720302052
0a3e3e0a656e646f626a0a3136332030206f626a0a3c3c0a2f
53202f500a2f54797065202f537472756374456c656d0a2f4b
205b365d0a2f5020313531203020520a2f5067203720302052
0a3e3e0a656e646f626a0a3136342030206f626a0a3c3c0a2f
53202f4c426f64790a2f54797065202f537472756374456c65
6d0a2f4b205b375d0a2f5020313635203020520a2f50672037
203020520a3e3e0a656e646f626a0a3136352030206f626a0a
3c3c0a2f53202f4c490a2f54797065202f537472756374456c
656d0a2f4b205b313634203020525d0a2f5020313636203020
520a3e3e0a656e646f626a0a3136372030206f626a0a3c3c0a
2f53202f4c426f64790a2f54797065202f537472756374456c
656d0a2f4b205b385d0a2f5020313638203020520a2f506720
37203020520a3e3e0a656e646f626a0a3136382030206f626a
0a3c3c0a2f53202f4c490a2f54797065202f53747275637445
6c656d0a2f4b205b313637203020525d0a2f50203136362030
20520a3e3e0a656e646f626a0a3136392030206f626a0a3c3c
0a2f53202f4c426f64790a2f54797065202f53747275637445
6c656d0a2f4b205b395d0a2f5020313730203020520a2f5067
2037203020520a3e3e0a656e646f626a0a3137302030206f62
6a0a3c3c0a2f53202f4c490a2f54797065202f537472756374
456c656d0a2f4b205b313639203020525d0a2f502031363620
3020520a3e3e0a656e646f626a0a3137312030206f626a0a3c
3c0a2f53202f4c426f64790a2f54797065202f537472756374
456c656d0a2f4b205b31305d0a2f5020313732203020520a2f
50672037203020520a3e3e0a656e646f626a0a313732203020
6f626a0a3c3c0a2f53202f4c490a2f54797065202f53747275
6374456c656d0a2f4b205b313731203020525d0a2f50203136
36203020520a3e3e0a656e646f626a0a3136362030206f626a
0a3c3c0a2f53202f4c0a2f54797065202f537472756374456c
656d0a2f4b205b313635203020522031363820302052203137
302030205220313732203020525d0a2f502031353120302052
0a3e3e0a656e646f626a0a3135312030206f626a0a3c3c0a2f
53202f54440a2f54797065202f537472756374456c656d0a2f
4b205b31353020302052203135352030205220313538203020
52203136312030205220313632203020522031363320302052
20313636203020525d0a2f5020313532203020520a3e3e0a65
6e646f626a0a3137332030206f626a0a3c3c0a2f53202f5370
616e0a2f54797065202f537472756374456c656d0a2f4b205b
31315d0a2f5020313532203020520a2f50672037203020520a
3e3e0a656e646f626a0a3135322030206f626a0a3c3c0a2f53
202f54520a2f54797065202f537472756374456c656d0a2f4b
205b3137332030205220313531203020525d0a2f5020313533
203020520a3e3e0a656e646f626a0a3135332030206f626a0a
3c3c0a2f53202f54426f64790a2f54797065202f5374727563
74456c656d0a2f4b205b313532203020525d0a2f5020313534
203020520a3e3e0a656e646f626a0a3137342030206f626a0a
3c3c0a2f53202f500a2f54797065202f537472756374456c65
6d0a2f4b205b31325d0a2f50203232203020520a2f50672037
203020520a3e3e0a656e646f626a0a33302030206f626a0a3c
3c0a2f53202f5461626c650a2f54797065202f537472756374
456c656d0a2f4b205b3239203020525d0a2f50203232203020
520a3e3e0a656e646f626a0a35382030206f626a0a3c3c0a2f
53202f5461626c650a2f54797065202f537472756374456c65
6d0a2f4b205b3537203020525d0a2f50203232203020520a3e
3e0a656e646f626a0a37322030206f626a0a3c3c0a2f53202f
5461626c650a2f54797065202f537472756374456c656d0a2f
4b205b3731203020525d0a2f50203232203020520a3e3e0a65
6e646f626a0a39342030206f626a0a3c3c0a2f53202f546162
6c650a2f54797065202f537472756374456c656d0a2f4b205b
3933203020525d0a2f50203232203020520a3e3e0a656e646f
626a0a3135342030206f626a0a3c3c0a2f53202f5461626c65
0a2f54797065202f537472756374456c656d0a2f4b205b3135
33203020525d0a2f50203232203020520a3e3e0a656e646f62
6a0a32322030206f626a0a3c3c0a2f53202f506172740a2f54
797065202f537472756374456c656d0a2f4b205b3231203020
52203736203020522032332030205220323420302052203235
20302052203330203020522035322030205220353320302052
20353820302052203636203020522036372030205220373220
30205220393420302052203135342030205220313734203020
525d0a2f502033203020520a3e3e0a656e646f626a0a373720
30206f626a0a3c3c0a2f4e756d73205b30205b323120302052
20323320302052203234203020522032352030205220323620
30205220333120302052203331203020522033312030205220
33322030205220333220302052203332203020522033332030
20522033332030205220333420302052203334203020522033
34203020522033352030205220333520302052203335203020
52203335203020522033352030205220333620302052203336
20302052203337203020522033372030205220333720302052
20333820302052203338203020522033382030205220333920
30205220333920302052203339203020522034302030205220
34322030205220343220302052203433203020522034332030
20522034332030205220343420302052203434203020522034
34203020522034352030205220343520302052203436203020
52203436203020522034362030205220343720302052203437
20302052203437203020522034382030205220343820302052
20343920302052203439203020522034392030205220353020
30205220353020302052203530203020522035312030205220
35322030205220353320302052203534203020522035392030
20522036302030205220363120302052203632203020522036
34203020522036352030205220363620302052203637203020
52203638203020522037332030205220373420302052203735
20302052203736203020525d2031205b393020302052203935
20302052203936203020522039392030205220313033203020
52203130362030205220313037203020522031303820302052
20313039203020522031313220302052203131342030205220
31313520302052203131362030205220313137203020522031
32302030205220313231203020522031323220302052203132
33203020522031323620302052203132372030205220313238
20302052203132392030205220313332203020522031333320
30205220313336203020522031333720302052203134302030
20522031343220302052203134342030205220313436203020
52203134372030205220313438203020525d2032205b313530
20302052203135352030205220313536203020522031353920
30205220313631203020522031363220302052203136332030
20522031363420302052203136372030205220313639203020
52203137312030205220313733203020522031373420302052
5d5d0a3e3e0a656e646f626a0a342030206f626a0a3c3c0a2f
466f6f746e6f7465202f4e6f74650a2f456e646e6f7465202f
4e6f74650a2f54657874626f78202f536563740a2f48656164
6572202f536563740a2f466f6f746572202f536563740a2f49
6e6c696e655368617065202f536563740a2f416e6e6f746174
696f6e202f536563740a2f4172746966616374202f53656374
0a2f576f726b626f6f6b202f446f63756d656e740a2f576f72
6b7368656574202f506172740a2f4d6163726f736865657420
2f506172740a2f43686172747368656574202f506172740a2f
4469616c6f677368656574202f506172740a2f536c69646520
2f506172740a2f4368617274202f536563740a2f4469616772
616d202f4669677572650a3e3e0a656e646f626a0a33203020
6f626a0a3c3c0a2f54797065202f5374727563745472656552
6f6f740a2f526f6c654d61702034203020520a2f4b205b3232
203020525d0a2f506172656e7454726565203737203020520a
2f506172656e74547265654e6578744b657920330a3e3e0a65
6e646f626a0a322030206f626a0a3c3c0a2f54797065202f50
616765730a2f4b696473205b35203020522036203020522037
203020525d0a2f436f756e7420330a3e3e0a656e646f626a0a
312030206f626a0a3c3c0a2f54797065202f436174616c6f67
0a2f50616765732032203020520a2f4c616e672028656e2d55
53290a2f53747275637454726565526f6f742033203020520a
2f4d61726b496e666f203c3c0a2f4d61726b65642074727565
0a3e3e0a3e3e0a656e646f626a0a3137352030206f626a0a3c
3c0a2f43726561746f72203c46454646303034443030363930
30363330303732303036463030373330303646303036363030
37343030414530303230303035373030364630303732303036
3430303230303033323030333030303331303033363e0a2f43
72656174696f6e446174652028443a32303235313131313137
333833362b303027303027290a2f50726f6475636572202877
77772e696c6f76657064662e636f6d290a2f4d6f6444617465
2028443a32303235313131313137333833375a290a3e3e0a65
6e646f626a0a787265660a30203137360a3030303030303030
303020363535333520660d0a30303030313434363030203030
303030206e0d0a30303030313434353331203030303030206e
0d0a30303030313434343231203030303030206e0d0a303030
30313434313338203030303030206e0d0a3030303030313538
3330203030303030206e0d0a30303030313239373935203030
303030206e0d0a30303030313331373736203030303030206e
0d0a30303030303030383730203030303030206e0d0a303030
30303030303135203030303030206e0d0a3030303030303032
3636203030303030206e0d0a30303030303031383436203030
303030206e0d0a30303030303031303535203030303030206e
0d0a30303030303031333132203030303030206e0d0a303030
30303032383039203030303030206e0d0a3030303030303230
3338203030303030206e0d0a30303030303032333031203030
303030206e0d0a30303030303033303033203030303030206e
0d0a30303030303033303630203030303030206e0d0a303030
30303033313137203030303030206e0d0a3030303030313231
3434203030303030206e0d0a30303030313332313235203030
303030206e0d0a30303030313433303532203030303030206e
0d0a30303030313332313938203030303030206e0d0a303030
30313332323731203030303030206e0d0a3030303031333233
3434203030303030206e0d0a30303030313332343137203030
303030206e0d0a30303030313333323038203030303030206e
0d0a30303030313334333337203030303030206e0d0a303030
30313334343230203030303030206e0d0a3030303031343236
3930203030303030206e0d0a30303030313332343933203030
303030206e0d0a30303030313332353730203030303030206e
0d0a30303030313332363438203030303030206e0d0a303030
30313332373235203030303030206e0d0a3030303031333238
3035203030303030206e0d0a30303030313332383931203030
303030206e0d0a30303030313332393638203030303030206e
0d0a30303030313333303438203030303030206e0d0a303030
30313333313238203030303030206e0d0a3030303031333334
3137203030303030206e0d0a30303030313334323035203030
303030206e0d0a30303030313333343934203030303030206e
0d0a30303030313333353731203030303030206e0d0a303030
30313333363531203030303030206e0d0a3030303031333337
3331203030303030206e0d0a30303030313333383038203030
303030206e0d0a30303030313333383838203030303030206e
0d0a30303030313333393638203030303030206e0d0a303030
30313334303435203030303030206e0d0a3030303031333431
3235203030303030206e0d0a30303030313333333430203030
303030206e0d0a30303030313334343932203030303030206e
0d0a30303030313334353636203030303030206e0d0a303030
30313334363430203030303030206e0d0a3030303031333439
3336203030303030206e0d0a30303030313335333237203030
303030206e0d0a30303030313335343130203030303030206e
0d0a30303030313432373632203030303030206e0d0a303030
30313334373134203030303030206e0d0a3030303031333437
3838203030303030206e0d0a30303030313334383632203030
303030206e0d0a30303030313335313033203030303030206e
0d0a30303030313335323531203030303030206e0d0a303030
30313335313737203030303030206e0d0a3030303031333530
3236203030303030206e0d0a30303030313335343832203030
303030206e0d0a30303030313335353536203030303030206e
0d0a30303030313335363330203030303030206e0d0a303030
30313335383532203030303030206e0d0a3030303031333630
3132203030303030206e0d0a30303030313336303838203030
303030206e0d0a30303030313432383334203030303030206e
0d0a30303030313335373034203030303030206e0d0a303030
30313335373738203030303030206e0d0a3030303031333539
3335203030303030206e0d0a30303030313336313630203030
303030206e0d0a30303030313433323232203030303030206e
0d0a30303030313236373633203030303030206e0d0a303030
30313236333338203030303030206e0d0a3030303031323631
3633203030303030206e0d0a30303030303136313837203030
303030206e0d0a30303030313235343434203030303030206e
0d0a30303030303136323632203030303030206e0d0a303030
30313235373134203030303030206e0d0a3030303031323633
3633203030303030206e0d0a30303030313237313638203030
303030206e0d0a30303030313236393038203030303030206e
0d0a30303030313237313436203030303030206e0d0a303030
30313237333430203030303030206e0d0a3030303031333632
3339203030303030206e0d0a30303030313336333132203030
303030206e0d0a30303030313336343537203030303030206e
0d0a30303030313430373236203030303030206e0d0a303030
30313432393036203030303030206e0d0a3030303031333633
3831203030303030206e0d0a30303030313336363131203030
303030206e0d0a30303030313430353634203030303030206e
0d0a30303030313430363439203030303030206e0d0a303030
30313336373633203030303030206e0d0a3030303031333930
3138203030303030206e0d0a30303030313339323235203030
303030206e0d0a30303030313430343037203030303030206e
0d0a30303030313336383337203030303030206e0d0a303030
30313336393136203030303030206e0d0a3030303031333639
3838203030303030206e0d0a30303030313337303539203030
303030206e0d0a30303030313337313334203030303030206e
0d0a30303030313337323039203030303030206e0d0a303030
30313337323834203030303030206e0d0a3030303031333733
3633203030303030206e0d0a30303030313337353836203030
303030206e0d0a30303030313337343335203030303030206e
0d0a30303030313337353134203030303030206e0d0a303030
30313337363635203030303030206e0d0a3030303031333737
3431203030303030206e0d0a30303030313337383137203030
303030206e0d0a30303030313337383933203030303030206e
0d0a30303030313337393733203030303030206e0d0a303030
30313338303435203030303030206e0d0a3030303031333831
3136203030303030206e0d0a30303030313338313932203030
303030206e0d0a30303030313338323638203030303030206e
0d0a30303030313338333434203030303030206e0d0a303030
30313338343234203030303030206e0d0a3030303031333834
3936203030303030206e0d0a30303030313338353637203030
303030206e0d0a30303030313338363433203030303030206e
0d0a30303030313338373139203030303030206e0d0a303030
30313338373935203030303030206e0d0a3030303031333838
3735203030303030206e0d0a30303030313338393437203030
303030206e0d0a30303030313336363834203030303030206e
0d0a30303030313339333834203030303030206e0d0a303030
30313430323339203030303030206e0d0a3030303031343033
3237203030303030206e0d0a30303030313339343630203030
303030206e0d0a30303030313339353336203030303030206e
0d0a30303030313339363136203030303030206e0d0a303030
30313430313434203030303030206e0d0a3030303031333936
3838203030303030206e0d0a30303030313339373638203030
303030206e0d0a30303030313339383430203030303030206e
0d0a30303030313339393230203030303030206e0d0a303030
30313339393932203030303030206e0d0a3030303031343030
3732203030303030206e0d0a30303030313339333035203030
303030206e0d0a30303030313430343839203030303030206e
0d0a30303030313336353333203030303030206e0d0a303030
30313330313433203030303030206e0d0a3030303031343038
3035203030303030206e0d0a30303030313432323631203030
303030206e0d0a30303030313432343630203030303030206e
0d0a30303030313432353430203030303030206e0d0a303030
30313432393738203030303030206e0d0a3030303031343038
3830203030303030206e0d0a30303030313430393535203030
303030206e0d0a30303030313431303334203030303030206e
0d0a30303030313431323537203030303030206e0d0a303030
30313431313036203030303030206e0d0a3030303031343131
3835203030303030206e0d0a30303030313431333336203030
303030206e0d0a30303030313431343131203030303030206e
0d0a30303030313431343836203030303030206e0d0a303030
30313431353631203030303030206e0d0a3030303031343136
3430203030303030206e0d0a30303030313432313636203030
303030206e0d0a30303030313431373132203030303030206e
0d0a30303030313431373931203030303030206e0d0a303030
30313431383633203030303030206e0d0a3030303031343139
3432203030303030206e0d0a30303030313432303134203030
303030206e0d0a30303030313432303934203030303030206e
0d0a30303030313432333831203030303030206e0d0a303030
30313432363135203030303030206e0d0a3030303031343437
3134203030303030206e0d0a747261696c65720a3c3c0a2f53
697a65203137360a2f526f6f742031203020520a2f496e666f
20313735203020520a2f4944205b285c3336345123675c3334
303f5c3337302139575c3231355c303033383e722329203c38
34373742423635433433414342374643303341374132383644
3044354337363e5d0a3e3e0a7374617274787265660a313434
3933310a2525454f460a', 0)
Exec Contrata '123456', @PDF, 'Hospital Hospitalar', 'Hospicio123'; --André, coloca aqui o binário do pdf
Exec Registra_Funcionario '123456', 4, 'Luiz Ricardo', 'Bombom';
Exec Registra_Funcionario '123456', 2, 'Rubens', 'Enjain';
Exec Registra_Funcionario '123456', 2, 'Evandro', 'Vo_cegueta';
Exec Contrata '654321', @PDF, 'Sergio Fârmacos', 'Jovenzinhos';
Exec Registra_Funcionario '654321', 3, 'Sergio', 'Esses_Jovenzinhos';
Exec Registra_Funcionario '654321', 1, 'Rodrigo F.I.', 'Binarios.com';
Exec Registra_Paciente '42379292809', 'etesp321', 'emailteste@gmail.com', 'John Tarantino Cardoso Centelha', 'John T.C.C.', '11969127828';
Exec Registra_Receita 2, 2, 'Enjain', '19-12-2025', '42379292809', 'Paracetamol 750mg', 'Tomar 2x ao dia', 2;
Exec Registra_Receita 3, 2, 'Vo_cegueta', '01-02-2026', '42379292809', 'Ômega 3 1000mg' , 'Uma dose durante a manhã', 1;
Exec Registra_Receita 3, 2, 'Vo_cegueta', '11-11-2025', '42379292809', 'Morfina 3L', 'Sempre que quiser', 20;
Exec Altera_Receita 5, 'Binarios.com','42379292809', 2;
Exec Insere_Historico '42379292809', 'etesp321', 0xABCDEF; --André, aqui tbm
Exec Desativa_Funcionario '123456', 'Hospicio123', 3;
Exec Envia_Mensagem_F 2, '42379292809', 'Socorro doutor!!!';
Exec Envia_Mensagem_F 2, '42379292809', 'Meu cabelo ta pegando fogo';
Exec Envia_Mensagem_P '42379292809', 2, 'Como? Você não tem cabelo';

/*
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
EXEC Altera_Receita 6, 'senha123?', '75974478096', 5;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 5;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 5;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 6, 'senha123?', '75974478096', 147;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
EXEC Altera_Receita 7, 'senha123?', '34731605040', 6;
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
EXEC Altera_Receita 4, 'senha123?', '58061315050', 145;
EXEC Altera_Receita 4, 'senha123?', '58061315050', 145;
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
EXEC Registra_Paciente '71438629007', 'Senha@789', 'fernanda.lopes@email.com', 'Fernanda Lopes', 'Fê', '11971234567';
EXEC Registra_Paciente '28496375041', 'Mudar@456', 'ricardo.souza@email.com', 'Ricardo Souza', '', '21982345678';
EXEC Registra_Paciente '53714928063', 'Nova#123', 'beatriz.mendes@email.com', 'Beatriz Mendes', 'Bia', '11993456789';
EXEC Registra_Paciente '84629517038', 'Pass$321', 'gustavo.rocha@email.com', 'Gustavo Rocha', '', '21904567890';
EXEC Registra_Paciente '92837465010', 'Acesso!654', 'larissa.dias@email.com', 'Larissa Dias', 'Lari', '11915678901';
EXEC Registra_Paciente '65192847036', 'Portal@987', 'thiago.barros@email.com', 'Thiago Barros', '', '21926789012';
EXEC Registra_Paciente '37428591062', 'Sistema#147', 'amanda.castro@email.com', 'Amanda Castro', 'Manda', '11937890123';
EXEC Registra_Paciente '19573846025', 'Entrada&258', 'vinicius.gomes@email.com', 'Vinícius Gomes', '', '21948901234';
EXEC Registra_Paciente '46285719084', 'Chave!369', 'camila.ribeiro@email.com', 'Camila Ribeiro', 'Cami', '11959012345';
EXEC Registra_Paciente '73916284052', 'Teste@741', 'rodrigo.pinto@email.com', 'Rodrigo Pinto', '', '21960123456';
EXEC Registra_Paciente '28574913069', 'Mudar#852', 'jessica.cardoso@email.com', 'Jessica Cardoso', 'Jess', '11971234568';
EXEC Registra_Paciente '91628473055', 'Nova@963', 'felipe.moreira@email.com', 'Felipe Moreira', '', '21982345679';
EXEC Registra_Paciente '54739182046', 'Pass!159', 'isabela.freitas@email.com', 'Isabela Freitas', 'Bela', '11993456780';
EXEC Registra_Paciente '67384921037', 'Acesso$357', 'bruno.teixeira@email.com', 'Bruno Teixeira', '', '21904567891';
EXEC Registra_Paciente '82947165028', 'Portal&753', 'natalia.ramos@email.com', 'Natália Ramos', 'Nat', '11915678902';
EXEC Registra_Paciente '39571846019', 'Sistema@951', 'leonardo.cunha@email.com', 'Leonardo Cunha', 'Leo', '21926789013';
EXEC Registra_Paciente '15482937064', 'Entrada#159', 'mariana.azevedo@email.com', 'Mariana Azevedo', 'Mari', '11937890124';
EXEC Registra_Paciente '74829163051', 'Chave!753', 'henrique.monteiro@email.com', 'Henrique Monteiro', '', '21948901235';
EXEC Registra_Paciente '26395817042', 'Teste&951', 'raquel.correia@email.com', 'Raquel Correia', 'Quel', '11959012346';
EXEC Registra_Paciente '58174629033', 'Mudar@357', 'diego.aragao@email.com', 'Diego Aragão', '', '21960123457';
EXEC Registra_Paciente '91827364025', 'Nova!159', 'carolina.batista@email.com', 'Carolina Batista', 'Carol', '11971234569';
EXEC Registra_Paciente '43658219076', 'Pass#753', 'matheus.neves@email.com', 'Matheus Neves', '', '21982345670';
EXEC Registra_Paciente '67291385041', 'Acesso@951', 'aline.farias@email.com', 'Aline Farias', '', '11993456781';
EXEC Registra_Paciente '85493726058', 'Portal$159', 'gabriel.santana@email.com', 'Gabriel Santana', 'Gabs', '21904567892';
EXEC Registra_Paciente '29846571039', 'Sistema!357', 'vanessa.carvalho@email.com', 'Vanessa Carvalho', 'Van', '11915678903';
EXEC Registra_Paciente '71528394062', 'Entrada@753', 'rafael.medeiros@email.com', 'Rafael Medeiros', '', '21926789014';
EXEC Registra_Paciente '34719628057', 'Chave#951', 'priscila.campos@email.com', 'Priscila Campos', 'Pri', '11937890125';
EXEC Registra_Paciente '96382745041', 'Teste!159', 'andre.vieira@email.com', 'André Vieira', '', '21948901236';
EXEC Registra_Paciente '52847196038', 'Mudar&357', 'leticia.duarte@email.com', 'Letícia Duarte', 'Lê', '11959012347';
EXEC Registra_Paciente '18574392024', 'Nova#753', 'paulo.nascimento@email.com', 'Paulo Nascimento', '', '21960123458';
EXEC Registra_Receita 10, 2, 'senha123', '15-11-2025', '71438629007', 'Losartana 50mg + HCTZ 12,5mg', 'Tomar 1 comp ao dia pela manhã', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '20-11-2025', '28496375041', 'Metformina 850mg', 'Tomar 1 comp 2x ao dia após refeições', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '25-11-2025', '53714928063', 'Atorvastatina 20mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '30-11-2025', '84629517038', 'Levotiroxina 75mcg', 'Tomar 1 comp em jejum 30min antes café', 90;
EXEC Registra_Receita 14, 2, 'senha123?', '05-12-2025', '92837465010', 'Sertralina 50mg', 'Tomar 1 comp pela manhã', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '10-12-2025', '65192847036', 'Omeprazol 40mg', 'Tomar 1 cáps em jejum', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '15-12-2025', '37428591062', 'Enalapril 20mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 10, 2, 'senha123', '20-12-2025', '19573846025', 'Anlodipino 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '18-10-2025', '46285719084', 'Amoxicilina 500mg', 'Tomar 1 cáps 8/8h por 10 dias', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '20-10-2025', '73916284052', 'Cefalexina 500mg', 'Tomar 1 cáps 6/6h por 7 dias', 28;
EXEC Registra_Receita 13, 2, 'senha123?', '22-10-2025', '28574913069', 'Azitromicina 500mg', 'Tomar 1 comp ao dia por 5 dias', 5;
EXEC Registra_Receita 14, 2, 'senha123?', '25-10-2025', '91628473055', 'Ciprofloxacino 500mg', 'Tomar 1 comp 12/12h por 7 dias', 14;
EXEC Registra_Receita 15, 2, 'senha123?', '28-10-2025', '54739182046', 'Levofloxacino 500mg', 'Tomar 1 comp ao dia por 7 dias', 7;
EXEC Registra_Receita 16, 2, 'senha123?', '30-10-2025', '67384921037', 'Claritromicina 500mg', 'Tomar 1 comp 12/12h por 10 dias', 20;
EXEC Registra_Receita 10, 2, 'senha123', '01-11-2025', '82947165028', 'Nimesulida 100mg', 'Tomar 1 comp 12/12h por 5 dias', 10;
EXEC Registra_Receita 11, 2, 'senha123?', '03-11-2025', '39571846019', 'Diclofenaco Sódico 50mg', 'Tomar 1 comp 8/8h após refeições', 21;
EXEC Registra_Receita 12, 2, 'senha123?', '05-11-2025', '15482937064', 'Ibuprofeno 600mg', 'Tomar 1 comp 8/8h se dor', 18;
EXEC Registra_Receita 13, 2, 'senha123?', '08-11-2025', '74829163051', 'Celecoxibe 200mg', 'Tomar 1 cáps ao dia', 15;
EXEC Registra_Receita 14, 2, 'senha123?', '10-11-2025', '26395817042', 'Meloxicam 15mg', 'Tomar 1 comp ao dia', 15;
EXEC Registra_Receita 15, 2, 'senha123?', '12-11-2025', '58174629033', 'Tramadol 50mg', 'Tomar 1 comp 8/8h se dor', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '14-11-2025', '91827364025', 'Ciclobenzaprina 10mg', 'Tomar 1 comp à noite', 20;
EXEC Registra_Receita 10, 2, 'senha123', '16-11-2025', '43658219076', 'Codeína 30mg', 'Tomar 1 comp 6/6h se dor forte', 24;
EXEC Registra_Receita 11, 2, 'senha123?', '18-11-2025', '67291385041', 'Pregabalina 75mg', 'Tomar 1 cáps 2x ao dia', 60;
EXEC Registra_Receita 12, 2, 'senha123?', '01-12-2025', '85493726058', 'Escitalopram 15mg', 'Tomar 1 comp pela manhã', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '03-12-2025', '29846571039', 'Fluoxetina 40mg', 'Tomar 1 cáps pela manhã', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '05-12-2025', '71528394062', 'Venlafaxina 75mg', 'Tomar 1 cáps ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '07-12-2025', '34719628057', 'Clonazepam 2mg', 'Tomar 1/2 comp à noite', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '09-12-2025', '96382745041', 'Alprazolam 0,5mg', 'Tomar 1 comp SOS ansiedade', 30;
EXEC Registra_Receita 10, 2, 'senha123', '11-12-2025', '52847196038', 'Bromazepam 3mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 11, 2, 'senha123?', '13-12-2025', '18574392024', 'Zolpidem 10mg', 'Tomar 1 comp antes de dormir', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '22-12-2025', '71438629007', 'Glibenclamida 5mg', 'Tomar 1 comp antes café manhã', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '24-12-2025', '28496375041', 'Gliclazida 30mg', 'Tomar 2 comp antes café', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '26-12-2025', '53714928063', 'Sitagliptina 100mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '28-12-2025', '84629517038', 'Empagliflozina 25mg', 'Tomar 1 comp pela manhã', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '15-01-2026', '92837465010', 'Montelucaste 10mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 10, 2, 'senha123', '17-01-2026', '65192847036', 'Formoterol+Budesonida 12/400', 'Inalar 2 jatos 12/12h', 1;
EXEC Registra_Receita 11, 2, 'senha123?', '19-01-2026', '37428591062', 'Salbutamol spray 100mcg', 'Inalar 2 jatos SOS falta de ar', 1;
EXEC Registra_Receita 12, 2, 'senha123?', '21-01-2026', '19573846025', 'Prednisolona 20mg', 'Tomar 2 comp manhã por 7 dias', 14;
EXEC Registra_Receita 13, 2, 'senha123?', '10-01-2026', '46285719084', 'Isotretinoína 20mg', 'Tomar 1 cáps 2x ao dia', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '12-01-2026', '73916284052', 'Doxiciclina 100mg (acne)', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '14-01-2026', '28574913069', 'Adapaleno gel 0,1%', 'Aplicar à noite', 1;
EXEC Registra_Receita 16, 2, 'senha123?', '16-01-2026', '91628473055', 'Tretinoína creme 0,025%', 'Aplicar à noite', 1;
EXEC Registra_Receita 10, 2, 'senha123', '05-01-2026', '54739182046', 'Desloratadina 5mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '07-01-2026', '67384921037', 'Fexofenadina 180mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '09-01-2026', '82947165028', 'Bilastina 20mg', 'Tomar 1 comp em jejum', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '25-01-2026', '39571846019', 'Pantoprazol 40mg', 'Tomar 1 comp em jejum', 30;
EXEC Registra_Receita 14, 2, 'senha123?', '27-01-2026', '15482937064', 'Esomeprazol 40mg', 'Tomar 1 cáps em jejum', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '29-01-2026', '74829163051', 'Domperidona 10mg', 'Tomar 1 comp 30min antes refeições', 90;
EXEC Insere_Historico '71438629007', 'Senha@789', 0xDEADBEEF;
EXEC Insere_Historico '28496375041', 'Mudar@456', 0xCAFEBABE;
EXEC Insere_Historico '53714928063', 'Nova#123', 0xFEEDFACE;
EXEC Insere_Historico '84629517038', 'Pass$321', 0xBAADF00D;
EXEC Insere_Historico '92837465010', 'Acesso!654', 0xDEADC0DE;
EXEC Insere_Historico '65192847036', 'Portal@987', 0xC0FFEE00;
EXEC Insere_Historico '37428591062', 'Sistema#147', 0xBEEFF00D;
EXEC Insere_Historico '19573846025', 'Entrada&258', 0xFACEFEED;
EXEC Insere_Historico '46285719084', 'Chave!369', 0xBADDCAFE;
EXEC Insere_Historico '73916284052', 'Teste@741', 0xDEFECA7E;
EXEC Insere_Historico '28574913069', 'Mudar#852', 0xFEEDBACC;
EXEC Insere_Historico '91628473055', 'Nova@963', 0xC0DED00D;
EXEC Insere_Historico '54739182046', 'Pass!159', 0xFACEB00C;
EXEC Insere_Historico '67384921037', 'Acesso$357', 0xDEADF00D;
EXEC Insere_Historico '82947165028', 'Portal&753', 0xBEEFCAFE;
EXEC Envia_Mensagem_P 10, '71438629007', 'Bom dia! Posso tomar a Losartana junto com suco de laranja?';
EXEC Envia_Mensagem_F '71438629007', 10, 'Bom dia! Pode sim, não há interação. Tome sempre no mesmo horário.';
EXEC Envia_Mensagem_P 10, '71438629007', 'Obrigado! E se esquecer de tomar, devo tomar duas doses?';
EXEC Envia_Mensagem_F '71438629007', 10, 'Não! Nunca dobre a dose. Tome assim que lembrar e retome horário normal.';
EXEC Envia_Mensagem_P 11, '28496375041', 'A Metformina está me dando diarreia, é normal?';
EXEC Envia_Mensagem_F '28496375041', 11, 'É efeito comum no início. Tome sempre com alimentos. Se persistir 2 semanas, me avise.';
EXEC Envia_Mensagem_P 11, '28496375041', 'Vou fazer isso. Quanto tempo até o corpo se acostumar?';
EXEC Envia_Mensagem_F '28496375041', 11, 'Geralmente 2-4 semanas. Se não melhorar, ajustamos a dose.';
EXEC Envia_Mensagem_P 12, '53714928063', 'Posso tomar a Atorvastatina de manhã em vez de à noite?';
EXEC Envia_Mensagem_F '53714928063', 12, 'Prefira à noite, o colesterol é produzido mais durante sono. Mas se esquecer muito, manhã é aceitável.';
EXEC Envia_Mensagem_P 13, '84629517038', 'Levotiroxina: posso tomar com café ou precisa ser água?';
EXEC Envia_Mensagem_F '84629517038', 13, 'Apenas ÁGUA! Café, leite e outros líquidos prejudicam absorção. Espere 30min para tomar café.';
EXEC Envia_Mensagem_P 14, '92837465010', 'Sertralina me deixa enjoado pela manhã. Posso tomar à noite?';
EXEC Envia_Mensagem_F '92837465010', 14, 'Pode, mas alguns pacientes têm insônia. Tente por 3 dias à noite e me conte como ficou.';
EXEC Envia_Mensagem_P 15, '65192847036', 'Preciso renovar receita do Omeprazol. Quando posso buscar?';
EXEC Envia_Mensagem_F '65192847036', 15, 'Vou preparar. Estará pronta amanhã após 14h.';
EXEC Envia_Mensagem_P 16, '37428591062', 'Minha receita vence semana que vem. Posso agendar renovação?';
EXEC Envia_Mensagem_F '37428591062', 16, 'Sim! Vou deixar receita pronta. Passe aqui qualquer dia.';
EXEC Envia_Mensagem_P 1, '46285719084', 'Amoxicilina está me dando coceira. Devo parar?';
EXEC Envia_Mensagem_F '46285719084', 1, 'PARE AGORA! Pode ser alergia. Venha hoje para avaliar e trocar antibiótico.';
EXEC Envia_Mensagem_P 1, '46285719084', 'Ok! Vou agora! A coceira está forte.';
EXEC Envia_Mensagem_F '46285719084', 1, 'Tome antialérgico se tiver. Estou te esperando.';
EXEC Envia_Mensagem_P 2, '73916284052', 'Cefalexina deixou meu estômago horrível. É normal?';
EXEC Envia_Mensagem_F '73916284052', 2, 'Sim, pode acontecer. Tome sempre após refeições. Use probiótico se piorar.';
EXEC Envia_Mensagem_P 3, '28574913069', 'Azitromicina me deu tontura. Posso dirigir?';
EXEC Envia_Mensagem_F '28574913069', 3, 'Evite dirigir se sentir tontura. Descanse e tome bastante água.';
EXEC Envia_Mensagem_P 4, '91628473055', 'Posso beber álcool tomando Ciprofloxacino?';
EXEC Envia_Mensagem_F '91628473055', 4, 'NÃO! Álcool com antibiótico pode causar efeitos graves. Zero álcool durante tratamento.';
EXEC Envia_Mensagem_P 5, '54739182046', 'Terminei Levofloxacino mas ainda tenho sintomas leves. É normal?';
EXEC Envia_Mensagem_F '54739182046', 5, 'Sintomas podem levar alguns dias para sumir totalmente. Se piorar, marque retorno.';
EXEC Envia_Mensagem_P 6, '82947165028', 'Nimesulida pode tomar em jejum ou só com comida?';
EXEC Envia_Mensagem_F '82947165028', 6, 'SEMPRE com alimento! Jejum causa lesão gástrica. Nunca tome em estômago vazio.';
EXEC Envia_Mensagem_P 7, '39571846019', 'Quanto tempo posso tomar Diclofenaco sem parar?';
EXEC Envia_Mensagem_F '39571846019', 7, 'Máximo 7-10 dias sem supervisão. Uso prolongado requer acompanhamento médico.';
EXEC Envia_Mensagem_P 8, '15482937064', 'Ibuprofeno com Dipirona pode tomar junto?';
EXEC Envia_Mensagem_F '15482937064', 8, 'Pode, mas prefira intervalo de 2h entre eles. Não precisa tomar ambos sempre.';
EXEC Envia_Mensagem_P 9, '74829163051', 'Preciso marcar retorno. Tem horário essa semana?';
EXEC Envia_Mensagem_F '74829163051', 9, 'Sim! Quinta às 15h está disponível. Confirmo para você?';
EXEC Envia_Mensagem_P 9, '74829163051', 'Perfeito! Confirmo quinta às 15h.';
EXEC Envia_Mensagem_F '74829163051', 9, 'Confirmado! Te aguardo quinta-feira.';
EXEC Envia_Mensagem_P 10, '26395817042', 'Posso antecipar minha consulta? Dores pioraram.';
EXEC Envia_Mensagem_F '26395817042', 10, 'Vou encaixar você amanhã às 10h30. Pode ser?';
EXEC Envia_Mensagem_P 10, '26395817042', 'Sim! Muito obrigado pela atenção!';
EXEC Envia_Mensagem_P 11, '58174629033', 'Obrigado pela consulta! Já comprei o Tramadol.';
EXEC Envia_Mensagem_F '58174629033', 11, 'Ótimo! Lembre: máximo 8/8h. Se dor forte persistir, me avise.';
EXEC Envia_Mensagem_P 12, '91827364025', 'Ciclobenzaprina está ajudando muito! Durmo melhor.';
EXEC Envia_Mensagem_F '91827364025', 12, 'Que bom! Continue por 14 dias como orientei. Retorno em 2 semanas.';
EXEC Envia_Mensagem_P 13, '43658219076', 'Codeína não está fazendo efeito. Dor continua forte.';
EXEC Envia_Mensagem_F '43658219076', 13, 'Venha hoje para reavaliar. Pode precisar ajustar medicação.';
EXEC Envia_Mensagem_P 13, '43658219076', 'Posso ir em 1 hora?';
EXEC Envia_Mensagem_F '43658219076', 13, 'Sim, estarei aqui. Traga exames se tiver.';
EXEC Envia_Mensagem_P 14, '67291385041', 'Pregabalina me deixou muito sonolento. É perigoso?';
EXEC Envia_Mensagem_F '67291385041', 14, 'Sonolência é comum na 1ª semana. NÃO dirija ou opere máquinas. Melhora em 7 dias.';
EXEC Envia_Mensagem_P 15, '85493726058', 'Escitalopram: quando começa a fazer efeito?';
EXEC Envia_Mensagem_F '85493726058', 15, 'Efeito completo em 3-4 semanas. Não desista! Continue tomando diariamente.';
EXEC Envia_Mensagem_P 16, '29846571039', 'Posso tomar Fluoxetina com chá verde?';
EXEC Envia_Mensagem_F '29846571039', 16, 'Chá verde em excesso pode interagir. Limite 1 xícara/dia, longe do medicamento.';
EXEC Envia_Mensagem_P 17, '71528394062', 'Venlafaxina com Ibuprofeno tem problema?';
EXEC Envia_Mensagem_F '71528394062', 17, 'Pode usar, mas por curto período. Ibuprofeno aumenta risco de sangramento com antidepressivos.';
EXEC Envia_Mensagem_P 18, '34719628057', 'Clonazepam: posso tomar com anticoncepcional?';
EXEC Envia_Mensagem_F '34719628057', 18, 'Sim, não há interação. Continue ambos normalmente.';
EXEC Envia_Mensagem_P 19, '96382745041', 'Vou viajar 2 meses. Preciso de receita extra de Alprazolam?';
EXEC Envia_Mensagem_F '96382745041', 19, 'Sim! Venha buscar receitas para 60 dias. Traga passagem como comprovante.';
EXEC Envia_Mensagem_P 19, '96382745041', 'Vou levar passagem amanhã. Obrigado!';
EXEC Envia_Mensagem_P 20, '52847196038', 'Estou grávida! Posso continuar Bromazepam?';
EXEC Envia_Mensagem_F '52847196038', 20, 'PARE AGORA! Marque urgente. Vamos trocar por medicação segura na gestação.';
EXEC Envia_Mensagem_P 20, '52847196038', 'Já parei! Vou aí hoje mesmo!';
EXEC Envia_Mensagem_F '52847196038', 20, 'Ótimo! Te aguardo. Parabéns pela gravidez!';
EXEC Envia_Mensagem_P 21, '18574392024', 'Zolpidem: posso tomar toda noite ou só às vezes?';
EXEC Envia_Mensagem_F '18574392024', 21, 'Use SOS insônia, não diariamente. Máximo 2-3x por semana para evitar dependência.';
EXEC Envia_Mensagem_P 22, '71438629007', 'Glibenclamida: glicemia 70 em jejum. Está baixa?';
EXEC Envia_Mensagem_F '71438629007', 22, 'Está no limite. Se tiver sintomas (tremor, suor), coma algo doce. Monitore mais vezes.';
EXEC Envia_Mensagem_P 23, '28496375041', 'Gliclazida com Metformina pode tomar junto?';
EXEC Envia_Mensagem_F '28496375041', 23, 'Sim! É combinação comum. Gliclazida antes café e Metformina após refeições.';
EXEC Envia_Mensagem_P 24, '53714928063', 'Sitagliptina causa hipoglicemia?';
EXEC Envia_Mensagem_F '53714928063', 24, 'Raramente sozinha. Mas se usar com outros diabéticos, pode baixar muito. Monitore glicemia.';
EXEC Envia_Mensagem_P 25, '84629517038', 'Empagliflozina: urino muito, é normal?';
EXEC Envia_Mensagem_F '84629517038', 25, 'Sim! Medicação elimina glicose pela urina. Beba bastante água. Melhora em 1 semana.';
EXEC Envia_Mensagem_P 26, '92837465010', 'Montelucaste tem horário específico ou tanto faz?';
EXEC Envia_Mensagem_F '92837465010', 26, 'Sempre à NOITE! Funciona melhor prevenindo crises noturnas e matinais.';
EXEC Envia_Mensagem_P 27, '65192847036', 'Bombinha de Budesonida: devo bochechar após usar?';
EXEC Envia_Mensagem_F '65192847036', 27, 'SIM! SEMPRE! Bochecho e cuspa para evitar candidíase oral. Muito importante!';
EXEC Envia_Mensagem_P 28, '37428591062', 'Salbutamol: quantas vezes posso usar por dia?';
EXEC Envia_Mensagem_F '37428591062', 28, 'Máximo 4x ao dia. Se precisar mais, é sinal de descontrole. Marque consulta urgente.';
EXEC Envia_Mensagem_P 29, '46285719084', 'Isotretinoína: lábios muito ressecados. É normal?';
EXEC Envia_Mensagem_F '46285719084', 29, 'Muito comum! Use protetor labial constantemente. Beba 2L água/dia. Melhora com hidratação.';
EXEC Envia_Mensagem_P 30, '73916284052', 'Doxiciclina para acne: quanto tempo até ver resultado?';
EXEC Envia_Mensagem_F '73916284052', 30, 'Melhora começa em 6-8 semanas. Não desista! Continue por 3 meses completos.';
EXEC Envia_Mensagem_P 31, '28574913069', 'Adapaleno: pele descascando muito. Devo parar?';
EXEC Envia_Mensagem_F '28574913069', 31, 'Não pare! É efeito esperado. Use hidratante pesado. Descamação diminui em 2 semanas.';
EXEC Envia_Mensagem_P 32, '91628473055', 'Tretinoína deixou pele avermelhada. Continuo?';
EXEC Envia_Mensagem_F '91628473055', 32, 'Vermelhidão leve é normal. Se arder muito, use dia sim/dia não. PROTETOR SOLAR obrigatório!';
EXEC Altera_Receita 1, 'senha123?', '71438629007', 153;
EXEC Altera_Receita 2, 'senha123?', '28496375041', 154;
EXEC Altera_Receita 3, 'senha123?', '53714928063', 155;
EXEC Altera_Receita 4, 'senha123?', '84629517038', 156;
EXEC Altera_Receita 5, 'senha123?', '92837465010', 157;
EXEC Altera_Receita 6, 'senha123?', '65192847036', 158;
EXEC Altera_Receita 7, 'senha123?', '37428591062', 159;
EXEC Altera_Receita 1, 'senha123?', '19573846025', 160;
EXEC Altera_Receita 2, 'senha123?', '46285719084', 161;
EXEC Altera_Receita 2, 'senha123?', '46285719084', 161;
EXEC Altera_Receita 3, 'senha123?', '73916284052', 162;
EXEC Altera_Receita 3, 'senha123?', '73916284052', 162;
EXEC Altera_Receita 3, 'senha123?', '73916284052', 162;
EXEC Altera_Receita 4, 'senha123?', '28574913069', 163;
EXEC Altera_Receita 5, 'senha123?', '91628473055', 164;
EXEC Altera_Receita 6, 'senha123?', '54739182046', 165;
EXEC Altera_Receita 7, 'senha123?', '67384921037', 166;
EXEC Altera_Receita 1, 'senha123?', '82947165028', 167;
EXEC Altera_Receita 2, 'senha123?', '39571846019', 168;
EXEC Altera_Receita 3, 'senha123?', '15482937064', 169;
EXEC Registra_Receita 10, 2, 'senha123', '15-05-2024', '71438629007', 'Paracetamol 750mg', 'Tomar 1 comp 6/6h se dor', 20;
EXEC Registra_Receita 11, 2, 'senha123?', '20-06-2024', '28496375041', 'Dipirona 1g', 'Tomar 1 comp até 4x ao dia', 40;
EXEC Registra_Receita 12, 2, 'senha123?', '10-07-2024', '53714928063', 'Cetirizina 10mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 13, 2, 'senha123?', '25-08-2024', '84629517038', 'Ranitidina 150mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '15-09-2024', '92837465010', 'Bromoprida 10mg', 'Tomar 1 comp 30min antes refeições', 90;
EXEC Envia_Mensagem_P 1, '54739182046', 'Doutor, tenho várias dúvidas sobre meus remédios';
EXEC Envia_Mensagem_F '54739182046', 1, 'Pode perguntar! Estou aqui para ajudar.';
EXEC Envia_Mensagem_P 1, '54739182046', '1) Desloratadina funciona para coceira de picada?';
EXEC Envia_Mensagem_F '54739182046', 1, 'Sim! Funciona bem para alergias e picadas. Toma 1x ao dia.';
EXEC Envia_Mensagem_P 1, '54739182046', '2) Posso tomar com estômago vazio?';
EXEC Envia_Mensagem_F '54739182046', 1, 'Pode! Desloratadina não precisa ser com comida.';
EXEC Envia_Mensagem_P 1, '54739182046', '3) Dá sono? Preciso dirigir.';
EXEC Envia_Mensagem_F '54739182046', 1, 'É anti-histamínico de 2ª geração, não dá sono. Pode dirigir tranquilo.';
EXEC Envia_Mensagem_P 1, '54739182046', 'Perfeito! Muito obrigado pelas respostas!';
EXEC Envia_Mensagem_P 2, '67384921037', 'Li na bula da Fexofenadina que pode dar arritmia. Devo me preocupar?';
EXEC Envia_Mensagem_F '67384921037', 2, 'Arritmia é raríssima! Ocorre em <0,1% dos casos. Seus exames cardíacos são normais.';
EXEC Envia_Mensagem_P 2, '67384921037', 'E se eu sentir palpitação?';
EXEC Envia_Mensagem_F '67384921037', 2, 'Me avise imediatamente. Mas pode ser ansiedade da leitura da bula. Fique tranquilo.';
EXEC Envia_Mensagem_P 2, '67384921037', 'Ok, vou tentar não ler tanto as bulas rs';
EXEC Envia_Mensagem_F '67384921037', 2, 'Boa ideia! rs Bulas assustam. Qualquer sintoma estranho, me procure.';
EXEC Envia_Mensagem_P 3, '82947165028', 'Doutora, Bilastina está R$ 180. Não consigo comprar...';
EXEC Envia_Mensagem_F '82947165028', 3, 'Entendo! Vou trocar por Loratadina que tem genérico barato. Funciona igual.';
EXEC Envia_Mensagem_P 3, '82947165028', 'Muito obrigada! Quanto custa mais ou menos?';
EXEC Envia_Mensagem_F '82947165028', 3, 'Genérico sai por R$ 8-15. Vou preparar receita nova. Busque amanhã.';
EXEC Envia_Mensagem_P 3, '82947165028', 'A senhora salvou meu mês! Gratidão!';
EXEC Envia_Mensagem_P 4, '39571846019', 'Doutor, minha mãe de 80 anos esquece de tomar Pantoprazol. O que fazer?';
EXEC Envia_Mensagem_F '39571846019', 4, 'Compre caixinha organizadora de medicamentos com dias da semana. Vende em farmácia.';
EXEC Envia_Mensagem_P 4, '39571846019', 'Boa ideia! E alarme no celular funciona?';
EXEC Envia_Mensagem_F '39571846019', 4, 'Ótimo! Configure alarme diário. Se ela tem smartphone, aplicativo de lembrete ajuda muito.';
EXEC Envia_Mensagem_P 4, '39571846019', 'Vou fazer isso! Ela tem celular sim. Obrigado!';
EXEC Envia_Mensagem_P 5, '15482937064', 'URGENTE! Manchas roxas apareceram no corpo após Esomeprazol!';
EXEC Envia_Mensagem_F '15482937064', 5, 'PARE medicação AGORA! Vá ao PRONTO SOCORRO imediatamente! Pode ser reação grave!';
EXEC Envia_Mensagem_P 5, '15482937064', 'Estou indo! É muito grave?';
EXEC Envia_Mensagem_F '15482937064', 5, 'Pode ser plaquetopenia. PS urgente! Me avise depois o que aconteceu!';
EXEC Envia_Mensagem_P 6, '74829163051', 'Tenho que tomar Domperidona por 3 meses? É muito tempo...';
EXEC Envia_Mensagem_F '74829163051', 6, 'Entendo sua preocupação. É tempo necessário para tratar gastroparesia. Vale a pena.';
EXEC Envia_Mensagem_P 6, '74829163051', 'Mas não tem efeito colateral de longo prazo?';
EXEC Envia_Mensagem_F '74829163051', 6, 'Faremos acompanhamento. Se surgir qualquer problema, ajustamos. Benefício supera risco.';
EXEC Envia_Mensagem_P 6, '74829163051', 'Ok, vou confiar no tratamento. Obrigado pela paciência!';
EXEC Registra_Receita 15, 2, 'senha123?', '01-02-2026', '12345678901', 'Atorvastatina 40mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 16, 2, 'senha123?', '03-02-2026', '98765432109', 'Glibenclamida 5mg', 'Tomar 1 comp antes café', 30;
EXEC Registra_Receita 10, 2, 'senha123', '05-02-2026', '45678912304', 'Sinvastatina 40mg', 'Tomar 1 comp à noite', 30;
EXEC Registra_Receita 11, 2, 'senha123?', '07-02-2026', '78912345607', 'Venlafaxina 150mg', 'Tomar 1 cáps pela manhã', 30;
EXEC Registra_Receita 12, 2, 'senha123?', '09-02-2026', '32165498708', 'Gabapentina 300mg', 'Tomar 1 cáps 3x ao dia', 90;
EXEC Registra_Receita 13, 2, 'senha123?', '11-02-2026', '65432198709', 'AAS 100mg', 'Tomar 1 comp ao dia após café', 90;
EXEC Registra_Receita 14, 2, 'senha123?', '13-02-2026', '98732165410', 'Enalapril 10mg', 'Tomar 1 comp ao dia', 30;
EXEC Registra_Receita 15, 2, 'senha123?', '15-02-2026', '14725836901', 'Metilfenidato 10mg', 'Tomar 1 comp manhã e 1 após almoço', 60;
EXEC Registra_Receita 16, 2, 'senha123?', '17-02-2026', '36925814702', 'Duloxetina 60mg', 'Tomar 1 cáps pela manhã', 30;
EXEC Registra_Receita 10, 2, 'senha123', '19-02-2026', '25836914703', 'Pregabalina 150mg', 'Tomar 1 cáps 2x ao dia', 60;
EXEC Desativa_Funcionario '2', 'senha1', 6;
EXEC Reativa_Funcionario '2', 'senha1', 6;
EXEC Desativa_Paciente '26395817042', 'Teste&951';
EXEC Reativa_Paciente '26395817042', 'raquel.correia@email.com';
EXEC Alt_Senha_P '71438629007', 'NovaSenha@2025';
EXEC Alt_Senha_P '28496375041', 'Mudar#Nova123';
EXEC Alt_Senha_P '53714928063', 'TrocaSenha!456';
EXEC Alt_Paciente '84629517038', 'Pass$321', 'gustavo.rocha.novo@email.com', 'Gustavo Rocha Silva', '', '21904567899';
EXEC Alt_Paciente '92837465010', 'Acesso!654', 'larissa.dias.novo@email.com', 'Larissa Dias Santos', 'Lari', '11915678999';
EXEC Alt_Funcionario 20, 'NovaSenhaFunc@123', '9', 'senha7';
EXEC Alt_Funcionario 30, 'SenhaAtualizada#456', '7', 'senha123?';
EXEC Lista_Funcionarios_Empresa '1', 0;
EXEC Lista_Funcionarios_Empresa '6', 1;
EXEC Lista_Funcionarios_Empresa '9', 0;
EXEC Envia_Mensagem_P 7, '26395817042', 'Meloxicam funcionou muito bem! Dor sumiu em 2 dias!';
EXEC Envia_Mensagem_F '26395817042', 7, 'Excelente! Continue por mais 5 dias e pare. Retorno em 15 dias.';
EXEC Envia_Mensagem_P 8, '58174629033', 'Farmácia só tinha genérico do Tramadol. Funciona igual?';
EXEC Envia_Mensagem_F '58174629033', 8, 'Sim! Genérico tem mesma eficácia. Pode usar tranquilo.';
EXEC Envia_Mensagem_P 9, '91827364025', 'Estou me sentindo melhor. Posso parar Ciclobenzaprina?';
EXEC Envia_Mensagem_F '91827364025', 9, 'Não pare sozinho! Complete 14 dias como prescrito. Parada precoce pode causar recaída.';
EXEC Envia_Mensagem_P 10, '43658219076', 'Codeína pode ficar fora da geladeira?';
EXEC Envia_Mensagem_F '43658219076', 10, 'Sim! Guarde em local fresco, seco, protegido da luz. Não precisa geladeira.';
EXEC Envia_Mensagem_P 11, '67291385041', 'Vou viajar para Europa. Pregabalina passa na alfândega?';
EXEC Envia_Mensagem_F '67291385041', 11, 'Leve receita + relatório médico em inglês. Vou preparar. Medicação na embalagem original.';
EXEC Envia_Mensagem_P 12, '85493726058', 'Escitalopram me deu leve enjoo hoje. É normal?';
EXEC Envia_Mensagem_F '85493726058', 12, 'Sim, primeiros dias pode dar enjoo. Tome com alimento. Melhora em 3-5 dias.';
EXEC Envia_Mensagem_P 13, '29846571039', 'Fluoxetina causa dependência?';
EXEC Envia_Mensagem_F '29846571039', 13, 'NÃO! Antidepressivos não causam dependência. Pode ficar tranquila.';
EXEC Envia_Mensagem_P 14, '71528394062', 'Posso comer queijo tomando Venlafaxina?';
EXEC Envia_Mensagem_F '71528394062', 14, 'Sim! Venlafaxina não tem restrição com queijo. Pode comer à vontade.';
EXEC Envia_Mensagem_P 15, '34719628057', 'Esqueci Clonazepam ontem. Tomo 2 hoje?';
EXEC Envia_Mensagem_F '34719628057', 15, 'NÃO! Tome apenas dose de hoje. Nunca dobre dose de controlados.';
EXEC Registra_Receita 11, 2, 'senha123?', '20-02-2026', '71438629007', 'Omeprazol 20mg + Claritromicina 500mg + Amoxicilina 1g', 'Esquema triplo para H.pylori: Omeprazol 2x, Claritro 2x, Amoxi 2x por 14 dias', 1;
EXEC Registra_Receita 12, 2, 'senha123?', '22-02-2026', '28496375041', 'Fluconazol 150mg', 'Tomar 1 cápsula semanal por 6 meses', 24;
EXEC Registra_Receita 13, 2, 'senha123?', '24-02-2026', '53714928063', 'Propranolol 40mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 14, 2, 'senha123?', '26-02-2026', '84629517038', 'Topiramato 25mg', 'Tomar 1 comp 2x ao dia', 60;
EXEC Registra_Receita 15, 2, 'senha123?', '28-02-2026', '92837465010', 'Pregabalina 75mg + Duloxetina 60mg', 'Pregabalina 1 cáps 2x, Duloxetina 1 cáps manhã', 1;

Exec Mostra_Chat '34719628057', 15;
*/