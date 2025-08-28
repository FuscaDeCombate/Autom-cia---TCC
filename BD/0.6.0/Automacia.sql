Use master
Go
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Automacia')
	DROP DATABASE Automacia;
Go
CREATE DATABASE Automacia;
Go
Use Automacia;
Go
Set dateformat DMY;
Go
--================================================================================================================================--
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '@AlAn21220JoRiVi21081/';

CREATE SYMMETRIC KEY EnK_Registro_C WITH ALGORITHM = AES_256 ENCRYPTION BY PASSWORD = 'Senha_Registro_C';
CREATE SYMMETRIC KEY EnK_Func_Rec WITH ALGORITHM = AES_256 ENCRYPTION BY PASSWORD = 'Senha_Func_Rec';
CREATE SYMMETRIC KEY EnK_Rec_P WITH ALGORITHM = AES_256 ENCRYPTION BY PASSWORD = 'Senha_Rec_P';
CREATE SYMMETRIC KEY EnK_Mensag WITH ALGORITHM = AES_256 ENCRYPTION BY PASSWORD = 'Senha_Mensag';
--================================================================================================================================--
Go
--Farm�cia/Hospital/Cl�nica
Create Table Contratante (
	CNPJ Varchar Unique Not null,
	Documentacao VarBinary(max) Not null,
	Nome_Contratante Varchar(50) Not null,
	--Varchar(32)
	Registro_C VarBinary(256) Not null,
	Primary Key (CNPJ)
);

--Tipo de Funcion�rio
Create Table Tipo_Funcionario (
	ID_Tipo_Funcionario TINYINT,
	Tipo_Funci Varchar(22),
	Primary Key (ID_Tipo_Funcionario)
);

--Funcion�rio de Farm�cia/Hospital/Cl�nica
Create Table Funcionario (
	Funcionar_Rec INT Identity Unique Not null,
	ID_Tipo_Funcionario TINYINT Not null,
	CNPJ Varchar Not null,
	--Varchar(32)
	Func_Rec VarBinary(256) Not null,
	Nome_Funcionario Varchar(50) Not null,
	Primary Key (Funcionar_Rec),
	Foreign Key (ID_Tipo_Funcionario) References Tipo_Funcionario(ID_Tipo_Funcionario),
	Foreign Key (CNPJ) References Contratante(CNPJ)
);

--Paciente
Create Table Paciente (
	Paciente_F Varchar(11) Unique Not null,
	--Varchar(32)
	Rec_P VarBinary(256) Not null,
	Email Varchar(45),
	Fone Varchar(16),
	Nome_Paciente Varchar(50) Not null,
	Nome_Social Varchar(50) Not null,
	Primary Key (Paciente_F)
);

--Receita
Create Table Receita (
	ID_Receita INT Identity Not null,
	Data_Receita Date Not null,
	Data_Validade Date Not null,
	Funcionar_Rec INT Not null,
	Paciente_F Varchar(11) Not null,
	Medicamento Varchar(100) Not null,
	Detalhes Varchar(300),
	Limite_Baixas Tinyint,
	Valido Bit,
	Baixas Tinyint,
	Primary Key (ID_Receita),
	Foreign Key (Funcionar_Rec) References Funcionario(Funcionar_Rec),
	Foreign Key (Paciente_F) References Paciente(Paciente_F)
);

--Historico Medico
Create Table Historico_Medico (
	ID_Historico INT Identity Not null,
	Paciente_F Varchar(11) Not null,
	Registro_Medico VarBinary(max) Not null,
	Primary Key (ID_Historico),
	Foreign Key (Paciente_F) References Paciente(Paciente_F)
);

--Mensagem
Create Table Mensagem (
	ID_Chat INT Identity,
	Paciente_F Varchar(11),
	Funcionar_Rec INT,
	--Varchar(255)
	Mensagem VarBinary(max),
	Hora_Envio DateTime,
	Primary Key (ID_Chat),
	Foreign Key (Paciente_F) References Paciente(Paciente_F),
	Foreign Key (Funcionar_Rec) References Funcionario(Funcionar_Rec)
);

/*
Como Monitorar o identificador o tornando algo que pode ser Paciente_F e Funcionar_Rec?
*/
Go

Create Index IDX_CNPJ On Contratante(CNPJ);
Create Index IDX_Paciente_F On Paciente(Paciente_F);
Create Index IDX_Funcionar_Rec On Funcionario(Funcionar_Rec);
Create Index IDX_ID_Receita On Receita(ID_Receita);
Create Index IDX_ID_Historico On Historico_Medico(ID_Historico);
Create Index IDX_ID_Chat On Mensagem(ID_Chat);

Go

Insert Into Tipo_Funcionario (ID_Tipo_Funcionario, Tipo_Funci) Values
	(1, 'Funcionario Farm�cia'),
	(2, 'Funcionario Saude'),
	(3, 'Administrador Farmacia'),
	(4, 'Administrador Hospital');

