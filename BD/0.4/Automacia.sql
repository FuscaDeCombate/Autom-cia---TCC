Use master
Go

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Automacia')
	DROP DATABASE Automacia;

CREATE DATABASE Automacia;
Go

Use Automacia;

Go

Set dateformat DMY;

Go

--Farmácia/Hospital/Clínica
Create Table Contratante (
	CNPJ Varchar Not null,
	Documentacao VarBinary(max) Not null,
	Nome_Contratante Varchar(50) Not null,
	Senha_Contratante Varchar(12) Not null,
	Primary Key (CNPJ)
);

--Tipo de Funcionário
Create Table Tipo_Funcionario (
	ID_Tipo_Funcionario TINYINT,
	Tipo_Funci Varchar(22),
	Primary Key (ID_Tipo_Funcionario)
);

--Funcionário de Farmácia/Hospital/Clínica
Create Table Funcionario (
	ID_Funcionario INT Identity Not null,
	ID_Tipo_Funcionario TINYINT Not null,
	CNPJ Varchar Not null,
	Senha_Funcionario Varchar(12) Not null,
	Nome_Funcionario Varchar(50) Not null,
	Primary Key (ID_Funcionario),
	Foreign Key (ID_Tipo_Funcionario) References Tipo_Funcionario(ID_Tipo_Funcionario),
	Foreign Key (CNPJ) References Contratante(CNPJ)
);

--Paciente
Create Table Paciente (
	CPF Varchar(11) Not null,
	Senha_Paciente Varchar(12) Not null,
	Email Varchar(45),
	Nome_Paciente Varchar(50) Not null,
	Nome_Social Varchar(50) Not null,
	Primary Key (CPF)
);

--Receita
Create Table Receita (
	ID_Receita INT Identity Not null,
	Data_Receita Date Not null,
	Data_Validade Date Not null,
	ID_Funcionario INT Not null,
	CPF Varchar(11) Not null,
	Medicamento Varchar(100) Not null,
	Detalhes Varchar(300),
	Limite_Baixas Tinyint,
	Baixas Tinyint,
	Primary Key (ID_Receita),
	Foreign Key (ID_Funcionario) References Funcionario(ID_Funcionario),
	Foreign Key (CPF) References Paciente(CPF)
);

--Historico Medico
Create Table Historico_Medico (
	ID_Historico INT Identity Not null,
	CPF Varchar(11) Not null,
	Registro_Medico VarBinary(max) Not null,
	Primary Key (ID_Historico),
	Foreign Key (CPF) References Paciente(CPF)
);

--Mensagem
Create Table Mensagem (
	ID_Chat INT Not null,
	CPF Varchar(11),
	ID_Funcionario INT,
	Primary Key (ID_Chat),
	Foreign Key (CPF) References Paciente(CPF),
	Foreign Key (ID_Funcionario) References Funcionario(ID_Funcionario)
);

/*
Como Monitorar o identificador o tornando algo que pode ser CPF e ID_Funcionario?
*/
Go


Create Index IDX_CNPJ On Contratante(CNPJ);
Create Index IDX_CPF On Paciente(CPF);
Create Index IDX_ID_Funcionario On Funcionario(ID_Funcionario);
Create Index IDX_ID_Receita On Receita(ID_Receita);
Create Index IDX_ID_Historico On Historico_Medico(ID_Historico);
Create Index IDX_ID_Chat On Mensagem(ID_Chat);

Go

Insert Into Tipo_Funcionario (ID_Tipo_Funcionario, Tipo_Funci) Values
	(1, 'Funcionario Farmácia'),
	(2, 'Funcionario Saude'),
	(3, 'Administrador Farmacia'),
	(4, 'Administrador Hospital');

--Necessário verificar como funciona VARBINARY para guardar imagens
INSERT Into Contratante (CNPJ, Documentacao, Nome_Contratante, Senha_Contratante) Values
	(1, 66656, 'Empresa Teste', 'senha');

Go

