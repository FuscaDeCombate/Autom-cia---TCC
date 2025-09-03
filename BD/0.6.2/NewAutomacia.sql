-- ========================================
-- SISTEMA AUTOMACIA - VERSÃO COMPLETA E SEGURA
-- ========================================

-- Fechar conexões e recriar banco
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

-- ========================================
-- CONFIGURAÇÃO DE CRIPTOGRAFIA
-- ========================================

-- Criar Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@AlAn21220JoRiVi21081/6969!';
GO

-- Criar Certificados
CREATE CERTIFICATE Cert_Registro_C
WITH SUBJECT = 'Certificado para Registro Contratante';
GO

CREATE CERTIFICATE Cert_Func_Rec
WITH SUBJECT = 'Certificado para Funcionario';
GO

CREATE CERTIFICATE Cert_Rec_P
WITH SUBJECT = 'Certificado para Paciente';
GO

CREATE CERTIFICATE Cert_Mensag
WITH SUBJECT = 'Certificado para Mensagens';
GO

-- Criar Symmetric Keys
CREATE SYMMETRIC KEY EnK_Registro_C 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Registro_C;
GO

CREATE SYMMETRIC KEY EnK_Func_Rec 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Func_Rec;
GO

CREATE SYMMETRIC KEY EnK_Rec_P 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Rec_P;
GO

CREATE SYMMETRIC KEY EnK_Mensag 
WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Mensag;
GO

-- ========================================
-- TABELAS
-- ========================================

-- Contratante (Farmácia/Hospital/Clínica)
CREATE TABLE Contratante (
	CNPJ VARCHAR(20) UNIQUE NOT NULL,
	Documentacao VARBINARY(MAX) NOT NULL,
	Nome_Contratante VARCHAR(100) NOT NULL,
	Registro_C VARBINARY(256) NOT NULL,
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
	Func_Rec VARBINARY(256) NOT NULL,
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
	Rec_P VARBINARY(256) NOT NULL,
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

-- ========================================
-- ÍNDICES
-- ========================================

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

-- Inserir contratante de exemplo
OPEN SYMMETRIC KEY EnK_Registro_C DECRYPTION BY CERTIFICATE Cert_Registro_C;

INSERT INTO Contratante (CNPJ, Documentacao, Nome_Contratante, Registro_C) VALUES
	('1', 0x123456, 'Empresa Teste', 
	 ENCRYPTBYKEY(KEY_GUID('EnK_Registro_C'), 'senha'));

CLOSE SYMMETRIC KEY EnK_Registro_C;
GO

-- ========================================
-- STORED PROCEDURES
-- ========================================

-- REGISTRAR PACIENTE
CREATE PROCEDURE Registra_Paciente(
	@CPF VARCHAR(11),
	@Senha VARCHAR(32),
	@Email VARCHAR(100),
	@Nome VARCHAR(100),
	@Nome_Social VARCHAR(100),
	@Fonee VARCHAR(20)
) AS 
BEGIN
	DECLARE
		@RetornoCPF BIT = 0,
		@RetornoNull BIT = 0,
		@RetornoEmail BIT = 1,
		@RetornoSenha BIT = 1,
		@CPFT VARCHAR(11),
		@SenhaT VARCHAR(32),
		@EmailT VARCHAR(100),
		@NomeT VARCHAR(100),
		@Nome_SocialT VARCHAR(100);
	
	BEGIN TRY
		-- Limpar dados de entrada
		SET @CPFT = REPLACE(@CPF, ' ', '');
		SET @SenhaT = REPLACE(@Senha, ' ', '');
		SET @EmailT = REPLACE(@Email, ' ', '');
		SET @NomeT = LTRIM(RTRIM(@Nome));
		SET @Nome_SocialT = LTRIM(RTRIM(@Nome_Social));

		-- Verificar nulos
		IF @CPFT = '' OR @SenhaT = '' OR @EmailT = '' OR @NomeT = ''
			SET @RetornoNull = 0;
		ELSE
			SET @RetornoNull = 1;

		-- Validação básica de email
		IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100
			SET @RetornoEmail = 0;

		-- Validação básica de CPF
		IF LEN(@CPFT) = 11 AND ISNUMERIC(@CPFT) = 1
			SET @RetornoCPF = 1;

		-- Validação de senha
		IF LEN(@SenhaT) >= 6
			SET @RetornoSenha = 1;
		ELSE
			SET @RetornoSenha = 0;

		-- Verificar se CPF já existe
		IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPFT)
		BEGIN
			SELECT 'CPF já cadastrado' As 'Registra_Paciente_Retorno';
			RETURN;
		END

		IF @RetornoNull = 0 OR @RetornoCPF = 0 OR @RetornoEmail = 0 OR @RetornoSenha = 0
		BEGIN
			IF (@RetornoNull = 0) SELECT 'Digite algo' As 'Registra_Paciente_Retorno';
			ELSE IF (@RetornoCPF = 0) SELECT 'CPF Inválido' As 'Registra_Paciente_Retorno';
			ELSE IF (@RetornoEmail = 0) SELECT 'Email Inválido' As 'Registra_Paciente_Retorno';
			ELSE IF (@RetornoSenha = 0) SELECT 'Senha Inválida' As 'Registra_Paciente_Retorno';
		END
		ELSE 
		BEGIN
			-- Criptografar e inserir
			OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
			
			INSERT INTO Paciente(Paciente_F, Rec_P, Email, Nome_Paciente, Nome_Social, Fone) 
			VALUES (@CPFT, ENCRYPTBYKEY(KEY_GUID('EnK_Rec_P'), @SenhaT), 
					@EmailT, @NomeT, @Nome_SocialT, @Fonee);
			
			CLOSE SYMMETRIC KEY EnK_Rec_P;
			
			SELECT 'Registro Concluido' As 'Registra_Paciente_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
		SELECT 'Informações inválidas' As 'Registra_Paciente_Retorno';
	END CATCH