Go
Open Symmetric Key EnK_Registro_C Decryption by Password = 'Senha_Registro_C';
INSERT Into Contratante (CNPJ, Documentacao, Nome_Contratante, Registro_C) Values
	(1, 66656, 'Empresa Teste', ENCRYPTBYKEY(KEY_GUID('EnK_Registro_C'), 'senha'));
Close Symmetric Key EnK_Registro_C
Go

--Procedure para registrar Paciente
Create Procedure Registra_Paciente(
	@Paciente_F Varchar(11),
	@Senha Varchar(32),
	@Email Varchar(45),
	@Nome Varchar(50),
	@Nome_Social Varchar(50),
	@Fonee Varchar(16)
	) As 
		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY PASSWORD = 'Senha_Rec_P';
		Declare
			@RetornoPaciente_F Bit,
			@RetornoNull Bit,
			@RetornoEmail Bit,
			@RetornoSenha Bit,

			@Paciente_FT Varchar(14),
			@SenhaT Varchar(32),
			@EmailT Varchar(45),
			@NomeT Varchar(50),
			@Nome_SocialT Varchar(50),

			@Veri1 Bit,
			@Veri2 Bit,
			@Veri3 Bit,
			@Veri4 Bit,
			@Veri5 Bit,
			@Veri6 Bit,

			@INDICE INT,
			@SOMA INT,
			@DIG1 INT,
			@DIG2 INT,
			@Paciente_F_TEMP VARCHAR(11),
			@DIGITOS_IGUAIS CHAR(1);
		
		Set @RetornoPaciente_F = 0;
		Set @RetornoNull = 0;
		Set @RetornoEmail = 1;
		Set @RetornoSenha = 1;

		--Trim nas variaveis
		Set @Paciente_FT = REPLACE(@Paciente_F, ' ', '');
		Set @SenhaT = REPLACE(@Senha, ' ', '');
		Set @EmailT = REPLACE(@Email, ' ', '');
		Set @NomeT = Trim(@Nome);
		Set @Nome_SocialT = Trim(@Nome_Social);

		Begin Try

		--Verifica se h� nulos
		
		If @Paciente_FT = '' or @SenhaT = '' or @EmailT = '' or @NomeT = ''
			Begin
				Set @RetornoNull = 0
			End
		Else
			Begin
				Set @RetornoNull = 1
			End

		--Verifica se � email v�lido
		Set @Veri1 = 0;
		Set @Veri2 = 0;
		Set @Veri3 = 0;
		Set @Veri4 = 0;
		Set @Veri5 = 0;
		Set @Veri6 = 0;

		While (@Veri1 = 0 or @Veri2 = 0 or @Veri3 = 0 or @Veri4 = 0 or @Veri5 = 0 or @Veri6 = 0)
			Begin
				IF CHARINDEX('@', @EmailT) = 0
					Begin
						Set @RetornoEmail = 0;
						Set @Veri1 = 1;
					End
				Else
					Begin
						Set @Veri1 = 1;
					End

				IF CHARINDEX('.', SUBSTRING(@EmailT, CHARINDEX('@', @EmailT) + 1, LEN(@EmailT))) = 0
					Begin
						Set @RetornoEmail = 0;
						Set @Veri2 = 1;
					End
				Else
					Begin
						Set @Veri2 = 1;
					End

				IF LEN(@EmailT) < 6 OR LEN(@EmailT) > 255
					Begin
						Set @RetornoEmail = 0;
						Set @Veri3 = 1;
					End	
				Else
					Begin
						Set @Veri3 = 1;
					End

				IF LEFT(@EmailT, 1) IN ('@', '.', '-') OR RIGHT(@EmailT, 1) IN ('@', '.', '-')
					Begin
						Set @RetornoEmail = 0;
						Set @Veri4 = 1;
					End
				Else
					Begin
						Set @Veri4 = 1;
					End

				IF PATINDEX('%[^a-zA-Z0-9@._-]% ', @EmailT) <> 0
					Begin
						Set @RetornoEmail = 0;
						Set @Veri5 = 1;
					End
				Else
					Begin
						Set @Veri5 = 1;
					End

				IF @EmailT LIKE '%..%' OR @EmailT LIKE '%@@%'
					Begin
						Set @RetornoEmail = 0;
						Set @Veri6 = 1
					End
				Else
					Begin
						Set @Veri6 = 1;
					End
			End

		--Verifica se o Paciente_F � verdadeiro
		SET @Paciente_F_TEMP = SUBSTRING(@Paciente_F,1,1);

		SET @INDICE = 1
		SET @DIGITOS_IGUAIS = 'S'

		WHILE (@INDICE <= 11)
			BEGIN
				IF SUBSTRING(@Paciente_F,@INDICE,1) <> @Paciente_F_TEMP
					SET @DIGITOS_IGUAIS = 'N'
					SET @INDICE = @INDICE + 1
			END;

		IF @DIGITOS_IGUAIS = 'N'
			BEGIN
				SET @SOMA = 0
				SET @INDICE = 1
				WHILE (@INDICE <= 9)
					BEGIN
						SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@Paciente_F,@INDICE,1)) * (11 - @INDICE);
						SET @INDICE = @INDICE + 1
					END

		SET @DIG1 = 11 - (@SOMA % 11)

		IF @DIG1 > 9
			SET @DIG1 = 0;
			SET @SOMA = 0
			SET @INDICE = 1
			WHILE (@INDICE <= 10)
				BEGIN
					SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@Paciente_F,@INDICE,1)) * (12 - @INDICE);
					SET @INDICE = @INDICE + 1
				END

		SET @DIG2 = 11 - (@SOMA % 11)

		IF @DIG2 > 9
			SET @DIG2 = 0;

		IF (@DIG1 = SUBSTRING(@Paciente_F,LEN(@Paciente_F)-1,1)) AND (@DIG2 = SUBSTRING(@Paciente_F,LEN(@Paciente_F),1))
			SET @RetornoPaciente_F = 1
		ELSE
			SET @RetornoPaciente_F = 0

			END

		--Verifica��o de Senha
			IF (Len(@SenhaT) < 6)
				Set @RetornoSenha = 0;

		IF @RetornoNull = 0 or @RetornoPaciente_F = 0 or @RetornoEmail = 0 or @RetornoSenha = 0
			Begin
				IF (@RetornoNull = 0) Select 'Digite algo'  As 'Registra_Paciente_Retorno'
				Else If (@RetornoPaciente_F = 0) Select 'Paciente_F Inv�lido' As 'Registra_Paciente_Retorno'
				Else If (@RetornoEmail = 0) Select 'Email Inv�lido' As 'Registra_Paciente_Retorno'
				Else If (@RetornoSenha = 0) Select 'Senha Inv�lida' As 'Registra_Paciente_Retorno'
				Else Select 'Tem algo muito errado' As 'Registra_Paciente_Retorno';
			End
		Else 
			Begin
			--Insere as informa��es caso passe por todas as verifica��es ENCRYPTBYKEY(KEY_GUID('MinhaChaveSecreta'), '987.654.321-11'),
				Insert Into Paciente(Paciente_F, Rec_P, Email, Nome_Paciente, Nome_Social, Fone) 
					Values (@Paciente_FT, ENCRYPTBYKEY(KEY_GUID('EnK_Rec_P'), @SenhaT), @EmailT, @NomeT, @Nome_SocialT, @Fonee);
					Select 'Registro Concluido' As 'Registra_Paciente_Retorno';
			End

		End Try

		Begin Catch
			Select 'Informa��es inv�lidas' As 'Registra_Paciente_Retorno';
		End Catch
		CLOSE SYMMETRIC KEY Enk_Rec_P;