--Procedure para registrar Paciente
Create Procedure Registra_Paciente(
	@CPF Varchar(11),
	@Senha Varchar(12),
	@Email Varchar(45),
	@Nome Varchar(50),
	@Nome_Social Varchar(50)
	) As 
		Declare
			@RetornoCPF Bit,
			@RetornoNull Bit,
			@RetornoEmail Bit,
			@RetornoSenha Bit,

			@CPFT Varchar(14),
			@SenhaT Varchar(12),
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
			@CPF_TEMP VARCHAR(11),
			@DIGITOS_IGUAIS CHAR(1);
		
		Set @RetornoCPF = 0;
		Set @RetornoNull = 0;
		Set @RetornoEmail = 1;
		Set @RetornoSenha = 1;

		--Trim nas variaveis
		Set @CPFT = REPLACE(@CPF, ' ', '');
		Set @SenhaT = REPLACE(@Senha, ' ', '');
		Set @EmailT = REPLACE(@Email, ' ', '');
		Set @NomeT = Trim(@Nome);
		Set @Nome_SocialT = Trim(@Nome_Social);

		Begin Try

		--Verifica se há nulos
		
		If @CPFT = '' or @SenhaT = '' or @EmailT = '' or @NomeT = ''
			Begin
				Set @RetornoNull = 0
			End
		Else
			Begin
				Set @RetornoNull = 1
			End

		--Verifica se é email válido
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

		--Verifica se o CPF é verdadeiro
		SET @CPF_TEMP = SUBSTRING(@CPF,1,1);

		SET @INDICE = 1
		SET @DIGITOS_IGUAIS = 'S'

		WHILE (@INDICE <= 11)
			BEGIN
				IF SUBSTRING(@CPF,@INDICE,1) <> @CPF_TEMP
					SET @DIGITOS_IGUAIS = 'N'
					SET @INDICE = @INDICE + 1
			END;

		IF @DIGITOS_IGUAIS = 'N'
			BEGIN
				SET @SOMA = 0
				SET @INDICE = 1
				WHILE (@INDICE <= 9)
					BEGIN
						SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (11 - @INDICE);
						SET @INDICE = @INDICE + 1
					END

		SET @DIG1 = 11 - (@SOMA % 11)

		IF @DIG1 > 9
			SET @DIG1 = 0;
			SET @SOMA = 0
			SET @INDICE = 1
			WHILE (@INDICE <= 10)
				BEGIN
					SET @Soma = @Soma + CONVERT(INT,SUBSTRING(@CPF,@INDICE,1)) * (12 - @INDICE);
					SET @INDICE = @INDICE + 1
				END

		SET @DIG2 = 11 - (@SOMA % 11)

		IF @DIG2 > 9
			SET @DIG2 = 0;

		IF (@DIG1 = SUBSTRING(@CPF,LEN(@CPF)-1,1)) AND (@DIG2 = SUBSTRING(@CPF,LEN(@CPF),1))
			SET @RetornoCPF = 1
		ELSE
			SET @RetornoCPF = 0

			END

		--Verificação de Senha
			IF (Len(@SenhaT) < 6)
				Set @RetornoSenha = 0;

		IF @RetornoNull = 0 or @RetornoCPF = 0 or @RetornoEmail = 0 or @RetornoSenha = 0
			Begin
				Select 'Informações inválidas' As 'Registra_Paciente_Retorno';
			End
		Else 
			Begin
			--Insere as informações caso passe por todas as verificações
				Insert Into Paciente(CPF, Senha_Paciente, Email, Nome_Paciente, Nome_Social) 
					Values (@CPFT, @SenhaT, @EmailT, @NomeT, @Nome_SocialT);
					Select 'Registro Concluido' As 'Registra_Paciente_Retorno';
			End

		End Try

		Begin Catch
			Select 'Informações inválidas' As 'Registra_Paciente_Retorno';
		End Catch

Go

--Procedure para login de Paciente (via CPF)
Create Procedure Login_Paciente(
	@CPF Varchar(11),
	@Senha Varchar(12)
	) AS
		Declare
		@Tamanho TINYINT,
		@SenhaR Varchar(12);

		Begin Try
			Set @Tamanho = (Select Count(CPF) From Paciente Where CPF = @CPF);
			Set @SenhaR = (Select Senha_Paciente From Paciente Where CPF = @CPF);


			If @Tamanho = 0 
				Begin
					Select 'Informações Inválidas' As 'Login_Paciente_Retorno';
				End
			Else 
				Begin
					IF @Senha = @SenhaR
						Begin
							Select * From Paciente Where CPF = @CPF;
						End
					Else
						Begin
							Select 'Informações Inválidas' As 'Login_Paciente_Retorno';
						End
				End
		End Try
		Begin Catch
			Select 'Informações Inválidas' As 'Login_Paciente_Retorno';
		End Catch

Go