END
GO

-- LOGIN PACIENTE
CREATE PROCEDURE Login_Paciente(
	@CPF VARCHAR(11),
	@Senha VARCHAR(32)
) AS
BEGIN
	DECLARE @SenhaArmazenada VARCHAR(32);
	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Login_Paciente_Retorno';
			RETURN;
		END

		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Rec_P)) 
		FROM Paciente WHERE Paciente_F = @CPF AND Ativo = 1;
		
		CLOSE SYMMETRIC KEY EnK_Rec_P;

		IF @Senha = @SenhaArmazenada
		BEGIN
			SELECT * FROM Paciente WHERE Paciente_F = @CPF;
		END
		ELSE
		BEGIN
			SELECT 'Senha Inválida' As 'Login_Paciente_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
		SELECT 'Informações Inválidas' As 'Login_Paciente_Retorno';
	END CATCH
END
GO

-- REGISTRAR FUNCIONÁRIO
CREATE PROCEDURE Registra_Funcionario(
	@CNPJ VARCHAR(20),
	@ID_Tipo_Funcionario TINYINT,
	@Nome_Funcionario VARCHAR(100),
	@Senha_Funcionario VARCHAR(32),
	@Senha_Contratante VARCHAR(32)
) AS
BEGIN
	DECLARE
		@SenhaEmpresa VARCHAR(32),
		@Verificado BIT = 1,
		@Empresa BIT = 0,
		@VSenha BIT = 0;
	
	BEGIN TRY
		-- Limpar entrada
		SET @CNPJ = LTRIM(RTRIM(@CNPJ));
		SET @Nome_Funcionario = LTRIM(RTRIM(@Nome_Funcionario));

		-- Verificar se empresa existe
		SET @Empresa = CASE WHEN EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ) THEN 1 ELSE 0 END;

		-- Verificar senha da empresa
		IF @Empresa = 1
		BEGIN
			OPEN SYMMETRIC KEY EnK_Registro_C DECRYPTION BY CERTIFICATE Cert_Registro_C;
			
			SELECT @SenhaEmpresa = CONVERT(VARCHAR(32), DECRYPTBYKEY(Registro_C))
			FROM Contratante WHERE CNPJ = @CNPJ;
			
			CLOSE SYMMETRIC KEY EnK_Registro_C;

			IF @SenhaEmpresa = @Senha_Contratante
				SET @VSenha = 1;
		END

		-- Verificar campos nulos
		IF (@CNPJ = '') OR (@Nome_Funcionario = '') OR (@Senha_Funcionario = '')
			SET @Verificado = 0;

		IF (@Empresa = 1) AND (@Verificado = 1) AND (@VSenha = 1)
		BEGIN
			OPEN SYMMETRIC KEY EnK_Func_Rec DECRYPTION BY CERTIFICATE Cert_Func_Rec;
			
			INSERT INTO Funcionario (ID_Tipo_Funcionario, Nome_Funcionario, Func_Rec, CNPJ) 
			VALUES (@ID_Tipo_Funcionario, @Nome_Funcionario, 
					ENCRYPTBYKEY(KEY_GUID('EnK_Func_Rec'), @Senha_Funcionario), @CNPJ);
			
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
			
			SELECT 'Registro Concluido' As 'Registra_Funcionario_Retorno';
		END
		ELSE
		BEGIN
			IF (@Empresa = 0) SELECT 'Empresa Inválida' As 'Registra_Funcionario_Retorno';
			ELSE IF (@Verificado = 0) SELECT 'Preencha todos os campos' As 'Registra_Funcionario_Retorno';
			ELSE IF (@VSenha = 0) SELECT 'Senha da empresa incorreta' As 'Registra_Funcionario_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Registro_C')
			CLOSE SYMMETRIC KEY EnK_Registro_C;
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Func_Rec')
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
		SELECT 'Informações Inválidas' As 'Registra_Funcionario_Retorno';
	END CATCH