Go

--Procedure para login de Paciente (via Paciente_F)
Create Procedure Login_Paciente(
	@Paciente_F Varchar(11),
	@Senha Varchar(32)
	) AS
		OPEN SYMMETRIC KEY EnK_Rec_P DECRYPTION BY PASSWORD = 'Senha_Rec_P';
		Declare
		@Tamanho TINYINT,
		@SenhaR Varchar(32);

		Begin Try
			Set @Tamanho = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F);
			Set @SenhaR = (Select CONVERT(varchar, DECRYPTBYKEY(Rec_P)) From Paciente Where Paciente_F = @Paciente_F);


			If @Tamanho = 0 
				Begin
					Select 'Paciente_F Inv�lido' As 'Login_Paciente_Retorno';
				End
			Else 
				Begin
					IF @Senha = @SenhaR
						Begin
							Select Paciente_F From Paciente Where Paciente_F = @Paciente_F;
						End
					Else
						Begin
							Select 'Senha Inv�lida' As 'Login_Paciente_Retorno';
						End
				End
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Login_Paciente_Retorno';
		End Catch
		CLOSE SYMMETRIC KEY Enk_Rec_P;
Go

--Procedure para registrar funcionario (recebe as informa��es e precida do CNPJ de empresa no banco)
Create Procedure Registra_Funcionario(
	@CNPJ Varchar,
	@ID_Tipo_Funcionario Tinyint,
	@Nome_Funcionario Varchar(50),
	@Func_Rec Varchar(32),
	@Registro_C Varchar(32)
	) AS
		Open Symmetric Key EnK_Registro_C Decryption by Password = 'Senha_Registro_C';
		Declare
			@CNPJT Varchar,
			@ID_Tipo_FuncionarioT Tinyint,
			@Nome_FuncionarioT Varchar(50),
			@Func_RecT Varchar(32),
			@Registro_CT Varchar(32),

			@Verificado Bit,
			@Empresa Bit,
			@VSenha Bit;
		Begin Try
			Set @CNPJT = REPLACE(@CNPJ, ' ', '');
			Set @ID_Tipo_FuncionarioT = REPLACE(@ID_Tipo_Funcionario, ' ', '');
			Set @Nome_FuncionarioT = Trim(@Nome_Funcionario);
			Set @Func_RecT = REPLACE(@Func_Rec, ' ', '');
			Set @Registro_CT = REPLACE(@Registro_C, ' ', '');
			Set @Verificado = 1;
			Set @Empresa = 0;
			Set @VSenha = 0;
			

			--Verifica se a empresa existe
			Set @Empresa = (Select Count(CNPJ) From Contratante Where CNPJ = @CNPJT);

			--Verifica se a senha da empresa est� correta
			Set @VSenha = (Select Count(@CNPJ) From Contratante Where CNPJ = @CNPJT and CONVERT(varchar, DECRYPTBYKEY(Registro_C)) = @Registro_CT);

			--Verifica se houve digita��es "nulas"
			If (@CNPJT = '') or (@ID_Tipo_FuncionarioT = '') or (@Nome_FuncionarioT = '') or (@Func_RecT = '') Set @Verificado = 0;
			
			IF (@Empresa = 1) and (@Verificado = 1) and (@VSenha = 1)
				Begin
					Open Symmetric Key EnK_Func_Rec Decryption by Password = 'Senha_Func_Rec';
					Insert Into Funcionario (ID_Tipo_Funcionario, Nome_Funcionario, Func_Rec, CNPJ) Values 
						(@ID_Tipo_Funcionario, @Nome_Funcionario, ENCRYPTBYKEY(KEY_GUID('EnK_Func_Rec'), @Func_RecT), @CNPJ);
						Select 'Registro Concluido' As 'Registra_Funcionario_Retorno';
						Close Symmetric Key EnK_Func_Rec;
				End
			Else
				Begin
					If (@Empresa = 0) Select 'Empreasa Inv�lida' As 'Registra_Funcionario_Retorno'
					Else If (@Verificado = 0) Select '' As 'Registra_Funcionario_Retorno'
					Else If (@VSenha = 0) Select '' As 'Registra_Funcionario_Retorno'
					Else Select 'Tem algo muito errado' As 'Registra_Funcionario_Retorno';
				End
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Registra_Funcionario_Retorno';
		End Catch
		Close Symmetric Key EnK_Registro_C
