-- ========================================
-- FECHAR CONEXÕES E RECRIAR BANCO
-- ========================================

-- Fechar todas as conexões com o banco Automacia
USE master;
GO

-- Forçar fechamento de conexões
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
-- CONFIGURAÇÃO CORRETA DAS SYMMETRIC KEYS
-- ========================================

-- 1. Criar Master Key (OBRIGATÓRIO para symmetric keys)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@AlAn21220JoRiVi21081/SuperSeguraCompleta2024!';
GO

-- 2. Criar Certificados para proteção adicional (SEM DATA DE EXPIRAÇÃO)
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

-- 3. Criar Symmetric Keys protegidas por certificados
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
-- TABELAS (mesma estrutura, melhorada)
-- ========================================

-- Farmácia/Hospital/Clínica
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

-- Funcionário de Farmácia/Hospital/Clínica
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

-- Historico Medico
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
	('12345678000195', 0x123456, 'Hospital São Paulo', 
	 ENCRYPTBYKEY(KEY_GUID('EnK_Registro_C'), 'SenhaHospital2024!'));

CLOSE SYMMETRIC KEY EnK_Registro_C;
GO

-- ========================================
-- PROCEDURE: REGISTRAR PACIENTE
-- ========================================

CREATE PROCEDURE Registra_Paciente(
	@Paciente_F VARCHAR(11),
	@Senha VARCHAR(32),
	@Email VARCHAR(100),
	@Nome VARCHAR(100),
	@Nome_Social VARCHAR(100),
	@Fonee VARCHAR(20)
) AS 
BEGIN
	DECLARE
		@Paciente_FT VARCHAR(11),
		@SenhaT VARCHAR(32),
		@EmailT VARCHAR(100),
		@NomeT VARCHAR(100),
		@Nome_SocialT VARCHAR(100);
	
	BEGIN TRY
		-- Limpar dados de entrada
		SET @Paciente_FT = REPLACE(@Paciente_F, ' ', '');
		SET @SenhaT = REPLACE(@Senha, ' ', '');
		SET @EmailT = REPLACE(@Email, ' ', '');
		SET @NomeT = LTRIM(RTRIM(@Nome));
		SET @Nome_SocialT = LTRIM(RTRIM(@Nome_Social));

		-- Verificar se há nulos
		IF @Paciente_FT = '' OR @SenhaT = '' OR @EmailT = '' OR @NomeT = ''
		BEGIN
			SELECT 'Preencha todos os campos obrigatórios' As 'Registra_Paciente_Retorno';
			RETURN;
		END

		-- Verificar se CPF já existe
		IF EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @Paciente_FT)
		BEGIN
			SELECT 'CPF já cadastrado no sistema' As 'Registra_Paciente_Retorno';
			RETURN;
		END

		-- Validar email básico
		IF @EmailT NOT LIKE '%@%.%' OR LEN(@EmailT) < 6 OR LEN(@EmailT) > 100
		BEGIN
			SELECT 'Email inválido' As 'Registra_Paciente_Retorno';
			RETURN;
		END

		-- Validar CPF básico
		IF LEN(@Paciente_FT) <> 11
		BEGIN
			SELECT 'CPF deve ter 11 dígitos' As 'Registra_Paciente_Retorno';
			RETURN;
		END

		-- Validar senha
		IF LEN(@SenhaT) < 6
		BEGIN
			SELECT 'Senha deve ter pelo menos 6 caracteres' As 'Registra_Paciente_Retorno';
			RETURN;
		END

		-- Abrir chave e inserir
		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
		
		INSERT INTO Paciente(Paciente_F, Rec_P, Email, Nome_Paciente, Nome_Social, Fone) 
		VALUES (@Paciente_FT, 
				ENCRYPTBYKEY(KEY_GUID('EnK_Rec_P'), @SenhaT), 
				@EmailT, @NomeT, @Nome_SocialT, @Fonee);
		
		CLOSE SYMMETRIC KEY EnK_Rec_P;
		
		SELECT 'Registro concluído com sucesso' As 'Registra_Paciente_Retorno';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
			
		SELECT 'Erro interno: ' + ERROR_MESSAGE() As 'Registra_Paciente_Retorno';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: LOGIN PACIENTE
-- ========================================