END
GO

-- LOGIN FUNCIONÁRIO
CREATE PROCEDURE Login_Funcionario(
	@ID_Funcionario INT,
	@Senha_Funcionario VARCHAR(32)
) AS
BEGIN
	DECLARE @SenhaArmazenada VARCHAR(32);
	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
		BEGIN
			SELECT 'Usuário Inválido' As 'Login_Funcionario_Retorno';
			RETURN;
		END

		OPEN SYMMETRIC KEY EnK_Func_Rec DECRYPTION BY CERTIFICATE Cert_Func_Rec;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Func_Rec)) 
		FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1;
		
		CLOSE SYMMETRIC KEY EnK_Func_Rec;

		IF @Senha_Funcionario = @SenhaArmazenada
		BEGIN
			SELECT * FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario;
		END
		ELSE
		BEGIN
			SELECT 'Senha Inválida' As 'Login_Funcionario_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Func_Rec')
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
		SELECT 'Informações Inválidas' As 'Login_Funcionario_Retorno';
	END CATCH
END
GO

-- REGISTRAR RECEITA
CREATE PROCEDURE Registra_Receita (
	@ID_Funcionario INT,
	@Tipo_Funcionario_R TINYINT,
	@Senha_Funcionario VARCHAR(32),
	@Data_Validade DATE,
	@CPF_Receita VARCHAR(11),
	@Medicamento VARCHAR(200),
	@Detalhes VARCHAR(500),
	@Limite_Baixas TINYINT
) AS
BEGIN
	DECLARE
		@ID_Funcionario_R BIT = 0,
		@Senha_Funcionario_R BIT = 0,
		@CPF_Receita_R BIT = 0,
		@SenhaArmazenada VARCHAR(32);

	BEGIN TRY
		-- Verificar funcionário
		IF EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario AND Ativo = 1)
			SET @ID_Funcionario_R = 1;

		-- Verificar senha funcionário
		IF @ID_Funcionario_R = 1
		BEGIN
			OPEN SYMMETRIC KEY EnK_Func_Rec DECRYPTION BY CERTIFICATE Cert_Func_Rec;
			
			SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Func_Rec))
			FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario;
			
			CLOSE SYMMETRIC KEY EnK_Func_Rec;

			IF @SenhaArmazenada = @Senha_Funcionario
				SET @Senha_Funcionario_R = 1;
		END

		-- Verificar paciente
		IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Receita AND Ativo = 1)
			SET @CPF_Receita_R = 1;

		-- Limitar baixas nulo se for zero
		IF @Limite_Baixas = 0
			SET @Limite_Baixas = NULL;

		-- Verificações finais e inserção
		IF (@ID_Funcionario_R = 1) AND (@Senha_Funcionario_R = 1) AND (@Tipo_Funcionario_R = 2) AND (@CPF_Receita_R = 1)
		BEGIN
			INSERT INTO Receita (Funcionar_Rec, Data_Validade, Medicamento, Detalhes, Limite_Baixas, Paciente_F, Valido, Baixas) 
			VALUES (@ID_Funcionario, @Data_Validade, @Medicamento, @Detalhes, @Limite_Baixas, @CPF_Receita, 1, 0);
			
			SELECT 'Receita Criada' As 'Retorno_Registra_Receita';
		END
		ELSE IF (@ID_Funcionario_R = 0) SELECT 'Funcionário Inválido' As 'Retorno_Registra_Receita';
		ELSE IF (@Senha_Funcionario_R = 0) SELECT 'Senha Inválida' As 'Retorno_Registra_Receita';
		ELSE IF (@Tipo_Funcionario_R != 2) SELECT 'Funcionário não tem permissão' As 'Retorno_Registra_Receita';
		ELSE IF (@CPF_Receita_R = 0) SELECT 'CPF Inválido' As 'Retorno_Registra_Receita';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Func_Rec')
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
		SELECT 'Informações Inválidas' As 'Retorno_Registra_Receita';
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
			SELECT 'Não há Receitas' As 'Ver_Receita_Retorno';
			RETURN;
		END

		SELECT * FROM Receita WHERE Paciente_F = @CPF_Receita;

	END TRY
	BEGIN CATCH
		SELECT 'Informações Inválidas' As 'Ver_Receita_Retorno';
	END CATCH