Go

--Procedure para login funcionario
Create Procedure Login_Funcionario(
	@Funcionar_Rec INT,
	@Func_Rec Varchar(12)
	) As
		Open Symmetric Key EnK_Func_Rec Decryption by Password = 'Senha_Func_Rec';
		Declare
			@Tamanho Bit,
			@SenhaR Bit;
		Begin Try
			Set @Tamanho = (Select Count(Funcionar_Rec) From Funcionario Where Funcionar_Rec = @Funcionar_Rec);
			Set @SenhaR = (Select Count(Funcionar_Rec) From Funcionario Where Funcionar_Rec = @Funcionar_Rec and CONVERT(varchar, DECRYPTBYKEY(Func_Rec)) = @Func_Rec);
			If (@Tamanho = 1) and (@SenhaR = 1) Select * From Funcionario Where Funcionar_Rec = @Funcionar_Rec;
			Else If (@Tamanho = 0) Select 'Usu�rio Inv�lido' As 'Login_Funcionario_Retorno'
			Else If (@SenhaR = 0) Select 'Senha Inv�lida' As 'Login_Funcionario_Retorno'
			Else Select 'Tem algo muito errado' As 'Login_Funcionario_Retorno'
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Login_Funcionario_Retorno'
		End Catch
		Close Symmetric Key EnK_Func_Rec;
Go