--Procedure para registrar funcionario (recebe as informações e precida do CNPJ de empresa no banco)
Create Procedure Registra_Funcionario(
	@CNPJ Varchar,
	@ID_Tipo_Funcionario Tinyint,
	@Nome_Funcionario Varchar(50),
	@Senha_Funcionario Varchar(12),
	@Senha_Contratante Varchar(12)
	) AS
		
		Declare
			@CNPJT Varchar,
			@ID_Tipo_FuncionarioT Tinyint,
			@Nome_FuncionarioT Varchar(50),
			@Senha_FuncionarioT Varchar(12),
			@Senha_ContratanteT Varchar(12),

			@Verificado Bit,
			@Empresa Bit,
			@VSenha Bit;
		Begin Try
			Set @CNPJT = REPLACE(@CNPJ, ' ', '');
			Set @ID_Tipo_FuncionarioT = REPLACE(@ID_Tipo_Funcionario, ' ', '');
			Set @Nome_FuncionarioT = Trim(@Nome_Funcionario);
			Set @Senha_FuncionarioT = REPLACE(@Senha_Funcionario, ' ', '');
			Set @Senha_ContratanteT = REPLACE(@Senha_Contratante, ' ', '');
			Set @Verificado = 1;
			Set @Empresa = 0;
			Set @VSenha = 0;
			

			--Verifica se a empresa existe
			Set @Empresa = (Select Count(CNPJ) From Contratante Where CNPJ = @CNPJT);

			--Verifica se a senha da empresa está correta
			Set @VSenha = (Select Count(@CNPJ) From Contratante Where CNPJ = @CNPJT and Senha_Contratante = @Senha_ContratanteT);

			--Verifica se houve digitações "nulas"
			If (@CNPJT = '') or (@ID_Tipo_FuncionarioT = '') or (@Nome_FuncionarioT = '') or (@Senha_FuncionarioT = '') Set @Verificado = 0;
			
			IF (@Empresa = 1) and (@Verificado = 1) and (@VSenha = 1)
				Begin
					Insert Into Funcionario (ID_Tipo_Funcionario, Nome_Funcionario, Senha_Funcionario, CNPJ) Values 
						(@ID_Tipo_Funcionario, @Nome_Funcionario, @Senha_Funcionario, @CNPJ);
						Select 'Registro Concluido' As 'Registra_Funcionario_Retorno';
				End
			Else
				Begin
					Select 'Informações Inválidas' As 'Registra_Funcionario_Retorno';
				End
		End Try
		Begin Catch
			Select 'Informações Inválidas' As 'Registra_Funcionario_Retorno';
		End Catch
		
Go

--Procedure para login funcionario
Create Procedure Login_Funcionario(
	@ID_Funcionario INT,
	@Senha_Funcionario Varchar(12)
	) As
		Declare
			@Tamanho Bit,
			@SenhaR Bit;
		Begin Try
			Set @Tamanho = (Select Count(ID_Funcionario) From Funcionario Where ID_Funcionario = @ID_Funcionario);
			Set @SenhaR = (Select Count(@ID_Funcionario) From Funcionario Where ID_Funcionario = @ID_Funcionario and Senha_Funcionario = @Senha_Funcionario);
			If (@Tamanho = 1) and (@SenhaR = 1) Select * From Funcionario Where ID_Funcionario = @ID_Funcionario;
			Else Select 'Informações Inválidas' As 'Login_Funcionario_Retorno'
		End Try
		Begin Catch
			Select 'Informações Inválidas' As 'Login_Funcionario_Retorno'
		End Catch

Go

--Procedure para registrar receita
Create Procedure Registra_Receita (
	@ID_Funcionario INT,
	@Tipo_Funcionario_R Tinyint,
	@Senha_Funcionario Varchar(12),
	@Data_Validade Date,
	@CPF_Receita Varchar(11),
	@Medicamento Varchar (100),
	@Detalhes Varchar(300),
	@Limite_Baixas Tinyint
	) As
		Declare
			@ID_Funcionario_R Bit,
			@Senha_Funcionario_R Bit,
			@CPF_Receita_R Varchar(11),
			@Medicamento_R Varchar (100),
			@Detalhes_R Varchar(300),
			@Limite_Baixas_R Tinyint;
		Begin Try
			Set @ID_Funcionario_R = (Select Count(ID_Funcionario) From Funcionario where ID_Funcionario = @ID_Funcionario);
			Set @Senha_Funcionario_R = (Select Count(ID_Funcionario) From Funcionario where ID_Funcionario = @ID_Funcionario and Senha_Funcionario = @Senha_Funcionario);
			Set @CPF_Receita_R = (Select Count(CPF) From Paciente where CPF = @CPF_Receita);
			Set @Medicamento_R = Trim(@Medicamento);
			Set @Detalhes_R = Trim(@Detalhes);
			--Se não declarar um limite de baixas o transforma em nulo
			If (@Limite_Baixas = 0) Set @Limite_Baixas_R = null;

			--Verificações
			If (@ID_Funcionario_R = 1) and (@Senha_Funcionario_R = 1) and (@Tipo_Funcionario_R = 2) and (@CPF_Receita_R = 1)
				Begin
					Insert Into Receita (ID_Funcionario, Data_Receita, Data_Validade, Medicamento, Detalhes, Limite_Baixas, CPF) Values
						(@ID_Funcionario, GETDATE(), @Data_Validade, @Medicamento_R, @Detalhes_R, @Limite_Baixas_R, @CPF_Receita);
						Select * From Receita;
				End
			Else
				Select 'Informações Inválidas';
		End Try
		Begin Catch
			Select 'Informações Inválidas';
		End Catch
			