END
GO

-- ALTERAR RECEITA (dar baixa)
CREATE PROCEDURE Altera_Receita (
	@ID_Funcionario_Alt INT,
	@Senha_Funcionario_Alt VARCHAR(32),
	@CPF_Alt VARCHAR(11),
	@ID_Receita INT
) AS
BEGIN
	DECLARE
		@SenhaArmazenada VARCHAR(32),
		@Tipo_Funcionario_Alt TINYINT,
		@Limite_Baixas_Alt TINYINT,
		@Baixas_Atual TINYINT;

	BEGIN TRY
		-- Verificações básicas
		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_Alt AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário Inválido' As 'Retorno_Altera_Receita';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Alt AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Retorno_Altera_Receita';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Receita WHERE ID_Receita = @ID_Receita)
		BEGIN
			SELECT 'Receita Inválida' As 'Retorno_Altera_Receita';
			RETURN;
		END

		-- Verificar senha funcionário
		OPEN SYMMETRIC KEY EnK_Func_Rec DECRYPTION BY CERTIFICATE Cert_Func_Rec;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Func_Rec)),
			   @Tipo_Funcionario_Alt = ID_Tipo_Funcionario
		FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_Alt;
		
		CLOSE SYMMETRIC KEY EnK_Func_Rec;

		IF @SenhaArmazenada != @Senha_Funcionario_Alt
		BEGIN
			SELECT 'Senha Inválida' As 'Retorno_Altera_Receita';
			RETURN;
		END

		IF @Tipo_Funcionario_Alt != 1
		BEGIN
			SELECT 'Funcionário não tem permissão' As 'Retorno_Altera_Receita';
			RETURN;
		END

		-- Verificar limite de baixas
		SELECT @Limite_Baixas_Alt = Limite_Baixas, @Baixas_Atual = Baixas
		FROM Receita WHERE ID_Receita = @ID_Receita;

		IF @Limite_Baixas_Alt IS NOT NULL AND @Baixas_Atual >= @Limite_Baixas_Alt
		BEGIN
			SELECT 'Não é possível dar mais baixas' As 'Retorno_Altera_Receita';
			RETURN;
		END

		-- Dar baixa
		UPDATE Receita SET Baixas = (Baixas + 1) WHERE ID_Receita = @ID_Receita;
		SELECT 'Baixa dada com sucesso' As 'Retorno_Altera_Receita';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Func_Rec')
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
		SELECT 'Informações Inválidas' As 'Retorno_Altera_Receita';
	END CATCH
END
GO

-- INSERIR HISTÓRICO
CREATE PROCEDURE Insere_Historico(
	@CPF_Rec VARCHAR(11),
	@Senha_Paciente_Rec VARCHAR(32),
	@Historico_Arqui VARBINARY(MAX)
) AS
BEGIN
	DECLARE @SenhaArmazenada VARCHAR(32);
	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Rec AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Retorno_Registra_Historico';
			RETURN;
		END

		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Rec_P))
		FROM Paciente WHERE Paciente_F = @CPF_Rec;
		
		CLOSE SYMMETRIC KEY EnK_Rec_P;

		IF @SenhaArmazenada = @Senha_Paciente_Rec
		BEGIN
			INSERT INTO Historico_Medico (Paciente_F, Registro_Medico) 
			VALUES (@CPF_Rec, @Historico_Arqui);
			SELECT 'Inserção feita' As 'Retorno_Registra_Historico';
		END
		ELSE
		BEGIN
			SELECT 'Senha Inválida' As 'Retorno_Registra_Historico';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
		SELECT 'Informações Inválidas' As 'Retorno_Registra_Historico';
	END CATCH
END
GO