--Procedure para registrar receita
Create Procedure Registra_Receita (
	@Funcionar_Rec INT,
	@Tipo_Funcionario_R Tinyint,
	@Func_Rec Varchar(12),
	@Data_Validade Date,
	@Paciente_F_Receita Varchar(11),
	@Medicamento Varchar (100),
	@Detalhes Varchar(300),
	@Limite_Baixas Tinyint
	) As
		Declare
			@Funcionar_Rec_R Bit,
			@Func_Rec_R Bit,
			@Paciente_F_Receita_R Varchar(11),
			@Medicamento_R Varchar (100),
			@Detalhes_R Varchar(300),
			@Limite_Baixas_R Tinyint;
		Begin Try
			Set @Funcionar_Rec_R = (Select Count(Funcionar_Rec) From Funcionario where Funcionar_Rec = @Funcionar_Rec);
			Set @Func_Rec_R = (Select Count(Funcionar_Rec) From Funcionario where Funcionar_Rec = @Funcionar_Rec and Func_Rec = @Func_Rec);
			Set @Paciente_F_Receita_R = (Select Count(Paciente_F) From Paciente where Paciente_F = @Paciente_F_Receita);
			Set @Medicamento_R = Trim(@Medicamento);
			Set @Detalhes_R = Trim(@Detalhes);
			--Se n�o declarar um limite de baixas o transforma em nulo
			If (@Limite_Baixas = 0) Set @Limite_Baixas_R = null;
			Else Set @Limite_Baixas_R = @Limite_Baixas;

			--Verifica��es
			If (@Funcionar_Rec_R = 1) and (@Func_Rec_R = 1) and (@Tipo_Funcionario_R = 2) and (@Paciente_F_Receita_R = 1)
				Begin
					Insert Into Receita (Funcionar_Rec, Data_Receita, Data_Validade, Medicamento, Detalhes, Limite_Baixas, Paciente_F, Valido, Baixas) Values
						(@Funcionar_Rec, (FORMAT(GETDATE() , 'dd/MM/yyyy HH:mm:ss')), @Data_Validade, @Medicamento_R, @Detalhes_R, @Limite_Baixas_R, @Paciente_F_Receita, 1, 0);
						Select 'Receita Criada' As 'Retorno_Registra_Receita';
				End
			Else If (@Funcionar_Rec_R = 0) Select 'Funcion�rio Inv�lido' As 'Retorno_Registra_Receita'
			Else If (@Func_Rec_R = 0) Select 'Senha Inv�lida' As 'Retorno_Registra_Receita'
			Else If (@Tipo_Funcionario_R != 2) Select 'Funcion�rio n�o tem permiss�o' As 'Retorno_Registra_Receita'
			Else If (@Paciente_F_Receita_R = 0) Select 'Paciente_F Inv�lido' As 'Retorno_Registra_Receita'
			Else Select 'Tem algo muito errado' As 'Retorno_Registra_Receita';
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Retorno_Registra_Receita';
		End Catch
			
Go

--Procedure para ver receita
Create Procedure Ver_Receita (
	@Paciente_F_Receita Varchar(11)
	) As
		Begin Try
			IF (Select Count(Paciente_F) From Receita where Paciente_F = @Paciente_F_Receita) >= 1
				Select * From Receita Where Paciente_F = @Paciente_F_Receita;
			Else
				Select 'N�o h� Receitas' As 'Ver_Receita_Retorno';
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Ver_Receita_Retorno';
		End Catch
		
Go

--Procedure altera receita (farm�cia d� baixa)
Create Procedure Altera_Receita (
	@Funcionar_Rec_Alt INT,
	@Func_Rec_Alt Varchar(12),
	@Paciente_F_Alt Varchar(11),
	@ID_Receita INT
	) As
		Declare
			@Funcionar_Rec_Alt_R Bit,
			@Func_Rec_Alt_R Bit,
			@Paciente_F_Alt_R Bit,
			@Tipo_Funcionario_Alt Tinyint,
			@Limite_Baixas_Alt Tinyint,
			@ID_Receita_Alt_R Bit;
		Begin Try
			Set @Funcionar_Rec_Alt_R = (Select Count(Funcionar_Rec) From Funcionario Where Funcionar_Rec = @Funcionar_Rec_Alt);
			Set @Func_Rec_Alt_R = (Select Count(Func_Rec) From Funcionario Where Funcionar_Rec = @Funcionar_Rec_Alt and Func_Rec = @Func_Rec_Alt);
			Set @Tipo_Funcionario_Alt = (Select ID_Tipo_Funcionario From Funcionario Where Funcionar_Rec = @Funcionar_Rec_Alt);
			Set @Paciente_F_Alt_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_Alt);
			Set @ID_Receita_Alt_R = (Select Count(ID_Receita) From Receita Where ID_Receita = @ID_Receita);
			Set @Limite_Baixas_Alt = (Select Limite_Baixas From Receita Where ID_Receita = @ID_Receita_Alt_R) - (Select Baixas From Receita Where ID_Receita = @ID_Receita_Alt_R)
			If (@Limite_Baixas_Alt < 1)
				Begin
					Select 'N�o � possivel dar mais baixas' As 'Retorno_Altera_Receita';
				End
			Else
				Begin
					IF (@Funcionar_Rec_Alt_R = 1) and (@Func_Rec_Alt_R = 1) and (@Paciente_F_Alt_R = 1) and (@ID_Receita_Alt_R != 0) and (@Tipo_Funcionario_Alt = 1)
						Begin
							Update Receita Set Baixas = (Baixas + 1) Where @ID_Receita = ID_Receita;
							Select 'Baixa dada com sucesso' As 'Retorno_Altera_Receita';
						End
					Else If (@Funcionar_Rec_Alt_R = 0) Select 'Funcion�rio Inv�lido' As 'Retorno_Altera_Receita'
					Else If (@Func_Rec_Alt_R = 0) Select 'Senha Inv�lida' As 'Retorno_Altera_Receita'
					Else If (@Paciente_F_Alt_R = 0) Select 'Paciente_F Inv�lido' As 'Retorno_Altera_Receita'
					Else If (@ID_Receita_Alt_R = 0) Select 'Receita Inv�lida' As 'Retorno_Altera_Receita'
					Else If (@Tipo_Funcionario_Alt != 1) Select 'Funcion�rio n�o tem permiss�o' As 'Retorno_Altera_Receita'
					Else Select 'Tem algo muito errado' As 'Retorno_Altera_Receita';
				End
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Retorno_Altera_Receita'
		End Catch
		
		
