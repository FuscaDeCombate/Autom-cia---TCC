using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Windows.Forms;
using System.Data;

namespace Automácia
{
    public class ClsBanco
    {
        //---------------------------------------------Declaração de Variáveis Necessárias--------------------------------------------
        //----------Variaveis da Conexão com o Banco e Comando----------
        // Variável da Conexão ao Banco
        private static string conexaoBD = 
            "Data Source = " + Environment.MachineName + ((Environment.MachineName == "ALAN") ? "" : @"\SQLEXPRESS") + ";" +
            "Initial Catalog = Automacia;" +
            "Integrated Security = True";

        SqlConnection conn = new SqlConnection(conexaoBD);

        // Variável dos Comandos
        SqlCommand comando = new SqlCommand();



        public ClsBanco()
        {
            try
            {
                conn.Open();
            }
            catch (Exception ex)
            {
                throw new Exception("Erro ao abrir o arquivo:" + ex);
            }
        }



        //---------------------------------------------Parte das Procedures do Banco--------------------------------------------
        //----------Procedures sobre Pacientes----------
        // Cadastra os Histórico Médico
        public String CadastraHistorico(String cpfPaciente, String senhaPaciente, byte[] arquivoHistorico)
        {
            comando.Parameters.Add("@CPF_Rec", SqlDbType.VarChar, 11).Value = cpfPaciente;
            comando.Parameters.Add("@Senha_Paciente_Rec", SqlDbType.VarChar, 256).Value = senhaPaciente;
            comando.Parameters.Add("@Historico_Arqui", SqlDbType.VarBinary).Value = arquivoHistorico;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Insere_Historico";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblRetornoHistorico");

            conn.Close();
            return myDataset.Tables["tblRetornoHistorico"].Rows[0]["Retorno_Registra_Historico"].ToString();
        }

        // Consulta os Histórico Médico
        public DataTable ConsultaHistorico(String cpfPaciente)
        {
            comando.Parameters.Add("@CPF_V_Historico_Pac", SqlDbType.VarChar, 11).Value = cpfPaciente;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Ver_Historico";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblHistorico");