CREATE PROCEDURE Login_Paciente(
	@Paciente_F VARCHAR(11),
	@Senha VARCHAR(32)
) AS
BEGIN
	DECLARE @SenhaArmazenada VARCHAR(32);
	
	BEGIN TRY
		-- Verificar se paciente existe
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @Paciente_F AND Ativo = 1)
		BEGIN
			SELECT 'CPF não encontrado ou inativo' As 'Login_Paciente_Retorno';
			RETURN;
		END

		-- Abrir chave e buscar senha
		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY CERTIFICATE Cert_Rec_P;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Rec_P)) 
		FROM Paciente 
		WHERE Paciente_F = @Paciente_F AND Ativo = 1;
		
		CLOSE SYMMETRIC KEY EnK_Rec_P;

		-- Verificar senha
		IF @Senha = @SenhaArmazenada
		BEGIN
			SELECT 
				Paciente_F,
				Nome_Paciente,
				Nome_Social,
				Email,
				Fone,
				'Login realizado com sucesso' as Status
			FROM Paciente 
			WHERE Paciente_F = @Paciente_F AND Ativo = 1;
		END
		ELSE
		BEGIN
			SELECT 'Senha incorreta' As 'Login_Paciente_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Rec_P')
			CLOSE SYMMETRIC KEY EnK_Rec_P;
			
		SELECT 'Erro no login: ' + ERROR_MESSAGE() As 'Login_Paciente_Retorno';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: REGISTRAR FUNCIONÁRIO
-- ========================================

CREATE PROCEDURE Registra_Funcionario(
	@CNPJ VARCHAR(20),
	@ID_Tipo_Funcionario TINYINT,
	@Nome_Funcionario VARCHAR(100),
	@Func_Rec VARCHAR(32),
	@Registro_C VARCHAR(32)
) AS
BEGIN
	DECLARE @SenhaEmpresa VARCHAR(32);
	
	BEGIN TRY
		-- Limpar entrada
		SET @CNPJ = LTRIM(RTRIM(@CNPJ));
		SET @Nome_Funcionario = LTRIM(RTRIM(@Nome_Funcionario));
		SET @Func_Rec = LTRIM(RTRIM(@Func_Rec));
		SET @Registro_C = LTRIM(RTRIM(@Registro_C));

		-- Validações básicas
		IF @CNPJ = '' OR @Nome_Funcionario = '' OR @Func_Rec = '' OR @Registro_C = ''
		BEGIN
			SELECT 'Preencha todos os campos' As 'Registra_Funcionario_Retorno';
			RETURN;
		END

		-- Verificar se empresa existe
		IF NOT EXISTS (SELECT 1 FROM Contratante WHERE CNPJ = @CNPJ)
		BEGIN
			SELECT 'Empresa não encontrada' As 'Registra_Funcionario_Retorno';
			RETURN;
		END

		-- Verificar senha da empresa
		OPEN SYMMETRIC KEY EnK_Registro_C DECRYPTION BY CERTIFICATE Cert_Registro_C;
		
		SELECT @SenhaEmpresa = CONVERT(VARCHAR(32), DECRYPTBYKEY(Registro_C))
		FROM Contratante 
		WHERE CNPJ = @CNPJ;
		
		CLOSE SYMMETRIC KEY EnK_Registro_C;

		IF @SenhaEmpresa <> @Registro_C
		BEGIN
			SELECT 'Senha da empresa incorreta' As 'Registra_Funcionario_Retorno';
			RETURN;
		END

		-- Validar tipo de funcionário
		IF NOT EXISTS (SELECT 1 FROM Tipo_Funcionario WHERE ID_Tipo_Funcionario = @ID_Tipo_Funcionario)
		BEGIN
			SELECT 'Tipo de funcionário inválido' As 'Registra_Funcionario_Retorno';
			RETURN;
		END

		-- Criptografar e inserir funcionário
		OPEN SYMMETRIC KEY EnK_Func_Rec DECRYPTION BY CERTIFICATE Cert_Func_Rec;
		
		INSERT INTO Funcionario (ID_Tipo_Funcionario, Nome_Funcionario, Func_Rec, CNPJ) 
		VALUES (@ID_Tipo_Funcionario, @Nome_Funcionario, 
				ENCRYPTBYKEY(KEY_GUID('EnK_Func_Rec'), @Func_Rec), @CNPJ);
		
		CLOSE SYMMETRIC KEY EnK_Func_Rec;
		
		SELECT 'Funcionário registrado com sucesso' As 'Registra_Funcionario_Retorno';

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Registro_C')
			CLOSE SYMMETRIC KEY EnK_Registro_C;
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Func_Rec')
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
			
		SELECT 'Erro no registro: ' + ERROR_MESSAGE() As 'Registra_Funcionario_Retorno';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: LOGIN FUNCIONÁRIO