Go

--Procedure para inserir hist�rico
Create Procedure Insere_Historico(
	@Paciente_F_Rec Varchar(11),
	@Rec_P_Rec Varchar(32),
	@Historico_Arqui Varbinary (Max)
	) As
		Declare 
			@Paciente_F_Rec_R Bit,
			@Rec_P_Rec_R Bit;
		Begin Try
			Set @Paciente_F_Rec_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_Rec);
			Set @Rec_P_Rec_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_Rec and Rec_P = @Rec_P_Rec);
			If (@Paciente_F_Rec_R = 1 and @Rec_P_Rec_R = 1) 
				Begin
					Insert Into Historico_Medico (Paciente_F, Registro_Medico) Values
						(@Paciente_F_Rec, @Historico_Arqui);
					Select 'Inser��o feita' As 'Retorno_Registra_Historico'
				End
			Else
				Begin
					If (@Paciente_F_Rec_R = 0) Select 'Paciente_F Inv�lido' As 'Retorno_Registra_Historico'
					Else If (@Rec_P_Rec_R = 0) Select 'Senha Inv�lida' As 'Retorno_Registra_Historico'
					Else Select 'Tem algo muito errado' As 'Retorno_Registra_Historico';
				End
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Retorno_Registra_Historico';
		End Catch
Go

--Procedure para ver hist�rico (Funcionario)

Go
--Procedure para ver hist�rico (paciente)
Create Procedure Ver_Historico_Paciente (
	@Paciente_F_V_Historico_Pac Varchar(11),
	@Senha_V_Historico_Pac Varchar(32)
	) As
		Declare
			@Paciente_F_V_Historico_Pac_R Bit,
			@Senha_V_Historico_Pac_R Bit;
		Begin Try
			Set @Paciente_F_V_Historico_Pac_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_V_Historico_Pac);
			Set @Senha_V_Historico_Pac_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_V_Historico_Pac and Rec_P = @Senha_V_Historico_Pac);
			If (@Paciente_F_V_Historico_Pac_R = 1 and @Senha_V_Historico_Pac_R = 1)
				Begin
					Select Registro_Medico From Historico_Medico Where Paciente_F = @Paciente_F_V_Historico_Pac;
				End
			Else
				Begin
					If (@Paciente_F_V_Historico_Pac_R = 0) Select 'Paciente_F Inv�lido' As 'Retorno_Ver_Hist�rico'
					Else IF (@Senha_V_Historico_Pac_R = 0) Select 'Senha Inv�lida' As 'Retorno_Ver_Hist�rico'
					Else Select 'Tem algo muito errado' As 'Retorno_Ver_Hist�rico';
				End
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Retorno_Ver_Hist�rico'
		End Catch
Go

--Procedure para enviar mensagem (Paciente)
Create Procedure Envia_Mensagem_P (
	@ID_Receptor INT,
	@ID_Mensageiro Varchar(11),
	@Mensagem Varchar(255)
	) As
		Declare
			@ID_Receptor_R Bit,
			@ID_Mensageiro_R Bit,
			@Hora DateTime;
		Begin Try
			Set @Hora = FORMAT(GETDATE() , 'dd/MM/yyyy HH:mm:ss.mmm');
			Set @ID_Mensageiro_R = (Select Count(Paciente_F) From Paciente Where @ID_Mensageiro = Paciente_F);
			Set @ID_Receptor_R = (Select Count(Funcionar_Rec) From Funcionario Where Funcionar_Rec = @ID_Receptor);
			IF (@ID_Mensageiro_R = 1) and (@ID_Receptor_R) = 1 Insert Into Mensagem (Paciente_F, Funcionar_Rec, Mensagem, Hora_Envio) Values (@ID_Mensageiro, @ID_Receptor, @Mensagem, @Hora);
			Else If (@ID_Mensageiro_R = 0) Select 'Paciente_F Inv�lido' As 'Mensagem_Retorno_P';
			Else If (@ID_Receptor_R = 0) Select 'Funcion�rio Inv�lido' As 'Mensagem_Retorno_P';
			Else Select 'Tem algo muito errado' As 'Mensagem_Retorno_P';
		End Try
		Begin Catch
			Select 'Informa��es inv�lidas' As 'Mensagem_Retorno_P';
		End Catch
		
Go

