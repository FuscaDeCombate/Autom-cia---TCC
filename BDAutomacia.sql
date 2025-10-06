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
                SELECT 'Erro interno - verifique os dados informados' AS 'Registra_Paciente_Retorno';
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
                SET @CNPJ = LTRIM(RTRIM(@CNPJ));
                SET @Nome_Funcionario = LTRIM(RTRIM(@Nome_Funcionario));
                IF EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ)
                        SET @Empresa = 1;
                IF @Empresa = 1
                BEGIN
                        SELECT @SaltEmpresa = Salt_Contratante, @HashEmpresa = Senha_Hash
                        FROM Contratante WHERE CNPJ = @CNPJ;
                        IF dbo.VerificarSenha(@Senha_Contratante, @SaltEmpresa, @HashEmpresa) = 1
                                SET @VSenha = 1;
                END
                IF (@CNPJ = '') OR (@Nome_Funcionario = '') OR (@Senha_Funcionario = '') OR (LEN(@Senha_Funcionario) < 6)
                        SET @Verificado = 0;

                IF (@Empresa = 1) AND (@Verificado = 1) AND (@VSenha = 1)
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
                        ELSE IF (@VSenha = 0) 
                                SELECT 'Senha da empresa incorreta' AS 'Registra_Funcionario_Retorno';
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
Exec Registra_Funcionario '9', 1, 'Alan Ono Osanai Pan',												'senha123',		'senha7';
Exec Registra_Funcionario '1', 1, 'Alexandre',															'senha123?',	'senha';
Exec Registra_Funcionario '1', 1, 'Allan Alves',														'senha123?',	'senha';
Exec Registra_Funcionario '1', 1, 'André Fabian',														'senha123?',	'senha';
Exec Registra_Funcionario '1', 1, 'Bruno Alves',														'senha123?',	'senha';
Exec Registra_Funcionario '2', 1, 'Caue',																'senha123?',	'senha1';
Exec Registra_Funcionario '9', 1, 'Cayo',																'senha123?',	'senha7';
Exec Registra_Funcionario '2', 1, 'Daniel',																'senha123?',	'senha1';
Exec Registra_Funcionario '2', 1, 'Elisa',																'senha123?',	'senha1';
Exec Registra_Funcionario '3', 2, 'Enzo',																'senha123?',	'senha2';
Exec Registra_Funcionario '3', 2, 'Gabriel Eiki',														'senha123?',	'senha2';
Exec Registra_Funcionario '3', 2, 'Gabriel Gonçalves',													'senha123?',	'senha2';
Exec Registra_Funcionario '4', 2, 'Gabriel Oliveira',													'senha123?',	'senha3';
Exec Registra_Funcionario '4', 2, 'Gabriel Sobral',														'senha123?',	'senha3';
Exec Registra_Funcionario '4', 2, 'Giovanini Urologista',												'senha123?',	'senha3';
Exec Registra_Funcionario '5', 2, 'Heloisa Aiko Uehara',												'senha123?',	'senha4';
Exec Registra_Funcionario '5', 2, 'Henrique Bressan',													'senha123',		'senha4';
Exec Registra_Funcionario '5', 2, 'Joana',																'senha123?',	'senha4';
Exec Registra_Funcionario '9', 2, 'João',																'senha123?',	'senha7';
Exec Registra_Funcionario '9', 3, 'Jonatas',															'senha123?',	'senha7';
Exec Registra_Funcionario '5', 3, 'Jorge',																'senha123?',	'senha4';
Exec Registra_Funcionario '5', 3, 'Juliana',															'senha123?',	'senha4';
Exec Registra_Funcionario '2', 3, 'Karina',																'senha123?',	'senha1';
Exec Registra_Funcionario '4', 3, 'Kaully',																'senha123?',	'senha3';
Exec Registra_Funcionario '4', 3, 'Kelly Park',															'senha123?',	'senha3';
Exec Registra_Funcionario '4', 3, 'Leandro',															'senha123?',	'senha3';
Exec Registra_Funcionario '7', 3, 'Leonardo',												 			'senha123?',	'senha5';
Exec Registra_Funcionario '7', 3, 'Lucas',																'senha123?',	'senha5';
Exec Registra_Funcionario '7', 3, 'Maria Vitória Tavares',												'senha123?',	'senha5';
Exec Registra_Funcionario '7', 4, 'Natália',															'senha123?',	'senha5';
Exec Registra_Funcionario '7', 4, 'Pedro²',																'senha123?',	'senha5';
Exec Registra_Funcionario '8', 4, 'Rafael',																'senha123?',	'senha6';
Exec Registra_Funcionario '8', 4, 'Ricardo',															'senha123?',	'senha6';
Exec Registra_Funcionario '8', 4, 'Rikelme',															'senha123?',	'senha6';
Exec Registra_Funcionario '6', 4, 'Riquelme Brain Rot da SILVA',										'senha123?',	'senhaMuitoBoa';
Exec Registra_Funcionario '6', 4, 'Sophia',																'senha123?',	'senhaMuitoBoa';
Exec Registra_Funcionario '8', 4, 'Teodora',															'senha123?',	'senha6';
Exec Registra_Funcionario '9', 4, 'Victor Hugo',														'senha123?',	'senha7';
Exec Registra_Funcionario '6', 4, 'V King',																'senha123?',	'senhaMuitoBoa';
Exec Registra_Funcionario '6', 4, 'Vítor Pires',														'senha123?',	'senhaMuitoBoa';
Exec Registra_Funcionario '6', 4, 'Vladmir Pudim',														'senha123?',	'senhaMuitoBoa';
EXEC Registra_Funcionario '6', 4, 'Wanderley da Silva Souza de Mata Pera Pereira Vazconselos Oliveira',	'senha123',		'senhaMuitoBoa';
Exec Registra_Funcionario '6', 4, 'Yasmin',																'senha123?',	'senhaMuitoBoa';
EXEC Registra_Paciente '54856098802',	'Alanzoca',		'algumEmail@gmail.com',			'Alan',						'Talvez',						'(55) +11 975793636';
EXEC Registra_Paciente '03674704030',	'Catapimbas12',	'webosi7905@dawhe.com',			'Mike Wazaoski',			'',								'(55) +11 923456789';
EXEC Registra_Paciente '05642844083',	'Bananas',		'rehab1695@uorak.com',			'Raimundo',					'',								'(55) +11 934567890';
EXEC Registra_Paciente '58061315050',	'Platano',		'joao3244@uorak.com',			'João',						'',								'(55) +11 945678901';
EXEC Registra_Paciente '87949685000',	'Pineapple',	'tabitha1366@uorak.com',		'Tabata',					'',								'(55) +11 956789012';
EXEC Registra_Paciente '75974478096',	'Abacaxi',		'jianhui5648@uorak.com',		'Jinora',					'',								'(55) +11 967890123';
EXEC Registra_Paciente '34731605040',	'Manzana',		'binbin3746@uorak.com',			'Bianca',					'',								'(55) +11 978901234';
EXEC Registra_Paciente '51890585068',	'Apple1',		'wilfrido2712@uorak.com',		'Wilfred',					'',								'(55) +11 989012345';
EXEC Registra_Paciente '81112054065',	'Blueberry',	'elane7766@uorak.com',			'Elane',					'',								'(55) +11 990123456';
EXEC Registra_Paciente '53274699055',	'Chia12',		'aroha4333@uorak.com',			'Aron',						'',								'(55) +11 991234567';
EXEC Registra_Paciente '07628546005',	'Protagonista',	'inara3252@uorak.com',			'Irene',					'',								'(55) +11 992345678';
EXEC Registra_Paciente '75286209041',	'Hornet',		'mitzie9696@uorak.com',			'Miriam',					'',								'(55) +11 993456789';
EXEC Registra_Paciente '56470317065',	'Bettle',		'alan2212@uorak.com',			'Aaaaalan',					'',								'(55) +11 994567890';
EXEC Registra_Paciente '19483550009',	'Parmegiana',	'adiela122@uorak.com',			'Kotone Shiomi',			'Not a Princess',				'(55) +11 995678901';
EXEC Registra_Paciente '93729214080',	'Rosbife',		'christopher3650@uorak.com',	'Kris Dremurr',				'Lightner',						'(55) +11 996789012';
EXEC Registra_Paciente '69068097091',	'Risoto',		'rabii3924@uorak.com',			'Keiji Shibusawa',			'Dragon',						'(55) +11 997890123';
EXEC Registra_Paciente '21955621020',	'Macarronada',	'charo1949@uorak.com',			'Carol',					'',								'(55) +11 998901234';
EXEC Registra_Paciente '08924899015',	'Bolonhesa',	'youcef4205@uorak.com',			'Yonatas',					'',								'(55) +11 999012345';
EXEC Registra_Paciente '21524961086',	'Roux12',		'salobral8643@uorak.com',		'Daiseuke Kuse',			'',								'(55) +21 923456789';
EXEC Registra_Paciente '39862328002',	'TortaDeLimao',	'wenche1232@uorak.com',			'Wesley',					'',								'(55) +21 934567890';
EXEC Registra_Paciente '05892157016',	'Banoffe',		'alenjandro7008@uorak.com',		'Alejandro',				'',								'(55) +21 945678901';
EXEC Registra_Paciente '22942383038',	'Cereja',		'amrinder8598@uorak.com',		'Ren Amamiya',				'JOKER',						'(55) +21 956789012';
EXEC Registra_Paciente '43817833016',	'Uva123',		'xantal7174@uorak.com',			'Xantae',					'',								'(55) +21 967890123';
EXEC Registra_Paciente '59784195070',	'Cogumelo',		'orencia5572@uorak.com',		'Ryuji Goda',				'Golden Dragon',				'(55) +21 978901234';
EXEC Registra_Paciente '54273844052',	'Shimeji',		'mayssa77@uorak.com',			'Mayara',					'',								'(55) +21 989012345';
EXEC Registra_Paciente '51971708089',	'Temaki',		'xevi7186@uorak.com',			'Yoshitaka Mine',			'The Kirin',					'(55) +21 990123456';
EXEC Registra_Paciente '58614220014',	'Sushi1',		'josphine8493@uorak.com',		'Josefina',					'',								'(55) +21 991234567';
EXEC Registra_Paciente '21341531058',	'Lamen1',		'dinis8748@uorak.com',			'Dionisio',					'',								'(55) +21 992345678';
EXEC Registra_Paciente '91948947013',	'Gyoza1',		'flors9789@uorak.com',			'Flordis',					'',								'(55) +21 993456789';
EXEC Registra_Paciente '40310919070',	'Taco12',		'penko988@uorak.com',			'Peko Pekoyama',			'Ultmate Martial Swordsman',	'(55) +21 994567890';
EXEC Registra_Paciente '74315582018',	'Burrito',		'khawla7812@uorak.com',			'Kasemiro Walter',			'',								'(55) +21 995678901';
EXEC Registra_Paciente '90934957045',	'Quesadilla',	'husam1393@uorak.com',			'Hugo Messias',				'',								'(55) +21 996789012';
EXEC Registra_Paciente '43014639095',	'Pao123',		'shanna6488@uorak.com',			'Samara',					'Sadaoko',						'(55) +21 997890123';
EXEC Registra_Paciente '33077793032',	'Lasanha',		'noria3789@uorak.com',			'Nori',						'',								'(55) +21 998901234';
EXEC Registra_Paciente '62062052073',	'Virado',		'cherise1512@uorak.com',		'Chiquitita',				'',								'(55) +21 999012345';
EXEC Registra_Paciente '10358560004',	'BaiaoDe2',		'enemesio7189@uorak.com',		'Eneias Pedro',				'',								'(55) +11 923567890';
EXEC Registra_Paciente '47298600044',	'FileMignhon',	'shameka3800@uorak.com',		'Shameka',					'',								'(55) +11 934678901';
EXEC Registra_Paciente '09577340008',	'PureDeBatata',	'espiritu2026@uorak.com',		'Espertino',				'',								'(55) +11 945789012';
EXEC Registra_Paciente '18065460003',	'Bacalhau',		'qasim8524@uorak.com',			'Quasit',					'',								'(55) +11 956890123';
EXEC Registra_Paciente '15150863050',	'Bolo3Leches',	'badara1011@uorak.com',			'Bandara',					'',								'(55) +11 967901234';
EXEC Registra_Paciente '12614706051',	'Panetone',		'margaux4438@uorak.com',		'Margô',					'',								'(55) +11 978012345';
EXEC Registra_Paciente '60030094038',	'Salame',		'koro8923@uorak.com',			'Koromaru',					'Koro-chan',					'(55) +11 989123456';
EXEC Registra_Paciente '74689923043',	'Queijo',		'apolinar7587@uorak.com',		'Péricles',					'',								'(55) +11 990234567';
EXEC Registra_Paciente '40526767006',	'Pizza1',		'dulcelina247@uorak.com',		'Dulcelina',				'',								'(55) +11 991345678';
EXEC Registra_Paciente '13164571097',	'Hamburguer',	'sharilyn2650@uorak.com',		'Shamyn',					'',								'(55) +11 992456789';
EXEC Registra_Paciente '86565804001',	'Beirute',		'ayaz6243@uorak.com',			'Ainz',						'',								'(55) +11 993567890';
EXEC Registra_Paciente '85194921004',	'Shawarma',		'aduen8584@uorak.com',			'Makoto Nijima',			'Queen',						'(55) +11 994678901';
EXEC Registra_Paciente '08343472020',	'Carbonara',	'chengjun9083@uorak.com',		'Cheng',					'',								'(55) +11 995789012';
EXEC Registra_Paciente '75064872097',	'Ossobuco',		'camelia3387@uorak.com',		'Camelia',					'',								'(55) +11 996890123';
EXEC Registra_Paciente '01421826054',	'Kimchi',		'fengqin5714@uorak.com',		'Feng Min',					'',								'(55) +11 997901234';
EXEC Registra_Paciente '05819922026',	'Falafel',		'humilde3571@uorak.com',		'Joao Pereira',				'',								'(55) +11 998012345';
EXEC Registra_Paciente '33342562005',	'Mussarela',	'messoud4453@uorak.com',		'Roberto Pessego',			'',								'(55) +11 999123456';
EXEC Registra_Paciente '82945026007',	'RomeuJulieta',	'nalaya7171@uorak.com',			'Erazor Djin',				'',								'(55) +21 923567890';
EXEC Registra_Paciente '38476344023',	'Cuzcuz',		'clair9757@uorak.com',			'Parcival',					'',								'(55) +21 934678901';
EXEC Registra_Paciente '30964927004',	'Cupim1',		'vidala7446@uorak.com',			'Ammon',					'',								'(55) +21 945789012';
EXEC Registra_Paciente '79021021056',	'Jajamyeon',	'etelvina4121@uorak.com',		'Parfait',					'',								'(55) +21 956890123';
EXEC Registra_Paciente '93379047058',	'Cebola',		'jazmine95@uorak.com',			'Maelle',					'',								'(55) +21 967901234';
EXEC Registra_Paciente '55124371005',	'Robux1',		'wiham8417@uorak.com',			'Clea',						'',								'(55) +21 978012345';
EXEC Registra_Paciente '78762128086',	'V-Bucks',		'huili546@uorak.com',			'Taiga Saejima',			'Tiger',						'(55) +21 989123456';
EXEC Registra_Paciente '42256849031',	'Bibinpap',		'stanford1897@uorak.com',		'Goro Majima',				'Mad Dog of Shimano',			'(55) +21 990234567';
EXEC Registra_Paciente '01400902070',	'Sashimi',		'alyona8632@uorak.com',			'Daigo Dojima',				'',								'(55) +21 991345678';
EXEC Registra_Paciente '49591700008',	'HotRoll',		'moneyba6921@uorak.com',		'Mr MoneyBags Sotenbori',	'',								'(55) +21 992456789';
EXEC Registra_Paciente '53497527076',	'Uramaki',		'obdulio666@uorak.com',			'Shoei Dojima',				'',								'(55) +21 993567890';
EXEC Registra_Paciente '17717478030',	'Naruto',		'shelton9852@uorak.com',		'Boruto Uzumaki',			'',								'(55) +21 994678901';
EXEC Registra_Paciente '96481104092',	'OvoCozido',	'judie4817@uorak.com',			'Tatsuo Shinada',			'Shrimp Man',					'(55) +21 995789012';
EXEC Registra_Paciente '17686975070',	'Pirulito',		'armindo8672@uorak.com',		'Myers',					'Escoteiro Chefe',				'(55) +21 996890123';
EXEC Registra_Paciente '37666471050',	'Marshmallow',	'kathrine2227@uorak.com',		'John Krammer',				'Jigshaw',						'(55) +21 997901234';
EXEC Registra_Paciente '58700766097',	'HotDog',		'florinel5540@uorak.com',		'Haruka Shawamura',			'',								'(55) +21 998012345';
EXEC Registra_Paciente '47077123049',	'Churros',		'shavon8845@uorak.com',			'Don Ramon',				'',								'(55) +21 999123456';
EXEC Registra_Paciente '96939809058',	'Shakra',		'wahab4798@uorak.com',			'Kazuma Kiryu',				'Dragon of Dojima',				'(55) +11 924567890';
EXEC Registra_Paciente '24547397040',	'Poshaka',		'rababe9316@uorak.com',			'Ralsei',					'Fluffy Boy',					'(55) +11 935678901';
EXEC Registra_Paciente '97702083026',	'Bazinga',		'grigore2265@uorak.com',		'Sheldon Copper',			'',								'(55) +11 946789012';
EXEC Registra_Paciente '05483202090',	'Sorvete',		'julija1797@uorak.com',			'Asreiel Dremurr',			'Deus da Hipermorte',			'(55) +11 957890123';
EXEC Registra_Paciente '73930978008',	'SopaDePedra',	'romul6283@uorak.com',			'Suzie',					'',								'(55) +11 968901234';
EXEC Registra_Paciente '54537158042',	'Bis123',		'elinore842@uorak.com',			'Louis Guiabern',			'O Tirano',						'(55) +11 979012345';
EXEC Registra_Paciente '00175474079',	'Chocolate',	'iosune8195@uorak.com',			'Nagito Komaeda',			'Ultmate Luck Student',			'(55) +11 980123456';
EXEC Registra_Paciente '26572689000',	'Miojo',		'hyon1372@uorak.com',			'Hajime Hinata',			'',								'(55) +11 991234568';
EXEC Registra_Paciente '67593704068',	'Camarão',		'yi6061@uorak.com',				'Makoto Naegi',				'Ultmate Hope',					'(55) +11 992345679';
EXEC Registra_Paciente '39867593014',	'agua12',		'sandro7749@uorak.com',			'Gundan Tanaka',			'Ultmate Caretaker',			'(55) +11 993456780';
EXEC Registra_Paciente '42891855094',	'Morango',		'kelly6831@uorak.com',			'Kyotaka',					'Ultmate Moral Compass',		'(55) +11 994567891';
EXEC Registra_Paciente '35295496066',	'Abacate',		'bubutsu@yahho.com',			'Junko Enoshima',			'Ultmate Despair',				'(55) +11 995678902';
EXEC Registra_Paciente '65331943055',	'Guacamole',	'bubutwsubaisein@gay.com',		'Ibuki Mioda',				'Ultmate Musician',				'(55) +11 996789013';
EXEC Registra_Paciente '89961711076',	'Chorizo',		'mojuro@gojokun.com',			'Madeline',					'',								'(55) +11 997890124';
EXEC Registra_Paciente '31895518040',	'Almondega',	'ahitor9468@uorak.com',			'Gerald Robotnik',			'',								'(55) +11 998901235';
EXEC Registra_Paciente '90653374070',	'CarneMoida',	'katarina2569@uorak.com',		'Sulivan',					'',								'(55) +11 999012346';
EXEC Registra_Paciente '46261355010',	'Cupim1',		'ramata3076@uorak.com',			'Dess Holiday',				'Roaring Knight',				'(55) +21 924567890';
EXEC Registra_Paciente '59442913034',	'Picanha',		'mohamedi1885@uorak.com',		'Noelle Holiday',			'',								'(55) +21 935678901';
EXEC Registra_Paciente '13977711008',	'Maminha',		'ilie8901@uorak.com',			'Gladion',					'',								'(55) +21 946789012';
EXEC Registra_Paciente '53595358066',	'Risole',		'doramas872@uorak.com',			'Cyntia',					'',								'(55) +21 957890123';
EXEC Registra_Paciente '87370831043',	'Salgadinho',	'shirl913@uorak.com',			'Volo',						'',								'(55) +21 968901234';
EXEC Registra_Paciente '52546518062',	'PaoDeAlho',	'princess9632@uorak.com',		'Arceus',					'',								'(55) +21 979012345';
EXEC Registra_Paciente '85082610040',	'Tomate',		'yeraldin4890@uorak.com',		'Geralt de Rívia',			'Geralt',						'(55) +21 980123456';
EXEC Registra_Paciente '56858037020',	'Costela',		'gustav6656@uorak.com',			'Yennefer de Vanderberg',	'Yen',							'(55) +21 991234568';
EXEC Registra_Paciente '90226815056',	'Pacu12',		'exuperancio8249@uorak.com',	'Cirila',					'Andorinha',					'(55) +21 992345679';
EXEC Registra_Paciente '63806193053',	'Cookie',		'roumaissa8810@uorak.com',		'Jaskier',					'',								'(55) +21 993456780';
EXEC Registra_Paciente '27788684023',	'Bolo12',		'sefora8192@uorak.com',			'Dandelion',				'',								'(55) +21 994567891';
Exec Registra_Receita 10,	2, 'senha123',	'19-12-2025', '54856098802', 'Dorflex',					'Tomar 3x ao dia',										3;
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