-- VER HISTÓRICO (PACIENTE)
CREATE PROCEDURE Ver_Historico_Paciente (
	@CPF_V_Historico_Pac VARCHAR(11),
	@Senha_V_Historico_Pac VARCHAR(32)
) AS
BEGIN
	DECLARE @SenhaArmazenada VARCHAR(32);
	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_V_Historico_Pac AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Retorno_Ver_Histórico';
			RETURN;
		END

		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Rec_P))
		FROM Paciente WHERE Paciente_F = @CPF_V_Historico_Pac;
		
		CLOSE SYMMETRIC KEY EnK_Rec_P;

		IF @SenhaArmazenada = @Senha_V_Historico_Pac
		BEGIN
			SELECT Registro_Medico FROM Historico_Medico WHERE Paciente_F = @CPF_V_Historico_Pac;
		END
		ELSE
		BEGIN
			SELECT 'Senha Inválida' As 'Retorno_Ver_Histórico';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
		SELECT 'Informações Inválidas' As 'Retorno_Ver_Histórico';
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
			SELECT 'CPF Inválido' As 'Mensagem_Retorno_P';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Receptor AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário Inválido' As 'Mensagem_Retorno_P';
			RETURN;
		END

		-- Criptografar e inserir mensagem
		OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
		
		INSERT INTO Mensagem (Paciente_F, Funcionar_Rec, Mensagem) 
		VALUES (@ID_Mensageiro, @ID_Receptor, 
				ENCRYPTBYKEY(KEY_GUID('EnK_Mensag'), @Mensagem));
		
		CLOSE SYMMETRIC KEY EnK_Mensag;
		
		SELECT 'Mensagem enviada com sucesso' As 'Mensagem_Retorno_P';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
			CLOSE SYMMETRIC KEY EnK_Mensag;
		SELECT 'Informações inválidas' As 'Mensagem_Retorno_P';
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
			SELECT 'Funcionário Inválido' As 'Mensagem_Retorno_F';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @ID_Receptor AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Mensagem_Retorno_F';
			RETURN;
		END

		-- Criptografar e inserir mensagem
		OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
		
		INSERT INTO Mensagem (Paciente_F, Funcionar_Rec, Mensagem) 
		VALUES (@ID_Receptor, @ID_Mensageiro, 
				ENCRYPTBYKEY(KEY_GUID('EnK_Mensag'), @Mensagem));
		
		CLOSE SYMMETRIC KEY EnK_Mensag;
		
		SELECT 'Mensagem enviada com sucesso' As 'Mensagem_Retorno_F';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
			CLOSE SYMMETRIC KEY EnK_Mensag;
		SELECT 'Informações inválidas' As 'Mensagem_Retorno_F';
	END CATCH
END
GO

-- ALTERAR PACIENTE
CREATE PROCEDURE Alt_Paciente(
	@CPF_Alt_P VARCHAR(11),
	@Senha_Alt_P VARCHAR(32),
	@Email_Alt_P VARCHAR(100),
	@Nome_Alt_P VARCHAR(100),
	@Nome_Social_Alt_P VARCHAR(100)
) AS 
BEGIN
	DECLARE 
		@RetornoEmail BIT = 1,
		@SenhaArmazenada VARCHAR(32),
		@EmailT VARCHAR(100);

	BEGIN TRY
		SET @EmailT = REPLACE(@Email_Alt_P, ' ', '');

		-- Validação básica de email
		IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100
			SET @RetornoEmail = 0;

		-- Verificar CPF e senha
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @CPF_Alt_P AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Retorono_Altera_Paciente';
			RETURN;
		END

		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Rec_P))
		FROM Paciente WHERE Paciente_F = @CPF_Alt_P;
		
		CLOSE SYMMETRIC KEY EnK_Rec_P;

		IF @SenhaArmazenada != @Senha_Alt_P
		BEGIN
			SELECT 'Senha Inválida' As 'Retorono_Altera_Paciente';
			RETURN;
		END

		IF @RetornoEmail = 0
		BEGIN
			SELECT 'Email Inválido' As 'Retorono_Altera_Paciente';
			RETURN;
		END

		-- Realizar alterações
		UPDATE Paciente SET 
			Email = @EmailT,
			Nome_Paciente = @Nome_Alt_P,
			Nome_Social = @Nome_Social_Alt_P 
		WHERE Paciente_F = @CPF_Alt_P;
		
		SELECT 'Alterações Concluidas' As 'Retorono_Altera_Paciente';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
		SELECT 'Informações Inválidas' As 'Retorono_Altera_Paciente';
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
			SELECT 'CPF Inválido' As 'Retorno_Mostra_Chat';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Funcionario_M_Chat AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário Inválido' As 'Retorno_Mostra_Chat';
			RETURN;
		END

		-- Descriptografar e mostrar mensagens
		OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
		
		SELECT 
			CONVERT(VARCHAR(500), DECRYPTBYKEY(Mensagem)) as Mensagem
		FROM Mensagem 
		WHERE Paciente_F = @CPF_M_Chat 
		  AND Funcionar_Rec = @ID_Funcionario_M_Chat
		ORDER BY Hora_Envio ASC;
		
		CLOSE SYMMETRIC KEY EnK_Mensag;

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
			CLOSE SYMMETRIC KEY EnK_Mensag;
		SELECT 'Informações Inválidas' As 'Retorno_Mostra_Chat';
	END CATCH