Go

--Procedure para ver receita
Create Procedure Ver_Receita (
	@CPF_Receita Varchar(11)
	) As
		IF (Select Count(CPF) From Receita where CPF = @CPF_Receita) = 1
			Select * From Receita Where CPF = @CPF_Receita;
		Else
			Select 'Informações Inválidas';
Go

--Procedure altera receita (farmácia)
Create Procedure Altera_Receita (
	@ID_Funcionario_Alt INT,
	@Senha_Funcionario_Alt Varchar(12),
	@CPF_Alt Varchar(11),
	@ID_Receita INT
	) As
		Declare
			@ID_Funcionario_Alt_R Bit,
			@Senha_Funcionario_Alt_R Bit,
			@CPF_Alt_R Bit,
			@Tipo_Funcionario_Alt Tinyint,
			@Limite_Baixas_Alt Tinyint,
			@ID_Receita_Alt_R Bit;
		Set @ID_Funcionario_Alt_R = (Select Count(ID_Funcionario) From Funcionario Where ID_Funcionario = @ID_Funcionario_Alt);
		Set @Senha_Funcionario_Alt_R = (Select Count(Senha_Funcionario) From Funcionario Where ID_Funcionario = @ID_Funcionario_Alt and Senha_Funcionario = @Senha_Funcionario_Alt);
		Set @Tipo_Funcionario_Alt = (Select ID_Tipo_Funcionario From Funcionario Where ID_Funcionario = @ID_Funcionario_Alt);
		Set @CPF_Alt_R = (Select Count(CPF) From Paciente Where CPF = @CPF_Alt);
		Set @ID_Receita_Alt_R = (Select Count(ID_Receita) From Receita Where ID_Receita = @ID_Receita_Alt_R);
		Set @Limite_Baixas_Alt = (Select Limite_Baixas From Receita Where ID_Receita = @ID_Receita_Alt_R) - (Select Baixas From Receita Where ID_Receita = @ID_Receita_Alt_R)
		If (@Limite_Baixas_Alt < 1)
			Begin
				Select 'Não é possivel dar mais baixas'
			End
		Else
			Begin
				IF (@ID_Funcionario_Alt_R = 1) and (@Senha_Funcionario_Alt_R = 1) and (@CPF_Alt_R = 1) and (@ID_Receita_Alt_R = 1) and (@Tipo_Funcionario_Alt = 1)
					Update Receita Set Baixas = (Baixas + 1);
				Else 
					Select 'Informações Inválidas'
			End
		
Go

--Procedure para inserir histórico

Go

--Procedure para ver histórico

Go

--Procedure Criar Chat?

Go
--Nota: a inserção no CPF NÃO está mais aceitando caracteres que não podem ser convertidos diretamente a INT
--Senha deve ter 6 ou mais caracteres
Exec Registra_Paciente '54856098802', 'Alanzoca', 'vitorpires3707@gmail.com', 'Alan', 'Talvez';
Go
--O Login_Paciente retorna todas as informações do paciente (Alterar)
Exec Login_Paciente '54856098802', 'Alanzoca';
Go
--Registra o Funcionário quando o CNPJ inserido é existente no Banco e a senha é correspondente do mesmo
Exec Registra_Funcionario '1', 2, 'Wanderley', 'senha123', 'senha';
Go
Exec Login_Funcionario '1', 'senha123';
Go
Exec Registra_Receita '1', 2,'senha123', '19-06-2025', '54856098802', 'Dorflex', 'Usar 3x ao dia', 0;
Go
Exec Ver_Receita '54856098802';
Go
Exec Altera_Receita '1', 'senha123',  '54856098802', 1;