-- ========================================

CREATE PROCEDURE Login_Funcionario(
	@Funcionar_Rec INT,
	@Func_Rec VARCHAR(32)
) AS
BEGIN
	DECLARE @SenhaArmazenada VARCHAR(32);
	
	BEGIN TRY
		-- Verificar se funcionário existe
		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @Funcionar_Rec AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário não encontrado ou inativo' As 'Login_Funcionario_Retorno';
			RETURN;
		END

		-- Abrir chave e buscar senha
		OPEN SYMMETRIC KEY EnK_Func_Rec DECRYPTION BY CERTIFICATE Cert_Func_Rec;
		
		SELECT @SenhaArmazenada = CONVERT(VARCHAR(32), DECRYPTBYKEY(Func_Rec)) 
		FROM Funcionario 
		WHERE Funcionar_Rec = @Funcionar_Rec AND Ativo = 1;
		
		CLOSE SYMMETRIC KEY EnK_Func_Rec;

		-- Verificar senha
		IF @Func_Rec = @SenhaArmazenada
		BEGIN
			SELECT 
				f.Funcionar_Rec,
				f.Nome_Funcionario,
				tf.Tipo_Funci,
				c.Nome_Contratante,
				'Login realizado com sucesso' as Status
			FROM Funcionario f
			INNER JOIN Tipo_Funcionario tf ON f.ID_Tipo_Funcionario = tf.ID_Tipo_Funcionario
			INNER JOIN Contratante c ON f.CNPJ = c.CNPJ
			WHERE f.Funcionar_Rec = @Funcionar_Rec AND f.Ativo = 1;
		END
		ELSE
		BEGIN
			SELECT 'Senha incorreta' As 'Login_Funcionario_Retorno';
		END

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Func_Rec')
			CLOSE SYMMETRIC KEY EnK_Func_Rec;
			
		SELECT 'Erro no login: ' + ERROR_MESSAGE() As 'Login_Funcionario_Retorno';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: ENVIAR MENSAGEM (PACIENTE)
-- ========================================

CREATE PROCEDURE Envia_Mensagem_P (
	@ID_Receptor INT,
	@ID_Mensageiro VARCHAR(11),
	@Mensagem VARCHAR(500)
) AS
BEGIN
	BEGIN TRY
		-- Validações
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @ID_Mensageiro AND Ativo = 1)
		BEGIN
			SELECT 'Paciente inválido' As 'Mensagem_Retorno_P';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Receptor AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário inválido' As 'Mensagem_Retorno_P';
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
			
		SELECT 'Erro ao enviar mensagem: ' + ERROR_MESSAGE() As 'Mensagem_Retorno_P';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: ENVIAR MENSAGEM (FUNCIONÁRIO)
-- ========================================

CREATE PROCEDURE Envia_Mensagem_F (
	@ID_Receptor VARCHAR(11),
	@ID_Mensageiro INT,
	@Mensagem VARCHAR(500)
) AS
BEGIN
	BEGIN TRY
		-- Validações
		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @ID_Mensageiro AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário inválido' As 'Mensagem_Retorno_F';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @ID_Receptor AND Ativo = 1)
		BEGIN
			SELECT 'Paciente inválido' As 'Mensagem_Retorno_F';
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
			
		SELECT 'Erro ao enviar mensagem: ' + ERROR_MESSAGE() As 'Mensagem_Retorno_F';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: VER MENSAGENS DESCRIPTOGRAFADAS
-- ========================================