END
GO

-- ALTERAR SENHA PACIENTE
CREATE PROCEDURE Alt_Senha_P(
	@Alt_CPF VARCHAR(11),
	@Alt_Senha VARCHAR(32)
) AS
BEGIN
	DECLARE @Alt_Senha_R BIT = 0;
	
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @Alt_CPF AND Ativo = 1)
		BEGIN
			SELECT 'CPF Inválido' As 'Alt_Senha_Retorno';
			RETURN;
		END

		IF LEN(@Alt_Senha) >= 6
			SET @Alt_Senha_R = 1;

		IF @Alt_Senha_R = 1
		BEGIN
			OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
			
			UPDATE Paciente SET Rec_P = ENCRYPTBYKEY(KEY_GUID('EnK_Rec_P'), @Alt_Senha) 
			WHERE Paciente_F = @Alt_CPF;
			
			CLOSE SYMMETRIC KEY EnK_Rec_P;
			
			SELECT 'Senha alterada com sucesso' As 'Alt_Senha_Retorno';
		END
		ELSE
		BEGIN
			SELECT 'Senha Inválida' As 'Alt_Senha_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
		SELECT 'Informações Inválidas' As 'Alt_Senha_Retorno';
	END CATCH
END
GO

-- ========================================
-- TRIGGER E PROCEDURE DE MANUTENÇÃO
-- ========================================

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
		
		SELECT 'Uma receita sofreu baixa' As 'Retorno_Trigger_Validade_R';
	END TRY
	BEGIN CATCH
		SELECT 'Erro no trigger' As 'Retorno_Trigger_Validade_R';
	END CATCH
END
GO

-- PROCEDURE: Atualizar receitas vencidas
CREATE PROCEDURE Atualiza_Receita AS 
BEGIN
	BEGIN TRY
		-- Invalidar receitas vencidas
		UPDATE Receita 
		SET Valido = 0 
		WHERE Data_Validade < CAST(GETDATE() AS DATE) 
		  AND Valido = 1;
		  
		SELECT 'Receitas atualizadas' As 'Retorno_Atualiza_Receita';
	END TRY
	BEGIN CATCH
		SELECT 'Erro ao atualizar receitas' As 'Retorno_Atualiza_Receita';
	END CATCH
END
GO

-- ========================================
-- TESTES COMPLETOS
-- ========================================

-- Teste 1: Registrar Paciente
EXEC Registra_Paciente '54856098802', 'Alanzoca', 'algumEmail@gmail.com', 'Alan', 'Talvez', '(55) +11 975793636';
GO

-- Teste 2: Login Paciente
EXEC Login_Paciente '54856098802', 'Alanzoca';
GO

-- Teste 3: Registrar Funcionário
EXEC Registra_Funcionario '1', 1, 'Wanderley', 'senha123', 'senha';
GO

-- Teste 4: Login Funcionário
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

-- ========================================
-- VERIFICAÇÕES FINAIS
-- ========================================

-- Ver dados inseridos
SELECT 'Contratantes' as Tabela, COUNT(*) as Total FROM Contratante
UNION ALL
SELECT 'Pacientes', COUNT(*) FROM Paciente
UNION ALL
SELECT 'Funcionarios', COUNT(*) FROM Funcionario
UNION ALL
SELECT 'Receitas', COUNT(*) FROM Receita
UNION ALL
SELECT 'Mensagens', COUNT(*) FROM Mensagem;
GO

-- Verificar chaves simétricas
SELECT name as 'Chaves_Simetricas' FROM sys.symmetric_keys WHERE name LIKE 'EnK_%';
GO