--Procedure para enviar mensagem (Funcionario) erro por causa do Identity
Create Procedure Envia_Mensagem_F (
	@ID_Receptor Varchar(11),
	@ID_Mensageiro INT,
	@Mensagem Varchar(255)
	) As
		Declare 
			@ID_Receptor_R Bit,
			@ID_Mensageiro_R Bit,
			@Hora DateTime;
		Begin Try
			Set @Hora = FORMAT(GETDATE() , 'dd/MM/yyyy HH:mm:ss:mmm');
			Set @ID_Mensageiro_R = (Select Count(Funcionar_Rec) From Funcionario Where @ID_Mensageiro = Funcionar_Rec);
			Set @ID_Receptor_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @ID_Receptor);
			IF (@ID_Mensageiro_R = 1) and (@ID_Receptor_R) = 1 Insert Into Mensagem (Paciente_F, Funcionar_Rec, Mensagem, Hora_Envio) Values (@ID_Receptor, @ID_Mensageiro, @Mensagem, @Hora);	
			Else IF (@ID_Mensageiro_R = 0) Select 'Funcion�rio Inv�lido' As 'Mensagem_Retorno_F';
			Else IF (@ID_Receptor_R = 0) Select 'Paciente_F Inv�lido' As 'Mensagem_Retorno_F';
			Else Select 'Tem algo muito errado' As 'Mensagem_Retorno_F';
		End Try
		Begin Catch
			Select 'Informa��es inv�lidas' As 'Mensagem_Retorno_F';
		End Catch
Go

--Procedure Altera Paciente (Menos Senha)
Create Procedure Alt_Paciente(
		@Paciente_F_Alt_P Varchar(11),
		@Senha_Alt_P Varchar(32),
		@Email_Alt_P Varchar(45),
		@Nome_Alt_P Varchar(50),
		@Nome_Social_Alt_P Varchar (50)
	) As 
		Declare 
			@RetornoEmail Bit,
			@Veri1 Bit,
			@Veri2 Bit,
			@Veri3 Bit,
			@Veri4 Bit,
			@Veri5 Bit,
			@Veri6 Bit,
			@EmailT Varchar(45),

			@Paciente_F_Alt_P_R Bit,
			@Senha_Alt_P_R Bit;

		Begin Try
			Set @Veri1 = 0;
			Set @Veri2 = 0;
			Set @Veri3 = 0;
			Set @Veri4 = 0;
			Set @Veri5 = 0;
			Set @Veri6 = 0;

			Set @RetornoEmail = 1;
			Set @EmailT = REPLACE(@Email_Alt_P, ' ', '');

			While (@Veri1 = 0 or @Veri2 = 0 or @Veri3 = 0 or @Veri4 = 0 or @Veri5 = 0 or @Veri6 = 0)
				Begin
					IF CHARINDEX('@', @EmailT) = 0
						Begin
							Set @RetornoEmail = 0;
							Set @Veri1 = 1;
						End
					Else
						Begin
							Set @Veri1 = 1;
						End

					IF CHARINDEX('.', SUBSTRING(@EmailT, CHARINDEX('@', @EmailT) + 1, LEN(@EmailT))) = 0
						Begin
							Set @RetornoEmail = 0;
							Set @Veri2 = 1;
						End
					Else
						Begin
							Set @Veri2 = 1;
						End

					IF LEN(@EmailT) < 6 OR LEN(@EmailT) > 255
						Begin
							Set @RetornoEmail = 0;
							Set @Veri3 = 1;
						End	
					Else
						Begin
							Set @Veri3 = 1;
						End

					IF LEFT(@EmailT, 1) IN ('@', '.', '-') OR RIGHT(@EmailT, 1) IN ('@', '.', '-')
						Begin
							Set @RetornoEmail = 0;
							Set @Veri4 = 1;
						End
					Else
						Begin
							Set @Veri4 = 1;
						End

					IF PATINDEX('%[^a-zA-Z0-9@._-]% ', @EmailT) <> 0
						Begin
							Set @RetornoEmail = 0;
							Set @Veri5 = 1;
						End
					Else
						Begin
							Set @Veri5 = 1;
						End

					IF @EmailT LIKE '%..%' OR @EmailT LIKE '%@@%'
						Begin
							Set @RetornoEmail = 0;
							Set @Veri6 = 1
						End
					Else
						Begin
							Set @Veri6 = 1;
						End
				End

			Set @Paciente_F_Alt_P_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_Alt_P);
			Set @Senha_Alt_P_R = (Select Count(Paciente_F) From Paciente Where Paciente_F = @Paciente_F_Alt_P and Rec_P = @Senha_Alt_P);

			IF @Paciente_F_Alt_P_R = 1 and @Senha_Alt_P_R = 1 and @RetornoEmail = 1
				Begin 
					Update Paciente Set Email = @EmailT Where Paciente_F = @Paciente_F_Alt_P;
					Update Paciente Set Nome_Paciente = @Nome_Alt_P Where Paciente_F = @Paciente_F_Alt_P;
					Update Paciente Set Nome_Social = @Nome_Social_Alt_P Where Paciente_F = @Paciente_F_Alt_P;
					Select 'Altera��es Concluidas' As 'Retorono_Altera_Paciente';
				End
			Else If (@Paciente_F_Alt_P_R = 0) Select 'Paciente_F Inv�lido' As 'Retorono_Altera_Paciente'
			Else IF (@Senha_Alt_P_R = 0) Select 'Senha Inv�lida' As 'Retorono_Altera_Paciente'
			Else IF (@RetornoEmail = 0) Select 'Email Inv�lido' As 'Retorono_Altera_Paciente'
			Else Select 'Tem algo muito errado' As 'Retorono_Altera_Paciente'
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Retorono_Altera_Paciente';
		End Catch