            conn.Close();
            return myDataset.Tables["tblHistorico"];
        }


        //----------Procedures sobre Funcionários----------
        // Cadastra os Funcionários
        public string CadastroFuncionario(string cnpj, int idTipo, string nomeFunc, string senhaFunc)
        {
            comando.Parameters.Add("@CNPJ", SqlDbType.VarChar, 20).Value = cnpj;
            comando.Parameters.Add("@ID_Tipo_Funcionario", SqlDbType.TinyInt).Value = idTipo;
            comando.Parameters.Add("@Nome_Funcionario", SqlDbType.VarChar, 100).Value = nomeFunc;
            comando.Parameters.Add("@Senha_Funcionario", SqlDbType.VarChar, 256).Value = senhaFunc;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Registra_Funcionario";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblRetornoCadastro");

            conn.Close();
            return myDataset.Tables["tblRetornoCadastro"].Rows[0]["Registra_Funcionario_Retorno"].ToString();
        }

        // Consulta os Funcionários
        public DataTable ConsultaFuncionarios(string CNPJ)
        {
            comando.Parameters.Add("@CNPJ_Contratante", SqlDbType.VarChar, 20).Value = CNPJ;
            comando.Parameters.Add("@Mostrar_Inativos", SqlDbType.Bit).Value = 0;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Lista_Funcionarios_Empresa";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblFuncionarios");

            conn.Close();
            return myDataset.Tables["tblFuncionarios"];
        }

        // Login dos Funcionários
        public DataTable LoginFuncionario(int IDFuncionario, string senha)
        {
            comando.Parameters.Add("@ID_Funcionario", SqlDbType.Int).Value = IDFuncionario;
            comando.Parameters.Add("@Senha_Funcionario", SqlDbType.VarChar).Value = senha;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Login_Funcionario";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblResultadoLogin");

            conn.Close();
            return myDataset.Tables["tblResultadoLogin"];
        }

        // Alterar a senha do Funcionário
        public string AlterarFuncionario(int IDFuncionario, string novaSenha, string CNPJ, string senhaContratante)
        {
            comando.Parameters.Add("@ID_Funcionario", SqlDbType.Int).Value = IDFuncionario;
            comando.Parameters.Add("@Nova_Senha", SqlDbType.VarChar, 256).Value = novaSenha;
            comando.Parameters.Add("@CNPJ_Contratante", SqlDbType.VarChar, 20).Value = CNPJ;
            comando.Parameters.Add("@Senha_Contratante", SqlDbType.VarChar, 256).Value = senhaContratante;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Alt_Funcionario";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblResultadoAlter");

            conn.Close();
            return myDataset.Tables["tblResultadoAlter"].Rows[0]["Retorno_Alt_Funcionario"].ToString();
        }

        // Alterar a senha do Funcionário
        public string InativarFuncionario(string CNPJ, string senhaContratante, int IDFuncionario)
        {
            comando.Parameters.Add("@CNPJ_Contratante", SqlDbType.VarChar, 20).Value = CNPJ;
            comando.Parameters.Add("@Senha_Contratante", SqlDbType.VarChar, 256).Value = senhaContratante;
            comando.Parameters.Add("@ID_Funcionario", SqlDbType.Int).Value = IDFuncionario;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Desativa_Funcionario";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblResultadoInativar");

            conn.Close();
            return myDataset.Tables["tblResultadoInativar"].Rows[0]["Retorno_Desativa_Funcionario"].ToString();
        }


        //----------Procedures sobre Receitas----------
        // Criação as Receitas
        public string EmitirReceita(int IDFuncionario, int IDTipo, string senhaFunc, DateTime dataValidade,
                                 string cpfReceita, string medicamento, string detalhes, int limiteBaixas)
        {
            comando.Parameters.Add("@ID_Funcionario", SqlDbType.Int).Value = IDFuncionario;
            comando.Parameters.Add("@Tipo_Funcionario_R", SqlDbType.TinyInt).Value = IDTipo;
            comando.Parameters.Add("@Senha_Funcionario", SqlDbType.VarChar, 32).Value = senhaFunc;
            comando.Parameters.Add("@Data_Validade", SqlDbType.Date).Value = dataValidade;
            comando.Parameters.Add("@CPF_Receita", SqlDbType.VarChar, 11).Value = cpfReceita;
            comando.Parameters.Add("@Medicamento", SqlDbType.VarChar, 100).Value = medicamento;
            comando.Parameters.Add("@Detalhes", SqlDbType.VarChar, 300).Value = detalhes;
            comando.Parameters.Add("@Limite_Baixas", SqlDbType.TinyInt).Value = limiteBaixas;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Registra_Receita";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblRetornoRegistraReceita");

            conn.Close();
            return myDataset.Tables["tblRetornoRegistraReceita"].Rows[0]["Retorno_Registra_Receita"].ToString();
        }

        // Consulta as Receitas
        public DataTable ConsultaReceita(string cpf)
        {
            comando.Parameters.Add("@CPF_Receita", SqlDbType.VarChar, 11).Value = cpf;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Ver_Receita";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblConsultaReceita");

            conn.Close();
            return myDataset.Tables["tblConsultaReceita"];
        }

        // Mostra as Receitas Criadas pelo Médico
        public DataTable ConsultaReceitaFunc(int idFunc)
        {
            comando.Parameters.Add("@ID_Funcionario", SqlDbType.Int).Value = idFunc;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Mostra_Receitas_Func";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblConsultaReceitaFunc");

            conn.Close();
            return myDataset.Tables["tblConsultaReceitaFunc"];
        }

        // Registra o uso das Receitas
        public string RegistrarUso(int IDFuncionario, string senhaFunc, string cpfReceita, int IDReceita)
        {
            comando.Parameters.Add("@ID_Funcionario_Alt", SqlDbType.Int).Value = IDFuncionario;
            comando.Parameters.Add("@Senha_Funcionario_Alt", SqlDbType.VarChar, 32).Value = senhaFunc;
            comando.Parameters.Add("@CPF_Alt", SqlDbType.VarChar, 11).Value = cpfReceita;
            comando.Parameters.Add("@ID_Receita", SqlDbType.Int).Value = IDReceita;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Altera_Receita";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset);

            conn.Close();
            return myDataset.Tables[myDataset.Tables.Count - 1].Rows[0]["Retorno_Altera_Receita"].ToString();
        }

        // Mostra as Baixas das Receitas feitas pelo Farmaceutico
        public DataTable ConsultaBaixas(int idFunc)
        {
            comando.Parameters.Add("@ID_Funcionario_Ba", SqlDbType.Int).Value = idFunc;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Mostra_Baixas";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblConsultaBaixas");

            conn.Close();
            return myDataset.Tables["tblConsultaBaixas"];
        }

        // Atualiza as Receitas
        public string AtualizaReceita()
        {
            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Atualiza_Receita";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset);

            conn.Close();
            return myDataset.Tables[myDataset.Tables.Count - 1].Rows[0]["Retorno_Atualiza_Receita"].ToString();
        }


        //----------Procedures sobre Chat----------
        // Mostra o Chat
        public DataTable MostraChat(string cpfPaciente, int IDFuncionario)
        {
            comando.Parameters.Add("@CPF_M_Chat", SqlDbType.VarChar, 11).Value = cpfPaciente;
            comando.Parameters.Add("@ID_Funcionario_M_Chat", SqlDbType.Int).Value = IDFuncionario;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Mostra_Chat";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblMostraChat");

            conn.Close();
            return myDataset.Tables["tblMostraChat"];
        }

        // Envia as Mensagens
        public string EnviaMensagem(string cpfPaciente, int IDFuncionario, string mensagem)
        {
            comando.Parameters.Add("@ID_Receptor", SqlDbType.VarChar, 11).Value = cpfPaciente;
            comando.Parameters.Add("@ID_Mensageiro", SqlDbType.Int).Value = IDFuncionario;
            comando.Parameters.Add("@Mensagem", SqlDbType.VarChar, 500).Value = mensagem;

            comando.CommandType = CommandType.StoredProcedure;
            comando.CommandText = "Envia_Mensagem_F";
            comando.Connection = conn;

            DataSet myDataset = new DataSet();

            SqlDataAdapter myAdapter = new SqlDataAdapter(comando);

            myAdapter.Fill(myDataset, "tblEnviaMensagem");

            conn.Close();
            return myDataset.Tables["tblEnviaMensagem"].Rows[0]["Mensagem_Retorno_F"].ToString();
        }
    }
}
