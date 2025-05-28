Use master
Go

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'TesteFunction')
	DROP DATABASE TesteFunction;

CREATE DATABASE TesteFunction;
Go

Use TesteFunction;

Go

Set dateformat DMY;

Go

Create Table Paciente (
	CPF Varchar(11) Not null,
	Senha_Paciente Varchar(12) Not null,
	Email Varchar(45),
	Nome_Paciente Varchar(50) Not null,
	Nome_Social Varchar(50) Not null,
	Primary Key (CPF)
);

Go 

CREATE FUNCTION CPF_VALIDACAO(@CPF VARCHAR(11)) RETURNS CHAR(1)
AS
BEGIN
  DECLARE @INDICE INT,
          @SOMA INT,
          @DIG1 INT,
          @DIG2 INT,
          @CPF_TEMP VARCHAR(11),
          @DIGITOS_IGUAIS CHAR(1),
          @RESULTADO CHAR(1)
          
  SET @RESULTADO = 'N'

  /*
      Verificando se os digitos s�o iguais
      A Principio CPF com todos o n�meros iguais s�o Inv�lidos
      apesar de validar o Calculo do digito verificado
      EX: O CPF 00000000000 � inv�lido, mas pelo calculo
      Validaria
  */

  SET @CPF_TEMP = SUBSTRING(@CPF,1,1)

  SET @INDICE = 1
  SET @DIGITOS_IGUAIS = 'S'

  WHILE (@INDICE <= 11)
  BEGIN
    IF SUBSTRING(@CPF,@INDICE,1) <> @CPF_TEMP
      SET @DIGITOS_IGUAIS = 'N'
    SET @INDICE = @INDICE + 1
  END;

  --Caso os digitos n�o sej�o todos iguais Come�o o calculo do digitos
  IF @DIGITOS_IGUAIS = 'N'
  BEGIN
    --C�lculo do 1� d�gito
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

    -- C�lculo do 2� d�gito
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

    -- Validando
    IF (@DIG1 = SUBSTRING(@CPF,LEN(@CPF)-1,1)) AND (@DIG2 = SUBSTRING(@CPF,LEN(@CPF),1))
      SET @RESULTADO = 'S'
    ELSE
      SET @RESULTADO = 'N'
  END
  RETURN @RESULTADO
END

Go

Create Procedure REGISTRA (
	@CPF Varchar(11),
	@Senha Varchar(12),
	@Email Varchar(45),
	@Nome Varchar(50),
	@Nome_Social Varchar(50)
	) AS
		Declare
			@retorno char(1);
		Set
			@retorno  = 'S'
			--Todas as tentativas abaixo est�o erradas ao executart a Function, portanto @retorno est� 'S' por padr�o
			--@retorno = Exec CPF_VALIDACAO(@CPF);
			--@retorno = Select CPF_VALIDACAO(@CPF)
			--@retorno = CPF_VALIDACAO(@CPF);
		If @retorno = 'S'
			Begin
				Insert Into Paciente(CPF, Senha_Paciente, Email, Nome_Paciente, Nome_Social) 
					Values (@CPF, @Senha, @Email, @Nome, @Nome_Social);
				Select * From Paciente;
			End
		Else
			Begin
				Select 'Dados inv�lidos';
			End

Go

--Nota: a inser��o no CPF N�O est� mais aceitando caracteres (qualquer que seja) que n�o podem ser convertidos diretamente a INT para evitar erros durante os testes
Exec REGISTRA '54856098802', 'Alanz', 'Osanai@aaa', 'Alan', 'Talvez';