Go

Create Procedure Mostra_Chat(
		@Paciente_F_M_Chat Varchar(11),
		@Funcionar_Rec_M_Chat INT
	) As
		Declare
			@Paciente_F_M_Chat_R Bit,
			@Funcionar_Rec_M_Chat_R Bit
		Begin Try
			Set @Paciente_F_M_Chat_R = (Select Count(Paciente_F) From Paciente);
			Set @Funcionar_Rec_M_Chat_R = (Select Count(Funcionar_Rec) From Funcionario);
			IF (@Paciente_F_M_Chat_R = 1) and (@Funcionar_Rec_M_Chat_R = 1) Select Mensagem From Mensagem Order By Hora_Envio ASC;
			Else IF (@Paciente_F_M_Chat_R = 0) Select 'Paciente_F Inv�lido' As 'Retorno_Mostra_Chat';
			Else IF (@Funcionar_Rec_M_Chat_R = 0) Select 'Funcion�rio Inv�lido' As 'Retorno_Mostra_Chat';
			Else Select 'Tem algo muito errado' AS 'Retorno_Mostra_Chat';
 		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Retorno_Mostra_Chat';
		End Catch
Go

Create Procedure Alt_Senha_P(
		@Alt_Paciente_F Varchar(11),
		@Alt_Senha Varchar(32)
	) As
		Declare
			@Alt_Paciente_F_R Bit,
			@Alt_Senha_R Bit,
			@T_Alt_Senha Varchar(32)
		Begin Try
			Set @T_Alt_Senha = REPLACE(@Alt_Senha, '', ' ')
			Set @Alt_Paciente_F_R = (Select Count(Paciente_F) From Paciente);
			If (Len(@Alt_Senha) >= 6) Set @Alt_Senha_R = 1;
			If (@Alt_Paciente_F_R = 1) and (@Alt_Senha_R = 1) Update Paciente Set Rec_P = @T_Alt_Senha Where Paciente_F = @Alt_Paciente_F;
			Else If (@Alt_Paciente_F_R = 0) Select 'Paciente_F Inv�lido' As 'Alt_Senha_Retorno';
			Else IF (@Alt_Senha_R = 0) Select 'Senha Inv�lida' As 'Alt_Senha_Retorno';
			Else Select 'Tem algo muito errado' As 'Alt_Senha_Retorno';
		End Try
		Begin Catch
			Select 'Informa��es Inv�lidas' As 'Alt_Senha_Retorno';
		End Catch
Go
--Nota: a inser��o no Paciente_F N�O est� mais aceitando caracteres que n�o podem ser convertidos diretamente a INT
--Senha deve ter 6 ou mais caracteres
Exec Registra_Paciente '54856098802', 'Alanzoca', 'algumEmail@gmail.com', 'Alan', 'Talvez', '(55) +11 975793636';
Go
--O Login_Paciente retorna todas as informa��es do paciente (Alterar)
Exec Login_Paciente '54856098802', 'Alanzoca';
Go
--Registra o Funcion�rio quando o CNPJ inserido � existente no Banco e a senha � correspondente do mesmo
Exec Registra_Funcionario '1', 1, 'Wanderley', 'senha123', 'senha';
Go
Exec Login_Funcionario '1', 'senha123';
Go
Exec Registra_Receita '1', 2,'senha123', '19-06-2025', '54856098802', 'Dorflex', 'Usar 3x ao dia', 3;
Go
Exec Ver_Receita '54856098802';
Go
Exec Altera_Receita '1', 'senha123',  '54856098802', 1;
Go
Exec Envia_Mensagem_P 1, '54856098802', 'Mensagem Teste1';
Go
Exec Envia_Mensagem_F '54856098802', 1, 'Mensagem Teste2';
Go
Exec Alt_Paciente '54856098802', 'Alanzoca', 'algumEmail@gmail.com', 'Alan2', 'Talvez2';
Go
Exec Mostra_Chat '54856098802', 1;
Go
Exec Alt_Senha_P '54856098802', 'Alanzocaaa';