CREATE PROCEDURE Mostra_Chat(
	@Paciente_F_M_Chat VARCHAR(11),
	@Funcionar_Rec_M_Chat INT
) AS
BEGIN
	BEGIN TRY
		-- Validações
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @Paciente_F_M_Chat AND Ativo = 1)
		BEGIN
			SELECT 'Paciente inválido' As 'Retorno_Mostra_Chat';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE Funcionar_Rec = @Funcionar_Rec_M_Chat AND Ativo = 1)
		BEGIN
			SELECT 'Funcionário inválido' As 'Retorno_Mostra_Chat';
			RETURN;
		END

		-- Descriptografar e mostrar mensagens
		OPEN SYMMETRIC KEY EnK_Mensag DECRYPTION BY CERTIFICATE Cert_Mensag;
		
		SELECT 
			ID_Chat,
			Paciente_F,
			Funcionar_Rec,
			CONVERT(VARCHAR(500), DECRYPTBYKEY(Mensagem)) as Mensagem_Texto,
			Hora_Envio,
			CASE 
				WHEN Paciente_F IS NOT NULL THEN 'Paciente'
				ELSE 'Funcionário'
			END as Remetente
		FROM Mensagem 
		WHERE Paciente_F = @Paciente_F_M_Chat 
		  AND Funcionar_Rec = @Funcionar_Rec_M_Chat
		ORDER BY Hora_Envio ASC;
		
		CLOSE SYMMETRIC KEY EnK_Mensag;

	END TRY
	BEGIN CATCH
		IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'EnK_Mensag')
			CLOSE SYMMETRIC KEY EnK_Mensag;
			
		SELECT 'Erro ao mostrar chat: ' + ERROR_MESSAGE() As 'Retorno_Mostra_Chat';
	END CATCH
END
GO

-- ========================================
-- PROCEDURE: VER RECEITAS
-- ========================================

CREATE PROCEDURE Ver_Receita (
	@Paciente_F_Receita VARCHAR(11)
) AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Paciente_F = @Paciente_F_Receita AND Ativo = 1)
		BEGIN
			SELECT 'Paciente inválido' As 'Ver_Receita_Retorno';
			RETURN;
		END

		IF NOT EXISTS (SELECT 1 FROM Receita WHERE Paciente_F = @Paciente_F_Receita)
		BEGIN
			SELECT 'Não há receitas' As 'Ver_Receita_Retorno';
			RETURN;
		END

		SELECT 
			r.ID_Receita,
			r.Data_Receita,
			r.Data_Validade,
			f.Nome_Funcionario as Medico,
			r.Medicamento,
			r.Detalhes,
			r.Limite_Baixas,
			r.Baixas,
			r.Valido,
			CASE 
				WHEN r.Data_Validade < GETDATE() THEN 'Vencida'
				WHEN r.Limite_Baixas IS NOT NULL AND r.Baixas >= r.Limite_Baixas THEN 'Esgotada'
				WHEN r.Valido = 0 THEN 'Inválida'
				ELSE 'Válida'
			END as Status
		FROM Receita r
		INNER JOIN Funcionario f ON r.Funcionar_Rec = f.Funcionar_Rec
		WHERE r.Paciente_F = @Paciente_F_Receita
		ORDER BY r.Data_Receita DESC;

	END TRY
	BEGIN CATCH
		SELECT 'Erro ao buscar receitas: ' + ERROR_MESSAGE() As 'Ver_Receita_Retorno';
	END CATCH
END
GO

-- ========================================
-- TESTES
-- ========================================

-- Testar registro de paciente
EXEC Registra_Paciente '12345678901', 'MinhaSenh@123', 'teste@email.com', 'João Silva', 'João', '(11) 99999-9999';
GO

-- Testar login de paciente
EXEC Login_Paciente '12345678901', 'MinhaSenh@123';
GO

-- Testar registro de funcionário
EXEC Registra_Funcionario '12345678000195', 2, 'Dr. Maria Santos', 'MinhaSenhaFunc123', 'SenhaHospital2024!';
GO

-- Testar login de funcionário
EXEC Login_Funcionario 1, 'MinhaSenhaFunc123';
GO

-- Testar envio de mensagem
EXEC Envia_Mensagem_P 1, '12345678901', 'Olá doutor, preciso de ajuda!';
GO

-- Testar resposta do funcionário
EXEC Envia_Mensagem_F '12345678901', 1, 'Olá! Como posso ajudá-lo?';
GO

-- Ver conversa
EXEC Mostra_Chat '12345678901', 1;
GO

-- Ver receitas
EXEC Ver_Receita '12345678901';
